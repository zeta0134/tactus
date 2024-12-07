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

; clobbers a, x
; put TargetTile wherever you want
; TODO: does this really need to be a macro?
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
        cmp #TILE_DISCO_FLOOR
        beq success_label
        ; Right now, one-beat hazards are also okay (they're mushroom spores)
        cmp #TILE_ONE_BEAT_HAZARD
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
        lda #entity_type
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
        lda #entity_type
        sta battlefield, y
        lda #<tile_id
        sta tile_patterns, y
        lda tile_attributes, x
        and #PAL_MASK
        ora #>tile_id
        sta tile_attributes, y
.endmacro

        .segment "ENEMY_UPDATE"
; Result in A, clobbers R0
; This variant always uses the player's current position
; against the active tile's current position
.proc ENEMY_UPDATE_player_manhattan_distance
PlayerDistance := R2
CurrentRow := R14
CurrentTile := R15
        ; First the row
        lda PlayerRow
        sec
        sbc CurrentRow
        bpl add_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
add_row_distance:
        sta PlayerDistance
        ; Now the column
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bpl add_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
add_col_distance:
        clc
        adc PlayerDistance
        sta PlayerDistance
        perform_zpcm_inc
        rts
.endproc

; Result in A, clobbers R2
; TargetTile in R0
; TargetRow in R1
.proc ENEMY_UPDATE_target_manhattan_distance_to_player
TargetTile := R0
TargetRow := R1
PlayerDistance := R2
        ; First the row
        lda PlayerRow
        sec
        sbc TargetRow
        bpl add_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
add_row_distance:
        sta PlayerDistance
        ; Now the column
        lda PlayerCol
        ldx TargetTile
        sec
        sbc tile_index_to_col_lut, x
        bpl add_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
add_col_distance:
        clc
        adc PlayerDistance
        sta PlayerDistance
        perform_zpcm_inc
        rts
.endproc

        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_spawn_death_sprite_here
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

        .segment "ENEMY_COLLIDE"

; TODO: the underneath-the-enemy thing should really have lower priority
damage_properties_by_direction:
        .byte 0 ; default, unused
        .byte SPRITE_HORIZ_FLIP ; north
        .byte 0 ; east
        .byte 0 ; south
        .byte SPRITE_HORIZ_FLIP ; west
        .byte 0 ; northeast
        .byte 0 ; southeast
        .byte SPRITE_HORIZ_FLIP ; northwest
        .byte SPRITE_HORIZ_FLIP ; southwest


.proc ENEMY_COLLIDE_spawn_damage_sprite_here
MetaSpriteIndex := R0

PuffPosX := R1
PuffPosY := R2

PuffSquare := R12
TargetSquare := R13

        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        jeq sprite_failed

        ; Slashes are yellowish
        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_PAL_1)
        ; Choose direction and other properties based on the puff direction
        ; we may have computed earlier
        ldy PlayerIncomingDamageDirection
        ora damage_properties_by_direction, y
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
        ; store this off for use later
        sta PuffPosX
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
        ; store this off for use later
        sta PuffPosY
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

        ; Now spawn a second sprite, directly under the puff spot, to
        ; indicate that this particular spot is where the damage came
        ; from. This will be a flashing indicator, so it should be
        ; perfectly aligned with the background square. It also should
        ; appear "underneath" this enemy, so it will use bgPriority, etc.
        
        ; (we may want separate versions for some enemies if this conflicts
        ; with their artistic use of BG0.0? and I'm not sure what to do about
        ; water enemies, which might need a totally separate concept here)

        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        ; The position is our puff coordinates that we computed earlier
        lda PuffPosX
        sta sprite_table + MetaSpriteState::PositionX, x
        lda PuffPosY
        ; aaaand random offset to counter "sprites are offset from the battlefield for depth"
        ; since this is ON the battlefield
        clc
        adc #1
        sta sprite_table + MetaSpriteState::PositionY, x
        ; The attributes are static: the flashing tile ID, in bright pink,
        ; with bgPriority and one-beat flags
        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_PAL_2 | SPRITE_BG_PRIORITY)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #<SPRITE_TILE_DAMAGE_FLASHING_SQUARE
        sta sprite_table + MetaSpriteState::TileIndex, x
        ; and... that's it?

sprite_failed:
        rts
.endproc

.proc ENEMY_COLLIDE_set_damage_direction_from_puff_tile
PuffSquare := R12
TargetSquare := R13

DIRECTION_NORTH = 1
DIRECTION_EAST  = 2
DIRECTION_SOUTH = 3
DIRECTION_WEST  = 4
DIRECTION_NORTHEAST = 5
DIRECTION_SOUTHEAST = 6
DIRECTION_NORTHWEST = 7
DIRECTION_SOUTHWEST = 8

check_ns:
        lda PlayerRow
        ldx PuffSquare
        sec
        sbc tile_index_to_row_lut, x
        beq check_ew
        bcs handle_north
        bcc handle_south

check_ew:
        lda PlayerCol
        ldx PuffSquare
        sec
        sbc tile_index_to_col_lut, x
        beq handle_default
        bcs handle_west
        bcc handle_east

handle_default:
        ; somehow we are on top of the player's position. maybe we are
        ; a hazard? use "south" as a reasonable default here, it'll bounce
        ; kinda "up" suggesting a floor hit.
        lda #DIRECTION_SOUTH
        sta PlayerIncomingDamageDirection
        rts

handle_north:
        ; check for diagonals here
        lda PlayerCol
        ldx PuffSquare
        sec
        sbc tile_index_to_col_lut, x
        beq plain_north
        bcs handle_northwest
        bcc handle_northeast

handle_south:
        ; check for diagonals here
        lda PlayerCol
        ldx PuffSquare
        sec
        sbc tile_index_to_col_lut, x
        beq plain_south
        bcs handle_southwest
        bcc handle_southeast

handle_east:
        lda PlayerRow
        ldx PuffSquare
        sec
        sbc tile_index_to_row_lut, x
        beq plain_east
        bcs handle_northeast
        bcc handle_southeast

handle_west:
        lda PlayerRow
        ldx PuffSquare
        sec
        sbc tile_index_to_row_lut, x
        beq plain_west
        bcs handle_northwest
        bcc handle_southwest

plain_north:
        lda #DIRECTION_NORTH
        sta PlayerIncomingDamageDirection
        rts
plain_south:
        lda #DIRECTION_SOUTH
        sta PlayerIncomingDamageDirection
        rts
plain_east:
        lda #DIRECTION_EAST
        sta PlayerIncomingDamageDirection
        rts
plain_west:
        lda #DIRECTION_WEST
        sta PlayerIncomingDamageDirection
        rts
handle_northeast:
        lda #DIRECTION_NORTHEAST
        sta PlayerIncomingDamageDirection
        rts
handle_northwest:
        lda #DIRECTION_NORTHWEST
        sta PlayerIncomingDamageDirection
        rts
handle_southeast:
        lda #DIRECTION_SOUTHEAST
        sta PlayerIncomingDamageDirection
        rts
handle_southwest:
        lda #DIRECTION_SOUTHWEST
        sta PlayerIncomingDamageDirection
        rts
.endproc

.proc ENEMY_COLLIDE_find_puff_tile
PuffSquare := R12
TargetSquare := R13
        lda #$FF        ; A value of $FF indicates search failure
        sta PuffSquare
        ldx #0
loop:
        perform_zpcm_inc
        ; is this a poof?
        lda battlefield, x
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
        .segment "RAM"
candidate_tiles:      .res 8
candidate_weights:    .res 8
candidate_rows:       .res 8 ; for smoke puffs
candidate_directions: .res 8 ; also for smoke puffs

ValidDestination: .res 1
SemisafeDestination: .res 1
NumCandidates: .res 1
ScratchChosenWeight: .res 1
TargetTile: .res 1

; Given up to 8 candidate directions, chooses the "best" one with caller-provided
; rates that is actually a valid destination tile. Tries to be reasonably efficient
; under these constraints. Most enemies use this in some form or fashion.
        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_choose_destination
        lda #$FF
        sta ValidDestination
        sta SemisafeDestination
        sta ScratchChosenWeight
        ldy #0
loop:
        perform_zpcm_inc
        lda candidate_weights, y  ; if we've already selected a better, valid candidate tile
        cmp ScratchChosenWeight ; then skip over the expensive "is valid" check entirely
        bcs destination_failure
        lda candidate_tiles, y
        sta TargetTile
        if_valid_destination destination_success
        if_semisafe_destination semisafe_destination_success
destination_failure:
        ; TODO: handle semisafe detection too!
        iny
        cpy NumCandidates
        bne loop
        rts
destination_success:
        lda candidate_tiles, y
        sta ValidDestination
        lda #$FF
        sta SemisafeDestination
        lda candidate_weights, y
        sta ScratchChosenWeight
        lda candidate_directions, y
        sta SmokePuffDirection
        iny 
        cpy NumCandidates
        bne loop
        rts
semisafe_destination_success:
        lda candidate_tiles, y
        sta SemisafeDestination
        lda #$FF
        sta ValidDestination
        lda candidate_weights, y
        sta ScratchChosenWeight
        lda candidate_directions, y
        sta SmokePuffDirection
        iny 
        cpy NumCandidates
        jne loop
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_with_hp
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
        near_call ENEMY_ATTACK_attack_with_hp_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_with_hp
        near_call ENEMY_ATTACK_attack_with_hp_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_with_hp_common
OriginalAttackSquare := R3

; For drawing tiles
TargetIndex := R0
TileId := R1

; Damage done by the weapon swing
WeaponDmg := R0

AttackLanded := R7
EffectiveAttackSquare := R10
EnemyHealth := R11
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; Add the player's currently equipped damage to our flags byte
        far_call FAR_weapon_dmg ; clobbers X,Y, result in R0
        lda WeaponDmg
        ldx EffectiveAttackSquare
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
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile

        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        near_call ENEMY_ATTACK_spawn_death_sprite_here

        ; A standard enemy died! Increment the player's ongoing combo
        inc PlayerCombo

        ; Roll for loot here!
        roll_loot_at OriginalAttackSquare

        ; Play an appropriately crunchy death sound
        queue_sfx_pulse1 sfx_defeat_enemy_pulse
        queue_sfx_noise sfx_defeat_enemy_noise

        lda #1
        sta EnemyDiedThisFrame

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        rts
.endproc

; ============================================================================================================================
; ===                                    Explosion Attacks Enemy Behaviors                                                 ===
; ============================================================================================================================
        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_direct_explode
AttackSquare := R3
EffectiveAttackSquare := R10
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_indirect_explode
        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_explode_common
; For drawing tiles
TargetIndex := R0
OriginalAttackSquare := R3
EffectiveAttackSquare := R10

        ; No funny business. Explosions kill common enemies in one hit!

die:
        ; Replace the struck enemy with a regular floor, and spawn the usual death juice
        ldx EffectiveAttackSquare
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        ; Yes, do draw the active tile, in case this enemy tried to leave
        ; the explosion radius. This may result in some overdraw; it's fine.
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile

        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        far_call ENEMY_ATTACK_spawn_death_sprite_here

        ; Make this square a one beat hazard
        ldx OriginalAttackSquare
        lda #TILE_ONE_BEAT_HAZARD
        sta battlefield, x

        ; Do NOT update the player's combo!
        ; Do NOT roll for loot (TODO: if we want loot, wee if we can roll without considering chain/combo)
        ; Do NOT play a SFX, the explosion SFX is already queued up

        ; DO decrement the active counter, as we have just properly died
        ; and such. (TODO: investigate if a moving enemy can double-decrement,
        ; and whether we consider this to be a game-breaking flaw if it would
        ; occur near the clearing of the room?)
        dec enemies_active

        rts
.endproc

; Mostly used by disco floors and objects that we want to "destroy" without
; making the resulting square safe to step on. One beat hazards revert themselves
; to standard disco tiles on the next beat, and the visual jank here will be
; hidden by explosion tiles, drawn separately.
.proc ENEMY_BOMB_SPELL_become_one_beat_hazard
OriginalAttackSquare := R3
EffectiveAttackSquare := R10 ; Unused (call this directly)
        ldx OriginalAttackSquare
        lda #TILE_ONE_BEAT_HAZARD
        sta battlefield, x
        rts
.endproc

; ============================================================================================================================
; ===                                      Spell Tickles Enemy Behaviors                                                   ===
; ============================================================================================================================

; All of these are called when a particular spell needs to affect the *entire* battlefield. Note the player will still have
; the spell equipped to A at this point, so we can just read the spell ID from there. The outer dispatch doesn't care what
; spell was called, so each dispatch function here will need to check the spell ID and deliniate accordingly.
; Otherwise the arguments are the same as enemy update, etc.

        .segment "ENEMY_BOMB_SPELL"

; Shared by the four "apply element to room" spells. This simply changes
; the color of the enemy tile to match the spell that was cast. Generally
; call this after processing other enemy logic, especially if the enemy
; can potentially be defeated by the unique effects before we get here.
.proc ENEMY_BOMB_SPELL_change_my_color
TargetColor := R0
CurrentRow := R14
CurrentTile := R15
        lda PlayerEquipmentSpell
        cmp #ITEM_SPELL_FIRE
        beq choose_fire
        cmp #ITEM_SPELL_AIR
        beq choose_air
        cmp #ITEM_SPELL_ICE
        beq choose_ice
choose_earth:
        lda #PAL_EARTH
        jmp done_choosing_color
choose_fire:
        lda #PAL_FIRE
        jmp done_choosing_color
choose_air:
        lda #PAL_AIR
        jmp done_choosing_color
choose_ice:
        lda #PAL_WATER
done_choosing_color:
        sta TargetColor

        ldx CurrentTile
        lda tile_attributes, x
        and #($FF-PAL_MASK)
        ora TargetColor
        sta tile_attributes, x
        rts
.endproc

slime_spell_lut:
        ; Slimes have the most basic response to elemental spells:
        ; they simply change color on the spot.
        ; TODO: should we reset their movement pattern data?
        .word ENEMY_BOMB_SPELL_change_my_color ; SPELL_FIRE
        .word ENEMY_BOMB_SPELL_change_my_color ; SPELL_AIR
        .word ENEMY_BOMB_SPELL_change_my_color ; SPELL_ICE
        .word ENEMY_BOMB_SPELL_change_my_color ; SPELL_EARTH
        .word FIXED_no_behavior                ; SPELL_BOMB
        .word FIXED_no_behavior                ; SPELL_LIFE

.proc ENEMY_BOMB_SPELL_slime_spell_dispatch
DispatchPtr := R0
;Length := R13
CurrentRow := R14
CurrentTile := R15
        lda PlayerEquipmentSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        ; Safety: don't call a spell effect that doesn't exist
        ; (This shouldn't happen, but crashing is no fun)
        cmp #LAST_SPELL_IN_ITEM_LIST
        bcc safe_to_dispatch
        rts
safe_to_dispatch:
        asl
        tax
        lda slime_spell_lut+0, x
        sta DispatchPtr+0
        lda slime_spell_lut+1, x
        sta DispatchPtr+1
        jmp (DispatchPtr)
        ; does not return
.endproc

; For any standard enemy that, specifically:
;  - Takes player damage using the common routine, after which this behavior is modeled
;  - Should change to the spell color for the four elemental spells
;  - Requires NO special behavior for any other spell (ie, the common behavior is fine)
.proc ENEMY_BOMB_SPELL_regular_enemy_spell_dispatch
        ; TODO: really not this. For now, all enemies just do the color change thing.
        jsr ENEMY_BOMB_SPELL_slime_spell_dispatch
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_basic_enemy_attacks_player
DamageAmount := R0

TargetIndex := R0
TileId := R1
PuffSquare := R12
TargetSquare := R13
        ; basic attacks do 4 damage (1 full heart)
        lda #4
        sta DamageAmount
        far_call FAR_damage_player

        ; Now the tricky part: we need to scan the map and find this enemy's poof
        ; (It might not exist if we have a bugged board, so handle that safely)
        near_call ENEMY_COLLIDE_find_puff_tile
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
        lda #TILE_DISCO_FLOOR
        sta battlefield, x
        lda #<BG_TILE_FLOOR
        sta tile_patterns, x
        lda #(>BG_TILE_FLOOR | PAL_EARTH)
        sta tile_attributes, x
        lda #0
        sta tile_data, x
        sta tile_flags, x
        jsr draw_active_tile
        
        ; Set the player's incoming damage direction, which is based
        ; on the puff tile we just returned to
        near_call ENEMY_COLLIDE_set_damage_direction_from_puff_tile
        ; Since we just damaged the player, spawn a hit sprite
        near_call ENEMY_COLLIDE_spawn_damage_sprite_here

        rts
no_puff_found:
        ; If we couldn't find a puff, then try to cancel the player's movement instead.
        ; This *shouldn't* happen for basic enemies, but if we can't kick the enemy back,
        ; we should try to at least separate it from the player. (If this also fails the
        ; player will soft lock and die very quickly.)
        near_call ENEMY_COLLIDE_forbid_player_movement

        rts
.endproc

.proc ENEMY_COLLIDE_solid_tile_forbids_movement
        near_call ENEMY_COLLIDE_forbid_player_movement
        rts
.endproc

.proc ENEMY_COLLIDE_forbid_player_movement
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
        .segment "ENEMY_UTIL"
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
.proc ENEMY_UTIL_find_safe_coordinate
TempCol := R0
TempRow := R1
; TODO: track attempts, to guard against failure?
TempIndex := R3

FinalIndex := R0
        jsr next_gameplay_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta TempRow
        jsr next_gameplay_rand
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
        cmp #TILE_DISCO_FLOOR
        beq is_valid_space
        ; no good; this is not a floor tile. We cannot spawn anything here,
        ; try again
        jmp ENEMY_UTIL_find_safe_coordinate
is_valid_space:
        lda TempIndex
        sta FinalIndex
        rts
.endproc

.proc ENEMY_UTIL_move_away_from_map_edge
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
        near_call ENEMY_UTIL_find_safe_coordinate
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
        near_call ENEMY_UTIL_draw_cleared_disco_tile

        rts
.endproc
