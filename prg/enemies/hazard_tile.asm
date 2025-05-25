; These are mostly for testing the hazard system. I'm not sure we'll
; keep these behaviors in this form? Unclear. Play it by ear I guess.

HAZARD_TILE_FLAG_INACTIVE = %00000001

 ; up to 15 dmg, which is almost 4 hearts, is absolutely nuts for one attack
HAZARD_TILE_DATA_DMG_AMOUNT      = %00001111
; up to 15 "musical beats" is plenty; almost nothing should need this
HAZARD_TILE_DATA_DEBUFF_DURATION = %11110000

        .segment "ENEMY_UPDATE0"
.proc ENEMY_UPDATE_update_hazard_tile
; these are provided for us
CurrentRow := R14
CurrentTile := R15

        ; As a special case, if our data happens to be exactly $00, we are inert! This means
        ; we are actually a hazard tile loaded in as part of a fixed map, and not spawned in manually.
        ; Here, set default parameters based on our type
        ldx CurrentTile
        lda tile_data, x
        bne data_is_valid
        lda battlefield, x
        cmp #TILE_HAZARD_POISON
        beq apply_poison_settings
        cmp #TILE_HAZARD_FREEZE
        beq apply_freeze_settings
        cmp #TILE_HAZARD_SHOCK
        beq apply_shock_settings
        cmp #TILE_HAZARD_BURN
        beq apply_burn_settings
apply_default_settings:
        ; for healing I guess?
        lda #$11 ; 7 beats, 1 initial dmg, 2 hearts total
        sta tile_data, x
        jmp data_is_valid
apply_poison_settings:
        lda #$71 ; 7 beats, 1 initial dmg, 2 hearts total
        sta tile_data, x
        jmp data_is_valid
apply_freeze_settings:
        lda #$44 ; 4 taps to unfreeze, 4 initial dmg, 1 heart total
        sta tile_data, x
        jmp data_is_valid
apply_shock_settings:
        lda #$44 ; 4 shock beats, 4 initial dmg, 1 heart total
        sta tile_data, x
        jmp data_is_valid
apply_burn_settings:
        lda #$84 ; 8 burn beats, 4 initial dmg, 1 heart total (and many more if the player isn't careful)
        sta tile_data, x
        jmp data_is_valid
data_is_valid:

        ; If we're not tripped then there's not much to do
        ldx CurrentTile
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
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
        lda tile_flags, x
        and #($FF - HAZARD_TILE_FLAG_INACTIVE)
        sta tile_flags, x

        rts
.endproc

        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_activate_hazard_healing
HealingAmount := R0

TargetIndex := R0
TargetSquare := R13

        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
        bne do_nothing

        ; This tile has no special parameters. Each time it is activated for any
        ; reason, the player is fully healed.

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
        lda tile_flags, x
        ora #HAZARD_TILE_FLAG_INACTIVE
        sta tile_flags, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_shock
DamageAmount := R0

TargetIndex := R0
HazardDuration := R1
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
        bne do_nothing

        ; If this hazard tile specifies damage, apply that now
        lda tile_data, x
        and #HAZARD_TILE_DATA_DMG_AMOUNT
        beq done_applying_damage
        sta DamageAmount
        far_call FAR_damage_player
done_applying_damage:

        ; Grab the hazard duration from the tile data. Should we not apply a hazard
        ; (meaning we only applied elementally-aligned incoming damage) then do nothing
        ldx TargetSquare
        lda tile_data, x
        and #HAZARD_TILE_DATA_DEBUFF_DURATION
        beq done_applying_lingering_status
        .repeat 4
        lsr
        .endrepeat
        sta HazardDuration

        ; TODO: do we need to manually throw the player into "shocked" state here, or will
        ; player logic pick up on this?
        ; TODO: how should we handle immunity from shock effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "shocked" to the player, replacing any previous lingering status
        lda #PlAYER_STATUS_SHOCKED
        sta PlayerLingeringStatusType
        lda HazardDuration
        sta PlayerLingeringStatusDuration
        ; For now, do this all manually
        lda #PLAYER_STATE_SHOCKED
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
done_applying_lingering_status:

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda tile_flags, x
        ora #HAZARD_TILE_FLAG_INACTIVE
        sta tile_flags, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_freeze
DamageAmount := R0

TargetIndex := R0
HazardDuration := R1
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
        bne do_nothing

        ; If this hazard tile specifies damage, apply that now
        lda tile_data, x
        and #HAZARD_TILE_DATA_DMG_AMOUNT
        beq done_applying_damage
        sta DamageAmount
        far_call FAR_damage_player
done_applying_damage:

        ; Grab the hazard duration from the tile data. Should we not apply a hazard
        ; (meaning we only applied elementally-aligned incoming damage) then do nothing
        ldx TargetSquare
        lda tile_data, x
        and #HAZARD_TILE_DATA_DEBUFF_DURATION
        beq done_applying_lingering_status
        .repeat 4
        lsr
        .endrepeat
        sta HazardDuration

        ; TODO: do we need to manually throw the player into "frozen" state here, or will
        ; player logic pick up on this?
        ; TODO: how should we handle immunity from freeze effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "frozen" to the player, replacing any previous lingering status
        lda #PlAYER_STATUS_FROZEN
        sta PlayerLingeringStatusType
        lda HazardDuration
        sta PlayerLingeringStatusDuration
        ; For now, do this all manually
        lda #PLAYER_STATE_FROZEN
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
done_applying_lingering_status:

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda tile_flags, x
        ora #HAZARD_TILE_FLAG_INACTIVE
        sta tile_flags, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_burn
DamageAmount := R0

TargetIndex := R0
HazardDuration := R1
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
        bne do_nothing

        ; If this hazard tile specifies damage, apply that now
        lda tile_data, x
        and #HAZARD_TILE_DATA_DMG_AMOUNT
        beq done_applying_damage
        sta DamageAmount
        far_call FAR_damage_player
done_applying_damage:

        ; Grab the hazard duration from the tile data. Should we not apply a hazard
        ; (meaning we only applied elementally-aligned incoming damage) then do nothing
        ldx TargetSquare
        lda tile_data, x
        and #HAZARD_TILE_DATA_DEBUFF_DURATION
        beq done_applying_lingering_status
        .repeat 4
        lsr
        .endrepeat
        sta HazardDuration

        ; TODO: do we need to manually throw the player into "burned" state here? is burned
        ; even a special state?
        ; TODO: how should we handle immunity from burn effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "burned" to the player, replacing any previous lingering status
        lda #PLAYER_STATUS_BURNED
        sta PlayerLingeringStatusType
        lda HazardDuration
        sta PlayerLingeringStatusDuration
done_applying_lingering_status:

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda tile_flags, x
        ora #HAZARD_TILE_FLAG_INACTIVE
        sta tile_flags, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc

.proc ENEMY_COLLIDE_activate_hazard_poison
DamageAmount := R0

TargetIndex := R0
HazardDuration := R1
TargetSquare := R13
        ; If we're inactive, do nothing
        ldx TargetSquare
        lda tile_flags, x
        and #HAZARD_TILE_FLAG_INACTIVE
        bne do_nothing

        ; If this hazard tile specifies damage, apply that now
        lda tile_data, x
        and #HAZARD_TILE_DATA_DMG_AMOUNT
        beq done_applying_damage
        sta DamageAmount
        far_call FAR_damage_player
done_applying_damage:

        ; Grab the hazard duration from the tile data. Should we not apply a hazard
        ; (meaning we only applied elementally-aligned incoming damage) then do nothing
        ldx TargetSquare
        lda tile_data, x
        and #HAZARD_TILE_DATA_DEBUFF_DURATION
        beq done_applying_lingering_status
        .repeat 4
        lsr
        .endrepeat
        sta HazardDuration

        ; TODO: do we need to manually throw the player into "poisoned" state here? is poison
        ; even a special state?
        ; TODO: how should we handle immunity from poison effects? We might need a player far_call
        ; here to apply effects, rather than putting the logic in the source?
        ; Apply 4 ticks of "poisoned" to the player, replacing any previous lingering status
        lda #PLAYER_STATUS_POISONED
        sta PlayerLingeringStatusType
        lda HazardDuration
        sta PlayerLingeringStatusDuration
done_applying_lingering_status:

        ; Finally, "trip" this tile, so that it doesn't repeatedly re-apply its effect. We'll
        ; reset it when the player steps elsewhere.
        ldx TargetSquare
        lda tile_attributes, x
        and #($FF - PAL_MASK)
        ora #PAL_EARTH
        sta tile_attributes, x
        lda tile_flags, x
        ora #HAZARD_TILE_FLAG_INACTIVE
        sta tile_flags, x

        stx TargetIndex
        jsr draw_active_tile
    
do_nothing:
        rts
.endproc
