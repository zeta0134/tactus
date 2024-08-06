
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

.global spawn_entity_list_NEW
.global spawn_entities_from_pool

.globalzp SpawnPoolPtr
.global SpawnPoolMin
.global SpawnPoolMax
.global PopulationLimit

.global spawn_pool_generic