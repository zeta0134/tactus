.global FAR_initialize_battlefield
.global FAR_queue_battlefield_updates
.global FAR_swap_battlefield_buffers

.global battlefield, inactive_tile_queue, inactive_attribute_queue, active_battlefield, tile_data, tile_flags, active_tile_queue, active_attribute_queue

BATTLEFIELD_WIDTH = 14
BATTLEFIELD_HEIGHT = 10
BATTLEFIELD_SIZE = (BATTLEFIELD_WIDTH*BATTLEFIELD_HEIGHT)
MAXIMUM_QUEUE_SIZE = 96