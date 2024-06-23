; kernel functions
.global FAR_initialize_widgets
.global FAR_update_widgets

; common widgets
.global widget_corner_cursor_init

; layouts (we might move these elsewhere eventually)
.global options_ui_layout

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

.macro widget_cursor ; no parameters needed
    .addr widget_cursor_init
    .byte 0, 0, 0, 0, 0, 0, 0, 0
.endmacro

.macro widget_text_label text_string, tile_x, tile_y
    .addr widget_text_label_init
    .byte tile_x, tile_y
    .addr text_string
    .byte 0, 0, 0, 0
.endmacro

.macro widget_text_options label_string, option_list, data_target, tile_x, tile_y
    .addr widget_text_options_init
    .byte tile_x, tile_y
    .addr label_string
    .addr option_list
    .addr data_target
.endmacro

.macro widget_text_button text_string, action_func_ptr, tile_x, tile_y
    .addr widget_text_button_init
    .byte tile_x, tile_y
    .addr text_string
    .addr action_func_ptr
    .byte 0, 0
.endmacro

; mostly for the cursor
WIDGET_STATE_NAVIGABLE  = %10000000
; to tell the widget what the cursor is doing
WIDGET_STATE_HOVER      = %00000001