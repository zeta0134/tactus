; this is several includes at once, because I see no practical reason to split it out

; generic macros that are used in lots of lists

; 2 bytes of bank number, which isn't as crazy as it sounds if we
; end up exceeding 2 MiB of PRG ROM at some point
.macro banked_addr address
        .addr address
        .byte <.bank(address), >.bank(address)
.endmacro

; ===============
;     SPAWNS
; ===============

.struct SpawnListEntry
        Behavior .byte
        TileLow .byte
        TileHighAttr .byte
        Data .byte
        Flags .byte
        SpawnCheck .addr
.endstruct

.macro basic_spawn_entry behavior, tile_id, pal
        .byte behavior           ; Behavior
        .byte (<tile_id)         ; TileLow
        .byte ((>tile_id) | pal) ; TileHighAttr
        .byte $0                 ; Data
        .byte $0                 ; Flags
        .addr single_disco_tile  ; SpawnCheck
.endmacro

.macro full_spawn_entry behavior, tile_id, pal, data, flags, spawn_condition
        .byte behavior           ; Behavior
        .byte (<tile_id)         ; TileLow
        .byte ((>tile_id) | pal) ; TileHighAttr
        .byte data               ; Data
        .byte flags              ; Flags
        .addr spawn_condition    ; SpawnCheck
.endmacro

.struct SpawnSetEntry
        SpawnList .addr
        Conditions .addr
        Bank .byte
.endstruct

.macro spawn_set_entry list_ptr
        .addr list_ptr
        .addr always_valid
        .byte <.bank(list_ptr)
.endmacro

.macro conditional_spawn_set_entry list_ptr, condition_func
        .addr list_ptr
        .addr condition_func
        .byte <.bank(list_ptr)
.endmacro

.struct SpawnPoolEntry
        Behavior .byte
        TileLow .byte
        TileHighAttr .byte
        Data .byte
        Flags .byte
        SpawnCheck .addr
        RoomCompatibility .byte
        Aggression .byte ; excessive danger
        Trickiness .byte ; unusual setup / resistance to standard techniques
        LootReward .byte ; unusually high rewards
        Tankiness .byte  ; unusually high health or defense
        PackSizeMin .byte
        PackSizeMax .byte
.endstruct

.macro default_spawn_pool_details
        .byte 0 ; compatible with all rooms
        .byte 0, 0, 0, 0 ; aggression, trickiness, loot, tankiness
.endmacro

.macro pack_size pack_min, pack_max
        .byte pack_min, pack_max ; pack size: min, max
.endmacro

.global SpawnedEntityIndex
.globalzp SpawnListPtr
.globalzp EntityPtr

.globalzp SpawnPoolPtr
.global SpawnPoolMin
.global SpawnPoolMax
.global PopulationLimit
.global FAR_spawn_entities_from_pool

.global spawn_pool_generic

.globalzp SpawnSetPtr
.global spawnset_a53_z1_f1
.global spawnset_a53_z1_f2
.global spawnset_a53_z1_f3
.global spawnset_a53_z1_f4
.global FAR_spawn_entities_from_spawn_set

; ===============
;     ZONES
; ===============

.struct HudBannerDef
        SpriteBankUpper .byte 1
        SpriteBankLower .byte 1
        SpriteTileIds .byte 4
        SpriteAttrs .byte 4
        BgTileIds .byte 8
        BgTileAttrs .byte 8
.endstruct

.macro hud_banner_sprite upper_sprite, lower_sprite
        ; 8x16 sprite banks
        .byte >upper_sprite
        .byte >lower_sprite
        ; 8x16 sprite tiles
        .byte <upper_sprite + 0 + SPRITE_OFFSET_BANNER_UPPER
        .byte <upper_sprite + 2 + SPRITE_OFFSET_BANNER_UPPER
        .byte <lower_sprite + 0 + SPRITE_OFFSET_BANNER_LOWER
        .byte <lower_sprite + 2 + SPRITE_OFFSET_BANNER_LOWER
.endmacro

.struct ZoneDefinition
        GeneralSpawnPool .addr
        ChallengeSpawnSet .addr

        SpawnPoolMin .byte
        SpawnPoolMax .byte
        PopulationLimit .byte

        FloorList .addr
        ExitList .addr
        MusicTrack .byte
        AddedTempo .byte

        HudBannerDef .word
        HudPal .word

        ; Each individual index in a shop gets one of these
        ShopLootPtr0 .word
        ShopLootPtr1 .word
        ShopLootPtr2 .word
        ShopLootPtr3 .word

        InteriorStructureLargeSet .word
        InteriorStructureLargeMaxMax .byte
        InteriorStructureSmallSet .word
        InteriorStructureSmallMaxMax .byte
        ExteriorStructureLargeSet .word
        ExteriorStructureLargeMaxMax .byte
        ExteriorStructureSmallSet .word
        ExteriorStructureSmallMaxMax .byte
.endstruct

.global all_zones_data_page

.global zone_grasslands_floor_1
.global zone_grasslands_floor_2
.global zone_grasslands_floor_3
.global zone_grasslands_floor_4
.global zone_hub_world

; various utility functions for working with zones, since
; their data lives in a dedicated bank
.global FAR_roll_floorplan_from_active_zone_pool
.global FAR_setup_spawn_set_for_current_zone
.global FAR_setup_spawn_pool_for_current_zone
.global FAR_setup_shop_loot_ptrs_for_current_zone
.global FAR_draw_banner_for_current_zone
.global FAR_load_hud_palette_for_current_zone
.global FAR_play_music_for_current_room
.global FAR_load_exit_pointer_from_current_zone

ROOM_POOL_OUT_OF_BOUNDS          =  0
ROOM_POOL_GRASSY_EXTERIOR        =  1
ROOM_POOL_CAVE_INTERIOR          =  2
ROOM_POOL_HUB_WORLD_SET_SPAWN    =  3
ROOM_POOL_BLOCKING_EXTERIOR      =  4
ROOM_POOL_BLOCKING_INTERIOR      =  5
ROOM_POOL_HUB_WORLD_SET_BIG_ROOM =  6
ROOM_POOL_HUB_WORLD_SET_DEBUG_1  =  7
ROOM_POOL_HUB_WORLD_SET_DEBUG_2  =  8
ROOM_POOL_HUB_WORLD_SET_DEBUG_3  =  9
ROOM_POOL_HUB_WORLD_SET_DEBUG_4  = 10
ROOM_POOL_HUB_WORLD_SET_DEBUG_5  = 11
ROOM_POOL_ZONE_1_BOSS            = 12
ROOM_POOL_ZONE_2A_BOSS           = 13
ROOM_POOL_ZONE_2B_BOSS           = 14
ROOM_POOL_ZONE_2C_BOSS           = 15
ROOM_POOL_ZONE_2W_BOSS           = 16
ROOM_POOL_ZONE_3A_BOSS           = 17
ROOM_POOL_ZONE_3B_BOSS           = 18
ROOM_POOL_ZONE_3C_BOSS           = 19
ROOM_POOL_ZONE_3W_BOSS           = 20
ROOM_POOL_ZONE_4A_BOSS           = 21
ROOM_POOL_ZONE_4B_BOSS           = 22
ROOM_POOL_ZONE_4C_BOSS           = 23
ROOM_POOL_ZONE_4W_BOSS           = 24
ROOM_POOL_ZONE_5S_BOSS           = 25
ROOM_POOL_ZONE_5W_BOSS           = 26
ROOM_POOL_ZONE_2_NORMAL_EXIT     = 27
ROOM_POOL_ZONE_3_NORMAL_EXIT     = 28
ROOM_POOL_ZONE_4_NORMAL_EXIT     = 29
ROOM_POOL_ZONE_5_NORMAL_EXIT     = 30
ROOM_POOL_ZONE_2_WARP_EXIT       = 31
ROOM_POOL_ZONE_3_WARP_EXIT       = 32
ROOM_POOL_ZONE_4_WARP_EXIT       = 33
ROOM_POOL_ZONE_5_WARP_EXIT       = 34

; ===============
;     ROOMS
; ===============

.struct Room
        Properties .byte
        Exits .byte
        RasterEffect .byte
        ColorEmphasis .byte
        BaseLogic .byte
        BgPalette .word
        ObjPalette .word
        OverlayList .word
        TileIDsLow .byte 176
        TileAttrsHigh .byte 176
        BehaviorIDs .byte 176
        FlagBytes .byte 176
.endstruct

.global FAR_load_room_palette             ; used during procgen, not general
.global FAR_load_palette_for_current_room ; can be called from almost anywhere, relies on PlayerRoomIndex
.global FAR_roll_room_from_floorplan_at_current_index

; ==================
;     STRUCTURES
; ==================

.struct StructureDefinition
        MinPosX .byte
        MaxPosX .byte
        MinPosY .byte
        MaxPosY .byte
        TileList .addr
        Requirements .addr
.endstruct

OVERLAY_OPEN_NE = 1
OVERLAY_OPEN_SE = 2
OVERLAY_OPEN_SW = 3
OVERLAY_OPEN_NW = 4

.global FAR_spawn_structures_from_zonedef

.global test_structure_set_small
.global test_structure_set_big
.global empty_structure_set

ROOM_BASE_LOGIC_NONE     = 0
ROOM_BASE_LOGIC_STANDARD = 1
