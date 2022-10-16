; Every entity has an ID, and in this game it also doubles as their starting tile in CHR space.
TILE_CLOCK_FACE = $00 ; debug sprite

; Non-enemies also have IDs, eeeeeeverything has an update function
TILE_REGULAR_FLOOR = $80
TILE_DISCO_FLOOR =   $84
TILE_WALL_TOP =      $88
TILE_WALL_FACE =     $8C
TILE_PIT_EDGE =      $90
TILE_PIT      =      $94

.global update_static_enemy_row