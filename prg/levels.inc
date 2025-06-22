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
        FinalizerBehavior .addr
.endstruct

.macro basic_spawn_entry behavior, tile_id, pal
        .byte behavior           ; Behavior
        .byte (<tile_id)         ; TileLow
        .byte ((>tile_id) | pal) ; TileHighAttr
        .byte $0                 ; Data
        .byte $0                 ; Flags
        .addr single_disco_tile  ; SpawnCheck
        .addr no_finalizer       ; Finalizer
.endmacro

.macro full_spawn_entry behavior, tile_id, pal, data, flags, spawn_condition, finalizer_behavior
        .byte behavior           ; Behavior
        .byte (<tile_id)         ; TileLow
        .byte ((>tile_id) | pal) ; TileHighAttr
        .byte data               ; Data
        .byte flags              ; Flags
        .addr spawn_condition    ; SpawnCheck
        .addr finalizer_behavior ; SpawnCheck
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
        FinalizerBehavior .addr
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
.global spawn_pool_grasslands_outdoors
.global spawn_pool_grasslands_cave

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
        InteriorSpawnPool .addr
        ExteriorSpawnPool .addr
        WarpSpawnPool     .addr
        GeneralChallengeSpawnSet .addr
        WarpChallengeSpawnSet .addr

        InteriorSpawnPoolMin .byte
        InteriorSpawnPoolMax .byte
        InteriorPopulationLimit .byte
        ExteriorSpawnPoolMin .byte
        ExteriorSpawnPoolMax .byte
        ExteriorPopulationLimit .byte
        WarpSpawnPoolMin .byte
        WarpSpawnPoolMax .byte
        WarpPopulationLimit .byte

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

        ; Warp structures don't have a max size. When we spawn these
        ; we'll REQUIRE exactly one to succeed. (Be sure it is possible,
        ; or level gen will lock up!)
        InteriorStructureWarpSet .word
        ExteriorStructureWarpSet .word

        NameStr .word        ; "Grasslands"
        SequenceStr .word    ; "1-1"
        RngIndex .byte       ; so zones use different-ish seeds
        OnLoadBehavior .byte ; some zones need special setup logic, mostly the HUB

        ; Parameters for chest spawning: which structure sets to use, which loot tables to pull from,
        ; and how many of each chest type to attempt to spawn, as a range. Note that there is no sanity
        ; check on the total number of chests, this just determines the relative quality between those
        ; chests that do get placed.
        StandardChestInteriorStructures .word
        StandardChestExteriorStructures .word
        StandardChestLootTable .word
        StandardChestMin .byte
        StandardChestMax .byte

        RareChestInteriorStructures .word
        RareChestExteriorStructures .word
        RareChestLootTable .word
        RareChestMin .byte
        RareChestMax .byte

        LegendaryChestInteriorStructures .word
        LegendaryChestExteriorStructures .word
        LegendaryChestLootTable .word
        LegendaryChestMin .byte
        LegendaryChestMax .byte

        ZoneIndex .byte  ; Zone 1, Zone 2, etc. Mind warps.
        FloorIndex .byte ; Floors range from 1 - 5, with 5 == boss. Not all zones have all floors. 0 is invalid.
.endstruct

ZONE_ONLOAD_NONE = 0
ZONE_ONLOAD_HUB  = 1

.macro rng_index_for_zone zone_id, floor_id
        .byte (5*zone_id)+floor_id
.endmacro

.global all_zones_data_page

ZONE_HUB_WORLD             = 00
ZONE_GRASSLANDS_FLOOR_1    = 01
ZONE_GRASSLANDS_FLOOR_2    = 02
ZONE_GRASSLANDS_FLOOR_3    = 03
ZONE_GRASSLANDS_FLOOR_4    = 04
ZONE_GRASSLANDS_FLOOR_BOSS = 05
ZONE_2A_FLOOR_1            = 06
ZONE_2A_FLOOR_2            = 07
ZONE_2A_FLOOR_3            = 08
ZONE_2A_FLOOR_4            = 09
ZONE_2A_FLOOR_BOSS         = 10
ZONE_2B_FLOOR_1            = 11
ZONE_2B_FLOOR_2            = 12
ZONE_2B_FLOOR_3            = 13
ZONE_2B_FLOOR_4            = 14
ZONE_2B_FLOOR_BOSS         = 15
ZONE_2C_FLOOR_1            = 16
ZONE_2C_FLOOR_2            = 17
ZONE_2C_FLOOR_3            = 18
ZONE_2C_FLOOR_4            = 19
ZONE_2C_FLOOR_BOSS         = 20
ZONE_2W_FLOOR_1            = 21
ZONE_2W_FLOOR_2            = 22
ZONE_2W_FLOOR_3            = 23
ZONE_2W_FLOOR_4            = 24
ZONE_2W_FLOOR_BOSS         = 25
ZONE_3A_FLOOR_1            = 26
ZONE_3A_FLOOR_2            = 27
ZONE_3A_FLOOR_3            = 28
ZONE_3A_FLOOR_4            = 29
ZONE_3A_FLOOR_BOSS         = 30
ZONE_3B_FLOOR_1            = 31
ZONE_3B_FLOOR_2            = 32
ZONE_3B_FLOOR_3            = 33
ZONE_3B_FLOOR_4            = 34
ZONE_3B_FLOOR_BOSS         = 35
ZONE_3C_FLOOR_1            = 36
ZONE_3C_FLOOR_2            = 37
ZONE_3C_FLOOR_3            = 38
ZONE_3C_FLOOR_4            = 39
ZONE_3C_FLOOR_BOSS         = 40
ZONE_3W_FLOOR_1            = 41
ZONE_3W_FLOOR_2            = 42
ZONE_3W_FLOOR_3            = 43
ZONE_3W_FLOOR_4            = 44
ZONE_3W_FLOOR_BOSS         = 45
ZONE_4A_FLOOR_1            = 46
ZONE_4A_FLOOR_2            = 47
ZONE_4A_FLOOR_3            = 48
ZONE_4A_FLOOR_4            = 49
ZONE_4A_FLOOR_BOSS         = 50
ZONE_4B_FLOOR_1            = 51
ZONE_4B_FLOOR_2            = 52
ZONE_4B_FLOOR_3            = 53
ZONE_4B_FLOOR_4            = 54
ZONE_4B_FLOOR_BOSS         = 55
ZONE_4C_FLOOR_1            = 56
ZONE_4C_FLOOR_2            = 57
ZONE_4C_FLOOR_3            = 58
ZONE_4C_FLOOR_4            = 59
ZONE_4C_FLOOR_BOSS         = 60
ZONE_4W_FLOOR_1            = 61
ZONE_4W_FLOOR_2            = 62
ZONE_4W_FLOOR_3            = 63
ZONE_4W_FLOOR_4            = 64
ZONE_4W_FLOOR_BOSS         = 65
ZONE_5S_FLOOR_1            = 66
ZONE_5S_FLOOR_BOSS         = 67
ZONE_5W_FLOOR_1            = 68
ZONE_5W_FLOOR_BOSS         = 69
ZONE_TOTAL_COUNT = 70

; various utility functions for working with zones, since
; their data lives in a dedicated bank
.global FAR_roll_floorplan_from_active_zone_pool
.global FAR_setup_general_spawn_set_for_current_zone
.global FAR_setup_warp_spawn_set_for_current_zone
.global FAR_setup_exterior_spawn_pool_for_current_zone
.global FAR_setup_interior_spawn_pool_for_current_zone
.global FAR_setup_warp_spawn_pool_for_current_zone
.global FAR_setup_shop_loot_ptrs_for_current_zone
.global FAR_draw_banner_for_current_zone
.global FAR_load_hud_palette_bg
.global FAR_load_hud_palette_for_current_zone
.global FAR_play_music_for_current_room
.global FAR_load_exit_pointer_from_current_zone
.global FAR_setup_prng_seeds_from_current_save_and_current_zone
.global FAR_set_zone_ptr_from_id
.global FAR_get_zone_id_from_zone_ptr

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
ROOM_POOL_ZONE_2_WARP            = 31
ROOM_POOL_ZONE_3_WARP            = 32
ROOM_POOL_ZONE_4_WARP            = 33
ROOM_POOL_ZONE_5_WARP            = 34

; ===============
;     ROOMS
; ===============

.struct Room
        Properties .byte
        Exits .byte
        RasterEffect .byte
        ColorEmphasis .byte
        BaseLogic .byte
        BgPaletteTablePtr .word
        BgPaletteTableBank .byte
        ObjPaletteTablePtr .word
        ObjPaletteTableBank .byte
        OverlayList .word
        FinalizerPtr .word
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

.global grassy_warp_structure_set
.global cave_warp_structure_set
.global blocking_warp_structure_set

.global standard_chest_structure_set
.global rare_chest_structure_set
.global legendary_chest_structure_set

ROOM_BASE_LOGIC_NONE     = 0
ROOM_BASE_LOGIC_STANDARD = 1
