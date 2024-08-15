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

; crude, but effective-ish
.proc FAR_draw_battlefield_block_A
; used by _draw_tiles_common
NametableAddr := R2
AttributeAddr := R6
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        beq second_nametable
        lda #$50
        sta NametableAddr+1
        lda #$58
        sta AttributeAddr+1
        jmp draw_rows
second_nametable:
        lda #$54
        sta NametableAddr+1
        lda #$5C
        sta AttributeAddr+1
draw_rows:
        ; the drawing function doesn't alter the addresses, so all we need to do
        ; is set the current tile and low byte of the address as we go, and occasionally
        ; increment the high byte
        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #0
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #16
        jsr _draw_tiles_common

        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #32
        jsr _draw_tiles_common

        lda #192
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #48
        jsr _draw_tiles_common

        rts
.endproc

.proc FAR_draw_battlefield_block_B
; used by _draw_tiles_common
NametableAddr := R2
AttributeAddr := R6
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        beq second_nametable
        lda #$51
        sta NametableAddr+1
        lda #$59
        sta AttributeAddr+1
        jmp draw_rows
second_nametable:
        lda #$55
        sta NametableAddr+1
        lda #$5D
        sta AttributeAddr+1
draw_rows:
        ; the drawing function doesn't alter the addresses, so all we need to do
        ; is set the current tile and low byte of the address as we go, and occasionally
        ; increment the high byte
        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #64
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #80
        jsr _draw_tiles_common

        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #96
        jsr _draw_tiles_common

        lda #192
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #112
        jsr _draw_tiles_common

        rts
.endproc

.proc FAR_draw_battlefield_block_C
; used by _draw_tiles_common
NametableAddr := R2
AttributeAddr := R6
        ; pick the high nametable/attr address bytes for row 0
        lda active_battlefield
        beq second_nametable
        lda #$52
        sta NametableAddr+1
        lda #$5A
        sta AttributeAddr+1
        jmp draw_rows
second_nametable:
        lda #$56
        sta NametableAddr+1
        lda #$5E
        sta AttributeAddr+1
draw_rows:
        ; the drawing function doesn't alter the addresses, so all we need to do
        ; is set the current tile and low byte of the address as we go, and occasionally
        ; increment the high byte
        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #128
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #144
        jsr _draw_tiles_common

        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        ldx #160
        jsr _draw_tiles_common

        rts
.endproc

PALETTE_MASK  := %11000000
LIGHTING_MASK := %00000011
CORNER_MASK   := %11111100

TOP_LEFT_BITS     := %00 ; not actually used
TOP_RIGHT_BITS    := %10
BOTTOM_LEFT_BITS  := %01
BOTTOM_RIGHT_BITS := %11

.proc _draw_tiles_common
; used by outer function; no touch
CurrentRow := R0

; destination nametable addr for this row, set by calling code
; args: X - starting battlefield tile
; (all regs clobbered)
NametableAddr := R2
; new: destination exattr for this row, set by calling code
AttributeAddr := R6
; used to hold the (shared) upper attribute byte, for palettes
; and (later) the extended CHR page. Does not hold lighting bits!
ScratchAttrByte := R8

        ; entry: 6

        ldy #0 ; 2

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc ; 6

        ; top left tile
        lda tile_patterns+i, x   ; 4
        ; ora #TOP_LEFT_BITS     ;   this would be a nop
        sta (NametableAddr), y   ; 6 store that to our regular nametable
        ; top-left attribute
        lda (AttributeAddr), y   ; 5
        and #LIGHTING_MASK       ; 2 keep only lighting bits        
        ora tile_attributes+i, x ; 4 NEW apply palette and high tile bits
        sta (AttributeAddr), y   ; 6
        iny                      ; 2

        ; top right tile
        lda tile_patterns+i, x   ; 4
        ora #TOP_RIGHT_BITS      ; 2
        sta (NametableAddr), y   ; 6
        ; top-right attribute
        lda (AttributeAddr), y   ; 5
        and #LIGHTING_MASK       ; 2 keep only lighting bits
        ora tile_attributes+i, x ; 4 NEW apply palette and high tile bits
        sta (AttributeAddr), y   ; 6
        iny                      ; 2
.endrepeat ; 66*16 = 1056

        
        ldy #32 ; 2

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc         ; 6

        ; bottom left tile
        lda tile_patterns+i, x   ; 4
        ora #BOTTOM_LEFT_BITS    ; 2
        sta (NametableAddr), y   ; 6 store that to our regular nametable
        ; bottom-left attribute
        lda (AttributeAddr), y   ; 5
        and #LIGHTING_MASK       ; 2 keep only lighting bits        
        ora tile_attributes+i, x ; 4 NEW apply palette and high tile bits
        sta (AttributeAddr), y   ; 6
        iny                      ; 2

        ; bottom right tile
        lda tile_patterns+i, x   ; 4
        ora #BOTTOM_RIGHT_BITS   ; 2
        sta (NametableAddr), y   ; 6
        ; top-right attribute
        lda (AttributeAddr), y   ; 5
        and #LIGHTING_MASK       ; 2 keep only lighting bits
        ora tile_attributes+i, x ; 4 NEW apply palette and high tile bits
        sta (AttributeAddr), y   ; 6
        iny                      ; 2
.endrepeat ; 68*16 = 1088

        rts ; 6
.endproc ; total function cost: 2160

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
        rts
second_nametable:
        inline_draw_battlefield_row 32, $5480, $5C80
        inline_draw_battlefield_row 48, $54C0, $5CC0
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
        rts
second_nametable:
        inline_draw_battlefield_row 64, $5500, $5D00
        inline_draw_battlefield_row 80, $5540, $5D40
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
        rts
second_nametable:
        inline_draw_battlefield_row  96, $5580, $5D80
        inline_draw_battlefield_row 112, $55C0, $5DC0
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
        rts
second_nametable:
        inline_draw_battlefield_row 128, $5600, $5E00
        inline_draw_battlefield_row 144, $5640, $5E40
        inline_draw_battlefield_row 160, $5680, $5E80
        rts
.endproc

