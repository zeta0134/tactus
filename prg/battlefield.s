        .macpack longbranch

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "PRGRAM"

battlefield: .res ::BATTLEFIELD_SIZE
tile_data: .res ::BATTLEFIELD_SIZE
tile_flags: .res ::BATTLEFIELD_SIZE

tile_patterns: .res ::BATTLEFIELD_SIZE
tile_attributes: .res ::BATTLEFIELD_SIZE
tile_detail: .res ::BATTLEFIELD_SIZE

; for those tiles that need to track a metasprite over time
; transient; this is not stored with the room because all
; metasprites are despawned. be sure to suspend properly!
tile_metasprite: .res ::BATTLEFIELD_SIZE

active_battlefield: .res 1
displayed_battlefield: .res 1

.segment "CODE_0"

.proc FAR_swap_battlefield_buffers
        ; first, copy the inactive queue to the active queue
        ; rationalle: anything we didn't get around to updating still needs to be drawn, we'll
        ; just be drawing it late with a visible glitch. It's fine
        perform_zpcm_inc

        lda active_battlefield
        eor #%00000001
        sta active_battlefield

        rts
.endproc

PALETTE_MASK  := %11000000
LIGHTING_MASK := %00000011
CORNER_MASK   := %11111100

TOP_LEFT_BITS     := %00 ; not actually used
TOP_RIGHT_BITS    := %10
BOTTOM_LEFT_BITS  := %01
BOTTOM_RIGHT_BITS := %11

.macro inline_draw_battlefield_row tile_index, nametable_addr, attribute_addr

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc ; 6

        ; First do the nametable copies; these can be optimized slightly due
        ; to shared state
        ; top left corner
        lda tile_patterns+tile_index+i            ; 4
        ; ora #TOP_LEFT_BITS   
        sta nametable_addr+(i*2)+0                ; 4
        ; top right corner
        ;lda tile_patterns+tile_index+i           ; 0 (unneeded?)
        eor #TOP_RIGHT_BITS                       ; 2
        sta nametable_addr+(i*2)+1                ; 4
        ; bottom left corner
        ;lda tile_patterns+tile_index+i           ; 0 (unneeded?)
        eor #(BOTTOM_LEFT_BITS^TOP_RIGHT_BITS)    ; 2
        sta nametable_addr+(i*2)+32               ; 4
        ; bottom right corner
        ;lda tile_patterns+tile_index+i           ; 0 (unneeded?)
        eor #(BOTTOM_LEFT_BITS^BOTTOM_RIGHT_BITS) ; 2
        sta nametable_addr+(i*2)+33               ; 4
        ; total for nametables: 26

        ; Next do the attribute copies; these are somewhat less efficient since
        ; we need to preserve torchlight state
        ; top left corner
        lda attribute_addr+(i*2)+0       ; 4
        and #LIGHTING_MASK               ; 2
        ora tile_attributes+tile_index+i ; 4
        sta attribute_addr+(i*2)+0       ; 4
        ; top right corner
        lda attribute_addr+(i*2)+1       ; 4
        and #LIGHTING_MASK               ; 2
        ora tile_attributes+tile_index+i ; 4
        sta attribute_addr+(i*2)+1       ; 4
        ; bottom left corner
        lda attribute_addr+(i*2)+32      ; 4
        and #LIGHTING_MASK               ; 2
        ora tile_attributes+tile_index+i ; 4
        sta attribute_addr+(i*2)+32      ; 4
        ; bottom right corner
        lda attribute_addr+(i*2)+33      ; 4
        and #LIGHTING_MASK               ; 2
        ora tile_attributes+tile_index+i ; 4
        sta attribute_addr+(i*2)+33      ; 4
        ; total for attributes: 56

.endrepeat

.endmacro ; cost for entire macro w/ 16 tiles: 1408

        .segment "CODE_5"

.proc FAR_draw_battlefield_block_A_inline
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        jeq second_nametable
first_nametable:
        inline_draw_battlefield_row  0, $5000, $5800
        inline_draw_battlefield_row 16, $5040, $5840
        rts
second_nametable:
        inline_draw_battlefield_row  0, $5400, $5C00
        inline_draw_battlefield_row 16, $5440, $5C40
        rts
.endproc

        .segment "CODE_6"

.proc FAR_draw_battlefield_block_B_inline
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        jeq second_nametable
first_nametable:
        inline_draw_battlefield_row 32, $5080, $5880
        inline_draw_battlefield_row 48, $50C0, $58C0
        perform_zpcm_inc
        rts
second_nametable:
        inline_draw_battlefield_row 32, $5480, $5C80
        inline_draw_battlefield_row 48, $54C0, $5CC0
        perform_zpcm_inc
        rts
.endproc

        .segment "CODE_7"

.proc FAR_draw_battlefield_block_C_inline
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        jeq second_nametable
first_nametable:
        inline_draw_battlefield_row 64, $5100, $5900
        inline_draw_battlefield_row 80, $5140, $5940
        perform_zpcm_inc
        rts
second_nametable:
        inline_draw_battlefield_row 64, $5500, $5D00
        inline_draw_battlefield_row 80, $5540, $5D40
        perform_zpcm_inc
        rts
.endproc

        .segment "CODE_8"

.proc FAR_draw_battlefield_block_D_inline
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        jeq second_nametable
first_nametable:
        inline_draw_battlefield_row  96, $5180, $5980
        inline_draw_battlefield_row 112, $51C0, $59C0
        perform_zpcm_inc
        rts
second_nametable:
        inline_draw_battlefield_row  96, $5580, $5D80
        inline_draw_battlefield_row 112, $55C0, $5DC0
        perform_zpcm_inc
        rts
.endproc

        .segment "CODE_9"

.proc FAR_draw_battlefield_block_E_inline
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        jeq second_nametable
first_nametable:
        inline_draw_battlefield_row 128, $5200, $5A00
        inline_draw_battlefield_row 144, $5240, $5A40
        inline_draw_battlefield_row 160, $5280, $5A80
        perform_zpcm_inc
        rts
second_nametable:
        inline_draw_battlefield_row 128, $5600, $5E00
        inline_draw_battlefield_row 144, $5640, $5E40
        inline_draw_battlefield_row 160, $5680, $5E80
        perform_zpcm_inc
        rts
.endproc

