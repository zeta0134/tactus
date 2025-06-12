; Spawn pools are sorted lists of potential enemy spawns, organized
; roughly by enemy difficulty. Rooms will partially index into this
; list based on the current zone's difficulty and the room's
; modifiers. As such, the sort doesn't need to be particularly accurate
; and it's best if enemies are "mixed up" a little bit near the seams

; Make sure all spawn pools add up to 128 in length! Repeat entries
; as necessary.

.if ::DEBUG_SPAWN_OVERRIDE

spawn_pool_generic:
    ; Always spawn THIS specific enemy
    ;.repeat 128
    ;.addr enemy_one_armed_bandit_air
    ;.endrepeat

    ; For when I'd like to test all four variants
    .repeat 32
    .addr enemy_one_armed_bandit_earth
    .addr enemy_one_armed_bandit_ice
    .addr enemy_one_armed_bandit_air
    .addr enemy_one_armed_bandit_fire
    .endrepeat

.else

; contains a spread of fairly basic enemies.
; suitable for use in all testing chambers, but we want to move away
; from this in favor of zone-specific lists for the final game.
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

spawn_pool_grasslands_outdoors:
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
    .addr enemy_one_armed_bandit_ice
    .addr enemy_one_armed_bandit_air
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
    .addr enemy_one_armed_bandit_fire
    .endrepeat
    ; just to fill out the top end: chasers galore!
    .repeat 3
    .addr enemy_zombie_advanced
    .endrepeat
    .repeat 4
    .addr enemy_spider_advanced
    .endrepeat

spawn_pool_grasslands_cave:
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
    .addr enemy_cultist_earth
    .addr enemy_cultist_air
    .addr enemy_cultist_fire
    .addr enemy_cultist_ice
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
    .addr enemy_one_armed_bandit_fire
    .endrepeat
    ; just to fill out the top end: chasers galore!
    .repeat 3
    .addr enemy_zombie_advanced
    .endrepeat
    .repeat 4
    .addr enemy_spider_advanced
    .endrepeat

.endif