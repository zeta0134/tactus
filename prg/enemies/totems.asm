; Yes plural. There are going to be a bunch of these, and they all share an entrypoint.
; These are uncommon in-world blocks, and rarely appear in a performance critical scenario,
; so they are prime candidates to have their entrypoints stubbed, and the core logic
; moved to some other bank.

; All totems have a state ID in their data byte, and may use the lower 7 bits of flags as
; additional state. These are almost always special case game-state affecting objects,
; so feel free to allocate additional memory for them as required.

        .segment "ENEMY_UPDATE0"

TOTEM_SPRITE_SPAWNED = %00000001

totem_update_dispatch_lut:
        .word ENEMY_UPDATE_empty_totem ; also default, if somehow created wrongly
        .word ENEMY_UPDATE_save_totem

.proc ENEMY_UPDATE_spawn_totem_sprite
MetaSpriteIndex := R0 ; also return value, sanity check this!
CurrentTile := R15

check_spawned_state:
        ; If we already have the item spawned, then there is not much
        ; else to do while we update.
        ldx CurrentTile
        lda tile_flags, x
        and #TOTEM_SPRITE_SPAWNED
        bne sprite_already_spawned

        far_call FAR_find_unused_sprite
        lda MetaSpriteIndex
        cmp #$FF
        bne sprite_succeeded
        rts

sprite_succeeded:
        ldx CurrentTile
        lda MetaSpriteIndex
        sta tile_metasprite, x
        lda tile_flags, x
        ora #TOTEM_SPRITE_SPAWNED
        sta tile_flags, x
        ; Setup everything except the tile ID / attributes, the calling function
        ; is in charge of that. Totems share sprite logic otherwise.

        ; Totem sprites are floaty, like items, and get some other special behaviors
        ; to handle disk side flipping
        ldx MetaSpriteIndex
        lda #SPRITE_FLOAT
        sta sprite_table + MetaSpriteState::SpecialBehavior, x

        ; They're at our X position, of course
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        ; But they're way up high, to float "above" the totem block
        ; (also, don't put totem blocks too close to the top of the map, it'll
        ; look weird)
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sec
        sbc #14 ; a liiiitle bit of overlap should look good?
        sta sprite_table + MetaSpriteState::PositionY, x

        ; All set. Note that if we don't set attributes at the call site, this sprite
        ; will be inactive and will despawn. Don't do that?
        lda MetaSpriteIndex
        rts

sprite_already_spawned:
        ldx CurrentTile
        lda tile_metasprite, x
        sta MetaSpriteIndex
        rts

.endproc

.proc ENEMY_UPDATE_totem_update
TotemDispatchPtr := R0
CurrentTile := R15
        ldx CurrentTile
        lda tile_data, x
        ; TODO: sanity / range check?
        asl
        tax
        lda totem_update_dispatch_lut+0, x
        sta TotemDispatchPtr+0
        lda totem_update_dispatch_lut+1, x
        sta TotemDispatchPtr+1
        jmp (TotemDispatchPtr)
        ; bye!
.endproc

.proc ENEMY_UPDATE_empty_totem
        ; It's absolutely nothing.
        rts
.endproc

.proc ENEMY_UPDATE_save_totem
MetaSpriteIndex := R0 ; also return value, sanity check this!
CurrentTile := R15
        ; Firstly, spawn our sprite. Should this fail for whatever reason (how!?), bail!
        near_call ENEMY_UPDATE_spawn_totem_sprite
        cmp #$FF
        bne sprite_succeeded
        rts
sprite_succeeded:

        ; TODO: If we start to run out of static sprite slots, we could have totems subscribe to
        ; the same allocation system that items use. Generally, totems and items won't be in the
        ; same room, though they could still coexist in small numbers or with sufficient bank sharing.
        ; Anyway, skipping this for now because we don't have that many totem sprites. It's fine.
        ; (I was worried about the 16 fixed-seed sprites, but those need to be background elements)

        ; Use the diskette as our base
        ldx MetaSpriteIndex
        set_static_07_sprite_x SPRITE_STATIC_07_DISKETTE
        ; Save sprites have a front/back facing thing going on, so get that set
        lda sprite_table + MetaSpriteState::SpecialBehavior, x
        ora #SPRITE_BIPHASIC
        sta sprite_table + MetaSpriteState::SpecialBehavior, x
        ; For now, just use the blue palette (later we'll cycle this)
        lda #(SPRITE_ACTIVE | SPRITE_PAL_YELLOW)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        ; And... that's it?
        rts
.endproc

        .segment "ENEMY_COLLIDE"

totem_collide_dispatch_lut:
        .word ENEMY_COLLIDE_solid_tile_forbids_movement ; empty totems have no behavior (but still go through dispatch)
        .word ENEMY_COLLIDE_save_totem

.proc ENEMY_COLLIDE_with_totem
TotemDispatchPtr := R0
TargetSquare := R13
        ldx TargetSquare
        lda tile_data, x
        ; TODO: sanity / range check?
        asl
        tax
        lda totem_collide_dispatch_lut+0, x
        sta TotemDispatchPtr+0
        lda totem_collide_dispatch_lut+1, x
        sta TotemDispatchPtr+1
        jmp (TotemDispatchPtr)
        ; bye!
.endproc

.proc ENEMY_COLLIDE_save_totem
TargetSquare := R13

        ; First up, always block player movement. This is a solid object.
        near_call ENEMY_COLLIDE_solid_tile_forbids_movement

        ; For now: just suspend out without confirmation. It's fine?
        ; (This looks **slightly** janky. We might want to put the player
        ; in some sort of a suspend state to animate out more cleanly.)
        st16 GameMode, suspend_current_game

        ; Fun SFX!
        queue_sfx_pulse1 sfx_teleport

        ; Do not run this logic again!
        ldx TargetSquare
        lda #TOTEM_EMPTY
        sta tile_data, x
    
        rts
.endproc

        .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_suspend_totem
CurrentSquare := R15
        ; If we are a save totem, we need to revert to an empty totem when the player
        ; leaves this map square.
        ldx CurrentSquare
        lda tile_data, x
        cmp #TOTEM_SAVE
        bne not_a_save_totem
        lda #TOTEM_EMPTY
        sta tile_data, x
not_a_save_totem:

        ; Clear out our sprite allocation bit, so we respawn the sprite on entry
        ldx CurrentSquare
        lda tile_flags, x
        and #($FF - TOTEM_SPRITE_SPAWNED)
        sta tile_flags, x
        rts
.endproc