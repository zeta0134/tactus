; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc attack_exit_block
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
        lda PlayerKeys
        beq no_key
        
        ; Register the attack as a hit
        ; (don't otherwise interfere with combat if the player doesn't have the key)
        lda #1
        sta AttackLanded

        ; Replace the exit block with the stairs down
        ldx AttackSquare
        stx TargetIndex
        lda #TILE_EXIT_STAIRS
        sta battlefield, x
        lda #0
        sta tile_data, x
        sta tile_flags, x
        lda #<BG_TILE_EXIT_STAIRS
        sta tile_patterns, x
        ; just in case, let's preserve the block color and draw the stairs the same way
        lda tile_attributes, x
        and #PAL_MASK
        ora #>BG_TILE_EXIT_STAIRS
        sta tile_attributes, x
        ; For attacks, immediately draw the resulting change
        jsr draw_active_tile

no_key:
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc descend_stairs
        st16 FadeToGameMode, advance_to_next_floor
        st16 GameMode, fade_to_game_mode        
        
        st16 R0, sfx_teleport
        jsr play_sfx_pulse1

        rts
.endproc