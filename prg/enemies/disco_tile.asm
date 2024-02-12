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
        ldx CurrentTile
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD
        jmp converge
disco_tile:
        ldx CurrentTile
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_DISCO_FLOOR, PAL_WORLD
converge:
        ldx CurrentRow
        jsr queue_row_x
        rts
.endproc

