        .macpack longbranch

        .include "action53.inc"
        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

battlefield: .res ::BATTLEFIELD_SIZE
tile_data_1: .res ::BATTLEFIELD_SIZE
tile_data_2: .res ::BATTLEFIELD_SIZE
active_tile_queue: .res ::BATTLEFIELD_HEIGHT
inactive_tile_queue: .res ::BATTLEFIELD_HEIGHT
active_attribute_queue: .res (::BATTLEFIELD_HEIGHT / 2)
inactive_attribute_queue: .res (::BATTLEFIELD_HEIGHT / 2)
queued_bytes_counter: .res 1
active_battlefield: .res 1

.segment "PRG0_8000"


test_layout:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
CF := TILE_CLOCK_FACE
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, PE, PE, PE, FL, FL, FL, FL, FL, WT ; 7
        .byte WT, FL, FL, FL, FL, PT, PT, PT, FL, FL, FL, FL, FL, WT ; 8
        .byte WF, PE, PE, PE, PE, PT, CF, PT, PE, PE, PE, PE, PE, WF ; 9
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
tile_loop:
        sta inactive_tile_queue, y
        iny
        cpy #::BATTLEFIELD_HEIGHT
        bne tile_loop

        ldy #0
attribute_loop:
        sta inactive_attribute_queue, y
        iny
        cpy #(::BATTLEFIELD_HEIGHT / 2)
        bne attribute_loop

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

        ldy #0
attribute_loop:
        lda inactive_attribute_queue, y
        sta active_attribute_queue, y
        iny
        cpy #(::BATTLEFIELD_HEIGHT / 2)
        bne attribute_loop

        ; now reset the inactive queue, setting it up for a full draw
        jsr reset_inactive_queue
        lda active_battlefield
        eor #%00000001
        sta active_battlefield
        rts
.endproc

.proc FAR_queue_battlefield_updates
        lda #0
        sta queued_bytes_counter
        jsr queue_active_tiles
        jsr queue_inactive_tiles
        jsr queue_active_attributes
        jsr queue_inactive_attributes
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
        st16 NametableAddr, $2082
        jmp row_loop
second_nametable:
        st16 NametableAddr, $2482
row_loop:
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
        st16 NametableAddr, $2082
        jmp row_loop
second_nametable:
        st16 NametableAddr, $2482
row_loop:
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
        adc #2
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

.proc queue_active_attributes
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        bne second_nametable
        st16 NametableAddr, $23C8
        jmp row_loop
second_nametable:
        st16 NametableAddr, $27C8
row_loop:
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 8)
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda active_attribute_queue, x
        jeq skip
        lda #0
        sta active_attribute_queue, x

        jsr _queue_attributes_common
        jmp converge

skip:
        add16b NametableAddr, #8
converge:
        clc
        lda CurrentTile
        adc #(::BATTLEFIELD_WIDTH * 2)
        sta CurrentTile
        inc CurrentRow
        lda CurrentRow
        cmp #(::BATTLEFIELD_HEIGHT / 2)
        beq done
        jmp row_loop

done:
        rts
.endproc

.proc queue_inactive_attributes
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
        lda #0
        sta CurrentRow
        sta CurrentTile
        lda active_battlefield
        beq second_nametable
        st16 NametableAddr, $23C8
        jmp row_loop
second_nametable:
        st16 NametableAddr, $27C8
row_loop:
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 8)
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        ldx CurrentRow
        lda inactive_attribute_queue, x
        jeq skip
        lda #0
        sta inactive_attribute_queue, x

        jsr _queue_attributes_common
        jmp converge

skip:
        add16b NametableAddr, #8
converge:
        clc
        lda CurrentTile
        adc #(::BATTLEFIELD_WIDTH * 2)
        sta CurrentTile
        inc CurrentRow
        lda CurrentRow
        cmp #(::BATTLEFIELD_HEIGHT / 2)
        beq done
        jmp row_loop

done:
        rts
.endproc

.proc _queue_attributes_common
CurrentRow := R0
NametableAddr := R2
CurrentTile := R4
RowCounter := R5
AttributeByte := R6

        write_vram_header_ptr NametableAddr, #8, VRAM_INC_1
        ldx CurrentTile
        ldy VRAM_TABLE_INDEX

        ; left bookend, the left attributes here are always %00
        ; top left
        clc
        ror AttributeByte
        clc
        ror AttributeByte
        ; top right
        lda battlefield, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; bottom left
        clc
        ror AttributeByte
        clc
        ror AttributeByte
        ; bottom right
        lda battlefield + ::BATTLEFIELD_WIDTH, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        lda AttributeByte
        sta VRAM_TABLE_START, y
        iny

        inx

        ; inner loop, repeat this 6 times for tiles 01 - 12
        lda #6
        sta RowCounter
inner_loop:
        ; top left
        lda battlefield, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; top right
        lda battlefield + 1, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; bottom left
        lda battlefield + ::BATTLEFIELD_WIDTH, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; bottom right
        lda battlefield + ::BATTLEFIELD_WIDTH + 1, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte

        lda AttributeByte
        sta VRAM_TABLE_START, y
        iny
        inx
        inx
        dec RowCounter
        bne inner_loop

        ; right bookend, here the rightmost tiles are always %00
        ; top left
        lda battlefield, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; top right
        clc
        ror AttributeByte
        clc
        ror AttributeByte
        ; bottom left
        lda battlefield + ::BATTLEFIELD_WIDTH, x
        lsr
        ror AttributeByte
        lsr
        ror AttributeByte
        ; bottom right
        clc
        ror AttributeByte
        clc
        ror AttributeByte

        lda AttributeByte
        sta VRAM_TABLE_START, y
        iny

        sty VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
        
        add16b NametableAddr, #8

        clc
        lda queued_bytes_counter
        adc #(8)
        sta queued_bytes_counter

        rts
.endproc