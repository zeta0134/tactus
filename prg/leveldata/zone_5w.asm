; Placeholder 5w

zone_5w_name_str: .asciiz "Placeholder 5W"

zone_5w_banner_1:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $08, $09 ; 5-1
        .byte $18, $19 ; 5-1
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_5w_floor_1:
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
        .addr zone_5w_blocking_mazes ; Maze Pool
        .addr zone_5w_floor_1_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 0   ; Added Tempo
        .word zone_5w_banner_1 ; HudBanner
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
        .word zone_5w_name_str            ; NameStr
        .word zone_sequence_str_5_1       ; SequenceStr
        rng_index_for_zone 5, 1           ; RngIndex
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
        .byte 5                              ; ZoneIndex
        .byte 1                              ; FloorIndex

zone_5w_floor_1_exits:
        .byte 1 ; length
        banked_addr zone_5w_floor_boss

zone_5w_banner_boss:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $88, $89 ; 5-B
        .byte $98, $99 ; 5-B
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_5w_floor_boss:
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
        .addr zone_5w_floor_boss_mazes ; Maze Pool
        .addr zone_5w_floor_boss_exits ; Exit List
        .byte TRACK_SILENCE      ; Music Track
        .byte 0                  ; Added Tempo
        .word zone_5w_banner_boss ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table         ; ShopLootPtr0 (unused?)
        .addr rare_treasure_table         ; ShopLootPtr1
        .addr common_treasure_table       ; ShopLootPtr2
        .addr consumable_treasure_table   ; ShopLootPtr3
        .addr empty_structure_set         ; InteriorStructureLargeSet
        .byte 0                           ; InteriorStructureLargeMaxMax
        .addr empty_structure_set         ; InteriorStructureSmallSet
        .byte 0                           ; InteriorStructureSmallMaxMax
        .addr empty_structure_set         ; ExteriorStructureLargeSet
        .byte 0                           ; ExteriorStructureLargeMaxMax
        .addr empty_structure_set         ; ExteriorStructureSmallSet
        .byte 0                           ; ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ; InteriorStructureWarpSet
        .addr blocking_warp_structure_set ; ExteriorStructureWarpSet
        .word zone_5w_name_str            ; NameStr
        .word zone_sequence_str_5_F       ; SequenceStr
        rng_index_for_zone 5, 2           ; RngIndex
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
        .byte 5                              ; ZoneIndex
        .byte 2                              ; FloorIndex

zone_5w_blocking_mazes:
        .byte 4 ; length        
        banked_addr floor_blocking_01
        banked_addr floor_blocking_02
        banked_addr floor_blocking_03
        banked_addr floor_blocking_04

; Unclear yet if these will be used. We may not ever spawn stairs, rather we'll
; probably trigger the game cleared / victory kernel state on success.
zone_5w_floor_boss_exits:
        .byte 1 ; length
        banked_addr zone_hub_world

zone_5w_floor_boss_mazes:
        .byte 1 ; Length
        banked_addr floor_zone_5w_final_boss
