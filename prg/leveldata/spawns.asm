
; The global set of spawn data, for use in spawn pools
enemy_slime_basic:
        basic_spawn_entry TILE_BASIC_SLIME, BG_TILE_SLIME_IDLE, PAL_BLUE
        default_spawn_pool_details
        pack_size 2, 3

enemy_slime_intermediate:
        full_spawn_entry TILE_INTERMEDIATE_SLIME, BG_TILE_SLIME_IDLE, PAL_YELLOW, 0, 0, disco_tile_to_my_right
        default_spawn_pool_details
        pack_size 2, 6

enemy_slime_advanced:
        full_spawn_entry TILE_ADVANCED_SLIME, BG_TILE_SLIME_IDLE, PAL_RED, 0, 0, disco_square_to_my_down_and_right
        default_spawn_pool_details
        pack_size 1, 3

enemy_zombie_basic:
        basic_spawn_entry TILE_ZOMBIE_BASIC, BG_TILE_ZOMBIE_IDLE, PAL_WORLD
        default_spawn_pool_details
        pack_size 3, 5

enemy_zombie_intermediate:
        basic_spawn_entry TILE_ZOMBIE_INTERMEDIATE, BG_TILE_ZOMBIE_IDLE, PAL_YELLOW
        default_spawn_pool_details
        pack_size 2, 4

enemy_zombie_advanced:
        basic_spawn_entry TILE_ZOMBIE_ADVANCED, BG_TILE_ZOMBIE_IDLE, PAL_RED
        default_spawn_pool_details
        pack_size 1, 3

enemy_spider_basic:
        basic_spawn_entry TILE_SPIDER_BASIC, BG_TILE_SPIDER, PAL_BLUE
        default_spawn_pool_details
        pack_size 2, 4

enemy_spider_intermediate:
        basic_spawn_entry TILE_SPIDER_INTERMEDIATE, BG_TILE_SPIDER, PAL_YELLOW
        default_spawn_pool_details
        pack_size 2, 4

enemy_spider_advanced:
        basic_spawn_entry TILE_SPIDER_ADVANCED, BG_TILE_SPIDER, PAL_RED
        default_spawn_pool_details
        pack_size 1, 3

; mushrooms are synchronized to the beat. we can spawn them offset so they aren't all
; attacking at the same time
enemy_mushroom_basic_beat_0:
        full_spawn_entry TILE_MUSHROOM_BASIC, BG_TILE_MUSHROOM_IDLE, PAL_RED, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_1:
        full_spawn_entry TILE_MUSHROOM_BASIC, BG_TILE_MUSHROOM_IDLE, PAL_RED, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_2:
        full_spawn_entry TILE_MUSHROOM_BASIC, BG_TILE_MUSHROOM_IDLE, PAL_RED, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_3:
        full_spawn_entry TILE_MUSHROOM_BASIC, BG_TILE_MUSHROOM_IDLE, PAL_RED, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_0:
        full_spawn_entry TILE_MUSHROOM_INTERMEDIATE, BG_TILE_MUSHROOM_IDLE, PAL_BLUE, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_1:
        full_spawn_entry TILE_MUSHROOM_INTERMEDIATE, BG_TILE_MUSHROOM_IDLE, PAL_BLUE, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_2:
        full_spawn_entry TILE_MUSHROOM_INTERMEDIATE, BG_TILE_MUSHROOM_IDLE, PAL_BLUE, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_3:
        full_spawn_entry TILE_MUSHROOM_INTERMEDIATE, BG_TILE_MUSHROOM_IDLE, PAL_BLUE, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_0:
        full_spawn_entry TILE_MUSHROOM_ADVANCED, BG_TILE_MUSHROOM_IDLE, PAL_YELLOW, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_1:
        full_spawn_entry TILE_MUSHROOM_ADVANCED, BG_TILE_MUSHROOM_IDLE, PAL_YELLOW, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_2:
        full_spawn_entry TILE_MUSHROOM_ADVANCED, BG_TILE_MUSHROOM_IDLE, PAL_YELLOW, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_0:
        full_spawn_entry TILE_MUSHROOM_WEIRD, BG_TILE_MUSHROOM_IDLE, PAL_WORLD, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_1:
        full_spawn_entry TILE_MUSHROOM_WEIRD, BG_TILE_MUSHROOM_IDLE, PAL_WORLD, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_2:
        full_spawn_entry TILE_MUSHROOM_WEIRD, BG_TILE_MUSHROOM_IDLE, PAL_WORLD, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_3:
        full_spawn_entry TILE_MUSHROOM_WEIRD, BG_TILE_MUSHROOM_IDLE, PAL_WORLD, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_4:
        full_spawn_entry TILE_MUSHROOM_WEIRD, BG_TILE_MUSHROOM_IDLE, PAL_WORLD, 4, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_birb_basic_left:
        basic_spawn_entry TILE_BIRB_LEFT_BASIC, BG_TILE_BIRB_IDLE_LEFT, PAL_YELLOW
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_basic_right:
        basic_spawn_entry TILE_BIRB_RIGHT_BASIC, BG_TILE_BIRB_IDLE_RIGHT, PAL_YELLOW
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_intermediate_left:
        basic_spawn_entry TILE_BIRB_LEFT_INTERMEDIATE, BG_TILE_BIRB_IDLE_LEFT, PAL_BLUE
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_intermediate_right:
        basic_spawn_entry TILE_BIRB_RIGHT_INTERMEDIATE, BG_TILE_BIRB_IDLE_RIGHT, PAL_BLUE
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_advanced_left:
        basic_spawn_entry TILE_BIRB_LEFT_ADVANCED, BG_TILE_BIRB_IDLE_LEFT, PAL_RED
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_advanced_right:
        basic_spawn_entry TILE_BIRB_RIGHT_ADVANCED, BG_TILE_BIRB_IDLE_RIGHT, PAL_RED
        default_spawn_pool_details
        pack_size 1, 2

enemy_mole_basic:
        basic_spawn_entry TILE_MOLE_HOLE_BASIC, BG_TILE_MOLE_HOLE, PAL_RED
        default_spawn_pool_details
        pack_size 2, 4

enemy_mole_advanced:
        basic_spawn_entry TILE_MOLE_HOLE_ADVANCED, BG_TILE_MOLE_HOLE, PAL_BLUE
        default_spawn_pool_details
        pack_size 1, 3

