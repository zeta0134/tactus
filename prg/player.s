        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.zeropage

PlayerWeapon: .res 2
PlayerWeaponPtr: .res 2

FxTileId: .res 1

.segment "RAM"

PlayerSpriteIndex: .res 1
PlayerRow: .res 1
PlayerCol: .res 1

PlayerNextDirection: .res 1

; full words, to do a smooth little lerp thing
PlayerCurrentX: .res 2
PlayerCurrentY: .res 2
PlayerTargetX: .res 2
PlayerTargetY: .res 2

PlayerJumpHeightPos: .res 2

PlayerWeaponDmg: .res 1
PlayerMovementBlocked: .res 1

PlayerMaxHealth: .res 1
PlayerHealth: .res 1
PlayerKeys: .res 1
PlayerGold: .res 2

PlayerZone: .res 1
PlayerFloor: .res 1
PlayerRoomIndex: .res 1

DIRECTION_NORTH = 1
DIRECTION_EAST  = 2
DIRECTION_SOUTH = 3
DIRECTION_WEST  = 4

.segment "PRGFIXED_C000"

JUMP_HEIGHT_END = 5
jump_height_table:
        .byte 6, 8, 7, 4, 1, 0

.proc init_player
MetaSpriteIndex := R0
        ; spawn in the player sprite
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        stx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #0 ; irrelevant
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #$FF ; intentionally offscreen
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #SPRITES_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x

        ; For now, init the player to position 6, 6 (for no particular reason)
        lda #6
        sta PlayerRow
        sta PlayerCol
        jsr set_player_target_coordinates
        jsr apply_target_coordinates_immediately

        ; Initialize us to the *end* of the jump height table; this is its resting state
        lda #JUMP_HEIGHT_END
        sta PlayerJumpHeightPos

        ; The player should start with a standard L1-DAGGER
        lda #WEAPON_DAGGER
        sta PlayerWeapon
        asl
        tax
        lda weapon_class_table, x
        sta PlayerWeaponPtr
        lda weapon_class_table+1, x
        sta PlayerWeaponPtr+1
        lda #1
        sta PlayerWeaponDmg

        lda #1
        sta PlayerHealth
        lda #4
        sta PlayerMaxHealth
        lda #0
        sta PlayerKeys
        sta PlayerRoomIndex
        st16 PlayerGold, 0

        lda #1
        sta PlayerZone
        lda #1
        sta PlayerFloor

        rts

sprite_failed:
        ; what? this should never happen...
        rts
.endproc

; Called once every frame
.proc draw_player
        ; For now, always lerp the player's current position to their target position
        jsr lerp_player_to_target_coordinates

        ; FOR NOW, just immediately draw the player based on their current position.
        ldx PlayerSpriteIndex
        lda PlayerCurrentX+1
        sta sprite_table + MetaSpriteState::PositionX, x
        lda PlayerCurrentY+1
        ; subtract the jump height (if there is one)
        ldy PlayerJumpHeightPos
        sec
        sbc jump_height_table, y
        sta sprite_table + MetaSpriteState::PositionY, x
        ; Update the jump height position every frame
        lda PlayerJumpHeightPos
        cmp #JUMP_HEIGHT_END
        beq done
        inc PlayerJumpHeightPos
done:
        rts
.endproc

; Called once every frame, after input has been processed.
; Updates variables related to the desired direction and 
; whether a down press has occurred at all this frame
.proc determine_player_intent
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT)
        bit ButtonsDown
        bne handle_button_press
        rts ; all done
handle_button_press:
        ; For now, the last button press we receive in a given beat
        ; will be the one that counts once we begin processing.
        ; TODO: detect if we receive an extra button press? we'd need 
        ; to detect the "all buttons released" state, cache that, and then
        ; check it when a new button down arrives. Ignoring this for now.
check_north:
        lda #KEY_UP
        bit ButtonsDown
        beq check_east
        lda #DIRECTION_NORTH
        sta PlayerNextDirection
        rts
check_east:
        lda #KEY_RIGHT
        bit ButtonsDown
        beq check_south        
        lda #DIRECTION_EAST
        sta PlayerNextDirection
        rts
check_south:
        lda #KEY_DOWN
        bit ButtonsDown
        beq check_west
        lda #DIRECTION_SOUTH
        sta PlayerNextDirection
        rts
check_west:
        lda #KEY_LEFT
        bit ButtonsDown
        beq no_valid_press ; this shouldn't be reachable
        lda #DIRECTION_WEST
        sta PlayerNextDirection        
no_valid_press:
        rts
.endproc

.proc set_player_target_coordinates
        lda PlayerCol
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta PlayerTargetX + 1
        lda #0
        sta PlayerTargetX

        lda PlayerRow
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta PlayerTargetY + 1
        lda #0
        sta PlayerTargetY

        rts
.endproc

; Useful during init, or to prevent a large travel lerp during teleports
.proc apply_target_coordinates_immediately
        ; Do not lerp. Do not collect 200 zorkmids
        lda PlayerTargetX
        sta PlayerCurrentX
        lda PlayerTargetX+1
        sta PlayerCurrentX+1
        lda PlayerTargetY
        sta PlayerCurrentY
        lda PlayerTargetY+1
        sta PlayerCurrentY+1
        rts
.endproc

; Standard, useful for moving between nearby tiles
.proc lerp_player_to_target_coordinates
CurrentPos := R0
TargetPos := R2
        lda PlayerCurrentX
        sta CurrentPos
        lda PlayerCurrentX+1
        sta CurrentPos+1
        lda PlayerTargetX
        sta TargetPos
        lda PlayerTargetX+1
        sta TargetPos+1
        jsr lerp_coordinate
        lda CurrentPos
        sta PlayerCurrentX
        lda CurrentPos+1
        sta PlayerCurrentX+1

        lda PlayerCurrentY
        sta CurrentPos
        lda PlayerCurrentY+1
        sta CurrentPos+1
        lda PlayerTargetY
        sta TargetPos
        lda PlayerTargetY+1
        sta TargetPos+1
        jsr lerp_coordinate        
        lda CurrentPos
        sta PlayerCurrentY
        lda CurrentPos+1
        sta PlayerCurrentY+1

        rts
.endproc

; lifted straight from dungeon game, with little to no modification
.proc lerp_coordinate
CurrentPos := R0
TargetPos := R2
Distance := R4
        sec
        lda TargetPos
        sbc CurrentPos
        sta Distance
        lda TargetPos+1
        sbc CurrentPos+1
        sta Distance+1
        ; for sign checks, we need a third distance byte; we'll use
        ; #0 for both incoming values
        lda #0
        sbc #0
        sta Distance+2

        ; sanity check: are we already very close to the target?
        ; If our distance byte is either $00 or $FF, then there is
        ; less than 1px remaining
        lda Distance+1
        cmp #$00
        beq arrived_at_target
        cmp #$FF
        beq arrived_at_target

        ; this is a signed comparison, and it's much easier to simply split the code here
        lda Distance+2
        bmi negative_distance

positive_distance:
        ; divide the distance by 2
.repeat 1
        lsr Distance+1
        ror Distance
.endrepeat
        jmp store_result

negative_distance:
        ; divide the distance by 2
.repeat 1
        sec
        ror Distance+1
        ror Distance
.endrepeat

store_result:
        ; apply the computed distance/4 to the current position
        clc
        lda CurrentPos
        adc Distance
        sta CurrentPos
        lda CurrentPos+1
        adc Distance+1
        sta CurrentPos+1
        ; and we're done!
        rts

arrived_at_target:
        ; go ahead and apply the target position completely, to skip the tail end of the lerp
        lda TargetPos + 1
        sta CurrentPos + 1
        lda #0
        sta CurrentPos
        rts
.endproc

.proc player_face_right
        ldx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        rts
.endproc

.proc player_face_left
        ldx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE | SPRITE_HORIZ_FLIP)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        rts
.endproc

; Called once at the beginning of every beat
.proc update_player
TargetRow := R14
TargetCol := R15
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol

; TODO: If no move or attack was attempted, reset the combo counter (assuming we implement one)
        lda PlayerNextDirection
        beq resolve_enemy_collision

        lda #0
        sta PlayerMovementBlocked

; TODO: Attempt an attack. If we hit something, most weapon types will skip movement
swing_weapon:
        jsr player_swing_weapon

        ; If the player's movement is still allowed, then attempt a move
        lda PlayerMovementBlocked
        bne resolve_enemy_collision

move_player:
        jsr player_move

resolve_enemy_collision:
        jsr player_resolve_collision

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        jsr set_player_target_coordinates

        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        rts
.endproc

.proc player_move
TargetRow := R14
TargetCol := R15
; If we get here, we are attempting a movement. Whether it succeeds or not, animate the
; player jumping (possibly in place)
        lda #0
        sta PlayerJumpHeightPos

; Movement 
        lda PlayerNextDirection
check_north:
        cmp #DIRECTION_NORTH
        bne check_east
        dec TargetRow
        jmp done_choosing_target
check_east:
        cmp #DIRECTION_EAST
        bne check_south
        inc TargetCol
        jsr player_face_right
        jmp done_choosing_target
check_south:
        cmp #DIRECTION_SOUTH
        bne check_west
        inc TargetRow
        jmp done_choosing_target
check_west:
        cmp #DIRECTION_WEST
        bne done_choosing_target
        dec TargetCol        
        jsr player_face_left
done_choosing_target:
        ; That's it; leave it in Target Col/Row for now, as we need to let
        ; collision have a go at it, and collision needs old/new coords

        rts
.endproc

; For rapidly computing the tile row
row_number_to_tile_index_lut:
player_tile_index_table:
        .repeat ::BATTLEFIELD_HEIGHT, i
        .byte (::BATTLEFIELD_WIDTH * i)
        .endrepeat

.proc player_swing_weapon
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9
; We don't use these, but we should know not to clobber them
EffectiveAttackSquare := R10
TargetRow := R14
TargetCol := R15
        ldx PlayerRow
        lda player_tile_index_table, x ; Row * Width
        clc
        adc PlayerCol                  ; ... + Col
        sta PlayerSquare

        ; depending on the player's directional input, we'll need to load one of
        ; the four directional pointers, so do that:

        lda PlayerNextDirection
check_north:
        cmp #DIRECTION_NORTH
        bne check_east
        ldy #WeaponClass::NorthSquaresPtr
        jmp done_choosing_direction
check_east:
        cmp #DIRECTION_EAST
        bne check_south
        jsr player_face_right
        ldy #WeaponClass::EastSquaresPtr
        jmp done_choosing_direction
check_south:
        cmp #DIRECTION_SOUTH
        bne check_west
        ldy #WeaponClass::SouthSquaresPtr
        jmp done_choosing_direction
check_west:
        cmp #DIRECTION_WEST
        bne done_choosing_direction ; should never be taken
        jsr player_face_left
        ldy #WeaponClass::WestSquaresPtr

done_choosing_direction:
        lda (PlayerWeaponPtr), y
        sta WeaponSquaresPtr
        iny
        lda (PlayerWeaponPtr), y
        sta WeaponSquaresPtr+1
        
        ; Now we iterate through each of these squares, roll an attack against the square
        lda #0
        sta AttackLanded
        sta WeaponSquaresIndex
        ldy #WeaponClass::NumSquares
        lda (PlayerWeaponPtr), y
        sta TilesRemaining
loop:
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare
        iny
        lda (WeaponSquaresPtr), y ; Y offset
        bmi negative_y
positive_y:
        tax        
        lda player_tile_index_table, x
        clc
        adc AttackSquare
        sta AttackSquare
        jmp converge
negative_y:
        eor #$FF
        tax
        inx
        sec
        lda AttackSquare
        sbc player_tile_index_table, x
        sta AttackSquare
converge:
        iny

        lda (WeaponSquaresPtr), y
        sta FxTileId ; stash for if this hits
        iny

        lda (WeaponSquaresPtr), y ; Behavioral Flags for this tile
        sta WeaponProperties      ; Stash these here so the enemies can see them (if applicable)
        iny
        sty WeaponSquaresIndex
        far_call FAR_attack_enemy_tile
check_player_movement:
        ; If this weapon square could cancel movement
        lda #WEAPON_CANCEL_MOVEMENT
        and WeaponProperties
        beq check_early_exit
        ; ... and an attack actually landed
        lda AttackLanded
        beq check_early_exit
        ; ... then block player movement
        lda #1
        sta PlayerMovementBlocked
check_early_exit:
        ; If this weapon square is single target...
        lda #WEAPON_SINGLE_TARGET
        and WeaponProperties
        beq no_early_exit
        ; ... and the attack actually landed
        lda AttackLanded
        beq no_early_exit
        ; Then we are done with the swing, and should clean up
        jsr draw_single_hit_fx
        jmp done_with_swing
no_early_exit:
        ; Otherwise, iterate to the next weapon square and continue
        dec TilesRemaining
        bne loop

        lda AttackLanded
        beq done_with_swing
        jsr draw_multiple_hit_fx

done_with_swing:
        ; If there is any cleanup to do, do that here. Otherwise we're finished I think?

        rts
.endproc

.proc draw_single_hit_fx
AttackSquare := R3
        jsr spawn_fx_sprite_here
        rts
.endproc

.proc draw_multiple_hit_fx
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
TilesRemaining := R9
        ; For this we actually need to loop all the way back over the structure
        ldy #WeaponClass::NumSquares
        lda (PlayerWeaponPtr), y
        sta TilesRemaining

        ; Just like when swinging the weapon, we must compute the position of each square
        lda #0
        sta WeaponSquaresIndex
        ldy #WeaponClass::NumSquares
        lda (PlayerWeaponPtr), y
        sta TilesRemaining
loop:
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare
        iny
        lda (WeaponSquaresPtr), y ; Y offset
        bmi negative_y
positive_y:
        tax        
        lda player_tile_index_table, x
        clc
        adc AttackSquare
        sta AttackSquare
        jmp converge
negative_y:
        eor #$FF
        tax
        inx
        sec
        lda AttackSquare
        sbc player_tile_index_table, x
        sta AttackSquare
converge:
        iny

        ; Read the FX ID, which we are about to draw
        lda (WeaponSquaresPtr), y
        sta FxTileId
        iny

        ; Skip over the behavioral flags
        iny
        sty WeaponSquaresIndex

        ; Now we have the attack square, we can draw the weapon FX 
        jsr spawn_fx_sprite_here
        dec TilesRemaining
        bne loop

        rts
.endproc

.proc spawn_fx_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_PAL_1)
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

        lda FxTileId
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        rts
.endproc

.proc player_resolve_collision
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        ldx TargetRow
        lda player_tile_index_table, x ; Row * Width
        clc
        adc TargetCol                  ; ... + Col
        sta TargetSquare

        far_call FAR_player_collides_with_tile

        rts
.endproc

.proc damage_player
        lda PlayerHealth
        beq already_dead
        dec PlayerHealth
already_dead:
        rts
.endproc

; Note: checks and updates PlayerRow/PlayerCol,
; but does **not** update the target or tween positions.
; This intentionally desynchronizes the on-screen position, which
; allows the player to appear to jump to the exit tile. When the next
; room loads, we'll instantly set their new position and they'll be in
; the right spot based on the way they left the previous field.
.proc detect_exit
        lda PlayerCol
        cmp #0
        beq exit_left
        cmp #(::BATTLEFIELD_WIDTH - 1)
        beq exit_right
        lda PlayerRow
        cmp #0
        beq exit_top
        cmp #(::BATTLEFIELD_HEIGHT - 1)
        beq exit_bottom
no_exit:
        rts
exit_left:
        dec PlayerRoomIndex
        lda #(::BATTLEFIELD_WIDTH - 2)
        sta PlayerCol
        jmp converge
exit_right:
        inc PlayerRoomIndex
        lda #1
        sta PlayerCol
        jmp converge
exit_top:
        lda PlayerRoomIndex
        sec
        sbc #4
        sta PlayerRoomIndex
        lda #(::BATTLEFIELD_HEIGHT - 2)
        sta PlayerRow
        jmp converge
exit_bottom:
        lda PlayerRoomIndex
        clc
        adc #4
        sta PlayerRoomIndex
        lda #1
        sta PlayerRow
        jmp converge
converge:
        ; TODO: this probably needs to be a fade out state, rather than right to room init
        st16 GameMode, room_init
        rts
.endproc

.proc detect_critical_existence_failure
        lda PlayerHealth
        bne existence_proven
        ; Whelp; that's the end of the line
        ; TODO: I dunno, screen shake? palette greyscale? SFX? Juice this up.
        st16 FadeToGameMode, game_end_screen_prep
        st16 GameMode, fade_to_game_mode
existence_proven:
        rts
.endproc