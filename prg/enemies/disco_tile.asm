; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

; FOR NOW, use a very static detail table
; (this will soon be replaced by the new map loading routine, I just want to
; see it work in the very short term)

disco_detail_lut:
        ; top two rows have no detail; if floor is drawn it is blank
        .repeat 14 * 2
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000
        .endrepeat
        ; third row starts a square, with corners 1 tile in
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000, <BG_TILE_DISCO_FLOOR_TILES_0001
        .repeat 10
        .byte <BG_TILE_DISCO_FLOOR_TILES_0002
        .endrepeat
        .byte <BG_TILE_DISCO_FLOOR_TILES_0003, <BG_TILE_DISCO_FLOOR_TILES_0000

        ; every row inbetween is the sides of the square, and some... mushrooms
        ; so we can see the dancing animation at work
        .repeat 5
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000, <BG_TILE_DISCO_FLOOR_TILES_0017
        .repeat 10
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000
        .endrepeat
        .byte <BG_TILE_DISCO_FLOOR_TILES_0019, <BG_TILE_DISCO_FLOOR_TILES_0000
        .endrepeat

        ; second to last row is the lower bit of the square
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000, <BG_TILE_DISCO_FLOOR_TILES_0033
        .repeat 10
        .byte <BG_TILE_DISCO_FLOOR_TILES_0034
        .endrepeat
        .byte <BG_TILE_DISCO_FLOOR_TILES_0035, <BG_TILE_DISCO_FLOOR_TILES_0000
        ; bottom row is, again, nothing
        .repeat 14
        .byte <BG_TILE_DISCO_FLOOR_TILES_0000
        .endrepeat

.proc draw_disco_tile
CurrentRow := R14
CurrentTile := R15

TileIdLow := R16
TileAttrHigh := R17

        ; first, load the detail variant for this floor, we'll use this as our base
        ldx CurrentTile
        lda disco_detail_lut, x
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
        sta TileAttrHigh
        ; TODO: what if this room needs a different palette for floor tiles?
        ; Ideally we could specify this as part of the map data... there's 2 free bits
        ; in the detail byte

        ldx CurrentTile
        ; draw_with_pal, adjusted for our temporary stash
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda TileIdLow
        sta tile_patterns, x
        lda TileAttrHigh
        sta tile_attributes, x

        ldx CurrentRow
        jsr queue_row_x
        rts
.endproc

