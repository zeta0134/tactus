#!/usr/bin/env python3

from PIL import Image
import pathlib, math, os, re
from ca65 import ca65_byte_literal, ca65_word_literal, ca65_label, pretty_print_table

FULLY_LIT = 0b00000000
DARK      = 0b00000001
DARKER    = 0b00000010
DARKEST   = 0b00000011

BAND_SIZE = 1.2

def light_value_at(distance, target_radius):
    if distance < target_radius:
        return FULLY_LIT
    if distance < target_radius + (BAND_SIZE * 1):
        return DARK
    if distance < target_radius + (BAND_SIZE * 2):
        return DARKER
    return DARKEST

def generate_torchlight(width, height, radius):
    center_x = width / 2
    center_y = height / 2
    light_lut = []
    for y in range(0, height):
        row = []
        for x in range(0, width):
            test_x = x + 0.5
            test_y = y + 0.5
            distance = math.sqrt(math.pow(center_x - test_x, 2) + math.pow(center_y - test_y, 2))
            row.append(light_value_at(distance, radius))
        light_lut += row
    return light_lut

def make_torchlight_image(width, height, torchlight):
    im = Image.new("L", (width, height))
    for x in range(0, width):
        for  y in range(0, height):
            torch_value = torchlight[y*width+x]
            if torch_value == FULLY_LIT:
                im.putpixel((x, y), 255)
            if torch_value == DARK:
                im.putpixel((x, y), 128)
            if torch_value == DARKER:
                im.putpixel((x, y), 64)
            if torch_value == DARKEST:
                im.putpixel((x, y), 0)
    return im

os.makedirs("build/torchlight",exist_ok=True)

torchlight_luts = []

for radius_index in range(0, 32):
    if radius_index == 0:
        radius = -10.0 # total darkness
    elif radius_index == 31:
        radius = 100.0 # total brightness
    else:
        radius = 0.75 + (radius_index * 0.25) + (radius_index * radius_index * 0.03)

    torchlight = generate_torchlight(64, 40, radius)
    torchlight_luts.append(torchlight)
    im = make_torchlight_image(64, 40, torchlight)
    im.save("build/torchlight/test_%s.png" % radius_index)

# for now, output just one of these things for rapid testing
with open("build/torchlight.incs", "w") as lut_file:
    print(ca65_label("torchlight_test_lut"), file=lut_file)
    pretty_print_table(torchlight_luts[10], lut_file, width=64)

