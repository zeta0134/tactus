; kernel functions
.global FAR_initialize_widgets
.global FAR_update_widgets

; common widgets
.global widget_corner_cursor_init

; layouts (we might move these elsewhere eventually)
.global options_ui_layout
.global title_ui_layout

; convenient macros to tweak widget state
.macro set_widget_state_y func_ptr
    lda #<func_ptr
    sta widgets_onupdate_low, y
    lda #>func_ptr
    sta widgets_onupdate_high, y
.endmacro

; convenient macros to build the layout list, largely
; to make specifying widget parameters more sane

.macro widget_controller init_function_ptr ; no parameters needed
    .addr init_function_ptr
    .byte 0, 0, 0, 0, 0, 0, 0, 0
.endmacro

; mostly for the cursor
WIDGET_STATE_NAVIGABLE  = %10000000
; to tell the widget what the cursor is doing
WIDGET_STATE_HOVER      = %00000001