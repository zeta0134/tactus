; proper organization eventually; let me get the skeleton of this 
; mess written before I commit to subfolders
        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
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
        .addr blocking_warp_structure_set ;InteriorStructureWarpSet (unused)
        .addr blocking_warp_structure_set ;ExteriorStructureWarpSet

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
        sta HudPaletteBuffer, y
        iny
        cpy #16
        bne hud_base_loop

        ldy #0
hud_zone_loop:
        perform_zpcm_inc
        lda (HudPalPtr), y
        sta HudPaletteBuffer+16, y
        iny
        cpy #16
        bne hud_zone_loop

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