#!/usr/bin/env python3
import xml.etree.ElementTree as ElementTree
import math, os, re, sys

from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict

from ca65 import pretty_print_table, pretty_print_table_str, ca65_label, ca65_byte_literal, ca65_word_literal
from compress import compress_smallest

# A structure is basically like a single layer of a room, with an extra pseudo-layer
# describing preflight checks before the structure is drawn. The requirements layer
# houses just behavioral IDs in a grid, all of which must match for the structure to
# be considered valid at a given location.

# Structures are (usually) smaller than maps, so we encode some extra data in their output
# to help the game engine randomly choose an offset for each generation attempt.

# Base tiles, read directly from a tileset
@dataclass
class TiledTile:
    tiled_index: int
    ordinal_index: int
    type: str
    integer_properties: Dict[str, int]
    boolean_properties: Dict[str, bool]
    string_properties: Dict[str, str]

@dataclass
class TiledTileSet:
    name: str
    first_gid: int
    tiles: Dict[int, TiledTile]
    string_properties: Dict[str, str]

BLANK_TILE = TiledTile(tiled_index=0, ordinal_index=0, integer_properties={}, boolean_properties={}, string_properties={}, type="blank")

@dataclass
class Structure:
    name: str
    width: int
    height: int
    tiles: [TiledTile]
    requirements: [TiledTile]
    avoid_edges: bool
    
def read_boolean_properties(tile_element):
    boolean_properties = {}
    properties_element = tile_element.find("properties")
    if properties_element is not None:
        for prop in properties_element.findall("property"):
            if prop.get("type") == "bool":
                boolean_properties[prop.get("name")] = (prop.get("value") == "true")
    return boolean_properties

def read_integer_properties(parent_element):
    integer_properties = {}
    properties_element = parent_element.find("properties")
    if properties_element is not None:
        for prop in properties_element.findall("property"):
            if prop.get("type") == "int":
                integer_properties[prop.get("name")] = int(prop.get("value"))
    return integer_properties

def read_string_properties(parent_element):
    string_properties = {}
    properties_element = parent_element.find("properties")
    if properties_element is not None:
        for prop in properties_element.findall("property"):
            if prop.get("type") == None or prop.get("type") == "string":
                string_properties[prop.get("name")] = prop.get("value")
    return string_properties

def read_tileset(tileset_filename, first_gid=0, name=""):
    tileset_element = ElementTree.parse(tileset_filename).getroot()
    tile_elements = tileset_element.findall("tile")
    tiles = {}
    for ordinal_index in range(0, len(tile_elements)):
        tile_element = tile_elements[ordinal_index]
        tiled_index = int(tile_element.get("id"))
        tiled_type = tile_element.get("type")
        boolean_properties = read_boolean_properties(tile_element)
        integer_properties = read_integer_properties(tile_element)
        string_properties = read_string_properties(tile_element)
        tiled_tile = TiledTile(ordinal_index=ordinal_index, tiled_index=tiled_index, boolean_properties=boolean_properties, integer_properties=integer_properties, string_properties=string_properties, type=tiled_type)
        tiles[tiled_index] = tiled_tile
    string_properties = read_string_properties(tileset_element)

    tileset = TiledTileSet(first_gid=first_gid, tiles=tiles, name=name, string_properties=string_properties)
    return tileset

def tile_from_gid(tile_index, tilesets):
    for tileset in reversed(tilesets):
        if tileset.first_gid <= tile_index:
            tileset_index = tile_index - tileset.first_gid
            return tileset.tiles.get(tileset_index, BLANK_TILE)
    return BLANK_TILE

def tileset_from_gid(tile_index, tilesets):
    for tileset in reversed(tilesets):
        if tileset.first_gid <= tile_index:
            return tileset
    return None

def read_layer(layer_element, tilesets):
    data = layer_element.find("data")
    if data.get("encoding") == "csv":
        cell_values = [int(x) for x in data.text.split(",")]
        tiles = [tile_from_gid(x, tilesets) for x in cell_values]
        return tiles
    exiterror("Non-csv encoding is not supported.")

def safe_label(arbitrary_str):
    return re.sub(r'[^A-Za-z0-9\_]', '_', arbitrary_str)

def nice_label(full_path_and_filename):
    (_, plain_filename) = os.path.split(full_path_and_filename)
    (base_filename, _) = os.path.splitext(plain_filename)
    return safe_label(base_filename)

def combine_tile_properties(graphics_tile, supplementary_tiles):
    combined_tile = TiledTile(
        ordinal_index=graphics_tile.ordinal_index,
        tiled_index=graphics_tile.tiled_index,
        boolean_properties=dict(graphics_tile.boolean_properties),
        integer_properties=dict(graphics_tile.integer_properties),
        string_properties=dict(graphics_tile.string_properties),
        type=graphics_tile.type
    )
    for supplementary_tile in supplementary_tiles:
        combined_tile.integer_properties = combined_tile.integer_properties | supplementary_tile.integer_properties
        combined_tile.boolean_properties = combined_tile.boolean_properties | supplementary_tile.boolean_properties
        combined_tile.string_properties = combined_tile.string_properties | supplementary_tile.string_properties
    return combined_tile

# Given a list of layer elements, parses the layer contents, then
# combines common attributes, using the "Base" layer as a base.
def read_and_combine_layers(layer_elements, tilesets):
    layers = {}
    for layer_element in layer_elements:
        layers[layer_element.get("name")] = read_layer(layer_element, tilesets)

    # At this point we should have at least one layer named "Base", if we don't
    # we can't continue and must bail
    graphics_layer = layers.pop("Base")
    supplementary_layers = layers

    combined_tiles = []
    for tile_index in range(0, len(graphics_layer)):
        graphics_tile = graphics_layer[tile_index]
        supplementary_tiles = [supplementary_layers[layer_name][tile_index] for layer_name in supplementary_layers]
        combined_tiles.append(combine_tile_properties(graphics_tile, supplementary_tiles))
    return combined_tiles

def read_structure(map_filename):
    map_element = ElementTree.parse(map_filename).getroot()
    map_width = int(map_element.get("width"))
    map_height = int(map_element.get("height"))

    # First read in all tilesets referenced by this map, making note of their
    # first gids
    tilesets = []
    tileset_elements = map_element.findall("tileset")
    for tileset_element in tileset_elements:
        first_gid = int(tileset_element.get("firstgid"))
        relative_path = tileset_element.get("source")
        base_path = Path(map_filename).parent
        tileset_path = (base_path / relative_path).resolve()
        tileset = read_tileset(tileset_path, first_gid, nice_label(tileset_path))
        tilesets.append(tileset)
    
    # then read in all map layers. Using the raw index data and the first gids, we can
    # translate the lists to the actual tiles they reference
    layers = map_element.findall("layer")
    combined_tiles = read_and_combine_layers(layers, tilesets)

    # now look for a tile group, which houses the requirements for this structure
    # (consider it an error if a structure lacks, or has more than one of these layers)
    tile_groups = map_element.findall("group")
    assert len(tile_groups) == 1, "wrong number of tile groups in structure"
    requirement_layers = tile_groups[0].findall("layer")
    requirement_tiles = read_and_combine_layers(requirement_layers, tilesets)

    boolean_properties = read_string_properties(map_element)
    avoid_edges = boolean_properties.get("avoid_map_edge", True)

    # finally let's make the name something useful
    (_, plain_filename) = os.path.split(map_filename)
    (base_filename, _) = os.path.splitext(plain_filename)
    safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)

    return Structure(name=safe_label, width=map_width, height=map_height, 
        requirements=requirement_tiles ,tiles=combined_tiles, avoid_edges=avoid_edges)

def tile_id_bytes(tiles):
  raw_bytes = []
  for tile in tiles:
    if "tile_id" in tile.string_properties:
        raw_bytes.append(f"<{tile.string_properties["tile_id"]}")
    else:
        if tile.type == "floor":
            raw_bytes.append(f"<BG_TILE_DISCO_FLOOR_TILES_{tile.tiled_index:04}")
        elif tile.type == "map":
            raw_bytes.append(f"<BG_TILE_MAP_TILES_{tile.tiled_index:04}")
        elif tile.type == "detail":
            raw_bytes.append(f"<{tile.string_properties.get('detail')}")
        elif tile.type == "blank":
            raw_bytes.append(f"ERROR_BLANK_TILE")
        else:
            print(f"Unrecognized tile type: {tile.type}, activating my panic and spin routines. PANIC AND SPIN!")
            sys.exit(-1)
  return raw_bytes

def tile_attr_bytes(tiles):
  # TODO: color attributes, somehow?
  raw_bytes = []
  for tile in tiles:
    palette_index = tile.integer_properties.get("palette_index",0) << 6
    if "tile_id" in tile.string_properties:
        raw_bytes.append(f">({tile.string_properties["tile_id"]}) | ${palette_index:02X}")
    else:
        if tile.type == "floor":
            raw_bytes.append(f">(BG_TILE_DISCO_FLOOR_TILES_{tile.tiled_index:04}) | ${palette_index:02X}")
        elif tile.type == "map":
            raw_bytes.append(f">(BG_TILE_MAP_TILES_{tile.tiled_index:04}) | ${palette_index:02X}")
        elif tile.type == "detail":
            raw_bytes.append(f"${palette_index:02X}")
        elif tile.type == "blank":
            raw_bytes.append(f"ERROR_BLANK_TILE")
        else:
            print(f"Unrecognized tile type: {tile.type}, activating my panic and spin routines. PANIC AND SPIN!")
            sys.exit(-1)
  return raw_bytes

def behavior_id_bytes(tiles):
  # TODO: tile properties should be able to override this. Individual tiles should be able
  # to override those... somehow. Punting complexity to my future self? Wheeee!
  raw_bytes = []
  for tile in tiles:
    if "behavior" in tile.string_properties:
        raw_bytes.append(tile.string_properties["behavior"])
    else:
        if tile.type == "floor":
            raw_bytes.append(f"TILE_DISCO_FLOOR")
        elif tile.type == "map":
            raw_bytes.append(f"TILE_WALL")
        elif tile.type == "blank":
            raw_bytes.append(f"ERROR_BLANK_TILE")
        else:
            print(f"Unrecognized tile type: {tile.type}, activating my panic and spin routines. PANIC AND SPIN!")
            sys.exit(-1)
  return raw_bytes

def behavior_flag_bytes(tiles):
  # TODO: yeah all of this
  raw_bytes = []
  for tile in tiles:
    if tile.type == "detail":
        raw_bytes.append(f"TILE_FLAG_DETAIL")
    elif tile.type == "exit":
        raw_bytes.append(f"TILE_FLAG_EXIT")
    else:
        raw_bytes.append("$00")
  return raw_bytes

# kinda similar to write overlay, except 
def write_structure_tiles(structure, output_file):
    structure_tile_id_bytes = tile_id_bytes(structure.tiles)
    structure_tile_attr_bytes = tile_attr_bytes(structure.tiles)
    structure_behavior_id_bytes = behavior_id_bytes(structure.tiles)
    structure_behavior_flag_bytes = behavior_flag_bytes(structure.tiles)

    structure_position_bytes = []
    structure_distances = []
    for x in range(0, structure.width):
        for y in range(0, structure.height):
            # the map index is based on the larger room size
            map_index = y * 16 + x
            structure_position_bytes.append(map_index)

    for i in range(0, len(structure.tiles)):
        candidate_tile = structure.tiles[i]
        if candidate_tile.type == "blank":
            # YOU SHALL NOT
            pass
        else:
            output_file.write(f"  .byte {structure_position_bytes[i]}, ")
            output_file.write(f"{structure_tile_id_bytes[i]}, ")
            output_file.write(f"{structure_tile_attr_bytes[i]}, ")
            output_file.write(f"{structure_behavior_id_bytes[i]}, ")
            output_file.write(f"{structure_behavior_flag_bytes[i]}\n")
    output_file.write("  .byte $FF ; end of structure tiles\n\n")


def write_requirements(structure, output_file):
    requirements_behavior_id_bytes = behavior_id_bytes(structure.requirements)
    requirements = []
    for x in range(0, structure.width):
        for y in range(0, structure.height):
            # the map index is based on the larger room size
            structure_index = y * structure.width + x
            map_index = y * 16 + x
            if requirements_behavior_id_bytes[structure_index] != "ERROR_BLANK_TILE":
                # the distance is based on the smaller structure size
                cx = structure.width / 2.0
                cy = structure.height / 2.0
                distance = math.hypot(x-cx, y-cy)
                requirements.append((requirements_behavior_id_bytes[structure_index], map_index, distance))
    sorted_requirements = sorted(requirements, key=lambda requirement: requirement[2], reverse=True)

    for requirement in sorted_requirements:
        output_file.write(f"  .byte {requirement[1]}, {requirement[0]}; index, behavior_id\n")
    output_file.write("  .byte $FF ; end of requirements\n\n")

def position_bounds(structure):
    min_x = 0
    min_y = 0
    max_x = 16 - structure.width
    max_y = 11 - structure.height
    if structure.avoid_edges == True:
        min_x += 1
        min_y += 1
        max_x -= 1
        max_y -= 1
    assert max_x >= min_x, "structure too wide to spawn!"
    assert max_y >= min_y, "structure too tall to spawn!"
    return min_x, max_x, min_y, max_y


def write_structure(structure, output_file):
    output_file.write(ca65_label("structure_"+structure.name) + "\n")
    min_x, max_x, min_y, max_y = position_bounds(structure)
    output_file.write(f"  .byte {min_x}; MinPosX\n")
    output_file.write(f"  .byte {max_x}; MaxPosX\n")
    output_file.write(f"  .byte {min_y}; MinPosY\n")
    output_file.write(f"  .byte {max_y}; MaxPosY\n")
    output_file.write("  .addr " + "structure_"+structure.name+"_tiles; tile list\n")
    output_file.write("  .addr " + "structure_"+structure.name+"_requirements; requirements list\n\n")
    # TODO: min/max, other properties, etc

    output_file.write(ca65_label("structure_"+structure.name+"_tiles") + "\n")
    write_structure_tiles(structure, output_file)
    output_file.write(ca65_label("structure_"+structure.name+"_requirements") + "\n")
    write_requirements(structure, output_file)

if __name__ == '__main__':
    # DEBUG TEST THINGS
    if len(sys.argv) != 3:
      print("Usage: structure.py input.tmx output.txt")
      sys.exit(-1)
    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    structure = read_structure(input_filename)

    with open(output_filename, "w") as output_file:
      write_structure(structure, output_file)


