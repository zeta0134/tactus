        .macpack longbranch

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "levels.inc"
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

inactive_tile_queue: .res ::BATTLEFIELD_HEIGHT
active_battlefield: .res 1

.segment "CODE_0"

.proc FAR_reset_inactive_queue
        perform_zpcm_inc
        lda #1
        .repeat ::BATTLEFIELD_HEIGHT, i
        sta inactive_tile_queue+i
        .endrepeat
        perform_zpcm_inc
        rts
.endproc

.proc FAR_swap_battlefield_buffers
        ; first, copy the inactive queue to the active queue
        ; rationalle: anything we didn't get around to updating still needs to be drawn, we'll
        ; just be drawing it late with a visible glitch. It's fine
        perform_zpcm_inc

        ; now reset the inactive queue, setting it up for a full draw
        near_call FAR_reset_inactive_queue

        lda active_battlefield
        eor #%00000001
        sta active_battlefield

        rts
.endproc

; crude, but effective-ish
.proc FAR_draw_battlefield_block_A
; used by _draw_tiles_common
NametableAddr := R2
CurrentTile := R4
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
        lda #0
        sta CurrentTile
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #16
        sta CurrentTile
        jsr _draw_tiles_common

        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #32
        sta CurrentTile
        jsr _draw_tiles_common

        rts
.endproc

.proc FAR_draw_battlefield_block_B
; used by _draw_tiles_common
NametableAddr := R2
CurrentTile := R4
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
        lda #192
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #48
        sta CurrentTile
        jsr _draw_tiles_common

        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        inc NametableAddr+1
        inc AttributeAddr+1
        lda #64
        sta CurrentTile
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #80
        sta CurrentTile
        jsr _draw_tiles_common

        rts
.endproc

.proc FAR_draw_battlefield_block_C
; used by _draw_tiles_common
NametableAddr := R2
CurrentTile := R4
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
        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #96
        sta CurrentTile
        jsr _draw_tiles_common

        lda #192
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #112
        sta CurrentTile
        jsr _draw_tiles_common

        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        inc NametableAddr+1
        inc AttributeAddr+1
        lda #128
        sta CurrentTile
        jsr _draw_tiles_common

        rts
.endproc

.proc FAR_draw_battlefield_block_D
; used by _draw_tiles_common
NametableAddr := R2
CurrentTile := R4
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

        ; TODO! TODO! TODO!
        ; NOTE: redundant for profiling, remove this later!!
        ; DEBUG! DEBUG! DEBUG!
        lda #0
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #128
        sta CurrentTile
        jsr _draw_tiles_common

        lda #64
        sta NametableAddr+0
        sta AttributeAddr+0
        lda #144
        sta CurrentTile
        jsr _draw_tiles_common

        lda #128
        sta NametableAddr+0
        sta AttributeAddr+0
        inc NametableAddr+1
        inc AttributeAddr+1
        lda #160
        sta CurrentTile
        jsr _draw_tiles_common

        rts
.endproc

.proc draw_inactive_tiles
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
AttributeAddr := R6
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        beq second_nametable
        st16 NametableAddr, $5000
        st16 AttributeAddr, $5800
        jmp row_loop
second_nametable:
        st16 NametableAddr, $5400
        st16 AttributeAddr, $5C00
row_loop:
        perform_zpcm_inc
        ldx CurrentRow
        lda inactive_tile_queue, x
        jeq skip
        lda #0
        sta inactive_tile_queue, x

        jsr _draw_tiles_common
skip:
        add16b NametableAddr, #64
        add16b AttributeAddr, #64
converge:
        clc
        lda CurrentTile
        adc #::BATTLEFIELD_WIDTH
        sta CurrentTile
        inc CurrentRow
        lda CurrentRow
        cmp #::BATTLEFIELD_HEIGHT
        beq done
        jmp row_loop

done:
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
NametableAddr := R2
; current tile, set by outer calling code, indexes
; into battlefield state. use this to read drawing
; details, clobber at will
CurrentTile := R4
; new: destination exattr for this row, set by calling code
AttributeAddr := R6
; used to hold the (shared) upper attribute byte, for palettes
; and (later) the extended CHR page. Does not hold lighting bits!
ScratchAttrByte := R8

        ldx CurrentTile
        ldy #0

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc

        ; top left tile
        lda tile_patterns, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ; ora #TOP_LEFT_BITS   ; this would be a nop
        sta (NametableAddr), y  ; store that to our regular nametable
        ; top-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; top right tile
        lda tile_patterns, x
        and #CORNER_MASK
        ora #TOP_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny 

        inx
.endrepeat


        ldx CurrentTile
        ldy #32

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc

        ; bottom left tile
        lda tile_patterns, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ora #BOTTOM_LEFT_BITS
        sta (NametableAddr), y  ; store that to our regular nametable
        ; bottom-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; bottom right tile
        lda tile_patterns, x
        and #CORNER_MASK
        ora #BOTTOM_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        inx
.endrepeat

        rts
.endproc
