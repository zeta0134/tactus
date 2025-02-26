;    ######   ########     ###     ######   ######  ##          ###    ##    ## ########   ######  
;   ##    ##  ##     ##   ## ##   ##    ## ##    ## ##         ## ##   ###   ## ##     ## ##    ## 
;   ##        ##     ##  ##   ##  ##       ##       ##        ##   ##  ####  ## ##     ## ##       
;   ##   #### ########  ##     ##  ######   ######  ##       ##     ## ## ## ## ##     ##  ######  
;   ##    ##  ##   ##   #########       ##       ## ##       ######### ##  #### ##     ##       ## 
;   ##    ##  ##    ##  ##     ## ##    ## ##    ## ##       ##     ## ##   ### ##     ## ##    ## 
;    ######   ##     ## ##     ##  ######   ######  ######## ##     ## ##    ## ########   ######  

zone_1_name_str: .asciiz "Grasslands"

zone_grasslands_banner_1_1:
        hud_banner_sprite SPRITE_BANNERS_00_GRASSLANDS_1_1, SPRITE_BANNERS_00_GRASSLANDS_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $00, $01
        .byte $10, $11
        .byte $A0, $A1
        .byte $B0, $B1
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_grasslands_banner_1_2:
        hud_banner_sprite SPRITE_BANNERS_00_GRASSLANDS_1_2, SPRITE_BANNERS_00_GRASSLANDS_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $20, $21
        .byte $30, $31
        .byte $A0, $A1
        .byte $B0, $B1
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_grasslands_banner_1_3:
        hud_banner_sprite SPRITE_BANNERS_00_GRASSLANDS_1_3, SPRITE_BANNERS_00_GRASSLANDS_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $40, $41
        .byte $50, $51
        .byte $A0, $A1
        .byte $B0, $B1
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_grasslands_banner_1_4:
        hud_banner_sprite SPRITE_BANNERS_00_GRASSLANDS_1_4, SPRITE_BANNERS_00_GRASSLANDS_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $60, $61
        .byte $70, $71
        .byte $A0, $A1
        .byte $B0, $B1
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_grasslands_banner_boss:
        hud_banner_sprite SPRITE_BANNERS_00_GRASSLANDS_BOSS, SPRITE_BANNERS_00_GRASSLANDS_LOWER
        ; 8x16 sprite attributes
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        .byte SPRITE_PAL_ZONE, SPRITE_PAL_ZONE
        ; 8x8 bg tiles
        .byte $80, $81
        .byte $90, $91
        .byte $A0, $A1
        .byte $B0, $B1
        ; 8x8 bg attributes
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ZONES), (HUD_PURPLE_PAL | CHR_BANK_ZONES)

zone_grasslands_floor_1:
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
        .addr zone_grasslands_floor_1_mazes ; Maze Pool
        .addr zone_grasslands_floor_1_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 0                     ; Added Tempo
        .word zone_grasslands_banner_1_1 ; HudBanner
        .addr hud_grasslands_pal
        .addr common_treasure_table     ; ShopLootPtr0
        .addr common_treasure_table     ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr test_structure_set_big    ;InteriorStructureLargeSet
        .byte 1                         ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small  ;InteriorStructureSmallSet
        .byte 1                         ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big    ;ExteriorStructureLargeSet
        .byte 1                         ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small  ;ExteriorStructureSmallSet
        .byte 3                         ;ExteriorStructureSmallMaxMax
        .addr cave_warp_structure_set   ;InteriorStructureWarpSet
        .addr grassy_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_1_name_str             ; NameStr
        .word zone_sequence_str_1_1       ; SequenceStr
        rng_index_for_zone 1, 1           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior


zone_grasslands_floor_2:
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
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_2_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 5   ; Added Tempo
        .word zone_grasslands_banner_1_2 ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax
        .addr cave_warp_structure_set   ;InteriorStructureWarpSet
        .addr grassy_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_1_name_str             ; NameStr
        .word zone_sequence_str_1_2       ; SequenceStr
        rng_index_for_zone 1, 2           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior

zone_grasslands_floor_3:
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
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_3_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 10   ; Added Tempo
        .word zone_grasslands_banner_1_3 ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax
        .addr cave_warp_structure_set   ;InteriorStructureWarpSet
        .addr grassy_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_1_name_str             ; NameStr
        .word zone_sequence_str_1_3       ; SequenceStr
        rng_index_for_zone 1, 3           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior

zone_grasslands_floor_4:
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
        .addr zone_grasslands_floor_234_mazes ; Maze Pool
        .addr zone_grasslands_floor_4_exits ; Exit List
        .byte TRACK_BOUNCY          ; Music Track
        .byte 15   ; Added Tempo
        .word zone_grasslands_banner_1_4 ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table       ; ShopLootPtr0
        .addr rare_treasure_table       ; ShopLootPtr1
        .addr common_treasure_table     ; ShopLootPtr2
        .addr consumable_treasure_table ; ShopLootPtr3
        .addr test_structure_set_big   ;InteriorStructureLargeSet
        .byte 1                        ;InteriorStructureLargeMaxMax
        .addr test_structure_set_small ;InteriorStructureSmallSet
        .byte 1                        ;InteriorStructureSmallMaxMax
        .addr test_structure_set_big   ;ExteriorStructureLargeSet
        .byte 1                        ;ExteriorStructureLargeMaxMax
        .addr test_structure_set_small ;ExteriorStructureSmallSet
        .byte 3                        ;ExteriorStructureSmallMaxMax
        .addr cave_warp_structure_set   ;InteriorStructureWarpSet
        .addr grassy_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_1_name_str             ; NameStr
        .word zone_sequence_str_1_4       ; SequenceStr
        rng_index_for_zone 1, 4           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior

zone_grasslands_floor_boss:
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
        .addr zone_grasslands_floor_boss_mazes ; Maze Pool
        .addr zone_grasslands_floor_boss_exits ; Exit List
        .byte TRACK_SILENCE      ; Music Track
        .byte 0                  ; Added Tempo
        .word zone_grasslands_banner_boss ; HudBanner
        .addr hud_grasslands_pal
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
        .addr cave_warp_structure_set   ;InteriorStructureWarpSet (unused)
        .addr grassy_warp_structure_set ;ExteriorStructureWarpSet
        .word zone_1_name_str             ; NameStr
        .word zone_sequence_str_1_B       ; SequenceStr
        rng_index_for_zone 1, 5           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior

zone_grasslands_floor_1_exits:
        .byte 5 ; length
        .addr zone_grasslands_floor_2
        .addr zone_2a_floor_1 ; warp destinations
        .addr zone_2b_floor_1
        .addr zone_2c_floor_1
        .addr zone_2w_floor_1

zone_grasslands_floor_2_exits:
        .byte 5 ; length
        .addr zone_grasslands_floor_3
        .addr zone_2a_floor_1 ; warp destinations
        .addr zone_2b_floor_1
        .addr zone_2c_floor_1
        .addr zone_2w_floor_1

zone_grasslands_floor_3_exits:
        .byte 5 ; length
        .addr zone_grasslands_floor_4
        .addr zone_2a_floor_1 ; warp destinations
        .addr zone_2b_floor_1
        .addr zone_2c_floor_1
        .addr zone_2w_floor_1

zone_grasslands_floor_4_exits:
        .byte 5 ; length
        .addr zone_grasslands_floor_boss
        .addr zone_2a_floor_1 ; warp destinations
        .addr zone_2b_floor_1
        .addr zone_2c_floor_1
        .addr zone_2w_floor_1

zone_grasslands_floor_boss_exits:
        .byte 3 ; length
        .addr zone_2a_floor_1
        .addr zone_2b_floor_1
        .addr zone_2c_floor_1

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

zone_grasslands_floor_boss_mazes:
        .byte 1 ; Length
        banked_addr floor_zone_1_boss