; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

HELPFUL_CHEST_STATE_INIT = 0
HELPFUL_CHEST_STATE_UPDATE = 1

.proc _reroll_helpful_chest_item
CurrentTile := R15
LootTablePtr := R16
ItemId := R18
        perform_zpcm_inc
spawn_item:
        access_data_bank PlayerZoneBank
        ldy #ZoneDefinition::StandardChestLootTable
        lda (PlayerZonePtr), y
        sta LootTablePtr+0
        iny
        lda (PlayerZonePtr), y
        sta LootTablePtr+1
        restore_previous_bank
        far_call FAR_roll_gameplay_loot
        ldx CurrentTile
        lda ItemId
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

.proc ENEMY_ATTACK_open_helpful_chest
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

.proc ENEMY_ATTACK_open_large_chest
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; TODO: open the chest and spawn its contents
        rts
.endproc

; ============================================================================================================================
; ===                                      Enemy Attacks Player Behaviors                                                  ===
; ============================================================================================================================
 

        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_open_helpful_chest
        near_call ENEMY_COLLIDE_solid_tile_forbids_movement

        ; TODO: if the player bumps us somehow, treat it like an attack
        ; and open the chest. This mostly works around an awkward Combat
        ; Anchor interaction, since it doesn't attack the forward tile.
        rts
.endproc


.proc ENEMY_COLLIDE_open_large_chest
        near_call ENEMY_COLLIDE_solid_tile_forbids_movement

        ; TODO: if the player bumps us somehow, treat it like an attack
        ; and open the chest. This mostly works around an awkward Combat
        ; Anchor interaction, since it doesn't attack the forward tile.
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

