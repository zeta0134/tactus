; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

HELPFUL_CHEST_STATE_INIT = 0
HELPFUL_CHEST_STATE_UPDATE = 1

.proc _reroll_helpful_chest_item
CurrentTile := R15
        perform_zpcm_inc
spawn_item:
        access_data_bank PlayerZoneBank
        ldy #ZoneDefinition::StandardChestLootTable
        lda (PlayerZonePtr), y
        sta ItemLootTable+0
        iny
        lda (PlayerZonePtr), y
        sta ItemLootTable+1
        st16 ItemFallbackLootTable, fallback_standard_chest_table
        restore_previous_bank
        far_call FAR_roll_gameplay_loot
        ldx CurrentTile
        lda ResultItemId
        sta tile_data, x
        perform_zpcm_inc
        rts
.endproc

.proc ENEMY_UPDATE_helpful_chest
        jsr _reroll_helpful_chest_item
        ; TODO: preview that item if the player has the appropriate accessory
        rts
.endproc

.proc ENEMY_UPDATE_large_chest
        ; TODO
        rts
.endproc

.proc ENEMY_UPDATE_challenge_chest
        ; TODO
        rts
.endproc

.proc ENEMY_UPDATE_timed_chest
        ; TODO
        rts
.endproc

; For level generation reasons, the hidden chests are split out into separate tile IDs.
; This is because the attribute, which would normally indicate rarity, is being used as
; part of whatever wall tile they end up embedded within. "Blue zones tend to have better
; loot" would be an interesting spice, but... no, we want actual control thanks XD

.proc ENEMY_UPDATE_hidden_chest
        ; TODO
        rts
.endproc

.proc ENEMY_UPDATE_hidden_rare_chest
        ; TODO
        rts
.endproc

.proc ENEMY_UPDATE_hidden_legendary_chest
        ; TODO
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_open_unlocked_chest
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
WeaponPtr := R11
        ; Register the attack as a hit
        lda #1
        sta WeaponAttackLanded
        
        ; TODO: if we have any sprites spawned, clean them up!

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        rts
.endproc

; ============================================================================================================================
; ===                                      Enemy Attacks Player Behaviors                                                  ===
; ============================================================================================================================
 

        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_open_unlocked_chest
TargetIndex := R0
TargetSquare := R13
        ; We behave like a wall on this beat, so we still want to push the player
        ; back if we can.
        ; But we also go ahead and open, which permits movement that is not an attack
        ; to still open the chest. This mostly helps to resolve situations with weapons that
        ; don't "attack" the square in the direction the player is moving.

        ; TODO: if we have any sprites spawned, clean them up!

        ; Mostly easy: replace the chest with an item shadow
        ldx TargetSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        ; Play the "weapon slash" sfx, just like if an attack had occurred, which functions as our
        ; "open chest" SFX in any other context. 
        queue_sfx_noise sfx_weapon_slash

        near_call ENEMY_COLLIDE_solid_tile_forbids_movement

        rts
.endproc

; TODO: rework this into an item? (what color will it be?)
; Alternate: rework it *properly* into an entity that follows the player
; (and can be stolen!)
.proc ENEMY_COLLIDE_collect_key
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda #1 ; there is only one key per dungeon floor
        sta PlayerKeys

        queue_sfx_pulse1 sfx_key_pulse1
        queue_sfx_pulse2 sfx_key_pulse2

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_EARTH

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; This is the big key! Now that we have it, reveal the location of the exit
        ; stairs (this stops the player from needing to do a brute-force search)
        ldx #0
find_exit_loop:
        perform_zpcm_inc
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq next_room
        lda room_minimap_state, x
        ora #ROOM_MINIMAP_FLAG_IDENTIFIED
        sta room_minimap_state, x
next_room:
        inx
        cpx #::FLOOR_SIZE
        bne find_exit_loop

        lda #1
        sta HudMapDirty

        rts
.endproc


; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_suspend_helpful_chest
        ; TODO: if we spawned a metasprite, clear that out so we know to
        ; re-generate it later.
        rts
.endproc

.proc ENEMY_UTIL_suspend_large_chest
        ; TODO: if we spawned a metasprite, clear that out so we know to
        ; re-generate it later.
        rts
.endproc

.proc ENEMY_UTIL_suspend_challenge_chest
        ; TODO: clear out our unconditional metasprite (the skull thingy)
        ; TODO: if we spawned a metasprite, clear that out so we know to
        ; re-generate it later.
        rts
.endproc

.proc ENEMY_UTIL_suspend_timed_chest
        ; TODO: clear out our unconditional metasprite (the timer halves)
        ; TODO: if we spawned a metasprite, clear that out so we know to
        ; re-generate it later.
        rts
.endproc

