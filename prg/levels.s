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
        .include "prng.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

global_rng_seed: .res 1
room_layouts: .res 16
room_flags: .res 16
room_seeds: .res 16
chest_spawned: .res 1
enemies_active: .res 1

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

        ; set each room up with its own RNG low byte
        ldx #0
seed_loop:
        jsr next_rand
        sta room_seeds, x
        inx
        cpx #16
        bne seed_loop        

        ; For now that's enough, don't overthink this :)
        ; TODO: pick the boss, exit, and player spawn locations here

        rts
.endproc

.proc FAR_init_current_room
LayoutPtr := R0
EntityList := R4
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

        ; If the player has already collected this room's treausre, then don't allow
        ; another one to spawn
        lda room_flags, x
        and #ROOM_FLAG_TREASURE_COLLECTED
        bne treasure_already_collected
        lda #0
        sta chest_spawned
        jmp converge_treasure
treasure_already_collected:
        lda #1
        sta chest_spawned
converge_treasure:

        ; set the initial enemies active counter to nonzero, so we process at least one full beat before considering the room to be "empty"
        lda #1
        sta enemies_active

        ; Has the player already cleared this room?
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne room_cleared
        jsr spawn_basic_enemies_from_pool
room_cleared:
        
        rts
.endproc

.proc FAR_handle_room_spawns
EntityId := R1
        lda enemies_active
        bne all_done
        lda chest_spawned
        bne all_done
        ; This room was just cleared! Mark it so
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED
        sta room_flags, x

        ; load the fixed seed for the players current room
        jsr set_fixed_room_seed
        ; spawn in a chest
        lda #TILE_TREASURE_CHEST
        sta EntityId
        jsr spawn_entity
        lda #1
        sta chest_spawned
all_done:
        ; reset the enemies active counter for the next beat
        lda #0
        sta enemies_active
        rts
.endproc

; These are used to take a 5bit random number and pick something "in bounds" coordinate wise,
; with reasonable speed and fairness
random_row_table:
        .repeat 32, i
        .byte (2 + (i .MOD (::BATTLEFIELD_HEIGHT - 4)))
        .endrepeat

random_col_table:
        .repeat 32, i
        .byte (2 + (i .MOD (::BATTLEFIELD_WIDTH - 4)))
        .endrepeat

; Spawn the provided entity somewhere "safe" in the room.
; Safe positions are: row >= 2, row <= height-2, col >= 2, col <= height-2
; The player's current location is not safe
; Only floor tiles (and disco floor tiles I suppose) are safe
; WARNING: If there are no safe floor tiles at all on this map, the function WILL lock up indefinitely.
; Try not to let this happen.
; Note: calls 
.proc spawn_entity
TempIndex := R0
EntityId := R1
TempRow := R2
TempCol := R3

find_safe_coordinate:
        jsr next_fixed_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta TempRow
        jsr next_fixed_rand
        and #%00011111
        tax
        lda random_col_table, x
        sta TempCol
check_player_coords:
        lda PlayerRow
        cmp TempRow
        bne check_floor
        lda PlayerCol
        cmp TempCol
        bne check_floor
        ; no good; this spawn would be on top of the player. Move it somewhere else
        jmp find_safe_coordinate
check_floor:
        ldx TempRow
        lda row_number_to_tile_index_lut, x
        clc
        adc TempCol
        sta TempIndex
        ldx TempIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_REGULAR_FLOOR
        beq is_valid_space
        cmp #TILE_DISCO_FLOOR
        beq is_valid_space
        ; no good; this is not a floor tile. We cannot spawn anything here,
        ; try again
        jmp find_safe_coordinate
is_valid_space:
        ; conveniently, X is already our destination, so just write this
        ; tile there
        jsr draw_active_tile
        ; zero out the other two properties
        ; (Not sure if this will ever be incorrect? unclear)
        ldx TempIndex
        lda #0
        sta tile_data, x
        sta tile_flags, x
        ; all done!
        rts
.endproc

.proc spawn_entity_list
EntityId := R1
EntityList := R4
ListIndex := R6
ListLength := R7
EntityCount := R8
        ldy #0
        lda (EntityList), y
        beq done ; do not process an empty list
        sta ListLength
        iny
        sty ListIndex
list_loop:
        ldy ListIndex
        lda (EntityList), y
        sta EntityId
        iny
        lda (EntityList), y
        sta EntityCount
        iny
        sty ListIndex
entity_loop:
        jsr spawn_entity
        dec EntityCount
        bne entity_loop
        dec ListLength
        bne list_loop
done:
        rts
.endproc

.proc spawn_basic_enemies_from_pool
CollectionPtr := R0
PoolPtr := R2
EntityList := R4
        ; Everything we are about to do depends on the room seed, so fix that in place before we start
        jsr set_fixed_room_seed

        ; First find the pool collection for this zone
        lda PlayerZone
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tax
        lda zone_list_basic, x
        sta CollectionPtr
        lda zone_list_basic+1, x
        sta CollectionPtr+1
        ; Now load the appropriate pool list for this floor from the collection
        lda PlayerFloor
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tay
        lda (CollectionPtr), y
        sta PoolPtr
        iny
        lda (CollectionPtr), y
        sta PoolPtr+1
        ; Here we need to pick a random number from 0-15, and use that to index the pool to select
        ; one of the enemy lists
        jsr next_fixed_rand ; clobbers Y
        and #%00001111
        asl ; still indexing words
        tay
        lda (PoolPtr), y
        sta EntityList
        iny
        lda (PoolPtr), y
        sta EntityList+1
        ; Finally, now that we have the entity list, spawn random enemies from it
        jsr spawn_entity_list
done:
        rts
.endproc

; =============================
; Floors - collections of rooms
; =============================

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
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_top_right:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_bottom_left:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_bottom_right:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_top_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_bottom_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE, PE ; 9

test_layout_left_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_right_edge:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9

test_layout_with_four_exits:
        ;      0   1   2   3   4   5   6   7   8   9  10  11  12  13
        .byte WT, WT, WT, WT, FL, FL, FL, FL, FL, FL, WT, WT, WT, WT ; 0
        .byte WT, WF, WF, WF, FL, FL, FL, FL, FL, FL, WF, WF, WF, WT ; 1
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 2
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 3
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 4
        .byte FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL ; 5
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 6
        .byte WT, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WT ; 7
        .byte WF, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, FL, WF ; 8
        .byte PE, PE, PE, PE, FL, FL, FL, FL, FL, FL, PE, PE, PE, PE ; 9


; =============================================
; Enemies - Pools of spawns for rooms to select
; =============================================

; Enemy lists have an arbitrary length, and can house any number
; of spawns. ALL spawns will appear in a room that uses a list, so
; if you want to vary the amount, make several similar lists

el_basic_slimes:
        .byte 1 ; length
        .byte TILE_BASIC_SLIME, 8

el_intermediate_slimes:
        .byte 2 ; length
        .byte TILE_BASIC_SLIME, 4
        .byte TILE_INTERMEDIATE_SLIME, 8

el_advanced_slimes:
        .byte 3 ; length
        .byte TILE_BASIC_SLIME, 2
        .byte TILE_INTERMEDIATE_SLIME, 4
        .byte TILE_ADVANCED_SLIME, 4

; Each pool is a FIXED length:
; - Basic pools have 16 entries
; - Boss pools have 4 entries
; If including fewer unique enemy lists, be sure
; to duplicate the list so that it is the full size

basic_pool_zone_1_floor_1:
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_basic_slimes
        .word el_intermediate_slimes
        .word el_intermediate_slimes
        .word el_intermediate_slimes
        .word el_intermediate_slimes

boss_pool_zone_1_floor_1:
        .word el_advanced_slimes
        .word el_advanced_slimes
        .word el_advanced_slimes
        .word el_advanced_slimes

; Each zone is a collection of pools, one pool for each floor

zone_1_basic_pools:
        .word basic_pool_zone_1_floor_1 ; floor 1
        .word basic_pool_zone_1_floor_1 ; floor 2
        .word basic_pool_zone_1_floor_1 ; floor 3
        .word basic_pool_zone_1_floor_1 ; floor 4

zone_1_boss_pools:
        .word boss_pool_zone_1_floor_1 ; floor 1
        .word boss_pool_zone_1_floor_1 ; floor 2
        .word boss_pool_zone_1_floor_1 ; floor 3
        .word boss_pool_zone_1_floor_1 ; floor 4

; And finally, here is the list of zone collections
zone_list_basic:
        .word zone_1_basic_pools ; zone 1
        .word zone_1_basic_pools ; zone 2
        .word zone_1_basic_pools ; zone 3
        .word zone_1_basic_pools ; zone 4

zone_list_boss:
        .word zone_1_boss_pools ; zone 1
        .word zone_1_boss_pools ; zone 2
        .word zone_1_boss_pools ; zone 3
        .word zone_1_boss_pools ; zone 4