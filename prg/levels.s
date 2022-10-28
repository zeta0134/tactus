        .macpack longbranch

        .include "action53.inc"
        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

global_rng_seed: .res 1
room_layouts: .res 16
room_flags: .res 16
room_seeds: .res 16

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
        ; For now that's enough, don't overthink this :)
        rts
.endproc

.proc FAR_init_current_room
LayoutPtr := R0
        ; Load this room into the current battlefield
        ldx PlayerRoomIndex
        lda room_layouts, x
        asl
        tax
        lda layouts_table, x
        sta LayoutPtr
        lda layouts_table+1, x
        sta LayoutPtr+1
        near_call FAR_initialize_battlefield

        ; Mark this room as visited
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_VISITED
        sta room_flags, x

        ; TODO: spawn enemies
        rts
.endproc

; Floors - collections of rooms

test_floor:
        .byte 1, 5, 5, 2
        .byte 7, 0, 0, 8
        .byte 7, 0, 0, 8
        .byte 3, 6, 6, 4


; Room Layouts

layouts_table:
        .word test_layout_with_four_exits
        .word test_layout_top_left
        .word test_layout_top_right
        .word test_layout_bottom_left
        .word test_layout_bottom_right
        .word test_layout_top_edge
        .word test_layout_bottom_edge
        .word test_layout_left_edge
        .word test_layout_right_edge

FL := TILE_REGULAR_FLOOR
WF := TILE_WALL_FACE
WT := TILE_WALL_TOP
PE := TILE_PIT_EDGE
PT := TILE_PIT
BS := TILE_BASIC_SLIME
IS := TILE_INTERMEDIATE_SLIME
AS := TILE_ADVANCED_SLIME
TC := TILE_TREASURE_CHEST
BK := TILE_BIG_KEY
HC := TILE_HEART_CONTAINER
GS := TILE_GOLD_SACK

test_layout_top_left:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte WT, FL, TC, GS, BK, HC, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_top_right:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_bottom_left:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_bottom_right:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_top_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte FL, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_bottom_edge:
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
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_left_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_right_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, IS, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, BS, FL, FL, FL, AS, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_with_four_exits:
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

test_layout:
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

far_too_many_slimes:
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

hit_box_testing:
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

