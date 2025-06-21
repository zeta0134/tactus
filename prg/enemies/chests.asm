; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

.proc ENEMY_UPDATE_helpful_chest
        ; TODO
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
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; TODO: open the chest and spawn its contents
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

