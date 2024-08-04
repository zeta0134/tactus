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

        ldy #0

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc

        ; top left tile
        lda tile_patterns+i, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ; ora #TOP_LEFT_BITS   ; this would be a nop
        sta (NametableAddr), y  ; store that to our regular nametable
        ; top-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes+i, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; top right tile
        lda tile_patterns+i, x
        and #CORNER_MASK
        ora #TOP_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes+i, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny 
.endrepeat

        
        ldy #32

.repeat ::BATTLEFIELD_WIDTH, i
        perform_zpcm_inc

        ; bottom left tile
        lda tile_patterns+i, x
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ora #BOTTOM_LEFT_BITS
        sta (NametableAddr), y  ; store that to our regular nametable
        ; bottom-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora tile_attributes+i, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; bottom right tile
        lda tile_patterns+i, x
        and #CORNER_MASK
        ora #BOTTOM_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora tile_attributes+i, x  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny
.endrepeat

        rts
.endproc
