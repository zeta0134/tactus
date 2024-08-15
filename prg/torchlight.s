    .macpack longbranch

    .include "bhop/bhop.inc"
    .include "battlefield.inc"
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
current_torchlight_radius: .res 1

target_counter: .res 1
target_torchlight_radius: .res 1

fully_lit_cooldown: .res 1

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
  .byte $14, $0c, $0f, $01, $09, $0e, $04, $0a, $08, $15, $07, $12, $06, $10, $02, $05
  .byte $0b, $13, $03, $00, $0d, $11, $15, $03, $00, $0a, $0b, $05, $02, $01, $0e, $14
  .byte $06, $12, $09, $08, $10, $0c, $0d, $04, $0f, $07, $11, $13, $15, $08, $09, $06
  .byte $0d, $10, $12, $11, $00, $05, $0e, $0f, $13, $04, $01, $0b, $07, $0c, $0a, $02
  .byte $03, $14, $0b, $05, $0a, $0e, $12, $0f, $11, $0c, $15, $09, $07, $13, $06, $08
  .byte $00, $14, $01, $10, $02, $04, $0d, $03, $11, $05, $0a, $0f, $01, $0e, $0b, $12
  .byte $0d, $04, $07, $02, $13, $08, $15, $03, $10, $06, $00, $09, $0c, $14, $14, $0c
  .byte $02, $00, $15, $0a, $09, $04, $01, $03, $12, $0e, $0d, $0f, $0b, $11, $05, $07
  .byte $10, $13, $08, $06, $0b, $02, $09, $14, $05, $06, $01, $0f, $11, $12, $15, $0a
  .byte $0d, $0e, $07, $0c, $13, $04, $00, $08, $10, $03, $0a, $14, $12, $0e, $00, $0c
  .byte $01, $09, $13, $04, $0d, $0f, $07, $15, $11, $08, $02, $03, $06, $0b, $10, $05
  .byte $09, $15, $08, $0b, $11, $0c, $13, $01, $07, $0d, $06, $12, $14, $00, $05, $0a
  .byte $0f, $0e, $02, $03, $04, $10, $06, $0c, $08, $0b, $0a, $11, $13, $07, $01, $10
  .byte $05, $15, $0e, $02, $03, $09, $0d, $12, $04, $00, $0f, $14, $0f, $0a, $00, $0b
  .byte $05, $0e, $10, $14, $09, $13, $06, $03, $07, $01, $04, $02, $12, $0c, $11, $08
  .byte $15, $0d, $13, $05, $02, $0a, $15, $14, $0d, $07, $0e, $00, $0b, $03, $12, $06

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

.proc FAR_init_torchlight
    lda #0
    sta current_lighting_row
    sta fully_lit_cooldown

    ; initialize all counters to 1, so they update right away
    ; when decremented the first time
    lda #1
    sta target_counter

    lda #30
    sta current_torchlight_radius
    sta target_torchlight_radius
    rts
.endproc

; For now, each call to update_torchlight should draw one (1) row and exit
.proc FAR_update_torchlight
    jsr update_current_radius
    rts
.endproc

.proc FAR_draw_torchlight
    perform_zpcm_inc
    lda current_torchlight_radius
    cmp #30
    beq at_max_brightness
    lda #0
    sta fully_lit_cooldown
    jmp proceed_to_draw
at_max_brightness:
    lda fully_lit_cooldown
    cmp #64
    bcc proceed_to_draw
    ; fully drawn at max brightness; nothing else to do.
    rts
proceed_to_draw:

    perform_zpcm_inc
    jsr setup_torchlight_pointers
    access_data_bank torchlight_bank
    perform_zpcm_inc
    jsr draw_one_torchlight_row
    perform_zpcm_inc
    restore_previous_bank

    ; TODO: can we make this update in a pseudorandom order?
    inc current_lighting_counter
    ldx current_lighting_counter
    lda torchlight_update_table, x
    sta current_lighting_row

    lda current_torchlight_radius
    cmp #30
    bne done
    lda fully_lit_cooldown
    cmp #64
    bcs done
    inc fully_lit_cooldown
done:

    perform_zpcm_inc
    rts
.endproc

; Meant for level transitions, this (slowly!) sets the entire inactive
; buffer to its darkest (%11) shade, all in one go. Will almost certainly
; cause lag, so use sparingly
.proc FAR_darken_entire_inactive_torchlight
TorchlightValue := R0
    lda #%11
    sta TorchlightValue
    jmp set_static_torchlight_common
    ; tail call
.endproc

; Same deal as above, but for lightening (%00) rooms on entry
.proc FAR_lighten_entire_inactive_torchlight
TorchlightValue := R0
    lda #%00
    sta TorchlightValue
    jmp set_static_torchlight_common
    ; tail call
.endproc

.proc set_static_torchlight_common
TorchlightValue := R0
NametablePtr := R2
TilesRemaining := R4
    lda #0
    sta NametablePtr+0
    lda active_battlefield
    beq second_nametable
first_nametable:
    lda #$58
    jmp done_picking_nametable
second_nametable:
    lda #$5C
done_picking_nametable:
    sta NametablePtr+1

    lda #(BATTLEFIELD_HEIGHT*2)
    sta TilesRemaining
big_giant_loop:
    ldy #0
    .repeat 32
    perform_zpcm_inc
    lda (NametablePtr), y       ; 5
    ; keep everything except old light level
    and #%11111100              ; 2
    ora TorchlightValue         ; 3
    sta (NametablePtr), y       ; 6
    iny                         ; 2
    .endrepeat
    add16b NametablePtr, #32
    dec TilesRemaining
    jne big_giant_loop
    rts
.endproc

.proc update_current_radius
    dec target_counter
    bne skip_update_target
    lda #4
    sta target_counter
    lda target_torchlight_radius
    cmp current_torchlight_radius
    beq skip_update_target
    bcc decrease_current
increase_current:
    inc current_torchlight_radius
    jmp skip_update_target
decrease_current:
    dec current_torchlight_radius
skip_update_target:

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
    lda current_lighting_row ; the battlefield starts on row 0 of the nametable, and spans its full width
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
    ldx current_torchlight_radius
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
    ; X = 31 - PlayerCol * 2 - 0
    lda #(31 - 0)
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