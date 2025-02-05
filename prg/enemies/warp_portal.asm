; Warp Portals! (and associated hidden blocks which become them)

    .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_cleanup_warp_entrance
        rts
.endproc

        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_become_warp_portal
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