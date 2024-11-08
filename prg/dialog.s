        .include "dialog.inc"

        .include "../build/tile_defs.inc"
        
        .include "_globals.inc"

        .include "far_call.inc"
        .include "input.inc"
        .include "nes.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "PRGRAM"

DialogState: .res 2
DialogHeight: .res 1
DialogOpenClosePos: .res 1

        .segment "CODE_0"

FONT_BANK = CHR_BANK_FONT_MARSHMALLOW
DIALOG_NAMETABLE_BASE = $56C0
DIALOG_ATTRIBUTE_BASE = $5EC0

DIALOG_EASING_LENGTH = 16
dialog_easing_lut:
    .byte 0,9,16,22,26,30,32,34,35,35,35,35,34,33,33,32

.proc init_dialog
        lda #0
        sta DialogHeight
        st16 DialogState, state_init_dialog
        rts
.endproc

.proc update_dialog
        jmp (DialogState)
        rts
.endproc

.proc state_init_dialog
        jsr clear_entire_dialog_area
        st16 DialogState, state_wait_for_activation
        rts
.endproc

; run once during initial init, this will
; ensure the entire text area is clear of artifacts
; from other non-gameplay modes
.proc clear_entire_dialog_area
        ; the bottom 8 rows of this nametable are ours to play with.
        ; we don't need all of these, but initialize them all anyway
        ldy #0
loop:
        lda #FONT_BANK
        sta DIALOG_ATTRIBUTE_BASE, y
        lda #'-' ; for great testing
        sta DIALOG_NAMETABLE_BASE, y
        iny
        bne loop
        rts
.endproc

.proc state_wait_for_activation
        ; For now, a very simple hack to force the dialog box open
check_a_button:
        lda #(KEY_A)
        bit ButtonsDown
        beq done
        lda #0
        sta DialogOpenClosePos
        st16 DialogState, state_open_dialog_animation
done:
        rts
.endproc

.proc state_open_dialog_animation
        inc DialogOpenClosePos
        ldx DialogOpenClosePos
        lda dialog_easing_lut, x
        sta DialogHeight
        cpx #(DIALOG_EASING_LENGTH-1)
        bne continue_opening
        ; TODO: whatever mode was requested
        st16 DialogState, state_wait_for_deactivation
continue_opening:
        rts
.endproc

.proc state_wait_for_deactivation
        ; For now, a very simple hack to force the dialog box closed again
check_b_button:
        lda #(KEY_B)
        bit ButtonsDown
        beq done
        lda #(DIALOG_EASING_LENGTH-1)
        sta DialogOpenClosePos
        st16 DialogState, state_close_dialog_animation
done:
        rts
.endproc

.proc state_close_dialog_animation
        dec DialogOpenClosePos
        ldx DialogOpenClosePos
        lda dialog_easing_lut, x
        sta DialogHeight
        cpx #0
        bne continue_closing
        ; TODO: whatever mode was requested
        st16 DialogState, state_wait_for_activation
continue_closing:
        rts
.endproc