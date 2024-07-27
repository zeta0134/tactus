.global FAR_draw_battlefield_block_A
.global FAR_draw_battlefield_block_B
.global FAR_draw_battlefield_block_C
.global FAR_swap_battlefield_buffers

.global battlefield
.global tile_data
.global tile_flags
.global tile_patterns
.global tile_attributes
.global tile_detail
.global tile_metasprite

.global active_battlefield, queued_bytes_counter

BATTLEFIELD_WIDTH = 16
BATTLEFIELD_HEIGHT = 11
BATTLEFIELD_SIZE = (BATTLEFIELD_WIDTH*BATTLEFIELD_HEIGHT)
MAXIMUM_QUEUE_SIZE = 128

BATTLEFIELD_OFFSET_X = 0
BATTLEFIELD_OFFSET_Y = 0
