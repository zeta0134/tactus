; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_challenge_spike
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        ; we can use our current graphics tile to store our state... but I don't want to. I want
        ; to experiment with using tile_data to store an index instead. So do that; it's initialized
        ; to 0 for us (usually), we'll treat that as the "lowered" state
        ldx CurrentTile
        lda tile_data, x
        beq lowered_state
        cmp #1
        beq rising_state
        cmp #2
        beq risen_state
        jmp lowering_state
lowered_state:
        ; if the room is currently cleared, then *stay* lowered
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq check_player_coordinates
        rts ; nothing to do
check_player_coordinates:
        ; we can only safely rise if the player is within the room bounds. here, we hard-code those to
        ; exclude the leftmost 2, rightmost 2, topmost 2, and bottommost 1 tiles
        lda PlayerRow
        cmp #2
        bcc player_coordinates_invalid
        cmp #(BATTLEFIELD_HEIGHT-1)
        bcs player_coordinates_invalid
        lda PlayerCol
        cmp #2
        bcc player_coordinates_invalid
        cmp #(BATTLEFIELD_WIDTH-2)
        bcs player_coordinates_invalid
        ; the player is in the challenge arena, dancing with foes!
        ; WE RISE!
        ldx CurrentTile
        lda #1
        sta tile_data, x
        draw_at_x_keeppal TILE_CHALLENGE_SPIKES, BG_TILE_SPIKES_RISING
        ; fall through to RTS; we're done here
player_coordinates_invalid:
        rts
rising_state:
        ; once we've started to rise, we will complete the motion. switch to the
        ; risen state and exit
        ldx CurrentTile
        lda #2
        sta tile_data, x
        draw_at_x_keeppal TILE_CHALLENGE_SPIKES, BG_TILE_SPIKES_RAISED
        rts
risen_state:
        ; if the room is currently cleared, then it's time to lower
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne begin_lowering
        rts ; nothing to do
begin_lowering:
        ldx CurrentTile
        lda #3
        sta tile_data, x
        draw_at_x_keeppal TILE_CHALLENGE_SPIKES, BG_TILE_SPIKES_LOWERING
        rts
lowering_state:
        ; once we've started to lower, we will complete the motion. switch to the
        ; lowered state and exit. this completes the loop; unless the room becomes
        ; non-cleared again, the spikes will stay grounded.
        ldx CurrentTile
        lda #0
        sta tile_data, x
        draw_at_x_keeppal TILE_CHALLENGE_SPIKES, BG_TILE_SPIKES_LOWERED
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_challenge_spike_solid_test
TargetSquare := R13
TargetRow := R14
TargetCol := R15
        ; the spikes are solid only if they are in some state
        ; other than 0
        ldx TargetSquare
        lda tile_data, x
        beq no_collision
        near_call ENEMY_COLLIDE_forbid_player_movement
no_collision:
        rts
.endproc
