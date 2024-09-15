        .setcpu "6502"

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "input.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "bhop/longbranch.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "palette.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "torchlight.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage

FxTileId: .res 1
SfxTileId: .res 1
SingleHitAttackSquare: .res 1
PlayerWeaponPtr: .res 2

PlayerZonePtr: .res 2

.segment "RAM"

DestinationZonePtr: .res 2

player_equipment_by_index: ; for indexing into this like a list
        PlayerEquipmentWeapon: .res 1
        PlayerEquipmentTorch: .res 1
        PlayerEquipmentArmor: .res 1
        PlayerEquipmentBoots: .res 1
        PlayerEquipmentAccessory: .res 1
        PlayerEquipmentBombs: .res 1
        PlayerEquipmentSpell: .res 1

PlayerBombCount: .res 1

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
PlayerMovementBlocked: .res 1
PlayerTorchlightRadius: .res 1

PlayerKeys: .res 1
PlayerGold: .res 2

PlayerRoomIndex: .res 1

PlayerIdleBeats: .res 1

; "Scratch" registers, because 16 was just not enough for some situations
EnemyDiedThisFrame: .res 1
SafetyCol: .res 1
SafetyRow: .res 1

; Score Multipliers
PlayerCombo: .res 1
PlayerChain: .res 1
PlayerChainGrace: .res 1

PlayerNavState: .res 1

PlayerPreviousSuccessfulDirection: .res 1

PlayerIntendsToPause: .res 1
PlayerIsPaused: .res 1

PlayerIntendsToWait: .res 1
PlayerIntendsToBomb: .res 1
PlayerIntendsToCast: .res 1

DIRECTION_NORTH = 1
DIRECTION_EAST  = 2
DIRECTION_SOUTH = 3
DIRECTION_WEST  = 4

.segment "PRGFIXED_E000"

; For rapidly computing the tile row
row_number_to_tile_index_lut:
player_tile_index_table:
        .repeat ::BATTLEFIELD_HEIGHT, i
        .byte (::BATTLEFIELD_WIDTH * i)
        .endrepeat

.segment "CODE_4"

; 4 bytes each, mostly so we can use NEXXT to design the things
player_palettes:
        .incbin "art/player_palettes_1.pal"

JUMP_HEIGHT_END = 5
jump_height_table:
        .byte 10, 14, 11, 7, 2, 0

.proc FAR_init_player
NewHeartType := R0
HealingAmount := R0
MetaSpriteIndex := R0
HeartCount := R2
        ; spawn in the player sprite
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        jeq sprite_failed
        stx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #0 ; irrelevant
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #$FF ; intentionally offscreen
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #<SPRITE_TILE_PLAYER
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

        lda #PLAYER_BASE_TORCHLIGHT
        sta PlayerTorchlightRadius

.if ::DEBUG_GOD_MODE
        ; The player should start with whatever Zeta likes        
        lda #ITEM_BROADSWORD_L2
        sta PlayerEquipmentWeapon
        lda #ITEM_LARGE_TORCH
        sta PlayerEquipmentTorch
        lda #ITEM_SHIELD
        sta PlayerEquipmentArmor
        lda #ITEM_NONE
        sta PlayerEquipmentBoots
        sta PlayerEquipmentAccessory
        sta PlayerEquipmentBombs
        sta PlayerEquipmentSpell

        near_call FAR_initialize_hearts_for_game
        
        ; All the heart types, yes!
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        near_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        near_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        near_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        near_call FAR_add_heart
        lda #HEART_TYPE_TEMPORARY
        sta NewHeartType
        near_call FAR_add_heart

        ; Some glass hearts, yes yes!
;        lda #3
;        sta HeartCount
;heart_loop:
;        lda #HEART_TYPE_GLASS
;        sta NewHeartType
;        near_call FAR_add_heart
;        dec HeartCount
;        bne heart_loop

        ; Heal the player to full! (regular hearts start empty)
        lda #255
        sta HealingAmount
        near_call FAR_receive_healing

        st16 PlayerGold, 150
.else
        ; The player should start with a standard L1-DAGGER
        lda #ITEM_DAGGER_L1
        sta PlayerEquipmentWeapon
        lda #ITEM_NONE
        sta PlayerEquipmentTorch
        sta PlayerEquipmentArmor
        sta PlayerEquipmentBoots
        sta PlayerEquipmentAccessory
        sta PlayerEquipmentBombs
        sta PlayerEquipmentSpell

        ; 2 regular hearts makes the starting player *quite* squishy.
        ; that's the point!
        near_call FAR_initialize_hearts_for_game

        lda #3
        sta HeartCount
heart_loop:
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        near_call FAR_add_heart
        dec HeartCount
        bne heart_loop

        ; Heal the player to full! (regular hearts start empty)
        lda #255
        sta HealingAmount
        near_call FAR_receive_healing

        st16 PlayerGold, 0
.endif

        lda #0
        sta PlayerKeys
        sta PlayerRoomIndex

        lda #0
        sta PlayerIdleBeats

        lda #0
        sta PlayerCombo
        sta PlayerChain
        sta PlayerChainGrace

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause
        sta PlayerNextDirection

        rts

sprite_failed:
        ; what? this should never happen...
        rts
.endproc

; So things other than main gameplay can do this, mostly for
; the title screen and eventual save screen, etc etc
.proc FAR_apply_player_palette
        lda setting_personal_color_phones
        sta ObjPaletteBuffer+1
        lda setting_personal_color_pajamas
        sta ObjPaletteBuffer+2
        lda setting_personal_color_pigment
        sta ObjPaletteBuffer+3
        rts
.endproc

; Called once every frame
.proc FAR_draw_player
        ; Based on the player's chosen sprite index, update their base sprite colors
        lda setting_personal_color_phones
        sta ObjPaletteBuffer+1
        lda setting_personal_color_pajamas
        sta ObjPaletteBuffer+2
        lda setting_personal_color_pigment
        sta ObjPaletteBuffer+3

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
        perform_zpcm_inc
        rts
.endproc

player_horiz_offset_lut:
        .byte   1,   1,   2,   3,   4,   7,  10,  15,  21,  28,  37,  48,  61,  75,  92, 112
        .byte 132, 149, 163, 176, 187, 196, 203, 209, 214, 217, 220, 221, 222, 223, 223, 223
player_vert_offset_lut:
        .byte   1,   1,   1,   2,   3,   5,   7,  10,  14,  18,  24,  31,  39,  49,  60,  72
        .byte  84,  95, 105, 113, 120, 126, 130, 134, 137, 139, 141, 142, 143, 143, 143, 143

; Note: these apply directly to the sprite position, we'll call this every frame
; but only during transitions. We clean up the position properly later.
.proc correct_player_pos_during_left_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionX, y
        clc
        adc player_horiz_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionX, y
        rts
.endproc

.proc correct_player_pos_during_right_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionX, y
        sec
        sbc player_horiz_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionX, y
        rts
.endproc

.proc correct_player_pos_during_up_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionY, y
        clc
        adc player_vert_offset_lut, x
        cmp #224
        bcs player_too_high
        ; additional tomfoolery: if the player's Y position went
        ; negative, clamp it back to 0. we only care about a small range here
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
player_too_high:
        lda #0
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
.endproc

.proc correct_player_pos_during_down_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionY, y
        sec
        sbc player_vert_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
.endproc

.proc FAR_correct_player_pos_during_slide
        lda RoomTransitionType
        cmp #ROOM_TRANSITION_SLIDE_RIGHT
        beq correct_slide_right
        cmp #ROOM_TRANSITION_SLIDE_LEFT
        beq correct_slide_left
        cmp #ROOM_TRANSITION_SLIDE_DOWN
        beq correct_slide_down
        cmp #ROOM_TRANSITION_SLIDE_UP
        beq correct_slide_up
        ; What? How did we get here?
        rts
correct_slide_right:
        jsr correct_player_pos_during_right_slide
        rts
correct_slide_left:
        jsr correct_player_pos_during_left_slide
        rts
correct_slide_down:
        jsr correct_player_pos_during_down_slide
        rts
correct_slide_up:
        jsr correct_player_pos_during_up_slide
        rts
.endproc

.proc FAR_finalize_player_pos_after_slide
        jsr set_player_target_coordinates
        jsr apply_target_coordinates_immediately
        rts
.endproc

; Called once every frame, after input has been processed.
; Updates variables related to the desired direction and 
; whether a down press has occurred at all this frame

; Notable: Only one (1) button takes action on a given gameplay
; beat. There is a priority for simultaneous presses, but we should
; never leave the output of this function in a state that suggests
; multiple actions on the same beat. Absolutely not allowed, this
; constraint simplifies logic elsewhere. We can conditionally choose
; whether to recognize the button, but if we do recognize it, it cancels
; all the other possibilities when chosen.

.proc FAR_determine_player_intent
        lda #(KEY_START)
        bit ButtonsDown
        beq check_pause_state
        lda #1
        sta PlayerIntendsToPause
        lda #0
        sta PlayerNextDirection
        rts

        ; While actually paused, the only valid action is to attempt to unpause!
check_pause_state:
        lda PlayerIsPaused
        beq check_action_buttons
        rts

check_action_buttons:
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT | KEY_SELECT | KEY_B  | KEY_A)
        bit ButtonsDown
        bne handle_button_press
        rts ; all done
handle_button_press:
        ; Only one button can take effect
        lda #0
        sta PlayerIntendsToPause

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
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_east:
        lda #KEY_RIGHT
        bit ButtonsDown
        beq check_south        
        lda #DIRECTION_EAST
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_south:
        lda #KEY_DOWN
        bit ButtonsDown
        beq check_west
        lda #DIRECTION_SOUTH
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_west:
        lda #KEY_LEFT
        bit ButtonsDown
        beq check_wait ; this shouldn't be reachable
        lda #DIRECTION_WEST
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts   
check_wait:
        lda #KEY_SELECT
        bit ButtonsDown
        beq check_bomb ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToWait
        lda #0
        sta PlayerNextDirection
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_bomb:
        lda #KEY_B
        bit ButtonsDown
        beq check_spellcast ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToBomb
        lda #0
        sta PlayerIntendsToWait
        sta PlayerNextDirection
        sta PlayerIntendsToCast
        rts
check_spellcast:
        lda #KEY_A
        bit ButtonsDown
        beq no_valid_press ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToCast
        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToWait
        sta PlayerNextDirection
        rts
no_valid_press: ; not really sure how this label gets hit, but whatever
        rts
.endproc

.proc set_player_target_coordinates
        perform_zpcm_inc
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
        perform_zpcm_inc
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
        perform_zpcm_inc
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

        perform_zpcm_inc

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

        perform_zpcm_inc

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

        perform_zpcm_inc

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
.proc FAR_update_player
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        ; First up, default the player's animation cel to either standing or, if it's been a really long
        ; time since we got a player input AND the room is clear, the idle pose for flavor
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq pick_standard_pose
check_for_idle_pose:
        lda PlayerIdleBeats
        cmp #16
        bcc pick_standard_pose
        lda #16
        sta PlayerIdleBeats
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x
        jmp done_with_initial_pose
pick_standard_pose:
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER
        sta sprite_table + MetaSpriteState::TileIndex, x
done_with_initial_pose:

        ; Always reset the player's palette back to 0 at the start of the beat
        ; (in case some other state changed it for an effect)
        ldx PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #($FF - SPRITE_PAL_MASK)
        ora #SPRITE_PAL_0
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol

        inc PlayerIdleBeats

        lda #0
        sta PlayerCombo

        lda PlayerNextDirection
        beq resolve_enemy_collision

        lda #0
        sta PlayerIdleBeats

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
        near_call FAR_player_resolve_collision

        jsr handle_go_go_boots_movement

        ; If the player's position changed, have the jumping pose kick in
        ; (this overrides attacking, which feels like it should be appropriate?)
        ; TODO: if something else can move the player (pushing enemies?) we might
        ; need a custom "being pushed" animation. at the very least, the player probably
        ; shouldn't visibly jump.
        lda TargetRow
        cmp PlayerRow
        bne apply_jumping_pose
        lda TargetCol
        cmp PlayerCol
        bne apply_jumping_pose
        ; the player's previous move did not succeed, so clear that flag
        lda #0
        sta PlayerPreviousSuccessfulDirection
        jmp skip_jumping_pose
apply_jumping_pose:
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER_JUMP
        sta sprite_table + MetaSpriteState::TileIndex, x
        ; The player's movement succeeded, so store that in a flag
        lda PlayerNextDirection
        sta PlayerPreviousSuccessfulDirection
skip_jumping_pose:

        ; Update the player's combo counter
        jsr update_chain_and_combo

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        jsr set_player_target_coordinates

        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        ; Detect equipment changes and update static player stats as necessary
        ; (this needs to happen BEFORE our exit changes, to facilitate room transition logic)
        far_call FAR_equipment_torchlight
        lda TorchlightTotal
        sta PlayerTorchlightRadius
        ; If this room is darkened, apply torchlight
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_darkness
        lda PlayerTorchlightRadius
        sta target_torchlight_radius
no_darkness:

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; Detect pausing. (The boss key, the mom alert, etc.)
        jsr detect_pause_action

        ; TODO: Detect other types of intent here. These aren't implemented,
        ; so just clear the intent flags for now.
        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait

        rts
.endproc

.proc handle_go_go_boots_movement
TargetRow := R14
TargetCol := R15
        ; ITEM: if the player has the gogo boots equipped, 
        ; AND the previous move succeeded,
        ; AND this is their second successful move,
        ; then attempt a move again!
        lda PlayerEquipmentBoots
        cmp #ITEM_GO_GO_BOOTS
        bne done_with_go_go_boots

        ; don't trigger if we aren't actually attempting a move
        lda PlayerNextDirection
        beq done_with_go_go_boots

        ; don't trigger if we are changing directions OR if this is our
        ; first movement in this chain
        lda PlayerPreviousSuccessfulDirection
        cmp PlayerNextDirection
        bne done_with_go_go_boots

        ; don't trigger if the previous movement failed!
        lda TargetRow
        cmp PlayerRow
        bne previous_move_succeeded
        lda TargetCol
        cmp PlayerCol
        bne previous_move_succeeded
        jmp done_with_go_go_boots
previous_move_succeeded:

        ; don't trigger if we are moving towards a map border and we have
        ; already arrived there!
        lda PlayerNextDirection
        ldx TargetCol
        ldy TargetRow
check_north:
        cmp #DIRECTION_NORTH
        bne check_east
        cpy #0
        beq done_with_go_go_boots
check_east:
        cmp #DIRECTION_EAST
        bne check_south
        cpx #(BATTLEFIELD_WIDTH-1)
        beq done_with_go_go_boots
check_south:
        cmp #DIRECTION_SOUTH
        bne check_west
        cpy #(BATTLEFIELD_HEIGHT-1)
        beq done_with_go_go_boots
check_west:
        cmp #DIRECTION_WEST
        bne done_with_map_edge_checks
        cpx #0
        beq done_with_go_go_boots
done_with_map_edge_checks:

        ; finally, all the sanity checks having passed, do the thing
        ; firstly, commit the previous move (it succeeded)
        lda TargetCol
        sta PlayerCol
        lda TargetRow
        sta PlayerRow

        ; the previous move actually happened, so apply the jumping pose
        ; (even if the next one fails!)
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER_JUMP
        sta sprite_table + MetaSpriteState::TileIndex, x

move_player:
        jsr player_move        

resolve_enemy_collision:
        near_call FAR_player_resolve_collision

done_with_go_go_boots:
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

.proc load_weapon_ptr
ItemPtr := R0
        access_data_bank #<.bank(item_table)
        lda PlayerEquipmentWeapon
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1
        ldy #ItemDef::WeaponShape
        lda (ItemPtr), y
        asl
        tay
        lda weapon_class_table+0, y
        sta PlayerWeaponPtr+0
        lda weapon_class_table+1, y
        sta PlayerWeaponPtr+1
        restore_previous_bank
        rts
.endproc

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
        perform_zpcm_inc

        jsr load_weapon_ptr ; clobbers R0,R1,y

        perform_zpcm_inc

        lda #0
        sta EnemyDiedThisFrame

        lda #0
        sta PlayerCombo

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
        perform_zpcm_inc
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
        perform_zpcm_inc
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; For safety, track the raw row/col as well
        lda PlayerRow
        sta SafetyRow
        lda PlayerCol
        sta SafetyCol

        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare
        
        ; Also add it to our tracked SafetyCol
        lda PlayerCol
        clc
        adc (WeaponSquaresPtr), y ; X offset
        sta SafetyCol

        iny
        ; For the SafetyRow, we can do simple arithmetic here
        lda (WeaponSquaresPtr), y ; Y offset
        clc
        adc SafetyRow
        sta SafetyRow
        
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
        perform_zpcm_inc

        lda (WeaponSquaresPtr), y
        sta FxTileId ; stash for if this hits
        iny
        lda (WeaponSquaresPtr), y
        sta SfxTileId ; stash for if this hits
        iny

        lda (WeaponSquaresPtr), y ; Behavioral Flags for this tile
        sta WeaponProperties      ; Stash these here so the enemies can see them (if applicable)
        iny
        sty WeaponSquaresIndex

        ; Safety Dance: do NOT attack tiles that are out of bounds
        lda SafetyCol
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_WIDTH
        bcs skip_out_of_bounds
        lda SafetyRow
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_HEIGHT
        bcs skip_out_of_bounds

        perform_zpcm_inc
        far_call FAR_attack_enemy_tile
skip_out_of_bounds:
        perform_zpcm_inc

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
        lda AttackSquare
        sta SingleHitAttackSquare
        jsr draw_single_hit_fx
        jsr draw_multiple_hit_sfx
        jmp done_with_swing
no_early_exit:
        ; Otherwise, iterate to the next weapon square and continue
        dec TilesRemaining
        jne loop

        lda AttackLanded
        beq done_with_swing
        jsr draw_multiple_hit_fx

done_with_swing:
        perform_zpcm_inc
        ; if an attack landed at all ...
        lda AttackLanded
        beq done
        
        ; ... play a weapon slash effect
        lda EnemyDiedThisFrame
        bne skip_weapon_sfx
        st16 R0, sfx_weapon_slash
        jsr play_sfx_noise
skip_weapon_sfx:
        ; ... and set our sprite state to attacking
        ; TODO: if we have multiple or weapon-specific attack animations, here is where to apply them
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER_ATTACK
        sta sprite_table + MetaSpriteState::TileIndex, x

done:
        ; If there is any cleanup to do, do that here. Otherwise we're finished I think?
        perform_zpcm_inc
        rts
.endproc

.proc update_chain_and_combo
ChainGraceThreshold := R0
        perform_zpcm_inc
        lda #1
        sta ChainGraceThreshold
        ; If the player has a chain effecting item equipped, increase their chain threshold accordingly
        lda PlayerEquipmentAccessory
        cmp #ITEM_CHAIN_LINK
        bne chain_threshold_finalized
        lda #3
        sta ChainGraceThreshold
chain_threshold_finalized:
        ; Based on the player's accumulated combo, manipulate their chain here
        lda PlayerCombo
        beq check_chain_over
        ; Continue the player's current chain
        inc PlayerChain
        lda #0
        sta PlayerChainGrace
        jmp cleanup
check_chain_over:
        ; If the player is below the grace threshold, continue the chain
        lda PlayerChainGrace
        cmp ChainGraceThreshold
        bcs chain_over
        ; continue the grace period
        inc PlayerChainGrace
        jmp cleanup
chain_over:
        ; Reset the chain and grace back to 0
        lda #0
        sta PlayerChain
        sta PlayerChainGrace

cleanup:
        perform_zpcm_inc
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
        perform_zpcm_inc
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; For safety, track the raw row/col as well
        lda PlayerRow
        sta SafetyRow
        lda PlayerCol
        sta SafetyCol
        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare

        ; Also add it to our tracked SafetyCol
        lda PlayerCol
        clc
        adc (WeaponSquaresPtr), y ; X offset
        sta SafetyCol

        iny
        ; For the SafetyRow, we can do simple arithmetic here
        lda (WeaponSquaresPtr), y ; Y offset
        clc
        adc SafetyRow
        sta SafetyRow

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
        perform_zpcm_inc

        ; Read the FX ID, which we are about to draw
        lda (WeaponSquaresPtr), y
        sta FxTileId
        iny
        lda (WeaponSquaresPtr), y
        sta SfxTileId
        iny

        ; Skip over the behavioral flags
        iny
        sty WeaponSquaresIndex

        ; Safety Dance: do NOT draw tiles that are out of bounds
        lda SafetyCol
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_WIDTH
        bcs skip_out_of_bounds
        lda SafetyRow
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_HEIGHT
        bcs skip_out_of_bounds

        ; Now we have the attack square, we can draw the weapon FX 
        jsr spawn_fx_sprite_here
skip_out_of_bounds:
        dec TilesRemaining
        bne loop

        rts
.endproc

; Variant used by spears and flails, for their non-hit sprites
.proc draw_multiple_hit_sfx
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
        perform_zpcm_inc
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; For safety, track the raw row/col as well
        lda PlayerRow
        sta SafetyRow
        lda PlayerCol
        sta SafetyCol
        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare

        ; Also add it to our tracked SafetyCol
        lda PlayerCol
        clc
        adc (WeaponSquaresPtr), y ; X offset
        sta SafetyCol

        iny
        ; For the SafetyRow, we can do simple arithmetic here
        lda (WeaponSquaresPtr), y ; Y offset
        clc
        adc SafetyRow
        sta SafetyRow

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
        perform_zpcm_inc

        ; Read the FX ID, which we are about to draw
        lda (WeaponSquaresPtr), y
        sta FxTileId
        iny
        lda (WeaponSquaresPtr), y
        sta SfxTileId
        iny

        ; Skip over the behavioral flags
        iny
        sty WeaponSquaresIndex

        ; Now we have the attack square, we can draw the weapon FX 
        ; But for SFX, only if this is NOT the square where the attack landed
        ; (... and maybe not if it matches the player's location?)
        lda AttackSquare
        cmp SingleHitAttackSquare
        beq skip_draw

        ; Safety Dance: do NOT draw tiles that are out of bounds
        lda SafetyCol
        bmi skip_draw
        cmp #BATTLEFIELD_WIDTH
        bcs skip_draw
        lda SafetyRow
        bmi skip_draw
        cmp #BATTLEFIELD_HEIGHT
        bcs skip_draw

        jsr spawn_sfx_sprite_here
skip_draw:

        dec TilesRemaining
        bne loop

        rts
.endproc

.proc spawn_fx_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
        perform_zpcm_inc
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        perform_zpcm_inc

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
        perform_zpcm_inc
        rts
.endproc

.proc spawn_sfx_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
        perform_zpcm_inc
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        perform_zpcm_inc

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

        lda SfxTileId
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        perform_zpcm_inc
        rts
.endproc

.proc FAR_player_resolve_collision
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        perform_zpcm_inc
        ldx TargetRow
        lda player_tile_index_table, x ; Row * Width
        clc
        adc TargetCol                  ; ... + Col
        sta TargetSquare

        far_call FAR_player_collides_with_tile
        perform_zpcm_inc
        rts
.endproc

.proc FAR_damage_player
IncomingDamage := R0
DamageReduction := R0
        lda IncomingDamage
        pha
        far_call FAR_dmg_reduction
        pla
        sec
        sbc DamageReduction
        bmi cap_to_minimum
        beq cap_to_minimum
        jmp damage_amount_okay
cap_to_minimum:
        lda #1
damage_amount_okay:
        sta IncomingDamage
        near_call FAR_receive_damage
        jsr FIXED_is_player_considered_dead
        bne already_dead

        lda #1
        sta ScreenShakeDepth
        lda #16
        sta ScreenShakeSpeed
        sta ScreenShakeDecayCounter

        ; Taking damage is a *big deal*
        st16 R0, sfx_weak_hit_pulse
        jsr play_sfx_pulse1
        st16 R0, sfx_weak_hit_tri
        jsr play_sfx_triangle
        st16 R0, sfx_weak_hit_noise
        jsr play_sfx_noise

        ; Taking damage resets any ongoing chain. We want to
        ; reward SKILLED play, not merely one's ability to
        ; kite a crowd of zombies and tank hits
        lda #0
        sta PlayerChain
        sta PlayerChainGrace

        ; apply the damage coloration no matter what pose we're in
        ldx PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #($FF - SPRITE_PAL_MASK)
        ora #SPRITE_PAL_2
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        ; If we are in our idle pose, switch to damage. (Let any other
        ; animation override the damage state though, as it's more important)
        lda sprite_table + MetaSpriteState::TileIndex, x
        cmp #<SPRITE_TILE_PLAYER
        beq apply_damage_animation
        cmp #<SPRITE_TILE_PLAYER_IDLE
        beq apply_damage_animation
        jmp action_overrides_damage_animation
apply_damage_animation:
        lda #<SPRITE_TILE_PLAYER_HIT
        sta sprite_table + MetaSpriteState::TileIndex, x
action_overrides_damage_animation:
        rts

already_dead:
        rts
.endproc

exit_left_lut:
        .repeat ::FLOOR_HEIGHT, h
        .byte (FLOOR_WIDTH-1) + (h * FLOOR_WIDTH)
        .repeat ::FLOOR_WIDTH - 1, w
        .byte (w) + (h * FLOOR_WIDTH)
        .endrepeat
        .endrepeat

exit_right_lut:
        .repeat ::FLOOR_HEIGHT, h
        .repeat ::FLOOR_WIDTH - 1, w
        .byte (w+1) + (h * FLOOR_WIDTH)
        .endrepeat
        .byte (0) + (h * FLOOR_WIDTH)
        .endrepeat

exit_up_lut:
        .repeat ::FLOOR_WIDTH, w
        .byte w + ((::FLOOR_HEIGHT-1) * FLOOR_WIDTH)
        .endrepeat
        .repeat ::FLOOR_HEIGHT-1, h
        .repeat ::FLOOR_WIDTH, w
        .byte (w) + (h * FLOOR_WIDTH)
        .endrepeat
        .endrepeat

exit_down_lut:
        .repeat ::FLOOR_HEIGHT-1, h
        .repeat ::FLOOR_WIDTH, w
        .byte (w) + ((h+1) * FLOOR_WIDTH)
        .endrepeat
        .endrepeat
        .repeat ::FLOOR_WIDTH, w
        .byte w + ((0) * FLOOR_WIDTH)
        .endrepeat

; Note: checks and updates PlayerRow/PlayerCol,
; but does **not** update the target or tween positions.
; This intentionally desynchronizes the on-screen position, which
; allows the player to appear to jump to the exit tile. When the next
; room loads, we'll instantly set their new position and they'll be in
; the right spot based on the way they left the previous field.
.proc detect_exit
RoomIndexScratch := R0
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
        ; For fun and later warping, wrap the room index around the map
        ; 
        ldx PlayerRoomIndex
        lda exit_left_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_LEFT
        sta RoomTransitionType
        lda #(::BATTLEFIELD_WIDTH - 2)
        sta PlayerCol
        jmp converge
exit_right:
        ldx PlayerRoomIndex
        lda exit_right_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_RIGHT
        sta RoomTransitionType
        lda #1
        sta PlayerCol
        jmp converge
exit_top:
        ldx PlayerRoomIndex
        lda exit_up_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_UP
        sta RoomTransitionType
        lda #(::BATTLEFIELD_HEIGHT - 2)
        sta PlayerRow
        jmp converge
exit_bottom:
        ldx PlayerRoomIndex
        lda exit_down_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_DOWN
        sta RoomTransitionType
        lda #1
        sta PlayerRow
        jmp converge
converge:
        st16 GameMode, room_transition
        ; mark the room as "busy", this prevents us clearing the next room prematurely
        lda #1
        sta first_beat_after_load
        ; suppress torchlight updates over the transition (resolves minor visual jank)
        lda #1
        sta SuppressTorchlight
        ; we may not PAUSE over the exit transition. this normally shouldn't occur, but
        ; an enemy might have forced us to the screen edge or something, so be safe
        lda #0
        sta PlayerIntendsToPause
        rts
.endproc

.proc detect_critical_existence_failure
        jsr FIXED_is_player_considered_dead
        beq existence_proven

        ; If we wanted to pause to avoid our fate, **TOO BAD.**
        ; (yes, this means an activating on-death item can eat a pause
        ; input; deal with it.)
        lda #0
        sta PlayerIntendsToPause

        ; TODO: items that activate on death (amulet!?)
        ; TODO: setup for a proper "dying" beat (greyscale background, player
        ; frozen in dmg state, etc)
        ; POSTPONED: fix hearts first :)

        ; Whelp; that's the end of the line
        ; TODO: I dunno, screen shake? palette greyscale? SFX? Juice this up.
        st16 FadeToGameMode, game_end_screen_prep
        st16 GameMode, fade_to_game_mode

        ; STOP the music
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        sta play_track

        ; Oops
        st16 R0, sfx_death_spin_pulse
        jsr play_sfx_pulse1
        st16 R0, sfx_death_spin_pulse
        jsr play_sfx_pulse1
        st16 R0, sfx_death_spin_tri
        jsr play_sfx_triangle
existence_proven:
        rts
.endproc

.proc detect_pause_action
        lda PlayerIntendsToPause
        bne proceed_to_pause
        lda PlayerIsPaused
        bne continue_being_paused
        rts
proceed_to_pause:
        ; Most importantly, consume the intent!
        lda #0
        sta PlayerIntendsToPause

        ; Are we pausing or unpausing?
        lda PlayerIsPaused
        beq perform_pause
perform_unpause:
        lda #0
        sta PlayerIsPaused
        lda #4
        sta TargetBrightness

        near_call FAR_play_music_for_current_room

        st16 R0, sfx_pause
        jsr play_sfx_pulse1

        rts
perform_pause:
        lda #1
        sta PlayerIsPaused
        lda #3
        sta TargetBrightness

        lda #TRACK_VARIANT_PAUSE
        jsr play_variant

        st16 R0, sfx_pause
        jsr play_sfx_pulse1

        jmp continue_being_paused
        rts

continue_being_paused:
        ; Put player in the "idle" pose during a pause
        ldx PlayerSpriteIndex
        lda #<SPRITE_TILE_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x

        ; Important: do NOT process any actual game logic while we are paused!
        ; Jump ahead to battlefield drawing, which will re-use the state we just computed.
        ; (why not just wait? because beat_frame_1 still switches the buffers; we need to
        ; draw or it'll flip back to the previous frame)
        st16 GameMode, draw_battlefield_A

        rts
.endproc
