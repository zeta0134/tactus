        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "chr.inc"
        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "input.inc"
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
        lda widgets_state_flags, x
        ora #WIDGET_STATE_CLEANUP_REQUESTED
        sta widgets_state_flags, x
        inx
        cpx #::MAX_WIDGETS
        bne cleanup_flag_loop

        lda #1
        sta SubLayoutRequested
        
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

.proc FAR_draw_widget_label
CurrentWidgetIndex := R20

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_text_string_low := widgets_data2
widget_text_string_high := widgets_data3

; arguments to string drawing functions
NametableAddr := T0
AttributeAddr := T2
TileX := T4
TileY := T5
StringPtr := T4
TileBase := T6
PaletteIndex := T7
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widget_tile_x, y
        sta TileX
        lda widget_tile_y, y
        sta TileY
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        far_call FAR_nametable_from_coordinates
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widget_text_string_low, y
        sta StringPtr+0
        lda widget_text_string_high, y
        sta StringPtr+1
        lda #CHR_BANK_FONT_MARSHMALLOW
        sta TileBase
        lda #0
        sta PaletteIndex
        jsr FIXED_draw_string

        rts
.endproc

.proc FAR_draw_widget_label_pal
CurrentWidgetIndex := R20

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_text_string_low := widgets_data2
widget_text_string_high := widgets_data3
widget_text_pal_index := widgets_data7

; arguments to string drawing functions
NametableAddr := T0
AttributeAddr := T2
TileX := T4
TileY := T5
StringPtr := T4
TileBase := T6
PaletteIndex := T7
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widget_tile_x, y
        sta TileX
        lda widget_tile_y, y
        sta TileY
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        far_call FAR_nametable_from_coordinates
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widget_text_string_low, y
        sta StringPtr+0
        lda widget_text_string_high, y
        sta StringPtr+1
        lda #CHR_BANK_FONT_MARSHMALLOW
        sta TileBase
        lda widget_text_pal_index, y
        sta PaletteIndex
        jsr FIXED_draw_string

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
        lda #CHR_BANK_FONT_MARSHMALLOW
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
