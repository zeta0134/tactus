        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bombs.inc"

        .include "battlefield.inc"
        .include "far_call.inc"
        .include "player.inc"
        .include "rainbow.inc"
        .include "sprites.inc"
        .include "zpcm.inc"
        .include "zeropage.inc"

; Note that fuse length is tracked separately.
; These two combined will determine where the
; bomb is drawn and what it looks like
BOMB_STATE_STANDARD_INIT     = 0
BOMB_STATE_STANDARD_HOISTING = 1
BOMB_STATE_STANDARD_HELD     = 2
BOMB_STATE_STANDARD_THROWN   = 3
BOMB_STATE_STANDARD_GROUNDED = 4

; Corresponding to player inputs
DIRECTION_NORTH = 1
DIRECTION_EAST  = 2
DIRECTION_SOUTH = 3
DIRECTION_WEST  = 4

        .segment "PRGRAM"

bomb_entities: .res ::MAX_ACTIVE_BOMBS * .sizeof(BombState)

        .segment "ENEMY_BOMB_SPELL"

.proc FAR_init_bomb_state
        lda #0
        .repeat ::MAX_ACTIVE_BOMBS, i
        sta bomb_entities + BombState::Flags + (i * .sizeof(BombState))
        .endrepeat
        rts
.endproc

; Called when the player has pressed the B button. Performs necessary
; checks to guard hoisting bombs, then attempts to spawn a bomb entity.
; On success, returns the entity ID, on failure always returns #$FF. The
; entity ID may be 0, so check for #$FF explicitly to detect failure.
; All bomb types may be assumed "held" after hoisting.
.proc FAR_try_hoist_bomb
MetaSpriteIndex := R0
NewBombIndex := R8
        ; If the player has no bombs, fail right away
        lda PlayerBombCount
        bne player_has_bombs
        lda #$FF
        rts
player_has_bombs:
        
        ; If the player is currently holding a bomb, do not hoist another.
        ; (This should never happen, but check for it to be safe.)
        lda PlayerHeldBombIndex
        cmp #$FF
        beq player_hands_empty
        lda #$FF
        rts
player_hands_empty:

        ; Game logic is passed, try to spawn a bomb entity
        jsr _find_first_inactive_bomb_slot
        cpx #$FF
        bne bomb_entity_spawning_success
        ; We are out of active bomb slots! Cancel the hoist input
        lda #$FF
        rts
bomb_entity_spawning_success:
        stx NewBombIndex

        ; Before we activate this entity, try to spawn a metasprite
        ; (which may also fail in extremely busy situations)
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        bne bomb_sprite_allocation_succeeded
        ; We are out of metasprites! We can't have a bomb without one,
        ; so react by canceling the hoist. Hopefully this should be a quite
        ; uncommon occurrence, but it may happen in semi-rare circumstances
        ; when many enemies are defeated on a single turn.
        lda #$FF
        rts
bomb_sprite_allocation_succeeded:

        ldx NewBombIndex

        ; Based on the bomb type, set the initial state
        lda PlayerEquipmentBombs
        cmp #ITEM_BOMB_STANDARD
        beq standard
        ; TODO: other bomb types here

        ; If we arrive here, something went wrong. Do not spawn
        ; a weird bomb, cancel the hoist! (the metasprite was never
        ; marked as active and will self-cancel here)
        lda #$FF
        rts
standard:
        lda #BOMB_STATE_STANDARD_INIT
        sta bomb_entities + BombState::State, x
        jmp done_picking_state
done_picking_state:

        ; At this point the bomb *definitely* succeeded in spawning.
        ; Hoist the bomb! Decrement the counter and initialize all the things
        dec PlayerBombCount

        ; Now we may initialize the rest of the bomb state
        lda #BOMB_FLAG_ACTIVE
        sta bomb_entities + BombState::Flags, x
        lda PlayerEquipmentBombs
        sta bomb_entities + BombState::Type, x

        lda MetaSpriteIndex
        sta bomb_entities + BombState::MetaspriteIndex, x
        sta bomb_entities + BombState::FuseDuration, x
        sta bomb_entities + BombState::FrameCounter, x
        ; Initialize the bomb position to the player position
        lda PlayerRow
        sta bomb_entities + BombState::CurrentRow, x
        lda PlayerCol
        sta bomb_entities + BombState::CurrentCol, x
        jsr _set_bomb_target_coordinates
        jsr _snap_to_target_position
        ; Now, our update routine will draw the sprite properly later,
        ; but we at least need to mark it as "active" so the metasprite
        ; isn't reclaimed for something else before that runs. do that here,
        ; and set it offscreen.
        ldx MetaSpriteIndex
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

        ; and... in theory that's it? ah, but we need to return the index
        lda NewBombIndex
        rts
.endproc

; Does what it says on the tin
.proc do_nothing
        rts
.endproc

; because states are linear, use that for dispatch logic
; (we'll mostly ignore type)
throw_bomb_dispatch_table:
        .addr do_nothing          ; BOMB_STATE_STANDARD_INIT    
        .addr throw_standard_bomb ; BOMB_STATE_STANDARD_HOISTING
        .addr throw_standard_bomb ; BOMB_STATE_STANDARD_HELD    
        .addr do_nothing          ; BOMB_STATE_STANDARD_THROWN  
        .addr do_nothing          ; BOMB_STATE_STANDARD_GROUNDED

.proc FAR_throw_held_bomb
DispatchPtr := R0
        ldx PlayerHeldBombIndex
        cpx #$FF
        bne safe_to_throw
        ; how did this happen?
        rts
safe_to_throw:
        lda bomb_entities + BombState::State, x
        asl
        tay
        lda throw_bomb_dispatch_table+0, y
        sta DispatchPtr+0
        lda throw_bomb_dispatch_table+1, y
        sta DispatchPtr+1
        jmp (DispatchPtr) ; Wheeeee
.endproc

.proc throw_standard_bomb
        ; TODO: do we need to resync with the player position here? What if the
        ; player got shoved by an enemy?

        ldx PlayerHeldBombIndex
        ; Based on the player's current throw direction, move the bomb ahead 2 squares
        ; in that direction. But! Don't move the bomb off the edge of the map
        lda PlayerNextDirection
        cmp #DIRECTION_NORTH
        beq try_up
        cmp #DIRECTION_SOUTH
        beq try_down
        cmp #DIRECTION_EAST
        beq try_right
        cmp #DIRECTION_WEST
        beq try_left
        ; huh? well that's weird. cancel!
        rts
try_up:
        jsr _nudge_up
        jsr _nudge_up
        jmp done_moving
try_down:
        jsr _nudge_down
        jsr _nudge_down
        jmp done_moving
try_left:
        jsr _nudge_left
        jsr _nudge_left
        jmp done_moving
try_right:
        jsr _nudge_right
        jsr _nudge_right
        jmp done_moving
done_moving:
        ; sanity check: did we successfully move away from the player?
        ; if not, cancel the throw
        lda bomb_entities + BombState::CurrentCol, x
        cmp PlayerCol
        bne successful_throw
        lda bomb_entities + BombState::CurrentRow, x
        cmp PlayerRow
        bne successful_throw
        ; no dice! we may be too close to a wall or something. cancel
        ; the throw entirely!
        rts
successful_throw:
        ; Switch our own state to "thrown"
        lda #BOMB_STATE_STANDARD_THROWN
        sta bomb_entities + BombState::State, x
        ; and... that should be it? our update function will take over
        ; from here and do the right thing, one hopes.
        rts
.endproc

tick_fuse_dispatch_table:
        .addr standard_bomb_tick_fuse ; BOMB_STATE_STANDARD_INIT    
        .addr standard_bomb_tick_fuse ; BOMB_STATE_STANDARD_HOISTING
        .addr standard_bomb_tick_fuse ; BOMB_STATE_STANDARD_HELD    
        .addr standard_bomb_tick_fuse ; BOMB_STATE_STANDARD_THROWN  
        .addr standard_bomb_tick_fuse ; BOMB_STATE_STANDARD_GROUNDED

.proc _bomb_trampoline
DispatchPtr := R0
        jmp (DispatchPtr) ; Wheeeee
.endproc

.proc FAR_tick_bomb_fuses
DispatchPtr := R0
CurrentBombIndex := R15

        lda #0
        sta CurrentBombIndex
fuse_tick_loop:
        ldx CurrentBombIndex
        lda bomb_entities + BombState::Flags, x
        and #BOMB_FLAG_ACTIVE
        beq done_with_this_bomb
        lda bomb_entities + BombState::State, x
        asl
        tay
        lda tick_fuse_dispatch_table+0, y
        sta DispatchPtr+0
        lda tick_fuse_dispatch_table+1, y
        sta DispatchPtr+1
        jsr _bomb_trampoline
done_with_this_bomb:
        lda CurrentBombIndex
        clc
        adc #.sizeof(BombState)
        sta CurrentBombIndex
        cmp #(::MAX_ACTIVE_BOMBS * .sizeof(BombState))
        bne fuse_tick_loop

        rts
.endproc

; Fuse tick functions all accept the working index in R15
; and should not clobber it. Everything else is fair game.
.proc standard_bomb_tick_fuse
CurrentBombIndex := R15
        ldx CurrentBombIndex
        ; Always perform basic fuse management
        inc bomb_entities + BombState::FuseDuration, x
        lda #0
        sta bomb_entities + BombState::FrameCounter, x

        lda bomb_entities + BombState::State, x
        cmp #BOMB_STATE_STANDARD_INIT
        beq advance_to_held
        cmp #BOMB_STATE_STANDARD_HOISTING
        beq advance_to_held
        cmp #BOMB_STATE_STANDARD_THROWN
        beq advance_to_grounded
        jmp done_with_state_changes
advance_to_held:
        lda #BOMB_STATE_STANDARD_HELD
        sta bomb_entities + BombState::State, x
        jmp done_with_state_changes
advance_to_grounded:
        lda #BOMB_STATE_STANDARD_GROUNDED
        sta bomb_entities + BombState::State, x
        jmp done_with_state_changes
done_with_state_changes:
        ; If we've exceeded the fuse length, pretty much no matter what
        ; actual state we're in, EXPLODE on the spot. Otherwise, we're done
        lda bomb_entities + BombState::FuseDuration, x
        cmp #4
        bcs explode
        rts
explode:
        ; TODO: the actual explosion here!

        ; Play a suitable explosion SFX
        ; Have some screen shake, etc

        ; Cleanup: if we were held by the player, clear that
        lda PlayerHeldBombIndex
        cmp CurrentBombIndex
        bne not_currently_held
        lda #$FF
        sta PlayerHeldBombIndex
not_currently_held:
        ; Despawn our own metasprite
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; Mark ourselves as inactive
        lda #0
        sta bomb_entities + BombState::Flags, x
        ; And... that should be it.
        rts
.endproc

update_bomb_dispatch_table:
        .addr standard_bomb_update_init     ; BOMB_STATE_STANDARD_INIT    
        .addr standard_bomb_update_hoist    ; BOMB_STATE_STANDARD_HOISTING
        .addr standard_bomb_update_held     ; BOMB_STATE_STANDARD_HELD    
        .addr standard_bomb_update_thrown   ; BOMB_STATE_STANDARD_THROWN  
        .addr standard_bomb_update_grounded ; BOMB_STATE_STANDARD_GROUNDED

.proc FAR_update_active_bombs
DispatchPtr := R0
CurrentBombIndex := R15

        lda #0
        sta CurrentBombIndex
update_loop:
        ldx CurrentBombIndex
        lda bomb_entities + BombState::Flags, x
        and #BOMB_FLAG_ACTIVE
        beq done_with_this_bomb

        ; All active bombs have common lerping behavior, moving
        ; from their current position to the target square, whatever
        ; that is. Do that here rather than copy/pasting it into each
        ; state machine. Don't draw the result, let the state function
        ; handle that in its own way.
        jsr _lerp_bomb_to_target_coordinates
        ldx CurrentBombIndex

        lda bomb_entities + BombState::State, x
        asl
        tay
        lda update_bomb_dispatch_table+0, y
        sta DispatchPtr+0
        lda update_bomb_dispatch_table+1, y
        sta DispatchPtr+1
        jsr _bomb_trampoline

        ; Advance the frame counter, but don't let it exceed
        ; 15, as our lookup tables aren't longer than this
        ldx CurrentBombIndex
        lda bomb_entities + BombState::FuseDuration, x
        cmp #15
        bcs done_with_this_bomb
        inc bomb_entities + BombState::FuseDuration, x
done_with_this_bomb:

        lda CurrentBombIndex
        clc
        adc #.sizeof(BombState)
        sta CurrentBombIndex
        cmp #(::MAX_ACTIVE_BOMBS * .sizeof(BombState))
        bne update_loop

        rts
.endproc

; rise up from the player's position, as they'll be
; animating something of a "lift up item" thing.
; make it quick, no time for fluff at faster tempos
hoist_height_lut:
        .byte 0, 8, 12, 16, 18, 18, 17, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16

; A cute little bounce on the beat, don't overdo it
hold_height_lut:
        .byte 14, 14, 14, 15, 15, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16

; A delightful arc. The underlying lerp is quite
; fast, so don't go nuts with hangtime
toss_height_lut:
        .byte 18, 19, 18, 17, 14, 11, 7, 4
        .byte  0,  2,  3,  1,  0,  0, 0, 0

.proc standard_bomb_update_init
CurrentBombIndex := R15
        ; setup sprite things!
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda #SPRITE_TILE_BOMB_STANDARD
        sta sprite_table + MetaSpriteState::TileIndex, y
        lda #(SPRITE_ACTIVE | SPRITE_PAL_PURPLE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; Switch into "hoist" mode
        lda #BOMB_STATE_STANDARD_HOISTING
        sta bomb_entities + BombState::State, x
        ; And because we are hoisting already, run that state too
        jsr standard_bomb_update_hoist
        rts
.endproc

.proc standard_bomb_update_hoist
CurrentBombIndex := R15
        ; Apply our lerped position to the sprite, offset by the
        ; hoisted height table
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda bomb_entities + BombState::CurrentPosX+1, x
        sta sprite_table + MetaSpriteState::PositionX, y
        lda bomb_entities + BombState::CurrentPosY+1, x
        ldy bomb_entities + BombState::FrameCounter, x
        clc
        adc hoist_height_lut, y
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::PositionY, y
        ; and... that's it?
        rts
.endproc

.proc standard_bomb_update_held
CurrentBombIndex := R15
        ; Apply our lerped position to the sprite, offset by the
        ; held height table
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda bomb_entities + BombState::CurrentPosX+1, x
        sta sprite_table + MetaSpriteState::PositionX, y
        lda bomb_entities + BombState::CurrentPosY+1, x
        ldy bomb_entities + BombState::FrameCounter, x
        clc
        adc hold_height_lut, y
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::PositionY, y
        ; and... that's it?
        rts
.endproc

.proc standard_bomb_update_thrown
CurrentBombIndex := R15
        ; Apply our lerped position to the sprite, offset by the
        ; thrown height table
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda bomb_entities + BombState::CurrentPosX+1, x
        sta sprite_table + MetaSpriteState::PositionX, y
        lda bomb_entities + BombState::CurrentPosY+1, x
        ldy bomb_entities + BombState::FrameCounter, x
        clc
        adc toss_height_lut, y
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::PositionY, y
        ; and... that's it?
        rts
.endproc

.proc standard_bomb_update_grounded
CurrentBombIndex := R15
        ; Apply our lerped position to the sprite, with
        ; no offset (we are "on the ground")
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda bomb_entities + BombState::CurrentPosX+1, x
        sta sprite_table + MetaSpriteState::PositionX, y
        lda bomb_entities + BombState::CurrentPosY+1, x
        sta sprite_table + MetaSpriteState::PositionY, y
        ; and... that's it?
        rts
.endproc

.proc _nudge_right
        lda bomb_entities + BombState::CurrentCol, x
        cmp #(BATTLEFIELD_WIDTH-2)
        bcs nope
        inc bomb_entities + BombState::CurrentCol, x
nope:
        rts
.endproc

.proc _nudge_down
        lda bomb_entities + BombState::CurrentRow, x
        cmp #(BATTLEFIELD_HEIGHT-2)
        bcs nope
        inc bomb_entities + BombState::CurrentRow, x
nope:
        rts
.endproc

.proc _nudge_left
        lda bomb_entities + BombState::CurrentCol, x
        cmp #2
        bcc nope
        dec bomb_entities + BombState::CurrentCol, x
nope:
        rts
.endproc

.proc _nudge_up
        lda bomb_entities + BombState::CurrentRow, x
        cmp #2
        bcc nope
        dec bomb_entities + BombState::CurrentRow, x
nope:
        rts
.endproc

; result in X
.proc _find_first_inactive_bomb_slot
        .repeat ::MAX_ACTIVE_BOMBS, i
        .scope
        ldx #(i * .sizeof(BombState))
        lda bomb_entities + BombState::Flags, x
        and #BOMB_FLAG_ACTIVE
        bne check_next
        rts
check_next:
        .endscope
        .endrepeat
        ldx #$FF ; failure
        rts
.endproc

; Very similar to set_player_target_coordinates, since a bomb's metasprite
; should have its "floor silhouette" computed the same way the player does.
; Expects X to contain the metasprite index
.proc _set_bomb_target_coordinates
        perform_zpcm_inc
        lda bomb_entities + BombState::CurrentCol, x
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta bomb_entities + BombState::TargetPosX + 1, x
        lda #0
        sta bomb_entities + BombState::TargetPosX + 0, x

        lda bomb_entities + BombState::CurrentRow, x
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta bomb_entities + BombState::TargetPosY + 1, x
        lda #0
        sta bomb_entities + BombState::TargetPosY + 0, x
        perform_zpcm_inc
        rts
.endproc

.proc _snap_to_target_position
        lda bomb_entities + BombState::TargetPosX + 0, x
        sta bomb_entities + BombState::CurrentPosX + 0, x
        lda bomb_entities + BombState::TargetPosX + 1, x
        sta bomb_entities + BombState::CurrentPosX + 1, x
        lda bomb_entities + BombState::TargetPosY + 0, x
        sta bomb_entities + BombState::CurrentPosY + 0, x
        lda bomb_entities + BombState::TargetPosY + 1, x
        sta bomb_entities + BombState::CurrentPosY + 1, x
        rts
.endproc

; Bomb index in X, as usual
.proc _lerp_bomb_to_target_coordinates
CurrentPos := R0
TargetPos := R2
        perform_zpcm_inc
        lda bomb_entities + BombState::CurrentPosX + 0, x
        sta CurrentPos
        lda bomb_entities + BombState::CurrentPosX + 1, x
        sta CurrentPos+1
        lda bomb_entities + BombState::TargetPosX + 0, x
        sta TargetPos
        lda bomb_entities + BombState::TargetPosX + 1, x
        sta TargetPos+1
        jsr lerp_coordinate
        lda CurrentPos
        sta bomb_entities + BombState::CurrentPosX + 0, x
        lda CurrentPos+1
        sta bomb_entities + BombState::CurrentPosX + 1, x

        perform_zpcm_inc
        lda bomb_entities + BombState::CurrentPosY + 0, x
        sta CurrentPos
        lda bomb_entities + BombState::CurrentPosY + 1, x
        sta CurrentPos+1
        lda bomb_entities + BombState::TargetPosY + 0, x
        sta TargetPos
        lda bomb_entities + BombState::TargetPosY + 1, x
        sta TargetPos+1
        jsr lerp_coordinate
        lda CurrentPos
        sta bomb_entities + BombState::CurrentPosY + 0, x
        lda CurrentPos+1
        sta bomb_entities + BombState::CurrentPosY + 1, x

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