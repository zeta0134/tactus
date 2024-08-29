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

smoke_puff_lut:
smoke_puff_n:
        .word BG_TILE_DUST_N_PLAIN
        .word BG_TILE_DUST_N_PLAIN
        .word BG_TILE_DUST_N_SOLID
        .word BG_TILE_DUST_N_SOLID
        .word BG_TILE_DUST_N_SOLID
        .word BG_TILE_DUST_N_OUTLINE
        .word BG_TILE_DUST_N_OUTLINE
        .word BG_TILE_DUST_N_OUTLINE
smoke_puff_ne:
        .word BG_TILE_DUST_NE_PLAIN
        .word BG_TILE_DUST_NE_PLAIN
        .word BG_TILE_DUST_NE_SOLID
        .word BG_TILE_DUST_NE_SOLID
        .word BG_TILE_DUST_NE_SOLID
        .word BG_TILE_DUST_NE_OUTLINE
        .word BG_TILE_DUST_NE_OUTLINE
        .word BG_TILE_DUST_NE_OUTLINE
smoke_puff_e:
        .word BG_TILE_DUST_E_PLAIN
        .word BG_TILE_DUST_E_PLAIN
        .word BG_TILE_DUST_E_SOLID
        .word BG_TILE_DUST_E_SOLID
        .word BG_TILE_DUST_E_SOLID
        .word BG_TILE_DUST_E_OUTLINE
        .word BG_TILE_DUST_E_OUTLINE
        .word BG_TILE_DUST_E_OUTLINE
smoke_puff_se:
        .word BG_TILE_DUST_SE_PLAIN
        .word BG_TILE_DUST_SE_PLAIN
        .word BG_TILE_DUST_SE_SOLID
        .word BG_TILE_DUST_SE_SOLID
        .word BG_TILE_DUST_SE_SOLID
        .word BG_TILE_DUST_SE_OUTLINE
        .word BG_TILE_DUST_SE_OUTLINE
        .word BG_TILE_DUST_SE_OUTLINE
smoke_puff_s:
        .word BG_TILE_DUST_S_PLAIN
        .word BG_TILE_DUST_S_PLAIN
        .word BG_TILE_DUST_S_SOLID
        .word BG_TILE_DUST_S_SOLID
        .word BG_TILE_DUST_S_SOLID
        .word BG_TILE_DUST_S_OUTLINE
        .word BG_TILE_DUST_S_OUTLINE
        .word BG_TILE_DUST_S_OUTLINE
smoke_puff_sw:
        .word BG_TILE_DUST_SW_PLAIN
        .word BG_TILE_DUST_SW_PLAIN
        .word BG_TILE_DUST_SW_SOLID
        .word BG_TILE_DUST_SW_SOLID
        .word BG_TILE_DUST_SW_SOLID
        .word BG_TILE_DUST_SW_OUTLINE
        .word BG_TILE_DUST_SW_OUTLINE
        .word BG_TILE_DUST_SW_OUTLINE
smoke_puff_w:
        .word BG_TILE_DUST_W_PLAIN
        .word BG_TILE_DUST_W_PLAIN
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_OUTLINE
        .word BG_TILE_DUST_W_OUTLINE
        .word BG_TILE_DUST_W_OUTLINE
smoke_puff_nw:
        .word BG_TILE_DUST_W_PLAIN
        .word BG_TILE_DUST_W_PLAIN
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_W_OUTLINE
        .word BG_TILE_DUST_W_OUTLINE
        .word BG_TILE_DUST_W_OUTLINE

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
.proc draw_smoke_puff
TargetFuncPtr := R0
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldx setting_disco_floor
        lda disco_behavior_lut_low, x
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, x
        sta TargetFuncPtr+1
        jsr _disco_trampoline

        ora SmokePuffDirection
        asl ; expand from byte to word alignment
        tay
        ldx SmokePuffTile
        lda #TILE_SMOKE_PUFF
        sta battlefield, x
        lda smoke_puff_lut+0, y
        sta tile_patterns, x
        lda smoke_puff_lut+1, y
        sta tile_attributes, x
        rts
.endproc