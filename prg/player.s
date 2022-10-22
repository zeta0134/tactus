        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "sprites.inc"
        .include "zeropage.inc"

.zeropage

.segment "RAM"

PlayerSpriteIndex: .res 1
PlayerRow: .res 1
PlayerCol: .res 1

PlayerNextDirection: .res 1


BATTLEFIELD_OFFSET_X = 16
BATTLEFIELD_OFFSET_Y = 32

DIRECTION_NORTH = 1
DIRECTION_EAST  = 2
DIRECTION_SOUTH = 3
DIRECTION_WEST  = 4

.segment "PRGFIXED_C000"

.proc init_player
MetaSpriteIndex := R0
        ; spawn in the player sprite
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        stx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #0 ; irrelevant
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #$FF ; intentionally offscreen
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #SPRITES_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x

        lda #6
        sta PlayerRow
        sta PlayerCol

        rts

sprite_failed:
        ; what? this should never happen...
        rts
.endproc

; Called once every frame
.proc draw_player
        ; FOR NOW, just immediately draw the player based on their tile position
        ldx PlayerSpriteIndex
        lda PlayerCol
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x
        lda PlayerRow
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta sprite_table + MetaSpriteState::PositionY, x
        rts
.endproc

; Called once every frame, after input has been processed.
; Updates variables related to the desired direction and 
; whether a down press has occurred at all this frame
.proc determine_player_intent
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT)
        bit ButtonsDown
        bne handle_button_press
        rts ; all done
handle_button_press:
        ; For now, the last button press we receive in a given beat
        ; will be the one that counts once we begin processing.
        ; TODO: detect if we receive an extra button press? we'd need 
        ; to detect the "all buttons released" state, cache that, and then
        ; check it when a new button down arrives. Ignoring this for now.
check_north:
        lda #KEY_UP
        bit ButtonsDown
        beq check_east
        lda #DIRECTION_NORTH
        sta PlayerNextDirection
        rts
check_east:
        lda #KEY_RIGHT
        bit ButtonsDown
        beq check_south        
        lda #DIRECTION_EAST
        sta PlayerNextDirection
        rts
check_south:
        lda #KEY_DOWN
        bit ButtonsDown
        beq check_west
        lda #DIRECTION_SOUTH
        sta PlayerNextDirection
        rts
check_west:
        lda #KEY_LEFT
        bit ButtonsDown
        beq no_valid_press ; this shouldn't be reachable
        lda #DIRECTION_WEST
        sta PlayerNextDirection        
no_valid_press:
        rts
.endproc

; Called once at the beginning of every beat
.proc update_player
TargetRow := R0
TargetCol := R1
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol

; TODO: If no move or attack was attempted, reset the combo counter (assuming we implement one)

; TODO: Attempt an attack. If we hit something, most weapon types will skip movement

; Movement 
        lda PlayerNextDirection
check_north:
        cmp #DIRECTION_NORTH
        bne check_east
        dec TargetRow
        jmp done_choosing_target
check_east:
        cmp #DIRECTION_EAST
        bne check_south
        inc TargetCol
        jmp done_choosing_target
check_south:
        cmp #DIRECTION_SOUTH
        bne check_west
        inc TargetRow
        jmp done_choosing_target
check_west:
        cmp #DIRECTION_WEST
        bne done_choosing_target
        dec TargetCol        

done_choosing_target:
        ; FOR NOW, merely set the player's new row and column and exit.
        ; TODO: check to see if this is a valid tile and, if not, forbid the move
        ; TODO: lerp from the old to the new position
        ; TODO: set up and apply a jump offset to the Y position here, even if the move is forbbidden (the jump in place communicates a "try")
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        rts
.endproc