        .setcpu "6502"

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "branch_util.inc"
        .include "coins.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "items.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "nes.inc"
        .include "palette_cycler.inc"
        .include "player.inc"
        .include "player_distance.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "settings.inc"
        .include "signs.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "torchlight.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"


.zeropage
DestPtr: .res 2
DamageSpriteCoordX: .res 2
DamageSpriteCoordY: .res 2
HealthDroughtCounter: .res 1

.segment "PRGRAM"

DiscoTile:
SmokePuffTile: .res 1
DiscoRow:
SmokePuffRow: .res 1

SmokePuffDirection: .res 1

WarpOverlayPattern: .res 1
WarpOverlayAttr: .res 1

.segment "PRGFIXED_E000"

PALETTE_MASK  := %11000000
LIGHTING_MASK := %00000011
CORNER_MASK   := %11111100

TOP_LEFT_BITS     := %00 ; not actually used
TOP_RIGHT_BITS    := %10
BOTTOM_LEFT_BITS  := %01
BOTTOM_RIGHT_BITS := %11

DUST_DIRECTION_N  := 0
DUST_DIRECTION_NE := 8
DUST_DIRECTION_E  := 16
DUST_DIRECTION_SE := 24
DUST_DIRECTION_S  := 32
DUST_DIRECTION_SW := 40
DUST_DIRECTION_W  := 48
DUST_DIRECTION_NW := 56

; Note: this is kinda slow! expect it to cause lag if we try to change a BUNCH of
; tiles in one go, but it should be reasonably okay for half a dozen or so
.proc draw_active_tile
TargetIndex := R0 ; TODO: move this out of R0? It's mildly inconvenient

NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2
HighRowScratch := ActiveDrawingScratch+4
LowRowScratch := ActiveDrawingScratch+5

        perform_zpcm_inc

        debug_color (TINT_G | LIGHTGRAY)

        ; init some scratch space
        lda #0
        sta HighRowScratch

        ; work out the high bits of the row, these are the top 4 bits of TargetIndex x64, so they
        ; are split across both nametable address bytes
        lda TargetIndex
        asl
        rol HighRowScratch
        asl
        rol HighRowScratch
        and #%11000000
        sta LowRowScratch
        ; now deal with the column, which here is x2 (we'll do a +32 later to skip over the row)
        lda TargetIndex
        asl
        and #%00011110
        ora LowRowScratch
        sta NametableAddr+0
        sta AttributeAddr+0

        lda active_battlefield
        bne second_nametable
        lda #$50
        ldy #$58
        jmp set_high_bytes
second_nametable:
        lda #$54
        ldy #$5C
set_high_bytes:
        ora HighRowScratch
        sta NametableAddr+1
        tya
        ora HighRowScratch
        sta AttributeAddr+1
        
        ; now actually draw the tile, here using logic mostly lifted from battlefield's "_draw_tiles_common"

        ldx TargetIndex
        ldy #0

        ; top left tile
        lda tile_patterns, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ; ora #TOP_LEFT_BITS   ; this would be a nop
        sta (NametableAddr), y  ; store that to our regular nametable
        ; top-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny ; Y = Y + 1

        ; top right tile
        lda tile_patterns, x
        and #CORNER_MASK
        ora #TOP_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        
        ldy #32 ; skip to the start of the next row for this tile

        ; bottom left tile
        lda tile_patterns, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ora #BOTTOM_LEFT_BITS
        sta (NametableAddr), y  ; store that to our regular nametable
        ; bottom-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; bottom right tile
        lda tile_patterns, x
        and #CORNER_MASK
        ora #BOTTOM_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;

        ; and with all that... we're done?
        debug_color LIGHTGRAY
        perform_zpcm_inc
        rts
.endproc

tile_index_to_row_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte h
        .endrepeat
        .endrepeat

tile_index_to_col_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte w
        .endrepeat
        .endrepeat

.proc FIXED_no_behavior
        ; does what it says on the tin
        rts
.endproc

.proc FIXED_crash_handler
        ; also does nothing, but we can break on this in Mesen
        ; todo: a real crash handler?
        rts
.endproc

.proc __trampoline
        perform_zpcm_inc
        jmp (DestPtr)
        ; tail call
.endproc

.include "enemies/common.asm"

.include "enemies/birb.asm"
.include "enemies/cardinal_chaser.asm"
.include "enemies/challenge_spikes.asm"
.include "enemies/chests.asm"
.include "enemies/cultist.asm"
.include "enemies/diagonal_chaser.asm"
.include "enemies/disco_tile.asm"
.include "enemies/exit_block.asm"
.include "enemies/hazard_tile.asm"
.include "enemies/item_shadow.asm"
.include "enemies/mimic.asm"
.include "enemies/mole.asm"
.include "enemies/mushroom.asm"
.include "enemies/one_armed_bandit.asm"
.include "enemies/semisafe_tile.asm"
.include "enemies/sign.asm"
.include "enemies/slimes.asm"
.include "enemies/smoke_puff.asm"
.include "enemies/totems.asm"
.include "enemies/warp_portal.asm"

.macro define_array name
    .macro .ident(.concat(.string(name), "_push_back")) value
        .local temp
        .define temp name
        .undefine name
        .ifblank temp
            .define name value
        .else
            .define name temp, value
        .endif
        .undefine temp
    end_mac

    .define name
.endmacro
.define end_mac .endmacro

define_array enemy_update_table
define_array enemy_update_bank_table
define_array enemy_direct_attack_table
define_array enemy_indirect_attack_table
define_array enemy_collide_table
define_array enemy_suspend_table
define_array enemy_direct_explode_table
define_array enemy_indirect_explode_table
define_array enemy_spell_table

_expected_update_tileid .set $00
_expected_attack_tileid .set $00
_expected_collide_tileid .set $00
_expected_suspend_tileid .set $00
_expected_explode_tileid .set $00
_expected_spell_tileid .set $00

.macro tile_update TILE_ID, update_func
        .assert _expected_update_tileid = TILE_ID, error, .sprintf("during tile_update for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_update_table_push_back update_func
        enemy_update_bank_table_push_back <.bank(update_func)
        _expected_update_tileid .set _expected_update_tileid + $01
.endmacro

.macro tile_attack TILE_ID, direct_attack_func, indirect_attack_func
        .assert _expected_attack_tileid = TILE_ID, error, .sprintf("during tile_attack for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_direct_attack_table_push_back direct_attack_func
        enemy_indirect_attack_table_push_back indirect_attack_func
        _expected_attack_tileid .set _expected_attack_tileid + $01
.endmacro

.macro tile_collide TILE_ID, collide_func
        .assert _expected_collide_tileid = TILE_ID, error, .sprintf("during tile_collide for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_collide_table_push_back collide_func
        _expected_collide_tileid .set _expected_collide_tileid + $01
.endmacro

.macro tile_suspend TILE_ID, suspend_func
        .assert _expected_suspend_tileid = TILE_ID, error, .sprintf("during tile_suspend for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_suspend_table_push_back suspend_func
        _expected_suspend_tileid .set _expected_suspend_tileid + $01
.endmacro

.macro tile_explode TILE_ID, direct_explode_func, indirect_explode_func
        .assert _expected_explode_tileid = TILE_ID, error, .sprintf("during tile_explode for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_direct_explode_table_push_back direct_explode_func
        enemy_indirect_explode_table_push_back indirect_explode_func
        _expected_explode_tileid .set _expected_explode_tileid + $01
.endmacro

.macro tile_spell TILE_ID, spellcast_func
        .assert _expected_spell_tileid = TILE_ID, error, .sprintf("during tile_spell for %s, expected $%02x, got instead $%02x", .string(TILE_ID), _expected_update_tileid, TILE_ID)
        enemy_spell_table_push_back spellcast_func
        _expected_spell_tileid .set _expected_spell_tileid + $01
.endmacro

tile_update  TILE_SMOKE_PUFF, ENEMY_UPDATE_update_smoke_puff
tile_attack  TILE_SMOKE_PUFF, ENEMY_ATTACK_direct_attack_puff, FIXED_no_behavior
tile_collide TILE_SMOKE_PUFF, FIXED_no_behavior
tile_suspend TILE_SMOKE_PUFF, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_SMOKE_PUFF, ENEMY_BOMB_SPELL_explode_puff, FIXED_no_behavior
tile_spell   TILE_SMOKE_PUFF, FIXED_no_behavior ; TODO: should we have these draw as disco tiles?
        
tile_update  TILE_SLIME, ENEMY_UPDATE_update_slime
tile_attack  TILE_SLIME, ENEMY_ATTACK_direct_attack_slime, ENEMY_ATTACK_indirect_attack_slime
tile_collide TILE_SLIME, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_SLIME, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_SLIME, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_SLIME, ENEMY_BOMB_SPELL_slime_spell_dispatch

tile_update  TILE_SPIDER, ENEMY_UPDATE_update_spider_base
tile_attack  TILE_SPIDER, ENEMY_ATTACK_direct_attack_spider, ENEMY_ATTACK_indirect_attack_spider
tile_collide TILE_SPIDER, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_SPIDER, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_SPIDER, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_SPIDER, ENEMY_BOMB_SPELL_spider_spell_dispatch

tile_update  TILE_SPIDER_ANTICIPATE, ENEMY_UPDATE_update_spider_anticipate
tile_attack  TILE_SPIDER_ANTICIPATE, ENEMY_ATTACK_direct_attack_spider, ENEMY_ATTACK_indirect_attack_spider
tile_collide TILE_SPIDER_ANTICIPATE, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_SPIDER_ANTICIPATE, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_SPIDER_ANTICIPATE, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_SPIDER_ANTICIPATE, ENEMY_BOMB_SPELL_spider_spell_dispatch

tile_update  TILE_ZOMBIE, ENEMY_UPDATE_update_zombie_base
tile_attack  TILE_ZOMBIE, ENEMY_ATTACK_direct_attack_zombie, ENEMY_ATTACK_indirect_attack_zombie
tile_collide TILE_ZOMBIE, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_ZOMBIE, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_ZOMBIE, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_ZOMBIE, ENEMY_BOMB_SPELL_zombie_spell_dispatch

tile_update  TILE_ZOMBIE_ANTICIPATE, ENEMY_UPDATE_update_zombie_anticipate
tile_attack  TILE_ZOMBIE_ANTICIPATE, ENEMY_ATTACK_direct_attack_zombie, ENEMY_ATTACK_indirect_attack_zombie
tile_collide TILE_ZOMBIE_ANTICIPATE, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_ZOMBIE_ANTICIPATE, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_ZOMBIE_ANTICIPATE, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_ZOMBIE_ANTICIPATE, ENEMY_BOMB_SPELL_zombie_spell_dispatch

tile_update  TILE_BIRB_LEFT, ENEMY_UPDATE_update_birb_left
tile_attack  TILE_BIRB_LEFT, ENEMY_ATTACK_direct_attack_birb, ENEMY_ATTACK_indirect_attack_birb
tile_collide TILE_BIRB_LEFT, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_BIRB_LEFT, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_BIRB_LEFT, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_BIRB_LEFT, ENEMY_BOMB_SPELL_birb_spell_dispatch

tile_update  TILE_BIRB_RIGHT, ENEMY_UPDATE_update_birb_right
tile_attack  TILE_BIRB_RIGHT, ENEMY_ATTACK_direct_attack_birb, ENEMY_ATTACK_indirect_attack_birb
tile_collide TILE_BIRB_RIGHT, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_BIRB_RIGHT, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_BIRB_RIGHT, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_BIRB_RIGHT, ENEMY_BOMB_SPELL_birb_spell_dispatch

tile_update  TILE_BIRB_LEFT_FLYING, ENEMY_UPDATE_update_birb_flying_left
tile_attack  TILE_BIRB_LEFT_FLYING, ENEMY_ATTACK_direct_attack_birb, ENEMY_ATTACK_indirect_attack_birb
tile_collide TILE_BIRB_LEFT_FLYING, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_BIRB_LEFT_FLYING, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_BIRB_LEFT_FLYING, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_BIRB_LEFT_FLYING, ENEMY_BOMB_SPELL_birb_spell_dispatch

tile_update  TILE_BIRB_RIGHT_FLYING, ENEMY_UPDATE_update_birb_flying_right
tile_attack  TILE_BIRB_RIGHT_FLYING, ENEMY_ATTACK_direct_attack_birb, ENEMY_ATTACK_indirect_attack_birb
tile_collide TILE_BIRB_RIGHT_FLYING, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_BIRB_RIGHT_FLYING, ENEMY_UTIL_move_away_from_map_edge
tile_explode TILE_BIRB_RIGHT_FLYING, ENEMY_BOMB_SPELL_direct_explode, ENEMY_BOMB_SPELL_indirect_explode
tile_spell   TILE_BIRB_RIGHT_FLYING, ENEMY_BOMB_SPELL_birb_spell_dispatch

tile_update  TILE_MOLE_HOLE, ENEMY_UPDATE_update_mole_hole
tile_attack  TILE_MOLE_HOLE, ENEMY_ATTACK_direct_attack_mole_hole, FIXED_no_behavior
tile_collide TILE_MOLE_HOLE, FIXED_no_behavior
tile_suspend TILE_MOLE_HOLE, FIXED_no_behavior
tile_explode TILE_MOLE_HOLE, ENEMY_BOMB_SPELL_direct_explode, FIXED_no_behavior
tile_spell   TILE_MOLE_HOLE, ENEMY_BOMB_SPELL_mole_spell_dispatch

tile_update  TILE_MOLE_THROWING, ENEMY_UPDATE_update_mole_throwing
tile_attack  TILE_MOLE_THROWING, ENEMY_ATTACK_direct_attack_mole_throwing, FIXED_no_behavior
tile_collide TILE_MOLE_THROWING, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_MOLE_THROWING, FIXED_no_behavior
tile_explode TILE_MOLE_THROWING, ENEMY_BOMB_SPELL_direct_explode, FIXED_no_behavior
tile_spell   TILE_MOLE_THROWING, ENEMY_BOMB_SPELL_mole_spell_dispatch

tile_update  TILE_MOLE_IDLE, ENEMY_UPDATE_update_mole_idle
tile_attack  TILE_MOLE_IDLE, ENEMY_ATTACK_direct_attack_mole_idle,     FIXED_no_behavior
tile_collide TILE_MOLE_IDLE, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_MOLE_IDLE, FIXED_no_behavior
tile_explode TILE_MOLE_IDLE, ENEMY_BOMB_SPELL_direct_explode, FIXED_no_behavior
tile_spell   TILE_MOLE_IDLE, ENEMY_BOMB_SPELL_mole_spell_dispatch

tile_update  TILE_WRENCH_PROJECTILE, ENEMY_UPDATE_update_wrench_projectile
tile_attack  TILE_WRENCH_PROJECTILE, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_WRENCH_PROJECTILE, ENEMY_COLLIDE_projectile_attacks_player
tile_suspend TILE_WRENCH_PROJECTILE, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_WRENCH_PROJECTILE, ENEMY_BOMB_SPELL_become_one_beat_hazard, FIXED_no_behavior ; TODO: clean these up?
tile_spell   TILE_WRENCH_PROJECTILE, FIXED_no_behavior

tile_update  TILE_CHALLENGE_SPIKES, ENEMY_UPDATE_update_challenge_spike
tile_attack  TILE_CHALLENGE_SPIKES, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_CHALLENGE_SPIKES, ENEMY_COLLIDE_challenge_spike_solid_test
tile_suspend TILE_CHALLENGE_SPIKES, FIXED_no_behavior
tile_explode TILE_CHALLENGE_SPIKES, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_CHALLENGE_SPIKES, FIXED_no_behavior

tile_update  TILE_MUSHROOM, ENEMY_UPDATE_update_mushroom
tile_attack  TILE_MUSHROOM, ENEMY_ATTACK_direct_attack_mushroom, FIXED_no_behavior
tile_collide TILE_MUSHROOM, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_MUSHROOM, FIXED_no_behavior
tile_explode TILE_MUSHROOM, ENEMY_BOMB_SPELL_direct_explode, FIXED_no_behavior
tile_spell   TILE_MUSHROOM, ENEMY_BOMB_SPELL_mushroom_spell_dispatch

tile_update  TILE_ONE_BEAT_HAZARD, ENEMY_UPDATE_revert_to_disco_tile
tile_attack  TILE_ONE_BEAT_HAZARD, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ONE_BEAT_HAZARD, ENEMY_COLLIDE_hazard_damages_player
tile_suspend TILE_ONE_BEAT_HAZARD, FIXED_no_behavior
tile_explode TILE_ONE_BEAT_HAZARD, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ONE_BEAT_HAZARD, FIXED_no_behavior ; TODO: do we need to revert to a disco tile?

tile_update  TILE_DISCO_FLOOR, ENEMY_UPDATE_draw_disco_tile
tile_attack  TILE_DISCO_FLOOR, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_DISCO_FLOOR, FIXED_no_behavior
tile_suspend TILE_DISCO_FLOOR, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_DISCO_FLOOR, ENEMY_BOMB_SPELL_become_one_beat_hazard, FIXED_no_behavior
tile_spell   TILE_DISCO_FLOOR, FIXED_no_behavior ; TODO: should we update normally, to suggest visual continiuty?

tile_update  TILE_SEMISAFE_FLOOR, ENEMY_UPDATE_update_semisafe_tile
tile_attack  TILE_SEMISAFE_FLOOR, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_SEMISAFE_FLOOR, ENEMY_COLLIDE_semisolid_attacks_player
tile_suspend TILE_SEMISAFE_FLOOR, FIXED_no_behavior
tile_explode TILE_SEMISAFE_FLOOR, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_SEMISAFE_FLOOR, FIXED_no_behavior

tile_update  TILE_WALL, FIXED_no_behavior
tile_attack  TILE_WALL, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_WALL, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_WALL, FIXED_no_behavior
tile_explode TILE_WALL, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_WALL, FIXED_no_behavior

tile_update  TILE_ITEM_SHADOW, ENEMY_UPDATE_update_item_shadow
tile_attack  TILE_ITEM_SHADOW, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ITEM_SHADOW, ENEMY_COLLIDE_collect_item
tile_suspend TILE_ITEM_SHADOW, ENEMY_UTIL_suspend_item_shadow
tile_explode TILE_ITEM_SHADOW, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ITEM_SHADOW, FIXED_no_behavior

tile_update  TILE_BIG_KEY, FIXED_no_behavior
tile_attack  TILE_BIG_KEY, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_BIG_KEY, ENEMY_COLLIDE_collect_key
tile_suspend TILE_BIG_KEY, FIXED_no_behavior
tile_explode TILE_BIG_KEY, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_BIG_KEY, FIXED_no_behavior

tile_update  TILE_EXIT_BLOCK, FIXED_no_behavior
tile_attack  TILE_EXIT_BLOCK, ENEMY_ATTACK_attack_exit_block, FIXED_no_behavior
tile_collide TILE_EXIT_BLOCK, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_EXIT_BLOCK, FIXED_no_behavior
tile_explode TILE_EXIT_BLOCK, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_EXIT_BLOCK, FIXED_no_behavior

tile_update  TILE_EXIT_STAIRS, FIXED_no_behavior
tile_attack  TILE_EXIT_STAIRS, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_EXIT_STAIRS, ENEMY_COLLIDE_descend_stairs
tile_suspend TILE_EXIT_STAIRS, FIXED_no_behavior
tile_explode TILE_EXIT_STAIRS, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_EXIT_STAIRS, FIXED_no_behavior

tile_update  TILE_SIGN, FIXED_no_behavior
tile_attack  TILE_SIGN, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_SIGN, ENEMY_COLLIDE_player_reads_sign
tile_suspend TILE_SIGN, FIXED_no_behavior
tile_explode TILE_SIGN, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_SIGN, FIXED_no_behavior

; TODO: real behaviors. These should convert to warp portals when hit by a bomb!
tile_update  TILE_CRACKED_WARP_WALL, ENEMY_UPDATE_proc_dingbat
tile_attack  TILE_CRACKED_WARP_WALL, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_CRACKED_WARP_WALL, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_CRACKED_WARP_WALL, FIXED_no_behavior
tile_explode TILE_CRACKED_WARP_WALL, ENEMY_BOMB_SPELL_become_warp_portal, FIXED_no_behavior
tile_spell   TILE_CRACKED_WARP_WALL, FIXED_no_behavior

; TODO: real behaviors. These should convert to warp portals when hit by a bomb,
; but only if the player isn't standing on top of them at the time!
tile_update  TILE_HIDDEN_WARP_FLOOR, ENEMY_UPDATE_hidden_warp_tile
tile_attack  TILE_HIDDEN_WARP_FLOOR, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HIDDEN_WARP_FLOOR, FIXED_no_behavior
tile_suspend TILE_HIDDEN_WARP_FLOOR, ENEMY_UTIL_suspend_hidden_warp_tile
tile_explode TILE_HIDDEN_WARP_FLOOR, ENEMY_BOMB_SPELL_become_warp_portal, FIXED_no_behavior
tile_spell   TILE_HIDDEN_WARP_FLOOR, FIXED_no_behavior

tile_update  TILE_WARP_PORTAL, ENEMY_UPDATE_draw_warp_portal
tile_attack  TILE_WARP_PORTAL, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_WARP_PORTAL, ENEMY_COLLIDE_teleport_to_warp_entrance
tile_suspend TILE_WARP_PORTAL, ENEMY_UTIL_cleanup_warp_entrance
tile_explode TILE_WARP_PORTAL, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_WARP_PORTAL, FIXED_no_behavior

tile_update  TILE_HAZARD_HEAL, ENEMY_UPDATE_update_hazard_tile
tile_attack  TILE_HAZARD_HEAL, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HAZARD_HEAL, ENEMY_COLLIDE_activate_hazard_healing
tile_suspend TILE_HAZARD_HEAL, FIXED_no_behavior
tile_explode TILE_HAZARD_HEAL, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HAZARD_HEAL, FIXED_no_behavior

tile_update  TILE_HAZARD_POISON, ENEMY_UPDATE_update_hazard_tile
tile_attack  TILE_HAZARD_POISON, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HAZARD_POISON, ENEMY_COLLIDE_activate_hazard_poison
tile_suspend TILE_HAZARD_POISON, FIXED_no_behavior
tile_explode TILE_HAZARD_POISON, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HAZARD_POISON, FIXED_no_behavior

tile_update  TILE_HAZARD_FREEZE, ENEMY_UPDATE_update_hazard_tile
tile_attack  TILE_HAZARD_FREEZE, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HAZARD_FREEZE, ENEMY_COLLIDE_activate_hazard_freeze
tile_suspend TILE_HAZARD_FREEZE, FIXED_no_behavior
tile_explode TILE_HAZARD_FREEZE, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HAZARD_FREEZE, FIXED_no_behavior

tile_update  TILE_HAZARD_SHOCK, ENEMY_UPDATE_update_hazard_tile
tile_attack  TILE_HAZARD_SHOCK, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HAZARD_SHOCK, ENEMY_COLLIDE_activate_hazard_shock
tile_suspend TILE_HAZARD_SHOCK, FIXED_no_behavior
tile_explode TILE_HAZARD_SHOCK, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HAZARD_SHOCK, FIXED_no_behavior

tile_update  TILE_HAZARD_BURN, ENEMY_UPDATE_update_hazard_tile
tile_attack  TILE_HAZARD_BURN, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HAZARD_BURN, ENEMY_COLLIDE_activate_hazard_burn
tile_suspend TILE_HAZARD_BURN, FIXED_no_behavior
tile_explode TILE_HAZARD_BURN, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HAZARD_BURN, FIXED_no_behavior

; Note: all totems have shared initial dispatch, so they don't consume
; extra enemy slots. There are a lot of these, but not a lot onscreen at
; once, so we can eat the performance penalty here.
tile_update  TILE_TOTEM, ENEMY_UPDATE_totem_update
tile_attack  TILE_TOTEM, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_TOTEM, ENEMY_COLLIDE_with_totem
tile_suspend TILE_TOTEM, ENEMY_UTIL_suspend_totem
tile_explode TILE_TOTEM, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_TOTEM, FIXED_no_behavior

tile_update  TILE_ONE_ARMED_BANDIT, ENEMY_UPDATE_update_one_armed_bandit
tile_attack  TILE_ONE_ARMED_BANDIT, ENEMY_ATTACK_direct_attack_one_armed_bandit, ENEMY_ATTACK_indirect_attack_one_armed_bandit
tile_collide TILE_ONE_ARMED_BANDIT, ENEMY_COLLIDE_one_armed_bandit_attacks_player
tile_suspend TILE_ONE_ARMED_BANDIT, ENEMY_UTIL_one_armed_bandit_suspend
tile_explode TILE_ONE_ARMED_BANDIT, ENEMY_BOMB_SPELL_one_armed_bandit_direct_explode, ENEMY_BOMB_SPELL_one_armed_bandit_indirect_explode
tile_spell   TILE_ONE_ARMED_BANDIT, FIXED_no_behavior

tile_update  TILE_CULTIST, ENEMY_UPDATE_cultist
tile_attack  TILE_CULTIST, ENEMY_ATTACK_direct_attack_cultist, ENEMY_ATTACK_indirect_attack_cultist
tile_collide TILE_CULTIST, ENEMY_COLLIDE_cultist_attacks_player
tile_suspend TILE_CULTIST, ENEMY_UTIL_cultist_suspend_logic
tile_explode TILE_CULTIST, ENEMY_BOMB_SPELL_cultist_direct_explode, ENEMY_BOMB_SPELL_cultist_indirect_explode
tile_spell   TILE_CULTIST, ENEMY_BOMB_SPELL_cultist_spell_dispatch

tile_update  TILE_MAGIC_CIRCLE, ENEMY_UPDATE_cultist_magic_circle
tile_attack  TILE_MAGIC_CIRCLE, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_MAGIC_CIRCLE, FIXED_no_behavior
tile_suspend TILE_MAGIC_CIRCLE, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_MAGIC_CIRCLE, FIXED_no_behavior, FIXED_no_behavior    ; ... shouldn't this cancel the teleport?
tile_spell   TILE_MAGIC_CIRCLE, FIXED_no_behavior 

tile_update  TILE_INDICATOR, ENEMY_UPDATE_revert_to_disco_tile
tile_attack  TILE_INDICATOR, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_INDICATOR, FIXED_no_behavior
tile_suspend TILE_INDICATOR, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_INDICATOR, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_INDICATOR, FIXED_no_behavior

tile_update  TILE_ONE_BEAT_POISON, ENEMY_UPDATE_flash_and_revert_to_disco_tile
tile_attack  TILE_ONE_BEAT_POISON, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ONE_BEAT_POISON, ENEMY_COLLIDE_activate_hazard_poison
tile_suspend TILE_ONE_BEAT_POISON, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_ONE_BEAT_POISON, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ONE_BEAT_POISON, FIXED_no_behavior

tile_update  TILE_ONE_BEAT_FREEZE, ENEMY_UPDATE_flash_and_revert_to_disco_tile
tile_attack  TILE_ONE_BEAT_FREEZE, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ONE_BEAT_FREEZE, ENEMY_COLLIDE_activate_hazard_freeze
tile_suspend TILE_ONE_BEAT_FREEZE, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_ONE_BEAT_FREEZE, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ONE_BEAT_FREEZE, FIXED_no_behavior

tile_update  TILE_ONE_BEAT_SHOCK, ENEMY_UPDATE_flash_and_revert_to_disco_tile
tile_attack  TILE_ONE_BEAT_SHOCK, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ONE_BEAT_SHOCK, ENEMY_COLLIDE_activate_hazard_shock
tile_suspend TILE_ONE_BEAT_SHOCK, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_ONE_BEAT_SHOCK, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ONE_BEAT_SHOCK, FIXED_no_behavior

tile_update  TILE_ONE_BEAT_BURN, ENEMY_UPDATE_flash_and_revert_to_disco_tile
tile_attack  TILE_ONE_BEAT_BURN, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_ONE_BEAT_BURN, ENEMY_COLLIDE_activate_hazard_burn
tile_suspend TILE_ONE_BEAT_BURN, ENEMY_UTIL_draw_cleared_disco_tile
tile_explode TILE_ONE_BEAT_BURN, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_ONE_BEAT_BURN, FIXED_no_behavior

tile_update  TILE_HELPFUL_CHEST, ENEMY_UPDATE_helpful_chest
tile_attack  TILE_HELPFUL_CHEST, ENEMY_ATTACK_open_unlocked_chest, FIXED_no_behavior
tile_collide TILE_HELPFUL_CHEST, ENEMY_COLLIDE_open_unlocked_chest
tile_suspend TILE_HELPFUL_CHEST, ENEMY_UTIL_suspend_helpful_chest
tile_explode TILE_HELPFUL_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HELPFUL_CHEST, FIXED_no_behavior

tile_update  TILE_LARGE_CHEST, ENEMY_UPDATE_large_chest
tile_attack  TILE_LARGE_CHEST, ENEMY_ATTACK_open_unlocked_chest, FIXED_no_behavior
tile_collide TILE_LARGE_CHEST, ENEMY_COLLIDE_open_unlocked_chest
tile_suspend TILE_LARGE_CHEST, ENEMY_UTIL_suspend_large_chest
tile_explode TILE_LARGE_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_LARGE_CHEST, FIXED_no_behavior

tile_update  TILE_CHALLENGE_CHEST, ENEMY_UPDATE_challenge_chest
tile_attack  TILE_CHALLENGE_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_CHALLENGE_CHEST, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_CHALLENGE_CHEST, ENEMY_UTIL_suspend_challenge_chest
tile_explode TILE_CHALLENGE_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_CHALLENGE_CHEST, FIXED_no_behavior

tile_update  TILE_TIMED_CHEST, ENEMY_UPDATE_timed_chest
tile_attack  TILE_TIMED_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_TIMED_CHEST, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_TIMED_CHEST, ENEMY_UTIL_suspend_timed_chest
tile_explode TILE_TIMED_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_TIMED_CHEST, FIXED_no_behavior

tile_update  TILE_MIMIC, ENEMY_UPDATE_mimic
tile_attack  TILE_MIMIC, ENEMY_ATTACK_direct_attack_mimic, ENEMY_ATTACK_indirect_attack_mimic
tile_collide TILE_MIMIC, ENEMY_COLLIDE_basic_enemy_attacks_player
tile_suspend TILE_MIMIC, ENEMY_UTIL_suspend_mimic
tile_explode TILE_MIMIC, ENEMY_BOMB_SPELL_mimic_direct_explode, ENEMY_BOMB_SPELL_mimic_indirect_explode
tile_spell   TILE_MIMIC, ENEMY_BOMB_SPELL_mimic_spell_dispatch

tile_update  TILE_HIDDEN_CHEST, ENEMY_UPDATE_hidden_chest
tile_attack  TILE_HIDDEN_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HIDDEN_CHEST, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_HIDDEN_CHEST, FIXED_no_behavior
tile_explode TILE_HIDDEN_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HIDDEN_CHEST, FIXED_no_behavior

tile_update  TILE_HIDDEN_RARE_CHEST, ENEMY_UPDATE_hidden_rare_chest
tile_attack  TILE_HIDDEN_RARE_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HIDDEN_RARE_CHEST, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_HIDDEN_RARE_CHEST, FIXED_no_behavior
tile_explode TILE_HIDDEN_RARE_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HIDDEN_RARE_CHEST, FIXED_no_behavior

tile_update  TILE_HIDDEN_LEGENDARY_CHEST, ENEMY_UPDATE_hidden_legendary_chest
tile_attack  TILE_HIDDEN_LEGENDARY_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_collide TILE_HIDDEN_LEGENDARY_CHEST, ENEMY_COLLIDE_solid_tile_forbids_movement
tile_suspend TILE_HIDDEN_LEGENDARY_CHEST, FIXED_no_behavior
tile_explode TILE_HIDDEN_LEGENDARY_CHEST, FIXED_no_behavior, FIXED_no_behavior
tile_spell   TILE_HIDDEN_LEGENDARY_CHEST, FIXED_no_behavior

.segment "PRGRAM"

RoomStateBanditsActiveCurrent:  .res 4
RoomStateBanditsActivePrevious: .res 4
RoomStateBanditsFrozenCurrent:  .res 4
RoomStateBanditsFrozenPrevious: .res 4
RoomStateBanditReelCountSeven:  .res 4
RoomStateBanditReelCountCherry: .res 4
RoomStateBanditReelCountGem:    .res 4
RoomStateBanditReelCountMagic:  .res 4

RoomStateHasHiddenFeatures: .res 1

.segment "ENEMY_UPDATE0"

; A few enemies need to coordinate their behavior as a group. This is the reset
; function for their memory. Anything those enemies want to persist needs to be
; handled during suspension. (Try to avoid this if we can, it gets very messy.)
.proc FAR_init_room_coordination_state
        ; When we enter a room, clear our knowledge of hidden features. Tiles which
        ; contain hidden features will use this flag to know whether the dingbat
        ; item should proc.
        lda #0
        sta RoomStateHasHiddenFeatures

        ; Bandits have one set of state variables per color group,
        ; allowing up to 4 groups (one of each element) to cooperate
        ; within the same chamber. Not sure how practical this is really,
        ; but I sorta want to design a boss fight that involves groups of
        ; the things, so there's that. Might as well.
        lda #0
        ldx #0
loop:
        sta RoomStateBanditsActiveCurrent, x
        sta RoomStateBanditsActivePrevious, x
        sta RoomStateBanditsFrozenCurrent, x
        sta RoomStateBanditsFrozenPrevious, x
        sta RoomStateBanditReelCountSeven, x
        sta RoomStateBanditReelCountCherry, x
        sta RoomStateBanditReelCountGem, x
        sta RoomStateBanditReelCountMagic, x
        inx
        cpx #4
        bne loop

        rts
.endproc

.proc FAR_init_beat_coordination_state
        ; Bandits need to key off the state of the previous beat, while simultaneously
        ; building the state of the current beat. Do that here
        ldx #0
loop:
        lda RoomStateBanditsActiveCurrent, x
        sta RoomStateBanditsActivePrevious, x
        lda RoomStateBanditsFrozenCurrent, x
        sta RoomStateBanditsFrozenPrevious, x
        lda #0
        sta RoomStateBanditsActiveCurrent, x
        sta RoomStateBanditsFrozenCurrent, x
        inx
        cpx #4
        bne loop
        rts
.endproc

; For speed and banking reasons, this whole bit is now moved into the fixed region
        .segment "PRGFIXED_E000"

static_behaviors_low:
        .lobytes enemy_update_table
        .repeat ($100 - _expected_update_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

static_behaviors_high:
        .hibytes enemy_update_table
        .repeat ($100 - _expected_update_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

static_behaviors_bank:
        .lobytes enemy_update_bank_table
        .repeat ($100 - _expected_update_tileid)
        .byte <.bank(FIXED_crash_handler)
        .endrepeat

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FIXED_update_static_enemy_row
Length := R13
CurrentRow := R14
StartingTile := R15
        ; First preserve the origin bank; we're going to do a goofy stubbed
        ; pseudo-far-call and will otherwise clobber this
        lda CurrentBank
        pha

        lda #::BATTLEFIELD_WIDTH
        sta Length
loop:
        perform_zpcm_inc
        ldx StartingTile
        ldy battlefield, x

        ; Manually bank switch the target bank here
        lda static_behaviors_bank, y
        sta CurrentBank ; if targets wish to far call, so they can return properly
        ;rainbow_set_code_bank CurrentBank (to skip a redundant lda)
        and #<__BANK_MASK__
        ora #<__BANK_OFFSET__
        sta code_bank_shadow
        sta MAP_PRG_8_LO

        ; Now it should be safe to call the target routine
        lda static_behaviors_low, y
        sta DestPtr+0
        lda static_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline
        inc StartingTile
        dec Length
        bne loop

        ; Now restore that bank we manually preserved before we return
        pla
        sta CurrentBank
        rainbow_set_code_bank CurrentBank

        rts
.endproc

.segment "ENEMY_ATTACK"

direct_attack_behaviors_low:
        .lobytes enemy_direct_attack_table
        .repeat ($100 - _expected_attack_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

direct_attack_behaviors_high:
        .hibytes enemy_direct_attack_table
        .repeat ($100 - _expected_attack_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

indirect_attack_behaviors_low:
        .lobytes enemy_indirect_attack_table
        .repeat ($100 - _expected_attack_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

indirect_attack_behaviors_high:
        .hibytes enemy_indirect_attack_table
        .repeat ($100 - _expected_attack_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

.proc FAR_attack_enemy_tile
; R0 - R2 are free for called enemy behaviors to use
; R4 - R9 are free for called enemy behaviors to use
; R11 - R13 are free for called enemy behaviors to use

; Current target square to consider for attacking, provided by caller
AttackSquare := R3
; For indirect attacks, the "effective" attack square goes here.
; Enemies which move almost always use this.
EffectiveAttackSquare := R10 

; The player's target location. Generally enemies shouldn't touch this
; on weapon strike, but they *could*, and this is how. Don't clobber these.
TargetRow := R14
TargetCol := R15
; R16 - R20 are free for called routines to use
        
        perform_zpcm_inc

        ldx AttackSquare
        ldy battlefield, x
        lda direct_attack_behaviors_low, y
        sta DestPtr+0
        lda direct_attack_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline

        perform_zpcm_inc

        rts
.endproc

.segment "ENEMY_COLLIDE"

bonk_behaviors_low:
        .lobytes enemy_collide_table
        .repeat ($100 - _expected_collide_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

bonk_behaviors_high:
        .hibytes enemy_collide_table
        .repeat ($100 - _expected_collide_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

.proc FAR_player_collides_with_tile
; Called functions may use/clobber R0 - R12
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        ldx TargetSquare
        ldy battlefield, x
        lda bonk_behaviors_low, y
        sta DestPtr+0
        lda bonk_behaviors_high, y
        sta DestPtr+1
        perform_zpcm_inc
        jsr __trampoline

        rts
.endproc

.segment "ENEMY_UTIL"

; called just before suspending the map, typically because the player
; is moving to an adjacent room. handles all sorts of fun jank
suspend_behaviors_low:
        .lobytes enemy_suspend_table
        .repeat ($100 - _expected_suspend_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

suspend_behaviors_high:
        .hibytes enemy_suspend_table
        .repeat ($100 - _expected_suspend_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FAR_suspend_entire_room
CurrentSquare := R15
        lda #0
        sta CurrentSquare
loop:
        perform_zpcm_inc
        ldx CurrentSquare
        ldy battlefield, x
        lda suspend_behaviors_low, y
        sta DestPtr+0
        lda suspend_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline
        inc CurrentSquare
        lda CurrentSquare
        cmp #BATTLEFIELD_SIZE
        bne loop
        rts
.endproc

.proc FAR_clear_active_move_flags
        clc
        ldx #0
loop:
        perform_zpcm_inc
        .repeat 8, i       
        lda tile_flags+i, x ; 4
        and #%01111111      ; 2
        sta tile_flags+i, x ; 5
        .endrepeat
        perform_zpcm_inc
        .repeat 8, i       
        lda tile_flags+i+8, x ; 4
        and #%01111111      ; 2
        sta tile_flags+i+8, x ; 5
        .endrepeat
        txa
        adc #16
        tax
        cpx #BATTLEFIELD_SIZE
        jne loop
        rts        
.endproc

.segment "ENEMY_BOMB_SPELL"

direct_explode_behaviors_low:
        .lobytes enemy_direct_explode_table
        .repeat ($100 - _expected_explode_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

direct_explode_behaviors_high:
        .hibytes enemy_direct_explode_table
        .repeat ($100 - _expected_explode_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

indirect_explode_behaviors_low:
        .lobytes enemy_indirect_explode_table
        .repeat ($100 - _expected_explode_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

indirect_explode_behaviors_high:
        .hibytes enemy_indirect_explode_table
        .repeat ($100 - _expected_explode_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

.proc FAR_explode_tile
AttackSquare := R3        
        perform_zpcm_inc

        ldx AttackSquare
        ldy battlefield, x
        lda direct_explode_behaviors_low, y
        sta DestPtr+0
        lda direct_explode_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline

        perform_zpcm_inc

        rts
.endproc

spell_dispatch_behaviors_low:
        .lobytes enemy_spell_table
        .repeat ($100 - _expected_spell_tileid)
        .byte <FIXED_crash_handler
        .endrepeat

spell_dispatch_behaviors_high:
        .hibytes enemy_spell_table
        .repeat ($100 - _expected_spell_tileid)
        .byte >FIXED_crash_handler
        .endrepeat

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FAR_cast_spell_on_static_enemy_row
Length := R13
CurrentRow := R14
StartingTile := R15
        lda #::BATTLEFIELD_WIDTH
        sta Length
loop:
        perform_zpcm_inc
        ldx StartingTile
        ldy battlefield, x
        lda spell_dispatch_behaviors_low, y
        sta DestPtr+0
        lda spell_dispatch_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline
        inc StartingTile
        dec Length
        bne loop
        rts
.endproc