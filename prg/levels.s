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

; Initialize a fixed floor, fully open, with boss and exit stairs
; in known, predictable locations. Useful for debugging
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
        lda floor_test_floor, x
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
        
        ; TODO: pick the boss, exit, and player spawn locations here
        ; FOR TESTING, the boss room will be slot 1
        ldx #1
        lda #ROOM_FLAG_BOSS
        sta room_flags, x
        ; FOR TESTING, the exit room shall be slot 2
        ldx #2
        lda #ROOM_FLAG_EXIT_STAIRS
        sta room_flags, x

        rts
.endproc

; Generate a maze layout, and pick the player, boss, and exit locations
.proc FAR_init_floor
FloorPtr := R0
BossIndex := R2
        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        sta room_flags, x
        inx
        cpx #16
        bne flag_loop

        ; pick a random maze layout and load it in
        ; TODO: maybe this could use a global seed? it'd be nice to have a game-level seed
        ; ... though I guess also todo: write a 6502 maze generator
        jsr next_rand
        ; There are only 16 mazes in the game right now
        and #$0F
        asl
        tax
        lda maze_list, x
        sta FloorPtr
        lda maze_list+1, x
        sta FloorPtr+1

        ; Load in that floor's layout bytes
        lda #0
        ldy #0
room_loop:
        lda (FloorPtr), y
        sta room_layouts, y
        iny
        cpy #16
        bne room_loop

        ; set each room up with its own RNG low byte
        ldx #0
seed_loop:
        jsr next_rand
        sta room_seeds, x
        inx
        cpx #16
        bne seed_loop       

        ; Okay now, pick a random room for the player to spawn in
        jsr next_rand
        and #$0F
        sta PlayerRoomIndex
        ; Mark the player's room as cleared, so they don't load in surrounded by mobs
        tax
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED
        sta room_flags, x
        ; if this is zone 1, floor 1, then allow the player to have one treasure when they start
        ; (it will spawn right away)
        lda PlayerZone
        cmp #1
        bne no_starting_treasure
        lda PlayerFloor
        cmp #1
        bne no_starting_treasure
        jmp done_with_player
no_starting_treasure:
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x
done_with_player:

        ; Next choose the boss location; importantly this should NOT be the
        ; same room the player spawned in
boss_loop:
        jsr next_rand
        and #$0F
        cmp PlayerRoomIndex
        beq boss_loop
        tax
        lda #ROOM_FLAG_BOSS
        sta room_flags, x
        stx BossIndex

        ; Finally choose the exit stairs location; this should again not be the same
        ; location as the player OR the boss
exit_loop:
        jsr next_rand
        and #$0F
        cmp PlayerRoomIndex
        beq exit_loop
        cmp BossIndex
        beq exit_loop
        tax
        lda #ROOM_FLAG_EXIT_STAIRS
        sta room_flags, x

        ; Aaaand.... that's it? I think that's it

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

        ; Does this room have exit stairs? If so, spawn those first
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq no_exit_stairs
        jsr spawn_exit_block
        ldx PlayerRoomIndex
no_exit_stairs:

        ; Has the player already cleared this room?
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne room_cleared
        ; If this is a boss room, we need to use the boss pool
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne spawn_boss_enemies
spawn_basic_enemies:
        jsr spawn_basic_enemies_from_pool
        jmp room_cleared
spawn_boss_enemies:
        jsr spawn_boss_enemies_from_pool
        jmp room_cleared
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

        ; Use the real list
        lda zone_list_basic, x
        sta CollectionPtr
        lda zone_list_basic+1, x
        sta CollectionPtr+1

        ; DEBUG: use a fake list for testing new enemy types
        ;lda debug_zone_list, x
        ;sta CollectionPtr
        ;lda debug_zone_list+1, x
        ;sta CollectionPtr+1

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

.proc spawn_boss_enemies_from_pool
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

        ; Use the real boss list
        lda zone_list_boss, x
        sta CollectionPtr
        lda zone_list_boss+1, x
        sta CollectionPtr+1

        ; Use a fake list with fewer enemies, for quick testing
        ;lda debug_boss_zone_list, x
        ;sta CollectionPtr
        ;lda debug_boss_zone_list+1, x
        ;sta CollectionPtr+1

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
        ; Here we need to pick a random number from 0-3, and use that to index the pool to select
        ; one of the enemy lists
        jsr next_fixed_rand ; clobbers Y
        and #%00000011
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

.proc spawn_exit_block
EntityId := R1
        jsr set_fixed_room_seed
        lda #TILE_EXIT_BLOCK
        sta EntityId
        jsr spawn_entity
        rts
.endproc

; =============================
; Floors - collections of rooms
; =============================

; Room Layouts

.include "../build/layouts/A0.incs"
.include "../build/layouts/B0.incs"
.include "../build/layouts/C0.incs"
.include "../build/layouts/D0.incs"
.include "../build/layouts/E0.incs"
.include "../build/layouts/F0.incs"
.include "../build/layouts/G0.incs"
.include "../build/layouts/H0.incs"
.include "../build/layouts/I0.incs"
.include "../build/layouts/J0.incs"
.include "../build/layouts/K0.incs"
.include "../build/layouts/L0.incs"
.include "../build/layouts/M0.incs"
.include "../build/layouts/N0.incs"
.include "../build/layouts/O0.incs"
.include "../build/layouts/P0.incs"

layouts_table:
        .word layout_A0
        .word layout_B0
        .word layout_C0
        .word layout_D0
        .word layout_E0
        .word layout_F0
        .word layout_G0
        .word layout_H0
        .word layout_I0
        .word layout_J0
        .word layout_K0
        .word layout_L0
        .word layout_M0
        .word layout_N0
        .word layout_O0
        .word layout_P0

; for debug mode we can force the layout to an open floor plan
.include "../build/floors/test_floor.incs"

; for the actual game, we use one of a set of pregenerated mazes
; (because I do not have time to write the maze generator in 6502)
.include "../build/floors/maze_0.incs"
.include "../build/floors/maze_1.incs"
.include "../build/floors/maze_2.incs"
.include "../build/floors/maze_3.incs"
.include "../build/floors/maze_4.incs"
.include "../build/floors/maze_5.incs"
.include "../build/floors/maze_6.incs"
.include "../build/floors/maze_7.incs"
.include "../build/floors/maze_8.incs"
.include "../build/floors/maze_9.incs"
.include "../build/floors/maze_10.incs"
.include "../build/floors/maze_11.incs"
.include "../build/floors/maze_12.incs"
.include "../build/floors/maze_13.incs"
.include "../build/floors/maze_14.incs"
.include "../build/floors/maze_15.incs"

maze_list:
        .word floor_maze_0
        .word floor_maze_1
        .word floor_maze_2
        .word floor_maze_3
        .word floor_maze_4
        .word floor_maze_5
        .word floor_maze_6
        .word floor_maze_7
        .word floor_maze_8
        .word floor_maze_9
        .word floor_maze_10
        .word floor_maze_11
        .word floor_maze_12
        .word floor_maze_13
        .word floor_maze_14
        .word floor_maze_15


; =============================================
; Enemies - Pools of spawns for rooms to select
; =============================================

; Enemy lists have an arbitrary length, and can house any number
; of spawns. ALL spawns will appear in a room that uses a list, so
; if you want to vary the amount, make several similar lists

; Each pool is a FIXED length:
; - Basic pools have 16 entries
; - Boss pools have 4 entries
; If including fewer unique enemy lists, be sure
; to duplicate the list so that it is the full size

; =============================================
;                Zone 1 - Basic
; =============================================
el_intermediate_slimes:
        .byte 2 ; length
        .byte TILE_BASIC_SLIME, 4
        .byte TILE_INTERMEDIATE_SLIME, 8

el_zombies_and_slimes:
        .byte 2 ; length
        .byte TILE_ZOMBIE_BASIC, 3
        .byte TILE_BASIC_SLIME, 3
        .byte TILE_INTERMEDIATE_SLIME, 1

el_spiders_and_slimes:
        .byte 2 ; length
        .byte TILE_SPIDER_BASIC, 3
        .byte TILE_BASIC_SLIME, 2
        .byte TILE_INTERMEDIATE_SLIME, 2

el_zombies_and_spiders:
        .byte 2 ; length
        .byte TILE_SPIDER_BASIC, 2
        .byte TILE_ZOMBIE_BASIC, 3

el_basic_mix:
        .byte 2 ; length
        .byte TILE_SPIDER_BASIC, 2
        .byte TILE_ZOMBIE_BASIC, 2
        .byte TILE_BASIC_SLIME, 1
        .byte TILE_INTERMEDIATE_SLIME, 2

basic_pool_zone_1_floor_1:
        ; Make sure all sections add up to 16
        .repeat 3
        .word el_intermediate_slimes
        .endrepeat

        .repeat 4
        .word el_zombies_and_slimes
        .endrepeat

        .repeat 3
        .word el_spiders_and_slimes
        .endrepeat

        .repeat 3
        .word el_zombies_and_spiders
        .endrepeat

        .repeat 3
        .word el_basic_mix
        .endrepeat

; =============================================
;                Zone 1 - Boss
; =============================================

el_slime_pit:
        .byte 3 ; length
        .byte TILE_BASIC_SLIME, 2
        .byte TILE_INTERMEDIATE_SLIME, 6
        .byte TILE_ADVANCED_SLIME, 4


boss_pool_zone_1_floor_1:
        ; Make sure sections add up to 4
        .repeat 4
        .word el_slime_pit
        .endrepeat

; =============================================
;                Zone 2 - Basic
; =============================================
;TODO

; =============================================
;                Zone 2 - Boss
; =============================================
;TODO

; =============================================
;                Zone 3 - Basic
; =============================================
;TODO

; =============================================
;                Zone 3 - Boss
; =============================================
;TODO

; =============================================
;                Zone 4 - Basic
; =============================================
;TODO

; =============================================
;                Zone 4 - Boss
; =============================================
;TODO



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
; (Note: for demo purposes, only zone 1 actually exists; this
; list is mostly useless as a result.)
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


; ============================================================================================
;                                     DEBUG ZONES BELOW
; ============================================================================================

el_debug_enemies:
        .byte 1
        .byte TILE_INTERMEDIATE_SLIME, 1

el_debug_boss_enemies:
        .byte 1
        .byte TILE_ADVANCED_SLIME, 1

debug_pool:
        .repeat 16
        .word el_debug_enemies
        .endrepeat

debug_pool_collection:
        .word debug_pool
        .word debug_pool
        .word debug_pool
        .word debug_pool

debug_zone_list:
        .word debug_pool_collection        
        .word debug_pool_collection
        .word debug_pool_collection
        .word debug_pool_collection

debug_boss_pool:
        .repeat 16
        .word el_debug_boss_enemies
        .endrepeat

debug_boss_pool_collection:
        .word debug_boss_pool
        .word debug_boss_pool
        .word debug_boss_pool
        .word debug_boss_pool

debug_boss_zone_list:
        .word debug_boss_pool_collection        
        .word debug_boss_pool_collection
        .word debug_boss_pool_collection
        .word debug_boss_pool_collection
