.global FAR_initialize_battlefield
.global FAR_queue_battlefield_updates
.global FAR_swap_battlefield_buffers

.global active_tile_queue, active_attribute_queue
.global inactive_tile_queue, inactive_attribute_queue
.global battlefield, tile_data, tile_flags
.global active_battlefield, queued_bytes_counter

BATTLEFIELD_WIDTH = 14
BATTLEFIELD_HEIGHT = 10
BATTLEFIELD_SIZE = (BATTLEFIELD_WIDTH*BATTLEFIELD_HEIGHT)
MAXIMUM_QUEUE_SIZE = 128

BATTLEFIELD_OFFSET_X = 16
BATTLEFIELD_OFFSET_Y = 32

