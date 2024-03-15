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

active_tile_queue: .res ::BATTLEFIELD_HEIGHT
inactive_tile_queue: .res ::BATTLEFIELD_HEIGHT
queued_bytes_counter: .res 1
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
        ldy #0
tile_loop:
        lda inactive_tile_queue, y
        sta active_tile_queue, y
        iny
        cpy #::BATTLEFIELD_HEIGHT
        bne tile_loop



        perform_zpcm_inc

        ; now reset the inactive queue, setting it up for a full draw
        near_call FAR_reset_inactive_queue
        lda active_battlefield
        eor #%00000001
        sta active_battlefield
        rts
.endproc

.proc FAR_queue_battlefield_updates
        perform_zpcm_inc
        lda #0
        sta queued_bytes_counter

        perform_zpcm_inc
        jsr draw_active_tiles
        perform_zpcm_inc
        jsr draw_inactive_tiles
        perform_zpcm_inc

        rts
.endproc

; TODO: will we be using this long term? We might replace it
; with a "draw specific active tile" routine to perform less
; work after vertical strikes. If we do that, maybe we can
; remove this function.
.proc draw_active_tiles
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
AttributeAddr := R6
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        bne second_nametable
        st16 NametableAddr, $5042
        st16 AttributeAddr, $5842
        jmp row_loop
second_nametable:
        st16 NametableAddr, $5442
        st16 AttributeAddr, $5C42
row_loop:
        perform_zpcm_inc
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28 - 28)
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda active_tile_queue, x
        jeq skip
        lda #0
        sta active_tile_queue, x

        jsr _draw_tiles_common
        jmp converge

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

.proc draw_inactive_tiles
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
AttributeAddr := R6
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        beq second_nametable
        st16 NametableAddr, $5042
        st16 AttributeAddr, $5842
        jmp row_loop
second_nametable:
        st16 NametableAddr, $5442
        st16 AttributeAddr, $5C42
row_loop:
        perform_zpcm_inc
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28 - 28)
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda inactive_tile_queue, x
        jeq skip
        lda #0
        sta inactive_tile_queue, x

        jsr _draw_tiles_common
        jmp converge

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
; this routine will add #64 to this address
NametableAddr := R2
; current tile, set by outer calling code, indexes
; into battlefield state. use this to read drawing
; details, clobber at will
CurrentTile := R4
; scratch, used to keep track of how many tiles we've drawn
RowCounter := R5
; new: destination exattr for this row, set by calling code
; this routine will add #64 to this address
AttributeAddr := R6
; used to hold the (shared) upper attribute byte, for palettes
; and (later) the extended CHR page. Does not hold lighting bits!
ScratchAttrByte := R8

        ldx CurrentTile
        ldy #0
        lda #::BATTLEFIELD_WIDTH
        sta RowCounter

top_row_loop:
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
        dec RowCounter
        bne top_row_loop


        add16b NametableAddr, #32
        add16b AttributeAddr, #32

        ldx CurrentTile
        ldy #0
        lda #::BATTLEFIELD_WIDTH
        sta RowCounter
bottom_row_loop:
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
        dec RowCounter
        bne bottom_row_loop
        
        add16b NametableAddr, #32
        add16b AttributeAddr, #32

        clc
        lda queued_bytes_counter
        adc #(28 + 28)
        sta queued_bytes_counter

        rts
.endproc
