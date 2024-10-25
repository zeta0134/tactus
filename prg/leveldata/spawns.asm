
; The global set of spawn data, for use in spawn pools
enemy_slime_basic:
        basic_spawn_entry TILE_SLIME, BG_TILE_SLIME_IDLE, PAL_WATER
        default_spawn_pool_details
        pack_size 2, 3

enemy_slime_intermediate:
        full_spawn_entry TILE_SLIME, BG_TILE_SLIME_IDLE, PAL_AIR, 0, 0, disco_tile_to_my_right
        default_spawn_pool_details
        pack_size 2, 6

enemy_slime_advanced:
        full_spawn_entry TILE_SLIME, BG_TILE_SLIME_IDLE, PAL_FIRE, 0, 0, disco_square_to_my_down_and_right
        default_spawn_pool_details
        pack_size 1, 3

enemy_zombie_basic:
        basic_spawn_entry TILE_ZOMBIE, BG_TILE_ZOMBIE_IDLE, PAL_EARTH
        default_spawn_pool_details
        pack_size 3, 5

enemy_zombie_intermediate:
        basic_spawn_entry TILE_ZOMBIE, BG_TILE_ZOMBIE_IDLE, PAL_AIR
        default_spawn_pool_details
        pack_size 2, 4

enemy_zombie_advanced:
        basic_spawn_entry TILE_ZOMBIE, BG_TILE_ZOMBIE_IDLE, PAL_FIRE
        default_spawn_pool_details
        pack_size 1, 3

enemy_spider_basic:
        basic_spawn_entry TILE_SPIDER, BG_TILE_SPIDER, PAL_WATER
        default_spawn_pool_details
        pack_size 2, 4

enemy_spider_intermediate:
        basic_spawn_entry TILE_SPIDER, BG_TILE_SPIDER, PAL_AIR
        default_spawn_pool_details
        pack_size 2, 4

enemy_spider_advanced:
        basic_spawn_entry TILE_SPIDER, BG_TILE_SPIDER, PAL_FIRE
        default_spawn_pool_details
        pack_size 1, 3

; mushrooms are synchronized to the beat. we can spawn them offset so they aren't all
; attacking at the same time
enemy_mushroom_basic_beat_0:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_FIRE, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_1:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_FIRE, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_2:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_FIRE, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_basic_beat_3:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_FIRE, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_0:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_WATER, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_1:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_WATER, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_2:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_WATER, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_intermediate_beat_3:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_WATER, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_0:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_AIR, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_1:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_AIR, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_advanced_beat_2:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_AIR, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_0:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_EARTH, 0, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_1:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_EARTH, 1, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_2:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_EARTH, 2, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_3:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_EARTH, 3, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_mushroom_weird_beat_4:
        full_spawn_entry TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE, PAL_EARTH, 4, 0, ring_of_disco_tiles
        default_spawn_pool_details
        pack_size 1, 1

enemy_birb_basic_left:
        basic_spawn_entry TILE_BIRB_LEFT, BG_TILE_BIRB_IDLE_LEFT, PAL_AIR
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_basic_right:
        basic_spawn_entry TILE_BIRB_RIGHT, BG_TILE_BIRB_IDLE_RIGHT, PAL_AIR
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_intermediate_left:
        basic_spawn_entry TILE_BIRB_LEFT, BG_TILE_BIRB_IDLE_LEFT, PAL_WATER
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_intermediate_right:
        basic_spawn_entry TILE_BIRB_RIGHT, BG_TILE_BIRB_IDLE_RIGHT, PAL_WATER
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_advanced_left:
        basic_spawn_entry TILE_BIRB_LEFT, BG_TILE_BIRB_IDLE_LEFT, PAL_FIRE
        default_spawn_pool_details
        pack_size 1, 2

enemy_birb_advanced_right:
        basic_spawn_entry TILE_BIRB_RIGHT, BG_TILE_BIRB_IDLE_RIGHT, PAL_FIRE
        default_spawn_pool_details
        pack_size 1, 2

enemy_mole_basic:
        basic_spawn_entry TILE_MOLE_HOLE, BG_TILE_MOLE_HOLE, PAL_FIRE
        default_spawn_pool_details
        pack_size 2, 4

enemy_mole_advanced:
        basic_spawn_entry TILE_MOLE_HOLE, BG_TILE_MOLE_HOLE, PAL_WATER
        default_spawn_pool_details
        pack_size 1, 3

