; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc update_smoke_puff
        ; All a smoke puff needs to do is return to normal floor after one beat
        jsr draw_disco_tile
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc direct_attack_puff
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9
; Indirect target square, so the tile we attack knows its own location
EffectiveAttackSquare := R10 

; We don't use these, but we should know not to clobber them
TargetRow := R14
TargetCol := R15
        
        ; A puff stores the tile index of the enemy that moved in its
        ; tile_data, so we'll roll an indirect attack on that square
        ldx AttackSquare
        lda tile_data, x
        sta EffectiveAttackSquare
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        ldx EffectiveAttackSquare
        lda battlefield, x
        lsr
        and #%01111110
        tax
        lda indirect_attack_behaviors, x
        sta DestPtr
        lda indirect_attack_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc