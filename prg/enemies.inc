

TILE_SMOKE_PUFF = $00
TILE_SLIME = $04
TILE_SPIDER = $08
TILE_SPIDER_ANTICIPATE = $0C
TILE_ZOMBIE = $10
TILE_ZOMBIE_ANTICIPATE = $14
TILE_BIRB_LEFT = $18
TILE_BIRB_RIGHT = $1C
TILE_BIRB_LEFT_FLYING = $20
TILE_BIRB_RIGHT_FLYING = $24
TILE_MOLE_HOLE = $28
TILE_MOLE_THROWING = $2C
TILE_MOLE_IDLE = $30
TILE_WRENCH_PROJECTILE = $34
TILE_CHALLENGE_SPIKES = $38
TILE_MUSHROOM = $3C
TILE_ONE_BEAT_HAZARD = $40

; Non-enemies, mostly level geometry
TILE_DISCO_FLOOR    = $84
TILE_SEMISAFE_FLOOR = $88
TILE_WALL           = $8C

; Treasure drops
TILE_ITEM_SHADOW = $90
TILE_TREASURE_CHEST = $98
TILE_BIG_KEY = $9C

; Interactable blocks
TILE_EXIT_BLOCK = $A8
TILE_EXIT_STAIRS = $AC

TILE_LAST_ID = $AC

; Actually in the fixed page
.global draw_active_tile
.global tile_index_to_row_lut, tile_index_to_col_lut

.globalzp ActiveDrawingScratch

; NOT in the fixed page
.global FAR_update_static_enemy_row
.global FAR_clear_active_move_flags
.global FAR_attack_enemy_tile
.global FAR_player_collides_with_tile
.global FAR_suspend_entire_room

FLAG_MOVED_THIS_FRAME = %10000000

; level gen needs to see these for shop loot purposes
ITEM_SPRITE_SPAWNED = %00000001
ITEM_FOR_PURCHASE   = %00000010