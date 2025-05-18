; BG_TILE_TEPELORT_AFTERIMAGE_FILLED = $28a8
; BG_TILE_TEPELORT_AFTERIMAGE_OUTLINE = $28ac
; BG_TILE_TEPELORT_AFTERIMAGE_PLAIN = $28b0

; BG_TILE_CULTIST_FEET_GLOWING = $2018
; BG_TILE_CULTIST_HANDS_ON_GROUND = $201c
; BG_TILE_CULTIST_HANDS_RAISED = $2020
; BG_TILE_CULTIST_IDLE = $2024
; BG_TILE_CULTIST_KNOCKED_BACK = $2028

; BG_TILE_WARNING_FILLED = $28c4
; BG_TILE_WARNING_OUTLINE = $28c8
; BG_TILE_WARNING_PLAIN = $28cc

CULTIST_FLAGS_STATE        = %00000111
CULTIST_FLAGS_HP           = %01111000

; Why store this again? because we may be HIT by a player spell, and change our color, between beats!
CULTIST_DATA_SPELL_COLOR   = %11000000
CULTIST_DATA_SPELL_PATTERN = %00111000
CULTIST_DATA_BEAT_COUNTER  = %00000111

CULTIST_STATE_MERCY_WAIT   = %00000000
CULTIST_STATE_IDLE         = %00000001
CULTIST_STATE_TEPELORTING  = %00000010
CULTIST_STATE_KNOCKED_BACK = %00000011
CULTIST_STATE_ANTICIPATE   = %00000100
CULTIST_STATE_CASTING      = %00000111

; Note: all macros assume X is prepopulated with our
; state index, as various entrypoints need to do that
; in their own way for dispatch reasons

; After this, A contains the FULL tile_data byte.
; If you like, follow this up with
;    and #CULTIST_DATA_BEAT_COUNTER
; to efficiently branch on the current counter value
.macro cultist_increment_beat_counter scratch_byte
        lda tile_data, x
        clc
        adc #1
        and #CULTIST_DATA_BEAT_COUNTER
        sta scratch_byte
        lda tile_data, x
        and #($FF - CULTIST_DATA_BEAT_COUNTER)
        ora scratch_byte
        sta tile_data, x
.endmacro

.macro cultist_set_state target_state
        lda tile_flags, x
        and #($FF - CULTIST_FLAGS_STATE)
        ora target_state
        sta tile_flags, x
.endmacro


; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

cultist_update_dispatch_lut:
        .addr ENEMY_UPDATE_cultist_mercy_wait
        .addr ENEMY_UPDATE_cultist_idle
        .addr ENEMY_UPDATE_cultist_tepelorting
        .addr ENEMY_UPDATE_cultist_knocked_back
        .addr ENEMY_UPDATE_cultist_anticipate
        .addr ENEMY_UPDATE_cultist_casting
        .addr ENEMY_UPDATE_cultist_idle
        .addr ENEMY_UPDATE_cultist_idle

.proc ENEMY_UPDATE_cultist
DestFunc := R0
CurrentRow := R14
CurrentTile := R15

        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; dispatch to our actual state handler
        ldx CurrentTile
        lda tile_flags, x
        and #CULTIST_FLAGS_STATE
        asl
        tay
        lda cultist_update_dispatch_lut+0, y
        sta DestFunc+0
        lda cultist_update_dispatch_lut+1, y
        sta DestFunc+1
        jmp (DestFunc)
        ; tail call
.endproc

; Our default state, and also the state we revert to when
; suspending a room. This gives all cultists a brief "cooldown" when
; the room is initially loaded, so the player has some breathing room.
; TODO: tweak this as necessary, we can probably get out of this without
; waiting for the whole 8-byte cycle
.proc ENEMY_UPDATE_cultist_mercy_wait
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        cultist_increment_beat_counter ScratchByte
        cultist_set_state #CULTIST_STATE_IDLE
do_nothing:
        rts
.endproc

.proc ENEMY_UPDATE_cultist_idle
ScratchByte := R0
TargetTile := R0

CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        cultist_increment_beat_counter ScratchByte
        and #CULTIST_DATA_BEAT_COUNTER
        bne do_nothing
        
        ; It's our turn to move! Get ready to do that. First, we need to
        ; choose our new target, which may fail, but generally should not.
        ; If it does, we'll passively skip our turn and visibly do nothing.
        jsr ENEMY_UPDATE_cultist_choose_target
        cmp #$FF
        bne targeting_succeeded
        rts

targeting_succeeded:
        ; Draw a magic circle at our target location, using our own palette
        ldx CurrentTile
        ldy TargetTile
        draw_at_y_with_pal_x TILE_MAGIC_CIRCLE, BG_TILE_MAGIC_TEPELORT_CIRCLE
        ; The magic circle's data byte should house our current location, as it will
        ; ultimately be responsible for processing the tepelort
        lda CurrentTile
        sta tile_data, y
        ; Clear the flags, and set the "already moved" so we don't tepelort early
        lda #$80
        sta tile_flags, y

        ; Set our own tile to the "tepelort anticipation" state, full of GLEE
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_FEET_GLOWING
        cultist_set_state #CULTIST_STATE_TEPELORTING

        ; ... and... we're done?
do_nothing:
        rts
.endproc

; Returns the target index on success, or $FF on failure
.proc ENEMY_UPDATE_cultist_choose_target
TargetTile := R0
NumAttempts := R7
        
        prng_from_table_y
        and #%11
        beq dog_player
        cmp #1
        beq near_player
        cmp #2
        beq near_player
        jmp entire_map

dog_player:
        jsr ENEMY_UPDATE_cultist_targeting_predict_player_position
        cmp #$FF
        beq near_player
        rts

near_player:
        lda #4
        sta NumAttempts
near_player_loop:
        jsr ENEMY_UPDATE_cultist_targeting_area_around_player
        cmp #$FF
        beq near_player_targeting_failed
        rts
near_player_targeting_failed:
        dec NumAttempts
        beq entire_map
        jmp near_player_loop
        
entire_map:
        lda #8
        sta NumAttempts
entire_map_loop:
        jsr ENEMY_UPDATE_cultist_random_targeting
        cmp #$FF
        beq entire_map_targeting_failed
        rts
entire_map_targeting_failed:
        dec NumAttempts
        beq return_failure
        jmp entire_map_loop

return_failure:
        lda #$FF
        rts
.endproc

; Targets the spot the player is currently on (or WILL be on, if we get fancy)
; Note: must fail if the player is too close to the map edge, for spellcasting
; reasons!
.proc ENEMY_UPDATE_cultist_targeting_predict_player_position
TargetTile := R0
        ; TODO: factor in the last successful input and do the math.
        ; For now, just target the player's current tile

        ; Sanity check the player's bounds, and bail if the player is too
        ; close to the map edge. This stops us from casting a spell whose component tiles
        ; leave the boundary of the world, which could cause minor, trivial problems like
        ; entire game crashes, etc etc
        lda PlayerRow
        cmp #2
        bcc return_failure
        cmp #(BATTLEFIELD_WIDTH-2)
        bcs return_failure

        lda PlayerCol
        cmp #2
        bcc return_failure
        cmp #(BATTLEFIELD_HEIGHT-2)
        bcs return_failure

        ldy PlayerRow
        lda row_number_to_tile_index_lut, y
        clc
        adc PlayerCol
        sta TargetTile

        if_valid_destination return_success
return_failure:
        lda #$FF
        sta TargetTile
        rts
return_success:
        lda TargetTile
        rts        
.endproc

; Targets a random square in a 5x5 block around the player, constrained
; to the map bounds. Will never ? never what? Zeta, what were you thinking?
.proc ENEMY_UPDATE_cultist_targeting_area_around_player
TargetTile := R0
ScratchByte := R0

LeftBounds := R1
RightBounds := R2
UpperBounds := R3
LowerBounds := R4

TargetRow := R5
TargetCol := R6

        lda PlayerCol
        sec
        sbc #2
        bmi clamp_left_col
        cmp #2
        bcc clamp_left_col
        jmp left_col_in_range
clamp_left_col:
        lda #2
left_col_in_range:
        sta LeftBounds

        lda PlayerCol
        clc
        adc #2
        cmp #(BATTLEFIELD_WIDTH-2)
        bcs clamp_right_col
        jmp right_col_in_range
clamp_right_col:
        lda #(BATTLEFIELD_WIDTH-3)
right_col_in_range:
        sta RightBounds

        lda PlayerRow
        sec
        sbc #2
        bmi clamp_upper_row
        cmp #2
        bcc clamp_upper_row
        jmp upper_row_in_range
clamp_upper_row:
        lda #2
upper_row_in_range:
        sta UpperBounds

        lda PlayerRow
        clc
        adc #2
        cmp #(BATTLEFIELD_HEIGHT-2)
        bcs clamp_lower_row
        jmp lower_row_in_range
clamp_lower_row:
        lda #(BATTLEFIELD_HEIGHT-3)
lower_row_in_range:
        sta LowerBounds

        ; Now actually roll the position within the 5x5 area
        lda RightBounds
        sec
        sbc LeftBounds
        sta ScratchByte
        in_range_smol_from_table_y ScratchByte
        clc
        adc LeftBounds
        sta TargetCol

        ; Now actually roll the position within the 5x5 area
        lda LowerBounds
        sec
        sbc UpperBounds
        sta ScratchByte
        in_range_smol_from_table_y ScratchByte
        clc
        adc UpperBounds
        sta TargetRow

        ldy TargetRow
        lda row_number_to_tile_index_lut, y
        clc
        adc TargetCol
        sta TargetTile

        if_valid_destination return_success
return_failure:
        lda #$FF
        sta TargetTile
        rts
return_success:
        lda TargetTile
        rts     
.endproc

.proc ENEMY_UPDATE_cultist_random_targeting
TargetTile := R0
ScratchByte := R0

TargetRow := R1
TargetCol := R2
        ; Pick a random square within the entire map, and try to teleport there
        lda #(BATTLEFIELD_WIDTH - 3)
        sec
        sbc #2
        sta ScratchByte
        in_range_smol_from_table_y ScratchByte
        clc
        adc #2
        sta TargetCol

        lda #(BATTLEFIELD_HEIGHT - 3)
        sec
        sbc #2
        sta ScratchByte
        in_range_smol_from_table_y ScratchByte
        clc
        adc #2
        sta TargetRow

        ldy TargetRow
        lda row_number_to_tile_index_lut, y
        clc
        adc TargetCol
        sta TargetTile

        if_valid_destination return_success
return_failure:
        lda #$FF
        sta TargetTile
        rts
return_success:
        lda TargetTile
        rts     
.endproc

.proc ENEMY_UPDATE_cultist_tepelorting
CurrentRow := R14
CurrentTile := R15
        ; This is sortof a no-op, but as a safety, set our state back to idle.
        ; Ordinarily the Magic Circle should move us and force our state to something
        ; else, and is also in charge of updating our move counter and all that jazz.
        ; Due to update order, we don't know which block of logic will run first.

        ; We're treating this as a safety that shouldn't *actually* run under normal
        ; circumstances, so don't bother to update the beat counter.
        ldx CurrentTile
        cultist_set_state #CULTIST_STATE_IDLE

        rts
.endproc

.proc ENEMY_UPDATE_cultist_magic_circle
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15

        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; It's time to actually run the tepelort! Move the cultist
        ; to our location, force its state into anticipate, and
        ; leave a puff tile with tepelort afterimage graphics where
        ; it used to be. Later, if the player happens to collide
        ; with the relocated cultist, they'll get sent back and should
        ; enter their "knockback" state.

        ldx CurrentTile
        lda tile_data, x
        tay
        lda battlefield, y
        cmp #TILE_CULTIST
        beq actually_a_cultist
not_a_cultist:
        ; Cleanup our own tile
        ldx CurrentTile
        stx DiscoTile
        lda CurrentRow
        sta DiscoRow
        near_call ENEMY_UPDATE_draw_disco_tile_here
        rts
actually_a_cultist:
        ; Move the cultist here
        lda battlefield, y
        sta battlefield, x
        lda tile_patterns, y
        sta tile_patterns, x
        lda tile_attributes, y
        sta tile_attributes, x
        lda tile_data, y
        sta tile_data, x
        lda tile_flags, y
        sta tile_flags, x
        ; Draw a puff tile at the old location
        ; TODO: make this fancier and use the filled / outline variant as appropriete
        lda #TILE_SMOKE_PUFF
        sta battlefield, y
        lda #(PAL_EARTH | >BG_TILE_TEPELORT_AFTERIMAGE_PLAIN)
        sta tile_attributes, y
        lda #<BG_TILE_TEPELORT_AFTERIMAGE_PLAIN
        sta tile_patterns, y
        txa
        sta tile_data, y
        lda #$80
        sta tile_flags, y

        ; Put the cultist in the IDLE state
        ; TODO: anticipate for spellcasting instead, and all of that logic
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_IDLE
        cultist_set_state #CULTIST_STATE_IDLE
        cultist_increment_beat_counter ScratchByte

        ; For now, we're done!
        rts
.endproc

.proc ENEMY_UPDATE_cultist_knocked_back
CurrentRow := R14
CurrentTile := R15
        rts
.endproc

.proc ENEMY_UPDATE_cultist_anticipate
CurrentRow := R14
CurrentTile := R15
        rts
.endproc

.proc ENEMY_UPDATE_cultist_casting
CurrentRow := R14
CurrentTile := R15
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_direct_attack_cultist
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_cultist
        rts
.endproc


; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_cultist_attacks_player
        rts
.endproc

; ============================================================================================================================
; ===                                    Explosion Attacks Enemy Behaviors                                                 ===
; ============================================================================================================================
        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_cultist_direct_explode
        rts
.endproc

.proc ENEMY_BOMB_SPELL_cultist_indirect_explode
        rts
.endproc

.proc ENEMY_BOMB_SPELL_cultist_spell_dispatch
        rts
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"
.proc ENEMY_UTIL_cultist_suspend_logic
        rts
.endproc

