; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

DISCO_OFFSET_NO_ANIMATION      = 0
DISCO_OFFSET_GROOVEMENT        = 1
DISCO_OFFSET_SOLID_GROWING     = 2
DISCO_OFFSET_SOLID_STATIC      = 3
DISCO_OFFSET_SOLID_SHRINKING   = 4
DISCO_OFFSET_OUTLINE_GROWING   = 5
DISCO_OFFSET_OUTLINE_STATIC    = 6
DISCO_OFFSET_OUTLINE_SHRINKING = 7

disco_tile_offset_lut_low:
        .byte $00, $80, $00, $80, $00, $80, $00, $80
disco_tile_offset_lut_high:
        .byte $00, $00, $04, $04, $08, $08, $0C, $0C

; got to bounce to the music
.proc _disco_trampoline
TargetFuncPtr := R0
        jmp (TargetFuncPtr)
.endproc

; one subroutine per accessibility mode, so we can decide which floor variant
; to choose with extreme flexibility

; Absolutely no movement whatsoever! The most extreme accessibility option for
; the floor tiles.
.proc ENEMY_UPDATE_disco_reduced_motion
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
.endproc

; Floor tiles dance when the room is active, and are still otherwise
.proc ENEMY_UPDATE_disco_just_groovement
        ; BASIC check: if the room is cleared, always return a cleared tile
        lda current_clear_status
        beq not_cleared
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
not_cleared:
        lda #DISCO_OFFSET_GROOVEMENT
        rts
.endproc

.proc ENEMY_UPDATE_disco_solid_instant_squares
        ; BASIC check: if the room is cleared, always return a cleared tile
        lda current_clear_status
        beq not_cleared
cleared:
        lda previous_clear_status
        bne cleared_not_shrinking
cleared_shrinking:
        ; work out the parity and decide whether to show a shrinking groovement
        ; tile or a plain groovement tile (art currently requires these to match)
        lda DiscoRow
        eor DiscoTile
        eor CurrentBeatCounter
        and #%00000001
        bne just_groovement
        lda #DISCO_OFFSET_SOLID_SHRINKING
        rts
just_groovement:
        lda #DISCO_OFFSET_GROOVEMENT
        rts
cleared_not_shrinking:
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
not_cleared:
        lda DiscoRow
        eor DiscoTile
        eor CurrentBeatCounter
        and #%00000001
        beq just_groovement
        lda previous_clear_status
        beq not_cleared_static
not_cleared_growing:
        lda #DISCO_OFFSET_SOLID_GROWING
        rts
not_cleared_static:
        lda #DISCO_OFFSET_SOLID_STATIC
        rts
.endproc

; "Frozen" parity ignores the current beat entirely, but still grows/shrinks
; into place to indicate changes in room tempo state
.proc ENEMY_UPDATE_disco_solid_frozen_squares
        ; BASIC check: if the room is cleared, always return a cleared tile
        lda current_clear_status
        beq not_cleared
cleared:
        lda previous_clear_status
        bne cleared_not_shrinking
cleared_shrinking:
        ; work out the parity and decide whether to show a shrinking groovement
        ; tile or a plain groovement tile (art currently requires these to match)
        lda DiscoRow
        eor DiscoTile
        and #%00000001
        bne just_groovement
        lda #DISCO_OFFSET_SOLID_SHRINKING
        rts
just_groovement:
        lda #DISCO_OFFSET_GROOVEMENT
        rts
cleared_not_shrinking:
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
not_cleared:
        lda DiscoRow
        eor DiscoTile
        and #%00000001
        bne just_groovement
        lda previous_clear_status
        beq not_cleared_static
not_cleared_growing:
        lda #DISCO_OFFSET_SOLID_GROWING
        rts
not_cleared_static:
        lda #DISCO_OFFSET_SOLID_STATIC
        rts
.endproc

.proc ENEMY_UPDATE_disco_outline_instant_squares
        ; BASIC check: if the room is cleared, always return a cleared tile
        lda current_clear_status
        beq not_cleared
cleared:
        lda previous_clear_status
        bne cleared_not_shrinking
cleared_shrinking:
        ; work out the parity and decide whether to show a shrinking groovement
        ; tile or a plain groovement tile (art currently requires these to match)
        lda DiscoRow
        eor DiscoTile
        eor CurrentBeatCounter
        and #%00000001
        bne just_groovement
        lda #DISCO_OFFSET_OUTLINE_SHRINKING
        rts
just_groovement:
        lda #DISCO_OFFSET_GROOVEMENT
        rts
cleared_not_shrinking:
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
not_cleared:
        lda DiscoRow
        eor DiscoTile
        eor CurrentBeatCounter
        and #%00000001
        beq just_groovement
        lda previous_clear_status
        beq not_cleared_static
not_cleared_growing:
        lda #DISCO_OFFSET_OUTLINE_GROWING
        rts
not_cleared_static:
        lda #DISCO_OFFSET_OUTLINE_STATIC
        rts
.endproc

; "Frozen" parity ignores the current beat entirely, but still grows/shrinks
; into place to indicate changes in room tempo state
.proc ENEMY_UPDATE_disco_outline_frozen_squares
        ; BASIC check: if the room is cleared, always return a cleared tile
        lda current_clear_status
        beq not_cleared
cleared:
        lda previous_clear_status
        bne cleared_not_shrinking
cleared_shrinking:
        ; work out the parity and decide whether to show a shrinking groovement
        ; tile or a plain groovement tile (art currently requires these to match)
        lda DiscoRow
        eor DiscoTile
        and #%00000001
        bne just_groovement
        lda #DISCO_OFFSET_OUTLINE_SHRINKING
        rts
just_groovement:
        lda #DISCO_OFFSET_GROOVEMENT
        rts
cleared_not_shrinking:
        lda #DISCO_OFFSET_NO_ANIMATION
        rts
not_cleared:
        lda DiscoRow
        eor DiscoTile
        and #%00000001
        bne just_groovement
        lda previous_clear_status
        beq not_cleared_static
not_cleared_growing:
        lda #DISCO_OFFSET_OUTLINE_GROWING
        rts
not_cleared_static:
        lda #DISCO_OFFSET_OUTLINE_STATIC
        rts
.endproc

disco_behavior_lut_low:
        .byte <ENEMY_UPDATE_disco_solid_instant_squares
        .byte <ENEMY_UPDATE_disco_solid_frozen_squares
        .byte <ENEMY_UPDATE_disco_outline_instant_squares
        .byte <ENEMY_UPDATE_disco_outline_frozen_squares
        .byte <ENEMY_UPDATE_disco_just_groovement
        .byte <ENEMY_UPDATE_disco_reduced_motion

disco_behavior_lut_high:
        .byte >ENEMY_UPDATE_disco_solid_instant_squares
        .byte >ENEMY_UPDATE_disco_solid_frozen_squares
        .byte >ENEMY_UPDATE_disco_outline_instant_squares
        .byte >ENEMY_UPDATE_disco_outline_frozen_squares
        .byte >ENEMY_UPDATE_disco_just_groovement
        .byte >ENEMY_UPDATE_disco_reduced_motion

.proc ENEMY_UPDATE_draw_disco_tile
TargetFuncPtr := R0
CurrentRow := R14
CurrentTile := R15

TileIdLow := R16
TileAttrHigh := R17
        ; Setup for the disco routines to use
        ; (this lets us share disco routines with other tile types that
        ; have different zp scratch arrangements)
        lda CurrentRow
        sta DiscoRow
        lda CurrentTile
        sta DiscoTile

        ; TODO - OPTIMIZATION: we could fall through to the below function?

        ; first, load the detail variant for this floor, we'll use this as our base
        ldx CurrentTile
        lda tile_detail, x
        sta TileIdLow

        ; run the selection logic based on the player's preference
        ldx setting_disco_floor
        lda disco_behavior_lut_low, x
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, x
        sta TargetFuncPtr+1
        jsr _disco_trampoline
        ; at this point, A contains the index into the disco tile lookup table
        tax
        lda disco_tile_offset_lut_low, x
        ora TileIdLow
        sta TileIdLow
        lda disco_tile_offset_lut_high, x
        sta TileAttrHigh

        ; now perform the actual draw
        ldx CurrentTile
        ; draw_with_pal, adjusted for our temporary stash
        lda #TILE_DISCO_FLOOR
        sta battlefield, x
        lda TileIdLow
        sta tile_patterns, x
        lda TileAttrHigh
        sta tile_attributes, x
        rts
.endproc

; Like the above, but expects DiscoRow/DiscoTile to be set by the
; calling function. Mostly used by "enemy taking damage" routines
.proc ENEMY_UPDATE_draw_disco_tile_here
TargetFuncPtr := R0

TileIdLow := R16
TileAttrHigh := R17
        perform_zpcm_inc

        ; first, load the detail variant for this floor, we'll use this as our base
        ldx DiscoTile
        lda tile_detail, x
        sta TileIdLow

        ; run the selection logic based on the player's preference
        ldx setting_disco_floor
        lda disco_behavior_lut_low, x
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, x
        sta TargetFuncPtr+1
        jsr _disco_trampoline
        ; at this point, A contains the index into the disco tile lookup table
        tax
        lda disco_tile_offset_lut_low, x
        ora TileIdLow
        sta TileIdLow
        lda disco_tile_offset_lut_high, x
        sta TileAttrHigh

        ; now perform the actual draw
        ldx DiscoTile
        ; draw_with_pal, adjusted for our temporary stash
        lda #TILE_DISCO_FLOOR
        sta battlefield, x
        lda TileIdLow
        sta tile_patterns, x
        lda TileAttrHigh
        sta tile_attributes, x
        perform_zpcm_inc
        rts
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"

; used anytime we need to guarantee that this disco tile is in its base state, usually
; when suspending a room (otherwise it looks weird on re-entry)
.proc ENEMY_UTIL_draw_cleared_disco_tile
CurrentTile := R15
        ; draw_with_pal, adjusted for our temporary stash
        ldx CurrentTile
        lda #TILE_DISCO_FLOOR
        sta battlefield, x
        ; use the detail pattern directly
        lda tile_detail, x
        sta tile_patterns, x
        ; always use the cleared variant
        lda #$00
        sta tile_attributes, x
        rts
.endproc
