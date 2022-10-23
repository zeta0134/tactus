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
HUD_LOWER_ROW_LEFT  = $2322
HUD_UPPER_ROW_RIGHT  = $2742
HUD_MIDDLE_ROW_RIGHT = $2762
HUD_LOWER_ROW_RIGHT  = $2722
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
        lda HudBottomRowDirty
        and #%00000001
        beq skip_bottom_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_bottom_row_left
        write_vram_header_imm HUD_LOWER_ROW_LEFT, #28, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_bottom_row
        lda HudBottomRowDirty
        and #%11111110
        sta HudBottomRowDirty
skip_bottom_row_left:
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
        lda HudBottomRowDirty
        and #%00000010
        beq skip_bottom_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_bottom_row_right
        write_vram_header_imm HUD_LOWER_ROW_RIGHT, #28, VRAM_INC_1
        ldy VRAM_TABLE_INDEX
        near_call FAR_queue_hud_bottom_row
        lda HudBottomRowDirty
        and #%11111101
        sta HudBottomRowDirty
skip_bottom_row_right:
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

zone_text: .asciiz "ZONE: "
hyphen_text: .asciiz "-"
weapon_level_text: .asciiz "L-"

weapon_name_table:
        .word dagger_text
        .word broadsword_text
        .word longsword_text
        .word spear_text
        .word flail_text

dagger_text:     .asciiz "DAGGER"     ; 6
broadsword_text: .asciiz "BROADSWORD" ; 10
longsword_text:  .asciiz "LONGSWORD"  ; 9
spear_text:      .asciiz "SPEAR"      ; 5
flail_text:      .asciiz "FLAIL"      ; 5

weapon_padding_table:
        .byte 4, 0, 1, 5, 5

.proc draw_padding
PaddingAmount := R0
        lda PaddingAmount
        beq skip
        lda #BLANK_TILE
loop:
        sta VRAM_TABLE_START, y
        iny
        dec PaddingAmount
        bne loop
skip:
        rts
.endproc

.proc draw_string
StringPtr := R0
VramIndex := R2
        sty VramIndex ; preserve
loop:
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        ldy VramIndex
        sta VRAM_TABLE_START, y
        inc VramIndex
        inc16 StringPtr
        jmp loop
end_of_string:
        ldy VramIndex
        rts
.endproc

.proc draw_single_digit
Digit := R0
        lda #NUMBERS_BASE
        clc
        adc Digit
        sta VRAM_TABLE_START, y
        iny
        rts
.endproc

.proc FAR_queue_hud_bottom_row
; One scratch byte, many functions
; (okay stringptr uses two bytes)
PaddingAmount := R0
StringPtr := R0
Digit := R0
        ; 0123456789012345678901234567
        ; ZONE: W-L     L-N WWWWWWWWWW
        ; Zone area, indicating our overall game state
        st16 StringPtr, zone_text
        jsr draw_string
        lda #1 ; TODO: use the actual world number
        sta Digit
        jsr draw_single_digit
        st16 StringPtr, hyphen_text
        jsr draw_string
        lda #1 ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit
        ; Fixed padding between zone end and weapon area begin
        lda #5
        sta PaddingAmount
        jsr draw_padding
        ; Variable padding depending on player equipped weapon
        ldx PlayerWeapon
        lda weapon_padding_table, x
        sta PaddingAmount
        jsr draw_padding
        ; Weapon level
        st16 StringPtr, weapon_level_text
        jsr draw_string
        lda PlayerWeaponDmg ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit
        ; One space between the weapon level and its name
        lda #1
        sta PaddingAmount
        jsr draw_padding
        ; Finally the weapon name
        lda PlayerWeapon
        asl
        tax
        lda weapon_name_table, x
        sta StringPtr
        lda weapon_name_table+1, x
        sta StringPtr+1
        jsr draw_string
        ; And that's the whole top row, we just need to close out the vram buffer 
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
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