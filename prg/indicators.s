    .macpack longbranch

    .include "../build/tile_defs.inc"
    .include "indicators.inc"
    .include "kernel.inc"
    .include "player.inc"
    .include "slowam.inc"
    .include "sprites.inc"
    .include "zeropage.inc"

    .segment "RAM"

LastDisplayedComboBeat: .res 1
LastDisplayedChain: .res 1
ComboBounceHeightPos: .res 1
ChainBounceHeightPos: .res 1

    .segment "CODE_3"

; TODO: move these up top
FIRST_INDICATOR_OAM_INDEX = 32+12
SECOND_INDICATOR_OAM_INDEX = 32+12+3

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

    jsr compute_next_indicator_position

    lda ChainBounceHeightPos
    cmp #BOUNCE_END
    beq done_with_chain
    inc ChainBounceHeightPos
done_with_chain:
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

    jsr compute_next_indicator_position

    lda ComboBounceHeightPos
    cmp #BOUNCE_END
    beq done_with_combo
    inc ComboBounceHeightPos
done_with_combo:
    rts
.endproc
