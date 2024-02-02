#!/usr/bin/env python3
from PIL import Image
import pathlib, math

def bits_to_byte(bit_array):
  byte = 0
  for i in range(0,8):
    byte = byte << 1;
    byte = byte + bit_array[i];
  return byte

def hardware_tile_to_bitplane(index_array):
  # Note: expects an 8x8 array of palette indices. Returns a 16-byte array of raw NES data
  # which encodes this tile's data as a bitplane for the PPU hardware
  low_bits = [x & 0x1 for x in index_array]
  high_bits = [((x & 0x2) >> 1) for x in index_array]
  low_bytes = [bits_to_byte(low_bits[i:i+8]) for i in range(0,64,8)]
  high_bytes = [bits_to_byte(high_bits[i:i+8]) for i in range(0,64,8)]
  return low_bytes + high_bytes

def convert_to_chr(image):
  chr_tiles = []
  for metatile_x in range(0, 4):
    for metatile_y in range(0, 4):
      for tile_x in range(0, 2):
        for tile_y in range(0, 2):
          left = metatile_x * 16 + tile_x * 8
          top = metatile_y * 16 + tile_y * 8
          right = left + 8
          bottom = top + 8
          chr_tiles.append(hardware_tile_to_bitplane(im.crop(left, top, right, bottom).getdata()))
  chr_bytes = []
  for tile in chr_tiles:
    chr_bytes = chr_bytes + tile
  return chr_bytes

def duplicate_static_frames(image):
  if image.width == 64:
    return image
  # for CHR ROM layout reasons, non-animated tiles need to be copied 4 times just
  # like the animated ones, so do that here
  new_image = Image.new(image.mode, (64, image.height))
  new_image.putpalette(image.palette.getdata()[1])
  new_image.paste(image, (0, 0))
  new_image.paste(image, (16, 0))
  new_image.paste(image, (32, 0))
  new_image.paste(image, (48, 0))
  return new_image

def generate_lighting_variants(image):
  if image.height == 64:
    return image
  new_image = Image.new(image.mode, (image.width, 64))
  new_image.putpalette(image.palette.getdata()[1])
  # first duplicate the original image four times
  new_image.paste(image, (0, 0))
  new_image.paste(image, (0, 16))
  new_image.paste(image, (0, 32))
  new_image.paste(image, (0, 48))
  # now subtract the metatile row from each palette index, to darken
  # each pixel by one shade
  for x in range(0, 64):
    for y in range(0, 64):
      metatile_row = math.floor(y / 16)
      old_palette_index = new_image.getpixel((x, y))
      adjusted_palette_index = old_palette_index - metatile_row
      new_image.putpixel((x, y), adjusted_palette_index)
  return new_image

def read_tile(filename):
  im = Image.open(filename)
  assert im.getpalette() != None, "Non-paletted tile found! This is unsupported: " + filename
  assert im.width in [16,64], "Tiles must be 16 or 64 pixels wide! Bailing. " + filename
  assert im.height in [16,64], "All tiles must be 16 or 64 pixels tall! Bailing. " + filename
  # if this image is smaller than full size, perform necessary transformations to get it ready
  # for the game's format
  if im.width == 16:
    im = duplicate_static_frames(im)
  if im.height == 16:
    im = generate_lighting_variants(im)
  return im

sprite_filenames = list(pathlib.Path('../art/sprite_tiles').glob('*.png'))
background_filenames = list(pathlib.Path('../art/background_tiles').glob('*.png'))

for background_filename in background_filenames:
  expanded_tile = read_tile(background_filename)
  test_destination = "../art/expanded_tiles/"+background_filename.name
  expanded_tile.save(test_destination)




