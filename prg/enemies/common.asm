; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================

.macro bail_if_already_moved
        ; All entities which can move use their high data flag to indicate that they have just done so.
        ; By bailing early, we prevent entities that care about this from accidentally being ticked
        ; twice in the same frame
        ; 76543210
        ; |
        ; +--------- actively moving
        lda tile_flags, x
        bpl continue
        rts
continue:
.endmacro

.macro if_valid_destination success_label,
        ; Screen edges are never okay
        ldx TargetTile
        lda tile_index_to_row_lut, x
        cmp #0
        beq failure
        cmp #(::BATTLEFIELD_HEIGHT-1)
        beq failure
        lda tile_index_to_col_lut, x
        cmp #0
        beq failure
        cmp #(::BATTLEFIELD_WIDTH-1)
        beq failure

        ldx TargetTile
        lda battlefield, x
        ; floors are unconditionally okay
        cmp #TILE_REGULAR_FLOOR
        beq success_label
        cmp #TILE_DISCO_FLOOR
        beq success_label
        ; puffs of smoke are only okay if they moved *last* frame
        ; (this resolves some weirdness with tile update order)
        cmp #TILE_SMOKE_PUFF
        bne failure
        lda tile_flags, x
        bpl success_label
failure:
.endmacro

; input tile in A
.proc draw_tile_here
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        sta battlefield, x
        ldx CurrentRow
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        lda #1
        sta inactive_attribute_queue, x
        rts
.endproc

.proc queue_row_x
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        lda #1
        sta inactive_attribute_queue, x
        rts
.endproc

.proc spawn_death_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
EffectiveAttackSquare := R10
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_RISE | SPRITE_PAL_3)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x

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

        lda #SPRITES_DEATH_SKULL
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        rts
.endproc

.proc spawn_damage_sprite_here
MetaSpriteIndex := R0
PuffSquare := R12
TargetSquare := R13
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        ; Damage is red
        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_RISE | SPRITE_PAL_2)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x

        lda #0
        sta DamageSpriteCoordX
        sta DamageSpriteCoordX+1
        sta DamageSpriteCoordY
        sta DamageSpriteCoordY+1
        ; Damage sprites need to be drawn *between* the player and the enemy that did the damage. We'll do this
        ; by adding both sprite coordinates, then dividing by 2.

        ; First the X coordinate for the player:
        ldy TargetSquare
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta DamageSpriteCoordX
        ; Now the Y coordinate for the player:
        ldy TargetSquare
        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta DamageSpriteCoordY

        ; Now the X coordinate for the enemy's *puff* location, which we've just returned them to:
        ldy PuffSquare
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        clc
        adc DamageSpriteCoordX
        sta DamageSpriteCoordX
        lda #0
        adc DamageSpriteCoordX+1
        sta DamageSpriteCoordX+1
        ; And again, the Y coordinate of the puff square
        ldy PuffSquare
        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        clc
        adc DamageSpriteCoordY
        sta DamageSpriteCoordY
        lda #0
        adc DamageSpriteCoordY+1
        sta DamageSpriteCoordY+1

        ; Now shift to divide those by 2
        lsr DamageSpriteCoordX+1
        ror DamageSpriteCoordX
        lsr DamageSpriteCoordY+1
        ror DamageSpriteCoordY

        ; And now we can apply the sprite position and properties
        lda DamageSpriteCoordX
        sta sprite_table + MetaSpriteState::PositionX, x
        lda DamageSpriteCoordY
        sta sprite_table + MetaSpriteState::PositionY, x

        lda #SPRITES_DAMAGE_PLAYER
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        rts
.endproc

.proc find_puff_tile
PuffSquare := R12
TargetSquare := R13
        lda #$FF        ; A value of $FF indicates search failure
        sta PuffSquare
        ldx #0
loop:
        ; is this a poof?
        lda battlefield, x
        and #%11111100
        cmp #TILE_SMOKE_PUFF
        bne not_our_puff
        ; is this OUR poof?
        lda tile_data, x
        cmp TargetSquare
        bne not_our_puff
        ; we did it!
        stx PuffSquare
        rts
not_our_puff:
        inx
        cpx #::BATTLEFIELD_SIZE
        bne loop
done:
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc no_behavior
        ; does what it says on the tin
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc direct_attack_with_hp
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; If we have *just moved*, then ignore this attack
        ; (A valid attack can only land at our previous destination)
        ldx AttackSquare
        lda tile_flags, x
        bmi ignore_attack
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        jsr attack_with_hp_common
ignore_attack:
        rts
.endproc

.proc indirect_attack_with_hp
        jsr attack_with_hp_common
        rts
.endproc

.proc attack_with_hp_common
; For drawing tiles
TargetIndex := R0
TileId := R1

AttackLanded := R7
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; Add the player's currently equipped damage to our flags byte
        ldx EffectiveAttackSquare
        lda PlayerWeaponDmg
        clc
        adc tile_flags, x
        sta tile_flags, x
        ; Now check: if the damage, NOT including the movement bit, is greater than our health...
        and #%01111111
        cmp EnemyHealth
        bcs die
        ; TODO: if we implement health bars, we should draw one right now
        ; TODO: should we have a "weapon hit something" SFX?
        ; otherwise we're done
        rts

die:
        ; Replace ourselves with a regular floor, and spawn the usual death juice
        lda EffectiveAttackSquare
        sta TargetIndex

        ; If the player is at less than max health, we can try to spawn a small heart
        lda PlayerMaxHealth
        cmp PlayerHealth
        beq drop_nothing
        ; Common enemies have a 1/32 chance to spawn a health tile when defeated
        jsr next_rand
        and #%00011111
        beq drop_health
drop_nothing:
        lda #TILE_REGULAR_FLOOR
        sta TileId
        inc HealthDroughtCounter
        jmp done_with_drops
drop_health:
        lda #TILE_SMALL_HEART
        sta TileId
        lda #0
        sta HealthDroughtCounter
done_with_drops:

        jsr draw_active_tile
        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        jsr spawn_death_sprite_here

        ; Play an appropriately crunchy death sound
        st16 R0, sfx_defeat_enemy_pulse
        jsr play_sfx_pulse1
        st16 R0, sfx_defeat_enemy_noise
        jsr play_sfx_noise

        lda #1
        sta EnemyDiedThisFrame

        ; Reward the player with the amount of gold this enemy is worth
        add16b PlayerGold, GoldToAward

        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc basic_enemy_attacks_player
TargetIndex := R0
TileId := R1
PuffSquare := R12
TargetSquare := R13
        ; All basic enemies do 1 damage to the player on hit
        jsr damage_player

        ; Now the tricky part: we need to scan the map and find this enemy's poof
        ; (It might not exist if we have a bugged board, so handle that safely)
        jsr find_puff_tile
        lda PuffSquare
        cmp #$FF
        beq no_puff_found
        ; Copy ourselves over the puff tile, to cancel our own movement
        lda PuffSquare
        sta TargetIndex
        ldx TargetSquare
        lda battlefield, x
        sta TileId
        jsr draw_active_tile

        ldx TargetSquare
        ldy PuffSquare
        lda tile_data, x
        sta tile_data, y
        lda tile_flags, x
        sta tile_flags, y

        ; Now, draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; TODO: we just damaged the player. Spawn a hit sprite inbetween the enemy that dealt
        ; the damage and the player's position
        jsr spawn_damage_sprite_here

        rts
no_puff_found:
        ; If we couldn't find a puff, then try to cancel the player's movement instead.
        ; This *shouldn't* happen for basic enemies, but if we can't kick the enemy back,
        ; we should try to at least separate it from the player. (If this also fails the
        ; player will soft lock and die very quickly.)
        jsr forbid_player_movement
        rts
.endproc

.proc solid_tile_forbids_movement
        jsr forbid_player_movement
        rts
.endproc

.proc forbid_player_movement
TargetRow := R14
TargetCol := R15
        ; if our current and target position is already the same, bail; nothing to do
        ; (this prevents getting caught in an infinite loop)
        lda PlayerCol
        cmp TargetCol
        bne proceed_to_forbid
        lda PlayerRow
        cmp TargetRow
        bne proceed_to_forbid
        rts        

proceed_to_forbid:
        ; Make our target position the same as our *old* position
        lda PlayerCol
        sta TargetCol
        lda PlayerRow
        sta TargetRow

        ; Now we need to check for damage again, this time at the square we just left.
        ; If we don't do this, then enemies which moves into that square on this turn can
        ; get stuck underneath us, causing general weirdness
        jsr player_resolve_collision

        ; TODO, BUGFIX: what happens if another enemy is now in our old position?
        ; This seems to get us STUCK! We should definitely fix this at some point.

        rts
.endproc

