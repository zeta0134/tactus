.global FAR_demo_init_floor
.global FAR_init_floor
.global FAR_init_current_room
.global FAR_handle_room_spawns

.global room_layouts, room_flags, room_seeds, room_properties, global_rng_seed, enemies_active

; layouts
.global test_layout_with_four_exits
.global test_layout
.global far_too_many_slimes
.global hit_box_testing

.struct Layout
    TileTypes .byte 140
    RoomProperties .byte
.endstruct

.struct Room
    Exits .byte 1
    TileIDsLow .byte 140
    TileAttrsHigh .byte 140
    BehaviorIDs .byte 140
    FlagBytes .byte 140
.endstruct

ROOM_FLAG_VISITED            = %10000000 ; mostly for minimap purposes
ROOM_FLAG_TREASURE_COLLECTED = %01000000 ; so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = %00100000 ; shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = %00010000 ; boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = %00001000 ; once cleared, a room will not respawn enemies when entered again
ROOM_FLAG_REVEALED           = %00000100 ; more explicitly for minimap purposes