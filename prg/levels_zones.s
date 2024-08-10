; proper organization eventually; let me get the skeleton of this 
; mess written before I commit to subfolders
    .macpack longbranch

    .include "../build/tile_defs.inc"

    .include "battlefield.inc"
    .include "enemies.inc"
    .include "far_call.inc"
    .include "hud.inc"
    .include "levels.inc"
    .include "loot.inc"
    .include "player.inc"
    .include "prng.inc"
    .include "procgen.inc"
    .include "rainbow.inc"
    .include "sound.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .segment "LEVEL_DATA_MAZE_LAYOUTS_0"

    ;.include "../build/floors/blocking_01.incs"
    ;.include "../build/floors/blocking_02.incs"
    ;.include "../build/floors/blocking_03.incs"
    ;.include "../build/floors/blocking_04.incs"

    .include "../build/floors/cave_small_01.incs"
    .include "../build/floors/cave_small_02.incs"
    .include "../build/floors/cave_small_03.incs"
    .include "../build/floors/cave_small_04.incs"
    .include "../build/floors/cave_small_05.incs"
    .include "../build/floors/cave_small_06.incs"
    .include "../build/floors/cave_small_07.incs"
    .include "../build/floors/cave_small_08.incs"
    .include "../build/floors/cave_small_09.incs"
    .include "../build/floors/cave_small_10.incs"
    .include "../build/floors/cave_small_11.incs"

    .include "../build/floors/grass_cave_mix_01.incs"
    .include "../build/floors/grass_cave_mix_02.incs"
    .include "../build/floors/grass_cave_mix_03.incs"
    .include "../build/floors/grass_cave_mix_04.incs"
    .include "../build/floors/grass_cave_mix_05.incs"
    .include "../build/floors/grass_cave_mix_06.incs"
    .include "../build/floors/grass_cave_mix_07.incs"
    .include "../build/floors/grass_cave_mix_08.incs"
    .include "../build/floors/grass_cave_mix_09.incs"
    .include "../build/floors/grass_cave_mix_10.incs"

    .include "../build/floors/grass_small_01.incs"
    .include "../build/floors/grass_small_02.incs"
    .include "../build/floors/grass_small_03.incs"
    .include "../build/floors/grass_small_04.incs"
    .include "../build/floors/grass_small_05.incs"
    .include "../build/floors/grass_small_06.incs"
    .include "../build/floors/grass_small_07.incs"
    .include "../build/floors/grass_small_08.incs"
    .include "../build/floors/grass_small_09.incs"
    .include "../build/floors/grass_small_10.incs"

    .include "../build/floors/test_floor_corner_cases.incs"
    .include "../build/floors/test_floor_wide_open.incs"

    .segment "DATA_3"

.macro zone_banner_pos tile_x, tile_y
    .byte HUD_WORLD_PAL | CHR_BANK_ZONES
    .byte ((tile_y*16)+tile_x)
.endmacro

all_zones_data_page:

;spawn_pool_floor_min_lut:
;        .byte 0, 0, 16, 48
;spawn_pool_floor_max_lut:
;        .byte 32, 64, 96, 128
;spawn_pool_population_lut:
;        .byte 8, 10, 12, 16

zone_grasslands_floor_1:
    .addr spawn_pool_generic ; Spawn Pool
    .addr spawnset_a53_z1_f1 ; Challenge Set
    .byte 0                  ; SpawnPoolMin
    .byte 32                 ; SpawnPoolMax
    .byte 8                  ; PopulationLimit
    .addr zone_grasslands_floor_1_mazes ; Maze Pool
    .addr zone_grasslands_floor_1_exits ; Exit List
    .byte TRACK_SHOWER_GROOVE   ; Music Track
    .byte 0   ; Added Tempo
    zone_banner_pos 0, 0        ; HudHeader
    zone_banner_pos 0, 5        ; HudBanner
    .addr common_treasure_table ; ShopLootPtr

; DEBUG: just loop back on ourselves for now
zone_grasslands_floor_1_exits:
    .byte 1 ; length
    .addr zone_grasslands_floor_1

zone_grasslands_floor_1_mazes:
        .byte 10 ; length        
        banked_addr floor_grass_cave_mix_01
        banked_addr floor_grass_cave_mix_02
        banked_addr floor_grass_cave_mix_03
        banked_addr floor_grass_cave_mix_04
        banked_addr floor_grass_cave_mix_05
        banked_addr floor_grass_cave_mix_06
        banked_addr floor_grass_cave_mix_07
        banked_addr floor_grass_cave_mix_08
        banked_addr floor_grass_cave_mix_09
        banked_addr floor_grass_cave_mix_10

        .segment "CODE_1"

.proc FAR_roll_floorplan_from_active_zone_pool
FloorListPtr := R0
FloorListLength := R2
        perform_zpcm_inc
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::FloorList
        lda (PlayerZonePtr), y
        sta FloorListPtr+0
        iny
        lda (PlayerZonePtr), y
        sta FloorListPtr+1

        ldy #0
        lda (FloorListPtr), y
        sta FloorListLength

        ; pick a random maze layout and load it in
        in_range next_floor_rand, FloorListLength
        perform_zpcm_inc

        ; use the drawn index to grab the relevant data from the table
        ; each table entry is 4 bytes long:
        asl
        asl
        ; and we need to skip past the length byte
        clc
        adc #1
        ; load it up!
        tay
        lda (FloorListPtr), y
        sta BigFloorPtr+0
        iny
        lda (FloorListPtr), y
        sta BigFloorPtr+1
        iny
        lda (FloorListPtr), y
        sta BigFloorBank

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_spawn_pool_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::GeneralSpawnPool
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+1

        ldy #ZoneDefinition::SpawnPoolMin
        lda (PlayerZonePtr), y
        sta SpawnPoolMin
        ldy #ZoneDefinition::SpawnPoolMax
        lda (PlayerZonePtr), y
        sta SpawnPoolMax
        ldy #ZoneDefinition::PopulationLimit
        lda (PlayerZonePtr), y
        sta PopulationLimit

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_spawn_set_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::ChallengeSpawnSet
        lda (PlayerZonePtr), y
        sta SpawnSetPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnSetPtr+1

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_shop_loot_ptrs_for_current_zone
LootTablePtr := R0
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::ShopLootPtr
        lda (PlayerZonePtr), y
        sta LootTablePtr+0
        iny
        lda (PlayerZonePtr), y
        sta LootTablePtr+1

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc