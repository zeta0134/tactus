#!/usr/bin/env python3

import math, sys
from ca65 import ca65_byte_literal, ca65_word_literal, ca65_label, pretty_print_table

def distance(a, b):
	return math.sqrt(a*a + b*b)

def distance_scaled(distance, max_distance):
	return min(255, round(distance * 256.0 / max_distance))

def full_distance_lut():
	distance_bytes = []
	player_x = 15
	player_y = 10
	max_distance = distance(11,16)
	for y in range(0, 21):
		for x in range(0, 31):
			distance_x = abs(x - player_x)
			distance_y = abs(y - player_y)
			raw_distance = distance(distance_x, distance_y)
			distance_bytes.append(distance_scaled(raw_distance, max_distance))
	return distance_bytes

def single_distance_lut(full_distance_table, x_offset):
	distance_bytes = []
	for y in range(0, 21):
		for x in range(x_offset, x_offset + 16):
			index = y * 31 + x
			distance_bytes.append(full_distance_table[index])
	return distance_bytes

full_distance_table = full_distance_lut()
for x_offset in range(0, 16):
	single_distance_table = single_distance_lut(full_distance_table, 15 - x_offset)
	print(ca65_label("player_distance_lut_%s" % x_offset))
	pretty_print_table(single_distance_table, sys.stdout, width=16)


