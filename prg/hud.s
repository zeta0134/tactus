        .macpack longbranch

        .include "battlefield.inc"
        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "hud.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

HudTopRowDirty: .res 1
HudMiddleRowDirty: .res 1
HudBottomRowDirty: .res 1
HudAttrDirty: .res 1
HudGoldDisplay: .res 5

.segment "PRG0_8000"

HUD_UPPER_ROW_LEFT  = $2342
HUD_MIDDLE_ROW_LEFT = $2362
HUD_LOWER_ROW_LEFT  = $2382
HUD_UPPER_ROW_RIGHT  = $2742
HUD_MIDDLE_ROW_RIGHT = $2762
HUD_LOWER_ROW_RIGHT  = $2782
HUD_ATTR_LEFT = $23F0
HUD_ATTR_RIGHT = $27F0

HEART_FULL_TILE = 204
HEART_HALF_TILE = 200
HEART_EMPTY_TILE = 196
BLANK_TILE = 254

.proc FAR_init_hud
        near_call FAR_refresh_hud
        lda #0
        sta HudGoldDisplay+0
        sta HudGoldDisplay+1
        sta HudGoldDisplay+2
        sta HudGoldDisplay+3
        sta HudGoldDisplay+4
        rts
.endproc

.proc FAR_refresh_hud
        lda #%00000011
        sta HudTopRowDirty
        sta HudMiddleRowDirty
        sta HudBottomRowDirty
        sta HudAttrDirty
        rts
.endproc

.proc FAR_queue_hud
        lda HudTopRowDirty
        and #%00000001
        beq skip_top_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_top_row_left
        write_vram_header_imm HUD_UPPER_ROW_LEFT, #20, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_top_row
        lda HudTopRowDirty
        and #%11111110
        sta HudTopRowDirty
skip_top_row_left:
        lda HudMiddleRowDirty
        and #%00000001
        beq skip_middle_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_middle_row_left
        write_vram_header_imm HUD_MIDDLE_ROW_LEFT, #20, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_middle_row
        lda HudMiddleRowDirty
        and #%11111110
        sta HudMiddleRowDirty
skip_middle_row_left:
        lda HudTopRowDirty
        and #%00000010
        beq skip_top_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_top_row_right
        write_vram_header_imm HUD_UPPER_ROW_RIGHT, #20, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_top_row
        lda HudTopRowDirty
        and #%11111101
        sta HudTopRowDirty
skip_top_row_right:
        lda HudMiddleRowDirty
        and #%00000010
        beq skip_middle_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_middle_row_right
        write_vram_header_imm HUD_MIDDLE_ROW_RIGHT, #20, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_middle_row
        lda HudMiddleRowDirty
        and #%11111101
        sta HudMiddleRowDirty
skip_middle_row_right:
        lda HudAttrDirty
        and #%00000001
        beq skip_attributes_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 8)
        bcs skip_attributes_left
        write_vram_header_imm HUD_ATTR_LEFT, #8, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_attributes
        lda HudAttrDirty
        and #%11111110
        sta HudAttrDirty
skip_attributes_left:
        lda HudAttrDirty
        and #%00000010
        beq skip_attributes_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 8)
        bcs skip_attributes_right
        write_vram_header_imm HUD_ATTR_RIGHT, #8, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_attributes
        lda HudAttrDirty
        and #%11111100
        sta HudAttrDirty
skip_attributes_right:

        
        rts
.endproc

.proc FAR_queue_hud_attributes
        ; TODO: this
        rts
.endproc

; Note: Expects a VRAM header to aleady be written, and Y to be loaded with the index
; DOES close out this header upon completion
.proc FAR_queue_hud_top_row
CurrentHeart := R0
FullHeartThreshold := R1
HalfHeartThreshold := R2
        ; up to 10 hearts
        lda #1
        sta CurrentHeart
        lda #2
        sta FullHeartThreshold
        lda #1
        sta HalfHeartThreshold
loop:
        lda PlayerHealth
        cmp FullHeartThreshold
        bcc check_half_heart
        lda #(HEART_FULL_TILE+0)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_FULL_TILE+2)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
check_half_heart:
        cmp HalfHeartThreshold
        bcc check_heart_container
        lda #(HEART_HALF_TILE+0)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_HALF_TILE+2)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
check_heart_container:
        lda PlayerMaxHealth
        cmp HalfHeartThreshold
        bcc draw_nothing
        lda #(HEART_EMPTY_TILE+0)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_EMPTY_TILE+2)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
draw_nothing:
        lda #BLANK_TILE
        sta VRAM_TABLE_START, y
        iny
        sta VRAM_TABLE_START, y
        iny
converge:
        ; DRAW TWO BLANK TILES
        inc FullHeartThreshold
        inc FullHeartThreshold
        inc HalfHeartThreshold
        inc HalfHeartThreshold
        inc CurrentHeart
        lda CurrentHeart
        cmp #11
        bne loop
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        ; TODO: gold counter (6 more tiles)

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter
        rts
.endproc

; Note: Expects a VRAM header to aleady be written, and Y to be loaded with the index
; DOES close out this header upon completion
.proc FAR_queue_hud_middle_row
CurrentHeart := R0
FullHeartThreshold := R1
HalfHeartThreshold := R2
        ; up to 10 hearts
        lda #1
        sta CurrentHeart
        lda #2
        sta FullHeartThreshold
        lda #1
        sta HalfHeartThreshold
        
loop:
        lda PlayerHealth
        cmp FullHeartThreshold
        bcc check_half_heart
        lda #(HEART_FULL_TILE+1)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_FULL_TILE+3)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
check_half_heart:
        cmp HalfHeartThreshold
        bcc check_heart_container
        lda #(HEART_HALF_TILE+1)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_HALF_TILE+3)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
check_heart_container:
        lda PlayerMaxHealth
        cmp HalfHeartThreshold
        bcc draw_nothing
        lda #(HEART_EMPTY_TILE+1)
        sta VRAM_TABLE_START, y
        iny
        lda #(HEART_EMPTY_TILE+3)
        sta VRAM_TABLE_START, y
        iny
        jmp converge
draw_nothing:
        lda #BLANK_TILE
        sta VRAM_TABLE_START, y
        iny
        sta VRAM_TABLE_START, y
        iny
converge:
        ; DRAW TWO BLANK TILES
        inc FullHeartThreshold
        inc FullHeartThreshold
        inc HalfHeartThreshold
        inc HalfHeartThreshold
        inc CurrentHeart
        lda CurrentHeart
        cmp #11
        bne loop
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        ; TODO: gold counter (6 more tiles)

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter

        rts
.endproc

; Note: Expects a VRAM header to aleady be written, and Y to be loaded with the index
; DOES close out this header upon completion
.proc FAR_queue_attributes
        ; heart cells (11) on the bottom, text (01) on the top
        lda #%11110101
        .repeat 5
        sta VRAM_TABLE_START, y
        iny
        .endrepeat
        ; everything else will be pure text
        lda #%01010101
        .repeat 3
        sta VRAM_TABLE_START, y
        iny
        .endrepeat
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
        rts
.endproc