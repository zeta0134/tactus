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
    Exits .byte
    BgPalette .word
    ObjPalette .word
    InteriorOverlayNorth .word
    InteriorOverlayEast .word
    InteriorOverlaySouth .word
    InteriorOverlayWest .word
    ExteriorOverlayNorth .word
    ExteriorOverlayEast .word
    ExteriorOverlaySouth .word
    ExteriorOverlayWest .word
    ChallengeOverlayNorth .word
    ChallengeOverlayEast .word
    ChallengeOverlaySouth .word
    ChallengeOverlayWest .word
    ShopOverlayNorth .word
    ShopOverlayEast .word
    ShopOverlaySouth .word
    ShopOverlayWest .word
    TileIDsLow .byte 176
    TileAttrsHigh .byte 176
    BehaviorIDs .byte 176
    FlagBytes .byte 176
.endstruct

FLOOR_WIDTH = 8
FLOOR_HEIGHT = 4
FLOOR_SIZE = (FLOOR_WIDTH*FLOOR_HEIGHT)

.struct BigFloor
    SpawningPoolIDs .byte ::FLOOR_SIZE
    RoomProperties .byte ::FLOOR_SIZE
.endstruct

ROOM_FLAG_VISITED            = %10000000 ; mostly for minimap purposes
ROOM_FLAG_TREASURE_COLLECTED = %01000000 ; so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = %00100000 ; shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = %00010000 ; boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = %00001000 ; once cleared, a room will not respawn enemies when entered again
ROOM_FLAG_REVEALED           = %00000100 ; more explicitly for minimap purposes

EXIT_FLAG_NORTH = %00000001
EXIT_FLAG_EAST  = %00000010
EXIT_FLAG_SOUTH = %00000100
EXIT_FLAG_WEST  = %00001000