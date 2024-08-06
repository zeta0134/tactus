; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc draw_disco_tile
CurrentRow := R14
CurrentTile := R15

TileIdLow := R16
TileAttrHigh := R17

        ; first, load the detail variant for this floor, we'll use this as our base
        ldx CurrentTile
        lda tile_detail, x
        sta TileIdLow

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
        lda CurrentRow
        eor CurrentTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile

regular_tile:
        ; unlit tiles still animate, so do that here. animations are always the 3rd variant
        lda #$0C
        jmp converge
cleared_tile:
        lda #$00
        jmp converge
disco_tile:
        ; disco tiles have two accessibility modes: regular and outline, so handle that here
        lda setting_disco_floor
        cmp #DISCO_FLOOR_OUTLINE
        beq outlined_disco_tile
full_disco_tile:
        lda #$04
        jmp converge
outlined_disco_tile:
        lda #$08
        jmp converge

converge:
        ;ora #$80
        sta TileAttrHigh
        ; TODO: what if this room needs a different palette for floor tiles?
        ; Ideally we could specify this as part of the map data... there's 2 free bits
        ; in the detail byte

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

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================


; used anytime we need to guarantee that this disco tile is in its base state, usually
; when suspending a room (otherwise it looks weird on re-entry)
.proc draw_cleared_disco_tile
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