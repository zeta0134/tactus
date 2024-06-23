        .include "../build/tile_defs.inc"

        .include "charmap.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "input.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "text_util.inc"
        .include "ui.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "RAM"

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

test_value_1: .res 1
test_value_2: .res 1
test_value_3: .res 1
test_value_4: .res 1
test_value_5: .res 1

        .segment "CODE_4"

; ======================================================================
;                         Test Layouts
;       (regular layouts should be split into separate files?)
; ======================================================================

options_ui_layout:
        widget_controller options_controller_init
        widget_cursor
        widget_text_label options_str, 4, 3
        widget_text_options disco_floor_str, disco_types, setting_disco_floor, 8, 5
        widget_text_button back_to_title_str, return_to_title, 8, 20
        .addr $0000 ; end of list

options_str:       .asciiz "- OPTIONS -"
disco_floor_str:   .asciiz "FLOOR: "
back_to_title_str: .asciiz "RETURN TO TITLE "

disco_types:
        .byte 4 ; length of option set
        .addr disco_option_0_str
        .addr disco_option_1_str
        .addr disco_option_2_str
        .addr disco_option_3_str

disco_option_0_str: .asciiz "DISCO SQUARES"
disco_option_1_str: .asciiz "DISCO OUTLINES"
disco_option_2_str: .asciiz "JUST GROOVEMENT"
disco_option_3_str: .asciiz "NO MOTION"

considerations:
        .byte 2
        .addr option_not_considered
        .addr option_considered

option_not_considered: .asciiz "NOT CONSIDERED"
option_considered:     .asciiz "CONSIDERED    "

empty_string: .asciiz ""

title_ui_layout:
        widget_controller title_controller_init
        widget_cursor
        widget_text_button empty_string, go_to_gameplay, 12, 10
        widget_text_button empty_string, go_to_options, 12, 13
        .addr $0000 ; end of list

; ======================================================================
;                      Layout Specific Functions
;       (mostly the "base" controller widget that manages state)
; ======================================================================

.proc options_controller_init
CurrentWidgetIndex := R20
        ; setup stuff, whatever, do it later

        ; Play the options track on the options screen
        lda #4
        jsr play_track

        ldy CurrentWidgetIndex
        set_widget_state_y options_controller_update
        rts
.endproc

.proc options_controller_update
        lda #KEY_B
        and ButtonsDown
        beq stay_here
        jsr return_to_title
stay_here:
        rts
.endproc

.proc return_to_title
        st16 FadeToGameMode, title_prep
        st16 GameMode, fade_to_game_mode
        rts
.endproc

.proc title_controller_init
        CurrentWidgetIndex := R20
        ; setup stuff, whatever, do it later

        ldy CurrentWidgetIndex
        set_widget_state_y title_controller_update
        rts
.endproc

.proc title_controller_update
        lda #KEY_START
        and ButtonsDown
        beq stay_here

        jsr go_to_gameplay
stay_here:
        rts
.endproc

.proc go_to_options
        st16 FadeToGameMode, options_prep
        st16 GameMode, fade_to_game_mode
        rts
.endproc

.proc go_to_gameplay
        st16 FadeToGameMode, game_prep
        st16 GameMode, fade_to_game_mode
        rts
.endproc

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
        ; firstly, for sanity, completely zero out all of widget memory
        ; absolutely no holding onto previous state from other runs
        lda #0
        ldy #0
memclr_loop:
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

        ; DEBUG
        lda #0
        sta test_value_1
        lda #0
        sta test_value_2

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
; Begin general-purpose, reusable widgets
; (screens will certainly have lots of custom widgets too)
; ======================================================================

.proc widget_no_behavior
        ; exactly that. used by all static elements that are done with initial setup
        ; (we don't clean these up because we might need other widgets to manipulate
        ; their state, and we also aren't performance bound at all)
        rts
.endproc

.proc widget_cursor_init
MetaSpriteIndex := R0
CurrentWidgetIndex := R20
        
widget_sprite_index := widgets_data0
widget_cursor_nav_index := widgets_data1

        ; firstly, set our tracked index to be invalid, which
        ; gives consistent behavior. we want our first update to perform
        ; a scan of the list, but we also want to give all the widgets
        ; a chance to initialize themselves first, so we wait one frame
        ; before triggering that scan for the first time
        ldy CurrentWidgetIndex
        lda #$FF
        sta widget_cursor_nav_index, y

        far_call FAR_find_unused_sprite
        lda MetaSpriteIndex
        ldy CurrentWidgetIndex
        sta widget_sprite_index, y

        ldx widget_sprite_index, y
        lda #(SPRITE_ACTIVE | SPRITE_PAL_1)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #0
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #$F0 ; offscreen for now 
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #<SPRITE_TILE_MENU_CURSOR_SPIN
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldy CurrentWidgetIndex
        set_widget_state_y widget_cursor_update

        rts
.endproc

.proc widget_cursor_update
TargetWidgetIndex := R0
CurrentWidgetIndex := R20

widget_sprite_index := widgets_data0
widget_cursor_nav_index := widgets_data1
        jsr clear_hover_states

        ldy CurrentWidgetIndex
        lda widget_cursor_nav_index, y
        sta TargetWidgetIndex

        ; if we are not currently pointing to a navigable element, try to find oue
        ; (this is our startup state; we'll usually be pointing at ourselves, and
        ; the cursor is not considered 'active') 

        ldx TargetWidgetIndex
        cmp #$FF
        beq find_new_widget
continue_considering:
        lda widgets_state_flags, x
        and #WIDGET_STATE_NAVIGABLE
        bne target_valid
find_new_widget:
        jsr find_first_active_widget
        ldy CurrentWidgetIndex
        lda TargetWidgetIndex
        sta widget_cursor_nav_index, y
        cmp #$FF
        bne new_target_acquired
target_invalid:
        ; hide ourselves immediately and do nothing
        ldx widget_sprite_index, y
        lda #$F0 ; offscreen for now 
        sta sprite_table + MetaSpriteState::PositionY, x
        rts
new_target_acquired:
        ; initialize our position to the target's position
        ; with no lerping
        jsr snap_to_widget_position
        jmp update_at_active_position
target_valid:
        ; if the user has pressed the UP or DOWN buttons,
        ; try to find a new target (which should remain valid)
        lda #KEY_DOWN
        bit ButtonsDown
        bne handle_move_down
        lda #KEY_UP
        bit ButtonsDown
        bne handle_move_up
        jmp update_at_active_position
handle_move_down:
        jsr move_to_next_active_widget
        ldy CurrentWidgetIndex
        lda TargetWidgetIndex
        sta widget_cursor_nav_index, y
        jmp update_at_active_position
handle_move_up:
        jsr move_to_previous_active_widget
        ldy CurrentWidgetIndex
        lda TargetWidgetIndex
        sta widget_cursor_nav_index, y
        ; fall through
update_at_active_position:
        ; smoothly lerp the cursor to its current position
        jsr lerp_to_widget_position
        ; tell the widget we're pointing at that it should become
        ; "hovered", whatever that widget thinks that means
        jsr set_hover_state
        rts
.endproc

; result placed in R0
; returns #$FF on failure
.proc find_first_active_widget
TargetWidgetIndex := R0
        ldy #0
loop:
        lda widgets_state_flags, y
        and #WIDGET_STATE_NAVIGABLE
        bne found_one
        iny
        cmp #::MAX_WIDGETS
        bne loop
did_not_find_one:
        lda #$FF
        sta TargetWidgetIndex
        rts
found_one:
        tya
        sta TargetWidgetIndex
        rts
.endproc

; for right now, widgets are in a simple linked list, and
; we traverse the items in that list in order. we might expand
; on this later, but we're thinking this will serve our needs
; for a good long while
.proc move_to_next_active_widget
TargetWidgetIndex := R0
        ; starting at our position +1, scan forward for an active widget
        ldy TargetWidgetIndex
        iny
        cpy #::MAX_WIDGETS   ; safety: if we run off the end of the list, bail
        beq did_not_find_one
loop:
        lda widgets_state_flags, y
        and #WIDGET_STATE_NAVIGABLE
        bne found_one
        iny
        cpy #::MAX_WIDGETS
        bne loop
did_not_find_one:
        ; leave the target unchanged!
        rts
found_one:
        ; TODO: play a "cursor moved" sfx here
        tya
        sta TargetWidgetIndex
        rts
.endproc

.proc move_to_previous_active_widget
TargetWidgetIndex := R0
        ; starting at our position -1, scan forward for an active widget
        ldy TargetWidgetIndex
        beq did_not_find_one
        dey
loop:
        lda widgets_state_flags, y
        and #WIDGET_STATE_NAVIGABLE
        bne found_one
        cpy #0
        beq did_not_find_one
        dey
        bne loop
did_not_find_one:
        ; leave the target unchanged!
        rts
found_one:
        ; TODO: play a "cursor moved" sfx here
        tya
        sta TargetWidgetIndex
        rts
.endproc

.proc snap_to_widget_position
TargetWidgetIndex := R0
CurrentWidgetIndex := R20

widget_sprite_index := widgets_data0

        ldy CurrentWidgetIndex
        lda widget_sprite_index, y
        tax
        ldy TargetWidgetIndex
        lda widgets_cursor_pos_x, y
        sta sprite_table + MetaSpriteState::PositionX, x
        lda widgets_cursor_pos_y, y
        sta sprite_table + MetaSpriteState::PositionY, x

        rts
.endproc

.proc lerp_to_widget_position
        ; FOR NOW, just snap. no lerping during debug
        jsr snap_to_widget_position

        rts
.endproc

.proc clear_hover_states
        ldy #0
loop:
        lda widgets_state_flags, y
        and #($FF - WIDGET_STATE_HOVER)
        sta widgets_state_flags, y
        iny
        cpy #::MAX_WIDGETS
        bne loop
        rts
.endproc

.proc set_hover_state
TargetWidgetIndex := R0
        ldx TargetWidgetIndex
        lda widgets_state_flags, x
        ora #WIDGET_STATE_HOVER
        sta widgets_state_flags, x
        rts
.endproc

.proc widget_text_label_init
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
        jsr _draw_widget_label

        ldy CurrentWidgetIndex
        set_widget_state_y widget_no_behavior

        rts
.endproc

.proc widget_text_options_init
CurrentWidgetIndex := R20

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_label_string_low := widgets_data2
widget_label_string_high := widgets_data3
widget_options_table_low := widgets_data4
widget_options_table_high := widgets_data5
widget_data_target_low := widgets_data6
widget_data_target_high := widgets_data7

        ; set our cursor position based on the leftmost tile position
        ldy CurrentWidgetIndex
        lda widget_tile_x, y
        asl ; x2
        asl ; x4
        asl ; x8
        sec
        sbc #17
        sta widgets_cursor_pos_x, y
        lda widget_tile_y, y
        asl ; x2
        asl ; x4
        asl ; x8
        sec
        sbc #4
        sta widgets_cursor_pos_y, y

        ; flag this widget as active for cursor navigation purposes
        lda widgets_state_flags, y
        ora #WIDGET_STATE_NAVIGABLE
        sta widgets_state_flags, y

        ; draw the initial label and options for this widget
        jsr _draw_widget_label
        jsr _draw_option

        ; now switch to the update function
        ldy CurrentWidgetIndex
        set_widget_state_y widget_text_options_update
        rts
.endproc

.proc widget_text_options_update
CurrentWidgetIndex := R20
        ; if we aren't even hovered, no change
        ldy CurrentWidgetIndex
        lda widgets_state_flags, y
        and #WIDGET_STATE_HOVER
        bne check_for_forward_input
        rts
check_for_forward_input:
        lda #(KEY_RIGHT | KEY_A)
        bit ButtonsDown
        beq check_for_reverse_input
        jsr cycle_to_next_option
        jmp redraw_self
check_for_reverse_input:
        lda #(KEY_LEFT)
        bit ButtonsDown
        beq nothing_to_do
        jsr cycle_to_previous_option
        jmp redraw_self
nothing_to_do:
        rts
redraw_self:
        jsr _draw_widget_label
        jsr _draw_option
        rts
.endproc

.proc cycle_to_next_option
OptionsTablePtr := R0
DataValuePtr := R2
CurrentWidgetIndex := R20

widget_options_table_low := widgets_data4
widget_options_table_high := widgets_data5
widget_data_target_low := widgets_data6
widget_data_target_high := widgets_data7
        jsr _erase_option

        ldy CurrentWidgetIndex
        lda widget_options_table_low, y
        sta OptionsTablePtr+0
        lda widget_options_table_high, y
        sta OptionsTablePtr+1
        lda widget_data_target_low, y
        sta DataValuePtr+0
        lda widget_data_target_high, y
        sta DataValuePtr+1

        ldy #0
        ;inc (DataValuePtr), y
        lda (DataValuePtr), y
        clc
        adc #1
        ; did we run past the end of the table?
        cmp (OptionsTablePtr), y ; first byte contains the length
        bcs wraparound
        sta (DataValuePtr), y
        rts
wraparound:
        lda #0
        sta (DataValuePtr), y
        rts
.endproc

.proc cycle_to_previous_option
OptionsTablePtr := R0
DataValuePtr := R2
CurrentWidgetIndex := R20

widget_options_table_low := widgets_data4
widget_options_table_high := widgets_data5
widget_data_target_low := widgets_data6
widget_data_target_high := widgets_data7
        jsr _erase_option

        ldy CurrentWidgetIndex
        lda widget_options_table_low, y
        sta OptionsTablePtr+0
        lda widget_options_table_high, y
        sta OptionsTablePtr+1
        lda widget_data_target_low, y
        sta DataValuePtr+0
        lda widget_data_target_high, y
        sta DataValuePtr+1

        ldy #0

        lda (DataValuePtr), y
        beq wraparound
        sec
        sbc #1
        sta (DataValuePtr), y
        rts
wraparound:
        lda (OptionsTablePtr), y
        sec
        sbc #1
        sta (DataValuePtr), y
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

        ldy CurrentWidgetIndex
        lda widget_tile_x, y
        sta TileX
        lda widget_tile_y, y
        sta TileY
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        far_call FAR_nametable_from_coordinates
        ldy CurrentWidgetIndex
        lda widget_text_string_low, y
        sta StringPtr+0
        lda widget_text_string_high, y
        sta StringPtr+1
        lda #CHR_BANK_OLD_CHRRAM
        sta TileBase
        lda #0 ; sure, why not
        sta PaletteIndex
        jsr FIXED_draw_string

        rts
.endproc

range_error_str: .asciiz "RANGE ERROR!"

.proc _draw_option_common
OptionsTablePtr := R0
DataValuePtr := R2
CurrentWidgetIndex := R20

; arguments to string drawing functions
NametableAddr := T0
AttributeAddr := T2
TileX := T4
TileY := T5
StringPtr := T4
TileBase := T6
PaletteIndex := T7

StringLenPtr := T0
StringLength := T2

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_label_string_low := widgets_data2
widget_label_string_high := widgets_data3
widget_options_table_low := widgets_data4
widget_options_table_high := widgets_data5
widget_data_target_low := widgets_data6
widget_data_target_high := widgets_data7

        ; first, we need to skip over the label portion, so work that out
        ldy CurrentWidgetIndex
        lda widget_label_string_low, y
        sta StringLenPtr+0
        lda widget_label_string_high, y
        sta StringLenPtr+1
        jsr FIXED_strlen
        ; however long the label is, add that much to the starting X position
        ; in tiles for string drawing
        ldy CurrentWidgetIndex
        lda StringLength
        clc
        adc widget_tile_x, y
        sta TileX
        lda widget_tile_y, y
        sta TileY
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        far_call FAR_nametable_from_coordinates
        ; Now pick out the appropriate entry from the options table
        ldy CurrentWidgetIndex
        lda widget_options_table_low, y
        sta OptionsTablePtr+0
        lda widget_options_table_high, y
        sta OptionsTablePtr+1
        lda widget_data_target_low, y
        sta DataValuePtr+0
        lda widget_data_target_high, y
        sta DataValuePtr+1

        ldy #0
        lda (DataValuePtr), y
        ; sanity check: have we somehow exceeded the bounds of the table?
        cmp (OptionsTablePtr), y
        bcs option_out_of_range
option_in_range:
        ; use the current value to index into the list of option strings
        asl
        clc
        adc #1
        tay
        lda (OptionsTablePtr), y
        sta StringPtr+0
        iny
        lda (OptionsTablePtr), y
        sta StringPtr+1
        jmp converge
option_out_of_range:
        lda #<range_error_str
        sta StringPtr+0
        lda #>range_error_str
        sta StringPtr+1
converge:
        ; finally, draw the stupid thing
        lda #CHR_BANK_OLD_CHRRAM
        sta TileBase
        lda #%01000000 ; sure, why not
        sta PaletteIndex        
        ; setup complete, the calling function will decide what to do
        ; with this string information. common, out!
        rts
.endproc

.proc _draw_option
        jsr _draw_option_common
        jsr FIXED_draw_string
        rts
.endproc

.proc _erase_option
        jsr _draw_option_common
        jsr FIXED_erase_string
        rts
.endproc

.proc widget_text_button_init
CurrentWidgetIndex := R20

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_label_string_low := widgets_data2
widget_label_string_high := widgets_data3

        ; set our cursor position based on the leftmost tile position
        ldy CurrentWidgetIndex
        lda widget_tile_x, y
        asl ; x2
        asl ; x4
        asl ; x8
        sec
        sbc #17
        sta widgets_cursor_pos_x, y
        lda widget_tile_y, y
        asl ; x2
        asl ; x4
        asl ; x8
        sec
        sbc #4
        sta widgets_cursor_pos_y, y

        ; flag this widget as active for cursor navigation purposes
        lda widgets_state_flags, y
        ora #WIDGET_STATE_NAVIGABLE
        sta widgets_state_flags, y

        ; draw the initial label and options for this widget
        jsr _draw_widget_label

        ; now switch to the update function
        ldy CurrentWidgetIndex
        set_widget_state_y widget_text_button_update
        rts
.endproc

.proc __action_trampoline
ActionFuncPtr := R0
        jmp (ActionFuncPtr)
        ; rts (implied)
.endproc

.proc widget_text_button_update
ActionFuncPtr := R0
CurrentWidgetIndex := R20

; rename the data labels to something more readable
widget_tile_x := widgets_data0
widget_tile_y := widgets_data1
widget_action_func_low := widgets_data4
widget_action_func_high := widgets_data5
        ; if we aren't even hovered, do nothing
        ldy CurrentWidgetIndex
        lda widgets_state_flags, y
        and #WIDGET_STATE_HOVER
        bne check_for_action_input
        rts
check_for_action_input:
        lda #KEY_A
        and ButtonsDown
        beq do_nothing

        ; load up our pointer and call into it
        lda widget_action_func_low, y
        sta ActionFuncPtr+0
        lda widget_action_func_high, y
        sta ActionFuncPtr+1
        jsr __action_trampoline

do_nothing:
        rts
.endproc