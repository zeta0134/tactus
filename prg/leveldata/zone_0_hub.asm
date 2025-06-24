;  ##     ## ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ######### ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ##     ##  #######  ########  

zone_hub_name_str: .asciiz "Home"
zone_hub_sequence_str: .asciiz "HUB"

zone_hub_banner:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_BANNERS_00_HUD_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $0E, $0F
        .byte $1E, $1F
        .byte $AE, $AF
        .byte $BE, $BF
        ; 8x8 bg attributes
        .byte (HUD_RED_PAL | CHR_BANK_ZONES), (HUD_RED_PAL | CHR_BANK_ZONES)
        .byte (HUD_RED_PAL | CHR_BANK_ZONES), (HUD_RED_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_hub_world:
        .addr spawn_pool_generic   ; Interior Spawn Pool
        .addr spawn_pool_generic   ; Exterior Spawn Pool
        .addr spawn_pool_generic   ; Warp Spawn Pool
        .addr spawnset_a53_z1_f1   ; General Challenge Set (unused)
        .addr spawnset_a53_z1_f1   ; Warp Challenge Set (unused)
        .byte 0                    ; InteriorSpawnPoolMin
        .byte 128                  ; InteriorSpawnPoolMax
        .byte 0                    ; InteriorPopulationLimit
        .byte 0                    ; ExteriorSpawnPoolMin
        .byte 128                  ; ExteriorSpawnPoolMax
        .byte 0                    ; ExteriorPopulationLimit
        .byte 0                    ; WarpSpawnPoolMin
        .byte 128                  ; WarpSpawnPoolMax
        .byte 0                    ; WarpPopulationLimit
        .addr zone_hub_world_mazes ; Maze Pool (TODO!!)
        .addr zone_hub_exits       ; Exit List
        .byte TRACK_OPTIONS        ; Music Track
        .byte 0   ; Added Tempo
        .word zone_hub_banner ; HudBanner
        .addr hud_hub_pal
        .addr rare_treasure_table       ; ShopLootPtr0 (unused)
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
        .word zone_hub_name_str           ; NameStr
        .word zone_hub_sequence_str       ; SequenceStr
        rng_index_for_zone 1, 1           ; RngIndex
        .byte ZONE_ONLOAD_HUB             ; OnLoadBehavior
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
        .byte 0                              ; ZoneIndex
        .byte 0                              ; FloorIndex

; TODO: for the real hub there is very little point in going
; to any floor other than 1, but as we only have the one zone,
; we'll use that as a standin for the actual behavior later.
zone_hub_exits:
        .byte 79
        banked_addr zone_grasslands_floor_1 ; for now, use this to "start a normal run" ish
        ; Debug Zone Exits follow

        ; Debug 1:
        ; Zone 1
        banked_addr zone_grasslands_floor_1
        banked_addr zone_grasslands_floor_2
        banked_addr zone_grasslands_floor_3
        banked_addr zone_grasslands_floor_4
        banked_addr zone_grasslands_floor_boss

        ; Debug 2:
        ; Zone 2A
        banked_addr zone_2a_floor_1
        banked_addr zone_2a_floor_2
        banked_addr zone_2a_floor_3
        banked_addr zone_2a_floor_4
        banked_addr zone_2a_floor_boss
        ; Zone 2B
        banked_addr zone_2b_floor_1
        banked_addr zone_2b_floor_2
        banked_addr zone_2b_floor_3
        banked_addr zone_2b_floor_4
        banked_addr zone_2b_floor_boss
        ; Zone 2C:
        banked_addr zone_2c_floor_1
        banked_addr zone_2c_floor_2
        banked_addr zone_2c_floor_3
        banked_addr zone_2c_floor_4
        banked_addr zone_2c_floor_boss
        ; Zone 2W:
        banked_addr zone_2w_floor_1
        banked_addr zone_2w_floor_2
        banked_addr zone_2w_floor_3
        banked_addr zone_2w_floor_4
        banked_addr zone_2w_floor_boss

        ; Debug 3:
        ; Zone 3A
        banked_addr zone_3a_floor_1
        banked_addr zone_3a_floor_2
        banked_addr zone_3a_floor_3
        banked_addr zone_3a_floor_4
        banked_addr zone_3a_floor_boss
        ; Zone 3B
        banked_addr zone_3b_floor_1
        banked_addr zone_3b_floor_2
        banked_addr zone_3b_floor_3
        banked_addr zone_3b_floor_4
        banked_addr zone_3b_floor_boss
        ; Zone 3C:
        banked_addr zone_3c_floor_1
        banked_addr zone_3c_floor_2
        banked_addr zone_3c_floor_3
        banked_addr zone_3c_floor_4
        banked_addr zone_3c_floor_boss
        ; Zone 3W:
        banked_addr zone_3w_floor_1
        banked_addr zone_3w_floor_2
        banked_addr zone_3w_floor_3
        banked_addr zone_3w_floor_4
        banked_addr zone_3w_floor_boss

        ; Debug 4:
        ; Zone 4A
        banked_addr zone_4a_floor_1
        banked_addr zone_4a_floor_2
        banked_addr zone_4a_floor_3
        banked_addr zone_4a_floor_4
        banked_addr zone_4a_floor_boss
        ; Zone 4B
        banked_addr zone_4b_floor_1
        banked_addr zone_4b_floor_2
        banked_addr zone_4b_floor_3
        banked_addr zone_4b_floor_4
        banked_addr zone_4b_floor_boss
        ; Zone 4C:
        banked_addr zone_4c_floor_1
        banked_addr zone_4c_floor_2
        banked_addr zone_4c_floor_3
        banked_addr zone_4c_floor_4
        banked_addr zone_4c_floor_boss
        ; Zone 4W:
        banked_addr zone_4w_floor_1
        banked_addr zone_4w_floor_2
        banked_addr zone_4w_floor_3
        banked_addr zone_4w_floor_4
        banked_addr zone_4w_floor_boss

        ; Debug 5:
        ; Zone 5S (normal run final challenge / boss)
        banked_addr zone_5s_floor_1          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_5s_floor_boss          ; unimplemented! :(
        ; Zone 5W (warp exclusive final challenge / boss)
        banked_addr zone_5w_floor_1          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_hub_world          ; unimplemented! :(
        banked_addr zone_5w_floor_boss          ; unimplemented! :(

        ; Debug Miscellaneous
        banked_addr zone_debug_1
        banked_addr zone_hub_world ; reserved for future use
        banked_addr zone_hub_world ; reserved for future use

zone_hub_world_mazes:
        .byte 1
        banked_addr floor_hub_world