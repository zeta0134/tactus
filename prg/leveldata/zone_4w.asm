; Placeholder 4w

zone_4w_banner_1:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $06, $07 ; 4-1
        .byte $16, $17 ; 4-1
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4w_floor_1:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f1 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 32                 ; SpawnPoolMax
        .byte 8                  ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_4w_floor_1_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 0   ; Added Tempo
        .word zone_4w_banner_1 ; HudBanner
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

zone_4w_floor_1_exits:
        .byte 3 ; length
        .addr zone_4w_floor_2
        .addr zone_5s_floor_1 ; warp destinations
        .addr zone_5w_floor_1

zone_4w_banner_2:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $26, $27 ; 4-2
        .byte $36, $37 ; 4-2
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4w_floor_2:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f2 ; Challenge Set
        .byte 0                  ; SpawnPoolMin
        .byte 64                 ; SpawnPoolMax
        .byte 10                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_4w_floor_2_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 5   ; Added Tempo
        .word zone_4w_banner_2 ; HudBanner
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

zone_4w_floor_2_exits:
        .byte 3 ; length
        .addr zone_4w_floor_3
        .addr zone_5s_floor_1 ; warp destinations
        .addr zone_5w_floor_1

zone_4w_banner_3:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $46, $47 ; 4-3
        .byte $56, $57 ; 4-3
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4w_floor_3:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f3 ; Challenge Set
        .byte 16                 ; SpawnPoolMin
        .byte 96                 ; SpawnPoolMax
        .byte 12                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_4w_floor_3_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 10   ; Added Tempo
        .word zone_4w_banner_3 ; HudBanner
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

zone_4w_floor_3_exits:
        .byte 3 ; length
        .addr zone_4w_floor_4
        .addr zone_5s_floor_1 ; warp destinations
        .addr zone_5w_floor_1

zone_4w_banner_4:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $66, $67 ; 4-4
        .byte $76, $77 ; 4-4
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4w_floor_4:
        .addr spawn_pool_generic ; Spawn Pool
        .addr spawnset_a53_z1_f4 ; Challenge Set
        .byte 48                 ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 16                 ; PopulationLimit
        .addr zone_blocking_mazes ; Maze Pool
        .addr zone_4w_floor_4_exits ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 15   ; Added Tempo
        .word zone_4w_banner_4 ; HudBanner
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

; DEBUG: for now, just go back to the hub world
; (later we'll want a boss chamber, and a branching path)
zone_4w_floor_4_exits:
        .byte 3 ; length
        .addr zone_4w_floor_boss
        .addr zone_5s_floor_1 ; warp destinations
        .addr zone_5w_floor_1

zone_4w_banner_boss:
        hud_banner_sprite SPRITE_000_BLANK_NOTHING, SPRITE_000_BLANK_NOTHING
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $86, $87 ; 4-B
        .byte $96, $97 ; 4-B
        .byte $AC, $AD ;  W
        .byte $BC, $BD ;  W
        ; 8x8 bg attributes
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ZONES), (HUD_YELLOW_PAL | CHR_BANK_ZONES)

zone_4w_floor_boss:
        .addr spawn_pool_generic ; Spawn Pool (unused)
        .addr spawnset_a53_z1_f4 ; Challenge Set (unused)
        .byte 0                  ; SpawnPoolMin
        .byte 128                ; SpawnPoolMax
        .byte 0                  ; PopulationLimit (the boss chamber will already have what it needs)
        .addr zone_4w_floor_boss_mazes ; Maze Pool
        .addr zone_4w_floor_boss_exits ; Exit List
        .byte TRACK_SILENCE      ; Music Track
        .byte 0                  ; Added Tempo
        .word zone_4w_banner_boss ; HudBanner
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

zone_4w_floor_boss_exits:
        .byte 1 ; length
        .addr zone_5s_floor_1

zone_4w_floor_boss_mazes:
        .byte 1 ; Length
        banked_addr floor_zone_4w_boss
