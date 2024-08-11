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
    
    HudHeader .word
    HudBanner .word
    HudPal .word

    ; TODO: guaranteed loot lists? consumable lists?
    ShopLootPtr .word

.endstruct

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
.global FAR_current_zone_header_tile
.global FAR_current_zone_banner_tile
.global FAR_load_hud_palette_for_current_zone
.global FAR_play_music_for_current_zone
.global FAR_load_exit_pointer_from_current_zone

ROOM_POOL_OUT_OF_BOUNDS   = 0
ROOM_POOL_GRASSY_EXTERIOR = 1
ROOM_POOL_CAVE_INTERIOR   = 2
ROOM_POOL_HUB_WORLD_SET_A = 3

; ===============
;     ROOMS
; ===============

.struct Room
    Properties .byte
    Exits .byte
    BgPalette .word
    ObjPalette .word
    OverlayList .word
    TileIDsLow .byte 176
    TileAttrsHigh .byte 176
    BehaviorIDs .byte 176
    FlagBytes .byte 176
.endstruct

.global FAR_load_room_palette
.global FAR_roll_room_from_floorplan_at_current_index