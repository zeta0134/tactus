        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "kernel.inc"
        .include "player.inc"
        .include "sprites.inc"
        .include "zeropage.inc"

.zeropage

.segment "RAM"

PlayerSpriteIndex: .res 1
PlayerRow: .res 1
PlayerCol: .res 1


BATTLEFIELD_OFFSET_X = 16
BATTLEFIELD_OFFSET_Y = 32

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

; Called once at the beginning of every beat
.proc update_player
        rts
.endproc