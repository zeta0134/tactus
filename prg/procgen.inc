.global FAR_demo_init_floor
.global FAR_init_floor
.global FAR_generate_rooms_for_floor
.global FAR_roll_for_detail
.global FAR_process_exit_data
.global FAR_process_sign_data

.global FAR_load_current_room
.global FAR_update_room_state
.global FAR_update_room_effects

.global room_layouts, room_flags, room_floorplan, room_properties, room_bank, room_ptr_high, room_ptr_low
.global room_raster_effect, room_color_emphasis, room_base_beat_logic, room_spell_beat_logic, room_spell_data0, room_spell_data1
.global room_palette_variant, room_minimap_state
.global first_beat_after_load, enemies_active

; layouts
.global test_layout_with_four_exits
.global test_layout
.global far_too_many_slimes
.global hit_box_testing

.globalzp BigFloorPtr
.global BigFloorBank
.global RoomIndexToGenerate

.global WarpPortalRoomIndex
.global WarpEntranceRoomIndex

.global current_clear_status
.global previous_clear_status

FLOOR_WIDTH = 6
FLOOR_HEIGHT = 4
FLOOR_SIZE = (FLOOR_WIDTH*FLOOR_HEIGHT)

.struct BigFloor
    SpawningPoolIDs .byte ::FLOOR_SIZE
    RoomProperties .byte ::FLOOR_SIZE
    MinChallengeRooms .byte
    MaxChallengeRooms .byte
    MinShopRooms .byte
    MaxShopRooms .byte
    MinExitRooms .byte
    MaxExitRooms .byte
    FloorProperties .byte
.endstruct

FLOOR_PROPERTIES_HAS_WARP_ZONE = %10000000

;ROOM_FLAG_VISITED            = %10000000 ; mostly for minimap purposes
ROOM_FLAG_TREASURE_SPAWNED   = %01000000 ; so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = %00100000 ; shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = %00010000 ; boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = %00001000 ; once cleared, a room will not respawn enemies when entered again
;ROOM_FLAG_REVEALED           = %00000100 ; more explicitly for minimap purposes
ROOM_FLAG_DARK               = %00000010 ; activates torchlight radius effect. spookiness is optional
ROOM_FLAG_WARP_PORTAL        = %00000001 ; this room contains (must generate) a portal to the warp zone

ROOM_MINIMAP_FLAG_VISITED    = %10000000
ROOM_MINIMAP_FLAG_MAPPED     = %01000000
ROOM_MINIMAP_FLAG_IDENTIFIED = %00100000

FLOORPLAN_PROPERTIES_NO_PLAYER_SPAWN  = %10000000 
FLOORPLAN_PROPERTIES_NO_MONSTER_SPAWN = %01000000
FLOORPLAN_MINIMAP_SHAPE_MASK          = %00110000
FLOORPLAN_MINIMAP_SHAPE_EXTERIOR      = %00000000
FLOORPLAN_MINIMAP_SHAPE_INTERIOR      = %00010000
FLOORPLAN_MINIMAP_SHAPE_STRUCTURE     = %00100000
FLOORPLAN_MINIMAP_SHAPE_RESERVED      = %00110000

ROOM_PROPERTIES_NOSPAWN      = %10000000
ROOM_PROPERTIES_DARK         = %01000000
ROOM_PROPERTIES_WARP         = %00001000 ; this room is part of the warp zone (don't put the player here)
ROOM_PROPERTIES_EXIT_CHAMBER = %00000100 ; this chamber contains an exit (currently only used for warps)
ROOM_CATEGORY_EXTERIOR       = %00000000
ROOM_CATEGORY_INTERIOR       = %00010000
ROOM_CATEGORY_CHALLENGE      = %00100000
ROOM_CATEGORY_SHOP           = %00110000
ROOM_CATEGORY_MASK           = %00110000

; All warp zones share these settings, unlike the regular floors which may
; differ depending on maze layout
WARP_MIN_CHALLENGE_COUNT = 0 ; TODO: if challenges are required for alt. boss, increment this!
WARP_MAX_CHALLENGE_COUNT = 3
WARP_MIN_SHOP_COUNT = 0
WARP_MAX_SHOP_COUNT = 1
WARP_MIN_EXIT_COUNT = 1
WARP_MAX_EXIT_COUNT = 1

ROOM_EXIT_FLAG_NORTH    = %00000001 ; Never
ROOM_EXIT_FLAG_EAST     = %00000010 ; Eat
ROOM_EXIT_FLAG_SOUTH    = %00000100 ; Soggy
ROOM_EXIT_FLAG_WEST     = %00001000 ; Waffles

TILE_FLAG_DETAIL = %10000000
TILE_FLAG_EXIT   = %01000000
TILE_FLAG_SIGN   = %00100000
TILE_FLAG_ITEM   = %00010000

DETAIL_SPARSE_GRASS            = 0
DETAIL_SPARSE_SHROOMS          = 2
DETAIL_SPARSE_GRASS_SHROOMS    = 4
DETAIL_CAVE                    = 6
DETAIL_CAVE_SHROOMS            = 8
DETAIL_SAND                    = 10
DETAIL_GRASS_WALL_LOWER_BORDER = 12
DETAIL_GRASS_WALL              = 14
DETAIL_GRASS_WALL_UPPER_BORDER = 16
DETAIL_GRASS_WALL_HORIZ_STRIP  = 18

ROOM_LOGIC_NORMAL = 0

SPELL_LOGIC_NONE = 0
SPELL_LOGIC_BOMB_FIESTA = 1
