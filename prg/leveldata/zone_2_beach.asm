;  ########  ########    ###     ######  ##     ## 
;  ##     ## ##         ## ##   ##    ## ##     ## 
;  ##     ## ##        ##   ##  ##       ##     ## 
;  ########  ######   ##     ## ##       ######### 
;  ##     ## ##       ######### ##       ##     ## 
;  ##     ## ##       ##     ## ##    ## ##     ## 
;  ########  ######## ##     ##  ######  ##     ## 

zone_beach_banner_2_1:
        hud_banner_sprite SPRITE_BANNERS_01_BEACH_2_1, SPRITE_BANNERS_01_BEACH_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $02, $03
        .byte $12, $13
        .byte $A2, $A3
        .byte $B2, $B3
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_beach_banner_2_2:
        hud_banner_sprite SPRITE_BANNERS_01_BEACH_2_2, SPRITE_BANNERS_01_BEACH_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $22, $23
        .byte $32, $33
        .byte $A2, $A3
        .byte $B2, $B3
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_beach_banner_2_3:
        hud_banner_sprite SPRITE_BANNERS_01_BEACH_2_3, SPRITE_BANNERS_01_BEACH_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $42, $43
        .byte $52, $53
        .byte $A2, $A3
        .byte $B2, $B3
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_beach_banner_2_4:
        hud_banner_sprite SPRITE_BANNERS_01_BEACH_2_4, SPRITE_BANNERS_01_BEACH_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $62, $63
        .byte $72, $73
        .byte $A2, $A3
        .byte $B2, $B3
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_beach_banner_boss:
        hud_banner_sprite SPRITE_BANNERS_01_BEACH_BOSS, SPRITE_BANNERS_01_BEACH_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $82, $83
        .byte $92, $93
        .byte $A2, $A3
        .byte $B2, $B3
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_beach_floor_1:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f1 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 32                 ; SpawnPoolMax
        .byte 8                  ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_1_exits ; Exit List
        .byte TRACK_ECHOES   ; Music Track
        .byte 0   ; Added Tempo
        .word zone_beach_banner_2_1 ; HudBanner
        .addr hud_beach_pal
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

zone_beach_floor_2:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f2 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 64                 ; SpawnPoolMax
        .byte 10                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_2_exits ; Exit List
        .byte TRACK_ECHOES   ; Music Track
        .byte 5   ; Added Tempo
        .word zone_beach_banner_2_2 ; HudBanner
        .addr hud_beach_pal
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

zone_beach_floor_3:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f3 ; Challenge Set
        .byte 16                 ; SpawnPoolMin
        .byte 96                 ; SpawnPoolMax
        .byte 12                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_3_exits ; Exit List
        .byte TRACK_ECHOES   ; Music Track
        .byte 10   ; Added Tempo
        .word zone_beach_banner_2_3 ; HudBanner
        .addr hud_beach_pal
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

zone_beach_floor_4:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f4 ; Challenge Set
        .byte 48                 ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 16                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_beach_floor_4_exits ; Exit List
        .byte TRACK_ECHOES   ; Music Track
        .byte 15   ; Added Tempo
        .word zone_beach_banner_2_4 ; HudBanner
        .addr hud_beach_pal
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