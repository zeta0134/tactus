; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

.proc ENEMY_UPDATE_update_birb_left
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; If the player is *directly* in front of us, then we should charge at them
        lda PlayerRow
        cmp CurrentRow
        bne do_not_charge
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq do_not_charge ; also how did this happen
        bpl face_to_the_right
chaaaaaaaaarge:
        ; Turn ourselves into our flying state
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_LEFT_FLYING, BG_TILE_BIRB_FLYING_LEFT

        ; And all done
        rts
do_not_charge:
        ; If the player is to the RIGHT of us...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq all_done
        bpl face_to_the_right
        ; ... otherwise, we're done
        rts
face_to_the_right:
        ; Turn to face the player. That's cute, and certainly not creepy at all!
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_RIGHT_BASE, BG_TILE_BIRB_IDLE_RIGHT

        ; And all done
all_done:
        rts
.endproc

.proc ENEMY_UPDATE_update_birb_right
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; If the player is *directly* in front of us, then we should charge at them
        lda PlayerRow
        cmp CurrentRow
        bne do_not_charge
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq do_not_charge ; also how did this happen
        bmi face_to_the_left
chaaaaaaaaarge:
        ; Turn ourselves into our flying state
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_RIGHT_FLYING, BG_TILE_BIRB_FLYING_RIGHT

        ; And all done
        rts
do_not_charge:
        ; If the player is to the LEFT of us...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq all_done
        bmi face_to_the_left
        ; ... otherwise, we're done
        rts
face_to_the_left:
        ; Turn to face the player. That's cute, and certainly not creepy at all!
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_LEFT_BASE, BG_TILE_BIRB_IDLE_LEFT

        ; And all done
all_done:
        rts
.endproc

.proc ENEMY_UPDATE_update_birb_flying_right
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        lda CurrentTile
        sta TargetTile

        lda CurrentRow
        sta TargetRow

        ; CHAAAAAAAARGE blindly forward
        inc TargetTile
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
        draw_at_x_keeppal TILE_BIRB_RIGHT_BASE, BG_TILE_BIRB_IDLE_RIGHT

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_BIRB_RIGHT_FLYING, BG_TILE_BIRB_FLYING_RIGHT

        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; Clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw a puff of smoke at our old location        
        lda #DUST_DIRECTION_W
        sta SmokePuffDirection
        lda CurrentTile
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_draw_smoke_puff

        rts
.endproc

.proc ENEMY_UPDATE_update_birb_flying_left
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        lda CurrentTile
        sta TargetTile

        lda CurrentRow
        sta TargetRow

        ; CHAAAAAAAARGE blindly forward
        dec TargetTile
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
        draw_at_x_keeppal TILE_BIRB_LEFT_BASE, BG_TILE_BIRB_IDLE_LEFT

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_BIRB_LEFT_FLYING, BG_TILE_BIRB_FLYING_LEFT 

        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; Clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw a puff of smoke at our old location        
        lda #DUST_DIRECTION_E
        sta SmokePuffDirection
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

.proc ENEMY_ATTACK_direct_attack_birb
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        set_loot_table basic_loot_table
        lda #1
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #2
        sta EnemyHealth        
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #4
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_birb
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        set_loot_table basic_loot_table
        lda #1
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #2
        sta EnemyHealth
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #4
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_indirect_attack_with_hp
        rts
.endproc
