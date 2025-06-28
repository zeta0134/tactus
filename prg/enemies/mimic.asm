; A mimic disguises itself as any of the three chest types, with
; slightly wrong artwork in the standard chest case. They occasionally
; fidget as a tell. When attacked, or approached while carrying the
; interrogation beam, a mimic becomes enraged and charges very quickly
; in the player's direction, before settling into a "red zombie" pattern.
; Should the player leave the room, the mimic will reposition and disguise
; itself once more. Upon defeat, the treasure the mimic was carrying is
; dropped just like any other chest. Mimics do NOT maintain an item preview,
; which is yet another tell. (Also this would be hard to coordinate, we are
; very state-bit poor with the things.)


MIMIC_FLAGS_STATE        = %01110000
MIMIC_FLAGS_HP           = %00001111

MIMIC_STATE_DISGUISED    = %00000000
MIMIC_STATE_ENRAGED_0    = %00010000
MIMIC_STATE_ENRAGED_1    = %00100000
MIMIC_STATE_ENRAGED_2    = %00110000
MIMIC_STATE_ENRAGED_3    = %01000000
MIMIC_STATE_IDLE         = %01010000
MIMIC_STATE_ANTICIPATE   = %01100000

.macro mimic_set_state target_state
        lda tile_flags, x
        and #($FF - MIMIC_FLAGS_STATE)
        ora target_state
        sta tile_flags, x
.endmacro

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

mimic_update_dispatch_lut:
        .addr ENEMY_UPDATE_mimic_disguised
        .addr ENEMY_UPDATE_mimic_enraged_0
        .addr ENEMY_UPDATE_mimic_enraged_1
        .addr ENEMY_UPDATE_mimic_enraged_2
        .addr ENEMY_UPDATE_mimic_enraged_3
        .addr ENEMY_UPDATE_mimic_idle
        .addr ENEMY_UPDATE_mimic_anticipate
        .addr ENEMY_UPDATE_mimic_idle ; should never be hit

.proc ENEMY_UPDATE_mimic
DestFunc := R0
CurrentRow := R14
CurrentTile := R15
        ; A mimic always counts as active, even while disguised.
        ; This is the player's most obvious tell, for all mimic types.
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; dispatch to our actual state handler
        ldx CurrentTile
        lda tile_flags, x
        and #MIMIC_FLAGS_STATE
        lsr
        lsr
        lsr
        tay
        lda mimic_update_dispatch_lut+0, y
        sta DestFunc+0
        lda mimic_update_dispatch_lut+1, y
        sta DestFunc+1
        jmp (DestFunc)
        ; tail call
.endproc

.proc ENEMY_UPDATE_mimic_disguised
; for draw_active_tile
TargetIndex := R0
CurrentTile := R15
        ; If the player has the interrogation beam...
        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_INTERROGATION_BEAM
        bne do_not_proc_interrogation_beam
        ; ... AND the player is standing close enough to the mimic
        ldy CurrentTile
        lda (PlayerDistanceLut), y
        cmp #MIMIC_INTERROGATION_BEAM_ACTIVATION_RADIUS
        bcs do_not_proc_interrogation_beam
        ; ... then switch to our enraged state and charge at the player,
        ; just like we normally do when taking a hit
        ldx CurrentTile
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        mimic_set_state #MIMIC_STATE_ENRAGED_0
        ; right now!
        stx TargetIndex
        jsr draw_active_tile
        ; roar, but delayed
        queue_sfx_pulse1 sfx_roar_pulse1
        queue_sfx_pulse2 sfx_roar_pulse2
        ; and do a delayed palette cycle (we're a bit past the start of the current beat)
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase
        ; now actually process the enraged behavior right away, for timing reasons
        jmp ENEMY_UPDATE_mimic_enraged_0
do_not_proc_interrogation_beam:

        ; While disguised, a mimic has a small (1/16) chance to fidget, which acts as a visual tell
        ; to very observant players.
        ldx CurrentTile
        prng_from_table_y
        and #$F
        beq fidget
do_not_fidget:
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_LARGE_CHEST
        rts
fidget:
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_FIDGET
        rts
.endproc

.proc ENEMY_UPDATE_mimic_enraged_0
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_ENRAGED_1
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        jsr _mimic_chase_player
        rts
.endproc

.proc ENEMY_UPDATE_mimic_enraged_1
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_ENRAGED_2
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        jsr _mimic_chase_player
        rts
.endproc

.proc ENEMY_UPDATE_mimic_enraged_2
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_ENRAGED_3
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        jsr _mimic_chase_player
        rts
.endproc

.proc ENEMY_UPDATE_mimic_enraged_3
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_IDLE
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_IDLE
        jsr _mimic_chase_player
        rts
.endproc

.proc ENEMY_UPDATE_mimic_idle
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_ANTICIPATE
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        rts
.endproc

.proc ENEMY_UPDATE_mimic_anticipate
CurrentTile := R15
        ldx CurrentTile
        mimic_set_state #MIMIC_STATE_IDLE
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_IDLE
        jsr _mimic_chase_player
        rts
.endproc

.proc _mimic_chase_player
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; Mimics always target the player. The player is TASTY!
        far_call ENEMY_UPDATE_target_player_cardinal
        lda ValidDestination
        cmp #$FF
        bne proceed_with_jump
jump_failed:
        lda SemisafeDestination
        cmp #$FF
        bne make_target_dangerous
        jmp return_to_idle_without_moving
make_target_dangerous:
        ; write our own position into the target tile, as this will help
        ; the damage sprite to spawn in the right location if the player
        ; takes the hit
        ldx SemisafeDestination
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
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_IDLE
        rts

proceed_with_jump:        
        ldx CurrentTile
        ldy ValidDestination
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_MIMIC, BG_TILE_MIMIC_IDLE
        ; Copy all of our data to the new tile
        lda tile_data, x
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda ValidDestination
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw the puff of smoke at our current location
        ; (this clobbers X and Y, so we prefer to do it last)
        lda CurrentTile
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        far_call ENEMY_UPDATE_draw_smoke_puff

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_mimic
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
        near_call ENEMY_ATTACK_attack_mimic_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_mimic
        near_call ENEMY_ATTACK_attack_mimic_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_mimic_common
; For drawing tiles
TargetIndex := R0
TileId := R1

; Damage done by the weapon swing
WeaponDmg := R0

OriginalAttackSquare := R3
EffectiveAttackSquare := R10 

        ; Register the attack as a hit
        lda #1
        sta WeaponAttackLanded

        ; Add the player's currently equipped damage to our flags byte
        far_call FAR_weapon_dmg ; clobbers X,Y, result in R0
        lda WeaponDmg
        ; now add that to our running HP total
        ldx EffectiveAttackSquare
        clc
        adc tile_flags, x
        sta tile_flags, x
        ; Now check: if the damage, NOT including the movement bit, is greater than our health...
        and #MIMIC_FLAGS_HP
        cmp #MIMIC_SHARED_HP
        bcs die

        ; If we were not already enraged, we certainly are now. Detect that and do the thing
        lda tile_flags, x
        and #MIMIC_FLAGS_STATE
        cmp #MIMIC_STATE_DISGUISED
        bne not_disguised
become_enraged:
        ; switch to the first enraged state
        mimic_set_state #MIMIC_STATE_ENRAGED_0
        ; redraw ourselves with our pearly whites
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_MIMIC_ANTICIPATE
        stx TargetIndex
        jsr draw_active_tile
        ; no need to palette cycle, as we just took damage, but we *should* roar with
        ; fairly high priority
        queue_sfx_pulse1 sfx_roar_pulse1
        queue_sfx_pulse2 sfx_roar_pulse2
not_disguised:

        ; we took a hit and did not die, so do the palette cycle thing
        lda EffectiveAttackSquare
        jsr queue_palette_cycle

        ; and for mimics that should be it
        rts

die:
        ; proc any items that depend on the enemy we are about to slay
        ; (do this BEFORE we replace ourselves with a floor tile)
        far_call FAR_proc_items_on_enemy_slain

        ; TODO: for enemies that are earthen when defeated, we should roll for
        ; the special loot table here

        ; Mimics should revert to an item shadow, whose data contains
        ; the item we wanted to spawn, just like opening a chest
        ldx OriginalAttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH
        lda #0
        sta tile_flags, x
        jsr draw_active_tile
        ; Also, if the mimic moved, then we must clean up its destination square
        lda OriginalAttackSquare
        cmp EffectiveAttackSquare
        beq mimic_was_stationary
mimic_moved:
        ; we need to move our data byte to the item square!
        ldx EffectiveAttackSquare
        lda tile_data, x
        ldy OriginalAttackSquare
        sta tile_data, y
        ; Okay, now turn the target square back into a disco tile
        ldx EffectiveAttackSquare
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile
mimic_was_stationary:

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        near_call ENEMY_ATTACK_spawn_death_sprite_here

        ; An enemy died! Increment the player's ongoing combo
        inc PlayerCombo

        ; spawn LOOT upon defeat. mimics do contain loot, and quite a bit of it.
        set_loot_table MIMIC_LOOT_TABLE
        roll_loot_at OriginalAttackSquare

        ; Play an appropriately crunchy death sound
        queue_sfx_pulse1 sfx_defeat_enemy_pulse
        queue_sfx_noise sfx_defeat_enemy_noise

        lda #1
        sta EnemyDiedThisFrame

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        ; Increase the player's warp stability any time they kill a common foe (via any means)
        increase_warp_stability

        rts
.endproc

; ============================================================================================================================
; ===                               Explosion / Spell Attacks Enemy Behaviors                                              ===
; ============================================================================================================================

        .segment "ENEMY_BOMB_SPELL"

mimic_spell_lut:
        .word ENEMY_BOMB_SPELL_mimic_elemental_attack ; SPELL_FIRE
        .word ENEMY_BOMB_SPELL_mimic_elemental_attack ; SPELL_AIR
        .word ENEMY_BOMB_SPELL_mimic_elemental_attack ; SPELL_ICE
        .word ENEMY_BOMB_SPELL_mimic_elemental_attack ; SPELL_EARTH
        .word FIXED_no_behavior                ; SPELL_BOMB
        .word FIXED_no_behavior                ; SPELL_LIFE

.proc ENEMY_BOMB_SPELL_mimic_spell_dispatch
DispatchPtr := R0
;Length := R13
CurrentRow := R14
CurrentTile := R15
        lda CurrentlyActiveSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        ; Safety: don't call a spell effect that doesn't exist
        ; (This shouldn't happen, but crashing is no fun)
        cmp #LAST_SPELL_IN_ITEM_LIST
        bcc safe_to_dispatch
        rts
safe_to_dispatch:
        asl
        tax
        lda mimic_spell_lut+0, x
        sta DispatchPtr+0
        lda mimic_spell_lut+1, x
        sta DispatchPtr+1
        jmp (DispatchPtr)
        ; does not return
.endproc

.proc ENEMY_BOMB_SPELL_mimic_elemental_attack
EnemyHealth := R12

CurrentRow := R14
CurrentTile := R15
        lda #4
        sta EnemyHealth

        near_call ENEMY_BOMB_SPELL_regular_enemy_elemental_spell_common

        ; TODO: cleanup if we were slain! (probably need to despawn that metasprite
        ; at the very least, and spawn the loot we were carrying)

        rts
.endproc


.proc ENEMY_BOMB_SPELL_mimic_direct_explode
AttackSquare := R3
EffectiveAttackSquare := R10
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_BOMB_SPELL_explode_common
        ; TODO: cleanup and spawn loot
        rts
.endproc

.proc ENEMY_BOMB_SPELL_mimic_indirect_explode
AttackSquare := R3
EffectiveAttackSquare := R10
        near_call ENEMY_BOMB_SPELL_explode_common
        ; TODO: cleanup and spawn loot
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_suspend_mimic
CurrentSquare := R15
        ; Mimic Behavior: If we are active, disguise ourselves and, if necessary, relocate away
        ; from the map edge.
        ldx CurrentSquare
        mimic_set_state #MIMIC_STATE_DISGUISED
        draw_at_x_keeppal TILE_MIMIC, BG_TILE_LARGE_CHEST
        near_call ENEMY_UTIL_move_away_from_map_edge
        rts
.endproc

