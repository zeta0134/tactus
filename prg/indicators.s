    .macpack longbranch

    .include "../build/tile_defs.inc"

    .include "_globals.inc"

    .include "beat_tracker.inc"
    .include "indicators.inc"
    .include "kernel.inc"
    .include "player.inc"
    .include "slowam.inc"
    .include "sprites.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .segment "PRGRAM"

LastDisplayedComboBeat: .res 1
LastDisplayedChain: .res 1
ComboBounceHeightPos: .res 1
ChainBounceHeightPos: .res 1
PauseBouncePos: .res 1

    .segment "CODE_3"

combo_left_lut:
    .byte $00
    .byte $00
    .byte <SPRITE_INDICATORS_02_CHAIN_COMBO_11 + SPRITE_OFFSET_COMBO + 2
    .byte <SPRITE_INDICATORS_03_COMBO_13 + SPRITE_OFFSET_COMBO + 0
    .byte <SPRITE_INDICATORS_03_COMBO_14 + SPRITE_OFFSET_COMBO + 2
    .byte <SPRITE_INDICATORS_03_COMBO_16 + SPRITE_OFFSET_COMBO + 0

combo_middle_lut:
    .byte $00
    .byte $00
    .byte <SPRITE_INDICATORS_02_COMBO_12 + SPRITE_OFFSET_COMBO + 0
    .byte <SPRITE_INDICATORS_03_COMBO_13 + SPRITE_OFFSET_COMBO + 2
    .byte <SPRITE_INDICATORS_03_COMBO_15 + SPRITE_OFFSET_COMBO + 0
    .byte <SPRITE_INDICATORS_03_COMBO_16 + SPRITE_OFFSET_COMBO + 2

combo_right_lut:
    .byte $00
    .byte $00
    .byte <SPRITE_INDICATORS_02_COMBO_12 + SPRITE_OFFSET_COMBO + 2
    .byte <SPRITE_INDICATORS_03_COMBO_14 + SPRITE_OFFSET_COMBO + 0
    .byte <SPRITE_INDICATORS_03_COMBO_15 + SPRITE_OFFSET_COMBO + 2
    .byte <SPRITE_INDICATORS_03_COMBO_WOW_17 + SPRITE_OFFSET_COMBO + 0

combo_bank_lut:
    .byte $00
    .byte $00
    .byte >SPRITE_INDICATORS_02_CHAIN_COMBO_11
    .byte >SPRITE_INDICATORS_03_COMBO_13
    .byte >SPRITE_INDICATORS_03_COMBO_14
    .byte >SPRITE_INDICATORS_03_COMBO_16

chain_left_lut:
    .byte $00 ; 0 (not used)
    .byte $00 ; 1 (not used)
    .byte <SPRITE_INDICATORS_01_CHAIN_01 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_01_CHAIN_02 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_01_CHAIN_04 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_01_CHAIN_05 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_02_CHAIN_07 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_02_CHAIN_08 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_02_CHAIN_10 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_03_COMBO_WOW_17 + SPRITE_OFFSET_CHAIN + 2

chain_middle_lut:
    .byte $00
    .byte $00
    .byte <SPRITE_INDICATORS_01_CHAIN_01 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_01_CHAIN_03 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_01_CHAIN_04 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_01_CHAIN_06 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_02_CHAIN_07 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_02_CHAIN_09 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_02_CHAIN_10 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_03_WOW_18 + SPRITE_OFFSET_CHAIN + 0

chain_right_lut:
    .byte $00
    .byte $00
    .byte <SPRITE_INDICATORS_01_CHAIN_02 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_01_CHAIN_03 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_01_CHAIN_05 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_01_CHAIN_06 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_02_CHAIN_08 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_02_CHAIN_09 + SPRITE_OFFSET_CHAIN + 2
    .byte <SPRITE_INDICATORS_02_CHAIN_COMBO_11 + SPRITE_OFFSET_CHAIN + 0
    .byte <SPRITE_INDICATORS_03_WOW_18 + SPRITE_OFFSET_CHAIN + 2

chain_bank_lut:
    .byte $00 ; 0 (not used)
    .byte $00 ; 1 (not used)
    .byte >SPRITE_INDICATORS_01_CHAIN_01
    .byte >SPRITE_INDICATORS_01_CHAIN_02
    .byte >SPRITE_INDICATORS_01_CHAIN_04
    .byte >SPRITE_INDICATORS_01_CHAIN_05
    .byte >SPRITE_INDICATORS_02_CHAIN_07
    .byte >SPRITE_INDICATORS_02_CHAIN_08
    .byte >SPRITE_INDICATORS_02_CHAIN_10
    .byte >SPRITE_INDICATORS_03_COMBO_WOW_17

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

    lda chain_bank_lut, x
    sta SPRITE_BANK_CHAIN

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

    lda combo_bank_lut, x
    sta SPRITE_BANK_COMBO

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
    .byte <SPRITE_INDICATORS_04_PAUSE_EP + SPRITE_OFFSET_COMBO + 2 ; symbol
    .byte <SPRITE_INDICATORS_04_PAUSE_EP + SPRITE_OFFSET_COMBO + 0 ; E
    .byte <SPRITE_INDICATORS_04_PAUSE_US + SPRITE_OFFSET_COMBO + 2 ; S
    .byte <SPRITE_INDICATORS_04_PAUSE_US + SPRITE_OFFSET_COMBO + 0 ; U
    .byte <SPRITE_INDICATORS_04_PAUSE_PA + SPRITE_OFFSET_COMBO + 2 ; A
    .byte <SPRITE_INDICATORS_04_PAUSE_PA + SPRITE_OFFSET_COMBO + 0 ; P
    .byte <SPRITE_INDICATORS_04_PAUSE_EP + SPRITE_OFFSET_COMBO + 2 ; symbol

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

    set_sprite_bank SPRITE_BANK_COMBO, SPRITE_INDICATORS_04_PAUSE_PA

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