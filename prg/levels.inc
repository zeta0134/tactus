.global FAR_demo_init_floor

.global room_layouts, room_flags

; layouts
.global test_layout
.global far_too_many_slimes
.global hit_box_testing

ROOM_FLAG_VISITED            = %10000000 ; mostly for minimap purposes
ROOM_FLAG_TREASURE_COLLECTED = %01000000 ; so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = %00100000 ; shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = %00010000 ; boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = %00001000 ; once cleared, a room will not respawn enemies when entered again