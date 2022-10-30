#!/usr/bin/env python3
import xml.etree.ElementTree as ElementTree
import math, os, re, sys

from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict

from ca65 import pretty_print_table, ca65_label, ca65_byte_literal, ca65_word_literal
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

BLANK_TILE = TiledTile(tiled_index=0, ordinal_index=0, integer_properties={}, boolean_properties={}, string_properties={}, type="")

@dataclass
class Layout:
    name: str
    width: int
    height: int
    tiles: [TiledTile]
    
def read_boolean_properties(tile_element):
    boolean_properties = {}
    properties_element = tile_element.find("properties")
    if properties_element:
        for prop in properties_element.findall("property"):
            if prop.get("type") == "bool":
                boolean_properties[prop.get("name")] = (prop.get("value") == "true")
    return boolean_properties

def read_integer_properties(parent_element):
    integer_properties = {}
    properties_element = parent_element.find("properties")
    if properties_element:
        for prop in properties_element.findall("property"):
            if prop.get("type") == "int":
                integer_properties[prop.get("name")] = int(prop.get("value"))
    return integer_properties

def read_string_properties(parent_element):
    string_properties = {}
    properties_element = parent_element.find("properties")
    if properties_element:
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

def nice_label(full_path_and_filename):
  (_, plain_filename) = os.path.split(full_path_and_filename)
  (base_filename, _) = os.path.splitext(plain_filename)
  safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)
  return safe_label

def read_layout(map_filename):
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

    # (hack: this converter only expects one layer, so ignore the name)
    only_layer = None
    layer_elements = map_element.findall("layer")
    for layer_element in layer_elements:
        only_layer = read_layer(layer_element, tilesets)

  

    # finally let's make the name something useful
    (_, plain_filename) = os.path.split(map_filename)
    (base_filename, _) = os.path.splitext(plain_filename)
    safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)

    return Layout(name=safe_label, width=map_width, height=map_height, tiles=only_layer)

def layout_bytes(tilemap):
  raw_bytes = []
  for tile in tilemap.tiles:
    raw_bytes.append(tile.integer_properties["enemy_index"])
  return raw_bytes

def write_layout(tilemap, output_file):
    output_file.write(ca65_label(tilemap.name) + "\n")
    pretty_print_table(layout_bytes(tilemap), output_file, tilemap.width)
    
if __name__ == '__main__':
    # DEBUG TEST THINGS
    if len(sys.argv) != 3:
      print("Usage: layout.py input.tmx output.txt")
      sys.exit(-1)
    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    tilemap = read_layout(input_filename)

    with open(output_filename, "w") as output_file:
      write_layout(tilemap, output_file)