; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"
; TODO: this might be going away! it might also switch to being
; some temporary part of the room state, a sprite, etc etc.
.proc ENEMY_COLLIDE_collect_small_heart
HealingAmount := R0

TargetIndex := R0
TileId := R1
TargetSquare := R13

        lda #4
        sta HealingAmount
        far_call FAR_receive_healing

        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD
        
        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile
        
        

        rts
.endproc
