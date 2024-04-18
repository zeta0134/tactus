#!/usr/bin/env python3

from PIL import Image
import pathlib, math, os, re, sys


def is_animated(im):
    cel_width = math.floor(im.width / 4)
    for x in range(0, cel_width):
        for y in range(0, im.height):
            candidate_pixels = [
                im.getpixel((x+cel_width*0, y)),
                im.getpixel((x+cel_width*1, y)),
                im.getpixel((x+cel_width*2, y)),
                im.getpixel((x+cel_width*3, y))]
            if len(set(candidate_pixels)) > 1:
                return True
    return False

def has_lighting(im):
    for x in range(0, im.width):
        for y in range(16, im.height):
            if im.getpixel((x, y)) != 0:
                return True
    return False

def construct_single_tile(atlas, x, y):
    unexpanded_width = math.floor(atlas.width / 4);
    unexpanded_height = math.floor(atlas.height / 4);

    combined_tile = Image.new(atlas.mode, (64, 64))
    combined_tile.putpalette(atlas.palette.getdata()[1])
    for ax in range(0, 4):
        for ly in range(0, 4):
            left = x + ax*unexpanded_width
            right = left+16
            top = y + ly*unexpanded_height
            bottom = top+16
            single_cel = atlas.crop((left, top, right, bottom))
            combined_tile.paste(single_cel, (ax*16, ly*16))
    if not has_lighting(combined_tile):
        combined_tile = combined_tile.crop((0, 0, combined_tile.width, 16))
    if not is_animated(combined_tile):
        combined_tile = combined_tile.crop((0, 0, 16, combined_tile.height))
    return combined_tile

def construct_tiles(atlas_filename):
    atlas = Image.open(atlas_filename)
    assert atlas.getpalette() != None, "Non-paletted tile found! This is unsupported: " + atlas_filename
    assert atlas.width % 64 == 0, "Width must be a multiple of 4 16x16 tiles" + atlas_filename
    assert atlas.height % 64 == 0, "Height must be a multiple of 4 16x16 tiles" + atlas_filename

    tiles = []
    tile_width = math.floor((atlas.width / 4) / 16)
    tile_height = math.floor((atlas.height / 4) / 16)
    for y in range(0, tile_height):
        for x in range(0, tile_width):
            tiles.append(construct_single_tile(atlas, x*16, y*16))
    return tiles

def write_all_tiles(tiles, output_directory, file_prefix):
    os.makedirs(output_directory,exist_ok=True)
    for i in range(0, len(tiles)):
        filename = f"{output_directory}/{file_prefix}_{i:04}.png"
        tiles[i].save(filename)

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("Usage: build_map_tiles.py input.png output_directory")
    sys.exit(-1)
  input_filename = sys.argv[1]
  output_directory = sys.argv[2]

  file_prefix = str(pathlib.PurePath(pathlib.PurePath(input_filename).name).stem)

  tiles = construct_tiles(input_filename)
  write_all_tiles(tiles, output_directory, file_prefix)
