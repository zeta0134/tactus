;  ##     ## ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ######### ##     ## ########  
;  ##     ## ##     ## ##     ## 
;  ##     ## ##     ## ##     ## 
;  ##     ##  #######  ########  

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
        .addr spawn_pool_generic   ; Spawn Pool (unused)
        .addr spawnset_a53_z1_f1   ; Challenge Set (unused)
        .byte 0                    ; SpawnPoolMin
        .byte 128                  ; SpawnPoolMax
        .byte 0                    ; PopulationLimit (do not spawn anything! it's the hub!)
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

; TODO: for the real hub there is very little point in going
; to any floor other than 1, but as we only have the one zone,
; we'll use that as a standin for the actual behavior later.
zone_hub_exits:
        .byte 79
        .addr zone_grasslands_floor_1 ; for now, use this to "start a normal run" ish
        ; Debug Zone Exits follow

        ; Debug 1:
        ; Zone 1
        .addr zone_grasslands_floor_1
        .addr zone_grasslands_floor_2
        .addr zone_grasslands_floor_3
        .addr zone_grasslands_floor_4
        .addr zone_grasslands_floor_boss

        ; Debug 2:
        ; Zone 2A
        .addr zone_2a_floor_1
        .addr zone_2a_floor_2
        .addr zone_2a_floor_3
        .addr zone_2a_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 2B
        .addr zone_2b_floor_1
        .addr zone_2b_floor_2
        .addr zone_2b_floor_3
        .addr zone_2b_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 2C:
        .addr zone_2c_floor_1
        .addr zone_2c_floor_2
        .addr zone_2c_floor_3
        .addr zone_2c_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 2W:
        .addr zone_2w_floor_1
        .addr zone_2w_floor_2
        .addr zone_2w_floor_3
        .addr zone_2w_floor_4
        .addr zone_hub_world          ; unimplemented! :(

        ; Debug 3:
        ; Zone 3A
        .addr zone_3a_floor_1
        .addr zone_3a_floor_2
        .addr zone_3a_floor_3
        .addr zone_3a_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 3B
        .addr zone_3b_floor_1
        .addr zone_3b_floor_2
        .addr zone_3b_floor_3
        .addr zone_3b_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 3C:
        .addr zone_3c_floor_1
        .addr zone_3c_floor_2
        .addr zone_3c_floor_3
        .addr zone_3c_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 3W:
        .addr zone_3w_floor_1
        .addr zone_3w_floor_2
        .addr zone_3w_floor_3
        .addr zone_3w_floor_4
        .addr zone_hub_world          ; unimplemented! :(

        ; Debug 4:
        ; Zone 4A
        .addr zone_4a_floor_1
        .addr zone_4a_floor_2
        .addr zone_4a_floor_3
        .addr zone_4a_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 4B
        .addr zone_4b_floor_1
        .addr zone_4b_floor_2
        .addr zone_4b_floor_3
        .addr zone_4b_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 4C:
        .addr zone_4c_floor_1
        .addr zone_4c_floor_2
        .addr zone_4c_floor_3
        .addr zone_4c_floor_4
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 4W:
        .addr zone_4w_floor_1
        .addr zone_4w_floor_2
        .addr zone_4w_floor_3
        .addr zone_4w_floor_4
        .addr zone_hub_world          ; unimplemented! :(

        ; Debug 5:
        ; Zone 5S (normal run final challenge / boss)
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        ; Zone 5W (warp exclusive final challenge / boss)
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(
        .addr zone_hub_world          ; unimplemented! :(

        ; Debug Miscellaneous
        .addr zone_grasslands_floor_2_but_fast
        .addr zone_hub_world ; reserved for future use
        .addr zone_hub_world ; reserved for future use

zone_hub_world_mazes:
        .byte 1
        banked_addr floor_hub_world