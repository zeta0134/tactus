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
class Floor:
    name: str
    width: int
    height: int
    tiles: [TiledTile]
    min_challenge_rooms: int
    max_challenge_rooms: int
    min_shop_rooms: int
    max_shop_rooms: int
    
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
    graphics_layer = layers.pop("Maze Shape")
    supplementary_layers = layers

    combined_tiles = []
    for tile_index in range(0, len(graphics_layer)):
        graphics_tile = graphics_layer[tile_index]
        supplementary_tiles = [supplementary_layers[layer_name][tile_index] for layer_name in supplementary_layers]
        combined_tiles.append(combine_tile_properties(graphics_tile, supplementary_tiles))
    return combined_tiles

def read_floor(map_filename):
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

    # TODO: other global properties of the floor would go here
    # (there aren't any yet)
    integer_properties = read_integer_properties(map_element)
    min_challenge_rooms = integer_properties.get("min_challenge_rooms", 1)
    max_challenge_rooms = integer_properties.get("max_challenge_rooms", 1)
    min_shop_rooms = integer_properties.get("min_shop_rooms", 0)
    max_shop_rooms = integer_properties.get("max_shop_rooms", 0)

    # finally let's make the name something useful
    (_, plain_filename) = os.path.split(map_filename)
    (base_filename, _) = os.path.splitext(plain_filename)
    safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)

    return Floor(name=safe_label, width=map_width, height=map_height, tiles=combined_tiles,
        min_challenge_rooms=min_challenge_rooms, max_challenge_rooms=max_challenge_rooms,
        min_shop_rooms=min_shop_rooms, max_shop_rooms=max_shop_rooms)

def tile_exit_flag_bytes(tiles):
  raw_bytes = []
  for tile in tiles:
    exit_flags = 0
    flags = tile.boolean_properties
    if tile.boolean_properties.get("exit_north", False):
        exit_flags |= 0b0001 # Never
    if tile.boolean_properties.get("exit_east", False):
        exit_flags |= 0b0010 # Eat
    if tile.boolean_properties.get("exit_south", False):
        exit_flags |= 0b0100 # Soggy
    if tile.boolean_properties.get("exit_west", False):
        exit_flags |= 0b1000 # Waffles
    if tile.boolean_properties.get("forbid_spawning", False):
        exit_flags |= 0b1000_0000
    # TODO: if there are other flags, check for those here
    raw_bytes.append(ca65_byte_literal(exit_flags))
  return raw_bytes

def tile_room_pool_bytes(tiles):
  raw_bytes = []
  for tile in tiles:
    raw_bytes.append(tile.string_properties.get("room_pool", "ERROR_NO_ROOM_POOL"))
  return raw_bytes

def write_floor(tilemap, output_file):
    output_file.write(ca65_label("floor_"+tilemap.name) + "\n")
    output_file.write("  ; Room Pools\n")
    pretty_print_table_str(tile_room_pool_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write("  ; Exits/Flags\n")
    pretty_print_table_str(tile_exit_flag_bytes(tilemap.tiles), output_file, tilemap.width)
    output_file.write(f"  .byte {tilemap.min_challenge_rooms} ; Min Challenge Rooms\n")
    output_file.write(f"  .byte {tilemap.max_challenge_rooms} ; Max Challenge Rooms\n")
    output_file.write(f"  .byte {tilemap.min_shop_rooms} ; Min Shop Rooms\n")
    output_file.write(f"  .byte {tilemap.max_shop_rooms} ; Max Shop Rooms\n")
    output_file.write("\n")
    
if __name__ == '__main__':
    # DEBUG TEST THINGS
    if len(sys.argv) != 3:
      print("Usage: floor.py input.tmx output.txt")
      sys.exit(-1)
    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    tilemap = read_floor(input_filename)

    with open(output_filename, "w") as output_file:
      write_floor(tilemap, output_file)