; TODO: This is GOING AWAY / BEING REDONE, etc.

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
TREASURE_ITEM = 0
TREASURE_HEART = 1
TREASURE_GOLD = 2
TREASURE_NAV = 3

; control frequency of gold, weapon, and heart container drops
; right now it feels like we should favor weapons, as the player
; has to work pretty hard to get a chest to spawn. Hearts are useful,
; gold not so much, it feels like a nothing drop
treasure_category_table:
        .repeat 4
        .byte TREASURE_GOLD
        .endrepeat
        .repeat 3
        .byte TREASURE_ITEM
        .endrepeat
        .repeat 1
        .byte TREASURE_HEART
        .endrepeat
        .repeat 8
        .byte TREASURE_NAV
        .endrepeat
        
        ; force a specific drop
        ;.repeat 16
        ;.byte TREASURE_ITEM
        ;.endrepeat

.proc ENEMY_ATTACK_attack_treasure_chest
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
WeaponPtr := R11 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; if this is a boss room, we need to always spawn the key!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        beq spawn_treasure
        near_call ENEMY_ATTACK_spawn_big_key
        rts
spawn_treasure:
        perform_zpcm_inc
        ; determine which weapon category to spawn
        jsr next_gameplay_rand
        and #%00001111
        tax
        lda treasure_category_table, x
check_nav:
        cmp #TREASURE_NAV
        bne check_item
        near_call ENEMY_ATTACK_spawn_nav_item
        rts
check_item:
        cmp #TREASURE_ITEM
        bne check_gold
        near_call ENEMY_ATTACK_spawn_item
        rts
check_gold:
        cmp #TREASURE_GOLD
        bne spawn_heart
        near_call ENEMY_ATTACK_spawn_gold_sack
        rts
spawn_heart:
        near_call ENEMY_ATTACK_spawn_heart_container
        rts
.endproc

.proc ENEMY_ATTACK_spawn_heart_container
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; If the player is already at max hearts...
        ldx #(MAX_REGULAR_HEARTS-1)
        lda heart_type, x
        cmp #HEART_TYPE_NONE      ; empty containers are fine
        beq okay_to_spawn
        cmp #HEART_TYPE_TEMPORARY ; temporary containers are also fine
        beq okay_to_spawn
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq okay_to_spawn
        ; ... then we must not increase their health any further.
        ; Spawn a gold sack instead
        near_call ENEMY_ATTACK_spawn_gold_sack
        rts

okay_to_spawn:
        ; Super easy: replace the chest with a heart container tile
        ldx AttackSquare
        stx TargetIndex
        draw_at_x_withpal TILE_HEART_CONTAINER, BG_TILE_FULL_HEART, PAL_RED

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile
        
        rts
.endproc

.proc ENEMY_ATTACK_spawn_gold_sack
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; Super easy: replace the chest with a gold sack tile
        ldx AttackSquare
        stx TargetIndex
        draw_at_x_withpal TILE_GOLD_SACK, BG_TILE_GOLD_SACK, PAL_YELLOW

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile
        
        rts
.endproc

.proc ENEMY_ATTACK_spawn_big_key
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; Super easy: replace the chest with a big key tile
        ldx AttackSquare
        stx TargetIndex
        draw_at_x_withpal TILE_BIG_KEY, BG_TILE_BIG_KEY, PAL_BLUE

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        rts
.endproc

.proc ENEMY_ATTACK_spawn_item
; for draw_active_tile
TargetIndex := R0

TileId := R1
AttackSquare := R3 ; do not clobber! (don't clobber R2 or R4-R15 either!)

; for rolling treasure loot
LootTablePtr := R16
ItemId := R18

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_WORLD

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        ; Now roll for the loot this item shadow will contain. This is a gameplay
        ; roll, so use that RNG and the appropriate table

        ; the real loot table
        ;st16 LootTablePtr, common_chest_treasure_table
        ; zeta needs to obtain a specific item for testing
        st16 LootTablePtr, test_specific_item_table

        far_call FAR_roll_gameplay_loot
        ldx AttackSquare
        lda ItemId
        sta tile_data, x

        rts
.endproc

.proc ENEMY_ATTACK_spawn_nav_item
; for draw_active_tile
TargetIndex := R0
TileId := R1
AttackSquare := R3 ; do not clobber! (don't clobber R2 or R4-R15 either!)

        ; depending on the player's nav index, we spawn nav helpers in a fixed order
        lda PlayerNavState
        beq spawn_compass
        cmp #1
        beq spawn_map
        ; the player has mapped this area; revert to generating a regular item instead
        near_call ENEMY_ATTACK_spawn_item
        rts
spawn_compass:
        inc PlayerNavState
        ldx AttackSquare
        lda #ITEM_COMPASS
        sta tile_data, x
        jmp converge
spawn_map:
        inc PlayerNavState
        ldx AttackSquare
        lda #ITEM_MAP
        sta tile_data, x
converge:

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_WORLD

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_collect_heart_container
NewHeartType := R0

TargetIndex := R0
TileId := R1
TargetSquare := R13
        
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart

        st16 R0, sfx_heart_container
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        rts
.endproc

.proc ENEMY_COLLIDE_collect_key
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda #1 ; there is only one key per dungeon floor
        sta PlayerKeys

        ; TODO: a nice SFX
        st16 R0, sfx_key_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_key_pulse2
        jsr play_sfx_pulse2

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; This is the big key! Now that we have it, reveal the location of the exit
        ; stairs (this stops the player from needing to do a brute-force search)
        ldx #0
find_exit_loop:
        perform_zpcm_inc
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq next_room
        lda room_flags, x
        ora #ROOM_FLAG_REVEALED
        sta room_flags, x
next_room:
        inx
        cpx #::FLOOR_SIZE
        bne find_exit_loop

        lda #1
        sta HudMapDirty

        rts
.endproc

.proc ENEMY_COLLIDE_collect_gold_sack
TargetIndex := R0
TileId := R1
TargetSquare := R13

        ; TODO: this used to award an amount of gold based on the floor. Do we care
        ; to make it variable based on zone somehow? (I kinda want to not?)
        add16w PlayerGold, #50
        clamp16 PlayerGold, #MAX_GOLD

done_awarding_gold:
        ; TODO: a nice SFX
        st16 R0, sfx_coin
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        rts
.endproc
