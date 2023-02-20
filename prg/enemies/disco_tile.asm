; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc draw_disco_tile
CurrentRow := R14
CurrentTile := R15
        ; If the current room is cleared, we release the player from the perils of the tempo. In
        ; this case, the disco tiles look _very wrong_, so don't draw them.
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne regular_tile

        ; here we want to draw a checkerboard pattern, which alternates every time the beat advances
        ; we can do this with an XOR of these low bits: X coordinate, Y coordinate, Beat Counter
        lda CurrentRow
        eor CurrentTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile
regular_tile:
        lda #TILE_REGULAR_FLOOR
        jsr draw_tile_here
        rts
disco_tile:
        lda #TILE_DISCO_FLOOR
        jsr draw_tile_here
        rts
.endproc

