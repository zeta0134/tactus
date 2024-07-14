PAL_MASK    = %11000000

PAL_WORLD  = %00000000
PAL_BLUE   = %01000000
PAL_YELLOW = %10000000
PAL_RED    = %11000000

; TODO: not this!
; Every entity has an ID, and in this game it also doubles as their starting tile in CHR space.
TILE_SMOKE_PUFF = $00
TILE_SLIME_BASE = $04
TILE_BASIC_SLIME = (TILE_SLIME_BASE | %01)
TILE_INTERMEDIATE_SLIME = (TILE_SLIME_BASE | %10)
TILE_ADVANCED_SLIME = (TILE_SLIME_BASE | %11)

TILE_SPIDER_BASE = $08
TILE_SPIDER_BASIC = (TILE_SPIDER_BASE | %01)
TILE_SPIDER_INTERMEDIATE = (TILE_SPIDER_BASE | %10)
TILE_SPIDER_ADVANCED = (TILE_SPIDER_BASE | %11)
TILE_SPIDER_ANTICIPATE = $0C

TILE_ZOMBIE_BASE = $10
TILE_ZOMBIE_BASIC = (TILE_ZOMBIE_BASE | %00)
TILE_ZOMBIE_INTERMEDIATE = (TILE_ZOMBIE_BASE | %10)
TILE_ZOMBIE_ADVANCED = (TILE_ZOMBIE_BASE | %11)
TILE_ZOMBIE_ANTICIPATE = $14

TILE_BIRB_LEFT_BASE = $18
TILE_BIRB_LEFT_BASIC = (TILE_BIRB_LEFT_BASE | %10)
TILE_BIRB_LEFT_INTERMEDIATE = (TILE_BIRB_LEFT_BASE | %01)
TILE_BIRB_LEFT_ADVANCED = (TILE_BIRB_LEFT_BASE | %11)
TILE_BIRB_RIGHT_BASE = $1C
TILE_BIRB_RIGHT_BASIC = (TILE_BIRB_RIGHT_BASE | %10)
TILE_BIRB_RIGHT_INTERMEDIATE = (TILE_BIRB_RIGHT_BASE | %01)
TILE_BIRB_RIGHT_ADVANCED = (TILE_BIRB_RIGHT_BASE | %11)
TILE_BIRB_LEFT_FLYING = $20
TILE_BIRB_RIGHT_FLYING = $24

TILE_MOLE_HOLE_BASE = $28
TILE_MOLE_HOLE_BASIC = (TILE_MOLE_HOLE_BASE | %11)
TILE_MOLE_HOLE_ADVANCED = (TILE_MOLE_HOLE_BASE | %01)
TILE_MOLE_THROWING = $2C
TILE_MOLE_IDLE = $30
TILE_WRENCH_PROJECTILE = $34

TILE_CHALLENGE_SPIKES = $38

; Non-enemies, mostly level geometry
TILE_REGULAR_FLOOR  = $80
TILE_DISCO_FLOOR    = $84 ; why are these still different?
TILE_SEMISAFE_FLOOR = $88
TILE_WALL           = $8C

; Treasure drops
TILE_TREASURE_CHEST = ($98 | %10)
TILE_BIG_KEY = ($9C | %01)
TILE_GOLD_SACK = ($A0 | %10)
TILE_WEAPON_SHADOW = $A4
TILE_HEART_CONTAINER = ($CC | %11)
TILE_SMALL_HEART = ($B0 | %11)

; Interactable blocks
TILE_EXIT_BLOCK = ($A8 | %01)
TILE_EXIT_STAIRS = ($AC | %00)

; Actually in the fixed page
.global draw_active_tile
.global tile_index_to_row_lut, tile_index_to_col_lut

; NOT in the fixed page
.global FAR_update_static_enemy_row
.global FAR_clear_active_move_flags
.global FAR_attack_enemy_tile
.global FAR_player_collides_with_tile
.global FAR_suspend_entire_room

; Below this distance, mobs will prefer to move directly towards the player
SPIDER_TARGET_RADIUS = 5
ZOMBIE_TARGET_RADIUS = 8

; Below this distance, moles will not rise out of the ground
; (intentionally very small, mostly to prevent the player from being able to
; stand on a mole hole *while* a mole is rising, which would deal way too much
; damage AND look weird)
MOLE_SUPPRESSION_RADIUS = 2

FLAG_MOVED_THIS_FRAME = %10000000
