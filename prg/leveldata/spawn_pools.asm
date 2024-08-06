; Spawn pools are sorted lists of potential enemy spawns, organized
; roughly by enemy difficulty. Rooms will partially index into this
; list based on the current zone's difficulty and the room's
; modifiers. As such, the sort doesn't need to be particularly accurate
; and it's best if enemies are "mixed up" a little bit near the seams

; Make sure all spawn pools add up to 128 in length! Repeat entries
; as necessary.

; contains every non-weird enemy in the game
; suitable for use in almost all chambers.
spawn_pool_generic:
    ; basic enemies
    .repeat 2 ; 34 entries total
    .addr enemy_slime_basic
    .addr enemy_slime_intermediate
    .addr enemy_slime_intermediate
    .addr enemy_zombie_basic
    .addr enemy_zombie_basic
    .addr enemy_zombie_basic
    .addr enemy_zombie_basic
    .addr enemy_spider_basic
    .addr enemy_spider_basic
    .addr enemy_spider_basic
    .addr enemy_spider_basic
    .addr enemy_mushroom_basic_beat_0
    .addr enemy_mushroom_basic_beat_1
    .addr enemy_mushroom_basic_beat_2
    .addr enemy_mushroom_basic_beat_3
    .addr enemy_birb_basic_left
    .addr enemy_birb_basic_right
    .endrepeat
    ; intermediate
    .repeat 3 ; 48 entries total
    .addr enemy_mole_basic
    .addr enemy_mole_basic
    .addr enemy_zombie_intermediate
    .addr enemy_zombie_intermediate
    .addr enemy_zombie_intermediate
    .addr enemy_zombie_intermediate
    .addr enemy_spider_intermediate
    .addr enemy_spider_intermediate
    .addr enemy_spider_intermediate
    .addr enemy_spider_intermediate
    .addr enemy_mushroom_intermediate_beat_0
    .addr enemy_mushroom_intermediate_beat_1
    .addr enemy_mushroom_intermediate_beat_2
    .addr enemy_mushroom_intermediate_beat_3
    .addr enemy_birb_intermediate_left
    .addr enemy_birb_intermediate_right
    .endrepeat
    ; advanced
    .repeat 3 ; 39 entries total
    .addr enemy_slime_intermediate
    .addr enemy_slime_advanced
    .addr enemy_slime_advanced
    .addr enemy_zombie_advanced
    .addr enemy_zombie_advanced
    .addr enemy_spider_advanced
    .addr enemy_spider_advanced
    .addr enemy_mushroom_advanced_beat_0
    .addr enemy_mushroom_advanced_beat_1
    .addr enemy_mushroom_advanced_beat_2
    .addr enemy_birb_advanced_left
    .addr enemy_birb_advanced_right
    .addr enemy_mole_advanced
    .endrepeat
    ; just to fill out the top end: chasers galore!
    .repeat 3
    .addr enemy_zombie_advanced
    .endrepeat
    .repeat 4
    .addr enemy_spider_advanced
    .endrepeat


