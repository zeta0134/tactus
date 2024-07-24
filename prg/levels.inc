.global FAR_demo_init_floor
.global FAR_init_floor
.global FAR_generate_rooms_for_floor

.global FAR_load_current_room
.global FAR_handle_room_spawns

.global room_layouts, room_flags, room_floorplan, room_properties, enemies_active

; layouts
.global test_layout_with_four_exits
.global test_layout
.global far_too_many_slimes
.global hit_box_testing

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

FLOOR_WIDTH = 8
FLOOR_HEIGHT = 4
FLOOR_SIZE = (FLOOR_WIDTH*FLOOR_HEIGHT)

.struct BigFloor
    SpawningPoolIDs .byte ::FLOOR_SIZE
    RoomProperties .byte ::FLOOR_SIZE
    MinChallengeRooms .byte
    MaxChallengeRooms .byte
    MinShopRooms .byte
    MaxShopRooms .byte
.endstruct

ROOM_FLAG_VISITED            = %10000000 ; mostly for minimap purposes
ROOM_FLAG_TREASURE_SPAWNED   = %01000000 ; so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = %00100000 ; shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = %00010000 ; boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = %00001000 ; once cleared, a room will not respawn enemies when entered again
ROOM_FLAG_REVEALED           = %00000100 ; more explicitly for minimap purposes
ROOM_FLAG_DARK               = %00000010 ; activates torchlight radius effect. spookiness is optional

FLOOR_PROPERTIES_NOSPAWN = %10000000 

ROOM_PROPERTIES_NOSPAWN = %10000000
ROOM_PROPERTIES_DARK    = %01000000
ROOM_CATEGORY_EXTERIOR  = %00000000
ROOM_CATEGORY_INTERIOR  = %00010000
ROOM_CATEGORY_CHALLENGE = %00100000
ROOM_CATEGORY_SHOP      = %00110000
ROOM_CATEGORY_MASK      = %00110000
ROOM_EXIT_FLAG_NORTH    = %00000001 ; Never
ROOM_EXIT_FLAG_EAST     = %00000010 ; Eat
ROOM_EXIT_FLAG_SOUTH    = %00000100 ; Soggy
ROOM_EXIT_FLAG_WEST     = %00001000 ; Waffles