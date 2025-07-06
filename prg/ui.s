        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "chr.inc"
        .include "dialog.inc"
        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "hud.inc"
        .include "input.inc"
        .include "levels.inc"
        .include "localized_text.inc"
        .include "localization_defines.inc"
        .include "main.inc"
        .include "math_util.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "saves.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "slowam.inc"
        .include "sprites.inc"
        .include "text_util.inc"
        .include "ui.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "PRGRAM"

MAX_WIDGETS = 24 ; just how many do we need!? (more than expected!)

; This is sortof like a baby finite state machine with extra
; UI information dangling off the side, mostly to help the
; cursor to move around sanely and skip over inactive bits

widgets_onupdate_low: .res ::MAX_WIDGETS
widgets_onupdate_high: .res ::MAX_WIDGETS
widgets_onupdate_bank: .res ::MAX_WIDGETS
widgets_cursor_pos_x: .res ::MAX_WIDGETS
widgets_cursor_pos_y: .res ::MAX_WIDGETS
widgets_state_flags: .res ::MAX_WIDGETS
; miscellaneous storage per widget
widgets_data0: .res ::MAX_WIDGETS
widgets_data1: .res ::MAX_WIDGETS
widgets_data2: .res ::MAX_WIDGETS
widgets_data3: .res ::MAX_WIDGETS
widgets_data4: .res ::MAX_WIDGETS
widgets_data5: .res ::MAX_WIDGETS
widgets_data6: .res ::MAX_WIDGETS
widgets_data7: .res ::MAX_WIDGETS
; not part of the widget definition, can be used as scratch space
widgets_data8: .res ::MAX_WIDGETS
;widgets_data9: .res ::MAX_WIDGETS
;widgets_data10: .res ::MAX_WIDGETS

; used to detect beat transitions, used for a few polish-y
; beat counting effects
LastBeat: .res 1

SubLayoutRequested: .res 1
SubLayoutPtr: .res 2
SubLayoutIndex: .res 1

; String processing, it turns out, needs lots of scratch space
UiStringScratch: .res 14


        .segment "DATA_UI_LAYOUTS"
ui_data_bank:

; some common strings and utilities shared by many layouts
empty_string: .asciiz ""

        ; Also sortof our "default UI code" for the moment
        .segment "CODE_UI_WIDGETS_0"

        .include "ui/widgets/cursors.incs"
        .include "ui/widgets/file_select_box.incs"
        .include "ui/widgets/numeric_slider.incs"
        .include "ui/widgets/numeric_viewer.incs"
        .include "ui/widgets/string_entry.incs"
        .include "ui/widgets/tab_bar.incs"
        .include "ui/widgets/text_label.incs"
        .include "ui/widgets/text_options.incs"
        .include "ui/widgets/text_button.incs"
        .include "ui/widgets/run_time_viewer.incs"
        .include "ui/widgets/step_count_viewer.incs"
        .include "ui/widgets/gold_earned_viewer.incs"
        .include "ui/widgets/short_floor_name_viewer.incs"
        .include "ui/widgets/equipment_inspector.incs"

        .include "ui/title_screen.incs"
        .include "ui/options_screen.incs"
        .include "ui/file_select_screen.incs"
        .include "ui/game_over_screen.incs"
        .include "ui/name_entry_screen.incs"
        .include "ui/file_details_screen.incs"

        .segment "CODE_UI_UTIL"

; ======================================================================
;                         Kernel Functions
;       (called at regular intervals to drive the UI subsystems)
; ======================================================================

; Call this with the pointer to a list of widgets in R0
; Each entry in the list is just a pointer to an init function,
; the widget code is expected to handle all of its own setup as
; required. The list is $FFFF terminated
.proc FAR_initialize_widgets
WidgetListPtr := R0
PtrStash := R2
        access_data_bank #<.bank(ui_data_bank)

        ; Perform initial basic state setup
        lda #0
        sta SubLayoutRequested

        perform_zpcm_inc
        ; firstly, for sanity, completely zero out all of widget memory
        ; absolutely no holding onto previous state from other runs
        lda #0
        ldy #0
memclr_loop:
        perform_zpcm_inc
        sta widgets_onupdate_low, y
        sta widgets_onupdate_high, y
        sta widgets_onupdate_bank, y
        sta widgets_cursor_pos_x, y
        sta widgets_cursor_pos_y, y
        sta widgets_state_flags, y
        sta widgets_data0, y
        sta widgets_data1, y
        sta widgets_data2, y
        sta widgets_data3, y
        sta widgets_data4, y
        sta widgets_data5, y
        sta widgets_data6, y
        sta widgets_data7, y
        iny
        cpy #::MAX_WIDGETS
        bne memclr_loop

        ; Now, until we hit a $0000 entry or run out of space, 
        ; continue to initialize widgets
        ldx #0 ; current widget index
        ldy #0 ; list index
widget_loop:
        perform_zpcm_inc
        lda (WidgetListPtr), y
        sta PtrStash+0
        iny
        lda (WidgetListPtr), y
        sta PtrStash+1
        iny
        ; sanity: are both of our pointer bytes $00? if so, exit!
        ora PtrStash+0
        beq done
        ; write the read pointer into the widget struct
        lda PtrStash+0
        sta widgets_onupdate_low, x
        lda PtrStash+1
        sta widgets_onupdate_high, x
        ; Copy the routine's bank into place, we'll use this during dispatch
        lda (WidgetListPtr), y
        sta widgets_onupdate_bank, x
        iny
        ; copy the next 8 bytes we find into the widget starting data
        ; (this is how reusable widgets specify things like their position,
        ; strings of text, etc)
        lda (WidgetListPtr), y
        sta widgets_data0, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data1, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data2, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data3, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data4, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data5, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data6, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data7, x
        iny

        ; advance!
        inx
        cpx #::MAX_WIDGETS
        beq done
        jmp widget_loop
done:
        perform_zpcm_inc
        restore_previous_bank
        rts
.endproc

; When calling this, prepopulate the SubLayoutPtr
; and SubLayoutIndex. This flags all sublayout widgets
; for the update and manages the state switch. Note
; that the requesting widget should be EARLIER in the
; set. Generally manage this with a controller, rather
; than some widget that will be replaced when the switch
; happens.
.proc FAR_request_sublayout
WidgetIndex := R0
        ldx SubLayoutIndex
cleanup_flag_loop:
        perform_zpcm_inc
        lda widgets_state_flags, x
        ora #WIDGET_STATE_CLEANUP_REQUESTED
        sta widgets_state_flags, x
        inx
        cpx #::MAX_WIDGETS
        bne cleanup_flag_loop

        lda #1
        sta SubLayoutRequested
        
        perform_zpcm_inc
        rts
.endproc

; Just like regular init, except we start at some index other than 0
; to preserve the earlier widgets. By this point, any widgets we are
; going to replace have had a chance to run their cleanup routine
; one time.
.proc FAR_initialize_sublayout
WidgetListPtr := R0
PtrStash := R2
        access_data_bank #<.bank(ui_data_bank)
        perform_zpcm_inc

        ; first clear out all of the widgets we are about to load
        lda #0
        ldy SubLayoutIndex
memclr_loop:
        perform_zpcm_inc
        sta widgets_onupdate_low, y
        sta widgets_onupdate_high, y
        sta widgets_onupdate_bank, y
        sta widgets_cursor_pos_x, y
        sta widgets_cursor_pos_y, y
        sta widgets_state_flags, y
        sta widgets_data0, y
        sta widgets_data1, y
        sta widgets_data2, y
        sta widgets_data3, y
        sta widgets_data4, y
        sta widgets_data5, y
        sta widgets_data6, y
        sta widgets_data7, y
        iny
        cpy #::MAX_WIDGETS
        bne memclr_loop

        ; and now load in the new widgets:

        lda SubLayoutPtr+0
        sta WidgetListPtr+0
        lda SubLayoutPtr+1
        sta WidgetListPtr+1

        ; Now, until we hit a $0000 entry or run out of space, 
        ; continue to initialize widgets
        ldx SubLayoutIndex ; current widget index
        ldy #0             ; list index
widget_loop:
        perform_zpcm_inc
        lda (WidgetListPtr), y
        sta PtrStash+0
        iny
        lda (WidgetListPtr), y
        sta PtrStash+1
        iny
        ; sanity: are both of our pointer bytes $00? if so, exit!
        ora PtrStash+0
        beq done
        ; write the read pointer into the widget struct
        lda PtrStash+0
        sta widgets_onupdate_low, x
        lda PtrStash+1
        sta widgets_onupdate_high, x
        ; Copy the routine's bank into place, we'll use this during dispatch
        lda (WidgetListPtr), y
        sta widgets_onupdate_bank, x
        iny
        ; copy the next 8 bytes we find into the widget starting data
        ; (this is how reusable widgets specify things like their position,
        ; strings of text, etc)
        lda (WidgetListPtr), y
        sta widgets_data0, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data1, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data2, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data3, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data4, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data5, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data6, x
        iny
        lda (WidgetListPtr), y
        sta widgets_data7, x
        iny

        ; advance!
        inx
        cpx #::MAX_WIDGETS
        beq done
        jmp widget_loop
done:
        perform_zpcm_inc
        restore_previous_bank
        rts
.endproc

.segment "CODE_UI_WIDGETS_0"

;.proc __widget_trampoline
;WidgetUpdatePtr := R18
;        jmp (WidgetUpdatePtr)
;        ; rts (implied)
;.endproc

.proc FAR_update_widgets
; put our own variables near the end of scratch, so 
; widget logic can use the low end without conflict
CurrentWidgetIndex := R20
        access_data_bank #<.bank(ui_data_bank)

        lda SubLayoutRequested
        beq no_sublayout_requested
        far_call FAR_initialize_sublayout
        lda #0
        sta SubLayoutRequested
no_sublayout_requested:

        lda #0
        sta CurrentWidgetIndex
loop:
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widgets_onupdate_high, y
        ; if the high byte is 0, this widget doesn't exist
        ; (widget code really shouldn't live in zeropage)
        beq widget_inactive

        ; at this point, do a manual far call. (don't worry
        ; about A, we don't care)
        ; this allows our widgets to be bank switched safely
        sta JumpTarget+1
        lda widgets_onupdate_low, y
        sta JumpTarget+0
        lda widgets_onupdate_bank, y
        sta TargetBank
        jsr launch_far_call

        ;sta WidgetUpdatePtr+1
        ;lda widgets_onupdate_low, y
        ;sta WidgetUpdatePtr+0
        ;jsr __widget_trampoline


widget_inactive:
        inc CurrentWidgetIndex
        lda CurrentWidgetIndex
        cmp #::MAX_WIDGETS
        beq done
        jmp loop
done:

        restore_previous_bank
        rts
.endproc

; ======================================================================
; Utility functions common to many widgets, various odds and ends, etc
; ======================================================================

; Teleports to various game modes, including other UI subscreens
.proc FAR_go_to_file_select
        queue_sfx_pulse2 sfx_teleport

        st16 FadeToGameMode, file_select_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_go_to_options
        queue_sfx_pulse2 sfx_teleport

        st16 FadeToGameMode, options_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_go_to_gameplay
        queue_sfx_pulse2 sfx_teleport

        st16 FadeToGameMode, game_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_go_to_name_entry
        queue_sfx_pulse2 sfx_teleport

        st16 FadeToGameMode, name_entry_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_go_to_file_details
        queue_sfx_pulse2 sfx_teleport

        st16 FadeToGameMode, file_details_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_return_to_title
        queue_sfx_pulse1 sfx_teleport

        st16 FadeToGameMode, title_prep
        st16 GameMode, fade_to_game_mode_from_ui
        rts
.endproc

.proc FAR_widget_no_behavior
        ; exactly that. used by all static elements that are done with initial setup
        ; (we don't clean these up because we might need other widgets to manipulate
        ; their state, and we also aren't performance bound at all)
        rts
.endproc

; Used by UI screens, often WIP, which don't have a default
; actual nametable to load. Just fill everything with space
; tiles. Clobbers R0-R5
.proc FAR_draw_blank_nametable
NametableAddr := R0
AttributeAddr := R2
Length := R4
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        st16 Length, $0400
        ldy #0
loop:
        perform_zpcm_inc
        lda #' '
        sta (NametableAddr), y
        lda #CHR_BANK_0_FONT_MARSHMALLOW
        sta (AttributeAddr), y
        inc16 NametableAddr
        inc16 AttributeAddr
        dec16 Length
        lda Length+0
        ora Length+1
        bne loop
        perform_zpcm_inc
        rts
.endproc

; Several of these are no-ops because they make no sense in a UI context,
; mostly the commands for manipulating the dialog subsystem. We'll reuse
; D_CLOSE as end-of-string, since we don't want to forbid 0 bytes for 
; all glyph sets. (this means we'll eventually phase out the idea of
; null-terminated strings altogether.)

draw_string_cmd_table:
        .word str_cmd_newline     ; D_NEWLINE     = $80
        .word str_cmd_dummy       ; D_WAIT        = $81
        .word str_cmd_dummy       ; D_CLEAR       = $82
        .word str_cmd_dummy       ; D_CLOSE       = $83 (processed manually)
        .word str_cmd_attr        ; D_ATTR        = $84
        .word str_cmd_localize    ; D_LOCALIZE    = $85
        .word str_cmd_return      ; D_RETURN      = $86
        .word str_cmd_ext_char    ; D_LOW_CHAR    = $87
        .word str_cmd_low_page    ; D_LOW_PAGE    = $88
        .word str_cmd_high_page   ; D_HI_PAGE     = $89
        .word str_cmd_pal         ; D_PAL         = $8A
        .word str_cmd_font        ; D_FONT        = $8B
        .word str_cmd_player_name ; D_PLAYER_NAME = $8C
        ; TODO: safety? bah!

.proc _str_cmd_trampoline
CommandPtr := UiStringScratch+0
        jmp (CommandPtr)
.endproc

.proc FAR_draw_ui_string
NametableAddr := T0
AttributeAddr := T2
StringPtr     := T4

CommandPtr := UiStringScratch+0
CurrentPage := UiStringScratch+2
CurrentAttr := UiStringScratch+3
LocalizePreservePtr := UiStringScratch+4
LocalizePreserveBank := UiStringScratch+6

LineStartTileAddr := UiStringScratch+8
LineStartAttrAddr := UiStringScratch+10

        ; Default our font and color to something sensible
        lda #(FONT_ASCII | UI_STRING_PAL_WHITE)
        sta CurrentAttr
attribute_set_converge:

        lda #0
        sta CurrentPage

        ; Preserve our starting position; this is useful
        ; primarily for newline processing
        mov16 LineStartTileAddr, NametableAddr
        mov16 LineStartAttrAddr, AttributeAddr

loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        bmi process_command
process_single_character:
        ora CurrentPage
        sta (NametableAddr), y
        lda CurrentAttr        
        sta (AttributeAddr), y
        inc16 NametableAddr
        inc16 AttributeAddr
        inc16 StringPtr
        jmp loop
process_command:
        perform_zpcm_inc
        cmp #D_CLOSE
        beq end_of_string
        asl
        tax
        lda draw_string_cmd_table+0, x
        sta CommandPtr+0
        lda draw_string_cmd_table+1, x
        sta CommandPtr+1
        jsr _str_cmd_trampoline ; which will inc16 as needed
        jmp loop
end_of_string:
        perform_zpcm_inc
        rts        
.endproc

; For the few times when we need to default the color
; to something other than MM+White, programmatically, use this!
.proc FAR_draw_colored_ui_string
PaletteIndex := T7
CurrentAttr := UiStringScratch+3
        lda PaletteIndex
        ; We still default to ascii as the font, since localized
        ; strings expect this and will break otherwise.
        and #%11000001
        ora #FONT_ASCII
        sta CurrentAttr

        jmp FAR_draw_ui_string::attribute_set_converge
.endproc

; NOTE: All string processing commands may assume that Y=0 on entry.
; It is not required to preserve Y beyond this.

.proc str_cmd_dummy
StringPtr := T4
        ; dummied out, this makes no sense for a UI string
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_newline
NametableAddr := T0
AttributeAddr := T2
StringPtr     := T4

LineStartTileAddr := UiStringScratch+8
LineStartAttrAddr := UiStringScratch+10
        ; Return to the start of the current line, then add 32 (one row) to that
        add16b LineStartTileAddr, #32
        add16b LineStartAttrAddr, #32
        mov16 NametableAddr, LineStartTileAddr
        mov16 AttributeAddr, LineStartAttrAddr
        ; onward!
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_attr
StringPtr := T4
CurrentAttr := UiStringScratch+3
        ; onward!
        inc16 StringPtr
        ; read and apply
        lda (StringPtr), y
        sta CurrentAttr
        ; onward properly!
        inc16 StringPtr
        perform_zpcm_inc
        rts
.endproc

.proc str_cmd_localize
StringPtr := T4
NewStrTablePtr  := T6
LocalizePreservePtr := UiStringScratch+4
LocalizePreserveBank := UiStringScratch+6
NewStrTableBank := UiStringScratch+7

        ; onward!
        inc16 StringPtr

        ; Read the target string and bank, incrementing as we go
        lda (StringPtr), y
        sta NewStrTablePtr+0
        inc16 StringPtr

        lda (StringPtr), y
        sta NewStrTablePtr+1
        inc16 StringPtr

        lda (StringPtr), y
        sta NewStrTableBank
        inc16 StringPtr

        ; Preserve the current dialog state into our temporaries
        lda StringPtr+0
        sta LocalizePreservePtr+0
        lda StringPtr+1
        sta LocalizePreservePtr+1
        lda CurrentDataBankLow
        sta LocalizePreserveBank

        ; Store and activate the new bank
        restore_previous_bank
        access_data_bank NewStrTableBank

        ; Use the table to read the string pointer out of the
        ; target bank (constraint: which shares the bank with the actual
        ; data, this in theory shouldn't be an issue ever)
        lda current_block + SaveBlock::GlobalOptionLanguage
        asl
        tay
        lda (NewStrTablePtr), y
        sta StringPtr+0
        iny
        lda (NewStrTablePtr), y
        sta StringPtr+1

        ; And... we're done?
        rts
.endproc

.proc str_cmd_return
StringPtr := T4
LocalizePreservePtr := UiStringScratch+4
LocalizePreserveBank := UiStringScratch+6
        ; Okay, return to our position in the original string.
        ; Should be straightforward.

        lda LocalizePreservePtr+0
        sta StringPtr+0
        lda LocalizePreservePtr+1
        sta StringPtr+1

        ; Switch to the new bank, and we're done
        restore_previous_bank
        access_data_bank LocalizePreserveBank

        rts
.endproc

.proc str_cmd_ext_char
NametableAddr := T0
AttributeAddr := T2
StringPtr := T4
CurrentAttr := UiStringScratch+3
        ; onward!
        inc16 StringPtr
        lda (StringPtr), y
        sta (NametableAddr), y
        lda CurrentAttr
        sta (AttributeAddr), y
        inc16 NametableAddr
        inc16 AttributeAddr
        ; onward!
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_low_page
StringPtr := T4
CurrentPage := UiStringScratch+2
        ; Switch to the low page and stay there. Simple!
        lda #0
        sta CurrentPage
        ; onward!
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_high_page
StringPtr := T4
CurrentPage := UiStringScratch+2
        ; Switch to the high page and stay there. Simple!
        lda #$80
        sta CurrentPage
        ; onward!
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_pal
StringPtr := T4
CurrentAttr := UiStringScratch+3
Scratch := UiStringScratch+7
        ; onward!
        inc16 StringPtr
        ; read and apply
        ldy #0
        lda (StringPtr), y
        and #%11000001
        sta Scratch
        lda CurrentAttr
        and #%00111110
        ora Scratch
        sta CurrentAttr
        ; onward properly!
        inc16 StringPtr
        perform_zpcm_inc
        rts
.endproc

.proc str_cmd_font
StringPtr := T4
CurrentAttr := UiStringScratch+3
Scratch := UiStringScratch+7
        ; onward!
        inc16 StringPtr
        ; read and apply
        ldy #0
        lda (StringPtr), y
        and #%00111110
        sta Scratch
        lda CurrentAttr
        and #%11000001
        ora Scratch
        sta CurrentAttr
        ; onward properly!
        inc16 StringPtr
        perform_zpcm_inc
        rts
.endproc

.proc str_cmd_player_name
NametableAddr := T0
AttributeAddr := T2
StringPtr := T4

CurrentAttr := UiStringScratch+3
        ; onward!
        inc16 StringPtr
        ; draw the entire player name, right here, on the spot, using our
        ; current nametable/attr position.
        ; TODO: rework this when the player name format changes, likely to support
        ; different character sets and whatnot. For now, the player name uses ascii
        ; and marshmallows, because marshmallows are nice.
        ldx #0
        ldy #0
loop:
        perform_zpcm_inc
        ; player names are null terminated in the FONT layer, so handle that
        lda current_save + SaveFile::PlayerNameFont, x
        beq done
        ; massage that into the current font color
        sta (AttributeAddr), y
        lda CurrentAttr
        and #%11000001
        ora (AttributeAddr), y
        sta (AttributeAddr), y
        ; the character is a fully qualified tile ID, no nonsense
        lda current_save + SaveFile::PlayerNameTiles, x
        sta (NametableAddr), y
        ; onwards and done
        inc16 NametableAddr
        inc16 AttributeAddr
        inx
        ; Safety: player names should not exceed 15 characters. How did that happen?
        cpx #15
        bne loop
done:

        perform_zpcm_inc
        rts
.endproc

; Like string drawing, usually, but for erasing instead.
; Not everything needs to exist, stub out things that make no sense,
; etc.
erase_string_cmd_table:
        .word str_cmd_newline        ; D_NEWLINE     = $80
        .word str_cmd_dummy          ; D_WAIT        = $81
        .word str_cmd_dummy          ; D_CLEAR       = $82
        .word str_cmd_dummy          ; D_CLOSE       = $83 (handled manually)
        .word str_cmd_dummy_param    ; D_ATTR        = $84
        .word str_cmd_localize       ; D_LOCALIZE    = $85
        .word str_cmd_return         ; D_RETURN      = $86
        .word str_cmd_erase_ext_char ; D_LOW_CHAR    = $87
        .word str_cmd_dummy          ; D_LOW_PAGE    = $88
        .word str_cmd_dummy          ; D_HI_PAGE     = $89
        .word str_cmd_dummy_param    ; D_PAL         = $8A
        .word str_cmd_dummy_param    ; D_FONT        = $8B
        .word str_cmd_dummy          ; D_PLAYER_NAME = $8C (not implemented)
        ; TODO: safety? bah!

.proc FAR_erase_ui_string
NametableAddr := T0
AttributeAddr := T2
StringPtr     := T4

CommandPtr := UiStringScratch+0
LocalizePreservePtr := UiStringScratch+4
LocalizePreserveBank := UiStringScratch+6

LineStartTileAddr := UiStringScratch+8
LineStartAttrAddr := UiStringScratch+10

        ; Preserve our starting position; this is useful
        ; primarily for newline processing
        mov16 LineStartTileAddr, NametableAddr
        mov16 LineStartAttrAddr, AttributeAddr

loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        bmi process_command
process_single_character:
        lda #' '
        sta (NametableAddr), y
        lda #FONT_ASCII
        sta (AttributeAddr), y
        inc16 NametableAddr
        inc16 AttributeAddr
        inc16 StringPtr
        jmp loop
process_command:
        perform_zpcm_inc
        cmp #D_CLOSE
        beq end_of_string
        asl
        tax
        lda erase_string_cmd_table+0, x
        sta CommandPtr+0
        lda erase_string_cmd_table+1, x
        sta CommandPtr+1
        jsr _str_cmd_trampoline ; which will inc16 as needed
        jmp loop
end_of_string:
        perform_zpcm_inc
        rts        
.endproc

.proc str_cmd_dummy_param
StringPtr     := T4
        ; dummied out, but we need to eat a param byte also
        inc16 StringPtr
        inc16 StringPtr
        rts
.endproc

.proc str_cmd_erase_ext_char
NametableAddr := T0
AttributeAddr := T2
StringPtr := T4
CurrentAttr := UiStringScratch+3
        ; onward!
        inc16 StringPtr
        lda #' '
        sta (NametableAddr), y
        lda #FONT_ASCII
        sta (AttributeAddr), y
        inc16 NametableAddr
        inc16 AttributeAddr
        ; onward!
        inc16 StringPtr
        rts
.endproc

; Mostly for the options: occasionally we need to know the length of one
; of these stupid things in characters. Here newlines do NOT make sense,
; so dummy those out. Otherwise this is remarkably similar to string drawing,
; except our goal is to count the bytes we would have displayed.
count_string_cmd_table:
        .word str_cmd_dummy          ; D_NEWLINE     = $80
        .word str_cmd_dummy          ; D_WAIT        = $81
        .word str_cmd_dummy          ; D_CLEAR       = $82
        .word str_cmd_dummy          ; D_CLOSE       = $83 (handled manually)
        .word str_cmd_dummy_param    ; D_ATTR        = $84
        .word str_cmd_localize       ; D_LOCALIZE    = $85
        .word str_cmd_return         ; D_RETURN      = $86
        .word str_cmd_count_ext_char ; D_LOW_CHAR    = $87
        .word str_cmd_dummy          ; D_LOW_PAGE    = $88
        .word str_cmd_dummy          ; D_HI_PAGE     = $89
        .word str_cmd_dummy_param    ; D_PAL         = $8A
        .word str_cmd_dummy_param    ; D_FONT        = $8B
        .word str_cmd_dummy          ; D_PLAYER_NAME = $8C (not implemented)
        ; TODO: safety? bah!

.proc FAR_strlen_ui_string
StringLength  := R0

StringPtr     := T4

CommandPtr := UiStringScratch+0
LocalizePreservePtr := UiStringScratch+4
LocalizePreserveBank := UiStringScratch+6

        ; Initialize our result
        st16 StringLength, 0

loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        bmi process_command
process_single_character:
        inc16 StringLength
        inc16 StringPtr
        jmp loop
process_command:
        perform_zpcm_inc
        cmp #D_CLOSE
        beq end_of_string
        asl
        tax
        lda count_string_cmd_table+0, x
        sta CommandPtr+0
        lda count_string_cmd_table+1, x
        sta CommandPtr+1
        jsr _str_cmd_trampoline ; which will inc16 as needed
        jmp loop
end_of_string:
        perform_zpcm_inc
        rts   
.endproc

.proc str_cmd_count_ext_char
StringLength  := R0

StringPtr     := T4
        ; skip over the command byte
        inc16 StringPtr
        ; count the text byte
        inc16 StringLength
        inc16 StringPtr
        rts
.endproc
