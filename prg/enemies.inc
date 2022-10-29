; Every entity has an ID, and in this game it also doubles as their starting tile in CHR space.
TILE_SMOKE_PUFF = $00 ; debug sprite
TILE_SLIME_BASE = $04
TILE_BASIC_SLIME = (TILE_SLIME_BASE | %01)
TILE_INTERMEDIATE_SLIME = (TILE_SLIME_BASE | %10)
TILE_ADVANCED_SLIME = (TILE_SLIME_BASE | %11)
TILE_SPIDER_BASE = $08
TILE_SPIDER_BASIC = (TILE_SPIDER_BASE | %01)
TILE_SPIDER_INTERMEDIATE = (TILE_SPIDER_BASE | %01)
TILE_SPIDER_ADVANCED = (TILE_SPIDER_BASE | %01)
TILE_SPIDER_ANTICIPATE = $0C

; Non-enemies also have IDs, eeeeeeverything has an update function
TILE_REGULAR_FLOOR = $80
TILE_DISCO_FLOOR =   $84
TILE_WALL_TOP =      $88
TILE_WALL_FACE =     $8C
TILE_PIT_EDGE =      $90
TILE_PIT      =      $94

; Treasure drops
TILE_TREASURE_CHEST = ($98 | %10)
TILE_BIG_KEY = ($9C | %01)
TILE_GOLD_SACK = ($A0 | %10)
TILE_WEAPON_SHADOW = $A4
TILE_HEART_CONTAINER = ($CC | %11)

; Interactable blocks
TILE_EXIT_BLOCK = ($A8 | %01)
TILE_EXIT_STAIRS = ($AC | %00)

.global update_static_enemy_row, clear_active_move_flags, attack_enemy_tile, player_collides_with_tile
.global draw_active_tile

.global tile_index_to_row_lut, tile_index_to_col_lut

SPIDER_TARGET_RADIUS = 5