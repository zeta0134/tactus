    .macpack longbranch

    .include "../build/tile_defs.inc"
    .include "beat_tracker.inc"
    .include "indicators.inc"
    .include "kernel.inc"
    .include "player.inc"
    .include "slowam.inc"
    .include "sprites.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .segment "RAM"

LastDisplayedComboBeat: .res 1
LastDisplayedChain: .res 1
ComboBounceHeightPos: .res 1
ChainBounceHeightPos: .res 1
PauseBouncePos: .res 1

    .segment "CODE_3"

combo_left_lut:
    .byte $00
    .byte $00
    .byte SPRITE_TILE_TACTUSINDICATORS11 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS13 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS14 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS16 + 0

combo_middle_lut:
    .byte $00
    .byte $00
    .byte SPRITE_TILE_TACTUSINDICATORS12 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS13 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS15 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS16 + 2

combo_right_lut:
    .byte $00
    .byte $00
    .byte SPRITE_TILE_TACTUSINDICATORS12 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS14 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS15 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS17 + 0

chain_left_lut:
    .byte $00 ; 0 (not used)
    .byte $00 ; 1 (not used)
    .byte SPRITE_TILE_TACTUSINDICATORS01 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS02 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS04 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS05 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS07 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS08 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS10 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS17 + 2

chain_middle_lut:
    .byte $00
    .byte $00
    .byte SPRITE_TILE_TACTUSINDICATORS01 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS03 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS04 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS06 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS07 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS09 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS10 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS18 + 0

chain_right_lut:
    .byte $00
    .byte $00
    .byte SPRITE_TILE_TACTUSINDICATORS02 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS03 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS05 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS06 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS08 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS09 + 2
    .byte SPRITE_TILE_TACTUSINDICATORS11 + 0
    .byte SPRITE_TILE_TACTUSINDICATORS18 + 2

bounce_height_table:
    .byte 2, 3, 3, 2, 1, 0, 0, 0, 0
BOUNCE_END = 6

.proc FAR_update_indicators
IndicatorX := R0
IndicatorY := R1
    ; sanity check: do we have anything to display?
    ; only display the player's combo if it is greater than 1
    lda PlayerCombo
    cmp #2
    bcs display_indicators
    ; only display the player's chain if it is greater than 1
    lda PlayerChain
    cmp #2
    bcs display_indicators
    ; nothing to display! sprites are already disabled, bail now.
    jmp cleanup
display_indicators:
    jsr compute_initial_indicator_position
    jsr draw_chain_indicator
    jsr draw_combo_indicator
cleanup:
    lda PlayerChain
    sta LastDisplayedChain
    lda CurrentBeatCounter
    sta LastDisplayedComboBeat
    ; as it's convenient, check for and draw the pause indicator here
    jsr draw_pause_indicator
    rts
.endproc

.proc compute_initial_indicator_position
IndicatorX := R0
IndicatorY := R1
    lda PlayerCurrentX+1
    sec
    sbc #4
    sta IndicatorX

    lda PlayerRow
    cmp #4
    bcs upper_indicator
lower_indicator:
    lda PlayerCurrentY+1
    clc
    adc #32
    sta IndicatorY
    rts
upper_indicator:
    lda PlayerCurrentY+1
    sec
    sbc #40
    sta IndicatorY
    rts
.endproc

.proc compute_next_indicator_position
IndicatorY := R1
    lda PlayerRow
    cmp #4
    bcs upper_indicator
lower_indicator:
    lda IndicatorY
    clc
    adc #16
    sta IndicatorY
    rts
upper_indicator:
    lda IndicatorY
    sec
    sbc #16
    sta IndicatorY
    rts
.endproc

MAX_CHAIN = 9
MAX_COMBO = 5

.proc draw_chain_indicator
IndicatorX := R0
IndicatorY := R1
SpritePtr := R2
ChainIndex := R4
    perform_zpcm_inc
    lda PlayerChain
    cmp #2
    jcc done_with_chain

    lda PlayerChain
    cmp LastDisplayedChain
    beq keep_current_bounce_position
    lda #0
    sta ChainBounceHeightPos
keep_current_bounce_position:

    ldx PlayerChain
    cpx #MAX_CHAIN
    bcc chain_in_range
    ldx #MAX_CHAIN
chain_in_range:
    stx ChainIndex

    ldy #FIRST_INDICATOR_OAM_INDEX
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ChainBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ChainIndex
    lda chain_left_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #2 ; reddish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    ldy #FIRST_INDICATOR_OAM_INDEX+1
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    clc
    adc #8
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ChainBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ChainIndex
    lda chain_middle_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #2 ; reddish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    ldy #FIRST_INDICATOR_OAM_INDEX+2
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    clc
    adc #16
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ChainBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ChainIndex
    lda chain_right_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #2 ; reddish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    jsr compute_next_indicator_position

    lda ChainBounceHeightPos
    cmp #BOUNCE_END
    beq done_with_chain
    inc ChainBounceHeightPos
done_with_chain:
    perform_zpcm_inc
    rts
.endproc

.proc draw_combo_indicator
IndicatorX := R0
IndicatorY := R1
SpritePtr := R2
ComboIndex := R4
    lda PlayerCombo
    cmp #2
    jcc done_with_combo

    lda CurrentBeatCounter
    cmp LastDisplayedComboBeat
    beq keep_current_bounce_position
    lda #0
    sta ComboBounceHeightPos
keep_current_bounce_position:

    ldx PlayerCombo
    cpx #MAX_COMBO
    bcc combo_in_range
    ldx #MAX_COMBO
combo_in_range:
    stx ComboIndex

    perform_zpcm_inc

    ldy #SECOND_INDICATOR_OAM_INDEX
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ComboBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ComboIndex
    lda combo_left_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #3 ; purpleish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    ldy #SECOND_INDICATOR_OAM_INDEX+1
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    clc
    adc #8
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ComboBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ComboIndex
    lda combo_middle_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #3 ; purpleish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    ldy #SECOND_INDICATOR_OAM_INDEX+2
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1
    lda IndicatorX
    clc
    adc #16
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda IndicatorY
    ldx ComboBounceHeightPos
    sec 
    sbc bounce_height_table, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    ldx ComboIndex
    lda combo_right_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda #3 ; purpleish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    perform_zpcm_inc

    jsr compute_next_indicator_position

    lda ComboBounceHeightPos
    cmp #BOUNCE_END
    beq done_with_combo
    inc ComboBounceHeightPos
done_with_combo:
    perform_zpcm_inc
    rts
.endproc

pause_bounce_lut:
    .byte 0, 0, 0, 0, 0, 0, 0 ; padding for reverse draw order ripple
    ;.byte 3, 3, 2, 1, 0, 0 ; short bounce
    .byte 3, 3, 3, 3, 2, 2, 1, 1 ; extended bounce
    .repeat 64 ; padding for safety
    .byte 0 
    .endrepeat

; in reverse, since that is the order in which we draw
pause_tiles_lut:
    .byte SPRITE_TILE_PAUSE_INDICATOR_EP + 2 ; symbol
    .byte SPRITE_TILE_PAUSE_INDICATOR_EP + 0 ; E
    .byte SPRITE_TILE_PAUSE_INDICATOR_US + 2 ; S
    .byte SPRITE_TILE_PAUSE_INDICATOR_US + 0 ; U
    .byte SPRITE_TILE_PAUSE_INDICATOR_PA + 2 ; A
    .byte SPRITE_TILE_PAUSE_INDICATOR_PA + 0 ; P
    .byte SPRITE_TILE_PAUSE_INDICATOR_EP + 2 ; symbol

.proc draw_pause_indicator
CurrentPosX := R0
BasePosY := R1
CurrentBounceOffset := R2
CurrentLetterIndex := R3
SpritePtr := R4

    ; only actually draw if we are paused!
    lda PlayerIsPaused
    bne perform_draw
    ; otherwise set the counter way after a single beat
    ; so we don't have a weird startup
    lda #16
    sta PauseBouncePos
    rts
perform_draw:

    lda TrackedMusicPos
    bne keep_current_bounce_position
    lda #0
    sta PauseBouncePos
keep_current_bounce_position:

    lda PlayerRow
    cmp #5
    bcs regular_pos
avoid_player_pos:
    lda #132
    jmp store_height
regular_pos:
    lda #48
store_height:
    sta BasePosY

    lda #160
    sta CurrentPosX

    lda PauseBouncePos
    sta CurrentBounceOffset

    lda #0
    sta CurrentLetterIndex

loop:
    ; Draw a thing!
    lda #PAUSE_INDICATOR_OAM_INDEX
    clc
    adc CurrentLetterIndex
    tay
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1

    lda CurrentPosX
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y

    lda BasePosY
    sec
    ldx CurrentBounceOffset
    sbc pause_bounce_lut, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y

    ldx CurrentLetterIndex
    lda pause_tiles_lut, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y

    lda #1 ; yellowish palette
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

    ; Increment all the things and advance
    inc CurrentLetterIndex
    lda CurrentLetterIndex
    cmp #7
    beq done

    lda CurrentPosX
    sec
    sbc #12
    sta CurrentPosX

    inc CurrentBounceOffset
    jmp loop

done:
    inc PauseBouncePos
    rts
.endproc