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
        lda tile_data, x
        sta ItemIndex

        ; For testing, load a lvl 1 dagger
        ;lda #ITEM_DAGGER_L1
        ;sta ItemIndex
        
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
ItemPtr         := R0
ItemCost        := R2
PriceColor      := R4

MetaSpriteIndex := R0

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        ; If this is an item for purchase, we need to look up its cost
        ; and display it
        ldx CurrentTile
        lda tile_flags, x
        and #ITEM_FOR_PURCHASE
        beq skip_cost_drawing

        ; Lookup the item properties from the table and nab the purchase price
        access_data_bank #<.bank(item_table)

        ; look up the item properties and stash them for later
        ldx CurrentTile
        lda tile_data, x
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1
        ldy #ItemDef::ShopCost
        lda (ItemPtr), y
        sta ItemCost+0
        iny
        lda (ItemPtr), y
        sta ItemCost+1

        restore_previous_bank

        ; if the player can afford this item, draw it in white. otherwise, draw it in red

        cmp16 PlayerGold, ItemCost
        jcc thats_too_expensive ; Can't afford it. Sorry!

sell_it_to_meeeeeee:
        lda #(PAL_BLUE | CHR_BANK_000_SHIFTED_NUMERALS)
        jmp queue_cost
thats_too_expensive:
        lda #(PAL_RED | CHR_BANK_000_SHIFTED_NUMERALS)
queue_cost:
        sta PriceColor
        far_call FAR_queue_price_tile_here
skip_cost_drawing:

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
ItemPtr := R0
ItemCost := R2
ItemSlot := R4
OldItem := R5


; for use by draw_active_tile later
TargetIndex := R0
TargetSquare := R13
        ; sanity: if we haven't spawned in yet, we cannot be collected. this prevents the player
        ; from rapidly picking up items while they stand on the square
        ldx TargetSquare
        lda tile_flags, x
        and #ITEM_SPRITE_SPAWNED
        bne try_item_collection
        rts

try_item_collection:
        access_data_bank #<.bank(item_table)

        ; look up the item properties and stash them for later
        ldx TargetSquare
        lda tile_data, x
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1
        ldy #ItemDef::ShopCost
        lda (ItemPtr), y
        sta ItemCost+0
        iny
        lda (ItemPtr), y
        sta ItemCost+1
        ldy #ItemDef::SlotId
        lda (ItemPtr), y
        sta ItemSlot

        restore_previous_bank

        ; if this is not an item for purchase, then perform the collection right away
        ldx TargetSquare
        lda tile_flags, x
        and #ITEM_FOR_PURCHASE
        beq perform_collection        

        cmp16 PlayerGold, ItemCost
        jcc deny_collection ; Can't afford it. Sorry!

        ; "We take Visa."
        sec
        lda PlayerGold+0
        sbc ItemCost+0
        sta PlayerGold+0
        lda PlayerGold+1
        sbc ItemCost+1
        sta PlayerGold+1

perform_collection:
        ; Play a joyous SFX
        ; TODO: should this be a different sound depending on the type of item? (yes, but how?)
        st16 R0, sfx_equip_ability_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_equip_ability_pulse2
        jsr play_sfx_pulse2

        ldy ItemSlot
        ; switcheroo!
        lda player_equipment_by_index, y
        sta OldItem
        ldx TargetSquare
        lda tile_data, x
        sta player_equipment_by_index, y

        ; we need to despawn our metasprite (the player's going to occupy this square, it should vanish)
        lda tile_metasprite, x
        tay
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y

        ; before we write the old item back, sanity check: is it nothing?
        ; if so, we should revert to a disco tile
        lda OldItem
        beq revert_to_disco_tile
        sta tile_data, x

        ; otherwise we have some cleanup to do. first off, the item was just purchased, so
        ; this tile is no longer a purchase square (the player can pick up their old item and
        ; swap back for free). while we're here, we also need to clear the "item spawned" flag so
        ; that the logic knows to spawn in the new one once the player moves away
        lda tile_flags, x
        and #($FF - ITEM_FOR_PURCHASE - ITEM_SPRITE_SPAWNED)
        sta tile_flags, x

        ; And we're done!
        rts

revert_to_disco_tile:
        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_WORLD)
        sta tile_attributes, x
        lda #0
        sta tile_data, x
        sta tile_flags, x
        jsr draw_active_tile
        rts

deny_collection:
        ; If the player can't afford this item, or can't pick it up for some other reason, then
        ; block their movement just like any wall
        jsr solid_tile_forbids_movement

        st16 R0, sfx_too_poor_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_too_poor_pulse2
        jsr play_sfx_pulse2

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