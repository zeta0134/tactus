; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc collect_small_heart
TargetIndex := R0
TileId := R1
TargetSquare := R13

        ; Add 1 to the player's health pool
        lda PlayerHealth
        clc
        adc #1
        sta PlayerHealth
        ; Now if we've just overhealed them...
        lda PlayerHealth
        cmp PlayerMaxHealth
        bcc not_overhealed
        ; ... then we set cap health to maximum
        lda PlayerMaxHealth
        sta PlayerHealth
not_overhealed:
        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD
        
        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile
        
        

        rts
.endproc