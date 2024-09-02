; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"
; Result in A, clobbers R0
.proc ENEMY_UPDATE_player_manhattan_distance
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
        perform_zpcm_inc
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"
; Spiders store their beat counter in tile_data, and damage in the low 7 bits of tile_flags

.proc ENEMY_UPDATE_update_spider_base
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
        draw_at_x_keeppal TILE_SPIDER_ANTICIPATE, BG_TILE_SPIDER_ANTICIPATE

no_change:
        rts
.endproc

; This really needs to be... just... ENTIRELY redone. Most notably, spiders
; are REAL bad about getting stuck in a corner with a 25% chance to escape. They
; do a bit better when tracking the player, but still make stupid decisions. We
; want them to try to always move if they're not completely blocked, and we want
; the whole "randomly pick a direction" logic to be much less stupid.
.proc ENEMY_UPDATE_update_spider_anticipate
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

        near_call ENEMY_UPDATE_player_manhattan_distance
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
        lda #DUST_DIRECTION_N ; temp
        sta SmokePuffDirection
        jmp row_target_converge
move_down:
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        inc TargetRow
        lda #DUST_DIRECTION_S ; temp
        sta SmokePuffDirection
        jmp row_target_converge
randomly_target_row:
        jsr next_gameplay_rand
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
        lda SmokePuffDirection
        cmp #DUST_DIRECTION_N
        bne dust_sw
dust_nw:
        lda #DUST_DIRECTION_SE
        sta SmokePuffDirection
        jmp col_target_converge
dust_sw:
        lda #DUST_DIRECTION_NE
        sta SmokePuffDirection
        jmp col_target_converge
move_right:
        inc TargetTile
        lda SmokePuffDirection
        cmp #DUST_DIRECTION_N
        bne dust_se
dust_ne:
        lda #DUST_DIRECTION_SW
        sta SmokePuffDirection
        jmp col_target_converge
dust_se:
        lda #DUST_DIRECTION_NW
        sta SmokePuffDirection
        jmp col_target_converge
randomly_target_col:
        jsr next_gameplay_rand
        bmi move_left
        jmp move_right
col_target_converge:
        
        ; Now our destination tile is in TargetTile, make sure it's valid
        if_valid_destination proceed_with_jump
jump_failed:
        if_semisafe_destination make_target_dangerous
        jmp return_to_idle_without_moving
make_target_dangerous:
        ; write our own position into the target tile, as this will help
        ; the damage sprite to spawn in the right location if the player
        ; takes the hit
        ldx TargetTile
        lda CurrentTile
        sta tile_data, x
        ; additionally, for update order reasons, mark the target as "already moved",
        ; this prevents it from clearing our damage state before the next beat
        lda tile_flags, x
        ora #%10000000
        sta tile_flags, x
        ;jmp return_to_idle_without_moving ; (fall through)
return_to_idle_without_moving:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        draw_at_x_keeppal TILE_SPIDER_BASE, BG_TILE_SPIDER


        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_SPIDER_BASE, BG_TILE_SPIDER

        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; Finally clear the data flags for the puff of smoke, just to keep things tidy
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
.proc ENEMY_ATTACK_direct_attack_spider
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
        set_loot_table basic_loot_table
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #6
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_spider
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
        set_loot_table basic_loot_table
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #6
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_indirect_attack_with_hp
        rts
.endproc
