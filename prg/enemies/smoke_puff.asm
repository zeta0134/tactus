; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_smoke_puff
CurrentTile := R15

        ; Do not revert to a disco tile if we are already updating today
        ldx CurrentTile
        bail_if_already_moved

        ; All a smoke puff needs to do is return to normal floor after one beat
        near_call ENEMY_UPDATE_draw_disco_tile
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_puff
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
        ldx EffectiveAttackSquare
        ldy battlefield, x
        lda indirect_attack_behaviors_low, y
        sta DestPtr+0
        lda indirect_attack_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc

; ============================================================================================================================
; ===                                    Explosion Attacks Enemy Behaviors                                                 ===
; ============================================================================================================================
        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_explode_puff
AttackSquare := R3
EffectiveAttackSquare := R10 
        
        ; A puff stores the tile index of the enemy that moved in its
        ; tile_data, so we'll roll an indirect attack on that square
        ldx AttackSquare
        lda tile_data, x
        sta EffectiveAttackSquare
        ldx EffectiveAttackSquare
        ldy battlefield, x
        lda indirect_explode_behaviors_low, y
        sta DestPtr+0
        lda indirect_explode_behaviors_high, y
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc

        .segment "ENEMY_UPDATE"

smoke_puff_lut:
smoke_puff_n:
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_N, OFFSET_PLAIN
smoke_puff_ne:
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_NE, OFFSET_PLAIN
smoke_puff_e:
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_E, OFFSET_PLAIN
smoke_puff_se:
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_SE, OFFSET_PLAIN
smoke_puff_s:
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_S, OFFSET_PLAIN
smoke_puff_sw:
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_SW, OFFSET_PLAIN
smoke_puff_w:
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_W, OFFSET_PLAIN
smoke_puff_nw:
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_SOLID_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_SOLID_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_OUTLINE_GROWING
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_OUTLINE_STATIC
        directional_tile_offset "DUST_TILES", OFFSET_NW, OFFSET_PLAIN

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
.proc ENEMY_UPDATE_draw_smoke_puff
TargetFuncPtr := R0
        perform_zpcm_inc
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldx current_save + SaveFile::OptionDiscoFloor
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
        perform_zpcm_inc
        rts
.endproc
