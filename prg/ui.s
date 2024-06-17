    .include "../build/tile_defs.inc"

    .include "far_call.inc"
    .include "sprites.inc"
    .include "ui.inc"
    .include "word_util.inc"
    .include "zeropage.inc"

    .segment "RAM"

MAX_WIDGETS = 16 ; just how many do we need!?

;widgets: .res (.sizeof(MenuWidget)*::MAX_WIDGETS)

; This is sortof like a baby finite state machine with extra
; UI information dangling off the side, mostly to help the
; cursor to move around sanely and skip over inactive bits

.struct MenuWidget
    UpdateFunc .addr
    OnSelectFunc .addr
    TopPixel .byte
    BottomPixel .byte
    LeftPixel .byte
    RightPixel .byte
    StateFlags .byte
    Data .byte 8 ; for whatever
.endstruct

widgets_onupdate_low: .res ::MAX_WIDGETS
widgets_onupdate_high: .res ::MAX_WIDGETS
widgets_onselect_low: .res ::MAX_WIDGETS
widgets_onselect_high: .res ::MAX_WIDGETS
widgets_top_pixel: .res ::MAX_WIDGETS
widgets_bottom_pixel: .res ::MAX_WIDGETS
widgets_left_pixel: .res ::MAX_WIDGETS
widgets_right_pixel: .res ::MAX_WIDGETS
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

    .segment "CODE_1"

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
    sta widgets_onselect_low, y
    sta widgets_onselect_high, y
    sta widgets_top_pixel, y
    sta widgets_bottom_pixel, y
    sta widgets_left_pixel, y
    sta widgets_right_pixel, y
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
    sta PtrStash+0
    sta widgets_onupdate_low, x
    sta PtrStash+1
    sta widgets_onupdate_high, x
    ; advance!
    inx
    cpx #::MAX_WIDGETS
    beq done
    jmp widget_loop

done:
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

.proc widget_corner_cursor_init
WidgetIndex := R0
    ; allocate all four corner sprites, which will track the onscreen position
    ; of the cursor

    ; (don't bother with failure; during UI drawing the sprite allocations are reasonably fixed)
    far_call FAR_find_unused_sprite
    ldy WidgetIndex
    txa
    sta widgets_data0, y
    far_call FAR_find_unused_sprite
    ldy WidgetIndex
    txa
    sta widgets_data1, y
    far_call FAR_find_unused_sprite
    ldy WidgetIndex
    txa
    sta widgets_data2, y
    far_call FAR_find_unused_sprite
    ldy WidgetIndex
    txa
    sta widgets_data3, y

    ; initialize all four sprites
    ldx widgets_data0, y
    lda #(SPRITE_ACTIVE | SPRITE_PAL_1)
    sta sprite_table + MetaSpriteState::BehaviorFlags, x
    lda #$FF
    sta sprite_table + MetaSpriteState::LifetimeBeats, x
    lda #0
    sta sprite_table + MetaSpriteState::PositionX, x
    lda #$F0 ; offscreen for now
    sta sprite_table + MetaSpriteState::PositionY, x
    lda #<SPRITE_TILE_MENU_CURSOR
    sta sprite_table + MetaSpriteState::TileIndex, x

    ldx widgets_data1, y
    lda #(SPRITE_ACTIVE | SPRITE_HORIZ_FLIP | SPRITE_PAL_1)
    sta sprite_table + MetaSpriteState::BehaviorFlags, x
    lda #$FF
    sta sprite_table + MetaSpriteState::LifetimeBeats, x
    lda #0
    sta sprite_table + MetaSpriteState::PositionX, x
    lda #$F0 ; offscreen for now
    sta sprite_table + MetaSpriteState::PositionY, x
    lda #<SPRITE_TILE_MENU_CURSOR
    sta sprite_table + MetaSpriteState::TileIndex, x

    ldx widgets_data2, y
    lda #(SPRITE_ACTIVE | SPRITE_VERT_FLIP | SPRITE_PAL_1)
    sta sprite_table + MetaSpriteState::BehaviorFlags, x
    lda #$FF
    sta sprite_table + MetaSpriteState::LifetimeBeats, x
    lda #0
    sta sprite_table + MetaSpriteState::PositionX, x
    lda #$F0 ; offscreen for now
    sta sprite_table + MetaSpriteState::PositionY, x
    lda #<SPRITE_TILE_MENU_CURSOR
    sta sprite_table + MetaSpriteState::TileIndex, x

    ldx widgets_data3, y
    lda #(SPRITE_ACTIVE | SPRITE_HORIZ_FLIP | SPRITE_VERT_FLIP | SPRITE_PAL_1)
    sta sprite_table + MetaSpriteState::BehaviorFlags, x
    lda #$FF
    sta sprite_table + MetaSpriteState::LifetimeBeats, x
    lda #0
    sta sprite_table + MetaSpriteState::PositionX, x
    lda #$F0 ; offscreen for now
    sta sprite_table + MetaSpriteState::PositionY, x
    lda #<SPRITE_TILE_MENU_CURSOR
    sta sprite_table + MetaSpriteState::TileIndex, x

    set_widget_state_y widget_corner_cursor_update

    rts
.endproc

.proc widget_corner_cursor_update
    ; nothing! nothing at all!
    rts
.endproc