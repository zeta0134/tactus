.macro set_widget_state_y func_ptr
    lda #<func_ptr
    sta widgets_onupdate_low, y
    lda #>func_ptr
    sta widgets_onupdate_high, y
.endmacro

; mostly for the cursor
WIDGET_STATE_NAVIGABLE  = %10000000
WIDGET_STATE_SELECTABLE = %01000000
; to tell the widget what the cursor is doing
WIDGET_STATE_HOVER      = %00000001