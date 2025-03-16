; proper organization eventually; let me get the skeleton of this 
; mess written before I commit to subfolders
        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "slowam.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "LEVEL_DATA_MAZE_LAYOUTS_0"

        .include "../build/floors/blocking_01.incs"
        .include "../build/floors/blocking_02.incs"
        .include "../build/floors/blocking_03.incs"
        .include "../build/floors/blocking_04.incs"

        .include "../build/floors/zone_1_boss.incs"
        .include "../build/floors/zone_2a_boss.incs"
        .include "../build/floors/zone_2b_boss.incs"
        .include "../build/floors/zone_2c_boss.incs"
        .include "../build/floors/zone_2w_boss.incs"
        .include "../build/floors/zone_3a_boss.incs"
        .include "../build/floors/zone_3b_boss.incs"
        .include "../build/floors/zone_3c_boss.incs"
        .include "../build/floors/zone_3w_boss.incs"
        .include "../build/floors/zone_4a_boss.incs"
        .include "../build/floors/zone_4b_boss.incs"
        .include "../build/floors/zone_4c_boss.incs"
        .include "../build/floors/zone_4w_boss.incs"
        .include "../build/floors/zone_5s_final_boss.incs"
        .include "../build/floors/zone_5w_final_boss.incs"

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

        .include "../build/floors/blocking_01_warp.incs"
        .include "../build/floors/blocking_02_warp.incs"
        .include "../build/floors/blocking_03_warp.incs"
        .include "../build/floors/blocking_04_warp.incs"

        .segment "LEVEL_DATA_ZONE_DEFS"

zone_sequence_str_1_1: .asciiz "1-1"
zone_sequence_str_1_2: .asciiz "1-2"
zone_sequence_str_1_3: .asciiz "1-3"
zone_sequence_str_1_4: .asciiz "1-4"
zone_sequence_str_1_B: .asciiz "1-B"

zone_sequence_str_2_1: .asciiz "2-1"
zone_sequence_str_2_2: .asciiz "2-2"
zone_sequence_str_2_3: .asciiz "2-3"
zone_sequence_str_2_4: .asciiz "2-4"
zone_sequence_str_2_B: .asciiz "2-B"

zone_sequence_str_3_1: .asciiz "3-1"
zone_sequence_str_3_2: .asciiz "3-2"
zone_sequence_str_3_3: .asciiz "3-3"
zone_sequence_str_3_4: .asciiz "3-4"
zone_sequence_str_3_B: .asciiz "3-B"

zone_sequence_str_4_1: .asciiz "4-1"
zone_sequence_str_4_2: .asciiz "4-2"
zone_sequence_str_4_3: .asciiz "4-3"
zone_sequence_str_4_4: .asciiz "4-4"
zone_sequence_str_4_B: .asciiz "4-B"

zone_sequence_str_5_1: .asciiz "5-1"
zone_sequence_str_5_F: .asciiz "5-F"

zone_name_str_debug: .asciiz "Debug"
zone_sequence_str_debug: .asciiz "DBG"

hud_base_pal:
        .incbin "../art/hud_base.pal"

hud_grasslands_pal:
        .incbin "../art/zone_1_banner.pal"

hud_beach_pal:
        .incbin "../art/zone_2_banner.pal"

hud_hub_pal:
        .incbin "../art/zone_hub_banner.pal"

.macro zone_banner_pos tile_x, tile_y
        .byte ((tile_y*16)+tile_x)
        .byte (HUD_TEXT_PAL | CHR_BANK_ZONES)
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

zone_blocking_with_warps_mazes:
        .byte 4 ; length        
        banked_addr floor_blocking_01_warp
        banked_addr floor_blocking_02_warp
        banked_addr floor_blocking_03_warp
        banked_addr floor_blocking_04_warp

        .include "leveldata/zone_0_hub.asm"

        .include "leveldata/zone_1_grasslands.asm"

        .include "leveldata/zone_2a_beach.asm"
        .include "leveldata/zone_2b.asm"
        .include "leveldata/zone_2c.asm"
        .include "leveldata/zone_2w.asm"

        .include "leveldata/zone_3a.asm"
        .include "leveldata/zone_3b.asm"
        .include "leveldata/zone_3c.asm"
        .include "leveldata/zone_3w.asm"

        .include "leveldata/zone_4a.asm"
        .include "leveldata/zone_4b.asm"
        .include "leveldata/zone_4c.asm"
        .include "leveldata/zone_4w.asm"

        .include "leveldata/zone_5s.asm"
        .include "leveldata/zone_5w.asm"


; ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒▒▓███▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░  

zone_grasslands_floor_2_but_fast:
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
        .addr zone_debug_exits   ; Exit List
        .byte TRACK_SHOWER_GROOVE   ; Music Track
        .byte 80   ; Added Tempo
        .word zone_grasslands_banner_1_1 ; HudBanner
        .addr hud_grasslands_pal
        .addr rare_treasure_table         ; ShopLootPtr0
        .addr rare_treasure_table         ; ShopLootPtr1
        .addr common_treasure_table       ; ShopLootPtr2
        .addr consumable_treasure_table   ; ShopLootPtr3
        .addr test_structure_set_big      ; InteriorStructureLargeSet
        .byte 1                           ; InteriorStructureLargeMaxMax
        .addr test_structure_set_small    ; InteriorStructureSmallSet
        .byte 1                           ; InteriorStructureSmallMaxMax
        .addr test_structure_set_big      ; ExteriorStructureLargeSet
        .byte 1                           ; ExteriorStructureLargeMaxMax
        .addr test_structure_set_small    ; ExteriorStructureSmallSet
        .byte 3                           ; ExteriorStructureSmallMaxMax
        .addr blocking_warp_structure_set ; InteriorStructureWarpSet (unused)
        .addr blocking_warp_structure_set ; ExteriorStructureWarpSet
        .word zone_name_str_debug         ; NameStr
        .word zone_sequence_str_debug     ; SequenceStr
        rng_index_for_zone 1, 1           ; RngIndex
        .byte ZONE_ONLOAD_NONE            ; OnLoadBehavior

; After debugging one zone, return to the hub world
; (note: later to the debug world?)
zone_debug_exits:
        .byte 1 ; length
        .addr zone_hub_world

        .segment "CODE_4"

zone_ptr_by_id_lut:
        .word zone_hub_world
        .word zone_grasslands_floor_1
        .word zone_grasslands_floor_2
        .word zone_grasslands_floor_3
        .word zone_grasslands_floor_4
        .word zone_grasslands_floor_boss
        .word zone_2a_floor_1
        .word zone_2a_floor_2
        .word zone_2a_floor_3
        .word zone_2a_floor_4
        .word zone_2a_floor_boss
        .word zone_2b_floor_1
        .word zone_2b_floor_2
        .word zone_2b_floor_3
        .word zone_2b_floor_4
        .word zone_2b_floor_boss
        .word zone_2c_floor_1
        .word zone_2c_floor_2
        .word zone_2c_floor_3
        .word zone_2c_floor_4
        .word zone_2c_floor_boss
        .word zone_2w_floor_1
        .word zone_2w_floor_2
        .word zone_2w_floor_3
        .word zone_2w_floor_4
        .word zone_2w_floor_boss
        .word zone_3a_floor_1
        .word zone_3a_floor_2
        .word zone_3a_floor_3
        .word zone_3a_floor_4
        .word zone_3a_floor_boss
        .word zone_3b_floor_1
        .word zone_3b_floor_2
        .word zone_3b_floor_3
        .word zone_3b_floor_4
        .word zone_3b_floor_boss
        .word zone_3c_floor_1
        .word zone_3c_floor_2
        .word zone_3c_floor_3
        .word zone_3c_floor_4
        .word zone_3c_floor_boss
        .word zone_3w_floor_1
        .word zone_3w_floor_2
        .word zone_3w_floor_3
        .word zone_3w_floor_4
        .word zone_3w_floor_boss
        .word zone_4a_floor_1
        .word zone_4a_floor_2
        .word zone_4a_floor_3
        .word zone_4a_floor_4
        .word zone_4a_floor_boss
        .word zone_4b_floor_1
        .word zone_4b_floor_2
        .word zone_4b_floor_3
        .word zone_4b_floor_4
        .word zone_4b_floor_boss
        .word zone_4c_floor_1
        .word zone_4c_floor_2
        .word zone_4c_floor_3
        .word zone_4c_floor_4
        .word zone_4c_floor_boss
        .word zone_4w_floor_1
        .word zone_4w_floor_2
        .word zone_4w_floor_3
        .word zone_4w_floor_4
        .word zone_4w_floor_boss
        .word zone_5s_floor_1
        .word zone_5s_floor_boss
        .word zone_5w_floor_1
        .word zone_5w_floor_boss

; Target ID in A please. Clobbers X, Y
.proc FAR_set_zone_ptr_from_id
        ; Safety dance, yes
        cmp #ZONE_TOTAL_COUNT
        bcc zone_id_in_range
        lda #0
zone_id_in_range:
        sta current_save + SaveFile::PlayerZoneId

        asl
        tax
        lda zone_ptr_by_id_lut+0, x
        sta PlayerZonePtr+0
        lda zone_ptr_by_id_lut+1, x
        sta PlayerZonePtr+1

        rts
.endproc

; The inverse, for when we need to go in the other direction. Mostly
; used during suspending the game, but can also be used to track progress
; through a run. (Yes this is stupid, it was all pointer-based originally
; and I don't feel like editing 70+ zones **AGAIN.** Deal.)
.proc FAR_get_zone_id_from_zone_ptr
        ldx #0        
loop:
        lda zone_ptr_by_id_lut+0, x
        cmp PlayerZonePtr+0
        bne not_this_one
        lda zone_ptr_by_id_lut+1, x
        cmp PlayerZonePtr+1
        beq found
not_this_one:
        inx
        inx
        cpx #(ZONE_TOTAL_COUNT * 2)
        bne loop
not_found:
        ; uhh?
        lda #ZONE_HUB_WORLD
        rts
found:
        txa
        lsr
        rts
.endproc

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

.proc FAR_setup_interior_spawn_pool_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::InteriorSpawnPool
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+1

        ldy #ZoneDefinition::InteriorSpawnPoolMin
        lda (PlayerZonePtr), y
        sta SpawnPoolMin
        ldy #ZoneDefinition::InteriorSpawnPoolMax
        lda (PlayerZonePtr), y
        sta SpawnPoolMax
        ldy #ZoneDefinition::InteriorPopulationLimit
        lda (PlayerZonePtr), y
        sta PopulationLimit

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_exterior_spawn_pool_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::ExteriorSpawnPool
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+1

        ldy #ZoneDefinition::ExteriorSpawnPoolMin
        lda (PlayerZonePtr), y
        sta SpawnPoolMin
        ldy #ZoneDefinition::ExteriorSpawnPoolMax
        lda (PlayerZonePtr), y
        sta SpawnPoolMax
        ldy #ZoneDefinition::ExteriorPopulationLimit
        lda (PlayerZonePtr), y
        sta PopulationLimit

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_warp_spawn_pool_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::WarpSpawnPool
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnPoolPtr+1

        ldy #ZoneDefinition::WarpSpawnPoolMin
        lda (PlayerZonePtr), y
        sta SpawnPoolMin
        ldy #ZoneDefinition::WarpSpawnPoolMax
        lda (PlayerZonePtr), y
        sta SpawnPoolMax
        ldy #ZoneDefinition::WarpPopulationLimit
        lda (PlayerZonePtr), y
        sta PopulationLimit

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_general_spawn_set_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::GeneralChallengeSpawnSet
        lda (PlayerZonePtr), y
        sta SpawnSetPtr+0
        iny
        lda (PlayerZonePtr), y
        sta SpawnSetPtr+1

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_setup_warp_spawn_set_for_current_zone
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::WarpChallengeSpawnSet
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
LootTableIndex := R2
        access_data_bank #<.bank(all_zones_data_page)

        lda LootTableIndex
        and #%00000011
        asl
        clc
        adc #ZoneDefinition::ShopLootPtr0
        tay
        lda (PlayerZonePtr), y
        sta LootTablePtr+0
        iny
        lda (PlayerZonePtr), y
        sta LootTablePtr+1

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_draw_banner_for_current_zone
NametableAddr := R0
AttributeAddr := R2
SpritePosX := R4
SpritePosY := R5
BannerDefPtr := R6
SpritePtr := R8
        perform_zpcm_inc
        access_data_bank #<.bank(all_zones_data_page)

        ldy #ZoneDefinition::HudBannerDef
        lda (PlayerZonePtr), y
        sta BannerDefPtr+0
        iny
        lda (PlayerZonePtr), y
        sta BannerDefPtr+1

        ; Banner banks
        perform_zpcm_inc
        ldy #HudBannerDef::SpriteBankUpper
        lda (BannerDefPtr), y
        sta SPRITE_BANK_BANNER_UPPER

        ldy #HudBannerDef::SpriteBankLower
        lda (BannerDefPtr), y
        sta SPRITE_BANK_BANNER_LOWER

        ; Nametable Tiles
        perform_zpcm_inc

        ldy #HudBannerDef::BgTileIds + 0
        lda (BannerDefPtr), y
        ldy #$00
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 1
        lda (BannerDefPtr), y
        ldy #$01
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 2
        lda (BannerDefPtr), y
        ldy #$20
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 3
        lda (BannerDefPtr), y
        ldy #$21
        sta (NametableAddr), y

        perform_zpcm_inc

        ldy #HudBannerDef::BgTileIds + 4
        lda (BannerDefPtr), y
        ldy #$40
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 5
        lda (BannerDefPtr), y
        ldy #$41
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 6
        lda (BannerDefPtr), y
        ldy #$60
        sta (NametableAddr), y

        ldy #HudBannerDef::BgTileIds + 7
        lda (BannerDefPtr), y
        ldy #$61
        sta (NametableAddr), y

        ; Attribute Definitions
        perform_zpcm_inc

        ldy #HudBannerDef::BgTileAttrs + 0
        lda (BannerDefPtr), y
        ldy #$00
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 1
        lda (BannerDefPtr), y
        ldy #$01
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 2
        lda (BannerDefPtr), y
        ldy #$20
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 3
        lda (BannerDefPtr), y
        ldy #$21
        sta (AttributeAddr), y

        perform_zpcm_inc

        ldy #HudBannerDef::BgTileAttrs + 4
        lda (BannerDefPtr), y
        ldy #$40
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 5
        lda (BannerDefPtr), y
        ldy #$41
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 6
        lda (BannerDefPtr), y
        ldy #$60
        sta (AttributeAddr), y

        ldy #HudBannerDef::BgTileAttrs + 7
        lda (BannerDefPtr), y
        ldy #$61
        sta (AttributeAddr), y

        ; Sprite: Top-Left
        perform_zpcm_inc
        ldy #BANNER_FIRST_OAM_INDEX+0
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda SpritePosX
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda SpritePosY
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteTileIds + 0
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteAttrs + 0
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y

        ; Sprite: Top-Right
        perform_zpcm_inc
        ldy #BANNER_FIRST_OAM_INDEX+1
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda SpritePosX
        clc
        adc #8
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda SpritePosY
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteTileIds + 1
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteAttrs + 1
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y

        ; Sprite: Bottom-Left
        perform_zpcm_inc
        ldy #BANNER_FIRST_OAM_INDEX+2
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda SpritePosX
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda SpritePosY
        clc
        adc #16
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteTileIds + 2
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteAttrs + 2
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y

        ; Sprite: Bottom-Right
        perform_zpcm_inc
        ldy #BANNER_FIRST_OAM_INDEX+3
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda SpritePosX
        clc
        adc #8
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda SpritePosY
        clc
        adc #16
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteTileIds + 3
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        ldy #HudBannerDef::SpriteAttrs + 3
        lda (BannerDefPtr), y
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y

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
hud_base_loop:
        perform_zpcm_inc
        lda hud_base_pal, y
        sta IncomingHwPalette, y
        iny
        cpy #16
        bne hud_base_loop

        far_call FAR_set_hud_bg_palette_from_hw

        ldy #0
hud_zone_loop:
        perform_zpcm_inc
        lda (HudPalPtr), y
        sta IncomingHwPalette, y
        iny
        cpy #16 ; TODO: we don't actually use all of these, should we shorten this?
        bne hud_zone_loop

        far_call FAR_set_hud_obj_palette_from_hw

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_play_music_for_current_room
        ; If the current room is a warp, play that music instead. 
        ldy PlayerRoomIndex
        lda room_properties, y
        and #ROOM_PROPERTIES_WARP
        beq not_a_warp_chamber
play_warp_chamber_music:
        ; Warp chambers always use the same base track, in its exterior
        ; variant, with no stock tempo adjustment. (This track is plenty
        ; tricky enough on its own.)
        lda #TRACK_IN_ANOTHER_WORLD
        ldy #TRACK_VARIANT_NORMAL
        jsr play_track
        lda #0
        sta tempo_adjustment
        rts

not_a_warp_chamber:
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

.proc FAR_setup_prng_seeds_from_current_save_and_current_zone
RngIndex := R0
        ; First, initialize the floor RNG from the run seed in
        ; the current save. this is always our starting point
        .repeat 4, i
        lda current_save + SaveFile::RunSeed + i
        sta floor_seed + i
        .endrepeat
        ; We shouldn't use the *same* seed for every floor, as
        ; several floors share maze pools and would otherwise end
        ; up with eerily similar generation. So each floor has an
        ; index, and we use this to run the RNG a few times to skip
        ; ahead some amount of its sequence
        ldy #ZoneDefinition::RngIndex
        lda (PlayerZonePtr), y
        sta RngIndex
        ; Now simply clock the floor seed that many times
rng_setup_loop:
        jsr next_floor_rand ; and throw it away
        dec RngIndex
        bne rng_setup_loop
        ; et voila: a floor seed for *this* floor, based on the
        ; run seed, which will be consistent every time regargless
        ; of what other floors the player visits.
        rts
.endproc