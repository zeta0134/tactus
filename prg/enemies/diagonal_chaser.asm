; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================

; Result in A, clobbers R0
.proc player_manhattan_distance
PlayerDistance := R2
CurrentRow := R14
CurrentTile := R15
        ; First the row
        lda PlayerRow
        sec
        sbc CurrentRow
        bpl add_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
add_row_distance:
        sta PlayerDistance
        ; Now the column
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bpl add_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
add_col_distance:
        clc
        adc PlayerDistance
        sta PlayerDistance
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

; Spiders store their beat counter in tile_data, and damage in the low 7 bits of tile_flags

.proc update_spider_base
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
        cmp IdleDelay ; TODO: pick a threshold based on spider difficulty
        bcc no_change
        ; switch to our anticipation pose
        lda battlefield, x
        and #%00000011
        ora #TILE_SPIDER_ANTICIPATE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

no_change:
        rts
.endproc

.proc update_spider_anticipate
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
        ; First the row
        ; If we're outside the tracking radius, choose it randomly
        ; (here, A already has the distance from before)
        cmp #SPIDER_TARGET_RADIUS
        bcs randomly_target_row
        ; Otherwise target the player on the vertical axis
        lda PlayerRow
        sec
        sbc CurrentRow
        beq randomly_target_row
        bpl move_down
move_up:
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        dec TargetRow
        jmp row_target_converge
move_down:
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        inc TargetRow
        jmp row_target_converge
randomly_target_row:
        jsr next_rand
        bmi move_up
        jmp move_down
row_target_converge:
        ; Now the column
        ; If we're outside the tracking radius, choose it randomly
        lda PlayerDistance
        cmp #SPIDER_TARGET_RADIUS
        bcs randomly_target_col
        ; Otherwise target the player on the horizontal axis
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq randomly_target_col
        bpl move_right
move_left:
        dec TargetTile
        jmp col_target_converge
move_right:
        inc TargetTile
        jmp col_target_converge
randomly_target_col:
        jsr next_rand
        bmi move_left
        jmp move_right
col_target_converge:
        
        ; Now our destination tile is in TargetTile, make sure it's valid
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_SPIDER_BASE
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
        ora #TILE_SPIDER_BASE
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

.proc direct_attack_spider
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

.proc indirect_attack_spider
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