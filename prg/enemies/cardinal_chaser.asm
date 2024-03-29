; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================

.proc pick_random_cardinal
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        lda CurrentRow
        sta TargetRow
        lda CurrentTile
        sta TargetTile

        jsr next_rand
        and #%00000011
        beq east
        cmp #1
        beq south
        cmp #2
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
east:
        inc TargetTile
        rts
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
west:
        dec TargetTile
        rts
.endproc

.proc target_player_cardinal
TargetRow := R0
TargetTile := R1
PlayerDistanceRow := R2
PlayerDistanceCol := R3
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        lda CurrentRow
        sta TargetRow
        lda CurrentTile
        sta TargetTile

        ; Compute the absolute distance the player is away from us on both axis, independently

        ; First the row
        lda PlayerRow
        sec
        sbc CurrentRow
        bpl save_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
save_row_distance:
        sta PlayerDistanceRow

        ; Now the column
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bpl save_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
save_col_distance:
        sta PlayerDistanceCol

        ; Now, whichever of these is bigger will be our axis of travel. If they re the same size,
        ; pick randomly
        lda PlayerDistanceRow
        sec
        sbc PlayerDistanceCol
        beq choose_randomly
        bmi move_horizontally
        jmp move_vertically
choose_randomly:
        jsr next_rand
        bmi move_horizontally
        jmp move_vertically

move_horizontally:
        ; If the player is to our right...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bmi move_left
move_right: 
        inc TargetTile
        rts
move_left:
        dec TargetTile
        rts

move_vertically:
        ; If the player is below us...
        lda PlayerRow
        sec
        sbc CurrentRow
        bmi move_up
move_down:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
move_up:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc update_zombie_base
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; Determine how many beats we should remain idle, based on difficulty
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate
        cmp #%11
        beq advanced
basic:
        lda #3
        sta IdleDelay
        jmp done
intermediate:
        lda #2
        sta IdleDelay
        jmp done
advanced:
        lda #1
        sta IdleDelay
done:

        inc tile_data, x
        lda tile_data, x
        cmp IdleDelay ; TODO: pick a threshold based on zombie difficulty
        bcc no_change
        ; switch to our anticipation pose
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_ANTICIPATE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

no_change:
        rts
.endproc

.proc update_zombie_anticipate
TargetRow := R0
TargetTile := R1
PlayerDistance := R2
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow

        jsr player_manhattan_distance
track_player:        
        ; If we're outside the tracking radius, choose our next position randomly
        ; (here, A already has the distance from before)
        cmp #ZOMBIE_TARGET_RADIUS
        bcs randomly_choose_direction
        ; Otherwise target the player
        jsr target_player_cardinal
        jmp location_chosen
randomly_choose_direction:
        jsr pick_random_cardinal
location_chosen:
        ; Now our destination tile is in TargetTile, make sure it's valid
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_BASE
        sta battlefield, x
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:        
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_BASE
        sta battlefield, y

        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Queue up both rows
        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc direct_attack_zombie
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        lda #10
        sta GoldToAward
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        lda #20
        sta GoldToAward
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
        lda #50
        sta GoldToAward
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_zombie
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        lda #10
        sta GoldToAward
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        lda #20
        sta GoldToAward
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
        lda #50
        sta GoldToAward
done:
        jsr indirect_attack_with_hp
        rts
.endproc