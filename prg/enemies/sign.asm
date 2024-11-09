        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_player_reads_sign
TargetSquare := R13

    ldx TargetSquare
    lda tile_data, x
    far_call FAR_display_sign_text

    ldx PlayerRow
    lda row_number_to_tile_index_lut, x
    clc
    adc PlayerCol
    sta PlayerActiveDialogSquare

    near_call ENEMY_COLLIDE_forbid_player_movement
    rts
.endproc
