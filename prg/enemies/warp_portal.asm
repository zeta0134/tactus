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

        rts
.endproc

        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_teleport_to_warp_entrance
        rts
.endproc

        .segment "ENEMY_UPDATE"

.proc ENEMY_UPDATE_draw_warp_portal
        ; Draw the fancy flickery palette thing! We do this every
        ; update because it resets when we switch rooms. Want the portal
        ; to still be here if the player decides to leave and then come back.
        ; TODO: also flag this on the minimap, yes yes!
        rts
.endproc