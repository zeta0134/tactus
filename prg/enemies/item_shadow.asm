ITEM_SPRITE_SPAWNED = %00000001
ITEM_FOR_PURCHASE   = %00000010

.proc draw_item_sprite
; as used by FAR_apply_item_world_metasprite 
MetaSpriteIndex := R0
ItemIndex := R1

CurrentRow := R14
CurrentTile := R15

        ; we can use the utility function to set the TileId and BehaviorFlags for
        ; this sprite:
        ldx CurrentTile
        lda tile_metasprite, x
        sta MetaSpriteIndex
        
        ; Load the real item
        ;lda tile_data, x
        ;sta ItemIndex

        ; For testing, load a lvl 1 dagger
        lda #ITEM_DAGGER_L1
        sta ItemIndex
        
        far_call FAR_apply_item_world_metasprite

        ; the X and Y position will be based on our current location, very similar to
        ; how we spawn death sprites

        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta sprite_table + MetaSpriteState::PositionY, x

        ; that should be it?
        
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc update_item_shadow
MetaSpriteIndex := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15

check_spawned_state:
        ; If we already have the item spawned, then there is not much
        ; else to do while we update.
        ldx CurrentTile
        lda tile_flags, x
        and #ITEM_SPRITE_SPAWNED
        beq check_player_position
        rts

check_player_position:
        ; Only spawn the new sprite if the player is somewhere other
        ; than our current position. (This stops things looking weird
        ; on the beat after the player has picked up the item, if they
        ; are also dropping an old item in its place.)
        lda CurrentRow
        cmp PlayerRow
        bne proceed_to_spawn_sprite
        ldx CurrentTile
        lda tile_index_to_col_lut, x ; A is now effectively CurrentCol
        cmp PlayerCol
        bne proceed_to_spawn_sprite
        rts

proceed_to_spawn_sprite:
        ; Spawn a new sprite object. This can fail in very busy
        ; situations (if the player is managing items during combat)
        ; so handle that gracefully
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        ; We need to despawn this later, so store the index
        ldy CurrentTile
        txa
        sta tile_metasprite, y

        jsr draw_item_sprite

        ; Okay, now we just need to preserve the WeaponClass byte as tile flags. for later use
        ; when this thing is collected by the player
        ldx CurrentTile
        lda tile_flags, x
        ora #ITEM_SPRITE_SPAWNED
        sta tile_flags, x
        ; ... and... we're done?

sprite_failed:
        ; no big deal, try again next beat. we shouldn't be starved indefinitely,
        ; but might have to wait if a bomb went off or something.
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc collect_item

        ; stub: nope!
        jsr solid_tile_forbids_movement

        rts
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================

.proc suspend_item_shadow
CurrentSquare := R15
        ; all we need to do is forget about our metasprite; we'll need to respawn it
        ; when we later resume

        ldx CurrentSquare
        lda tile_flags, x
        and #($FF-ITEM_SPRITE_SPAWNED)
        sta tile_flags, x

        rts
.endproc