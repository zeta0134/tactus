import math, sys

from ca65 import pretty_print_table

direction_count = 32
direction_step = 11
initial_offset_degrees = 5

angle_step = (direction_step / direction_count) * 2.0 * math.pi
angles_radians = [angle_step*i+math.radians(initial_offset_degrees) for i in range(0, direction_count)]

print(f"With {direction_count} steps of {100*direction_step/direction_count}% magnitude, starting at {initial_offset_degrees} degrees, we get:")
angles_degrees = ["{0:.2f}".format(math.degrees(i) % 360.0) for i in angles_radians]
print(angles_degrees)

full_speed_steps = 8 # in frames
half_speed_steps = 9 # in frames
desired_travel_distance = 20 # in pixels

total_half_size_steps = full_speed_steps * 2 + half_speed_steps
distance_per_half_step = desired_travel_distance / total_half_size_steps
distance_per_full_step = distance_per_half_step * 2

print(f"Want to move {desired_travel_distance} pixels total in {full_speed_steps} fast frames and {half_speed_steps} slow frames")
print(f"fast speed will be {distance_per_full_step} pixels per frame")
print(f"slow speed will be {distance_per_half_step} pixels per frame")

x_fast_speeds = [math.cos(i)*distance_per_full_step for i in angles_radians]
y_fast_speeds = [math.sin(i)*distance_per_full_step for i in angles_radians]

x_slow_speeds = [math.cos(i)*distance_per_half_step for i in angles_radians]
y_slow_speeds = [math.sin(i)*distance_per_half_step for i in angles_radians]


x_slow_low_bytes = [(int(i * 256.0) & 0xFF)           for i in x_slow_speeds]
x_slow_high_bytes = [((int(i * 256.0) & 0xFF00) >> 8) for i in x_slow_speeds]
y_slow_low_bytes = [(int(i * 256.0) & 0xFF)           for i in y_slow_speeds]
y_slow_high_bytes = [((int(i * 256.0) & 0xFF00) >> 8) for i in y_slow_speeds]
x_fast_low_bytes = [(int(i * 256.0) & 0xFF)           for i in x_fast_speeds]
x_fast_high_bytes = [((int(i * 256.0) & 0xFF00) >> 8) for i in x_fast_speeds]
y_fast_low_bytes = [(int(i * 256.0) & 0xFF)           for i in y_fast_speeds]
y_fast_high_bytes = [((int(i * 256.0) & 0xFF00) >> 8) for i in y_fast_speeds]

print("coin_speed_slow_x_low_lut:")
pretty_print_table(x_slow_low_bytes, sys.stdout)
print("coin_speed_slow_x_high_lut:")
pretty_print_table(x_slow_high_bytes, sys.stdout)

print("coin_speed_slow_y_low_lut:")
pretty_print_table(y_slow_low_bytes, sys.stdout)
print("coin_speed_slow_y_high_lut:")
pretty_print_table(y_slow_high_bytes, sys.stdout)

print("coin_speed_fast_x_low_lut:")
pretty_print_table(x_fast_low_bytes, sys.stdout)
print("coin_speed_fast_x_high_lut:")
pretty_print_table(x_fast_high_bytes, sys.stdout)

print("coin_speed_fast_y_low_lut:")
pretty_print_table(y_fast_low_bytes, sys.stdout)
print("coin_speed_fast_y_high_lut:")
pretty_print_table(y_fast_high_bytes, sys.stdout)