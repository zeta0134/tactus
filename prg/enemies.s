        .setcpu "6502"

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "branch_util.inc"
        .include "coins.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "hud.inc"
        .include "items.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "palette_cycler.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage
DestPtr: .res 2
DamageSpriteCoordX: .res 2
DamageSpriteCoordY: .res 2
HealthDroughtCounter: .res 1

; TODO: can we relocate this to shared zeropage scratch later?
ActiveDrawingScratch: .res 6

.segment "RAM"

SmokePuffTile: .res 1
SmokePuffRow: .res 1
SmokePuffDirection: .res 1

.segment "PRGFIXED_E000"

PALETTE_MASK  := %11000000
LIGHTING_MASK := %00000011
CORNER_MASK   := %11111100

TOP_LEFT_BITS     := %00 ; not actually used
TOP_RIGHT_BITS    := %10
BOTTOM_LEFT_BITS  := %01
BOTTOM_RIGHT_BITS := %11

DUST_DIRECTION_N  := 0
DUST_DIRECTION_NE := 2
DUST_DIRECTION_E  := 4
DUST_DIRECTION_SE := 6
DUST_DIRECTION_S  := 8
DUST_DIRECTION_SW := 10
DUST_DIRECTION_W  := 12
DUST_DIRECTION_NW := 14

; Note: this is kinda slow! expect it to cause lag if we try to change a BUNCH of
; tiles in one go, but it should be reasonably okay for half a dozen or so
.proc draw_active_tile
TargetIndex := R0

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

.segment "CODE_2"

.include "enemies/common.asm"

.include "enemies/birb.asm"
.include "enemies/cardinal_chaser.asm"
.include "enemies/challenge_spikes.asm"
.include "enemies/diagonal_chaser.asm"
.include "enemies/disco_tile.asm"
.include "enemies/exit_block.asm"
.include "enemies/item_shadow.asm"
.include "enemies/mole.asm"
.include "enemies/slimes.asm"
.include "enemies/semisafe_tile.asm"
.include "enemies/small_heart.asm"
.include "enemies/smoke_puff.asm"
.include "enemies/treasure_chest.asm"
.include "enemies/weapon_shadow.asm"

static_behaviors:
        .word update_smoke_puff         ; $00
        .word update_slime              ; $04
        .word update_spider_base        ; $08
        .word update_spider_anticipate  ; $0C
        .word update_zombie_base        ; $10
        .word update_zombie_anticipate  ; $14
        .word update_birb_left          ; $18
        .word update_birb_right         ; $1C
        .word update_birb_flying_left   ; $20
        .word update_birb_flying_right  ; $24
        .word update_mole_hole          ; $28
        .word update_mole_throwing      ; $2C
        .word update_mole_idle          ; $30
        .word update_wrench_projectile  ; $34
        .word update_challenge_spike    ; $38
        .repeat 17
        .word no_behavior ; unimplemented
        .endrepeat
        .word draw_disco_tile           ; $80 - plain floor
        .word draw_disco_tile           ; $84 - disco floor
        .word update_semisafe_tile      ; $88 - semisafe floor
        .word no_behavior               ; $8C - wall
        .word update_item_shadow        ; $90 - item shadow
        .word no_behavior               ; $94 - UNUSED
        .word no_behavior               ; $98 - treasure chest
        .word no_behavior               ; $9C - big key
        .word no_behavior               ; $A0 - gold sack
        .word update_weapon_shadow      ; $A4 - weapon shadow
        ; safety: fill out the rest of the table
        .repeat 22
        .word no_behavior
        .endrepeat

direct_attack_behaviors:
        ; enemies
        .word direct_attack_puff
        .word direct_attack_slime
        .word direct_attack_spider
        .word direct_attack_spider
        .word direct_attack_zombie
        .word direct_attack_zombie
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_mole_hole
        .word direct_attack_mole_throwing
        .word direct_attack_mole_idle
        .word no_behavior ; wrench projectile
        .word no_behavior ; challenge spike
        .repeat 17
        .word no_behavior
        .endrepeat
        ; floors, statics, and technical tiles
        .word no_behavior ; $80 - plain floor
        .word no_behavior ; $84 - disco floor
        .word no_behavior ; $88 - semisafe floor
        .word no_behavior ; $8C - wall face
        .word no_behavior ; $90 - item shadow
        .word no_behavior ; $94 - UNUSED
        .word attack_treasure_chest ; $98 - treasure chest
        .word no_behavior ; $9C - big key
        .word no_behavior ; $A0 - gold sack
        .word no_behavior ; $A4 - weapon shadow
        .word attack_exit_block ; $A8 - exit block
        .word no_behavior ; $AC - exit stairs
        ; safety: fill out the rest of the table
        .repeat 23
        .word no_behavior
        .endrepeat

indirect_attack_behaviors:
        .word no_behavior ; smoke puff can't attack itself
        .word indirect_attack_slime
        .word indirect_attack_spider
        .word indirect_attack_spider
        .word indirect_attack_zombie
        .word indirect_attack_zombie
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word no_behavior ; moles - do not move, and therefore will never be indirectly attacked
        .word no_behavior
        .word no_behavior
        .word no_behavior ; wrench projectile
        .word no_behavior ; challenge spike
        .repeat 17
        .word no_behavior
        .endrepeat
        ; safety: fill out the rest of the table
        .repeat 32
        .word no_behavior
        .endrepeat

bonk_behaviors:
        .word no_behavior ; standing in a smoke puff is fine
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word no_behavior ; mole holes, when unoccupied, do no damage
        .word basic_enemy_attacks_player ; moles when bonked, mostly with the flail, *do* do damage
        .word basic_enemy_attacks_player
        .word projectile_attacks_player ; projectiles do damage, but also need to erase themselves
        .word challenge_spike_solid_test
        .repeat 17
        .word no_behavior
        .endrepeat
        .word no_behavior ; $80 - plain floor
        .word no_behavior ; $84 - disco floor
        .word semisolid_attacks_player ; $88 - semisafe floor
        .word solid_tile_forbids_movement     ; $8C - wall face
        .word collect_item ; $90 - item shadow
        .word no_behavior  ; $94 - UNUSED
        .word solid_tile_forbids_movement ; $98 - treasure chest
        .word collect_key ; $9C - big key
        .word collect_gold_sack ; $A0 - gold sack
        .word collect_weapon ; $A4 - weapon shadow
        .word solid_tile_forbids_movement ; $A8 - exit block
        .word descend_stairs ; $AC - exit stairs
        .word collect_small_heart ; $B0
        .word no_behavior ; $B4
        .word no_behavior ; $B8
        .word no_behavior ; $BC
        .word no_behavior ; $C0
        .word no_behavior ; $C4
        .word no_behavior ; $C8
        .word collect_heart_container ; $CC - heart container
        ; safety: fill out the rest of the table
        .repeat 12
        .word no_behavior
        .endrepeat

; called just before suspending the map, typically because the player
; is moving to an adjacent room. handles all sorts of fun jank
suspend_behaviors:
        .word draw_cleared_disco_tile  ; smoke puff
        .word move_away_from_map_edge  ; slime
        .word move_away_from_map_edge  ; spider
        .word move_away_from_map_edge  ; spider (anticipating)
        .word move_away_from_map_edge  ; zombie
        .word move_away_from_map_edge  ; zombie (anticipating)
        .word move_away_from_map_edge  ; birb (left)
        .word move_away_from_map_edge  ; birb (right)
        .word move_away_from_map_edge  ; birb (flying, left)
        .word move_away_from_map_edge  ; birb (flying, right)
        .word no_behavior              ; mole hole
        .word no_behavior              ; mole throwing
        .word no_behavior              ; mole idle
        .word draw_cleared_disco_tile  ; wrench
        .word no_behavior              ; challenge spike
        .repeat 17
        .word no_behavior ; unimplemented
        .endrepeat
        .word draw_cleared_disco_tile   ; $80 - plain floor
        .word draw_cleared_disco_tile   ; $84 - disco floor
        .word no_behavior               ; $88 - semisafe floor
        .word no_behavior               ; $8C - wall
        .word suspend_item_shadow       ; $90 - item shadow
        .word no_behavior               ; $94 - UNUSED
        .word no_behavior               ; $98 - treasure chest
        .word no_behavior               ; $9C - big key
        .word no_behavior               ; $A0 - gold sack
        .word suspend_weapon_shadow     ; $A4 - weapon shadow
        ; safety: fill out the rest of the table
        .repeat 22
        .word no_behavior
        .endrepeat

.proc __trampoline
        perform_zpcm_inc
        jmp (DestPtr)
        ; tail call
.endproc

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FAR_update_static_enemy_row
Length := R13
CurrentRow := R14
StartingTile := R15
        lda #::BATTLEFIELD_WIDTH
        sta Length
loop:
        ldx StartingTile
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda static_behaviors, x
        sta DestPtr
        lda static_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline
        inc StartingTile
        dec Length
        bne loop
        rts
.endproc

.proc FAR_clear_active_move_flags
        ldx #0
loop:
        perform_zpcm_inc
        lda tile_flags, x
        and #%01111111
        sta tile_flags, x
        inx
        cpx #BATTLEFIELD_SIZE
        bne loop
        rts
.endproc

.proc FAR_attack_enemy_tile
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9
; We don't use these, but we should know not to clobber them
TargetRow := R14
TargetCol := R15
        
        perform_zpcm_inc

        ldx AttackSquare
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda direct_attack_behaviors, x
        sta DestPtr
        lda direct_attack_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline

        perform_zpcm_inc

        rts
.endproc

.proc FAR_player_collides_with_tile
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        ldx TargetSquare
        lda battlefield, x
        lsr
        and #%01111110
        tax
        lda bonk_behaviors, x
        sta DestPtr
        lda bonk_behaviors+1, x
        sta DestPtr+1
        perform_zpcm_inc
        jsr __trampoline

        rts
.endproc

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FAR_suspend_entire_room
CurrentSquare := R15
        lda #0
        sta CurrentSquare
loop:
        ldx CurrentSquare
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda suspend_behaviors, x
        sta DestPtr
        lda suspend_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline
        inc CurrentSquare
        lda CurrentSquare
        cmp #BATTLEFIELD_SIZE
        bne loop
        rts
.endproc