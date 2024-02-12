; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc update_birb_left
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

        ldx CurrentRow
        jsr queue_row_x

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

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
all_done:
        rts
.endproc

.proc update_birb_right
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


        ldx CurrentRow
        jsr queue_row_x

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

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
all_done:
        rts
.endproc

.proc update_birb_flying_right
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

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_RIGHT_BASE, BG_TILE_BIRB_IDLE_RIGHT

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_BIRB_RIGHT_FLYING, BG_TILE_BIRB_FLYING_RIGHT

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        draw_at_x_keeppal TILE_SMOKE_PUFF, BG_TILE_SMOKE_PUFF

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

.proc update_birb_flying_left
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

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        draw_at_x_keeppal TILE_BIRB_LEFT_BASE, BG_TILE_BIRB_IDLE_LEFT

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_BIRB_LEFT_FLYING, BG_TILE_BIRB_FLYING_LEFT 

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        draw_at_x_keeppal TILE_SMOKE_PUFF, BG_TILE_SMOKE_PUFF
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

.proc direct_attack_birb
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
        lda #1
        sta EnemyHealth
        lda #5
        sta GoldToAward
        jmp done
intermediate_hp:
        lda #2
        sta EnemyHealth
        lda #10
        sta GoldToAward
        jmp done
advanced_hp:
        lda #4
        sta EnemyHealth
        lda #20
        sta GoldToAward
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_birb
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
        lda #1
        sta EnemyHealth
        lda #5
        sta GoldToAward
        jmp done
intermediate_hp:
        lda #2
        sta EnemyHealth
        lda #10
        sta GoldToAward
        jmp done
advanced_hp:
        lda #4
        sta EnemyHealth
        lda #20
        sta GoldToAward
done:
        jsr indirect_attack_with_hp
        rts
.endproc