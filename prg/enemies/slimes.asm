; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_slime
CurrentTile := R15
        inc enemies_active
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate
        cmp #%11
        beq advanced
        ; Basic slimes have no update behavior; they are stationary
        rts
intermediate:
        near_call ENEMY_UPDATE_update_intermediate_slime
        rts
advanced:
        near_call ENEMY_UPDATE_update_advanced_slime
        rts
.endproc

.proc ENEMY_UPDATE_update_intermediate_slime
TargetTile := R0
CurrentRow := R14
CurrentTile := R15

        ; Intermediate slime: every 2 beats, move horizontally. We'll use these state
        ; bits, which normally start all zero:
        ; 76543210
        ;      |||
        ;      |++-- beat counter
        ;      +---- direction flag: 0 = jump right, 1 = jump left
        ldx CurrentTile
        bail_if_already_moved
        lda tile_data, x
        and #%00000011
        cmp #1
        beq jump
continue_waiting:
        inc tile_data, x
        rts
jump:
        ; Now, use our tile data to determine which direction to jump
        lda tile_data, x
        and #%00000100
        beq jump_right
jump_left:
        lda CurrentTile
        sta TargetTile
        dec TargetTile
        lda #DUST_DIRECTION_E
        sta SmokePuffDirection
        jmp converge
jump_right:
        lda CurrentTile
        sta TargetTile
        inc TargetTile
        lda #DUST_DIRECTION_W
        sta SmokePuffDirection
converge:
        ; Sanity check: is the target tile free?
        if_valid_destination proceed_with_jump
cancel_jump:
        ; fix our state and exit
        ldx CurrentTile
        lda tile_data, x
        and #%11111100 ; reset the beat counter for the next attempt
        eor #%00000100 ; invert the direction: if there was a wall to one side, try the other side next time
        sta tile_data, x
        rts
proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_SLIME_BASE, BG_TILE_SLIME_IDLE

        ; Set up our attributes for the next jump
        lda tile_data, x
        and #%11111100 ; reset the beat counter for the next attempt
        eor #%00000100 ; invert the direction: if there was a wall to one side, try the other side next time        
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Flag ourselves as having just moved; this signals to the player that our old
        ; position is a valid target, and it also signals to the engine that we shouldn't be ticked
        ; a second time, if our target square comes up while we're scanning
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, y
        ; Clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw the puff of smoke at our current location
        ; (this clobbers X and Y, so we prefer to do it last)
        lda CurrentTile
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_draw_smoke_puff

        rts
.endproc

.proc ENEMY_UPDATE_update_advanced_slime
TargetTile := R0
TargetRow := R1
CurrentRow := R14
CurrentTile := R15
        ; Advanced slime: every beats, move in one of the 4 cardinal directions
        ; bits, which normally start all zero:
        ; 76543210
        ;       ||
        ;       ++-- next direction
        ldx CurrentTile
        bail_if_already_moved

        lda CurrentRow
        sta TargetRow

        lda tile_data, x
        and #%00000011
        cmp #0
        beq east
        cmp #1
        beq south
        cmp #2
        beq west
north:
        lda #DUST_DIRECTION_S
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #(BATTLEFIELD_WIDTH)
        sta TargetTile
        dec TargetRow
        jmp converge
east:
        lda #DUST_DIRECTION_W
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #1
        sta TargetTile
        jmp converge
south:
        lda #DUST_DIRECTION_N
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #(BATTLEFIELD_WIDTH)
        sta TargetTile
        inc TargetRow
        jmp converge
west:
        lda #DUST_DIRECTION_E
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #1
        sta TargetTile
converge:
        ; Sanity check: is the target tile free?
        if_valid_destination proceed_with_jump
cancel_jump:
        ; fix our state and exit
        ldx CurrentTile
        lda tile_data, x
        ; ahead and advance to the next direction
        clc
        adc #1 
        ; but not too far
        and #%00000011
        sta tile_data, x
        rts
proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_SLIME_BASE, BG_TILE_SLIME_IDLE

        ; Set up our attributes for the next jump
        lda tile_data, x
        ; ahead and advance to the next direction
        clc
        adc #1 
        ; but not too far
        and #%00000011
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Flag ourselves as having just moved; this signals to the player that our old
        ; position is a valid target, and it also signals to the engine that we shouldn't be ticked
        ; a second time, if our target square comes up while we're scanning
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, y
        ; Clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw the puff of smoke at our current location
        ; (this clobbers X and Y, so we prefer to do it last)
        lda CurrentTile
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_draw_smoke_puff

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_slime
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; If we have *just moved*, then ignore this attack
        ; (A valid attack can only land at our previous destination)
        ldx AttackSquare
        lda tile_flags, x
        bmi ignore_attack
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_ATTACK_attack_slime_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_slime
        near_call ENEMY_ATTACK_attack_slime_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_slime_common
; For drawing tiles
TargetIndex := R0
TileId := R1

OriginalAttackSquare := R3

AttackLanded := R7
EffectiveAttackSquare := R10 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; slimes all have 1 HP, so there is no health bar. Just delete
        ; the slime by replacing it
        ldx EffectiveAttackSquare
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile

        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        near_call ENEMY_ATTACK_spawn_death_sprite_here

        ; A slime died! Increment the player's ongoing combo
        inc PlayerCombo

        ; spawn LOOT upon defeat. Slimes always use the tiny loot table,
        ; regardless of their "difficulty" (which really just affects their
        ; movement pattern)
        set_loot_table SLIME_LOOT_TABLE
        roll_loot_at OriginalAttackSquare

        ; Play an appropriately crunchy death sound
        st16 R0, sfx_defeat_enemy_pulse
        jsr play_sfx_pulse1
        st16 R0, sfx_defeat_enemy_noise
        jsr play_sfx_noise

        lda #1
        sta EnemyDiedThisFrame

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        rts
.endproc
