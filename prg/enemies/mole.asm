; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

MOLE_NORTH = 0
MOLE_EAST = 1
MOLE_SOUTH = 2
MOLE_WEST = 3

.proc update_mole_hole
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; Determine how many beats we should remain idle, based on difficulty
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq advanced
basic:
        lda #2
        sta IdleDelay
        jmp done
advanced:
        lda #0 ; pop up quickly
        sta IdleDelay
done:

        ldx CurrentTile
        lda tile_data, x
        cmp IdleDelay
        bcc continue_waiting

        ; Okay first, we cannot rise out of the ground if the player is too close,
        ; both for engine and gameplay reasons, so compute that
        jsr player_manhattan_distance
        cmp #MOLE_SUPPRESSION_RADIUS
        bcc do_nothing

        ; Now, we only pop up if the player is in our line of sight, and we'll throw
        ; a wrench at them (evenutally) so, first, does the player's column match ours?
        lda PlayerCol
        ldx CurrentTile
        cmp tile_index_to_col_lut, x
        beq line_of_sight_vertical

        ; What about the row?
        lda PlayerRow
        cmp CurrentRow
        beq line_of_sight_horizontal

        ; Neither? Then continue waiting, we can't "see" them from here
        jmp do_nothing
line_of_sight_vertical:
        ; if the player's row is less than ours...
        lda PlayerRow
        cmp CurrentRow
        bpl south
north:
        ; ... then we will throw north
        lda #MOLE_NORTH
        sta tile_data, x
        jmp switch_to_attack_pose
south:
        ; ... otherwise, we will throw south
        lda #MOLE_SOUTH
        sta tile_data, x
        jmp switch_to_attack_pose

line_of_sight_horizontal:
        ; if the player's column is more than ours...
        lda PlayerCol
        ldx CurrentTile
        cmp tile_index_to_col_lut, x
        bmi west
east:
        ; ... then we will throw north
        lda #MOLE_EAST
        sta tile_data, x
        jmp switch_to_attack_pose
west:
        ; ... otherwise, we will throw south
        lda #MOLE_WEST
        sta tile_data, x
        jmp switch_to_attack_pose

switch_to_attack_pose:
        ; switch to our anticipation pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_THROWING
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And we're done, the tile_data is set up for the next frame, and we don't
        ; need to bother with the flags byte this round

        rts

continue_waiting:
        inc tile_data, x
do_nothing:
        rts
.endproc

.proc update_mole_throwing
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow
        ; Using our tile data, determine which direction we will be attempting to throw
        ldx CurrentTile
        lda tile_data, x
        cmp #MOLE_EAST
        beq east
        cmp #MOLE_SOUTH
        beq south
        cmp #MOLE_WEST
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
east:
        inc TargetTile
        jmp attempt_to_spawn_wrench
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
west:
        dec TargetTile
attempt_to_spawn_wrench:
        if_valid_destination spawn_wrench
        jmp switch_to_idle_pose
spawn_wrench:
        ldx CurrentTile
        ldy TargetTile

        ; Draw a wrench at the chosen target location, using our palette from the
        ; current location
        lda battlefield, x
        and #%00000011
        ora #TILE_WRENCH_PROJECTILE
        sta battlefield, y
        ; Write the throw direction to the data byte for the wrench, that way
        ; it keeps going in the same direction we threw it initially
        lda tile_data, x
        sta tile_data, y
        ; Set the flags on the wrench to indicate that we have just moved,
        ; this prevents us from going an extra square in the east/south directions
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, y
        
        ldx TargetRow
        jsr queue_row_x

switch_to_idle_pose:

        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_IDLE
        sta battlefield, x
        ; reset tile_data to 0, it will be our counter for idle -> hole
        lda #0
        sta tile_data, x

        ldx CurrentRow
        jsr queue_row_x

        rts
.endproc

.proc update_mole_idle
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
        cmp #%01
        beq advanced
basic:
        lda #2
        sta IdleDelay
        jmp done
advanced:
        lda #1 ; return underground quickly
        sta IdleDelay
done:

        lda tile_data, x
        cmp IdleDelay 
        bcc continue_waiting

        ; Switch back into our hole pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_HOLE_BASE
        sta battlefield, x
        ; Again reset our delay counter
        lda #0
        sta tile_data, x
        ; Because we just went intangible this frame, mark ourselves as having "just moved"
        ; This allows the player to attack us on what, to them, feels like the frame when we
        ; were still above ground.
        lda tile_flags, x
        ora #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x
        rts

continue_waiting:
        inc tile_data, x
        rts
.endproc

.proc update_wrench_projectile
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved

        ; Very similar to the mole's throwing pose, we first need to work out where the wrench
        ; wants to GO from here...
        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow

        ; Using our tile data, determine which direction we will be attempting to move
        ldx CurrentTile
        lda tile_data, x
        cmp #MOLE_EAST
        beq east
        cmp #MOLE_SOUTH
        beq south
        cmp #MOLE_WEST
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
east:
        inc TargetTile
        jmp attempt_to_spawn_wrench
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
west:
        dec TargetTile
attempt_to_spawn_wrench:
        if_valid_destination spawn_new_wrench
        jmp despawn_old_wrench
spawn_new_wrench:
        ldx CurrentTile
        ldy TargetTile

        ; Draw a wrench at the chosen target location, using our palette from the
        ; current location
        lda battlefield, x
        and #%00000011
        ora #TILE_WRENCH_PROJECTILE
        sta battlefield, y
        ; Write the throw direction to the data byte for the wrench, that way
        ; it keeps going in the same direction we threw it initially
        lda tile_data, x
        sta tile_data, y
        ; Set the new wrench as active, so it isn't ticked multiple times
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, y
        
        ldx TargetRow
        jsr queue_row_x
        
despawn_old_wrench:
        ; mark ourselves as floor; we're done
        ; (no puff stool this time, projectiles can't be attacked)
        ldx CurrentTile
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        ; clean up the other flags for posterity
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ldx CurrentRow
        jsr queue_row_x

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc direct_attack_mole_idle
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        lda #25
        sta GoldToAward
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
        lda #100
        sta GoldToAward
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc direct_attack_mole_throwing
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        lda #25
        sta GoldToAward
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
        lda #100
        sta GoldToAward
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc direct_attack_mole_hole
AttackSquare := R3
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ; Mole holes are intangible except on the frame they appear, since visually the mole
        ; was above ground from the player's point of view. So, check for that here
        ldx AttackSquare
        lda tile_flags, x
        bmi allow_attack
        rts
allow_attack:
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        lda #25
        sta GoldToAward
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
        lda #100
        sta GoldToAward
done:
        lda AttackSquare
        sta EffectiveAttackSquare
        jsr indirect_attack_with_hp
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc projectile_attacks_player
TargetIndex := R0
TileId := R1
TargetSquare := R13
        ; All projectiles do 1 damage to the player on hit
        jsr damage_player

        ; Now, despawn the projectile:
        ; draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        rts
.endproc

