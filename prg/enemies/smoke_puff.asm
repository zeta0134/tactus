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

OFFSET_N  =  0 * 4
OFFSET_NE =  5 * 4
OFFSET_E  = 10 * 4
OFFSET_SE = 15 * 4
OFFSET_S  = 20 * 4
OFFSET_SW = 25 * 4
OFFSET_W  = 30 * 4
OFFSET_NW = 35 * 4

OFFSET_PLAIN           = 0 * 4
OFFSET_SOLID_GROWING   = 1 * 4
OFFSET_SOLID_STATIC    = 2 * 4
OFFSET_OUTLINE_GROWING = 3 * 4
OFFSET_OUTLINE_STATIC  = 4 * 4
; note: use "PLAIN" for the shrinking variants; the
; early bit of the animation will hide the lack of a tile underneath, and
; that combination isn't supposed to show up anyway for game logic reasons

smoke_puff_lut:
smoke_puff_n:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_N + OFFSET_PLAIN
smoke_puff_ne:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
smoke_puff_e:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_E + OFFSET_PLAIN
smoke_puff_se:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
smoke_puff_s:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_S + OFFSET_PLAIN
smoke_puff_sw:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
smoke_puff_w:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_W + OFFSET_PLAIN
smoke_puff_nw:
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_SOLID_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_SOLID_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_OUTLINE_GROWING
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_OUTLINE_STATIC
        .word BG_TILE_DUST_TILES_0000 + OFFSET_NW + OFFSET_PLAIN

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