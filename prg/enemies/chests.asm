; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE1"

CHEST_FLAGS_SPRITE_SPAWNED = %01000000
CHEST_FLAGS_TIME_ELAPSED   = %00111111

.proc _reroll_helpful_chest_item
CurrentTile := R15
        perform_zpcm_inc
spawn_item:
        access_data_bank PlayerZoneBank
        ldy #ZoneDefinition::StandardChestLootTable
        lda (PlayerZonePtr), y
        sta ItemLootTable+0
        iny
        lda (PlayerZonePtr), y
        sta ItemLootTable+1
        st16 ItemFallbackLootTable, fallback_standard_chest_table
        restore_previous_bank
        far_call FAR_roll_gameplay_loot
        ldx CurrentTile
        lda ResultItemId
        sta tile_data, x
        perform_zpcm_inc
        rts
.endproc

.proc _spawn_standard_chest_metasprites_if_needed
MetaSpriteIndex := R0 ; also return value, sanity check this!

ItemIndex := R1
BankOffset := R4

CurrentTile := R15
        ; If metasprites are already spawned, bail!
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        beq proceed_to_spawn
        rts
proceed_to_spawn:

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
        ora #CHEST_FLAGS_SPRITE_SPAWNED
        sta tile_flags, x

        ; Item preview sprites are floaty and transparent
        ldx MetaSpriteIndex
        lda #(SPRITE_FLICKER)
        sta sprite_table + MetaSpriteState::SpecialBehavior, x

        ; Preemptively allocate an item bank for this sprite, just for state reasons
        ldx CurrentTile
        lda tile_data, x
        sta ItemIndex
        far_call FAR_allocate_item_bank

        ; All set. Note that if we don't set attributes at the call site, this sprite
        ; will be inactive and will despawn. Don't do that?
        lda MetaSpriteIndex
        rts
.endproc

; Like the above, but we need to spawn both sprites at once
.proc _spawn_fancy_chest_metasprites_if_needed
MetaSpriteIndex := R0 ; also return value, sanity check this!

ItemIndex := R1
BankOffset := R4

CurrentTile := R15
        ; If metasprites are already spawned, bail!
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        beq proceed_to_spawn
        rts
proceed_to_spawn:

        far_call FAR_find_unused_sprite
        lda MetaSpriteIndex
        cmp #$FF
        bne fancy_sprite_succeeded
        rts

fancy_sprite_succeeded:
        ; Save this sprite's index and mark it as active, but don't do anything else yet
        ldx CurrentTile
        lda MetaSpriteIndex
        sta tile_transient_data, x
        ldy MetaSpriteIndex
        lda #SPRITE_ACTIVE
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; Okay now try to spawn the preview sprite
        far_call FAR_find_unused_sprite
        lda MetaSpriteIndex
        cmp #$FF
        bne preview_sprite_succeeded
preview_sprite_failed:
        ; darn. whelp; undo the first allocation and bail safely
        ldx CurrentTile
        lda tile_transient_data, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        rts
preview_sprite_succeeded:
        ; Store that off also, and now we're golden
        ldx CurrentTile
        lda MetaSpriteIndex
        sta tile_metasprite, x
        ; Just for consistency, mark the new sprite as active
        ldy MetaSpriteIndex
        lda #SPRITE_ACTIVE
        sta sprite_table + MetaSpriteState::BehaviorFlags, y

        ; Note that we successfully spawned both sprites
        lda tile_flags, x
        ora #CHEST_FLAGS_SPRITE_SPAWNED
        sta tile_flags, x

        ; Item preview sprites are floaty and transparent
        ldx MetaSpriteIndex
        lda #(SPRITE_FLICKER)
        sta sprite_table + MetaSpriteState::SpecialBehavior, x

        ; Preemptively allocate an item bank for the preview sprite, just for state reasons
        ldx CurrentTile
        lda tile_data, x
        sta ItemIndex
        far_call FAR_allocate_item_bank

        ; Everything else diverges based on chest type, so do that elsewhere

        ; All set. Note that if we don't set attributes at the call site, this sprite
        ; will be inactive and will despawn. Don't do that?
        lda MetaSpriteIndex
        rts
.endproc

.proc _free_preview_allocation
ItemIndex := R1
TargetSquare := R13
        ldx TargetSquare
        lda tile_data, x
        sta ItemIndex
        far_call FAR_free_item_bank
        rts
.endproc

.proc _update_preview_item
MetaSpriteIndex := R0
ItemIndex := R1
CurrentTile := R15
        ; If metasprites are NOT spawned, bail!
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        bne proceed_to_draw_preview
        rts
proceed_to_draw_preview:
        ; The preview item and attribute are drawn based on our current item ID, so get set up
        ; to read those back out
        lda tile_metasprite, x
        sta MetaSpriteIndex
        lda tile_data, x
        sta ItemIndex

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

        ; If the player isn't carrying the interrogation beam, hide this sprite offscreen
        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_INTERROGATION_BEAM
        beq has_interrogation_beam
does_not_have_interrogation_beam:
        ldx MetaSpriteIndex
        lda #$F8
        sta sprite_table + MetaSpriteState::PositionY, x
        jmp done_setting_y_position
has_interrogation_beam:
        ; But they're way up high, to float "above" the chest
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
done_setting_y_position:

        ; Preemptively allocate an item bank for this sprite, just for state reasons
        ldx CurrentTile
        lda tile_data, x
        sta ItemIndex
        far_call FAR_allocate_item_bank
        
        ; This sets the tile ID and attribute, and that second thing stops this
        ; sprite from despawning
        far_call FAR_apply_item_world_metasprite
        perform_zpcm_inc
        rts
.endproc

.proc _update_challenge_skull
MetaSpriteIndex := R0
CurrentTile := R15
        ; If metasprites are NOT spawned, bail!
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        bne proceed_to_draw
        rts
proceed_to_draw:

        lda tile_transient_data, x
        sta MetaSpriteIndex

        ; It's at our X position, of course
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        ; It's a little bit farther down though, for chest art alignment
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        clc
        adc #5
        sta sprite_table + MetaSpriteState::PositionY, x

        ; The chest sprite always has fixed graphics, and no special behavior, but WHICH skull we use
        ; depends on our own lightness
        ldy CurrentTile
        lda tile_patterns, y
        cmp #<BG_TILE_CHALLENGE_CHEST_LIGHT
        bne use_dark_skull
use_light_skull:
        set_static_04_sprite_x SPRITE_STATIC_04_CHEST_SKULL_LIGHT
        jmp done_setting_tile
use_dark_skull:
        set_static_04_sprite_x SPRITE_STATIC_04_CHEST_SKULL
done_setting_tile:
        
        ; Finally, the skull is always yellow, regardless of what color the chest is
        lda #(SPRITE_ACTIVE | SPRITE_PAL_1)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        rts
.endproc

chest_tens_digit_lut:
        .byte <SPRITE_STATIC_03_TIMER_0 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_1 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_2 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_3 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_4 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_5 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_6 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_03_TIMER_7 + SPRITE_OFFSET_STATIC_03 + 0
        .byte <SPRITE_STATIC_04_TIMER_8 + SPRITE_OFFSET_STATIC_04 + 0
        .byte <SPRITE_STATIC_04_TIMER_9 + SPRITE_OFFSET_STATIC_04 + 0
chest_ones_digit_lut:
        .byte <SPRITE_STATIC_03_TIMER_0 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_1 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_2 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_3 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_4 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_5 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_6 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_03_TIMER_7 + SPRITE_OFFSET_STATIC_03 + 2
        .byte <SPRITE_STATIC_04_TIMER_8 + SPRITE_OFFSET_STATIC_04 + 2
        .byte <SPRITE_STATIC_04_TIMER_9 + SPRITE_OFFSET_STATIC_04 + 2

.proc _update_timer_digits
MetaSpriteIndex := R0
EffectiveTimer := R1
EffectiveTens := R2
EffectiveOnes := R3
CurrentTile := R15
        ; If metasprites are NOT spawned, bail!
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        bne proceed_to_draw
        rts
proceed_to_draw:

        lda tile_transient_data, x
        sta MetaSpriteIndex

        ; It's at our X position, of course
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        ; It's a little bit farther down though, for chest art alignment
        ldx MetaSpriteIndex
        ldy CurrentTile
        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        clc
        adc #5
        sta sprite_table + MetaSpriteState::PositionY, x

        ; The timing digits are yellow, and require special behavior so that each "half" can use
        ; a different tile ID. TODO: change the palette to pink/red if the timer value is low?
        lda #(SPRITE_ACTIVE | SPRITE_PAL_1)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #SPRITE_CUSTOM_HALF
        sta sprite_table + MetaSpriteState::SpecialBehavior, x

        ; Our chest timer counts UP, so first work out the effective timer
        ldy CurrentTile
        lda tile_flags, y
        and #CHEST_FLAGS_TIME_ELAPSED
        sta EffectiveTimer
        lda #60 ; TODO: move this to a balance constant. Also consider making it tweakable somehow?
        sec
        sbc EffectiveTimer
        sta EffectiveTimer
        ; Now we need to do a simple base 10 conversion, here as a dumb naive loop
        lda #0
        sta EffectiveTens
        lda EffectiveTimer
base_10_loop:
        cmp #10
        bcc done_with_tens
        inc EffectiveTens
        sec
        sbc #10
        jmp base_10_loop
done_with_tens:
        sta EffectiveOnes

        ; Now we can draw those two tiles
        ldy EffectiveTens
        lda chest_tens_digit_lut, y
        sta sprite_table + MetaSpriteState::TileIndex, x
        ldy EffectiveOnes
        lda chest_ones_digit_lut, y
        sta sprite_table + MetaSpriteState::RightTileIndex, x
        ; And that's it for display!
        
        rts
.endproc

.proc ENEMY_UPDATE_helpful_chest
        jsr _spawn_standard_chest_metasprites_if_needed
        jsr _free_preview_allocation
        jsr _reroll_helpful_chest_item
        jsr _update_preview_item
        rts
.endproc

.proc ENEMY_UPDATE_large_chest
        jsr _spawn_standard_chest_metasprites_if_needed
        jsr _free_preview_allocation
        jsr _update_preview_item
        rts
.endproc

.proc ENEMY_UPDATE_challenge_chest
TargetIndex := R0
MetaSpriteIndex := R0
ScratchByte := R1
CurrentTile := R15
        ; Always do basic sprite maintenance
        jsr _spawn_fancy_chest_metasprites_if_needed
        jsr _free_preview_allocation
        jsr _update_preview_item
        jsr _update_challenge_skull

        ; Now process the challenge chest's basic effects. Firstly, if the room
        ; is NOT clear, reset our cooldown
        lda current_clear_status
        beq not_cleared
room_is_clear:
        ; Now increment our cooldown unconditionally
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_TIME_ELAPSED
        clc
        adc #1
        sta ScratchByte
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        ora ScratchByte
        sta tile_flags, x
        ; If our new cooldown is >= 2 beats... 
        lda ScratchByte
        cmp #2
        bcs cooldown_satisfied
        ; ... it's not, so we're done.
        rts
cooldown_satisfied:
        ; ... then deallocate only our fancy sprite, and revert to a regular large chest.
        lda tile_transient_data, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y

        ; The chest type we revert to is again based on what we are currently, so it matches the brightness
        ; we spawned with
        lda tile_patterns, x
        cmp #<BG_TILE_CHALLENGE_CHEST_LIGHT
        bne use_dark_tile
use_light_tile:
        draw_at_x_keeppal TILE_LARGE_CHEST, BG_TILE_LARGE_CHEST_LIGHT
        jmp done_setting_tile
use_dark_tile:
        draw_at_x_keeppal TILE_LARGE_CHEST, BG_TILE_LARGE_CHEST
done_setting_tile:

        ; ... and mostly for syncing with the sprite vanishing, draw ourselves right now.
        stx TargetIndex
        jsr draw_active_tile
        rts

not_cleared:
        ldx CurrentTile
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UPDATE_timed_chest
TargetIndex := R0
MetaSpriteIndex := R0
ScratchByte := R1
CurrentTile := R15
        ; TODO: timed chest behaviors! timed chest sprites!
        jsr _spawn_fancy_chest_metasprites_if_needed
        jsr _free_preview_allocation
        jsr _update_preview_item
        jsr _update_timer_digits

        ; Now process the timer chest's basic effects. Firstly, if the room
        ; is NOT clear, increment our timer
        lda current_clear_status
        beq not_cleared
room_is_clear:
        ; We don't have any extra state to store a cooldown on the clear mode, so
        ; just revert to a large chest right away. We can continue to use our
        ; base underlying graphic here, it'll look better than a shape change

        ; first, deallocate only our fancy sprite
        ldx CurrentTile
        lda tile_transient_data, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; And now revert our behavior to a standard chest. Very simple.
        lda #TILE_LARGE_CHEST
        sta battlefield, x
        ; Et voila!
        ; TODO: any "you did the thing" juice (particles, palette cycles, SFX, etc)
        rts

not_cleared:
        ; Firstly, increment our timer unconditionally (note that this is AFTER displaying
        ; the OLD timer value)
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_TIME_ELAPSED
        clc
        adc #1
        sta ScratchByte
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        ora ScratchByte
        sta tile_flags, x
        ; If our new cooldown is >= 60 beats... 
        lda ScratchByte
        cmp #62 ; TODO: test and tweak so we display 00 reliably
        bcs timer_expired
        ; ... it's not, so we're done.
        rts
timer_expired:
        ; the challenge is failed! despawn both of our sprites:
        lda tile_metasprite, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        lda tile_transient_data, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; And revert to an exploding bomb tile (right now)
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_EXPLOSION, PAL_AIR
        stx TargetIndex
        jsr draw_active_tile
        ; then draw a disco tile, which will be displayed on the next beat
        ldx CurrentTile
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        rts
.endproc

.proc ENEMY_UPDATE_proc_dingbat
        ; Only proc if we are the first call on this beat, so we don't spam the SFX
        lda RoomStateHasHiddenFeatures
        beq not_already_alerted
        rts
not_already_alerted:
        ; We should only alert if the player is actually carrying the item. This way,
        ; if they happen to obtain the item while in a room with a hidden secret, it
        ; will ding right away.
        
        lda current_save + SaveFile::PlayerEquipmentAccessory
        cmp #ITEM_DINGBAT
        beq perform_alert
        rts

perform_alert:
        ; Proceed to actually alert
        queue_sfx_pulse1 sfx_dingbat
        inc RoomStateHasHiddenFeatures
        rts
.endproc

; For level generation reasons, the hidden chests are split out into separate tile IDs.
; This is because the attribute, which would normally indicate rarity, is being used as
; part of whatever wall tile they end up embedded within. "Blue zones tend to have better
; loot" would be an interesting spice, but... no, we want actual control thanks XD

.proc ENEMY_UPDATE_hidden_chest
; Return from FAR_spawn_entity
SpawnedEntityIndex := R0
; arguments to FAR_spawn_entity
EntityId := R1
EntityPattern := R2
EntityAttribute := R3

ScratchByte := R1
CurrentTile := R15
        near_call ENEMY_UPDATE_proc_dingbat

        ; Now process the hidden chest's effects. Firstly, if the room
        ; is NOT clear, reset our cooldown
        lda current_clear_status
        beq not_cleared
room_is_clear:
        ; Now increment our cooldown unconditionally
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_TIME_ELAPSED
        clc
        adc #1
        sta ScratchByte
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        ora ScratchByte
        sta tile_flags, x
        ; If our new cooldown is >= 2 beats... 
        lda ScratchByte
        cmp #2
        bcs cooldown_satisfied
        ; ... it's not, so we're done.
        rts
cooldown_satisfied:
        
        ; Okay now things get fun: we need to try to spawn the chest somewhere inside the room, but
        ; only on otherwise valid tiles. This is just like the old room clear logic.
        
        ; First, spawn in the entity. 
        lda #TILE_HELPFUL_CHEST
        sta EntityId
        ; We need to pick the tile to spawn based on whether our current
        ; room is dark. (hopefully we don't need special cases here >_<)
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_darkness
darkness:
        lda #<BG_TILE_SMALL_CHEST
        sta EntityPattern
        lda #(>BG_TILE_SMALL_CHEST | PAL_AIR)
        sta EntityAttribute
        jmp perform_spawn
no_darkness:
        lda #<BG_TILE_SMALL_CHEST_LIGHT
        sta EntityPattern
        lda #(>BG_TILE_SMALL_CHEST_LIGHT | PAL_AIR)
        sta EntityAttribute
        ; fall through to perform_spawn
perform_spawn:
        far_call FAR_spawn_entity
        ; With the entity index we just spawned, copy in our own tile data, so it has the proper
        ; item sprite
        ldx CurrentTile
        ldy SpawnedEntityIndex
        lda tile_data, x
        sta tile_data, y

        ; With that, we're done with this logic. We don't need any personal graphical updates, we simply
        ; revert back to a wall tile. All set.
        lda #TILE_WALL
        sta battlefield, x
        rts

not_cleared:
        ldx CurrentTile
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UPDATE_hidden_rare_chest
; Return from FAR_spawn_entity
SpawnedEntityIndex := R0
; arguments to FAR_spawn_entity
EntityId := R1
EntityPattern := R2
EntityAttribute := R3

ScratchByte := R1
CurrentTile := R15
        near_call ENEMY_UPDATE_proc_dingbat

        ; Now process the hidden chest's effects. Firstly, if the room
        ; is NOT clear, reset our cooldown
        lda current_clear_status
        beq not_cleared
room_is_clear:
        ; Now increment our cooldown unconditionally
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_TIME_ELAPSED
        clc
        adc #1
        sta ScratchByte
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        ora ScratchByte
        sta tile_flags, x
        ; If our new cooldown is >= 2 beats... 
        lda ScratchByte
        cmp #2
        bcs cooldown_satisfied
        ; ... it's not, so we're done.
        rts
cooldown_satisfied:
        
        ; Okay now things get fun: we need to try to spawn the chest somewhere inside the room, but
        ; only on otherwise valid tiles. This is just like the old room clear logic.
        
        ; First, spawn in the entity. 
        lda #TILE_LARGE_CHEST
        sta EntityId
        ; We need to pick the tile to spawn based on whether our current
        ; room is dark. (hopefully we don't need special cases here >_<)
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_darkness
darkness:
        lda #<BG_TILE_LARGE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_LARGE_CHEST | PAL_FIRE)
        sta EntityAttribute
        jmp perform_spawn
no_darkness:
        lda #<BG_TILE_LARGE_CHEST_LIGHT
        sta EntityPattern
        lda #(>BG_TILE_LARGE_CHEST_LIGHT | PAL_FIRE)
        sta EntityAttribute
        ; fall through to perform_spawn
perform_spawn:
        far_call FAR_spawn_entity
        ; With the entity index we just spawned, copy in our own tile data, so it has the proper
        ; item sprite
        ldx CurrentTile
        ldy SpawnedEntityIndex
        lda tile_data, x
        sta tile_data, y

        ; With that, we're done with this logic. We don't need any personal graphical updates, we simply
        ; revert back to a wall tile. All set.
        lda #TILE_WALL
        sta battlefield, x
        rts

not_cleared:
        ldx CurrentTile
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UPDATE_hidden_legendary_chest
; Return from FAR_spawn_entity
SpawnedEntityIndex := R0
; arguments to FAR_spawn_entity
EntityId := R1
EntityPattern := R2
EntityAttribute := R3

ScratchByte := R1
CurrentTile := R15
        near_call ENEMY_UPDATE_proc_dingbat

        ; Now process the hidden chest's effects. Firstly, if the room
        ; is NOT clear, reset our cooldown
        lda current_clear_status
        beq not_cleared
room_is_clear:
        ; Now increment our cooldown unconditionally
        ldx CurrentTile
        lda tile_flags, x
        and #CHEST_FLAGS_TIME_ELAPSED
        clc
        adc #1
        sta ScratchByte
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        ora ScratchByte
        sta tile_flags, x
        ; If our new cooldown is >= 2 beats... 
        lda ScratchByte
        cmp #2
        bcs cooldown_satisfied
        ; ... it's not, so we're done.
        rts
cooldown_satisfied:
        
        ; Okay now things get fun: we need to try to spawn the chest somewhere inside the room, but
        ; only on otherwise valid tiles. This is just like the old room clear logic.
        
        ; First, spawn in the entity. 
        lda #TILE_LARGE_CHEST
        sta EntityId
        ; We need to pick the tile to spawn based on whether our current
        ; room is dark. (hopefully we don't need special cases here >_<)
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_darkness
darkness:
        lda #<BG_TILE_LARGE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_LARGE_CHEST | PAL_ICE)
        sta EntityAttribute
        jmp perform_spawn
no_darkness:
        lda #<BG_TILE_LARGE_CHEST_LIGHT
        sta EntityPattern
        lda #(>BG_TILE_LARGE_CHEST_LIGHT | PAL_ICE)
        sta EntityAttribute
        ; fall through to perform_spawn
perform_spawn:
        far_call FAR_spawn_entity
        ; With the entity index we just spawned, copy in our own tile data, so it has the proper
        ; item sprite
        ldx CurrentTile
        ldy SpawnedEntityIndex
        lda tile_data, x
        sta tile_data, y

        ; With that, we're done with this logic. We don't need any personal graphical updates, we simply
        ; revert back to a wall tile. All set.
        lda #TILE_WALL
        sta battlefield, x
        rts

not_cleared:
        ldx CurrentTile
        lda tile_flags, x
        and #($FF - CHEST_FLAGS_TIME_ELAPSED)
        sta tile_flags, x
        rts
.endproc


; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_open_unlocked_chest
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
WeaponPtr := R11
        ; Register the attack as a hit
        lda #1
        sta WeaponAttackLanded
        
        ldx AttackSquare
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        beq skip_sprite_cleanup
        lda tile_metasprite, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        sta tile_metasprite, x
skip_sprite_cleanup:

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        rts
.endproc

; ============================================================================================================================
; ===                                      Enemy Attacks Player Behaviors                                                  ===
; ============================================================================================================================
 

        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_open_unlocked_chest
TargetIndex := R0
TargetSquare := R13
        ; We behave like a wall on this beat, so we still want to push the player
        ; back if we can.
        ; But we also go ahead and open, which permits movement that is not an attack
        ; to still open the chest. This mostly helps to resolve situations with weapons that
        ; don't "attack" the square in the direction the player is moving.

        ldx TargetSquare
        lda tile_flags, x
        and #CHEST_FLAGS_SPRITE_SPAWNED
        beq skip_sprite_cleanup
        lda tile_metasprite, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        sta tile_metasprite, x
skip_sprite_cleanup:

        ; Mostly easy: replace the chest with an item shadow
        ldx TargetSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        ; Play the "weapon slash" sfx, just like if an attack had occurred, which functions as our
        ; "open chest" SFX in any other context. 
        queue_sfx_noise sfx_weapon_slash

        near_call ENEMY_COLLIDE_solid_tile_forbids_movement

        rts
.endproc

; TODO: rework this into an item? (what color will it be?)
; Alternate: rework it *properly* into an entity that follows the player
; (and can be stolen!)
.proc ENEMY_COLLIDE_collect_key
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda #1 ; there is only one key per dungeon floor
        sta PlayerKeys

        queue_sfx_pulse1 sfx_key_pulse1
        queue_sfx_pulse2 sfx_key_pulse2

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_EARTH

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; This is the big key! Now that we have it, reveal the location of the exit
        ; stairs (this stops the player from needing to do a brute-force search)
        ldx #0
find_exit_loop:
        perform_zpcm_inc
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq next_room
        lda room_minimap_state, x
        ora #ROOM_MINIMAP_FLAG_IDENTIFIED
        sta room_minimap_state, x
next_room:
        inx
        cpx #::FLOOR_SIZE
        bne find_exit_loop

        lda #1
        sta HudMapDirty

        rts
.endproc


; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"

.proc ENEMY_UTIL_suspend_helpful_chest
CurrentSquare := R15
        ; we should forget about our metasprites, so we know to respawn them later
        ldx CurrentSquare
        lda tile_flags, x
        and #($FF-CHEST_FLAGS_SPRITE_SPAWNED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UTIL_suspend_large_chest
CurrentSquare := R15
        ; we should forget about our metasprites, so we know to respawn them later
        ldx CurrentSquare
        lda tile_flags, x
        and #($FF-CHEST_FLAGS_SPRITE_SPAWNED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UTIL_suspend_challenge_chest
CurrentSquare := R15
        ; we should forget about our metasprites, so we know to respawn them later
        ldx CurrentSquare
        lda tile_flags, x
        and #($FF-CHEST_FLAGS_SPRITE_SPAWNED)
        sta tile_flags, x
        rts
.endproc

.proc ENEMY_UTIL_suspend_timed_chest
CurrentSquare := R15
        ; we should forget about our metasprites, so we know to respawn them later
        ldx CurrentSquare
        lda tile_flags, x
        and #($FF-CHEST_FLAGS_SPRITE_SPAWNED)
        sta tile_flags, x
        rts
.endproc

