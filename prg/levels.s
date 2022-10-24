        .macpack longbranch

        .include "action53.inc"
        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

room_layouts: .res 16
room_flags: .res 16

.segment "PRG0_8000"

.proc FAR_demo_init_floor
        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        sta room_flags, x
        inx
        cpx #16
        bne flag_loop
        ; load in the test floor's layout indices
        lda #0
        ldx #0
room_loop:
        lda test_floor, x
        sta room_layouts, x
        inx
        cpx #16
        bne room_loop
        ; for map testing, mark some of the rooms as visited, special, etc
        lda #(ROOM_FLAG_VISITED)
        sta room_flags+0
        sta room_flags+1
        sta room_flags+5
        sta room_flags+9
        sta room_flags+10
        lda #(ROOM_FLAG_VISITED | ROOM_FLAG_EXIT_STAIRS)
        sta room_flags+6
        ; For now that's enough, don't overthink this :)
        rts
.endproc

; Floors - collections of rooms

test_floor:
        .byte 0, 0, 0, 0
        .byte 0, 1, 1, 0
        .byte 0, 2, 2, 0
        .byte 0, 0, 0, 0


; Room Layouts

layouts_table:
        .word test_layout_with_four_exits
        .word test_layout
        .word far_too_many_slimes
        .word hit_box_testing


test_layout_with_four_exits:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
BS := TILE_BASIC_SLIME
IS := TILE_INTERMEDIATE_SLIME
AS := TILE_ADVANCED_SLIME
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte FL, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9
.endscope

test_layout:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
BS := TILE_BASIC_SLIME
IS := TILE_INTERMEDIATE_SLIME
AS := TILE_ADVANCED_SLIME
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte WT, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9
.endscope

far_too_many_slimes:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
BS := TILE_BASIC_SLIME
IS := TILE_INTERMEDIATE_SLIME
AS := TILE_ADVANCED_SLIME
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, FL, BS, FL, FL, AS, IS, FL, FL, BS, FL, FL, IS, WT ; 2
        .byte WT, BS, FL, FL, BS, IS, FL, FL, AS, FL, FL, FL, FL, WT ; 3
        .byte WT, FL, AS, AS, FL, FL, IS, IS, FL, FL, AS, FL, BS, WT ; 4
        .byte WT, FL, IS, FL, FL, BS, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, AS, BS, FL, BS, FL, BS, FL, AS, IS, IS, FL, FL, WT ; 6
        .byte WT, FL, FL, IS, FL, IS, FL, AS, FL, FL, FL, BS, FL, WT ; 7
        .byte WF, FL, AS, FL, BS, FL, FL, IS, FL, FL, AS, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9
.endscope

hit_box_testing:
.scope
FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
BS := TILE_BASIC_SLIME
IS := TILE_INTERMEDIATE_SLIME
AS := TILE_ADVANCED_SLIME
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, BS, BS, BS, BS, BS, FL, FL, FL, BS, FL, FL, FL, WT ; 2
        .byte WT, BS, BS, BS, BS, BS, FL, FL, FL, FL, BS, FL, FL, WT ; 3
        .byte WT, BS, BS, BS, BS, BS, FL, FL, FL, FL, FL, BS, FL, WT ; 4
        .byte WT, BS, BS, BS, BS, BS, FL, FL, FL, FL, BS, FL, FL, WT ; 5
        .byte WT, BS, BS, BS, BS, BS, FL, FL, FL, BS, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, BS, BS, BS, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9
.endscope