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
        .addr zone_blocking_mazes ; Maze Pool
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

zone_5w_floor_1_exits:
        .byte 1 ; length
        .addr zone_5w_floor_boss

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

; Unclear yet if these will be used. We may not ever spawn stairs, rather we'll
; probably trigger the game cleared / victory kernel state on success.
zone_5w_floor_boss_exits:
        .byte 1 ; length
        .addr zone_hub_world

zone_5w_floor_boss_mazes:
        .byte 1 ; Length
        banked_addr floor_zone_5w_final_boss
