    .include "player.inc"
    .include "torchlight.inc"
    .include "word_util.inc"
    .include "zeropage.inc"

    .segment "RAM"

current_lighting_row: .res 1


    .segment "CODE_3"
    ; TODO: use more than just one of these
    .include "../build/torchlight.incs"

.proc FAR_init_torchlight
    lda #0
    sta current_lighting_row
    rts
.endproc

; For now, each call to update_torchlight should draw one (1) row and exit
.proc FAR_update_torchlight
    jsr setup_torchlight_pointers
    jsr draw_one_torchlight_row

    ; TODO: can we make this update in a pseudorandom order?
    inc current_lighting_row
    lda #20
    cmp current_lighting_row
    bne done
    lda #0
    sta current_lighting_row
done:
    rts
.endproc

.proc setup_torchlight_pointers
FirstNametablePtr := R0
SecondNametablePtr := R2
TorchlightPtr := R4

Scratch := R6
    ; Compute the nametable destinations, which are always based on the current lighting row
    lda #$58
    sta FirstNametablePtr+1
    lda #$5C
    sta SecondNametablePtr+1

    lda #0
    sta Scratch
    lda current_lighting_row
    clc
    adc #4 ; the battlefield starts on row 2 of the nametable, and spans its full width
    .repeat 5
    asl
    rol Scratch
    .endrepeat
    sta FirstNametablePtr+0
    sta SecondNametablePtr+0
    clc
    lda Scratch
    adc FirstNametablePtr+1
    sta FirstNametablePtr+1
    clc
    lda Scratch
    adc SecondNametablePtr+1
    sta SecondNametablePtr+1

    ; Compute the index into the lookup table, which is based on the current
    ; lighting row and the player's current position
    st16 TorchlightPtr, torchlight_test_lut

    ; The torchlight LUT is 64x40, which is twice the size of the battlefield.
    ; Light is centered in this LUT, such that a 2x2 square at position 31, 19
    ; lines up with the fully lit 16x16 square in the middle of the field. Thus,
    ; we use this as our basis and compute the starting point in the table relative
    ; to the player's current position in 2x2 squares

    lda #0
    sta Scratch
    ; Y = 19 - PlayerRow * 2
    lda #19
    sec
    sbc PlayerRow ; cannot carry, value ranges from 0-9
    sbc PlayerRow ; also cannot carry
    clc
    adc current_lighting_row
    ; TorchlightPtr += Y * 64
    .repeat 6
    asl
    rol Scratch
    .endrepeat
    clc
    adc TorchlightPtr+0
    sta TorchlightPtr+0
    lda Scratch
    adc TorchlightPtr+1
    sta TorchlightPtr+1
    ; X = 31 - PlayerCol * 2
    lda #31
    sec
    sbc PlayerCol
    sbc PlayerCol
    ; TorchlightPtr += X
    clc
    adc TorchlightPtr+0
    sta TorchlightPtr+0
    lda #0
    adc TorchlightPtr+1
    sta TorchlightPtr+1

    rts
.endproc


.proc draw_one_torchlight_row
FirstNametablePtr := R0
SecondNametablePtr := R2
TorchlightPtr := R4

    ; everything from here should work with any setup of the above
    ldy #0
    .repeat 32 ; (36*32) (1152)
    lda (FirstNametablePtr), y  ; 5
    ; keep everything except old light level
    and #%11111100              ; 2
    ora (TorchlightPtr), y      ; 5
    sta (FirstNametablePtr), y  ; 5
    lda (SecondNametablePtr), y ; 5
    ; keep everything except old light level
    and #%11111100              ; 2
    ora (TorchlightPtr), y      ; 5
    sta (SecondNametablePtr), y ; 5
    iny                         ; 2
    .endrepeat

    rts
.endproc