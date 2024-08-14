#!/usr/bin/env python3

# A rather simple tool for generating sine-wave offsets in the X or Y direction.
# Doesn't do much else. Don't overcomplicate it, zeta!

import pathlib, math, os, re
from ca65 import ca65_byte_literal, ca65_word_literal, ca65_label, pretty_print_table

def pixel_sine_with(period, amplitude, step_count, offset=0):
    return [round(math.sin((math.pi * 2.0 / period) * (i+offset)) * amplitude) for i in range(0, step_count)]

# the PPU doesn't automatically change the scroll X position, so the
# encoded expectation is that it should stay the same
def next_scroll_x(current_scroll):
    return current_scroll

# for Y, the PPU does an auto-increment, but we also need to clamp the values to the
# height of the playfield, so that's encoded in here too
def next_scroll_y(current_scroll):
    return (current_scroll+1) % 240

def difference_pairs(distorted_pattern, next_value_func, initial=0):
    pairs = []
    for i in range(0, len(distorted_pattern)):
        if i == 0:
            pairs.append((distorted_pattern[i], i+initial))
        else:
            expected_variance = next_value_func(distorted_pattern[i-1]) - distorted_pattern[i-1]
            actual_variance = distorted_pattern[i] - distorted_pattern[i-1]
            if expected_variance != actual_variance:
                pairs.append((distorted_pattern[i], i+initial))
    return pairs

def distorted_x_pairs(period, amplitude, step_count, offset=0, initial=0):
    light_distortion = pixel_sine_with(period, amplitude, step_count, offset)
    distorted_scroll = [0 + light_distortion[i] for i in range(0, step_count)]
    dpairs = difference_pairs(distorted_scroll, next_scroll_x, initial)
    return dpairs

def distorted_y_pairs(period, amplitude, step_count, offset=0, initial=0):
    light_distortion = pixel_sine_with(period, amplitude, step_count, offset) 
    distorted_scroll = [i + light_distortion[i] for i in range(0, step_count)]
    clamped_distortion = [min(175, max(0, distorted_scroll[i])) for i in range(0, step_count)]
    dpairs = difference_pairs(clamped_distortion, next_scroll_y, initial)
    return dpairs

def print_common_tables(effect_name, output_file):
    print(ca65_label(f"{effect_name}_ppumask_common"), file=output_file)
    print("  .repeat 32", file=output_file)
    print("  .byte $1E", file=output_file)
    print("  .endrepeat", file=output_file)
    print("", file=output_file)
    print(ca65_label(f"{effect_name}_irq_common"), file=output_file)
    print("  .repeat 32", file=output_file)
    print("  .byte >full_scroll_and_ppumask_irq", file=output_file)
    print("  .endrepeat", file=output_file)
    print("", file=output_file)

def print_common_x_table(effect_name, output_file):
    print(ca65_label(f"{effect_name}_scrollx_common"), file=output_file)
    print("  .repeat 32", file=output_file)
    print("  .byte 0", file=output_file)
    print("  .endrepeat", file=output_file)
    print("", file=output_file)

def print_scrolly_distortion_table(effect_name, frame_number, dpairs, output_file):
    scrolly_values = [p[0] for p in dpairs]
    scanline_numbers = [p[1] for p in dpairs]
    print(ca65_label(f"{effect_name}_scrolly_frame_{frame_number}"), file=output_file)
    pretty_print_table(scrolly_values, output_file, width=32)
    print(ca65_label(f"{effect_name}_scanline_frame_{frame_number}"), file=output_file)
    pretty_print_table(scanline_numbers, output_file, width=32)

def print_y_distortion_frames(effect_name, num_frames, output_file):
    for i in range(0, num_frames):
        labels = [
            f"{effect_name}_scrollx_common",
            f"{effect_name}_scrolly_frame_{i}",
            f"{effect_name}_scanline_frame_{i}",
            f"{effect_name}_ppumask_common",
            f"{effect_name}_irq_common"]
        print(f"{effect_name}_frame_{i}:", file=output_file)
        print(f"  .addr {", ".join(labels)}", file=output_file)
    print("", file=output_file)

def print_frame_list(effect_name, framesets):
    print(ca65_label(f"{effect_name}_frames"), file=output_file)
    for i in range(0, len(framesets)):
        print(f"  .addr {effect_name}_frame_{i}", file=output_file)
        print(f"  .byte {len(framesets[i])}", file=output_file)
        print(f"  .byte <.bank({effect_name}_frame_{i})", file=output_file)
    print("", file=output_file)

effect_name = "underwater"
period = 64      # height of the sine wave, also playback frames/duration
amplitude = 1    # strength of the distortion
step_count = 176 # height of the playfield
initial_scanline = 4 # because we can't start at the top of the screen

with open(f"../prg/raster/{effect_name}.incs", "w") as output_file:
    # todo: effect header, frame table, etc
    print_y_distortion_frames(effect_name, period, output_file)
    print_common_tables(effect_name, output_file)
    print_common_x_table(effect_name, output_file)
    framesets = []
    for i in range(0, period):
        dypairs = distorted_y_pairs(period, amplitude, step_count, initial=initial_scanline, offset=i)
        print_scrolly_distortion_table(effect_name, i, dypairs, output_file)
        framesets.append(dypairs)
    print_frame_list(effect_name, framesets)




