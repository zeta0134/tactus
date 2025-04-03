; These are mostly for testing the hazard system. I'm not sure we'll
; keep these behaviors in this form? Unclear. Play it by ear I guess.

        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_hazard_tile
; these are provided for us
CurrentRow := R14
CurrentTile := R15

        ; If we're not tripped then there's not much to do
        ldx CurrentTile
        lda tile_data, x
        beq do_nothing

        ; If we are tripped, and the player is NOT currently standing on our square,
        ; reset ourselves to active.
        lda CurrentRow
        cmp PlayerRow
        bne proceed_to_reset_hazard
        ldx CurrentTile
        lda tile_index_to_col_lut, x ; A is now effectively CurrentCol
        cmp PlayerCol
        bne proceed_to_reset_hazard
do_nothing:
        rts
proceed_to_reset_hazard:
        ldx CurrentTile
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_AIR
        sta tile_attributes, x
        lda #0
        sta tile_data, x

        rts
.endproc

        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_activate_hazard_healing
HealingAmount := R0
TargetSquare := R13

TargetIndex := R0
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_data, x
        bne do_nothing

        ; Heal the player to full
        lda #128
        far_call FAR_receive_healing
        ; Play a cute SFX
        queue_sfx_triangle sfx_small_heart
        ; Apply 1 tick of "just healed" to the player, replacing any previous lingering status
        ; (this will also make them glow pink)
        lda #PlAYER_STAUTS_JUST_HEALED
        sta PlayerLingeringStatusType
        lda #1
        sta PlayerLingeringStatusDuration

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda #1
        sta tile_data, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_shock
TargetIndex := R0
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_data, x
        bne do_nothing

        ; TODO: do we need to manually throw the player into "shocked" state here, or will
        ; player logic pick up on this?
        ; TODO: how should we handle immunity from shock effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "shocked" to the player, replacing any previous lingering status
        lda #PlAYER_STATUS_SHOCKED
        sta PlayerLingeringStatusType
        lda #4
        sta PlayerLingeringStatusDuration
        ; For now, do this all manually
        lda #PLAYER_STATE_SHOCKED
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda #1
        sta tile_data, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_freeze
TargetIndex := R0
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_data, x
        bne do_nothing

        ; TODO: do we need to manually throw the player into "frozen" state here, or will
        ; player logic pick up on this?
        ; TODO: how should we handle immunity from freeze effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "frozen" to the player, replacing any previous lingering status
        lda #PlAYER_STATUS_FROZEN
        sta PlayerLingeringStatusType
        lda #4
        sta PlayerLingeringStatusDuration
        ; For now, do this all manually
        lda #PLAYER_STATE_FROZEN
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda #1
        sta tile_data, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_burn
TargetIndex := R0
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_data, x
        bne do_nothing

        ; TODO: do we need to manually throw the player into "burned" state here? is burned
        ; even a special state?
        ; TODO: how should we handle immunity from burn effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "burned" to the player, replacing any previous lingering status
        lda #PLAYER_STATUS_BURNED
        sta PlayerLingeringStatusType
        lda #4
        sta PlayerLingeringStatusDuration

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda #1
        sta tile_data, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_poison
TargetIndex := R0
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_data, x
        bne do_nothing

        ; TODO: do we need to manually throw the player into "poisoned" state here? is poison
        ; even a special state?
        ; TODO: how should we handle immunity from poison effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "poisoned" to the player, replacing any previous lingering status
        lda #PLAYER_STATUS_POISONED
        sta PlayerLingeringStatusType
        lda #4
        sta PlayerLingeringStatusDuration

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda #1
        sta tile_data, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc
