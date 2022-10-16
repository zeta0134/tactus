        .macpack longbranch

        .include "action53.inc"
        .include "battlefield.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

BATTLEFIELD_WIDTH = 14
BATTLEFIELD_HEIGHT = 10
BATTLEFIELD_SIZE = (BATTLEFIELD_WIDTH*BATTLEFIELD_HEIGHT)
MAXIMUM_QUEUE_SIZE = 144

battlefield: .res ::BATTLEFIELD_SIZE
tile_data_1: .res ::BATTLEFIELD_SIZE
tile_data_2: .res ::BATTLEFIELD_SIZE
active_queue: .res ::BATTLEFIELD_HEIGHT
inactive_queue: .res ::BATTLEFIELD_HEIGHT
queued_bytes_counter: .res 1
active_battlefield: .res 1

.segment "PRG0_8000"

TILE_REGULAR_FLOOR = $80
TILE_DISCO_FLOOR =   $82
TILE_WALL_TOP =      $84
TILE_WALL_FACE =     $86
TILE_PIT_EDGE =      $88


test_layout:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 8
        .byte WF, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, WF ; 9
.endscope

.proc FAR_initialize_battlefield
LayoutPtr := R0
Length := R2
        ; TODO: make this accept the layout pointer as an argument
        st16 LayoutPtr, test_layout
        ldy #0
loop:
        lda (LayoutPtr), y
        sta battlefield, y
        lda #0
        sta tile_data_1
        sta tile_data_2
        iny
        cpy #::BATTLEFIELD_SIZE
        bne loop
        jsr reset_inactive_queue
        rts
.endproc

.proc reset_inactive_queue
        lda #1
        ldy #0
loop:
        sta inactive_queue, y
        iny
        cpy #::BATTLEFIELD_HEIGHT
        bne loop
        rts
.endproc

.proc FAR_swap_battlefield_buffers
        ; first, copy the inactive queue to the active queue
        ; rationalle: anything we didn't get around to updating still needs to be drawn, we'll
        ; just be drawing it late with a visible glitch. It's fine
        ldy #0
loop:
        lda inactive_queue, y
        sta active_queue, y
        iny
        cpy #::BATTLEFIELD_HEIGHT
        bne loop
        ; now reset the inactive queue, setting it up for a full draw
        jsr reset_inactive_queue
        rts
.endproc

.proc FAR_queue_battlefield_updates
        lda #0
        sta queued_bytes_counter
        jsr queue_active_tiles
        jsr queue_inactive_tiles
        rts
.endproc

.proc queue_active_tiles
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        bne second_nametable
        st16 NametableAddr, $2000
        jmp row_loop
second_nametable:
        st16 NametableAddr, $2400
row_loop:
        lda queued_bytes_counter
        cmp #MAXIMUM_QUEUE_SIZE
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda active_queue, x
        jeq skip
        lda #0
        sta active_queue, x

        jsr _queue_tiles_common
        jmp converge

skip:
        add16b NametableAddr, #64
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

.proc queue_inactive_tiles
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        beq second_nametable
        st16 NametableAddr, $2000
        jmp row_loop
second_nametable:
        st16 NametableAddr, $2400
row_loop:
        lda queued_bytes_counter
        cmp #MAXIMUM_QUEUE_SIZE
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda inactive_queue, x
        jeq skip
        lda #0
        sta inactive_queue, x

        jsr _queue_tiles_common
        jmp converge

skip:
        add16b NametableAddr, #64
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

.proc _queue_tiles_common
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
        write_vram_header_ptr NametableAddr, #28, VRAM_INC_1
        ldx CurrentTile
        ldy VRAM_TABLE_INDEX
        lda #::BATTLEFIELD_WIDTH
        sta RowCounter
top_row_loop:
        ; top left
        lda battlefield, x
        sta VRAM_TABLE_START, y
        iny
        ; top right
        clc
        adc #1
        sta VRAM_TABLE_START, y
        iny
        inx
        dec RowCounter
        bne top_row_loop
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        add16b NametableAddr, #32

        write_vram_header_ptr NametableAddr, #28, VRAM_INC_1
        ldx CurrentTile
        ldy VRAM_TABLE_INDEX
        lda #::BATTLEFIELD_WIDTH
        sta RowCounter
bottom_row_loop:
        ; bottom left
        lda battlefield, x
        clc
        adc #16
        sta VRAM_TABLE_START, y
        iny
        ; bottom right
        clc
        adc #1
        sta VRAM_TABLE_START, y
        iny
        inx
        dec RowCounter
        bne bottom_row_loop
        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
        
        add16b NametableAddr, #32

        clc
        lda queued_bytes_counter
        adc #(28 + 28)
        sta queued_bytes_counter

        rts
.endproc