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

smoke_puff_plain_lut:
        .word BG_TILE_DUST_N_PLAIN
        .word BG_TILE_DUST_NE_PLAIN
        .word BG_TILE_DUST_E_PLAIN
        .word BG_TILE_DUST_SE_PLAIN
        .word BG_TILE_DUST_S_PLAIN
        .word BG_TILE_DUST_SW_PLAIN
        .word BG_TILE_DUST_W_PLAIN
        .word BG_TILE_DUST_NW_PLAIN
smoke_puff_solid_lut:
        .word BG_TILE_DUST_N_SOLID
        .word BG_TILE_DUST_NE_SOLID
        .word BG_TILE_DUST_E_SOLID
        .word BG_TILE_DUST_SE_SOLID
        .word BG_TILE_DUST_S_SOLID
        .word BG_TILE_DUST_SW_SOLID
        .word BG_TILE_DUST_W_SOLID
        .word BG_TILE_DUST_NW_SOLID
smoke_puff_outline_lut:
        .word BG_TILE_DUST_N_OUTLINE
        .word BG_TILE_DUST_NE_OUTLINE
        .word BG_TILE_DUST_E_OUTLINE
        .word BG_TILE_DUST_SE_OUTLINE
        .word BG_TILE_DUST_S_OUTLINE
        .word BG_TILE_DUST_SW_OUTLINE
        .word BG_TILE_DUST_W_OUTLINE
        .word BG_TILE_DUST_NW_OUTLINE

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
.proc draw_smoke_puff
        ; The smoke puff needs to obey the same accesibility rules as the disco tile so
        ; that it meshes well with the underlying floor. Do all of those same checks here

        ; If the current room is cleared, we release the player from the perils of the tempo, and the
        ; floor stops dancing. (these would look very spastic if they flickered with the player's moves)
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne cleared_tile
        ; If we are in disco accessibility mode 3, treat all rooms as cleared for disco purposes,
        ; effectively suppressing the animation entirely
        lda setting_disco_floor
        cmp #DISCO_FLOOR_STATIC
        beq cleared_tile
        ; If we are in mode 2, don't draw the checkerboard pattern. Instead, treat all tiles as though
        ; they are unlit. This still allows the detail to dance with the music
        cmp #DISCO_FLOOR_NO_OUTLINE
        beq regular_tile

        ; Otherwise, we want to draw a checkerboard pattern, which alternates every time the beat advances
        ; we can do this with an XOR of these low bits: X coordinate, Y coordinate, Beat Counter
        lda SmokePuffRow
        eor SmokePuffTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile

        ; Here we diverge heavily; the smoke puff tiles have a completely different
        ; layout in memory. Note that smoke puffs now always use the world color, which
        ; diverges from their old behavior (they used to preserve the enemy color) since
        ; this looks weird with their disco floor variants
regular_tile:
        ; "regular" and "cleared" tiles are the same for smoke poffs
cleared_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda smoke_puff_plain_lut+0, y
        sta tile_patterns, x
        lda smoke_puff_plain_lut+1, y
        sta tile_attributes, x
        jmp converge
disco_tile:
        perform_zpcm_inc
        ; disco tiles have two accessibility modes: regular and outline, so handle that here
        lda setting_disco_floor
        cmp #DISCO_FLOOR_OUTLINE
        beq outlined_disco_tile
full_disco_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda smoke_puff_solid_lut+0, y
        sta tile_patterns, x
        lda smoke_puff_solid_lut+1, y
        sta tile_attributes, x
        jmp converge
outlined_disco_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda smoke_puff_outline_lut+0, y
        sta tile_patterns, x
        lda smoke_puff_outline_lut+1, y
        sta tile_attributes, x
        jmp converge

converge:
        ; draw_with_pal, adjusted for our temporary stash
        lda #TILE_SMOKE_PUFF
        sta battlefield, x
        rts
.endproc