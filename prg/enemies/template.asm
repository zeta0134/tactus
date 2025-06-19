; Note: do not include. Intentionally minimal, meant as a base for new
; enemy types. If this enemy were to actually spawn, it behaves like am
; attackable wall tile that dies in one hit.

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE0"

.proc ENEMY_UPDATE_update_template
    rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_template
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
        near_call ENEMY_ATTACK_attack_template_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_template
        near_call ENEMY_ATTACK_attack_template_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_template_common
; For drawing tiles
TargetIndex := R0
TileId := R1

OriginalAttackSquare := R3

EffectiveAttackSquare := R10 
        ; Register the attack as a hit
        lda #1
        sta WeaponAttackLanded

        ; proc any items that depend on the enemy we are about to slay
        ; (do this BEFORE we replace ourselves with a floor tile)
        far_call FAR_proc_items_on_enemy_slain

        ; For an enemy with no health, just erase it and replace with
        ; a disco tile
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

        ; An enemy died! Increment the player's ongoing combo
        inc PlayerCombo

        ; spawn LOOT upon defeat
        set_loot_table SLIME_LOOT_TABLE
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
