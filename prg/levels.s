        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"

global_rng_seed: .res 1
room_layouts: .res 16
room_flags: .res 16 ; what did we spawn in here? what is the current status of those things?
room_seeds: .res 16
room_properties: .res 16 ; what are the BASE properties of this room? (exits, lighting, special render modes, etc)
chest_spawned: .res 1
enemies_active: .res 1

.segment "CODE_1"

; TODO: there is little reason for the various "wall" types to occupy
; different behavioral IDs, collapse these at some point
layout_behavior_ids:
        .byte 128 ; plain floor
        .byte 132 ; disco floor (unused?)
        .byte 140 ; wall face
        .byte 136 ; wall top
        .byte 144 ; south pit edge (wall)
        .byte 148 ; north pit edge (unused?)

layout_patterns:
        .byte <BG_TILE_FLOOR
        .byte <BG_TILE_DISCO_FLOOR
        .byte <BG_TILE_WALL_FACE
        .byte <BG_TILE_WALL_TOP
        .byte <BG_TILE_PIT_EDGE
        .byte <BG_TILE_PIT_CENTER

layout_attributes:
        .byte >BG_TILE_FLOOR
        .byte >BG_TILE_DISCO_FLOOR
        .byte >BG_TILE_WALL_FACE
        .byte >BG_TILE_WALL_TOP
        .byte >BG_TILE_PIT_EDGE
        .byte >BG_TILE_PIT_CENTER

.proc initialize_battlefield
LayoutPtr := R0
        ldy #0
loop:
        perform_zpcm_inc
        lda (LayoutPtr), y
        tax
        lda layout_behavior_ids, x
        sta battlefield, y
        lda #0
        sta tile_data, y
        sta tile_flags, y
        lda layout_patterns, x
        sta tile_patterns, y
        lda layout_attributes, x
        sta tile_attributes, y

        iny
        cpy #::BATTLEFIELD_SIZE
        bne loop
        far_call FAR_reset_inactive_queue
        rts
.endproc

.proc initialize_battlefield_new
RoomPtr := R0
TileIdPtr := R2
TileAddrPtr := R4
BehaviorIdPtr := R6
FlagsPtr := R8
        mov16 TileIdPtr, RoomPtr
        add16w TileIdPtr, #Room::TileIDsLow
        mov16 TileAddrPtr, RoomPtr
        add16w TileAddrPtr, #Room::TileAttrsHigh
        mov16 BehaviorIdPtr, RoomPtr
        add16w BehaviorIdPtr, #Room::BehaviorIDs
        ;mov16 FlagsPtr, RoomPtr
        ;add16w FlagsPtr, #Room::FlagBytes

        ldy #0
loop:
        lda (TileIdPtr), y
        sta tile_patterns, y   ; current tile ID (low byte)
        sta tile_detail, y     ; original, mostly for disco tiles
        lda (TileAddrPtr), y
        sta tile_attributes, y ; current attributes (palette, lighting, high tile ID, etc)
        lda (BehaviorIdPtr), y
        sta battlefield, y     ; behavior (indexes into AI lookup tables)
        ; would do flags bytes here, maybe?
        ; TODO: ah, this is where we would roll for detail tiles, I think
        ; (When we do this, don't forget to set the ROOM SEED)
        lda #0
        sta tile_data, y
        sta tile_flags, y

        iny
        cpy #::BATTLEFIELD_SIZE
        bne loop
        far_call FAR_reset_inactive_queue
        rts
.endproc

; Initialize a fixed floor, fully open, with boss and exit stairs
; in known, predictable locations. Useful for debugging
.proc FAR_demo_init_floor
        access_data_bank #<.bank(floor_test_floor)

        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        perform_zpcm_inc
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

        ; Load in the properties byte from each selected layout
        jsr load_floor_properties

        ; set each room up with its own RNG low byte
        ldx #0
seed_loop:
        ; jsr next_rand
        lda #DEBUG_SEED
        sta room_seeds, x
        inx
        cpx #16
        bne seed_loop
        
        ; TODO: pick the boss, exit, and player spawn locations here
        ; FOR TESTING, the boss room will be slot 1
        ldx #1
        lda #(ROOM_FLAG_BOSS | ROOM_FLAG_REVEALED)
        sta room_flags, x
        ; FOR TESTING, the exit room shall be slot 2
        ldx #2
        lda #ROOM_FLAG_EXIT_STAIRS
        sta room_flags, x

        restore_previous_bank
        rts
.endproc

; Generate a maze layout, and pick the player, boss, and exit locations
.proc FAR_init_floor
FloorPtr := R0
BossIndex := R2
        access_data_bank #<.bank(layouts_table)

        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        perform_zpcm_inc
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
        perform_zpcm_inc
        lda (FloorPtr), y
        sta room_layouts, y
        iny
        cpy #16
        bne room_loop

        ; Load in the properties byte from each selected layout
        jsr load_floor_properties

        ; set each room up with its own RNG low byte
        ldx #0
seed_loop:
        perform_zpcm_inc
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
        perform_zpcm_inc
        jsr next_rand
        and #$0F
        cmp PlayerRoomIndex
        beq boss_loop
        tax
        lda #(ROOM_FLAG_BOSS | ROOM_FLAG_REVEALED)
        sta room_flags, x
        stx BossIndex

        ; Choose the exit stairs location; this should again not be the same
        ; location as the player OR the boss
exit_loop:
        perform_zpcm_inc
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
        perform_zpcm_inc

        restore_previous_bank
        rts
.endproc

.proc load_floor_properties
LayoutPtr := R0
RoomIndex := R2
        access_data_bank #<.bank(layouts_table)

        lda #0
        sta RoomIndex
loop:
        perform_zpcm_inc
        ldx RoomIndex
        lda room_layouts, x
        asl
        tax
        lda layouts_table, x
        sta LayoutPtr
        lda layouts_table+1, x
        sta LayoutPtr+1

        ldx RoomIndex
        ldy #Layout::RoomProperties
        lda (LayoutPtr), y
        sta room_properties, x
        inc RoomIndex
        lda RoomIndex
        cmp #16
        bne loop

        restore_previous_bank

        rts
.endproc

.proc FAR_init_current_room
;LayoutPtr := R0
RoomPtr := R0
EntityList := R4
        access_data_bank #<.bank(layouts_table)

        ; OLD: load a "layout" from a static maze floor
        ;ldx PlayerRoomIndex
        ;lda room_layouts, x
        ;asl
        ;tax
        ;lda layouts_table, x
        ;sta LayoutPtr
        ;lda layouts_table+1, x
        ;sta LayoutPtr+1
        ;jsr initialize_battlefield

        ; NEW: load a "room", still from a static maze floor
        ldx PlayerRoomIndex
        lda room_layouts, x
        asl
        asl
        tax
        lda temporary_rooms_table+0, x
        sta RoomPtr+0
        lda temporary_rooms_table+1, x
        sta RoomPtr+1
        access_data_bank {temporary_rooms_table+2, x}
        jsr initialize_battlefield_new
        restore_previous_bank

        ; Mark this room as visited
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_VISITED
        sta room_flags, x
        lda #1
        sta HudMapDirty

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

        restore_previous_bank
        rts
.endproc

.proc FAR_handle_room_spawns
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
        access_data_bank #<.bank(layouts_table)

check_room_clear:
        lda enemies_active
        bne all_done

        perform_zpcm_inc

        ; Is this room already cleared?
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne check_chest_spawn

        ; This room is freshly cleared! Mark it so
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED
        sta room_flags, x
        lda #1
        sta HudMapDirty
        jmp all_done

check_chest_spawn:
        lda chest_spawned
        bne all_done

        perform_zpcm_inc

        ; load the fixed seed for the players current room
        jsr set_fixed_room_seed
        ; spawn in a chest
        lda #TILE_TREASURE_CHEST
        sta EntityId
        lda #<BG_TILE_TREASURE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_TREASURE_CHEST | PAL_YELLOW)
        sta EntityAttribute
        jsr spawn_entity
        lda #1
        sta chest_spawned
        
all_done:
        perform_zpcm_inc
        ; reset the enemies active counter for the next beat
        lda #0
        sta enemies_active

        restore_previous_bank
        rts
.endproc

; These are used to take a 5bit random number and pick something "in bounds" coordinate wise,
; with reasonable speed and fairness
random_row_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_HEIGHT - 6)))
        .endrepeat

random_col_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_WIDTH - 6)))
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
EntityPattern := R2
EntityAttribute := R3
TempRow := R9
TempCol := R10

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
        ; TODO: Safety: if the list near/equal/larger than the number of safe tiles
        ; on a map, this can take a very long time or lock up entirely. We should maybe
        ; have a watchdog and bail after a very high number of attempts.
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
        lda EntityId
        sta battlefield, x
        lda EntityPattern
        sta tile_patterns, x
        lda EntityAttribute
        sta tile_attributes, x
        ; draw the new tile to the active buffer right away
        jsr draw_active_tile
        ; zero out the other two properties
        ; (Not sure if this will ever be incorrect? unclear)
        ; (probably not, we'll use a spawn state if we need to set them)
        ldx TempIndex
        lda #0
        sta tile_data, x
        sta tile_flags, x
        ; all done!
        rts
.endproc

.proc spawn_entity_list
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
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
        sta EntityPattern
        iny
        lda (EntityList), y
        sta EntityAttribute
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

        

        .if ::DEBUG_TEST_FLOOR
        ; DEBUG: use a fake list for testing new enemy types
        lda debug_zone_list, x
        sta CollectionPtr
        lda debug_zone_list+1, x
        sta CollectionPtr+1
        .else
        ; Use the real list
        lda zone_list_basic, x
        sta CollectionPtr
        lda zone_list_basic+1, x
        sta CollectionPtr+1
        .endif

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

        .if ::DEBUG_TEST_FLOOR
        ; DEBUG: use a fake list for testing new enemy types
        lda debug_boss_zone_list, x
        sta CollectionPtr
        lda debug_boss_zone_list+1, x
        sta CollectionPtr+1
        .else
        ; Use the real list
        lda zone_list_boss, x
        sta CollectionPtr
        lda zone_list_boss+1, x
        sta CollectionPtr+1
        .endif

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
EntityPattern := R2
EntityAttribute := R3
        jsr set_fixed_room_seed
        lda #TILE_EXIT_BLOCK
        sta EntityId
        lda #<BG_TILE_EXIT_BLOCK
        sta EntityPattern
        lda #(>BG_TILE_EXIT_BLOCK | PAL_BLUE)
        sta EntityAttribute
        jsr spawn_entity
        rts
.endproc

        .segment "DATA_3"

.include "../build/rooms/GrassyTest_Standard_E.incs"
.include "../build/rooms/GrassyTest_Standard_W.incs"
.include "../build/rooms/GrassyTest_Standard_EW.incs"
.include "../build/rooms/GrassyTest_Standard_S.incs"
.include "../build/rooms/GrassyTest_Standard_ES.incs"
.include "../build/rooms/GrassyTest_Standard_SW.incs"
.include "../build/rooms/GrassyTest_Standard_ESW.incs"
.include "../build/rooms/GrassyTest_Standard_N.incs"
.include "../build/rooms/GrassyTest_Standard_NE.incs"
.include "../build/rooms/GrassyTest_Standard_NW.incs"
.include "../build/rooms/GrassyTest_Standard_NEW.incs"
.include "../build/rooms/GrassyTest_Standard_NS.incs"
.include "../build/rooms/GrassyTest_Standard_NES.incs"
.include "../build/rooms/GrassyTest_Standard_NSW.incs"

        .segment "DATA_4"

.include "../build/rooms/GrassyTest_Standard_NESW.incs"

; In the form of layouts table, which is soon to be rewritten
; entirely in a form that looks nothing like this
.macro temporary_room_entry room_label
        .addr room_label
        .byte <.bank(room_label), >.bank(room_label)
.endmacro

temporary_rooms_table:
        temporary_room_entry room_GrassyTest_Standard_NESW ; 0, never used
        temporary_room_entry room_GrassyTest_Standard_E
        temporary_room_entry room_GrassyTest_Standard_W
        temporary_room_entry room_GrassyTest_Standard_EW
        temporary_room_entry room_GrassyTest_Standard_S
        temporary_room_entry room_GrassyTest_Standard_ES
        temporary_room_entry room_GrassyTest_Standard_SW
        temporary_room_entry room_GrassyTest_Standard_ESW
        temporary_room_entry room_GrassyTest_Standard_N
        temporary_room_entry room_GrassyTest_Standard_NE
        temporary_room_entry room_GrassyTest_Standard_NW
        temporary_room_entry room_GrassyTest_Standard_NEW
        temporary_room_entry room_GrassyTest_Standard_NS
        temporary_room_entry room_GrassyTest_Standard_NES
        temporary_room_entry room_GrassyTest_Standard_NSW
        temporary_room_entry room_GrassyTest_Standard_NESW


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
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   3
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 4

el_zombies_and_slimes:
        .byte 3 ; length
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  3
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   3
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1

el_spiders_and_slimes:
        .byte 3 ; length
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE),   3
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 2

el_zombies_and_spiders:
        .byte 2 ; length
        .byte TILE_SPIDER_BASIC, <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),  2
        .byte TILE_ZOMBIE_BASIC, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD), 3

el_basic_mix:
        .byte 4 ; length
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  2
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2

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
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 6
        .byte TILE_ADVANCED_SLIME,     <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),    4


boss_pool_zone_1_floor_1:
        ; Make sure sections add up to 4
        .repeat 4
        .word el_slime_pit
        .endrepeat

; =============================================
;                Zone 2 - Basic
; =============================================

el_zombies_and_spiders2:
        .byte 4 ; length
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   3
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  5

el_birds_and_spiders:
        .byte 3
        .byte TILE_BIRB_LEFT_BASIC,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_YELLOW), 2
        .byte TILE_BIRB_RIGHT_BASIC, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,     <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_BLUE),   3

el_hello_mr_mole:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,    <BG_TILE_MOLE_HOLE,   (>BG_TILE_MOLE_HOLE   | PAL_RED),    2
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  3

el_full_mix:
        .byte 6
        .byte TILE_MOLE_HOLE_BASIC,    <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    1
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_YELLOW), 1
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  2
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_BIRB_LEFT_BASIC,    <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_YELLOW), 1

el_zombie_hoard:
        .byte 2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  7

basic_pool_zone_1_floor_2:
        ; Make sure all sections add up to 16
        .repeat 3
        .word el_zombies_and_spiders2
        .endrepeat

        .repeat 3
        .word el_birds_and_spiders
        .endrepeat

        .repeat 4
        .word el_hello_mr_mole
        .endrepeat

        .repeat 3
        .word el_full_mix
        .endrepeat

        .repeat 3
        .word el_zombie_hoard
        .endrepeat

; =============================================
;                Zone 2 - Boss
; =============================================

el_scary_scary_spiders:
        .byte 3
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,    (>BG_TILE_SPIDER    | PAL_BLUE),   2
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,    (>BG_TILE_SPIDER    | PAL_YELLOW), 4
        .byte TILE_MOLE_HOLE_BASIC,     <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_RED),    4

el_rockin_flock:
        .byte 7
        .byte TILE_ZOMBIE_INTERMEDIATE,     <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_YELLOW), 4
        .byte TILE_BIRB_LEFT_BASIC,         <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_YELLOW), 1
        .byte TILE_BIRB_RIGHT_BASIC,        <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_YELLOW), 1
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),   2
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE),   2
        .byte TILE_BIRB_LEFT_ADVANCED,      <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_RED),    1
        .byte TILE_BIRB_RIGHT_ADVANCED,     <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    1

boss_pool_zone_1_floor_2:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_scary_scary_spiders
        .endrepeat
        .repeat 2
        .word el_rockin_flock
        .endrepeat


; =============================================
;                Zone 3 - Basic
; =============================================

el_slimes_and_imm_zombies:
        .byte 5
        .byte TILE_BASIC_SLIME,         <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED),    1
        .byte TILE_ZOMBIE_BASIC,        <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 3

el_mole_and_friends:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,         <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_RED),   4
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),  1
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE),  1
        .byte TILE_ZOMBIE_BASIC,            <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_WORLD), 3

el_mix3:
        .byte 6
        .byte TILE_MOLE_HOLE_BASIC,        <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    2
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_BLUE),   1
        .byte TILE_ZOMBIE_BASIC,           <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,           <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_YELLOW), 2

el_adv_slimes_and_spiders:
        .byte 3
        .byte TILE_ADVANCED_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),  3
        .byte TILE_SPIDER_BASIC,    <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE), 3
        .byte TILE_MOLE_HOLE_BASIC, <BG_TILE_MOLE_HOLE,  (>BG_TILE_MOLE_HOLE  | PAL_RED),  2

basic_pool_zone_1_floor_3:
        ; Make sure all sections add up to 16
        .repeat 4
        .word el_slimes_and_imm_zombies
        .endrepeat

        .repeat 4
        .word el_mole_and_friends
        .endrepeat

        .repeat 4
        .word el_mix3
        .endrepeat

        .repeat 4
        .word el_adv_slimes_and_spiders
        .endrepeat

; =============================================
;                Zone 3 - Boss
; =============================================

el_aaaaaahhh_spiders:
        .byte 4
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE),   4
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_YELLOW), 5
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_RED),    3

el_mr_whiskers:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,         <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_RED),  6
        .byte TILE_MOLE_HOLE_ADVANCED,      <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_BLUE), 4
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE), 1
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE), 1

boss_pool_zone_1_floor_3:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_aaaaaahhh_spiders
        .endrepeat
        .repeat 2
        .word el_mr_whiskers
        .endrepeat

; =============================================
;                Zone 4 - Basic
; =============================================

el_advanced_slimes_and_zombies:
        .byte 4
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 4
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED), 2
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED), 2
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2

el_oops_all_chasers:
        .byte 6
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_ADVANCED,        <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_RED),    2
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_YELLOW), 2
        .byte TILE_SPIDER_ADVANCED,        <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_RED),    3
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),   1
        .byte TILE_BIRB_RIGHT_ADVANCED,    <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    1

el_advanced_moles_and_friends:
        .byte 5
        .byte TILE_MOLE_HOLE_ADVANCED,  <BG_TILE_MOLE_HOLE,  (>BG_TILE_MOLE_HOLE  | PAL_BLUE),   4
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_RED),    2
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_YELLOW), 1
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),    2

el_zombie_hoard_round_2:
        .byte 3
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 3
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 5
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED),    6

el_extra_healthy_mix4:
        .byte 6
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_RED),    3
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,      (>BG_TILE_SLIME_IDLE      | PAL_RED),    1
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_RED),    1
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_YELLOW), 2
        .byte TILE_BIRB_RIGHT_ADVANCED, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    2
        .byte TILE_MOLE_HOLE_ADVANCED,  <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_BLUE),   2

basic_pool_zone_1_floor_4:
        ; Make sure all sections add up to 16
        .repeat 4
        .word el_advanced_slimes_and_zombies
        .endrepeat

        .repeat 3
        .word el_oops_all_chasers
        .endrepeat

        .repeat 3
        .word el_advanced_moles_and_friends
        .endrepeat

        .repeat 3
        .word el_zombie_hoard_round_2
        .endrepeat

        .repeat 3
        .word el_extra_healthy_mix4
        .endrepeat

; =============================================
;                Zone 4 - Boss
; =============================================

el_reinforcements:
        .byte 7
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED),    6
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,        <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  2
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_RED),    4
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED),    2

el_family_reunion:
        .byte 14
        .byte TILE_BASIC_SLIME,            <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME,     <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,         <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_RED),    2
        .byte TILE_ZOMBIE_BASIC,           <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_YELLOW), 1
        .byte TILE_ZOMBIE_ADVANCED,        <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_RED),    3
        .byte TILE_SPIDER_BASIC,           <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_YELLOW), 1
        .byte TILE_SPIDER_ADVANCED,        <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_RED),    2
        .byte TILE_MOLE_HOLE_BASIC,        <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    1
        .byte TILE_MOLE_HOLE_ADVANCED,     <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_BLUE),   2
        .byte TILE_BIRB_LEFT_BASIC,        <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_YELLOW), 1
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_BLUE),   1
        .byte TILE_BIRB_LEFT_ADVANCED,     <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_RED),    2

boss_pool_zone_1_floor_4:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_reinforcements
        .endrepeat
        .repeat 2
        .word el_family_reunion
        .endrepeat

; Each zone is a collection of pools, one pool for each floor

zone_1_basic_pools:
        .word basic_pool_zone_1_floor_1 ; floor 1
        .word basic_pool_zone_1_floor_2 ; floor 2
        .word basic_pool_zone_1_floor_3 ; floor 3
        .word basic_pool_zone_1_floor_4 ; floor 4

zone_1_boss_pools:
        .word boss_pool_zone_1_floor_1 ; floor 1
        .word boss_pool_zone_1_floor_2 ; floor 2
        .word boss_pool_zone_1_floor_3 ; floor 3
        .word boss_pool_zone_1_floor_4 ; floor 4

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
        .byte TILE_BASIC_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE), 1
        ;.byte TILE_ZOMBIE_BASIC, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD), 4
        ;.byte TILE_MOLE_HOLE_BASIC, <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_RED), 2
        ;.byte TILE_MOLE_HOLE_ADVANCED, <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_BLUE), 2

el_debug_boss_enemies:
        .byte 1
        .byte TILE_ADVANCED_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED), 1

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

