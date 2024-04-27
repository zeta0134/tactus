.global FAR_queue_battlefield_updates
.global FAR_swap_battlefield_buffers
.global FAR_reset_inactive_queue

.global active_tile_queue, active_attribute_queue
.global inactive_tile_queue, inactive_attribute_queue
.global battlefield, tile_data, tile_flags, tile_patterns, tile_attributes, tile_detail
.global active_battlefield, queued_bytes_counter

BATTLEFIELD_WIDTH = 16
BATTLEFIELD_HEIGHT = 11
BATTLEFIELD_SIZE = (BATTLEFIELD_WIDTH*BATTLEFIELD_HEIGHT)
MAXIMUM_QUEUE_SIZE = 128

BATTLEFIELD_OFFSET_X = 0
BATTLEFIELD_OFFSET_Y = 0

