# Given a source full-screen PNG, attempt to deconstruct it to 8x8 attributes,
# then spit out the accompanying nametable in ExRAM format. Given the matching
# sprite overlay, attempt to deconstruct that into (for now) grid-aligned 8x8
# sprites.

# Will spit out the matching CHR data to be further consumed by build_chrrom
# and put in the right place. Loading code may need to supply an offset to the
# nametable data, this is currently not baked in advance.

from PIL import Image
import pathlib, math, os, re, sys
from ca65 import ca65_byte_literal, ca65_word_literal, pretty_print_table

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

# very simple 8x8 grid aligned stuff here, no funny business (yet)
def convert_bg_to_chr(image):
  chr_tiles = {}
  chr_indices = []

  for tile_y in range(0, 30):
    for tile_x in range(0, 32):
      left = tile_x * 8
      top = tile_y * 8
      right = left + 8
      bottom = top + 8
      raw_chr_bytes = hardware_tile_to_bitplane(image.crop((left, top, right, bottom)).getdata())
      dict_key = tuple(raw_chr_bytes) # tuple? string? performance? unclear!
      if dict_key not in chr_tiles != None:
        index = len(chr_tiles)
        chr_tiles[dict_key] = {"index": index, "data": raw_chr_bytes}
      chr_indices.append(chr_tiles[dict_key]["index"])

  bg_chr_bytes = []
  for tile in chr_tiles:
    bg_chr_bytes = bg_chr_bytes + chr_tiles[tile]["data"]
  return (bg_chr_bytes, chr_indices)

def determine_bg_attr(original_indices, tile_x, tile_y):
  attr = None
  for index in original_indices:
    subindex = index & 0b0011
    subpalette = (index & 0b1100) >> 2
    if subindex != 0:
      assert attr == None or attr == subpalette, f"Illegal bg tile at {tile_x, tile_y}"
      attr = subpalette
  if attr == None:
    attr = 0
  return attr

def convert_bg_to_attr(image):
  attr_indices = []
  for tile_y in range(0, 30):
    for tile_x in range(0, 32):
      left = tile_x * 8
      top = tile_y * 8
      right = left + 8
      bottom = top + 8
      original_palette_indices = image.crop((left, top, right, bottom)).getdata()
      attr_indices.append(determine_bg_attr(original_palette_indices, tile_x, tile_y))
  return attr_indices

def is_empty_sprite(raw_chr_bytes):
  for i in range(0, len(raw_chr_bytes)):
    if raw_chr_bytes[i] != 0:
      return False
  return True

def convert_sprites(image):
  chr_tiles = []
  oam_entries = []

  # All sprites are annotated with a particular palette index in the left column.
  # When we find this index, we'll collect all matching pixels in that 8x8 region that
  # correspond to that row of palette colors.

  for guide_y in range(480, 720):
    for guide_x in range(0, 256):
      candidate_guide_px = image.getpixel((guide_x, guide_y))
      candidate_index =  candidate_guide_px & 0b0011
      candidate_subpalette = candidate_guide_px & 0b11100
      # explicitly ignore subpalette 0, and also index nonzero within each subpalette
      if candidate_subpalette != 0 and candidate_index == 0:
        # grab the 8x8 region in the sprite layer corresponding to this guide pixel
        left = guide_x
        top = guide_y - 240
        right = left + 8
        bottom = top + 8
        original_pixels = image.crop((left, top, right, bottom)).getdata()
        # isolate only those pixels which are part of the guide subpalette, ignore all others
        isolated_pixels = []
        nonzero_pixel = False
        for original_pixel in original_pixels:
          if (original_pixel & 0b11100)  == candidate_subpalette:
            isolated_pixels.append(original_pixel)
            nonzero_pixel = True
          else:
            isolated_pixels.append(0)
        # sanity check: don't actually process an empty source tile (even with an explicit guide)
        if nonzero_pixel == True:
          # process the isolated pixels into a CHR tile (don't worry about deduplication for now)
          chr_tile = hardware_tile_to_bitplane(isolated_pixels)
          # produce the corresponding OAM entry
          oam_entry = {"x": guide_x, "y": guide_y - 480, "attr": (candidate_subpalette & 0b01100) >> 2, "index": len(chr_tiles)}
          oam_entries.append(oam_entry)
          # and add that entry to our overall set
          chr_tiles.append(chr_tile)

  obj_chr_bytes = []
  for tile in chr_tiles:
    obj_chr_bytes = obj_chr_bytes + tile

  return (obj_chr_bytes, oam_entries)

def write_nametable(chr_indices, attr_indices, output_file):
  low_plane_bytes = []
  high_plane_bytes = []
  for i in range(0, 32 * 30):
    high_plane_bytes.append(attr_indices[i] << 6 | chr_indices[i] >> 8)
    low_plane_bytes.append(chr_indices[i] & 0xFF)

  output_file.write("nametable:\n")
  pretty_print_table(low_plane_bytes, output_file, 32)
  output_file.write("\n")
  output_file.write("exattr:\n")
  pretty_print_table(high_plane_bytes, output_file, 32)
  output_file.write("\n")

def write_oam(oam_entries, output_file):
  output_file.write("oam:\n")
  for oam_entry in oam_entries:
    output_file.write(".byte " +
     ca65_byte_literal(oam_entry["y"] + 4) + ", " + 
     ca65_byte_literal(oam_entry["index"]) + ", " + 
     ca65_byte_literal(oam_entry["attr"]) + ", " + 
     ca65_byte_literal(oam_entry["x"]) + "\n")
  for i in range(0, 64 - len(oam_entries)):
    output_file.write(".byte $F8, $F8, $F8, $F8\n")
  output_file.write("\n")


if __name__ == '__main__':
  if len(sys.argv) != 5:
    print("Usage: title_nonsense.py image.png data.asm bg.chr obj.chr")
    sys.exit(-1)
  input_filename = sys.argv[1]
  output_data_filename = sys.argv[2]
  output_bg_chr_filename = sys.argv[3]
  output_obj_chr_filename = sys.argv[4]

  image = Image.open(input_filename)
  assert image.getpalette() != None, "Non-paletted tile found! This is unsupported: " + input_filename
  assert image.width in [256], "Canvas tiles must be 256 pixels wide! Bailing. " + input_filename
  assert image.height in [720], "Canvas tiles must be 720 pixels tall! Bailing. " + input_filename

  (bg_chr_bytes, chr_indices) = convert_bg_to_chr(image)
  attr_indices = convert_bg_to_attr(image)
  (obj_chr_bytes, oam_entries) = convert_sprites(image)

  with open(output_data_filename, "w") as output_file:
      write_nametable(chr_indices, attr_indices, output_file)
      write_oam(oam_entries, output_file)

  with open(output_bg_chr_filename, "wb") as bg_chr_file:
    bg_chr_file.write(bytes(bg_chr_bytes))

  with open(output_obj_chr_filename, "wb") as obj_chr_file:
    obj_chr_file.write(bytes(obj_chr_bytes))

  # stats!
  print("Number of unique BG tiles: ", len(bg_chr_bytes) >> 4)
  print("Number of unique sprites: ", len(oam_entries))
