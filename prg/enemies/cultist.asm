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
CULTIST_DATA_SPELL_SHAPE   = %00111000
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

cultist_cast_table_io:
        ; [ ] [ ] [ ]
        ; [s] [C] [ ]
        ; [s] [s] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((1 * BATTLEFIELD_WIDTH) - 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [s] [s] [ ]
        ; [s] [C] [ ]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) - 1)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte 0 ; padding
        ; [ ] [s] [s]
        ; [ ] [C] [s]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [ ] [ ]
        ; [ ] [C] [s]
        ; [ ] [s] [s]
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 0)
        .byte <((1 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [ ] [ ] [ ]
        ; [ ] [ ] [ ] [ ]
        ; [s] [C] [s] [s]
        ; [ ] [ ] [ ] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 2)
        .byte 0 ; padding
        ; [ ] [ ] [ ] [ ]
        ; [ ] [ ] [ ] [ ]
        ; [s] [s] [C] [s]
        ; [ ] [ ] [ ] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) - 2)
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [s] [ ] [ ]
        ; [ ] [s] [ ] [ ]
        ; [ ] [C] [ ] [ ]
        ; [ ] [s] [ ] [ ]
        .byte <((-2 * BATTLEFIELD_WIDTH) + 0)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [s] [ ] [ ]
        ; [ ] [C] [ ] [ ]
        ; [ ] [s] [ ] [ ]
        ; [ ] [s] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 2 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding

; In this arrangement, with the cultist centered,
; the T shape only has 4 meaningful variants. We
; only have 7 shapes and someone had to get the short
; end of the stick. Sorry, T cultist! Next time try
; being *less* evil.
cultist_cast_table_t:
        .repeat 2        
        ; [ ] [ ] [ ]
        ; [s] [C] [s]
        ; [ ] [s] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [s] [ ]
        ; [ ] [C] [s]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding        
        ; [ ] [s] [ ]
        ; [s] [C] [s]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [s] [ ]
        ; [s] [C] [ ]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        .endrepeat

cultist_cast_table_lj:
        ; [ ] [s] [ ]
        ; [ ] [C] [ ]
        ; [ ] [s] [s]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [ ] [s]
        ; [s] [C] [s]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [s] [s] [ ]
        ; [ ] [C] [ ]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) - 1)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [ ] [ ]
        ; [s] [C] [s]
        ; [s] [ ] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((1 * BATTLEFIELD_WIDTH) - 1)
        .byte 0 ; padding        
        ; [ ] [s] [ ]
        ; [ ] [C] [ ]
        ; [s] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 1 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [ ] [ ]
        ; [s] [C] [s]
        ; [ ] [ ] [s]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [s] [s]
        ; [ ] [C] [ ]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [s] [ ] [ ]
        ; [s] [C] [s]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding

cultist_cast_table_sz:
        ; [ ] [ ] [ ]
        ; [ ] [C] [s]
        ; [s] [s] [ ]
        .byte <((0 * BATTLEFIELD_WIDTH) + 1)
        .byte <((1 * BATTLEFIELD_WIDTH) - 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [s] [s]
        ; [s] [C] [ ]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte 0 ; padding
        ; [ ] [s] [ ]
        ; [ ] [C] [s]
        ; [ ] [ ] [s]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [s] [ ] [ ]
        ; [s] [C] [ ]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding
        ; [ ] [ ] [ ]
        ; [s] [C] [ ]
        ; [ ] [s] [s]
        .byte <((0 * BATTLEFIELD_WIDTH) - 1)
        .byte <((1 * BATTLEFIELD_WIDTH) + 0)
        .byte <((1 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [s] [s] [ ]
        ; [ ] [C] [s]
        ; [ ] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) - 1)
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte 0 ; padding
        ; [ ] [s] [ ]
        ; [s] [C] [ ]
        ; [s] [ ] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 0)
        .byte <(( 0 * BATTLEFIELD_WIDTH) - 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) - 1)
        .byte 0 ; padding
        ; [ ] [ ] [s]
        ; [ ] [C] [s]
        ; [ ] [s] [ ]
        .byte <((-1 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 0 * BATTLEFIELD_WIDTH) + 1)
        .byte <(( 1 * BATTLEFIELD_WIDTH) + 0)
        .byte 0 ; padding

cultist_update_dispatch_lut:
        .addr ENEMY_UPDATE_cultist_mercy_wait
        .addr ENEMY_UPDATE_cultist_idle
        .addr ENEMY_UPDATE_cultist_tepelorting
        .addr ENEMY_UPDATE_cultist_knocked_back
        .addr ENEMY_UPDATE_cultist_anticipate
        .addr ENEMY_UPDATE_cultist_casting
        .addr ENEMY_UPDATE_cultist_idle
        .addr ENEMY_UPDATE_cultist_idle

; Note: attack/collide routines will need their own copies of these tables
; and routines
; Have X set to the tile index of the enemy before calling this function
; (make sure it's the enemy with the authorative palette at this stage, not
; the poof tile or something silly)
.proc ENEMY_UPDATE_set_spell_shape_table
SpellShapeTable := R0       
CurrentTile := R15
        ; These mappings are somewhat arbitrary; feel free to tweak to taste.
        ; We want each color to draw from its own unique pool of shape types
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq load_earth_table
        cmp #PAL_ICE
        beq load_ice_table
        cmp #PAL_AIR
        beq load_air_table
        cmp #PAL_FIRE
        beq load_fire_table
        ; unreachable? fall through to earth I guess
load_earth_table:
        lda #<cultist_cast_table_t
        sta SpellShapeTable+0
        lda #>cultist_cast_table_t
        sta SpellShapeTable+1
        rts
load_ice_table:
        lda #<cultist_cast_table_lj
        sta SpellShapeTable+0
        lda #>cultist_cast_table_lj
        sta SpellShapeTable+1
        rts
load_air_table:
        lda #<cultist_cast_table_sz
        sta SpellShapeTable+0
        lda #>cultist_cast_table_sz
        sta SpellShapeTable+1
        rts
load_fire_table:
        lda #<cultist_cast_table_io
        sta SpellShapeTable+0
        lda #>cultist_cast_table_io
        sta SpellShapeTable+1
        rts
.endproc

.proc ENEMY_UPDATE_choose_spell_shape
SpellShapeTable := R0
SpellIndex := R2
SpellCounter := R3

ChosenIndex := R4
ChosenTileCount := R5
CandidateTileCount := R6

SpellShapeCounter := R7

CurrentRow := R14
CurrentTile := R15
        ; First, set up the spell table based on our palette color
        ; these mappings are arbitrary and may be tweaked to taste
        ldx CurrentTile
        near_call ENEMY_UPDATE_choose_spell_shape
        ; Now choose a random index into that table, preshifted
        prng_from_table_y
        and #%00011100 ; 8 possibilities, 4 bytes each
        sta SpellIndex
        sta ChosenIndex
        ; Set up to loop over the entries
        lda #0
        sta ChosenTileCount
        sta CandidateTileCount
        lda #8
        sta SpellCounter
spell_shape_loop:
        lda #3
        sta SpellShapeCounter
        ldy SpellIndex
spell_tile_loop:
        lda (SpellShapeTable), y
        if_valid_destination spell_tile_is_valid
spell_tile_is_invalid:
        jmp increment_spell_tile_counters
spell_tile_is_valid:
        inc CandidateTileCount
increment_spell_tile_counters:
        iny
        dec SpellShapeCounter
        bne spell_tile_loop
done_with_this_shape:
        ; If this shape beats our current candidate, copy those details over
        lda CandidateTileCount
        cmp ChosenTileCount
        bcc candidate_not_beaten
        sta ChosenTileCount
        lda SpellIndex
        sta ChosenIndex
        ; Now, if the candidate count happens to be 3+ here, we're instantly done. Skip all the
        ; rest of the looping, we'll never find a better one
        lda CandidateTileCount
        cmp #3
        bcs done_with_all_shapes
        ; Otherwise, keep looping through the rest of the shapes
candidate_not_beaten:
        lda SpellIndex
        clc
        adc #%00000100
        and #%00011100
        sta SpellIndex
        dec SpellCounter
        bne spell_shape_loop
done_with_all_shapes:
        ; Okay, by this point we've committed to whatever spell index we chose, regardless of its
        ; quality, so get that massagged and written back to our entity slot
        ; fortunately this bit is straightforward
        asl ChosenIndex                       ; format is now: ..XXX...
        lda tile_data, x
        and #($FF - CULTIST_DATA_SPELL_SHAPE)
        ora SpellIndex
        sta tile_data, x

        rts
.endproc

.proc ENEMY_UPDATE_draw_spell_warning
SpellShapeTable := R0
TargetTile := R2
CurrentRow := R14
CurrentTile := R15
        ; For every valid tile in the spell shape table, 
        ; draw a disco tile but use the "warning" artwork.
        ; we should be handling our own cleanup, but on the off
        ; chance that something goes wrong, these will self-revert
        ; on their own.
        ldx CurrentTile
        near_call ENEMY_UPDATE_set_spell_shape_table
        ldy #3
spell_tile_loop:
        lda (SpellShapeTable), y
        sta TargetTile
        if_valid_destination draw_warning_here
        jmp done_with_this_tile
draw_warning_here:
        ldx TargetTile
        ; TODO: respect filled / outline!
        lda #<BG_TILE_WARNING_PLAIN
        sta tile_patterns, x
        lda #>BG_TILE_WARNING_PLAIN
        sta tile_attributes, x
        lda #TILE_DISCO_FLOOR
        sta battlefield, x
done_with_this_tile:
        dey
        bne spell_tile_loop
        rts
.endproc

.proc ENEMY_UPDATE_cast_spell
SpellShapeTable := R0
TargetTile := R2
SpellPattern := R3
SpellAttr := R4
SpellBehavior := R5

CurrentRow := R14
CurrentTile := R15
        ; Very similar to drawing the warning, with a couple of changes. Most
        ; notably, we need to differentiate the spell tiles based on the enemy color.
        ; TODO: further differentiate based on checkerboard style!
        ldx CurrentTile
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq use_poison_tile
        cmp #PAL_ICE
        beq use_crystal_tile
        cmp #PAL_AIR
        beq use_lightning_ball_tile
        cmp #PAL_FIRE
        beq use_flame_tile
use_poison_tile:
        lda #<BG_TILE_HAZARD_POISON_OUTLINE
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_POISON_OUTLINE | PAL_EARTH)
        sta SpellAttr
        lda #TILE_DISCO_FLOOR ; TODO: not this!
        sta SpellBehavior
        jmp done_picking_spell_tile
use_crystal_tile:
        lda #<BG_TILE_HAZARD_ICE_OUTLINE
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_ICE_OUTLINE | PAL_ICE)
        sta SpellAttr
        lda #TILE_DISCO_FLOOR ; TODO: not this!
        sta SpellBehavior
        jmp done_picking_spell_tile
use_lightning_ball_tile:
        lda #<BG_TILE_HAZARD_LIGHTNING_OUTLINE
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_LIGHTNING_OUTLINE | PAL_AIR)
        sta SpellAttr
        lda #TILE_DISCO_FLOOR ; TODO: not this!
        sta SpellBehavior
        jmp done_picking_spell_tile
use_flame_tile:
        lda #<BG_TILE_HAZARD_FIRE_OUTLINE
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_FIRE_OUTLINE | PAL_FIRE)
        sta SpellAttr
        lda #TILE_DISCO_FLOOR ; TODO: not this!
        sta SpellBehavior
        jmp done_picking_spell_tile
done_picking_spell_tile:
        near_call ENEMY_UPDATE_set_spell_shape_table

        ; Okay, now loop through and apply this to all valid tiles. Notably
        ; our "warning" tiles use DISCO FLOOR as their behavioral base, so they
        ; will still be considered "valid" when this code runs.
        ldy #3
spell_tile_loop:
        lda (SpellShapeTable), y
        sta TargetTile
        if_valid_destination draw_warning_here
        jmp done_with_this_tile
draw_warning_here:
        ldx TargetTile
        ; TODO: respect filled / outline!
        lda SpellPattern
        sta tile_patterns, x
        lda SpellAttr
        sta tile_attributes, x
        lda SpellBehavior
        sta battlefield, x
done_with_this_tile:
        dey
        bne spell_tile_loop
        rts
.endproc

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

