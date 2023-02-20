; map all 5 weapons to 16 entries, for a mostly fair random type
; we'll give longswords one extra slot, as they're a fairly decent
; weapon type that many players will find success with
cheaty_weapon_lut:
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        ; bonus percent
        .byte WEAPON_LONGSWORD

weapon_damage_lut:
        .byte 1, 2, 3, 3

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

; ... crickets ...

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors (... kindof)                                     ===
; ============================================================================================================================

.proc spawn_weapon
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
WeaponPtr := R12 
        ; First we need to roll a weapon class
        ; TODO: this should almost certainly use a FIXED seed. Without this, the player
        ; can leave and re-enter the room to try the roll again, which is scummy
        jsr next_fixed_rand
        and #%00111111 ; low 2 bits = weapon strength, middle 4 bits = weapon type from table
        sta WeaponClassTemp
        ; TODO: chests should spawn any treasure, not just a weapon. But as weapons are complicated...
        ; let's do those first.
        ; weapon strength should be clamped based on the current floor (and later, zone?)
        and #%00000011 ; isolate the damage index
        cmp PlayerFloor
        bcc zone_index_valid
        lda #0 ; force a lvl 1 weapon; this affects spawn rate of higher tier weapons on each floor
zone_index_valid:
        tax
        lda WeaponClassTemp
        and #%00111100 ; isolate weapon type
        ora weapon_damage_lut, x  ;  apply the damage bits here
        sta WeaponClassTemp

spawn_weapon:
        ; Spawn a sprite to hold the weapon
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        ; We need to despawn this later, so store the index in the data byte for this tile
        ldy AttackSquare
        txa
        sta tile_data, y
        ; This is an active sprite, it does not move
        ; and the palette we choose here will be the same as the weapon class low 2 bits
        lda WeaponClassTemp
        and #%00000011
        ora #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF ; irrelevant
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        ; the X and Y position will be based on our current location, very similar to
        ; how we spawn death sprites
        ldy AttackSquare
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
        ; *whew.* Okay, now we just need to preserve the WeaponClass byte as tile flags. for later use
        ; when this thing is collected by the player
        lda WeaponClassTemp
        ldx AttackSquare
        sta tile_flags, x
        ; and finally, set this tile to a weapon shadow

        lda AttackSquare
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
TargetSquare := R13
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

        ; Finally, draw a basic floor tile here
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
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