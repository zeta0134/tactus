; Placeholder 4b

zone_4b_name_str: .byte "Placeholder 4B", D_CLOSE
zone_sequence_str_4b_1: .byte "4-1", D_CLOSE
zone_sequence_str_4b_2: .byte "4-2", D_CLOSE
zone_sequence_str_4b_3: .byte "4-3", D_CLOSE
zone_sequence_str_4b_4: .byte "4-4", D_CLOSE
zone_sequence_str_4b_B: .byte "4-B", D_CLOSE

zone_4b_banner_1:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $06, $07 ; 4-1
        .byte $16, $17 ; 4-1
        .byte $A6, $A7 ;  B
        .byte $B6, $B7 ;  B
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4b_floor_1:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f1 ; General Challenge Set
        .addr spawnset_a53_z1_f1 ; Warp Challenge Set
        .byte 0                  ; InteriorSpawnPoolMin
        .byte 32                 ; InteriorSpawnPoolMax
        .byte 8                  ; InteriorPopulationLimit
        .byte 0                  ; ExteriorSpawnPoolMin
        .byte 32                 ; ExteriorSpawnPoolMax
        .byte 8                  ; ExteriorPopulationLimit
        .byte 0                  ; WarpSpawnPoolMin
        .byte 32                 ; WarpSpawnPoolMax
        .byte 8                  ; WarpPopulationLimit
        .addr zone_4b_blocking_mazes ; Maze Pool
        .addr zone_4b_floor_1_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 0   ; Added Tempo
        .word zone_4b_banner_1 ; HudBanner
        .addr hud_hub_pal
        .addr common_treasure_table     ; ShopLootPtr0
        .addr common_treasure_table     ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_4b_name_str            ; NameStr
        .word zone_sequence_str_4b_1       ; SequenceStr
        rng_index_for_zone 4, 1           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior
        .word standard_chest_structure_set_interior   ; StandardChestInteriorStructures
        .word standard_chest_structure_set_exterior   ; StandardChestExteriorStructures
        .word standard_chest_treasure_table  ; StandardChestLootTable
        .byte 8                              ; StandardChestMin
        .byte 16                             ; StandardChestMax
        .word rare_chest_structure_set_interior       ; RareChestInteriorStructures
        .word rare_chest_structure_set_exterior       ; RareChestExteriorStructures
        .word rare_chest_treasure_table      ; RareChestLootTable
        .byte 0                              ; RareChestMin
        .byte 2                              ; RareChestMax
        .word legendary_chest_structure_set_interior  ; LegendaryChestInteriorStructures
        .word legendary_chest_structure_set_exterior  ; LegendaryChestExteriorStructures
        .word legendary_chest_treasure_table ; LegendaryChestLootTable
        .byte 0                              ; LegendaryChestMin
        .byte 1                              ; LegendaryChestMax
        .byte 4                              ; ZoneIndex
        .byte 1                              ; FloorIndex

zone_4b_floor_1_exits:
        .byte 3 ; length
        banked_addr zone_4b_floor_2
        banked_addr zone_5s_floor_1 ; warp destinations
        banked_addr zone_5w_floor_1

zone_4b_banner_2:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $26, $27 ; 4-2
        .byte $36, $37 ; 4-2
        .byte $A6, $A7 ;  B
        .byte $B6, $B7 ;  B
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4b_floor_2:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f2 ; General Challenge Set
        .addr spawnset_a53_z1_f2 ; Warp Challenge Set
        .byte 0                  ; InteriorSpawnPoolMin
        .byte 64                 ; InteriorSpawnPoolMax
        .byte 10                 ; InteriorPopulationLimit
        .byte 0                  ; ExteriorSpawnPoolMin
        .byte 64                 ; ExteriorSpawnPoolMax
        .byte 10                 ; ExteriorPopulationLimit
        .byte 0                  ; WarpSpawnPoolMin
        .byte 64                 ; WarpSpawnPoolMax
        .byte 10                 ; WarpPopulationLimit
        .addr zone_4b_blocking_with_warps_mazes ; Maze Pool
        .addr zone_4b_floor_2_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 5   ; Added Tempo
        .word zone_4b_banner_2 ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_4b_name_str            ; NameStr
        .word zone_sequence_str_4b_2       ; SequenceStr
        rng_index_for_zone 4, 2           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior
        .word standard_chest_structure_set_interior   ; StandardChestInteriorStructures
        .word standard_chest_structure_set_exterior   ; StandardChestExteriorStructures
        .word standard_chest_treasure_table  ; StandardChestLootTable
        .byte 8                              ; StandardChestMin
        .byte 16                             ; StandardChestMax
        .word rare_chest_structure_set_interior       ; RareChestInteriorStructures
        .word rare_chest_structure_set_exterior       ; RareChestExteriorStructures
        .word rare_chest_treasure_table      ; RareChestLootTable
        .byte 0                              ; RareChestMin
        .byte 2                              ; RareChestMax
        .word legendary_chest_structure_set_interior  ; LegendaryChestInteriorStructures
        .word legendary_chest_structure_set_exterior  ; LegendaryChestExteriorStructures
        .word legendary_chest_treasure_table ; LegendaryChestLootTable
        .byte 0                              ; LegendaryChestMin
        .byte 1                              ; LegendaryChestMax
        .byte 4                              ; ZoneIndex
        .byte 2                              ; FloorIndex

zone_4b_floor_2_exits:
        .byte 3 ; length
        banked_addr zone_4b_floor_3
        banked_addr zone_5s_floor_1 ; warp destinations
        banked_addr zone_5w_floor_1

zone_4b_banner_3:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $46, $47 ; 4-3
        .byte $56, $57 ; 4-3
        .byte $A6, $A7 ;  B
        .byte $B6, $B7 ;  B
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4b_floor_3:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f3 ; General Challenge Set
        .addr spawnset_a53_z1_f3 ; Warp Challenge Set
        .byte 16                 ; InteriorSpawnPoolMin
        .byte 96                 ; InteriorSpawnPoolMax
        .byte 12                 ; InteriorPopulationLimit
        .byte 16                 ; ExteriorSpawnPoolMin
        .byte 96                 ; ExteriorSpawnPoolMax
        .byte 12                 ; ExteriorPopulationLimit
        .byte 16                 ; WarpSpawnPoolMin
        .byte 96                 ; WarpSpawnPoolMax
        .byte 12                 ; WarpPopulationLimit
        .addr zone_4b_blocking_with_warps_mazes ; Maze Pool
        .addr zone_4b_floor_3_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 10   ; Added Tempo
        .word zone_4b_banner_3 ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_4b_name_str            ; NameStr
        .word zone_sequence_str_4b_3       ; SequenceStr
        rng_index_for_zone 4, 3           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior
        .word standard_chest_structure_set_interior   ; StandardChestInteriorStructures
        .word standard_chest_structure_set_exterior   ; StandardChestExteriorStructures
        .word standard_chest_treasure_table  ; StandardChestLootTable
        .byte 8                              ; StandardChestMin
        .byte 16                             ; StandardChestMax
        .word rare_chest_structure_set_interior       ; RareChestInteriorStructures
        .word rare_chest_structure_set_exterior       ; RareChestExteriorStructures
        .word rare_chest_treasure_table      ; RareChestLootTable
        .byte 0                              ; RareChestMin
        .byte 2                              ; RareChestMax
        .word legendary_chest_structure_set_interior  ; LegendaryChestInteriorStructures
        .word legendary_chest_structure_set_exterior  ; LegendaryChestExteriorStructures
        .word legendary_chest_treasure_table ; LegendaryChestLootTable
        .byte 0                              ; LegendaryChestMin
        .byte 1                              ; LegendaryChestMax
        .byte 4                              ; ZoneIndex
        .byte 3                              ; FloorIndex

zone_4b_floor_3_exits:
        .byte 3 ; length
        banked_addr zone_4b_floor_4
        banked_addr zone_5s_floor_1 ; warp destinations
        banked_addr zone_5w_floor_1

zone_4b_banner_4:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $66, $67 ; 4-4
        .byte $76, $77 ; 4-4
        .byte $A6, $A7 ;  B
        .byte $B6, $B7 ;  B
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4b_floor_4:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f4 ; General Challenge Set
        .addr spawnset_a53_z1_f4 ; Warp Challenge Set
        .byte 48                 ; InteriorSpawnPoolMin
        .byte 128                ; InteriorSpawnPoolMax
        .byte 16                 ; InteriorPopulationLimit
        .byte 48                 ; ExteriorSpawnPoolMin
        .byte 128                ; ExteriorSpawnPoolMax
        .byte 16                 ; ExteriorPopulationLimit
        .byte 48                 ; WarpSpawnPoolMin
        .byte 128                ; WarpSpawnPoolMax
        .byte 16                 ; WarpPopulationLimit
        .addr zone_4b_blocking_with_warps_mazes ; Maze Pool
        .addr zone_4b_floor_4_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 15   ; Added Tempo
        .word zone_4b_banner_4 ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_4b_name_str            ; NameStr
        .word zone_sequence_str_4b_4       ; SequenceStr
        rng_index_for_zone 4, 4           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior
        .word standard_chest_structure_set_interior   ; StandardChestInteriorStructures
        .word standard_chest_structure_set_exterior   ; StandardChestExteriorStructures
        .word standard_chest_treasure_table  ; StandardChestLootTable
        .byte 8                              ; StandardChestMin
        .byte 16                             ; StandardChestMax
        .word rare_chest_structure_set_interior       ; RareChestInteriorStructures
        .word rare_chest_structure_set_exterior       ; RareChestExteriorStructures
        .word rare_chest_treasure_table      ; RareChestLootTable
        .byte 0                              ; RareChestMin
        .byte 2                              ; RareChestMax
        .word legendary_chest_structure_set_interior  ; LegendaryChestInteriorStructures
        .word legendary_chest_structure_set_exterior  ; LegendaryChestExteriorStructures
        .word legendary_chest_treasure_table ; LegendaryChestLootTable
        .byte 0                              ; LegendaryChestMin
        .byte 1                              ; LegendaryChestMax
        .byte 4                              ; ZoneIndex
        .byte 4                              ; FloorIndex

; DEBUG: for now, just go back to the hub world
; (later we'll want a boss chamber, and a branching path)
zone_4b_floor_4_exits:
        .byte 3 ; length
        banked_addr zone_4b_floor_boss
        banked_addr zone_5s_floor_1 ; warp destinations
        banked_addr zone_5w_floor_1

zone_4b_banner_boss:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $86, $87 ; 4-B
        .byte $96, $97 ; 4-B
        .byte $A6, $A7 ;  B
        .byte $B6, $B7 ;  B
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4b_floor_boss:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f4 ; General Challenge Set
        .addr spawnset_a53_z1_f4 ; Warp Challenge Set
        .byte 0                  ; InteriorSpawnPoolMin
        .byte 128                ; InteriorSpawnPoolMax
        .byte 0                  ; InteriorPopulationLimit
        .byte 0                  ; ExteriorSpawnPoolMin
        .byte 128                ; ExteriorSpawnPoolMax
        .byte 0                  ; ExteriorPopulationLimit
        .byte 0                  ; WarpSpawnPoolMin
        .byte 128                ; WarpSpawnPoolMax
        .byte 0                  ; WarpPopulationLimit
        .addr zone_4b_floor_boss_mazes ; Maze Pool
        .addr zone_4b_floor_boss_exits ; Exit List
        .byte TRACK_SILENCE      ; Music Track
        .byte 0                  ; Added Tempo
        .word zone_4b_banner_boss ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table       ; ShopLootPtr0 (unused?)
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr empty_structure_set ;InteriorStructureLargeSet
        .byte 0                   ;InteriorStructureLargeMaxMax
        .addr empty_structure_set ;InteriorStructureSmallSet
        .byte 0                   ;InteriorStructureSmallMaxMax
        .addr empty_structure_set ;ExteriorStructureLargeSet
        .byte 0                   ;ExteriorStructureLargeMaxMax
        .addr empty_structure_set ;ExteriorStructureSmallSet
        .byte 0                   ;ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_4b_name_str            ; NameStr
        .word zone_sequence_str_4b_B       ; SequenceStr
        rng_index_for_zone 4, 5           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior
        .word empty_structure_set            ; StandardChestInteriorStructures
        .word empty_structure_set            ; StandardChestExteriorStructures
        .word standard_chest_treasure_table  ; StandardChestLootTable
        .byte 0                              ; StandardChestMin
        .byte 0                              ; StandardChestMax
        .word empty_structure_set            ; RareChestInteriorStructures
        .word empty_structure_set            ; RareChestExteriorStructures
        .word rare_chest_treasure_table      ; RareChestLootTable
        .byte 0                              ; RareChestMin
        .byte 0                              ; RareChestMax
        .word empty_structure_set            ; LegendaryChestInteriorStructures
        .word empty_structure_set            ; LegendaryChestExteriorStructures
        .word legendary_chest_treasure_table ; LegendaryChestLootTable
        .byte 0                              ; LegendaryChestMin
        .byte 0                              ; LegendaryChestMax
        .byte 4                              ; ZoneIndex
        .byte 5                              ; FloorIndex

zone_4b_blocking_mazes:
        .byte 4 ; length        
        banked_addr floor_blocking_01
        banked_addr floor_blocking_02
        banked_addr floor_blocking_03
        banked_addr floor_blocking_04

zone_4b_blocking_with_warps_mazes:
        .byte 4 ; length        
        banked_addr floor_blocking_01_warp
        banked_addr floor_blocking_02_warp
        banked_addr floor_blocking_03_warp
        banked_addr floor_blocking_04_warp

zone_4b_floor_boss_exits:
        .byte 1 ; length
        banked_addr zone_5s_floor_1

zone_4b_floor_boss_mazes:
        .byte 1 ; Length
        banked_addr floor_zone_4b_boss

