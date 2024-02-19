    .include "bhop/bhop.inc"
    .include "far_call.inc"
    .include "player.inc"
    .include "rainbow.inc"
    .include "torchlight.inc"
    .include "word_util.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .segment "RAM"

current_lighting_counter: .res 1
current_lighting_row: .res 1
current_radius: .res 1

current_base_radius: .res 1
target_counter: .res 1
target_radius: .res 1

torchlight_bank: .res 1

    .segment "TORCHLIGHT_0"
    .include "../build/torchlight/torchlight_0.incs"
    .include "../build/torchlight/torchlight_1.incs"
    .include "../build/torchlight/torchlight_2.incs"

    .segment "TORCHLIGHT_1"
    .include "../build/torchlight/torchlight_3.incs"
    .include "../build/torchlight/torchlight_4.incs"
    .include "../build/torchlight/torchlight_5.incs"

    .segment "TORCHLIGHT_2"
    .include "../build/torchlight/torchlight_6.incs"
    .include "../build/torchlight/torchlight_7.incs"
    .include "../build/torchlight/torchlight_8.incs"

    .segment "TORCHLIGHT_3"
    .include "../build/torchlight/torchlight_9.incs"
    .include "../build/torchlight/torchlight_10.incs"
    .include "../build/torchlight/torchlight_11.incs"

    .segment "TORCHLIGHT_4"
    .include "../build/torchlight/torchlight_12.incs"
    .include "../build/torchlight/torchlight_13.incs"
    .include "../build/torchlight/torchlight_14.incs"

    .segment "TORCHLIGHT_5"
    .include "../build/torchlight/torchlight_15.incs"
    .include "../build/torchlight/torchlight_16.incs"
    .include "../build/torchlight/torchlight_17.incs"

    .segment "TORCHLIGHT_6"
    .include "../build/torchlight/torchlight_18.incs"
    .include "../build/torchlight/torchlight_19.incs"
    .include "../build/torchlight/torchlight_20.incs"

    .segment "TORCHLIGHT_7"
    .include "../build/torchlight/torchlight_21.incs"
    .include "../build/torchlight/torchlight_22.incs"
    .include "../build/torchlight/torchlight_23.incs"

    .segment "TORCHLIGHT_8"
    .include "../build/torchlight/torchlight_24.incs"
    .include "../build/torchlight/torchlight_25.incs"
    .include "../build/torchlight/torchlight_26.incs"

    .segment "TORCHLIGHT_9"
    .include "../build/torchlight/torchlight_27.incs"
    .include "../build/torchlight/torchlight_28.incs"
    .include "../build/torchlight/torchlight_29.incs"

    .segment "TORCHLIGHT_A"
    .include "../build/torchlight/torchlight_30.incs"
    .include "../build/torchlight/torchlight_31.incs"

    .segment "CODE_3"

torchlight_update_table:
  .byte $0d, $08, $0f, $04, $06, $0b, $13, $01, $0e, $11, $02, $12, $00, $03, $10, $07
  .byte $0a, $09, $05, $0c, $08, $09, $10, $04, $11, $0d, $0f, $05, $0a, $0e, $07, $12
  .byte $06, $0c, $0b, $02, $13, $03, $01, $00, $07, $05, $06, $0b, $10, $00, $0d, $13
  .byte $0c, $01, $11, $04, $09, $12, $08, $02, $03, $0a, $0f, $0e, $02, $08, $00, $05
  .byte $07, $06, $0c, $0f, $01, $0e, $11, $0b, $10, $09, $0d, $12, $13, $03, $0a, $04
  .byte $12, $01, $06, $0c, $02, $0b, $10, $07, $13, $0a, $11, $05, $0d, $03, $0e, $00
  .byte $09, $04, $0f, $08, $0c, $13, $02, $08, $03, $0d, $00, $0f, $0e, $01, $12, $0b
  .byte $07, $10, $04, $0a, $05, $11, $06, $09, $08, $01, $05, $0b, $12, $0d, $0f, $04
  .byte $13, $02, $09, $00, $07, $03, $11, $0e, $0c, $06, $0a, $10, $08, $13, $04, $0c
  .byte $0f, $0d, $0e, $03, $02, $01, $11, $06, $09, $10, $0a, $07, $00, $0b, $12, $05
  .byte $13, $00, $0e, $0a, $04, $06, $08, $10, $07, $03, $0d, $0f, $12, $01, $02, $05
  .byte $09, $0b, $0c, $11, $07, $0c, $06, $05, $02, $0f, $13, $08, $0b, $0a, $0d, $00
  .byte $03, $11, $12, $10, $04, $09, $0e, $01, $11, $04, $02, $10, $0d, $01, $0f, $06
  .byte $0e, $08, $07, $0c, $0a, $03, $0b, $12, $05, $09, $13, $00, $13, $01, $10, $02
  .byte $06, $08, $0b, $04, $03, $07, $0e, $0a, $00, $05, $11, $0f, $09, $0c, $0d, $12
  .byte $11, $03, $10, $06, $02, $00, $05, $09, $0f, $0d, $01, $08, $07, $04, $0e, $0c

torchlight_luts_low:
    .repeat 32, i
    .byte <.ident(.concat("torchlight_lut_", .string(i)))
    .endrepeat
torchlight_luts_high:
    .repeat 32, i
    .byte >.ident(.concat("torchlight_lut_", .string(i)))
    .endrepeat
torchlight_luts_bank:
    .repeat 32, i
    .byte <.bank(.ident(.concat("torchlight_lut_", .string(i))))
    .endrepeat

breathing_lut:
    ;.byte 2, 3, 3, 4, 4, 4, 3, 3, 2, 1, 1, 0, 0, 0, 1, 1 ; strength 2
    ;.byte 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 1 ; strength 1
    .byte 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 ; strength 0.5, synced to music


.proc FAR_init_torchlight
    lda #0
    sta current_lighting_row

    ; initialize all counters to 1, so they update right away
    ; when decremented the first time
    lda #1
    sta target_counter

    lda #1
    sta current_radius
    sta current_base_radius

    lda #11
    sta target_radius
    rts
.endproc

; For now, each call to update_torchlight should draw one (1) row and exit
.proc FAR_update_torchlight
    jsr update_current_radius
    rts
.endproc

.proc FAR_draw_torchlight
    perform_zpcm_inc
    jsr setup_torchlight_pointers

    access_data_bank torchlight_bank
    jsr draw_one_torchlight_row
    perform_zpcm_inc
    restore_previous_bank

    ; TODO: can we make this update in a pseudorandom order?
    inc current_lighting_counter
    ldx current_lighting_counter
    lda torchlight_update_table, x
    sta current_lighting_row
    perform_zpcm_inc
    rts
.endproc

.proc update_current_radius
    dec target_counter
    bne skip_update_target
    lda #20
    sta target_counter
    lda target_radius
    cmp current_base_radius
    beq skip_update_target
    bcc decrease_current
increase_current:
    inc current_base_radius
    jmp skip_update_target
decrease_current:
    dec current_base_radius
skip_update_target:

    lda row_counter
    and #%00001111
    tax

    lda current_base_radius
    clc
    adc breathing_lut, x
    cmp #31
    bcs overflow
    sta current_radius
    rts
overflow:
    lda #31
    sta current_radius
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
    
    ;st16 TorchlightPtr, torchlight_10_lut
    ldx current_radius
    lda torchlight_luts_low, x
    sta TorchlightPtr+0
    lda torchlight_luts_high, x
    sta TorchlightPtr+1
    lda torchlight_luts_bank, x
    sta torchlight_bank

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
    ; X = 31 - PlayerCol * 2 - 2
    lda #(31 - 2)
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
    perform_zpcm_inc
    .endrepeat

    rts
.endproc