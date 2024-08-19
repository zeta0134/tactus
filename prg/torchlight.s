        .macpack longbranch

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "player.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
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

SuppressTorchlight: .res 1

; For keeping track of the rather involved update procedure between rooms
RasterState: .res 2
RasterTopLeftLut: .res 2
RasterTorchlightBank: .res 1
LeadingNametable: .res 2
TrailingNametable: .res 2
CurrentRow: .res 1
CleanupMode: .res 1

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
        sta SuppressTorchlight

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

        lda SuppressTorchlight
        beq safe_to_draw
        rts
safe_to_draw:
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

; Identical to the usual row drawing logic, but only for a single nametable
; Used during Up/Down room transitions
; Safe to call around 15 times per frame. We need 11 per frame. Good!
.proc draw_one_half_torchlight_row
NametablePtr := R0
TorchlightPtr := R2
        perform_zpcm_inc
        ; everything from here should work with any setup of the above
        ldy #0
        .repeat 8 ; (82*8) (656)
        .repeat 4 ; (19*4) (76)
        lda (NametablePtr), y       ; 5
        ; keep everything except old light level
        and #%11111100              ; 2
        ora (TorchlightPtr), y      ; 5
        sta (NametablePtr), y       ; 5
        iny                         ; 2
        .endrepeat
        perform_zpcm_inc            ; 6 (inefficient?)
        .endrepeat

        rts
.endproc

; Similar to the half-row, we're targeting one column of a single nametable
; This is somewhat less efficient than row drawing due to the conflicting
; pointer math, but helped by columns being shorter
.proc draw_one_half_torchlight_column
NametablePtr := R0
TorchlightPtr := R2
        perform_zpcm_inc
        ; everything from here should work with any setup of the above
        ldy #0
        .repeat 11 ; (60*11) (660)
        .repeat 2 ; (27*2) = 54
        lda (NametablePtr), y       ; 5
        ; keep everything except old light level
        and #%11111100              ; 2
        ora (TorchlightPtr), y      ; 5
        sta (NametablePtr), y       ; 5
        add16b NametablePtr, #32    ; 5(bt) (could optimize; we know when overflows happen)
        add16b TorchlightPtr, #64   ; 5(bt) (cannot optimize; can start on any row)
        .endrepeat
        perform_zpcm_inc            ; 6
        .endrepeat

        rts
.endproc

; These show the row/column we are CURRENTLY drawing. It is not safe to draw 
; the trailing edge until the raster effect has moved PAST this value!
safe_col_x_lut:
        .byte  0,  0,  0,  0,  0,  1,  1,  2,  3,  4,  5,  6,  8, 10, 13, 16
        .byte 18, 21, 23, 25, 26, 28, 29, 29, 30, 31, 31, 31, 31, 31, 31, 31
safe_row_y_lut:
        .byte  0,  0,  0,  0,  0,  0,  1,  1,  2,  2,  3,  4,  6,  7,  9, 11
        .byte 12, 14, 16, 17, 18, 19, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21

.proc __torchlight_raster_trampoline
        jmp (RasterState)
.endproc

.proc FAR_reset_torchlight_raster_slide_updater
        st16 RasterState, init_state
        rts
.endproc

.proc FAR_update_torchlight_over_raster_slide_updater
        lda #0
        sta CleanupMode
        jsr __torchlight_raster_trampoline
        rts
.endproc

.proc FAR_catchup_and_finalize_torchlight_raster_slide
catchup_loop:
        lda RasterState+1
        cmp #>finished_state
        bne not_done_yet
        lda RasterState+0
        cmp #<finished_state
        bne not_done_yet
        ; done!
        rts
not_done_yet:
        lda #1 ;  hurry up, will ya?
        sta CleanupMode
        jsr __torchlight_raster_trampoline
        jmp catchup_loop
.endproc

.proc init_state
Scratch := R0
        ; First determine the leading/trailing nametable pointers to start with
        ; (we might tweak these as we go)
        lda active_battlefield
        bne right_nametable_active
left_nametable_active:
        st16 LeadingNametable, $5C00
        st16 TrailingNametable, $5800
        jmp done_with_nametables
right_nametable_active:
        st16 LeadingNametable, $5800
        st16 TrailingNametable, $5C00
done_with_nametables:
        ; Set up the initial lookup table pointer
        ; (which will also change over time)
        ; this is just like the regular function above, except with "current_lighting_row" forced to 0

        ldx current_torchlight_radius
        lda torchlight_luts_low, x
        sta RasterTopLeftLut+0
        lda torchlight_luts_high, x
        sta RasterTopLeftLut+1
        lda torchlight_luts_bank, x
        sta RasterTorchlightBank

        lda #0
        sta Scratch
        ; Y = 19 - PlayerRow * 2
        lda #19
        sec
        sbc PlayerRow ; cannot carry, value ranges from 0-9
        sbc PlayerRow ; also cannot carry
        ; RasterTopLeftLut += Y * 64
        .repeat 6
        asl
        rol Scratch
        .endrepeat
        clc
        adc RasterTopLeftLut+0
        sta RasterTopLeftLut+0
        lda Scratch
        adc RasterTopLeftLut+1
        sta RasterTopLeftLut+1
        ; X = 31 - PlayerCol * 2 - 0
        lda #(31 - 0)
        sec
        sbc PlayerCol
        sbc PlayerCol
        ; RasterTopLeftLut += X
        clc
        adc RasterTopLeftLut+0
        sta RasterTopLeftLut+0
        lda #0
        adc RasterTopLeftLut+1
        sta RasterTopLeftLut+1

        lda #0
        sta CurrentRow

        ; now, based on the player's movement direction, pick a target state
        lda RoomTransitionType
        cmp #ROOM_TRANSITION_SLIDE_RIGHT
        beq setup_slide_right
        cmp #ROOM_TRANSITION_SLIDE_LEFT
        beq setup_slide_left
        cmp #ROOM_TRANSITION_SLIDE_DOWN
        beq setup_slide_down
        cmp #ROOM_TRANSITION_SLIDE_UP
        beq setup_slide_up
        ; ... what? this shouldn't be possible! (oh no)
        st16 RasterState, finished_state
        rts
setup_slide_right:
        st16 RasterState, leading_right_state
        rts
setup_slide_left:
        st16 RasterState, leading_left_state
        rts
setup_slide_up:
        st16 RasterState, leading_up_state
        rts
setup_slide_down:
        st16 RasterState, leading_down_state
        rts
.endproc

; The four leading states just run as fast as they can (as often as we
; can afford to call them) since they start offscren entirely, and we want
; them drawn well before their contents are shown.
.proc leading_right_state
NametablePtr := R0
TorchlightPtr := R2
        ; both the nametable and column pointers are aligned
        ; so we can take advantage of this when setting up the initial pointer
        lda LeadingNametable+1
        sta NametablePtr+1
        lda CurrentRow
        sta NametablePtr+0

        lda RasterTopLeftLut+1
        sta TorchlightPtr+1
        clc
        lda RasterTopLeftLut+0 ; will range from 0-31
        adc CurrentRow ; result ranges from 31-62
        sta TorchlightPtr+0

        access_data_bank RasterTorchlightBank

        jsr draw_one_half_torchlight_column
        inc CurrentRow

        restore_previous_bank

        lda CurrentRow
        cmp #32
        bne done
        lda #0
        sta CurrentRow
        st16 RasterState, trailing_right_state
done:
        rts
.endproc

.proc leading_left_state
NametablePtr := R0
TorchlightPtr := R2
        ; both the nametable and column pointers are aligned
        ; so we can take advantage of this when setting up the initial pointer
        lda LeadingNametable+1
        sta NametablePtr+1
        sec
        lda #31
        sbc CurrentRow
        sta NametablePtr+0

        lda RasterTopLeftLut+1
        sta TorchlightPtr+1
        clc
        lda RasterTopLeftLut+0 ; will range from 0-31
        adc NametablePtr+0 ; result ranges from 31-62
        sta TorchlightPtr+0

        access_data_bank RasterTorchlightBank

        jsr draw_one_half_torchlight_column
        inc CurrentRow

        restore_previous_bank

        lda CurrentRow
        cmp #32
        bne done
        lda #0
        sta CurrentRow
        st16 RasterState, trailing_left_state
done:
        rts
.endproc

.proc leading_up_state
        ; Unimplemented!
        st16 RasterState, finished_state
        rts
.endproc

.proc leading_down_state
        ; Unimplemented!
        st16 RasterState, finished_state
        rts
.endproc

.proc trailing_right_state
NametablePtr := R0
TorchlightPtr := R2
        ; Safety: if we can't draw yet, bail!
        lda CleanupMode
        bne safe_to_draw
        ldx RasterEffectFrame
        lda CurrentRow
        cmp safe_col_x_lut, x
        bcc safe_to_draw
not_safe:
        rts

safe_to_draw:
        ; both the nametable and column pointers are aligned
        ; so we can take advantage of this when setting up the initial pointer
        lda TrailingNametable+1
        sta NametablePtr+1
        lda CurrentRow
        sta NametablePtr+0

        lda RasterTopLeftLut+1
        sta TorchlightPtr+1
        clc
        lda RasterTopLeftLut+0 ; will range from 0-31
        adc CurrentRow ; result ranges from 31-62
        sta TorchlightPtr+0

        access_data_bank RasterTorchlightBank

        jsr draw_one_half_torchlight_column
        inc CurrentRow

        restore_previous_bank

        lda CurrentRow
        cmp #32
        bne done
        st16 RasterState, finished_state
done:
        rts
.endproc

.proc trailing_left_state
NametablePtr := R0
TorchlightPtr := R2
        ; Safety: if we can't draw yet, bail!
        lda CleanupMode
        bne safe_to_draw
        ldx RasterEffectFrame
        lda CurrentRow
        cmp safe_col_x_lut, x
        bcc safe_to_draw
not_safe:
        rts

safe_to_draw:
        ; both the nametable and column pointers are aligned
        ; so we can take advantage of this when setting up the initial pointer
        lda TrailingNametable+1
        sta NametablePtr+1
        sec
        lda #31
        sbc CurrentRow
        sta NametablePtr+0

        lda RasterTopLeftLut+1
        sta TorchlightPtr+1
        clc
        lda RasterTopLeftLut+0 ; will range from 0-31
        adc NametablePtr+0 ; result ranges from 31-62
        sta TorchlightPtr+0

        access_data_bank RasterTorchlightBank

        jsr draw_one_half_torchlight_column
        inc CurrentRow

        restore_previous_bank

        lda CurrentRow
        cmp #32
        bne done
        st16 RasterState, finished_state
done:
        rts
.endproc

.proc trailing_up_state
        ; Unimplemented!
        st16 RasterState, finished_state
        rts
.endproc

.proc trailing_down_state
        ; Unimplemented!
        st16 RasterState, finished_state
        rts
.endproc

.proc finished_state
        ; nothing to do!
        rts
.endproc