        .include "../build/tile_defs.inc"        
        .include "_globals.inc"

        .include "dialog.inc"
        .include "dynamic_palette.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "input.inc"
        .include "nes.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .zeropage
DialogStringCurrentPtr: .res 2
DialogNametablePtr: .res 2
DialogAttrPtr: .res 2

        .segment "PRGRAM"
DialogState: .res 2
DialogHeight: .res 1
DialogOpenClosePos: .res 1
DialogCurrentAttr: .res 1

DialogStringCurrentBank: .res 1
DialogCurrentModeActive: .res 1
DialogCurrentModePassive: .res 1

; For in-game descriptions of pickups. Held open until
; the dismiss event is received, then automatically closes
; on a timer. Player options can tweak this behavior, including
; disabling these kinds of popups entirely.
DialogInitiatePassiveMode: .res 1
DialogDismissPassiveMode: .res 1
DialogPassiveStringPtr: .res 2
DialogPassiveStringBank: .res 1

; For NPCs, signs, and other in-game activations. Advanced by
; game logic. Can (usually) be dismissed early, which closes
; the dialog immediately without processing (or displaying)
; the remainder of its text.
DialogInitiateActiveMode: .res 1
DialogDismissActiveMode: .res 1
DialogActiveStringPtr: .res 2
DialogActiveStringBank: .res 1

DialogChirpTimer: .res 1

TimerActive: .res 1
TimerIndex: .res 1
TimerDelay: .res 1

        .segment "TEXT_STRINGS"

hello_dialog:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL), "DIALOG TEST", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL), "Hello World!", D_WAIT, D_CLEAR
        .byte "This dialog box has", D_NEWLINE
        .byte "multiple pages of text.", D_WAIT, D_CLOSE

        .segment "CODE_0"

DIALOG_EASING_LENGTH = 12
dialog_easing_lut:
        .byte 0,10,17,23,27,29,30,31,30,30,29,28

DIALOG_ADVANCE_INDICATOR = $E0
DIALOG_CLOSE_INDICATOR = $E1
DIALOG_BOTTOM_BORDER = $E2
DIALOG_WAIT_INDICATOR_LENGTH = 17
DIALOG_WAIT_COOLDOWN = 8

DIALOG_WAIT_INDICATOR_OFFSET = 30

DIALOG_CHIRP_COOLDOWN = 5

dialog_wait_indicator_lut:
        .byte $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
        .byte $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
        .byte $EF

.proc init_dialog
        lda #0
        sta DialogHeight
        sta DialogChirpTimer
        st16 DialogState, state_init_dialog
        rts
.endproc

.proc update_dialog
        jmp (DialogState)
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
        ; clear the first 3 rows to actually blank
        ldy #0
text_loop:
        perform_zpcm_inc
        lda #FONT_BANK
        sta DIALOG_ATTRIBUTE_BASE, y
        lda #0
        sta DIALOG_NAMETABLE_BASE, y
        iny
        cpy #96
        bne text_loop
border_loop:
        perform_zpcm_inc
        lda #(FONT_BANK | HUD_TEXT_PAL)
        sta DIALOG_ATTRIBUTE_BASE, y
        lda #DIALOG_BOTTOM_BORDER
        sta DIALOG_NAMETABLE_BASE, y
        iny
        cpy #128
        bne border_loop
        rts
.endproc

.proc state_wait_for_activation
        ; Now the separator has real brightness, so we can just write a colorspace
        ; to it directly
        lda #$00
        sta HudSeparatorPal+0
        sta HudSeparatorPal+1
        sta HudSeparatorPal+2
        sta StagingHudPaletteDirty

        perform_zpcm_inc

check_for_active:
        lda DialogInitiateActiveMode
        beq check_for_passive

        ; Consume the request to enter active mode
        lda #0
        sta DialogInitiateActiveMode
        lda #1
        sta DialogCurrentModeActive
        lda #0
        sta DialogCurrentModePassive
        ; don't dismiss the thing we're just activating on the same frame!
        lda #0
        sta DialogDismissActiveMode 
        ; Copy the string properties to set up the draw
        lda DialogActiveStringPtr+0
        sta DialogStringCurrentPtr+0
        lda DialogActiveStringPtr+1
        sta DialogStringCurrentPtr+1
        lda DialogActiveStringBank
        sta DialogStringCurrentBank
        ; Clear out the dialog in prep for the opening animation
        jsr clear_entire_dialog_area
        ; Now switch our mode into the opening animation
        lda #0
        sta DialogOpenClosePos
        ; Play an opening sfx, as this is an "interaction" with some in-game object
        queue_sfx_pulse2 sfx_dialog_advance

        st16 DialogState, state_open_dialog_animation
        perform_zpcm_inc
        rts

check_for_passive:
        lda DialogInitiatePassiveMode
        beq done

        ; Consume the request to enter passove mode
        lda #0
        sta DialogInitiatePassiveMode
        lda #1
        sta DialogCurrentModePassive
        lda #0
        sta DialogCurrentModeActive
        lda #0
        ; don't dismiss the thing we're just activating on the same frame!
        lda #0
        sta DialogDismissPassiveMode
        ; Copy the string properties to set up the draw
        lda DialogPassiveStringPtr+0
        sta DialogStringCurrentPtr+0
        lda DialogPassiveStringPtr+1
        sta DialogStringCurrentPtr+1
        lda DialogPassiveStringBank
        sta DialogStringCurrentBank
        ; Clear out the dialog in prep for the opening animation
        jsr clear_entire_dialog_area
        ; Initialize some extra state for passive mode
        lda #0
        sta TimerActive
        ; Now switch our mode into the opening animation
        lda #0
        sta DialogOpenClosePos
        st16 DialogState, state_open_dialog_animation
        perform_zpcm_inc
        rts

done:
        perform_zpcm_inc
        rts
.endproc

.proc state_open_dialog_animation
        lda #0
        sta DialogChirpTimer

        ; Now the separator has real brightness, so we can just write a colorspace
        ; to it directly
        lda #$00
        sta HudSeparatorPal+0
        sta HudSeparatorPal+2
        lda #$10
        sta HudSeparatorPal+1
        sta StagingHudPaletteDirty

        inc DialogOpenClosePos
        ldx DialogOpenClosePos
        lda dialog_easing_lut, x
        sta DialogHeight
        cpx #(DIALOG_EASING_LENGTH-1)
        bne continue_opening
        ; TODO: whatever mode was requested
        st16 DialogState, state_init_text_display
continue_opening:
        perform_zpcm_inc
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
        perform_zpcm_inc
        rts
.endproc

.proc state_init_text_display
        st16 DialogNametablePtr, (DIALOG_NAMETABLE_BASE+2)
        st16 DialogAttrPtr, (DIALOG_ATTRIBUTE_BASE+2)

        st16 DialogState, state_run_text_display
        perform_zpcm_inc
        rts
.endproc

.proc __cmd_trampoline
CommandPtr := R0
        jmp (CommandPtr)
.endproc

.proc state_run_text_display
        ; early-out: if an activation for passive mode arrives
        ; and we are currently in passive mode,
        ; bail right away!
        lda DialogCurrentModePassive
        beq no_bail
        lda DialogInitiatePassiveMode
        beq no_bail

        st16 DialogState, state_wait_for_activation
        perform_zpcm_inc
        rts

no_bail:
        access_data_bank DialogStringCurrentBank

        ; TODO: wait time between characters?

        ; For now: double speed!
        jsr process_one_character
        jsr process_one_character
        
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc process_one_character
CommandPtr := R0
        ldy #0
        lda (DialogStringCurrentPtr), y
        bpl draw_single_character
        asl
        tax
        lda dialog_command_lut+0, x
        sta CommandPtr+0
        lda dialog_command_lut+1, x
        sta CommandPtr+1
        jsr __cmd_trampoline
        rts
draw_single_character:
        perform_zpcm_inc
        sta (DialogNametablePtr), y
        cmp #' '
        beq no_chirp
        jsr dialog_play_chirp
no_chirp:
        ldy #0
        lda DialogCurrentAttr ; TODO: commands to set text color/font?
        sta (DialogAttrPtr), y
        inc16 DialogNametablePtr
        inc16 DialogAttrPtr
        ; onward!
        inc16 DialogStringCurrentPtr
        perform_zpcm_inc
        rts
.endproc

dialog_command_lut:
        .word dialog_cmd_newline; D_NEWLINE = $80
        .word dialog_cmd_wait  ; D_WAIT    = $81
        .word dialog_cmd_clear ; D_CLEAR   = $82
        .word dialog_cmd_close ; D_CLOSE   = $83
        .word dialog_cmd_attr  ; D_ATTR    = $84
        ; TODO: safety? bah!

.proc dialog_cmd_newline
        perform_zpcm_inc
        ; clear out the low 5 bits to reset to 0, then add 32, then add 2
        lda DialogNametablePtr+0
        and #%11100000
        clc
        adc #34
        sta DialogNametablePtr+0
        ; that might have carried
        lda DialogNametablePtr+1
        adc #0
        sta DialogNametablePtr+1

        ; Same deal for the attribute pointer
        lda DialogAttrPtr+0
        and #%11100000
        clc
        adc #34
        sta DialogAttrPtr+0
        ; that might have carried
        lda DialogAttrPtr+1
        adc #0
        sta DialogAttrPtr+1

        ; onward
        inc16 DialogStringCurrentPtr
        perform_zpcm_inc
        rts
.endproc

.proc dialog_cmd_clear
        perform_zpcm_inc
        ; oh, this is probably overkill. we might need to not do this
        ; once we are drawing borders, etc?
        jsr clear_entire_dialog_area
        st16 DialogNametablePtr, (DIALOG_NAMETABLE_BASE+2)
        st16 DialogAttrPtr, (DIALOG_ATTRIBUTE_BASE+2)
        ; onward
        inc16 DialogStringCurrentPtr
        perform_zpcm_inc
        rts
.endproc

.proc dialog_cmd_wait
        perform_zpcm_inc
        lda #0
        sta DialogChirpTimer

perform_active_mode_checks:
        lda DialogCurrentModeActive
        beq perform_passive_mode_checks

        ; TODO: what if the underlying string changes?

        ; if the player has "initiated" the mode again, advance!
        lda DialogInitiateActiveMode
        beq no_active_advance
        lda #0
        sta DialogInitiateActiveMode ; consume the flag

        ; peek ahead: is this a close?
        ldy #1
        lda (DialogStringCurrentPtr), y
        cmp #D_CLOSE
        bne play_advance_sfx
play_close_sfx:
        queue_sfx_pulse2 sfx_dialog_close
        jmp advance
play_advance_sfx:
        queue_sfx_pulse2 sfx_dialog_advance
        jmp advance
no_active_advance:

        ; if the player has "dismissed" the mode, cancel!
        lda DialogDismissActiveMode
        beq no_active_dismiss
        lda #0
        sta DialogDismissActiveMode ; consume the flag
        queue_sfx_pulse2 sfx_dialog_close
        jmp close_early
no_active_dismiss:
        jmp active_waiting

perform_passive_mode_checks:

        ; If another activation has come in (the player may have moved onto a second item
        ; while the first is still displayed), cancel immediately. (don't consume the flag though!)
        lda DialogInitiatePassiveMode
        beq no_passive_cancel
        jmp close_instantly
no_passive_cancel:

        ; if the player has "dismissed" the mode, start the timer!
        lda DialogDismissPassiveMode
        beq no_passive_dismiss
        lda #0
        sta DialogDismissPassiveMode ; consume the flag
        jmp start_timer
no_passive_dismiss:
        jmp passive_waiting

advance:
        ; Clear the waiting icon
        lda #0
        ldy #0
        sta (DialogNametablePtr), y

        ; Conditionally, onward!
        inc16 DialogStringCurrentPtr
        rts

close_early:
        ; immediately execute a close dialog command
        jsr dialog_cmd_close
        ; This will cease all remaining dialog processing on its own.
        rts

close_instantly:
        ; immediately revert to the *opening* state. right now! do not delay!
        st16 DialogState, state_wait_for_activation
        rts

active_waiting:
        ; Draw the waiting icon!
        ; First, check to see if the next byte is close, so we can pick the right one
        ldy #1
        lda (DialogStringCurrentPtr), y
        cmp #D_CLOSE
        beq close_indicator
advance_indicator:
        lda #DIALOG_ADVANCE_INDICATOR
        ldy #0
        sta (DialogNametablePtr), y
        lda #FONT_BANK | HUD_PURPLE_PAL
        sta (DialogAttrPtr), y
        jmp done_with_indicator
close_indicator:
        lda #DIALOG_CLOSE_INDICATOR
        ldy #0
        sta (DialogNametablePtr), y
        lda #FONT_BANK | HUD_PURPLE_PAL
        ldy #0
        sta (DialogAttrPtr), y
done_with_indicator:
        rts

passive_waiting:
        lda TimerActive
        bne run_timer
        ; do absolutely nothing!
        rts
run_timer:
        ; Draw the timer!
        ldx TimerIndex
        lda dialog_wait_indicator_lut, x
        ldy #0
        sta DIALOG_NAMETABLE_BASE + DIALOG_WAIT_INDICATOR_OFFSET
        lda #FONT_BANK | HUD_PURPLE_PAL
        sta DIALOG_ATTRIBUTE_BASE + DIALOG_WAIT_INDICATOR_OFFSET
        ; Advance the timer!
        lda TimerDelay
        beq clock_timer
        dec TimerDelay
        rts
clock_timer:
        lda #DIALOG_WAIT_COOLDOWN
        sta TimerDelay
        inc TimerIndex
        lda TimerIndex
        cmp #DIALOG_WAIT_INDICATOR_LENGTH
        bne done_with_timer
        ; The timer has expired! Advance!
        lda #0
        sta TimerActive
        jmp advance
done_with_timer:
        rts

start_timer:
        ; if the timer is already active, don't start it again!
        lda TimerActive
        bne run_timer

        lda #0
        sta TimerIndex
        lda #1
        sta TimerActive
        lda #DIALOG_WAIT_COOLDOWN
        sta TimerDelay
        rts
.endproc

.proc dialog_cmd_close
        perform_zpcm_inc
        st16 DialogState, state_close_dialog_animation
        ; Do not advance, there is no more data to process.
        ; If we somehow process this command again, we might softlock the dialog system,
        ; but we won't crash the rest of the game. Good enough?
        rts
.endproc

.proc dialog_cmd_attr
        ; onward!
        inc16 DialogStringCurrentPtr
        ; read and apply
        ldy #0
        lda (DialogStringCurrentPtr), y
        sta DialogCurrentAttr
        ; onward properly!
        inc16 DialogStringCurrentPtr
        perform_zpcm_inc
        rts
.endproc

chirps_lut:
        .word sfx_dialog_text_variant_1
        .word sfx_dialog_text_variant_2
        .word sfx_dialog_text_variant_3
        .word sfx_dialog_text_variant_1
        .word sfx_dialog_text_variant_2
        .word sfx_dialog_text_variant_3
        .word sfx_dialog_text_variant_1
        .word sfx_dialog_text_variant_2
        .word sfx_dialog_text_variant_3
        .word sfx_dialog_text_variant_1
        .word sfx_dialog_text_variant_2
        .word sfx_dialog_text_variant_3
        .word sfx_dialog_text_variant_1
        .word sfx_dialog_text_variant_2
        .word sfx_dialog_text_variant_3

.proc dialog_play_chirp
SfxPtr := R0
        ; if we're not in active mode, don't chirp at all
        ; (for passive dialog it interferes with coin collection)
        lda DialogCurrentModeActive
        beq no_chirp

        lda DialogChirpTimer
        beq play_chirp
        dec DialogChirpTimer
no_chirp:
        rts
play_chirp:
        lda #DIALOG_CHIRP_COOLDOWN
        sta DialogChirpTimer

        in_range_smol next_gameplay_rand, #15
        asl
        tax
        lda chirps_lut+0, x
        sta SfxPtr+0
        lda chirps_lut+1, x
        sta SfxPtr+1
        queue_sfx_pulse1_ptr SfxPtr

        perform_zpcm_inc
        rts
.endproc