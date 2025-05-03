#!/usr/bin/env python3

# Extremely custom generator for the title text and pretty much nothing else.

from PIL import Image
import pathlib, math, os, re, sys
from ca65 import ca65_byte_literal, ca65_word_literal, pretty_print_table

# Layer samplers: these all accept the X/Y **source** pixel and the
# animation frame. Distortions should be applied here and nowhere else.
# Each layer has its own idea of "transparent" as well.

BG_OFFSET        = 240 * 0
LOW_FLAME_OFFSET = 240 * 1
MID_FLAME_OFFSET = 240 * 2
HI_FLAME_OFFSET  = 240 * 3
TEXT_OFFSET      = 240 * 4
MASK_OFFSET      = 240 * 5

def in_range_x(x):
  return max(0, min(255, x))

def in_range_y(y):
  return max(0, min(239, y))

def sample_text_layer(image, x, y, animation_frame):
  window_px = image.getpixel((x, y + TEXT_OFFSET))
  mask_px = image.getpixel((x, y + MASK_OFFSET))
  is_transprent = (mask_px == 4)
  return (window_px, is_transprent)

def sample_background_layer(image, x, y, animation_frame):
  px = image.getpixel((x, y + BG_OFFSET))
  is_transprent = False
  return (px, is_transprent)

def sample_low_flame_layer(image, x, y, animation_frame):
  target_x = in_range_x(x + animation_frame)
  target_y = y
  px = image.getpixel((target_x, target_y + LOW_FLAME_OFFSET))
  is_transprent = (px == 0) or (px > 3)
  return (px, is_transprent)

def sample_mid_flame_layer(image, x, y, animation_frame):
  target_x = in_range_x(x - animation_frame)
  target_y = y
  px = image.getpixel((target_x, target_y + MID_FLAME_OFFSET))
  is_transprent = (px == 0) or (px > 3)
  return (px, is_transprent)

def sample_high_flame_layer(image, x, y, animation_frame):
  target_x = in_range_x(x + animation_frame)
  target_y = y
  px = image.getpixel((target_x, target_y + HI_FLAME_OFFSET))
  is_transprent = (px == 0) or (px > 3)
  return (px, is_transprent)

# Put it all together and what do you get?
def sample_layers(image, x, y, animation_frame):
  (window_px, window_is_transparent) = sample_text_layer(image, x, y, animation_frame)
  if not window_is_transparent:
    return window_px
  (high_flame_px, high_flame_is_transparent) = sample_high_flame_layer(image, x, y, animation_frame)
  if not high_flame_is_transparent:
    return high_flame_px
  (mid_flame_px, mid_flame_is_transparent) = sample_mid_flame_layer(image, x, y, animation_frame)
  if not mid_flame_is_transparent:
    return mid_flame_px
  (low_flame_px, low_flame_is_transparent) = sample_low_flame_layer(image, x, y, animation_frame)
  if not low_flame_is_transparent:
    return low_flame_px
  (background_px, bg_is_transparent) = sample_background_layer(image, x, y, animation_frame)
  if not bg_is_transparent:
    return background_px
  # panic and spin!
  return 0

def bits_to_byte(bit_array):
  byte = 0
  for i in range(0,8):
    byte = byte << 1;
    byte = byte + bit_array[i];
  return byte

def hardware_tiles_to_bitplane(index_array):
  # Note: expects an array of palette indices. Returns a byte array of raw NES data
  # which encodes this tile's data as a bitplane for the PPU hardware. 
  low_bits = [x & 0x1 for x in index_array]
  high_bits = [((x & 0x2) >> 1) for x in index_array]
  output_bytes = []
  for tile in range(0, len(low_bits), 64):
    output_bytes += [bits_to_byte(low_bits[i:i+8]) for i in range(tile,tile+64,8)]
    output_bytes += [bits_to_byte(high_bits[i:i+8]) for i in range(tile,tile+64,8)]
  return output_bytes

# my goodness, all the funny business
def convert_prepared_title_to_chr(image):
  chr_tiles = {}
  chr_indices = []

  for tile_y in range(0, 30):
    for tile_x in range(0, 32):
      pixel_bytes = []
      for animation_frame in range(0, 16):
        for pixel_y in range(0, 8):
          for pixel_x in range(0, 8):
            pixel_bytes.append(sample_layers(image, tile_x * 8 + pixel_x, tile_y * 8 + pixel_y, animation_frame))
      raw_chr_bytes = hardware_tiles_to_bitplane(pixel_bytes)
          
      dict_key = tuple(raw_chr_bytes) # tuple? string? performance? unclear! also don't care.
      if dict_key not in chr_tiles != None:
        index = len(chr_tiles)
        chr_tiles[dict_key] = {"index": index, "data": raw_chr_bytes}
      chr_indices.append(chr_tiles[dict_key]["index"])

  # at this point chr_indices is functionally our nametable, but we still need to unpack
  # all 16 CHR tiles into their respective banks. Do that here
  chr_banks = []
  for animation_frame in range(0, 16):
    bg_chr_bytes = []
    for tile in chr_tiles:
      bg_chr_bytes = bg_chr_bytes + chr_tiles[tile]["data"][animation_frame*16:(animation_frame+1)*16]
    # pad all banks to 4k for my personal sanity
    bg_chr_bytes += [0] * (4096 - len(bg_chr_bytes))
    chr_banks.append(bg_chr_bytes)
  return (chr_banks, chr_indices)

def write_nametable(chr_indices, output_file):
  nametable_bytes = []
  for i in range(0, 32 * 30):
    nametable_bytes.append(chr_indices[i] & 0xFF)
  nametable_bytes += [0] * (1024 - len(nametable_bytes))
  output_file.write(bytes(nametable_bytes))

if __name__ == '__main__':
  if len(sys.argv) != 4:
    print("Usage: title_shenanigans.py source_image.png nametable.nam chr_directory")
    sys.exit(-1)
  input_filename = sys.argv[1]
  output_nametable_filename = sys.argv[2]
  chr_directory = sys.argv[3]

  image = Image.open(input_filename)
  assert image.getpalette() != None, "Non-paletted tile found! This is unsupported: " + input_filename

  (chr_banks, chr_indices) = convert_prepared_title_to_chr(image)

  with open(output_nametable_filename, "wb") as output_file:
      write_nametable(chr_indices, output_file)
  os.makedirs(chr_directory,exist_ok=True)
  for i in range(0, len(chr_banks)):
    chr_filename = f"{chr_directory}/title_{i:04}.chr"
    with open(chr_filename, "wb") as bg_chr_file:
      bg_chr_file.write(bytes(chr_banks[i]))
