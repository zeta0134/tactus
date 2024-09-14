        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "chr.inc"
        ;.include "charmap.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "input.inc"
        .include "math_util.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "text_util.inc"
        .include "ui.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "PRGRAM"

MAX_WIDGETS = 16 ; just how many do we need!?

; This is sortof like a baby finite state machine with extra
; UI information dangling off the side, mostly to help the
; cursor to move around sanely and skip over inactive bits

widgets_onupdate_low: .res ::MAX_WIDGETS
widgets_onupdate_high: .res ::MAX_WIDGETS
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
;widgets_data8: .res ::MAX_WIDGETS
;widgets_data9: .res ::MAX_WIDGETS
;widgets_data10: .res ::MAX_WIDGETS

; used to detect beat transitions, used for a few polish-y
; beat counting effects
LastBeat: .res 1

        .segment "CODE_B"

        .include "ui/widgets/cursors.incs"
        .include "ui/widgets/numeric_slider.incs"
        .include "ui/widgets/text_label.incs"
        .include "ui/widgets/text_options.incs"
        .include "ui/widgets/text_button.incs"

; some common strings and utilities shared by many layouts
empty_string: .asciiz ""

        .include "ui/title_screen.incs"
        .include "ui/options_screen.incs"

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
        perform_zpcm_inc
        ; firstly, for sanity, completely zero out all of widget memory
        ; absolutely no holding onto previous state from other runs
        lda #0
        ldy #0
memclr_loop:
        perform_zpcm_inc
        sta widgets_onupdate_low, y
        sta widgets_onupdate_high, y
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
        rts
.endproc

.proc __widget_trampoline
WidgetUpdatePtr := R18
        jmp (WidgetUpdatePtr)
        ; rts (implied)
.endproc

.proc FAR_update_widgets
; put our own variables near the end of scratch, so 
; widget logic can use the low end without conflict
WidgetUpdatePtr := R18
CurrentWidgetIndex := R20
        lda #0
        sta CurrentWidgetIndex
loop:
        perform_zpcm_inc
        ldy CurrentWidgetIndex
        lda widgets_onupdate_high, y
        beq widget_inactive ; if the high byte is 0, this widget doesn't exist
        sta WidgetUpdatePtr+1
        lda widgets_onupdate_low, y
        sta WidgetUpdatePtr+0
        jsr __widget_trampoline
widget_inactive:
        inc CurrentWidgetIndex
        lda CurrentWidgetIndex
        cmp #::MAX_WIDGETS
        beq done
        jmp loop
done:
        rts
.endproc

; ======================================================================
; Utility functions common to many widgets, various odds and ends, etc
; ======================================================================

.proc widget_no_behavior
        ; exactly that. used by all static elements that are done with initial setup
        ; (we don't clean these up because we might need other widgets to manipulate
        ; their state, and we also aren't performance bound at all)
        rts
.endproc

.proc _draw_widget_label
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
        lda #0 ; sure, why not
        sta PaletteIndex
        jsr FIXED_draw_string

        rts
.endproc

