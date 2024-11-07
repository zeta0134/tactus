
; Note: in no particular order! IDs must be ascending, don't overthink
; this otherwise, it's a pain to rearrange entries in the list. :)
TILE_SMOKE_PUFF        = 00   ; = $00
TILE_SLIME             = 01   ; = $04
TILE_SPIDER            = 02   ; = $08
TILE_SPIDER_ANTICIPATE = 03   ; = $0C
TILE_ZOMBIE            = 04   ; = $10
TILE_ZOMBIE_ANTICIPATE = 05   ; = $14
TILE_BIRB_LEFT         = 06   ; = $18
TILE_BIRB_RIGHT        = 07   ; = $1C
TILE_BIRB_LEFT_FLYING  = 08   ; = $20
TILE_BIRB_RIGHT_FLYING = 09   ; = $24
TILE_MOLE_HOLE         = 10   ; = $28
TILE_MOLE_THROWING     = 11   ; = $2C
TILE_MOLE_IDLE         = 12   ; = $30
TILE_WRENCH_PROJECTILE = 13   ; = $34
TILE_CHALLENGE_SPIKES  = 14   ; = $38
TILE_MUSHROOM          = 15   ; = $3C
TILE_ONE_BEAT_HAZARD   = 16   ; = $40
TILE_DISCO_FLOOR       = 17   ; = $84
TILE_SEMISAFE_FLOOR    = 18   ; = $88
TILE_WALL              = 19   ; = $8C
TILE_ITEM_SHADOW       = 20   ; = $90
TILE_TREASURE_CHEST    = 21   ; = $98
TILE_BIG_KEY           = 22   ; = $9C
TILE_EXIT_BLOCK        = 23   ; = $A8
TILE_EXIT_STAIRS       = 24   ; = $AC

; Used to fill out the rest of the behavioral tables for safety. Should
; always be the final ID + 1
TILE_LAST_EXPECTED_ID  = 25 

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