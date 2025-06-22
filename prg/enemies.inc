
; Note: in no particular order! IDs must be ascending, don't overthink
; this otherwise, it's a pain to rearrange entries in the list. :)
TILE_SMOKE_PUFF             = 00
TILE_SLIME                  = 01
TILE_SPIDER                 = 02
TILE_SPIDER_ANTICIPATE      = 03
TILE_ZOMBIE                 = 04
TILE_ZOMBIE_ANTICIPATE      = 05
TILE_BIRB_LEFT              = 06
TILE_BIRB_RIGHT             = 07
TILE_BIRB_LEFT_FLYING       = 08
TILE_BIRB_RIGHT_FLYING      = 09
TILE_MOLE_HOLE              = 10
TILE_MOLE_THROWING          = 11
TILE_MOLE_IDLE              = 12
TILE_WRENCH_PROJECTILE      = 13
TILE_CHALLENGE_SPIKES       = 14
TILE_MUSHROOM               = 15
TILE_ONE_BEAT_HAZARD        = 16
TILE_DISCO_FLOOR            = 17
TILE_SEMISAFE_FLOOR         = 18
TILE_WALL                   = 19
TILE_ITEM_SHADOW            = 20
TILE_BIG_KEY                = 21
TILE_EXIT_BLOCK             = 22
TILE_EXIT_STAIRS            = 23
TILE_SIGN                   = 24
TILE_CRACKED_WARP_WALL      = 25
TILE_HIDDEN_WARP_FLOOR      = 26
TILE_WARP_PORTAL            = 27
TILE_HAZARD_HEAL            = 28
TILE_HAZARD_POISON          = 29 ; \ 
TILE_HAZARD_FREEZE          = 30 ; | debug single-tile things that always apply this effect
TILE_HAZARD_SHOCK           = 31 ; | we shouldn't need these long term, consider removing them
TILE_HAZARD_BURN            = 32 ; /
TILE_TOTEM                  = 33
TILE_ONE_ARMED_BANDIT       = 34
TILE_CULTIST                = 35
TILE_MAGIC_CIRCLE           = 36
TILE_INDICATOR              = 37 ; \ (this one is inert / safe)
TILE_ONE_BEAT_POISON        = 38 ; | all of these revert to a plain
TILE_ONE_BEAT_FREEZE        = 39 ; | disco tile on the following beat. good for
TILE_ONE_BEAT_SHOCK         = 40 ; | enemy abilities, spells, etc
TILE_ONE_BEAT_BURN          = 41 ; /
TILE_HELPFUL_CHEST          = 42 ; rerolls common loot dynamically to aid the player
TILE_LARGE_CHEST            = 43 ; fixed contents, unlocked, generated with the world
TILE_CHALLENGE_CHEST        = 44 ; fixed contents, locked until the room is cleared
TILE_TIMED_CHEST            = 45 ; fixed contents, locked, vanishes if room not cleared in time
TILE_MIMIC                  = 46 ; a perfectly ordinary chest. nothing suspicious about it
TILE_HIDDEN_CHEST           = 47 ; acts like a wall, spawns the corresponding chest when room is cleared
TILE_HIDDEN_RARE_CHEST      = 48 ; same deal but it's rare
TILE_HIDDEN_LEGENDARY_CHEST = 49 ; same deal but it's legendary

; Actually in the fixed page
.global draw_active_tile
.global tile_index_to_row_lut, tile_index_to_col_lut

.globalzp ActiveDrawingScratch

.global WarpOverlayPattern
.global WarpOverlayAttr

; NOT in the fixed page
.global FIXED_update_static_enemy_row
.global FAR_clear_active_move_flags
.global FAR_attack_enemy_tile
.global FAR_player_collides_with_tile
.global FAR_suspend_entire_room
.global FAR_explode_tile
.global FAR_cast_spell_on_static_enemy_row
.global FAR_init_room_coordination_state
.global FAR_init_beat_coordination_state

FLAG_MOVED_THIS_FRAME = %10000000

; level gen needs to see these for shop loot purposes
ITEM_SPRITE_SPAWNED = %00000001
ITEM_FOR_PURCHASE   = %00000010