#!/usr/bin/env python3

from PIL import Image
import pathlib, math, os, re
from ca65 import ca65_byte_literal, ca65_word_literal

# 4k pages range from 0-63, with the upper 2 bits reserved to specify
# the palette. Outer pages range from 0-3. All outer pages will be swapped
# to the animation, so even static unmoving images will need to be duplicated
# within this space in order to look correct. We're choosing to spend CHR ROM
# to keep things simple and easy to drive.

# For organization purposes, we'll ignore the outer bank and focus on the
# space within one 256k region.

# Background tiles need to generate lighting variants, so one logical page
# of background tiles will consume 4 adjacent physical pages. 
# Make sure the background region is aligned to a 4-page boundary, and that
# the region following this is also aligned to a 4-page boundary, to avoid conflicts

# Sprite tiles do not generate lighting variants, so there are no special
# restrictions.

# Miscellaneous CHR pages can also be provided, for one-off static screens and
# other tomfoolery. Not sure yet if they can be animated, I'm working that out.

BACKGROUND_REGION_BASE = 0x00
SPRITE_REGION_BASE     = 0x20
RAW_CHR_REGION_BASE    = 0x30

MAX_BACKGROUND_TILES = ((SPRITE_REGION_BASE - BACKGROUND_REGION_BASE) / 4) * 64
MAX_SPRITE_TILES = (RAW_CHR_REGION_BASE - SPRITE_REGION_BASE) * 64
MAX_CHR_PAGES = 0x40 - RAW_CHR_REGION_BASE

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
  for metatile_x in range(0, math.floor(image.width / 16)):
    for metatile_y in range(0, math.floor(image.height / 16)):
      for tile_x in range(0, 2):
        for tile_y in range(0, 2):
          left = metatile_x * 16 + tile_x * 8
          top = metatile_y * 16 + tile_y * 8
          right = left + 8
          bottom = top + 8
          chr_tiles.append(hardware_tile_to_bitplane(image.crop((left, top, right, bottom)).getdata()))
  chr_bytes = []
  for tile in chr_tiles:
    chr_bytes = chr_bytes + tile
  return chr_bytes

def convert_to_raw_chr(image):
  chr_tiles = []
  for tile_y in range(0, math.floor(image.height / 8)):
    for tile_x in range(0, 16):
      left = tile_x * 8
      top = tile_y * 8
      right = left + 8
      bottom = top + 8
      chr_tiles.append(hardware_tile_to_bitplane(image.crop((left, top, right, bottom)).getdata()))
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

def generate_lighting_variants_smooth(image):
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
      old_palette_index = new_image.getpixel((x, y)) % 4
      adjusted_palette_index = max(old_palette_index - metatile_row, 0)
      new_image.putpixel((x, y), adjusted_palette_index)
  return new_image

def generate_lighting_variants_dithered(image):
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
    # for the first variant, we'll decrease all colors by 1 stage in a checkerboard pattern
    for y in range(16, 32):
      if ((x + y) % 2) == 0:
        old_palette_index = new_image.getpixel((x, y)) % 4
        adjusted_palette_index = max(old_palette_index - 1, 0)
        new_image.putpixel((x, y), adjusted_palette_index)
    # for the second variant, always decrease the colors by 1 stage, and in a checkerboard
    # pattern decrease by one additional stage
    for y in range(32, 48):
      old_palette_index = new_image.getpixel((x, y)) % 4
      adjusted_palette_index = max(old_palette_index - 1, 0)
      if ((x + y) % 2) == 0:
        adjusted_palette_index = max(adjusted_palette_index - 1, 0)
      new_image.putpixel((x, y), adjusted_palette_index)
    # the darkest generated variant is always solid BG0.0
    for y in range(48, 64):
      new_image.putpixel((x, y), 0)
  return new_image

def read_background_tile(filename):
  im = Image.open(filename)
  assert im.getpalette() != None, "Non-paletted tile found! This is unsupported: " + filename
  assert im.width in [16,64], "BG tiles must be 16 or 64 pixels wide! Bailing. " + filename
  assert im.height in [16,64], "BG tiles must be 16 or 64 pixels tall! Bailing. " + filename
  # if this image is smaller than full size, perform necessary transformations to get it ready
  # for the game's format
  if im.width == 16:
    im = duplicate_static_frames(im)
  if im.height == 16:
    #im = generate_lighting_variants(im)
    im = generate_lighting_variants_dithered(im)
  return im

def read_sprite_tile(filename):
  im = Image.open(filename)
  assert im.getpalette() != None, "Non-paletted tile found! This is unsupported: " + filename
  assert im.width in [16,64], "Sprite tiles must be 16 or 64 pixels wide! Bailing. " + filename
  assert im.height in [16], "Sprite tiles must be 16 pixels tall! Bailing. " + filename
  # if this image is smaller than full size, perform necessary transformations to get it ready
  # for the game's format
  if im.width == 16:
    im = duplicate_static_frames(im)
  return im

# for now, only supports chr files of exactly 4k
def read_raw_chr(filename):
  with open(filename, "rb") as file:
    raw_bytes = file.read(4 * 1024)
    if len(raw_bytes) < (4 * 1024):
      raw_bytes = raw_bytes + bytes([0] * ((4 * 1024) - len(raw_bytes)))
    return list(raw_bytes)

# we can define entire 4k CHR banks as .png instead, and this permits animations
# to boot. here, treat it the same as a rather large sprite
def read_png_chr(filename):
  im = Image.open(filename)
  assert im.getpalette() != None, "Non-paletted tile found! This is unsupported: " + filename
  assert im.width in [128], "PNG CHR files must be 128 pixels wide! Bailing. " + filename
  assert im.height in [128,512], "PNG CHR files must be 128 or 16384 pixels tall! Bailing. " + filename
  return convert_to_raw_chr(im)

def background_tile_base_address(tile_id):
  # location of the top-left tile, within the 0th lighting page,
  # on the 0th animation outer bank. Start with this and tweak
  # accordingly
  page_id = math.floor(tile_id / 64)
  inner_tile_address = (tile_id % 64) * 64
  return (BACKGROUND_REGION_BASE * 4096) + (page_id * 4 * 4096) + inner_tile_address

def sprite_tile_base_address(tile_id):
  page_id = math.floor(tile_id / 64)
  inner_tile_address = (tile_id % 64) * 64
  return (SPRITE_REGION_BASE * 4096) + (page_id * 4096) + inner_tile_address

def chr_bank_base_address(bank_id):
  return (RAW_CHR_REGION_BASE * 4096) + (bank_id * 4096)

def generate_chr(background_tiles, sprite_tiles, raw_chr_banks):
  # start with 1 MB of blank CHR tiles
  chr_bytes = [0] * 1024 * 1024
  # for every background tile, which is now 64x64 and a 4x4 grid of CHR tiles,
  # write those tiles into the appropriate location
  for i in range(0, len(background_tiles)):
    chr_data = convert_to_chr(background_tiles[i])
    metatile_base_addr = background_tile_base_address(i)
    for animation_frame in range(0, 4):
      for lighting_variant in range(0, 4):
        for tile_id in range(0, 4):
          dest_addr = (animation_frame * 256 * 1024) + metatile_base_addr + (lighting_variant * 4 * 1024) + (tile_id * 16)
          chr_addr = (animation_frame * 16 * 16) + (lighting_variant * 16 * 4) + (tile_id * 16)
          chr_bytes[dest_addr:dest_addr+16] = chr_data[chr_addr:chr_addr+16]
  # sprite tiles are very similar, but without the lighting variant offsets
  for i in range(0, len(sprite_tiles)):
    chr_data = convert_to_chr(sprite_tiles[i])
    metatile_base_addr = sprite_tile_base_address(i)
    for animation_frame in range(0, 4):
      for tile_id in range(0, 4):
        dest_addr = (animation_frame * 256 * 1024) + metatile_base_addr + (tile_id * 16)
        chr_addr = (animation_frame * 16 * 4) + (tile_id * 16)
        chr_bytes[dest_addr:dest_addr+16] = chr_data[chr_addr:chr_addr+16]
  # chr banks are just written right into place in all four animation banks
  for i in range(0, len(raw_chr_banks)):
    for animation_frame in range(0, 4):
      chr_addr = chr_bank_base_address(i)
      dest_addr = (animation_frame * 256 * 1024) + chr_addr
      if len(raw_chr_banks[i]) <= 4096:
        chr_bytes[dest_addr:dest_addr+4096] = raw_chr_banks[i]
      elif len(raw_chr_banks[i]) == 4096*4:
        chr_bytes[dest_addr:dest_addr+4096] = raw_chr_banks[i][animation_frame*4096:animation_frame*4096+4096]
      else:
        raise "Wrong length for raw chr data!"
  return chr_bytes

disco_filenames = sorted(list(pathlib.Path('art/disco_tiles').glob('*.png')))
map_filenames = sorted(list(pathlib.Path('art/map_tiles').glob('*.png')))
loose_background_filenames = sorted(list(pathlib.Path('art/background_tiles').glob('*.png')))
background_filenames = disco_filenames + map_filenames + loose_background_filenames

sprite_filenames = sorted(list(pathlib.Path('art/sprite_tiles').glob('*.png')))
raw_chr_filenames = sorted(list(pathlib.Path('art/raw_chr').glob('*.chr')))
png_chr_filenames = sorted(list(pathlib.Path('art/raw_chr').glob('*.png')))

background_tiles = [read_background_tile(f) for f in background_filenames]
sprite_tiles = [read_sprite_tile(f) for f in sprite_filenames]
raw_chr_banks = [read_raw_chr(f) for f in raw_chr_filenames]
png_chr_banks = [read_png_chr(f) for f in png_chr_filenames]
chr_bytes = generate_chr(background_tiles, sprite_tiles, raw_chr_banks + png_chr_banks)

os.makedirs("build/expanded_tiles",exist_ok=True)

with open('build/output_chr.bin', 'wb') as chr_file:
  chr_file.write(bytes(chr_bytes))

for background_filename in background_filenames:
  expanded_tile = read_background_tile(background_filename)
  test_destination = "build/expanded_tiles/bg_"+background_filename.name
  expanded_tile.save(test_destination)
for sprite_filename in sprite_filenames:
  expanded_tile = read_sprite_tile(sprite_filename)
  test_destination = "build/expanded_tiles/sprite_"+sprite_filename.name
  expanded_tile.save(test_destination)

def constant_name(filename):
  file_str = str(pathlib.PurePath(pathlib.PurePath(filename).name).stem)
  return re.sub('[^A-Z0-9_]', '', file_str.upper())

with open('build/tile_defs.inc', 'w') as definitions:
  print("; segment definitions", file=definitions)
  print("BACKGROUND_REGION_BASE = %s" % (ca65_byte_literal(BACKGROUND_REGION_BASE)), file=definitions)
  print("SPRITE_REGION_BASE = %s" % (ca65_byte_literal(SPRITE_REGION_BASE)), file=definitions)
  print("RAW_CHR_REGION_BASE = %s" % (ca65_byte_literal(RAW_CHR_REGION_BASE)), file=definitions)
  print("", file=definitions)
  print("; background tiles", file=definitions)
  for i in range(0, len(background_filenames)):
    metatile_id = (i % 64) * 4
    bank_id = math.floor(i / 64) * 4 + BACKGROUND_REGION_BASE
    tiledef = (bank_id << 8) + metatile_id
    print("BG_TILE_%s = %s" % (constant_name(background_filenames[i]), ca65_word_literal(tiledef)), file=definitions)
  print("", file=definitions)
  print("; sprite tiles", file=definitions)
  for i in range(0, len(sprite_filenames)):
    metatile_id = (i % 64) * 4
    bank_id = math.floor(i / 64) + SPRITE_REGION_BASE
    tiledef = (bank_id << 8) + metatile_id
    print("SPRITE_TILE_%s = %s" % (constant_name(sprite_filenames[i]), ca65_word_literal(tiledef)), file=definitions)
  print("", file=definitions)
  print("; raw_chr banks", file=definitions)
  combined_chr_filenames = raw_chr_filenames + png_chr_filenames
  for i in range(0, len(combined_chr_filenames)):
    bank_id = i + RAW_CHR_REGION_BASE
    print("CHR_BANK_%s = %s" % (constant_name(combined_chr_filenames[i]), ca65_byte_literal(bank_id)), file=definitions)
  print("", file=definitions)



