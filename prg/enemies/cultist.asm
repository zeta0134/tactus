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

CULTIST_FLAGS_STATE        = %01110000
CULTIST_FLAGS_HP           = %00001111

; Why store this again? because we may be HIT by a player spell, and change our color, between beats!
CULTIST_DATA_SPELL_COLOR   = %11000000
CULTIST_DATA_SPELL_SHAPE   = %00111000
CULTIST_DATA_BEAT_COUNTER  = %00000111

CULTIST_STATE_MERCY_WAIT   = %00000000
CULTIST_STATE_IDLE         = %00010000
CULTIST_STATE_TEPELORTING  = %00100000
CULTIST_STATE_KNOCKED_BACK = %00110000
CULTIST_STATE_ANTICIPATE   = %01000000
CULTIST_STATE_CASTING      = %01010000

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
        .segment "ENEMY_UPDATE1"

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

TargetTile := R8

CurrentRow := R14
CurrentTile := R15
        ; First, set up the spell table based on our palette color
        ; these mappings are arbitrary and may be tweaked to taste
        ldx CurrentTile
        near_call ENEMY_UPDATE_set_spell_shape_table
        ; Now choose a random index into that table, preshifted
        prng_from_table_y
        and #%00011100 ; 8 possibilities, 4 bytes each
        sta SpellIndex
        sta ChosenIndex
        ; Set up to loop over the entries
        lda #0
        sta ChosenTileCount
        lda #8
        sta SpellCounter
spell_shape_loop:
        lda #3
        sta SpellShapeCounter
        lda #0
        sta CandidateTileCount
        ldy SpellIndex
spell_tile_loop:
        lda (SpellShapeTable), y
        clc
        adc CurrentTile
        sta TargetTile
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
        ldx CurrentTile
        lda tile_data, x
        and #($FF - CULTIST_DATA_SPELL_SHAPE)
        ora ChosenIndex
        sta tile_data, x

        rts
.endproc

.proc ENEMY_UPDATE_draw_spell_warning
SpellShapeTable := R0
TargetTile := R2
SpellTileCounter := R3
CurrentSpellTileIndex := R4
CurrentRow := R14
CurrentTile := R15
        ; For every valid tile in the spell shape table, 
        ; draw a disco tile but use the "warning" artwork.
        ; we should be handling our own cleanup, but on the off
        ; chance that something goes wrong, these will self-revert
        ; on their own.
        ldx CurrentTile
        near_call ENEMY_UPDATE_set_spell_shape_table
        lda #3
        sta SpellTileCounter
        ldx CurrentTile
        lda tile_data, x
        and #CULTIST_DATA_SPELL_SHAPE
        lsr ; format is now ...XXX..
        sta CurrentSpellTileIndex
spell_tile_loop:
        ldy CurrentSpellTileIndex
        lda (SpellShapeTable), y
        clc
        adc CurrentTile
        sta TargetTile
        if_valid_destination draw_warning_here
        jmp done_with_this_tile
draw_warning_here:
        ldx TargetTile
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_warning_tile_here_x
        lda #TILE_INDICATOR
        sta battlefield, x
        lda tile_flags, x
        ora #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x
done_with_this_tile:
        inc CurrentSpellTileIndex
        dec SpellTileCounter
        bne spell_tile_loop
        rts
.endproc

; Called as a COLLISION response. Make sure we are not clobbering
; collision state while we're at it, though that should be relatively
; minimal.
.proc ENEMY_UPDATE_during_collision_cleanup_spell_warning
TempSpellShapeTable := R0
TargetIndex := R0

SpellShapeTable := R2
TargetTile := R4
SpellTileCounter := R5
CurrentSpellTileIndex := R6

PuffSquare := R12
TargetSquare := R13

        ldx TargetSquare
        near_call ENEMY_UPDATE_set_spell_shape_table
        ; aaand move this out of range because draw_active_tile is going to clobber R0
        mov16 SpellShapeTable, TempSpellShapeTable

        lda #3
        sta SpellTileCounter
        ldx TargetSquare
        lda tile_data, x
        and #CULTIST_DATA_SPELL_SHAPE
        lsr ; format is now ...XXX..
        sta CurrentSpellTileIndex
spell_tile_loop:
        ldy CurrentSpellTileIndex
        lda (SpellShapeTable), y
        clc
        adc TargetSquare
        sta TargetTile
        ; ONLY clean up indicator tiles. Affect nothing else!
        ldx TargetTile
        lda battlefield, x
        cmp #TILE_INDICATOR
        bne done_with_this_tile
draw_disco_tile_here:
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda DiscoTile
        sta TargetIndex
        jsr draw_active_tile
done_with_this_tile:
        inc CurrentSpellTileIndex
        dec SpellTileCounter
        bne spell_tile_loop
        rts
.endproc

.proc ENEMY_UPDATE_cast_spell
SpellShapeTable := R0
TargetTile := R2
SpellPattern := R3
SpellAttr := R4
SpellBehavior := R5
SpellTileCounter := R6

CurrentSpellTileIndex := R7

CurrentRow := R14
CurrentTile := R15
        ; Very similar to drawing the warning, with a couple of changes. Most
        ; notably, we need to differentiate the spell tiles based on the enemy color.
        ; TODO: further differentiate based on checkerboard style!
        ; TODO: spellcast SFX? we might want to only do this if the player gets hit?
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
        lda #<BG_TILE_HAZARD_POISON_FILLED
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_POISON_FILLED | PAL_EARTH)
        sta SpellAttr
        lda #TILE_ONE_BEAT_POISON
        sta SpellBehavior
        jmp done_picking_spell_tile
use_crystal_tile:
        lda #<BG_TILE_HAZARD_ICE_FILLED
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_ICE_FILLED | PAL_ICE)
        sta SpellAttr
        lda #TILE_ONE_BEAT_FREEZE
        sta SpellBehavior
        jmp done_picking_spell_tile
use_lightning_ball_tile:
        lda #<BG_TILE_HAZARD_LIGHTNING_FILLED
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_LIGHTNING_FILLED | PAL_AIR)
        sta SpellAttr
        lda #TILE_ONE_BEAT_SHOCK
        sta SpellBehavior
        jmp done_picking_spell_tile
use_flame_tile:
        lda #<BG_TILE_HAZARD_FIRE_FILLED
        sta SpellPattern
        lda #(>BG_TILE_HAZARD_FIRE_FILLED | PAL_FIRE)
        sta SpellAttr
        lda #TILE_ONE_BEAT_BURN
        sta SpellBehavior
        jmp done_picking_spell_tile
done_picking_spell_tile:

        ; Okay, now loop through and apply this to all valid tiles. Notably
        ; our "warning" tiles use DISCO FLOOR as their behavioral base, so they
        ; will still be considered "valid" when this code runs.
        near_call ENEMY_UPDATE_set_spell_shape_table
        lda #3
        sta SpellTileCounter
        ldx CurrentTile
        lda tile_data, x
        and #CULTIST_DATA_SPELL_SHAPE
        lsr ; format is now ...XXX..
        sta CurrentSpellTileIndex
spell_tile_loop:
        ldy CurrentSpellTileIndex
        lda (SpellShapeTable), y
        clc
        adc CurrentTile
        sta TargetTile
        
        ldx TargetTile
        lda battlefield, x
        cmp #TILE_INDICATOR      ; indicators are valid for spellcasts, but not anything else
        beq draw_spell_tile_here ; (we don't want enemies moving into spell range if we can help it)
        if_valid_destination draw_spell_tile_here
        jmp done_with_this_tile
draw_spell_tile_here:
        ldx TargetTile
        lda SpellBehavior
        sta battlefield, x
        lda tile_flags, x
        ora #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x
        lda SpellPattern
        sta tile_patterns, x
        lda SpellAttr
        sta tile_attributes, x
        
        ; TODO: set data to indicate damage output and hazard strength?
        ; (receiving end needs to respect this, new system, etc)

done_with_this_tile:
        inc CurrentSpellTileIndex
        dec SpellTileCounter
        bne spell_tile_loop

        rts
.endproc

; Called as an ATTACK response. Make sure we are not clobbering
; attack state while we're at it!
.proc ENEMY_UPDATE_during_attack_cleanup_spell_effects
TempSpellShapeTable := R0 ;  and R1
TargetIndex := R0
; DO NOT USE: R2 - R10

EffectiveAttackSquare := R10 
; DO NOT USE: R14, R15

; OR R16 - R17, used by disco tile routines >_<

SpellShapeTable := R18
TargetTile := R20
SpellTileCounter := R21
CurrentSpellTileIndex := R22

        ldx EffectiveAttackSquare
        near_call ENEMY_UPDATE_set_spell_shape_table
        ; aaand move this out of range because draw_active_tile is going to clobber R0
        mov16 SpellShapeTable, TempSpellShapeTable

        lda #3
        sta SpellTileCounter
        ldx EffectiveAttackSquare
        lda tile_data, x
        and #CULTIST_DATA_SPELL_SHAPE
        lsr ; format is now ...XXX..
        sta CurrentSpellTileIndex
spell_tile_loop:
        ldy CurrentSpellTileIndex
        lda (SpellShapeTable), y
        clc
        adc EffectiveAttackSquare
        sta TargetTile
        ; ONLY clean up spell tiles. Affect nothing else!
        ldx TargetTile
        lda battlefield, x
        cmp #TILE_INDICATOR       ; included so we can reuse the logic during indirect attacks
        beq draw_disco_tile_here
        cmp #TILE_ONE_BEAT_POISON
        beq draw_disco_tile_here
        cmp #TILE_ONE_BEAT_FREEZE
        beq draw_disco_tile_here
        cmp #TILE_ONE_BEAT_SHOCK
        beq draw_disco_tile_here
        cmp #TILE_ONE_BEAT_BURN
        beq draw_disco_tile_here
        jmp done_with_this_tile
draw_disco_tile_here:
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda DiscoTile
        sta TargetIndex
        jsr draw_active_tile
done_with_this_tile:
        inc CurrentSpellTileIndex
        dec SpellTileCounter
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
        lsr
        lsr
        lsr
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
        near_call ENEMY_UPDATE_cultist_choose_target
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
        near_call ENEMY_UPDATE_cultist_targeting_predict_player_position
        cmp #$FF
        beq near_player
        rts

near_player:
        lda #4
        sta NumAttempts
near_player_loop:
        near_call ENEMY_UPDATE_cultist_targeting_area_around_player
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
        near_call ENEMY_UPDATE_cultist_random_targeting
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
        far_call ENEMY_UPDATE_draw_disco_tile_here
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
        txa
        sta tile_data, y
        lda #$80
        sta tile_flags, y

        sty DiscoTile
        lda tile_index_to_row_lut, y
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_teleport_tile_here_y ; clobbers X

        ; Put the cultist in the ANTICIPATE state
        ldx CurrentTile
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_HANDS_RAISED
        cultist_set_state #CULTIST_STATE_ANTICIPATE
        cultist_increment_beat_counter ScratchByte

        ; Decide what magic spell the cultist will cast, and cache that in its data struct
        near_call ENEMY_UPDATE_choose_spell_shape
        ; Draw "warning" tiles for the entire spell area, as we will be casting the spell on the next beat
        near_call ENEMY_UPDATE_draw_spell_warning

        ; And now, we're done!
        rts
.endproc


.proc ENEMY_UPDATE_cultist_knocked_back
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ; By the time we get here, we can just return to our regular idle. Nothing else needs doing.
        ldx CurrentTile
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_IDLE
        cultist_set_state #CULTIST_STATE_IDLE
        cultist_increment_beat_counter ScratchByte

        rts
.endproc

.proc ENEMY_UPDATE_cultist_anticipate
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ; Put the cultist in the CASTING state
        ldx CurrentTile
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_HANDS_ON_GROUND
        cultist_set_state #CULTIST_STATE_CASTING
        cultist_increment_beat_counter ScratchByte

        ; Actually cast that spell
        near_call ENEMY_UPDATE_cast_spell

        ; ... we're done?

        rts
.endproc

.proc ENEMY_UPDATE_cultist_casting
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        
        ; Gleefully return to idle, yes! Time for another round.
        ; (of waiting)
        ldx CurrentTile
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_IDLE
        cultist_set_state #CULTIST_STATE_IDLE
        cultist_increment_beat_counter ScratchByte

        ; On THIS beat we will be in the "casting" state, so draw ourselves
        ; with a palette flash to suggest that effort
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase

        rts
.endproc

        
; Does what it says on the tin! Great for powerful spell effects
.proc ENEMY_UPDATE_flash_and_revert_to_disco_tile
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved

        ; it's been one beat! stop being a one beat hazard, thx.
        ldx CurrentTile
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_EARTH
        far_call ENEMY_UPDATE_draw_disco_tile

        ; flash wildly, yes yes!
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase

        rts
.endproc

        ; these functions rely on disco logic to determine which variant to display, and they're
        ; short, so put them in the main bank. we'll need to far call on use.
        .segment "ENEMY_UPDATE0"

.proc _cultist_disco_trampoline
TargetFuncPtr := R10
        jmp (TargetFuncPtr)
.endproc

teleport_tiles_by_disco_floor_lut:
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_FILLED
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_FILLED
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_OUTLINE
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_OUTLINE
        .word (PAL_EARTH << 8) | BG_TILE_TEPELORT_AFTERIMAGE_PLAIN

; Note: This is only for DRAWING the teleport tile! Anything else you need to do
; to the thing has to happen at the call site.
; Arguments: Y contains destination tile
; Clobbers: X
.proc ENEMY_UPDATE_draw_teleport_tile_here_y
TargetFuncPtr := R10
        perform_zpcm_inc
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldx current_save + SaveFile::OptionDiscoFloor
        lda disco_behavior_lut_low, x
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, x
        sta TargetFuncPtr+1
        jsr _cultist_disco_trampoline

        asl ; expand from byte to word alignment
        tax
        
        lda teleport_tiles_by_disco_floor_lut+0, x
        sta tile_patterns, y
        lda teleport_tiles_by_disco_floor_lut+1, x
        sta tile_attributes, y

        ; And done!
        perform_zpcm_inc
        rts
.endproc

warning_tiles_by_disco_floor_lut:
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_FILLED
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_FILLED
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_PLAIN
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_OUTLINE
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_OUTLINE
        .word (PAL_EARTH << 8) | BG_TILE_WARNING_PLAIN

; Note: This is only for DRAWING the teleport tile! Anything else you need to do
; to the thing has to happen at the call site.
; Arguments: X contains destination tile
; Clobbers:  Y
.proc ENEMY_UPDATE_draw_warning_tile_here_x
TargetFuncPtr := R10 ; to not clobber call site state
        perform_zpcm_inc
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldy current_save + SaveFile::OptionDiscoFloor
        lda disco_behavior_lut_low, y
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, y
        sta TargetFuncPtr+1
        jsr _cultist_disco_trampoline

        asl ; expand from byte to word alignment
        tay
        
        lda warning_tiles_by_disco_floor_lut+0, y
        sta tile_patterns, x
        lda warning_tiles_by_disco_floor_lut+1, y
        sta tile_attributes, x

        ; And done!
        perform_zpcm_inc
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_direct_attack_cultist
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; If we have *just moved*, then ignore this attack
        ; (A valid attack can only land at our previous destination)
        ldx AttackSquare
        lda tile_flags, x
        bmi ignore_attack
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_ATTACK_attack_cultist_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_cultist
        near_call ENEMY_ATTACK_attack_cultist_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_cultist_common
; Damage done by the weapon swing
WeaponDmg := R0

AttackLanded := R7
EffectiveAttackSquare := R10 
        
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; Add the player's currently equipped damage to our flags byte
        far_call FAR_weapon_dmg ; clobbers X,Y, result in R0
        lda WeaponDmg
        ; now add that to our running HP total
        ldx EffectiveAttackSquare
        clc
        adc tile_flags, x
        sta tile_flags, x
        ; Now check: if the damage, NOT including the movement bit, is greater than our health...
        and #CULTIST_FLAGS_HP
        cmp #CULTIST_SHARED_HP ; TODO: should this be shared?
        bcs die
        
        ; If this cultist is not in the casting state, then queue up a palette flash.
        ; (otherwise we would queue them up twice, which will look strange)
        lda tile_flags, x
        and #CULTIST_FLAGS_STATE
        cmp #CULTIST_STATE_CASTING
        beq doing_science_and_still_alive

        lda EffectiveAttackSquare
        jsr queue_palette_cycle

doing_science_and_still_alive:
        rts

die:
        ; Oh dear.
        ; Whelp. If we're in a spellcasting state, we need to clean up our warning/spell tiles
        ldx EffectiveAttackSquare
        lda tile_flags, x
        and #CULTIST_FLAGS_STATE
        cmp #CULTIST_STATE_ANTICIPATE
        beq cleanup_tiles
        cmp #CULTIST_STATE_CASTING
        beq cleanup_tiles
        jmp no_cleanup_needed
cleanup_tiles:
        far_call ENEMY_UPDATE_during_attack_cleanup_spell_effects
no_cleanup_needed:
        ; And now all the rest works like any other enemy
        ; ... in fact... the only thing we really need to do differently is set our
        ; loot table, so do that now
        set_loot_table CULTIST_SHARED_LOOT
        jmp ENEMY_ATTACK_attack_with_hp_common::die
        ; tail call
.endproc


; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_cultist_attacks_player
TargetSquare := R13
        ; If we are currently in our anticipation state, then we need to clean up our warning tiles and switch
        ; to our knockback state. The collision logic is about to yoink us back to our old puff tile.
        ldx TargetSquare
        lda tile_flags, x
        and #CULTIST_FLAGS_STATE
        cmp #CULTIST_STATE_ANTICIPATE
        bne converge_with_standard_collision
        ; Switch to the knockback state
        cultist_set_state #CULTIST_STATE_KNOCKED_BACK
        ; Set our tile pattern/attribute accordingly
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_KNOCKED_BACK
        ; Cleanup any warning tiles that we previously generated
        far_call ENEMY_UPDATE_during_collision_cleanup_spell_warning
        ; And now we may fall through to the shared handler for player bumps

converge_with_standard_collision:
        ; tail call into the damaging function

        ; TODO: make a variant of this that doesn't assume adjacency. (no slash sprite, just the flashing square)
        jmp ENEMY_COLLIDE_basic_enemy_attacks_player

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

; for calling ENEMY_UPDATE_during_attack_cleanup_spell_effects
EffectiveAttackSquare := R10 

; for convering with standard spell damage stuff
EnemyHealth := R12

CurrentRow := R14
CurrentTile := R15
        ; If we are hit by a spell while in any clearly-moving pose, switch to knocked-back. Otherwise switch to
        ; mercy-idle. The point here is to cancel the cast and give the player a beat to read the room before they
        ; need to react to us again, and the decision about which state to enter is just visual flair.

        ldx CurrentTile
        lda tile_flags, x
        and #CULTIST_FLAGS_STATE
        cmp #CULTIST_STATE_ANTICIPATE
        beq switch_to_knockback
        cmp #CULTIST_STATE_CASTING
        beq switch_to_knockback
switch_to_mercy_wait:
        cultist_set_state #CULTIST_STATE_MERCY_WAIT
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_IDLE
        jmp done_switching_states
switch_to_knockback:
        cultist_set_state #CULTIST_STATE_KNOCKED_BACK
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_KNOCKED_BACK
        ; In either of these states, we need to clean up the warning/spell tiles
        ; so they don't actually finish their cast, as we've "interrupted" that action
        ; Here we're reusing logic meant for being attacked, so move out index into
        ; R10 to match what it expects
        ; TODO: can we clean up "which tile are we" interfacing with enemy routines in general?
        lda CurrentTile
        sta EffectiveAttackSquare
        far_call ENEMY_UPDATE_during_attack_cleanup_spell_effects
done_switching_states:

        ; And now that we've done all of that, we can run the normal spellcast logic just like
        ; for any other enemy.
        lda #CULTIST_SHARED_HP
        sta EnemyHealth
        jmp ENEMY_BOMB_SPELL_regular_enemy_elemental_spell_common
        ; tail call
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"
.proc ENEMY_UTIL_cultist_suspend_logic
ScratchByte := R0
CurrentSquare := R15
        ; Simple enough: whatever state we are in, move to mercy idle instead, just like if we were freshly spawned.
        ; (Our targeting logic means we are never too close to the map edge for our position to be a problem otherwise)
        ldx CurrentSquare
        cultist_set_state #CULTIST_STATE_MERCY_WAIT
        draw_at_x_keeppal TILE_CULTIST, BG_TILE_CULTIST_IDLE

        rts
.endproc

