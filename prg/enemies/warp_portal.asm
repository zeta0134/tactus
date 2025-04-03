; Warp Portals! (and associated hidden blocks which become them)

    .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_cleanup_warp_entrance
        rts
.endproc

        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_become_warp_portal
AttackSquare := R3
        ; TODO: immediately start to palette cycle! (That's not built out yet)
        ldx AttackSquare

        ; First, preserve our old tile type. We'll use this when cleaning up the
        ; entrance, as we need to know if we should replace it with a wall or a
        ; disco floor among other stuff
        lda battlefield, x
        sta tile_data, x

        ; Set ourselves to a warp portal!
        lda #TILE_WARP_PORTAL
        sta battlefield, x
        ; TODO: if we have variants, decide on those and do that here
        ; (optional todo: decorative nearby tile variants? sounds kinda complicated!)
        lda #<BG_TILE_SPIRAL
        sta tile_patterns, x
        lda tile_attributes, x
        and #PAL_MASK
        ora #>BG_TILE_SPIRAL
        sta tile_attributes, x

        ; TODO: play a real fancy SFX?
        ; TODO: draw right now? it's a bit unclear!

        rts
.endproc

        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_teleport_to_warp_entrance
TargetSquare := R13

TargetRow := R14
TargetCol := R15
        ; if our current and target position is already the same, bail!
        ; this prevents two separate issues:
        ;  - players revealing a warp tile they're currently standing on
        ;  - players getting ejected into a cracked warp tile, which reverts to an actual wall
        lda PlayerCol
        cmp TargetCol
        bne proceed_to_warp
        lda PlayerRow
        cmp TargetRow
        bne proceed_to_warp
        rts        
proceed_to_warp:
        lda PlayerCol
        sta PlayerWarpEjectCol
        lda PlayerRow
        sta PlayerWarpEjectRow

        lda #29
        sta WarpStability
        lda #0
        sta MusicalWarpStabilityCooldown

        lda WarpEntranceRoomIndex
        sta PlayerRoomIndex

        lda #ROOM_TRANSITION_WARP_ENTRANCE
        sta RoomTransitionType
        st16 GameMode, room_transition

        ; mark the room as "busy", this prevents us clearing the next room prematurely
        lda #1
        sta first_beat_after_load
        ; suppress torchlight updates over the transition (resolves minor visual jank)
        lda #1
        sta SuppressTorchlight
        ; we may not PAUSE over the exit transition. this normally shouldn't occur, but
        ; an enemy might have forced us to the screen edge or something, so be safe
        lda #0
        sta PlayerIntendsToPause

        ; TODO: flag the warp portal so that it vanishes (on suspend) if the player is later ejected!
        ; (since we aren't going to draw+active this tile, maybe we can do that now?)
        ldx TargetSquare
        lda tile_data, x
        sta battlefield, x
        lda WarpOverlayPattern
        sta tile_patterns, x
        lda WarpOverlayAttr
        sta tile_attributes, x

        rts
.endproc

        .segment "ENEMY_UPDATE"

.proc ENEMY_UPDATE_draw_warp_portal
CurrentRow := R14
CurrentTile := R15
        ; Draw the fancy flickery palette thing! We do this every
        ; update because it resets when we switch rooms. Want the portal
        ; to still be here if the player decides to leave and then come back.
        ; TODO: also flag this on the minimap, yes yes!

        lda CurrentTile
        sta WarpTilePos

        rts
.endproc

.proc ENEMY_UPDATE_hidden_warp_tile
CurrentRow := R14
CurrentTile := R15
        ; Visually behave like a regular disco tile
        near_call ENEMY_UPDATE_draw_disco_tile

        ; But make sure we still behave like a hidden warp floor tile, and not
        ; a permanent disco tile
        ldx CurrentTile
        lda #TILE_HIDDEN_WARP_FLOOR
        sta battlefield, x

        rts
.endproc

        .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_suspend_hidden_warp_tile
CurrentRow := R14
CurrentTile := R15
        ; Visually behave like a regular disco tile
        near_call ENEMY_UTIL_draw_cleared_disco_tile

        ; But make sure we still behave like a hidden warp floor tile, and not
        ; a permanent disco tile
        ldx CurrentTile
        lda #TILE_HIDDEN_WARP_FLOOR
        sta battlefield, x

        rts
.endproc
