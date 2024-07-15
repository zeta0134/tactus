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
        beq valid_destination_failure
        cmp #(::BATTLEFIELD_HEIGHT-1)
        beq valid_destination_failure
        lda tile_index_to_col_lut, x
        cmp #0
        beq valid_destination_failure
        cmp #(::BATTLEFIELD_WIDTH-1)
        beq valid_destination_failure

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
        bne valid_destination_failure
        lda tile_flags, x
        bpl success_label
valid_destination_failure:
.endmacro

.macro if_semisafe_destination success_label,
        ldx TargetTile
        lda battlefield, x
        ; currently there is only one semisolid tile, since
        ; it never animates. later we might need to expand this list
        cmp #TILE_SEMISAFE_FLOOR
        beq success_label
semisafe_failure:
.endmacro

; Various battlefield drawing macros, mostly to cut down on repetition and copy/pasta errors

; Draw a given entity/tile into the battlefield at position X. Preserves the original
; palette at this location
.macro draw_at_x_keeppal entity_type, tile_id
        lda battlefield, x
        and #%00000011
        ora #entity_type
        sta battlefield, x
        lda #<tile_id
        sta tile_patterns, x
        lda tile_attributes, x
        and #PAL_MASK
        ora #>tile_id
        sta tile_attributes, x
.endmacro

; Note: does not set the palette bits in entity_type, somewhat
; on purpose, as our long term plan is to remove these bits and
; switch to 8bit entity IDs
.macro draw_at_x_withpal entity_type, tile_id, palette_index
        lda #entity_type
        sta battlefield, x
        lda #<tile_id
        sta tile_patterns, x
        lda #(>tile_id | palette_index)
        sta tile_attributes, x
.endmacro

.macro draw_at_y_with_pal_x entity_type, tile_id
        lda battlefield, x
        and #%00000011
        ora #entity_type
        sta battlefield, y
        lda #<tile_id
        sta tile_patterns, y
        lda tile_attributes, x
        and #PAL_MASK
        ora #>tile_id
        sta tile_attributes, y
.endmacro

.proc spawn_death_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
EffectiveAttackSquare := R10
        far_call FAR_find_unused_sprite
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

        lda #<SPRITE_TILE_DEATH_SKULL
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        rts
.endproc

.proc spawn_damage_sprite_here
MetaSpriteIndex := R0
PuffSquare := R12
TargetSquare := R13
        far_call FAR_find_unused_sprite
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

        lda #<SPRITE_TILE_DAMAGE_PLAYER
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
        perform_zpcm_inc
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
        perform_zpcm_inc
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
OriginalAttackSquare := R3

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
        ; TODO: can we build a system that palette cycles enemies once they take damage? just a quick
        ; rotation through the four palettes, at frame speed rather than beat speed

        ; this enemy took a hit and did not die! let's cycle their palette for flashy effect
        lda EffectiveAttackSquare
        jsr queue_palette_cycle

        rts

die:
        ; Replace ourselves with a regular floor, and spawn the usual death juice
        ldx EffectiveAttackSquare
        stx TargetIndex

        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_WORLD)
        sta tile_attributes, x
        jsr draw_active_tile

        ; If the player is at less than max health, we can try to spawn a small heart
        lda PlayerMaxHealth
        cmp PlayerHealth
        beq drop_nothing
        ; Common enemies have a 1/16 chance to spawn a health tile when defeated
        jsr next_rand
        
        and #%00001111

        beq drop_health
drop_nothing:
        
        inc HealthDroughtCounter
        jmp done_with_drops
drop_health:
        ldx OriginalAttackSquare
        stx TargetIndex
        lda #TILE_SMALL_HEART
        sta battlefield, x
        lda #<BG_TILE_SMALL_HEART
        sta tile_patterns, x
        lda #(>BG_TILE_SMALL_HEART | PAL_RED)
        sta tile_attributes, x
        jsr draw_active_tile
        lda #0
        sta HealthDroughtCounter

done_with_drops:
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

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

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
        far_call FAR_damage_player

        ; Now the tricky part: we need to scan the map and find this enemy's poof
        ; (It might not exist if we have a bugged board, so handle that safely)
        jsr find_puff_tile
        lda PuffSquare
        cmp #$FF
        beq no_puff_found
        ; Copy ourselves over the puff tile, to cancel our own movement
        ldx TargetSquare
        ldy PuffSquare
        lda battlefield, x
        sta battlefield, y
        lda tile_data, x
        sta tile_data, y
        lda tile_flags, x
        sta tile_flags, y
        lda tile_patterns, x
        sta tile_patterns, y
        lda tile_attributes, x
        sta tile_attributes, y

        ; if our old square was flashing, move the flashing effect to our new location
        lda TargetSquare
        ldy PuffSquare
        jsr move_palette_cycle

        lda PuffSquare
        sta TargetIndex
        jsr draw_active_tile

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
        
        ; Since we just damaged the player, spawn a hit sprite
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
        far_call FAR_player_resolve_collision

        ; TODO, BUGFIX: what happens if another enemy is now in our old position?
        ; This seems to get us STUCK! We should definitely fix this at some point.

        rts
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================

; These are used to take a 5bit random number and pick something "in bounds" coordinate wise,
; with reasonable speed and fairness
random_row_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_HEIGHT - 6)))
        .endrepeat

random_col_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_WIDTH - 6)))
        .endrepeat

; result in R0
.proc find_safe_coordinate
TempCol := R0
TempRow := R1
; TODO: track attempts, to guard against failure?
TempIndex := R3

FinalIndex := R0
        jsr next_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta TempRow
        jsr next_rand
        and #%00011111
        tax
        lda random_col_table, x
        sta TempCol
check_floor:
        ldx TempRow
        lda row_number_to_tile_index_lut, x
        clc
        adc TempCol
        sta TempIndex
        ldx TempIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_REGULAR_FLOOR
        beq is_valid_space
        cmp #TILE_DISCO_FLOOR
        beq is_valid_space
        ; no good; this is not a floor tile. We cannot spawn anything here,
        ; try again
        jmp find_safe_coordinate
is_valid_space:
        lda TempIndex
        sta FinalIndex
        rts
.endproc

.proc move_away_from_map_edge
NewSquare := R0
CurrentSquare := R15
        ; This is a generic implementation that simply teleports the enemy to a valid tile somewhere
        ; near the center of the room, just like when they were initially spawned. For many enemies,
        ; we can write a custom fix that is less arbitrary, but this works as a default

        ; Firstly, does this enemy need treatment? If they aren't on an extreme map edge then they do not:
        ldx CurrentSquare
        lda tile_index_to_row_lut, x
        ; (enemies can't move onto the extreme map edges at all, so we're just checking
        ; the spots where the player can spawn in)
        cmp #1
        beq adjustment_needed
        cmp #(BATTLEFIELD_HEIGHT-2)
        beq adjustment_needed
        lda tile_index_to_col_lut, x
        cmp #1
        beq adjustment_needed
        cmp #(BATTLEFIELD_WIDTH-2)
        beq adjustment_needed
        ; This enemy is in a safe spot; we're done
        rts
adjustment_needed:
        jsr find_safe_coordinate
        ; move ourselves to the new coordinate
        ldx CurrentSquare
        ldy NewSquare

        lda battlefield, x
        sta battlefield, y
        lda tile_data, x
        sta tile_data, y
        lda tile_flags, x
        sta tile_flags, y
        lda tile_patterns, x
        sta tile_patterns, y
        lda tile_attributes, x
        sta tile_attributes, y
        ; do not move detail. detail always stays behind

        ; okay, now draw a cleared disco tile at our current location
        jsr draw_cleared_disco_tile

        rts
.endproc


