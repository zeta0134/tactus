; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

.proc ENEMY_UPDATE_mimic
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
        ; TODO: if we spawned a metasprite, clear that out so we know to
        ; re-generate it later.
        ; Mimic Behavior: If we are active, pick a new location and hide again.
        rts
.endproc

