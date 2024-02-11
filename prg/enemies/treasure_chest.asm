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
        cmp #(MAX_HEARTS * 2)
        bne okay_to_spawn
        ; ... then we must not increase their health any further.
        ; Spawn a gold sack instead
        jsr spawn_gold_sack
        rts

okay_to_spawn:
        ; Super easy: replace the chest with a heart container tile
        ldx AttackSquare
        stx TargetIndex

        lda #TILE_HEART_CONTAINER
        sta battlefield, x
        lda #<BG_TILE_FULL_HEART
        sta tile_patterns, x
        lda #(>BG_TILE_FULL_HEART | PAL_RED)
        sta tile_attributes, x
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

        lda #TILE_GOLD_SACK
        sta battlefield, x
        lda #<BG_TILE_GOLD_SACK
        sta tile_patterns, x
        lda #(>BG_TILE_GOLD_SACK | PAL_YELLOW)
        sta tile_attributes, x
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

        lda #TILE_BIG_KEY
        sta battlefield, x
        lda #<BG_TILE_BIG_KEY
        sta tile_patterns, x
        lda #(>BG_TILE_BIG_KEY | PAL_BLUE)
        sta tile_attributes, x
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
        adc #2
        sta PlayerMaxHealth
        sta PlayerHealth

        st16 R0, sfx_heart_container
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex

        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_WORLD)
        sta tile_attributes, x
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
        
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_WORLD)
        sta tile_attributes, x
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
        beq floor4
floor_1:
        add16w PlayerGold, #100
        jmp done_awarding_gold
floor2:
        add16w PlayerGold, #200
        jmp done_awarding_gold
floor3:
        add16w PlayerGold, #300
        jmp done_awarding_gold
floor4:
        add16w PlayerGold, #500
done_awarding_gold:
        ; TODO: a nice SFX
        st16 R0, sfx_coin
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_WORLD)
        sta tile_attributes, x
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