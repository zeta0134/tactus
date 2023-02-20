                        ; ssccccdd
SHADOW_STATE_MASK      = %11000000
SHADOW_WEAPON_MASK     = %00111100
SHADOW_DMG_MASK        = %00000011
SHADOW_STATE_ACTIVE    = %00000000
SHADOW_STATE_COLLECTED = %01000000

; map all 5 weapons to 16 entries, for a mostly fair random type
; we'll give longswords one extra slot, as they're a fairly decent
; weapon type that many players will find success with
cheaty_weapon_lut:
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL

        ; bonus percent
        .byte WEAPON_BROADSWORD
        .byte WEAPON_BROADSWORD
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_SPEAR
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        .byte WEAPON_FLAIL

weapon_damage_lut:
        .byte 1, 2, 3, 3

; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================

.proc roll_weapon
WeaponClassTemp := R1
        jsr set_fixed_room_seed

perform_roll:
        ; First we need to roll a weapon class
        jsr next_fixed_rand
        and #(SHADOW_WEAPON_MASK | SHADOW_DMG_MASK) ; low 2 bits = weapon strength, middle 4 bits = weapon type from table
        sta WeaponClassTemp
        ; weapon strength should be clamped based on the current floor (and later, zone?)
        and #SHADOW_DMG_MASK ; isolate the damage index
        cmp PlayerFloor
        bcc zone_index_valid
        lda #0 ; force a lvl 1 weapon; this affects spawn rate of higher tier weapons on each floor
zone_index_valid:
        tax
        lda WeaponClassTemp
        and #SHADOW_WEAPON_MASK   ; isolate weapon type
        ora weapon_damage_lut, x  ;  apply the damage bits here
        sta WeaponClassTemp
check_reroll_condition:
        ; If this weapon is a totally different class from the player's equipped weapon, then keep it
        lda WeaponClassTemp
        and #SHADOW_WEAPON_MASK
        lsr
        lsr
        tax
        lda cheaty_weapon_lut, x
        cmp PlayerWeapon
        bne keep_this_weapon
        ; Since this is the same weapon class the player is holding, keep it only if it is an upgrade
        lda WeaponClassTemp
        and #SHADOW_DMG_MASK
        cmp PlayerWeaponDmg
        beq perform_roll
        bcs keep_this_weapon
        jmp perform_roll

keep_this_weapon:
        rts
.endproc

.proc draw_weapon_sprite
MetaSpriteIndex := R0
WeaponClassTemp := R1
DestinationSquare := R3
WeaponPtr := R11
        ; This is an active sprite, it does not move
        ; and the palette we choose here will be the same as the weapon class low 2 bits
        lda WeaponClassTemp
        and #SHADOW_DMG_MASK
        ora #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF ; irrelevant
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        ; the X and Y position will be based on our current location, very similar to
        ; how we spawn death sprites
        ldy DestinationSquare
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

        ; Finally the tile ID will be based on the weapon class we rolled, so
        ; let's work that out
        lda WeaponClassTemp
        lsr
        lsr
        tax
        lda cheaty_weapon_lut, x
        ; now use the weapon type to index into the weapons table
        asl
        tax
        lda weapon_class_table, x
        sta WeaponPtr
        lda weapon_class_table+1, x
        sta WeaponPtr+1
        ldy #WeaponClass::TileIndex
        lda (WeaponPtr), y
        ldx MetaSpriteIndex
        sta sprite_table + MetaSpriteState::TileIndex, x

        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc update_weapon_shadow
PlayerTile := R0
MetaSpriteIndex := R0
WeaponClassTemp := R1
DestinationSquare := R3
; these are provided for us
CurrentRow := R14
CurrentTile := R15

check_collected_state:
        ; If we are currently in a collected state...
        ldx CurrentTile
        lda tile_flags, x
        and #SHADOW_STATE_MASK
        cmp #SHADOW_STATE_COLLECTED
        beq check_player_position
        rts

check_player_position:
        ; ... and the player is not standing right on top of us ...
        lda CurrentRow
        cmp PlayerRow
        bne spawn_old_weapon
        ldx CurrentTile
        lda tile_index_to_col_lut, x ; A is now effectively CurrentCol
        cmp PlayerCol
        bne spawn_old_weapon
        rts

spawn_old_weapon:
        ; Spawn a sprite to hold the weapon
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        ; We need to despawn this later, so store the index in the data byte for this tile
        ldy CurrentTile
        txa
        sta tile_data, y

        ; Draw the sprite based on the old weapon, which is stashed in the current tile_flags
        lda tile_flags, y
        and #(SHADOW_WEAPON_MASK | SHADOW_DMG_MASK)
        sta WeaponClassTemp

        lda CurrentTile
        sta DestinationSquare

        jsr draw_weapon_sprite

        ; Okay, now we just need to preserve the WeaponClass byte as tile flags. for later use
        ; when this thing is collected by the player
        ldx CurrentTile
        lda WeaponClassTemp
        ora #(SHADOW_STATE_ACTIVE)
        sta tile_flags, x
        ; ... and... we're done?


sprite_failed:
        ; this really *shouldn't* happen, but if it does, try again next beat
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors (... kindof)                                     ===
; ============================================================================================================================

.proc spawn_weapon
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
DestinationSquare := R3
WeaponPtr := R11 
        jsr roll_weapon

spawn_weapon:
        ; Spawn a sprite to hold the weapon
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        ; We need to despawn this later, so store the index in the data byte for this tile
        ldy DestinationSquare
        txa
        sta tile_data, y

        jsr draw_weapon_sprite

        ; Okay, now we just need to preserve the WeaponClass byte as tile flags. for later use
        ; when this thing is collected by the player
        ldx DestinationSquare
        lda WeaponClassTemp
        ora #(SHADOW_STATE_ACTIVE)
        sta tile_flags, x
        ; and finally, set this tile to a weapon shadow

        lda DestinationSquare
        sta TargetIndex
        lda #TILE_WEAPON_SHADOW
        sta TileId
        jsr draw_active_tile
        ; ... we're done?
        rts

sprite_failed:
        ; Since we failed to spawn the sprite, we cannot spawn a weapon! Do nothing; we will wait until the next beat and try again
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc collect_weapon
TargetIndex := R0
TileId := R1
OldWeaponTmp := R2
TargetSquare := R13
        ldx TargetSquare
        lda tile_flags, x
        and #SHADOW_STATE_MASK
        cmp #SHADOW_STATE_ACTIVE
        beq proceed_to_collect
        rts

proceed_to_collect:
        ; First, compute the player's old weapon in tmp form, since we're about to overwrite it
        lda PlayerWeapon ; ....wwww
        asl
        asl              ; ..wwww..
        and #%00111100
        sta OldWeaponTmp
        lda PlayerWeaponDmg ; ......dd
        and #%00000011
        ora OldWeaponTmp
        sta OldWeaponTmp

        ; We stuffed the WeaponClassTemp variable in tile_flags, so use that to determine
        ; the weapon properties
        ldx TargetSquare
        lda tile_flags, x
        and #%00000011
        sta PlayerWeaponDmg
        lda tile_flags, x
        and #%00111100
        lsr
        lsr
        tax
        lda cheaty_weapon_lut, x
        sta PlayerWeapon
        ; we also need to update the weapon ptr here
        asl
        tax
        lda weapon_class_table, x
        sta PlayerWeaponPtr
        lda weapon_class_table+1, x
        sta PlayerWeaponPtr+1

        ; TODO: play a weapon gain SFX

        ; Despawn the weapon sprite
        ldx TargetSquare
        lda tile_data, x
        tax
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        ; Switch our own state to "collected", so we can respawn the player's
        ; original weapon when they move off this square
        ldx TargetSquare
        lda OldWeaponTmp
        ora #(SHADOW_STATE_COLLECTED)
        sta tile_flags, x

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        ; Play a joyous SFX
        st16 R0, sfx_equip_ability_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_equip_ability_pulse2
        jsr play_sfx_pulse2

        rts
.endproc
