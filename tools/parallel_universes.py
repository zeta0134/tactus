#!/usr/bin/env python3

import sys

def extract_header(rom_image):
    return rom_image[0:16]

def extract_prg(rom_image, prgsize):
    return rom_image[16:16+prgsize]

def extract_data(rom_image, prgsize):
    return rom_image[16+prgsize+prgsize:]

if __name__ == '__main__':
  if len(sys.argv) != 5:
    print("Usage: parallel_universes.py universe_1.bin universe_2.bin prg_size combined_univese.nes")
    sys.exit(-1)
  first_universe_filename = sys.argv[1]
  second_universe_filename = sys.argv[2]
  universe_size = int(sys.argv[3])
  combined_universe_filename = sys.argv[4]

  with open(first_universe_filename, "rb") as first_universe_file:
    first_universe = first_universe_file.read()
  with open(second_universe_filename, "rb") as second_universe_file:
    second_universe = second_universe_file.read()

  shared_header = extract_header(first_universe)
  first_universe_code = extract_prg(first_universe, universe_size)
  second_universe_code = extract_prg(second_universe, universe_size)
  shared_data = extract_data(first_universe, universe_size)

  with open(combined_universe_filename, "wb") as combined_universe_file:
    combined_universe_file.write(shared_header)
    combined_universe_file.write(first_universe_code)
    combined_universe_file.write(second_universe_code)
    combined_universe_file.write(shared_data)


  



