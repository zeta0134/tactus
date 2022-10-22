        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "zeropage.inc"

.zeropage

PlayerWeaponPtr: .res 2

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

BATTLEFIELD_OFFSET_X = 16
BATTLEFIELD_OFFSET_Y = 32

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

        ; The player should start with a standard dagger
        lda #WEAPON_DAGGER
        asl
        tax
        lda weapon_class_table, x
        sta PlayerWeaponPtr
        lda weapon_class_table+1, x
        sta PlayerWeaponPtr+1
        lda #1
        sta PlayerWeaponDmg

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
TargetRow := R0
TargetCol := R1
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



do_nothing:
        jsr set_player_target_coordinates

        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        rts
.endproc

.proc player_move
TargetRow := R0
TargetCol := R1
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
        ; FOR NOW, merely set the player's new row and column and exit.
        ; TODO: check to see if this is a valid tile and, if not, forbid the move
        ; TODO: lerp from the old to the new position
        ; TODO: set up and apply a jump offset to the Y position here, even if the move is forbbidden (the jump in place communicates a "try")
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        rts
.endproc

; For rapidly computing the tile row
player_tile_index_table:
        .repeat ::BATTLEFIELD_HEIGHT, i
        .byte (::BATTLEFIELD_WIDTH * i)
        .endrepeat

.proc player_swing_weapon
; We don't use these, but we should know not to clobber them
TargetRow := R0
TargetCol := R1
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9

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
        ldy #WeaponClass::SouthSquaresPtr

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
        lda player_tile_index_table
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
        lda (WeaponSquaresPtr), y ; Behavioral Flags for this tile
        sta WeaponProperties      ; Stash these here so the enemies can see them (if applicable)
        sty WeaponSquaresIndex
        jsr attack_enemy_tile
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
        jmp done_with_swing
no_early_exit:
        ; Otherwise, iterate to the next weapon square and continue
        dec TilesRemaining
        bne loop

done_with_swing:
        ; If there is any cleanup to do, do that here. Otherwise we're finished I think?

        rts
.endproc

