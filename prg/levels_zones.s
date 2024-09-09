; proper organization eventually; let me get the skeleton of this 
; mess written before I commit to subfolders
        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "LEVEL_DATA_MAZE_LAYOUTS_0"

        .include "../build/floors/blocking_01.incs"
        .include "../build/floors/blocking_02.incs"
        .include "../build/floors/blocking_03.incs"
        .include "../build/floors/blocking_04.incs"

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
        .include "../build/floors/hub_world.incs"

        .segment "DATA_3"

hud_grasslands_pal:
        .incbin "../art/zone_1_banner.pal"

hud_beach_pal:
        .incbin "../art/zone_2_banner.pal"

hud_hub_pal:
        .incbin "../art/zone_hub_banner.pal"

.macro zone_banner_pos tile_x, tile_y
        .byte ((tile_y*16)+tile_x)
        .byte (HUD_WORLD_PAL | CHR_BANK_ZONES)
.endmacro

; for bank switching
all_zones_data_page:

;  ########  ##        #######   ######  ##    ## #### ##    ##  ######   
;  ##     ## ##       ##     ## ##    ## ##   ##   ##  ###   ## ##    ##  
;  ##     ## ##       ##     ## ##       ##  ##    ##  ####  ## ##        
;  ########  ##       ##     ## ##       #####     ##  ## ## ## ##   #### 
;  ##     ## ##       ##     ## ##       ##  ##    ##  ##  #### ##    ##  
;  ##     ## ##       ##     ## ##    ## ##   ##   ##  ##   ### ##    ##  
;  ########  ########  #######   ######  ##    ## #### ##    ##  ######   

zone_blocking_mazes:
        .byte 4 ; length        
        banked_addr floor_blocking_01
        banked_addr floor_blocking_02
        banked_addr floor_blocking_03
        banked_addr floor_blocking_04

;    ######   ########     ###     ######   ######  ##          ###    ##    ## ########   ######  
;   ##    ##  ##     ##   ## ##   ##    ## ##    ## ##         ## ##   ###   ## ##     ## ##    ## 
;   ##        ##     ##  ##   ##  ##       ##       ##        ##   ##  ####  ## ##     ## ##       
;   ##   #### ########  ##     ##  ######   ######  ##       ##     ## ## ## ## ##     ##  ######  
;   ##    ##  ##   ##   #########       ##       ## ##       ######### ##  #### ##     ##       ## 
;   ##    ##  ##    ##  ##     ## ##    ## ##    ## ##       ##     ## ##   ### ##     ## ##    ## 
;    ######   ##     ## ##     ##  ######   ######  ######## ##     ## ##    ## ########   ######  

zone_grasslands_floor_1:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f1 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 32                 ; SpawnPoolMax
        .byte 8                  ; PopulationLimit
        .addr zone_grasslands_floor_1_mazes ; Maze Pool
        .addr zone_grasslands_floor_1_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 0                     ; Added Tempo
        zone_banner_pos 0, 0        ; HudHeader
        zone_banner_pos 0, 5        ; HudBanner
        .addr hud_grasslands_pal
        .addr common_treasure_table ; ShopLootPtr
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax


zone_grasslands_floor_2:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f2 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 64                 ; SpawnPoolMax
        .byte 10                 ; PopulationLimit
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_2_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 5   ; Added Tempo
        zone_banner_pos 0, 1        ; HudHeader
        zone_banner_pos 0, 5        ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax

zone_grasslands_floor_3:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f3 ; Challenge Set
        .byte 16                 ; SpawnPoolMin
        .byte 96                 ; SpawnPoolMax
        .byte 12                 ; PopulationLimit
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_3_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 10   ; Added Tempo
        zone_banner_pos 0, 2        ; HudHeader
        zone_banner_pos 0, 5        ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax

zone_grasslands_floor_4:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f4 ; Challenge Set
        .byte 48                 ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 16                 ; PopulationLimit
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_4_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 15   ; Added Tempo
        zone_banner_pos 0, 3        ; HudHeader
        zone_banner_pos 0, 5        ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax

zone_grasslands_floor_1_exits:
        .byte 1 ; length
        .addr zone_grasslands_floor_2

zone_grasslands_floor_2_exits:
        .byte 1 ; length
        .addr zone_grasslands_floor_3

zone_grasslands_floor_3_exits:
        .byte 1 ; length
        .addr zone_grasslands_floor_4

; DEBUG: for now, just go back to the hub world
; (later we'll want a boss chamber, and a branching path)
zone_grasslands_floor_4_exits:
        .byte 1 ; length
        .addr zone_hub_world

zone_grasslands_floor_1_mazes:
        .byte 10 ; length        
        banked_addr floor_grass_small_01
        banked_addr floor_grass_small_02
        banked_addr floor_grass_small_03
        banked_addr floor_grass_small_04
        banked_addr floor_grass_small_05
        banked_addr floor_grass_small_06
        banked_addr floor_grass_small_07
        banked_addr floor_grass_small_08
        banked_addr floor_grass_small_09
        banked_addr floor_grass_small_10
        

zone_grasslands_floor_234_mazes:
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

;  ##     ## ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ######### ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ##     ##  #######  ########  

zone_hub_world:
        .addr spawn_pool_generic ; Spawn Pool (unused)
        .addr spawnset_a53_z1_f1 ; Challenge Set (unused)
        .byte 0                  ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 0                  ; PopulationLimit (do not spawn anything! it's the hub!)
        .addr zone_hub_world_mazes ; Maze Pool (TODO!!)
        .addr zone_hub_exits     ; Exit List
        .byte TRACK_IN_ANOTHER_WORLD ; Music Track
        .byte 0   ; Added Tempo
        zone_banner_pos 14, 0        ; HudHeader
        zone_banner_pos 14, 5        ; HudBanner
        .addr hud_hub_pal
        .addr common_treasure_table ; ShopLootPtr
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax

; TODO: for the real hub there is very little point in going
; to any floor other than 1, but as we only have the one zone,
; we'll use that as a standin for the actual behavior later.
zone_hub_exits:
        .byte 5
        .addr zone_hub_world ; this shouldn't generate. if it does, panic!
        .addr zone_grasslands_floor_1
        .addr zone_beach_floor_1
        .addr zone_grasslands_floor_2_but_fast
        .addr zone_grasslands_floor_2 ; for quickly demoing normal caves

zone_hub_world_mazes:
        .byte 1
        banked_addr floor_hub_world

;  ########  ########    ###     ######  ##     ## 
;  ##     ## ##         ## ##   ##    ## ##     ## 
;  ##     ## ##        ##   ##  ##       ##     ## 
;  ########  ######   ##     ## ##       ######### 
;  ##     ## ##       ######### ##       ##     ## 
;  ##     ## ##       ##     ## ##    ## ##     ## 
;  ########  ######## ##     ##  ######  ##     ## 

zone_beach_floor_1:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f1 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 32                 ; SpawnPoolMax
        .byte 8                  ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_1_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 0   ; Added Tempo
        zone_banner_pos 2, 0        ; HudHeader
        zone_banner_pos 2, 5        ; HudBanner
        .addr hud_beach_pal
        .addr common_treasure_table ; ShopLootPtr
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax

zone_beach_floor_2:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f2 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 64                 ; SpawnPoolMax
        .byte 10                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_2_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 5   ; Added Tempo
        zone_banner_pos 2, 1        ; HudHeader
        zone_banner_pos 2, 5        ; HudBanner
        .addr hud_beach_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax

zone_beach_floor_3:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f3 ; Challenge Set
        .byte 16                 ; SpawnPoolMin
        .byte 96                 ; SpawnPoolMax
        .byte 12                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_3_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 10   ; Added Tempo
        zone_banner_pos 2, 2        ; HudHeader
        zone_banner_pos 2, 5        ; HudBanner
        .addr hud_beach_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax

zone_beach_floor_4:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f4 ; Challenge Set
        .byte 48                 ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 16                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_4_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 15   ; Added Tempo
        zone_banner_pos 2, 3        ; HudHeader
        zone_banner_pos 2, 5        ; HudBanner
        .addr hud_beach_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax

zone_beach_floor_1_exits:
        .byte 1 ; length
        .addr zone_beach_floor_2

zone_beach_floor_2_exits:
        .byte 1 ; length
        .addr zone_beach_floor_3

zone_beach_floor_3_exits:
        .byte 1 ; length
        .addr zone_beach_floor_4

; DEBUG: for now, just go back to the hub world
; (later we'll want a boss chamber, and a branching path)
zone_beach_floor_4_exits:
        .byte 1 ; length
        .addr zone_hub_world

; ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒▒▓███▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░  

zone_grasslands_floor_2_but_fast:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f2 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 64                 ; SpawnPoolMax
        .byte 10                 ; PopulationLimit
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_debug_exits   ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 80   ; Added Tempo
        zone_banner_pos 14, 1       ; DebugHeader
        zone_banner_pos 14, 5       ; DebugBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table ; ShopLootPtr
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax

; After debugging one zone, return to the hub world
; (note: later to the debug world?)
zone_debug_exits:
        .byte 1 ; length
        .addr zone_hub_world

        .segment "CODE_4"

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

.proc FAR_current_zone_header_tile
DrawTile := R0
DrawAttr := R1
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::HudHeader
        lda (PlayerZonePtr), y
        sta DrawTile
        iny
        lda (PlayerZonePtr), y
        sta DrawAttr

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_current_zone_banner_tile
DrawTile := R0
DrawAttr := R1
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::HudBanner
        lda (PlayerZonePtr), y
        sta DrawTile
        iny
        lda (PlayerZonePtr), y
        sta DrawAttr

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

; note: utility function, assumes the room data is already banked in, etc
; this code is colocated with the palettes so a simple far call is all that
; is needed to operate it
.proc FAR_load_hud_palette_for_current_zone
HudPalPtr := R0
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::HudPal
        lda (PlayerZonePtr), y
        sta HudPalPtr+0
        iny
        lda (PlayerZonePtr), y
        sta HudPalPtr+1

        ldy #0
hud_bg_loop:
        perform_zpcm_inc
        lda (HudPalPtr), y
        sta HudPaletteBuffer, y
        iny
        cpy #16
        bne hud_bg_loop

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_play_music_for_current_room
        access_data_bank #<.bank(all_zones_data_page)

        ; the track number comes from the zone, of course
        ldy #ZoneDefinition::MusicTrack
        lda (PlayerZonePtr), y
        pha

        ; the track variant depends on the player's room. right now we just use
        ; the "interior" category to mean variant 1, and any other category to mean
        ; variant 0. later this might change!
        ldy PlayerRoomIndex
        lda room_properties, y
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        bne normal_variant
        ldy #TRACK_VARIANT_INTERIOR
        jmp done_picking_variant
normal_variant:
        ldy #TRACK_VARIANT_NORMAL
done_picking_variant:
        pla
        jsr play_track

        ldy #ZoneDefinition::AddedTempo
        lda (PlayerZonePtr), y
        sta tempo_adjustment

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_load_exit_pointer_from_current_zone
ExitIndex := R0
ExitListPtr := R2
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::ExitList
        lda (PlayerZonePtr), y
        sta ExitListPtr+0
        iny
        lda (PlayerZonePtr), y
        sta ExitListPtr+1

        ldy #0
        lda ExitIndex
        cmp (ExitListPtr), y ; check to see if the desire exit is in-bounds
        bcc exit_in_bounds
        lda #0
exit_in_bounds:
        ; address the exit in words
        asl
        ; skip past the length byte
        tay
        iny
        ; load it up!
        lda (ExitListPtr), y
        sta DestinationZonePtr+0
        iny
        lda (ExitListPtr), y
        sta DestinationZonePtr+1

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc