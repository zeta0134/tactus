; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================


.proc update_semisafe_tile
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved
        
        ; After one beat, mark the semisafe tile as safe again, to clear out
        ; any past damage. We only want this tile to be dangerous on the beat that
        ; an attack occurs!
        ldx CurrentTile
        lda #0
        sta tile_data, x
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc semisolid_attacks_player
DamageAmount := R0

PuffSquare := R12
TargetSquare := R13
        ; if we have "stored" an attack, then hit the player with it (ouch!)
        ldx TargetSquare
        lda tile_data, x
        bne apply_damage
        rts

apply_damage:
        ; For now, the semisafe tile always does 2 damage to the player. Stronger
        ; attacks, if they exist, might need special consideration here?
        lda #2
        sta DamageAmount
        far_call FAR_damage_player
        
        ; Now we need to spawn a damage sprite. Using the original logic, the PuffSquare
        ; is where the enemy is standing (they never moved) and the TargetSquare is where
        ; the player is standing. To set this up, copy the tile_data (storing the attacking
        ; enemy's position) into the PuffSquare
        ldx TargetSquare
        lda tile_data, x
        sta PuffSquare
        jsr spawn_damage_sprite_here
        ; Finally, clear out our damage value, just to be extra sure it doesn't apply twice
        ldx TargetSquare
        lda #0
        sta tile_data, x
        rts
.endproc