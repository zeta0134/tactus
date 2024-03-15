; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

TREASURE_WEAPON = 0
TREASURE_HEART = 1
TREASURE_GOLD = 2

; control frequency of gold, weapon, and heart container drops
; right now it feels like we should favor weapons, as the player
; has to work pretty hard to get a chest to spawn. Hearts are useful,
; gold not so much, it feels like a nothing drop
treasure_category_table:
        .repeat 4
        .byte TREASURE_GOLD
        .endrepeat
        .repeat 10
        .byte TREASURE_WEAPON
        .endrepeat
        .repeat 2
        .byte TREASURE_HEART
        .endrepeat

.proc attack_treasure_chest
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

        ; load the room seed before spawning the treasure
        jsr set_fixed_room_seed

        ; if this is a boss room, we need to always spawn the key!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        beq spawn_treasure
        jsr spawn_big_key
        rts
spawn_treasure:
        ; determine which weapon category to spawn
        jsr next_fixed_rand
        and #%00001111
        tax
        lda treasure_category_table, x
check_weapon:
        cmp #TREASURE_WEAPON
        bne check_gold
        jsr spawn_weapon
        rts
check_gold:
        cmp #TREASURE_GOLD
        bne spawn_heart
        jsr spawn_gold_sack
        rts
spawn_heart:
        jsr spawn_heart_container
        rts
.endproc

.proc spawn_heart_container
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; If the player is already at max hearts...
        lda PlayerMaxHealth
        cmp #(MAX_HEARTS * 4)
        bne okay_to_spawn
        ; ... then we must not increase their health any further.
        ; Spawn a gold sack instead
        jsr spawn_gold_sack
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

.proc spawn_gold_sack
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

.proc spawn_big_key
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

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc collect_heart_container
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda PlayerMaxHealth
        clc
        adc #4
        sta PlayerMaxHealth
        sta PlayerHealth

        st16 R0, sfx_heart_container
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile
        

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        rts
.endproc

.proc collect_key
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
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

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
        cpx #16
        bne find_exit_loop

        lda #1
        sta HudMapDirty

        rts
.endproc

.proc collect_gold_sack
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda PlayerFloor
        cmp #2
        beq floor2
        cmp #3
        beq floor3
        cmp #4
        jeq floor4
floor_1:
        add16w PlayerGold, #10
        clamp16 PlayerGold, #MAX_GOLD
        jmp done_awarding_gold
floor2:
        add16w PlayerGold, #20
        clamp16 PlayerGold, #MAX_GOLD
        jmp done_awarding_gold
floor3:
        add16w PlayerGold, #30
        clamp16 PlayerGold, #MAX_GOLD
        jmp done_awarding_gold
floor4:
        add16w PlayerGold, #50
        clamp16 PlayerGold, #MAX_GOLD
done_awarding_gold:
        ; TODO: a nice SFX
        st16 R0, sfx_coin
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        rts
.endproc