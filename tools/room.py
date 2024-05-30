#!/usr/bin/env python3
import xml.etree.ElementTree as ElementTree
import math, os, re, sys

from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict

from ca65 import pretty_print_table, pretty_print_table_str, ca65_label, ca65_byte_literal, ca65_word_literal
from compress import compress_smallest

# === Data Types ===
# Note: concerned with data for map conversion only. We ignore everything else.
# Graphics conversion is a separate step entirely.

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
class Room:
    name: str
    width: int
    height: int
    tiles: [TiledTile]
    overlays: Dict[str, TiledTile]
    exit_id: int
    dark: bool
    forbid_spawning: bool
    category: str
    bg_palette: str
    obj_palette: str
    
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

def read_room(map_filename):
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

    # now read any tile groups; these are named overlays, which we'll need to parse
    # like additional collections of layers
    overlays = {}
    tile_groups = map_element.findall("group")
    for tile_group in tile_groups:
        overlay_name = tile_group.get("name")
        overlay_layers = tile_group.findall("layer")
        overlay_tiles = read_and_combine_layers(overlay_layers, tilesets)
        overlays[overlay_name] = overlay_tiles

    # construct the exit ID from the four exit booleans, if present
    exit_id = 0
    flags = read_boolean_properties(map_element)
    if "exit_north" in flags and flags["exit_north"] == True:
        exit_id |= 0b0001 # Never
    if "exit_east" in flags and flags["exit_east"] == True:
        exit_id |= 0b0010 # Eat
    if "exit_south" in flags and flags["exit_south"] == True:
        exit_id |= 0b0100 # Soggy
    if "exit_west" in flags and flags["exit_west"] == True:
        exit_id |= 0b1000 # Waffles
    is_dark = flags.get("dark", False)
    forbid_spawning = flags.get("forbid_spawning", False)
    string_properties = read_string_properties(map_element)
    category = string_properties.get("category", "exterior")

    string_properties = read_string_properties(map_element)
    room_bg_palette = string_properties.get("room_palette","grassy_palette")
    room_obj_palette = string_properties.get("room_obj_palette","sprite_palette_overworld")

    # finally let's make the name something useful
    (_, plain_filename) = os.path.split(map_filename)
    (base_filename, _) = os.path.splitext(plain_filename)
    safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)

    return Room(name=safe_label, width=map_width, height=map_height, tiles=combined_tiles, overlays=overlays,
        exit_id=exit_id, bg_palette=room_bg_palette, obj_palette=room_obj_palette, dark=is_dark, category=category,
        forbid_spawning=forbid_spawning)

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
        raw_bytes.append(f">({tile.string_properties["tile_id"]} | ${palette_index:02X})")
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
            raw_bytes.append(f"TILE_REGULAR_FLOOR")
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
    else:
        raw_bytes.append("$00")
  return raw_bytes

valid_overlays = [
"Overlay: Interior - North",
"Overlay: Interior - East",
"Overlay: Interior - South",
"Overlay: Interior - West",
"Overlay: Exterior - North",
"Overlay: Exterior - East",
"Overlay: Exterior - South",
"Overlay: Exterior - West",
"Overlay: Challenge - North",
"Overlay: Challenge - East",
"Overlay: Challenge - South",
"Overlay: Challenge - West",
"Overlay: Shop - North",
"Overlay: Shop - East",
"Overlay: Shop - South",
"Overlay: Shop - West",
]

def write_overlay(overlay_tiles, output_file):
    overlay_tile_id_bytes = tile_id_bytes(overlay_tiles)
    overlay_tile_attr_bytes = tile_attr_bytes(overlay_tiles)
    overlay_behavior_id_bytes = behavior_id_bytes(overlay_tiles)
    overlay_behavior_flag_bytes = behavior_flag_bytes(overlay_tiles)

    for tile_id in range(0, len(overlay_tiles)):
        candidate_tile = overlay_tiles[tile_id]
        if candidate_tile.type == "blank":
            # YOU SHALL NOT
            pass
        else:
            output_file.write(f"  .byte {ca65_byte_literal(tile_id)}, ")
            output_file.write(f"{overlay_tile_id_bytes[tile_id]}, ")
            output_file.write(f"{overlay_tile_attr_bytes[tile_id]}, ")
            output_file.write(f"{overlay_behavior_id_bytes[tile_id]}, ")
            output_file.write(f"{overlay_behavior_flag_bytes[tile_id]}\n")
    output_file.write("  .byte $FF ; end of overlay\n\n")

category_ids = {
    "exterior": 0,
    "interior": 1,
    "challenge": 2,
    "shop": 3,
}

def write_room(tilemap, output_file):
    properties_byte = 0
    if tilemap.dark:
        properties_byte |= 0x40
    if tilemap.forbid_spawning:
        properties_byte |= 0x80
    properties_byte |= (category_ids[tilemap.category] << 4)
    output_file.write(ca65_label("room_"+tilemap.name) + "\n")
    output_file.write("  .byte " + ca65_byte_literal(properties_byte) + " ; property flags\n")
    output_file.write("  .byte " + ca65_byte_literal(tilemap.exit_id) + " ; supported exits\n")
    output_file.write("  .addr " + tilemap.bg_palette + " ; BG palette for this room\n")
    output_file.write("  .addr " + tilemap.obj_palette + " ; OBJ palette for this room\n")
    output_file.write("  ; Overlays\n")
    for overlay_name in valid_overlays:
        if overlay_name in tilemap.overlays:
            output_file.write(f"  .addr room_{tilemap.name}_{safe_label(overlay_name)} ; {overlay_name}\n")
        else:
            output_file.write(f"  .addr $0000 ; {overlay_name}\n")
    output_file.write("  ; Drawn Tile IDs, LOW\n")
    pretty_print_table_str(tile_id_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write("  ; Drawn Tile IDs, HIGH + Attributes\n")
    pretty_print_table_str(tile_attr_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write("  ; Behavior IDs\n")
    pretty_print_table_str(behavior_id_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write("  ; Special Flags\n")
    pretty_print_table_str(behavior_flag_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write("\n")
    for overlay_name in valid_overlays:
        if overlay_name in tilemap.overlays:
            output_file.write(f"room_{tilemap.name}_{safe_label(overlay_name)}:\n")
            write_overlay(tilemap.overlays[overlay_name], output_file)
    output_file.write("\n")
    
if __name__ == '__main__':
    # DEBUG TEST THINGS
    if len(sys.argv) != 3:
      print("Usage: room.py input.tmx output.txt")
      sys.exit(-1)
    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    tilemap = read_room(input_filename)

    with open(output_filename, "w") as output_file:
      write_room(tilemap, output_file)