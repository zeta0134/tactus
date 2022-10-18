#!/usr/bin/env python3
from PIL import Image
import pathlib
from pathlib import Path

from ca65 import pretty_print_table, ca65_label, ca65_byte_literal, ca65_word_literal
from compress import compress_smallest
import os, json, re, sys

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

def read_tile(filename):
  im = Image.open(filename)
  assert im.getpalette() != None, "Non-paletted tile found! This is unsupported: " + filename
  assert im.width == 16, "Static tiles must be 16 pixels wide! Bailing. " + filename
  assert im.height == 16, "All tiles must be 16 pixels tall! Bailing. " + filename
  chr_tiles = []
  chr_tiles.append(hardware_tile_to_bitplane(im.crop((0, 0,  8,  8)).getdata()))
  chr_tiles.append(hardware_tile_to_bitplane(im.crop((0, 8,  8, 16)).getdata()))
  chr_tiles.append(hardware_tile_to_bitplane(im.crop((8, 0, 16,  8)).getdata()))
  chr_tiles.append(hardware_tile_to_bitplane(im.crop((8, 8, 16, 16)).getdata()))
  chr_bytes = []
  for tile in chr_tiles:
    chr_bytes = chr_bytes + tile
  return chr_bytes

def nice_label(full_path_and_filename):
  (_, plain_filename) = os.path.split(full_path_and_filename)
  (base_filename, _) = os.path.splitext(plain_filename)
  safe_label = re.sub(r'[^A-Za-z0-9\-\_]', '_', base_filename)
  return safe_label

def write_tile(filename, chr_bytes):
  with open(filename, "w") as output_file:
    compression_type, compressed_bytes = compress_smallest(chr_bytes)

    label = nice_label(filename)
    output_file.write(ca65_label(label) + "\n")
    output_file.write("  .byte %s ; compression type\n" % ca65_byte_literal(compression_type))
    output_file.write("  .word %s ; decompressed length in bytes\n" % ca65_word_literal(len(chr_bytes)))
    output_file.write("              ; compressed length: $%04X, ratio: %.2f:1 \n" % (len(compressed_bytes), len(chr_bytes) / len(compressed_bytes)))
    pretty_print_table(compressed_bytes, output_file, 16)
    output_file.write("\n")

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("Usage: statictile.py input.png output.chr")
    sys.exit(-1)
  input_filename = sys.argv[1]
  output_filename = sys.argv[2]

  chr_bytes = read_tile(input_filename)
  write_tile(output_filename, chr_bytes)

