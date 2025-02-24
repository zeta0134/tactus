        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bombs.inc"

        .include "battlefield.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

; Note that fuse length is tracked separately.
; These two combined will determine where the
; bomb is drawn and what it looks like
BOMB_STATE_STANDARD_INIT     = 0
BOMB_STATE_STANDARD_HOISTING = 1
BOMB_STATE_STANDARD_HELD     = 2
BOMB_STATE_STANDARD_THROWN   = 3
BOMB_STATE_STANDARD_GROUNDED = 4
BOMB_STATE_PARTY_INIT     = 5
BOMB_STATE_PARTY_GROUNDED = 6

        .segment "PRGRAM"

bomb_entities: .res ::MAX_ACTIVE_BOMBS * .sizeof(BombState)

LastPartyBombCol: .res 1
LastPartyBombRow: .res 1

        .segment "ENEMY_BOMB_SPELL"

.proc FAR_init_bomb_state
        lda #0
        .repeat ::MAX_ACTIVE_BOMBS, i
        sta bomb_entities + BombState::Flags + (i * .sizeof(BombState))
        .endrepeat
        sta LastPartyBombCol
        sta LastPartyBombRow
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
        lda current_save + SaveFile::PlayerBombCount
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
        perform_zpcm_inc

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
        lda current_save + SaveFile::PlayerEquipmentBombs
        cmp #ITEM_BOMB_STANDARD
        beq standard
        ; TODO: other bomb types here

        ; If we arrive here, something went wrong. Do not spawn
        ; a weird bomb, cancel the hoist! (the metasprite was never
        ; marked as active and will self-cancel here)
        lda #$FF
        rts
standard:
        ; What this should be
        lda #BOMB_STATE_STANDARD_INIT
        sta bomb_entities + BombState::State, x
        jmp done_picking_state
done_picking_state:

.if ::DEBUG_GOD_MODE
        ; Do not decrement the bomb counter! Infinite bombs for testing, yes yes
.else
        ; At this point the bomb *definitely* succeeded in spawning.
        ; Hoist the bomb! Decrement the counter and initialize all the things
        dec PlayerBombCount
        ; If this was our last bomb, clear the item slot
        lda PlayerBombCount
        bne more_bombs_remain
        lda #ITEM_NONE
        sta PlayerEquipmentBombs
more_bombs_remain:
.endif

        ; Now we may initialize the rest of the bomb state
        lda #BOMB_FLAG_ACTIVE
        sta bomb_entities + BombState::Flags, x

        lda MetaSpriteIndex
        sta bomb_entities + BombState::MetaspriteIndex, x
        lda #0
        sta bomb_entities + BombState::FuseDuration, x
        sta bomb_entities + BombState::FrameCounter, x
        sta bomb_entities + BombState::PartyCounter, x
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
        set_static_02_sprite_x SPRITE_STATIC_02_BOMB_STANDARD

        ; We're hoisting a bomb (successfully) so play an appropriate SFX
        queue_sfx_pulse1 sfx_hoist_pulse

        ; and... in theory that's it? ah, but we need to return the index
        lda NewBombIndex
        rts
.endproc

; 32 entries, slightly disfavoring the map edges
party_bomb_x_lut:
        .byte 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
        .byte 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
        .byte       4, 5, 6, 7, 8, 9, 10, 11
party_bomb_y_lut:
        .byte 2, 3, 4, 5, 6, 7, 8
        .byte 2, 3, 4, 5, 6, 7, 8
        .byte 2, 3, 4, 5, 6, 7, 8
        .byte 2, 3, 4, 5, 6, 7, 8
        .byte       4, 5, 6, 7

.proc FAR_spawn_party_bomb
MetaSpriteIndex := R0
TempCol := R1
TempRow := R2
WallAttempts := R3
OverlapAttempts := R4
NewBombIndex := R8
        perform_zpcm_inc
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
        
        lda #BOMB_STATE_PARTY_INIT
        sta bomb_entities + BombState::State, x
        jmp done_picking_state
done_picking_state:
        perform_zpcm_inc

        ; Generate a spawn location for the party. This two notable
        ; constraints:
        ;   - It should be within the bounds of the map, so the bomb
        ;       lands where its 3x3 blast radius can potentially hit
        ;       all 9 targets
        ;   - The bomb should try not to drop itself into a wall tile
        ; We can't stall here forever, so after a few attempts we'll
        ; drop the wall requirement, and after a few more attempts we'll
        ; accept whatever we rolled.
        lda #8
        sta WallAttempts
        lda #16
        sta OverlapAttempts
bomb_positioning_loop:
        perform_zpcm_inc
        prng_from_table_y
        and #$1F
        tay
        lda party_bomb_x_lut, y
        sta TempCol
        prng_from_table_y
        and #$1F
        tay
        lda party_bomb_y_lut, y
        sta TempRow
        ; First check to see if this is inside a wall tile
        lda WallAttempts
        beq wall_check_passed
        ldx TempRow
        lda tile_index_to_row_lut, x
        clc
        adc TempCol
        tax
        lda battlefield, x
        cmp #TILE_WALL
        bne wall_check_passed
        dec WallAttempts
        jmp bomb_positioning_loop
wall_check_passed:
        perform_zpcm_inc
        ; Next check to see if we are overlapping the 3x3 blast radius
        ; of the party bomb we spawned previously
        lda OverlapAttempts
        beq overlap_check_passed

        lda TempRow
        sec
        sbc LastPartyBombRow
        beq overlap_check_failed ; exact match
        cmp #1
        beq overlap_check_failed ; +1
        cmp #$FF
        beq overlap_check_failed ; -1

        lda TempCol
        sec
        sbc LastPartyBombCol
        beq overlap_check_failed ; exact match
        cmp #1
        beq overlap_check_failed ; +1
        cmp #$FF
        beq overlap_check_failed ; -1
        jmp overlap_check_passed
overlap_check_failed:
        dec OverlapAttempts
        jmp bomb_positioning_loop
overlap_check_passed:
        perform_zpcm_inc
        ; At this point we'll keep this bomb, so write its position out
        ; for the next check, and also into our struct for spawning
        ldx NewBombIndex
        lda TempRow
        sta LastPartyBombRow
        sta bomb_entities + BombState::CurrentRow, x
        lda TempCol
        sta LastPartyBombCol
        sta bomb_entities + BombState::CurrentCol, x

        ; And from here, proceed to spawn the bomb the same way as a hoist,
        ; minus the player holding business
        lda #BOMB_FLAG_ACTIVE
        sta bomb_entities + BombState::Flags, x

        lda MetaSpriteIndex
        sta bomb_entities + BombState::MetaspriteIndex, x
        lda #0
        sta bomb_entities + BombState::FuseDuration, x
        sta bomb_entities + BombState::FrameCounter, x
        sta bomb_entities + BombState::PartyCounter, x
        ; Initialize the bomb position to our chosen position
        perform_zpcm_inc
        jsr _set_bomb_target_coordinates
        jsr _snap_to_target_position
        perform_zpcm_inc
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
        set_static_02_sprite_x SPRITE_STATIC_02_BOMB_STANDARD

        ; Party bombs should play a cartoony "long fall" SFX
        queue_sfx_triangle sfx_cartoony_fall_tri

        perform_zpcm_inc

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
        .addr do_nothing          ; BOMB_STATE_PARTY_INIT
        .addr do_nothing          ; BOMB_STATE_PARTY_GROUNDED

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

; NOTE: Do not clobber R14-R15!
.proc throw_standard_bomb
        ; TODO: do we need to resync with the player position here? What if the
        ; player got shoved by an enemy?

        ldx PlayerHeldBombIndex
        ; Based on the player's current throw direction, move the bomb ahead 2 squares
        ; in that direction. But! Don't move the bomb off the edge of the map
        lda PlayerNextDirection
        cmp #PLAYER_DIRECTION_NORTH
        beq try_up
        cmp #PLAYER_DIRECTION_SOUTH
        beq try_down
        cmp #PLAYER_DIRECTION_EAST
        beq try_right
        cmp #PLAYER_DIRECTION_WEST
        beq try_left
        ; huh? well that's weird. cancel!
        rts
try_up:
        .repeat ::BOMB_STANDARD_THROW_DISTANCE
        jsr _nudge_up
        .endrepeat
        jmp done_moving
try_down:
        .repeat ::BOMB_STANDARD_THROW_DISTANCE
        jsr _nudge_down
        .endrepeat
        jmp done_moving
try_left:
        .repeat ::BOMB_STANDARD_THROW_DISTANCE
        jsr _nudge_left
        .endrepeat
        jmp done_moving
try_right:
        .repeat ::BOMB_STANDARD_THROW_DISTANCE
        jsr _nudge_right
        .endrepeat
        jmp done_moving
done_moving:
        ; Because we may have just moved, update our target coordinates
        jsr _set_bomb_target_coordinates
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
        ; Remove ourselves from the player's hands
        lda #$FF
        sta PlayerHeldBombIndex
        ; We threw successfully, so play an appropriate SFX
        queue_sfx_pulse1 sfx_throw_pulse
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
        .addr party_bomb_tick_fuse    ; BOMB_STATE_PARTY_INIT
        .addr party_bomb_tick_fuse    ; BOMB_STATE_PARTY_GROUNDED

.proc _bomb_trampoline
DispatchPtr := R0
        jmp (DispatchPtr) ; Wheeeee
.endproc

.proc FAR_tick_bomb_fuses
DispatchPtr := R0
CurrentBombIndex := R15

        ; Do not tick fuses while paused!
        ; (Frankly this is likely to become buggy; I'm tempted to suppress pausing
        ; while there is any active bomb or special effect going on)
        lda PlayerIsPaused
        beq not_paused
        perform_zpcm_inc
        rts
not_paused:

        lda #0
        sta CurrentBombIndex
fuse_tick_loop:
        perform_zpcm_inc
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
        perform_zpcm_inc
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
        perform_zpcm_inc
        ; If we've exceeded the fuse length, pretty much no matter what
        ; actual state we're in, EXPLODE on the spot. Otherwise, we're done
        lda bomb_entities + BombState::FuseDuration, x
        cmp #BOMB_STANDARD_FUSE_LENGTH
        bcs explode
        rts
explode:
        ; KA-BOOM!
        jsr _explode_3x3_here
        ; Play a suitable explosion SFX
        queue_sfx_pulse1_with_priority sfx_kaboom_pulse_1, #10
        queue_sfx_pulse2_with_priority sfx_kaboom_pulse_1, #10
        queue_sfx_noise_with_priority sfx_kaboom_noise, #10

        perform_zpcm_inc

        ; Have some screen shake, etc
        lda #2
        sta ScreenShakeDepth
        lda #8
        sta ScreenShakeSpeed
        sta ScreenShakeDecayCounter

        ; Cleanup: if we were held by the player, clear that
        lda PlayerHeldBombIndex
        cmp CurrentBombIndex
        bne not_currently_held
        lda #$FF
        sta PlayerHeldBombIndex
not_currently_held:
        ldx CurrentBombIndex
        ; Despawn our own metasprite
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; Mark ourselves as inactive
        lda #0
        sta bomb_entities + BombState::Flags, x
        ; And... that should be it.
        perform_zpcm_inc
        rts
.endproc

.proc party_bomb_tick_fuse
CurrentBombIndex := R15
        ldx CurrentBombIndex
        ; Always perform basic fuse management
        inc bomb_entities + BombState::FuseDuration, x
        lda #0
        sta bomb_entities + BombState::FrameCounter, x

        ; Cleanup: if we were held by the player, clear that
        ; (party bombs shouldn't normally be held, but they are for
        ; testing, so don't do dumb things)
        lda PlayerHeldBombIndex
        cmp CurrentBombIndex
        bne not_currently_held
        lda #$FF
        sta PlayerHeldBombIndex
not_currently_held:

        ; If we've exceeded the fuse length, pretty much no matter what
        ; actual state we're in, EXPLODE on the spot. Otherwise, we're done
        lda bomb_entities + BombState::FuseDuration, x
        cmp #BOMB_STANDARD_FUSE_LENGTH
        bcs explode
        rts
explode:
        ; KA-BOOM!
        jsr _explode_3x3_here
        ; Play a suitable explosion SFX
        queue_sfx_pulse1_with_priority sfx_kaboom_pulse_1, #10
        queue_sfx_pulse2_with_priority sfx_kaboom_pulse_1, #10
        queue_sfx_noise_with_priority sfx_kaboom_noise, #10

        ; Have some screen shake, etc. Not as much as a standard
        ; bomb, since these will be happening more frequently and the
        ; player will be reacting quite a bit
        lda #1
        sta ScreenShakeDepth
        lda #8
        sta ScreenShakeSpeed
        sta ScreenShakeDecayCounter

        ldx CurrentBombIndex
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
        .addr standard_bomb_party_init      ; BOMB_STATE_PARTY_INIT
        .addr standard_bomb_party_grounded  ; BOMB_STATE_PARTY_GROUNDED

.proc FAR_update_active_bombs
DispatchPtr := R0
CurrentBombIndex := R15

        lda #0
        sta CurrentBombIndex
update_loop:
        perform_zpcm_inc
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
        perform_zpcm_inc

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
        ; 31, as our lookup tables aren't longer than this
        ldx CurrentBombIndex
        lda bomb_entities + BombState::FrameCounter, x
        cmp #31
        bcs done_with_this_bomb
        inc bomb_entities + BombState::FrameCounter, x
        perform_zpcm_inc

        ; All standard bombs have the same coloration based on fuse
        ; length, so handle that here
        ldx CurrentBombIndex
        jsr _set_color_based_on_fuse_length_standard
        jsr _set_sprite_based_on_fuse_length_standard

done_with_this_bomb:

        lda CurrentBombIndex
        clc
        adc #.sizeof(BombState)
        sta CurrentBombIndex
        cmp #(::MAX_ACTIVE_BOMBS * .sizeof(BombState))
        bne update_loop
        perform_zpcm_inc
        rts
.endproc

; rise up from the player's position, as they'll be
; animating something of a "lift up item" thing.
; make it quick, no time for fluff at faster tempos
hoist_height_lut:
        .byte  0,  8, 12, 16, 18, 18, 17, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16

; A cute little bounce on the beat, don't overdo it
hold_height_lut:
        .byte 14, 14, 14, 15, 15, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16
        .byte 16, 16, 16, 16, 16, 16, 16, 16

; A delightful arc. The underlying lerp is quite
; fast, so don't go nuts with hangtime
toss_height_lut:
        .byte 18, 17, 12, 7, 2, 0, 2, 3
        .byte  1,  0,  0, 0, 0, 0, 0, 0
        .byte  0,  0,  0, 0, 0, 0, 0, 0
        .byte  0,  0,  0, 0, 0, 0, 0, 0

; Fall from way up in the SKY
; TODO: make this easing function suck less
party_height_lut:
        .byte 60,59,58,55,52,47,42,35
        .byte 28,19,10, 0, 5, 9,12,14
        .byte 15,15,14,11, 8, 4, 0, 3
        .byte  4, 4, 3, 1, 1, 1, 0, 0

fuse_tick_pal_lut:
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_RED
        .repeat 29
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .endrepeat

earth_shattering_pal_lut:
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_YELLOW
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .byte SPRITE_ACTIVE | SPRITE_PAL_PURPLE
        .repeat 20
        .byte SPRITE_ACTIVE | SPRITE_PAL_RED
        .endrepeat

.proc standard_bomb_update_init
CurrentBombIndex := R15
        ; setup sprite things!
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        set_static_02_sprite_y SPRITE_STATIC_02_BOMB_STANDARD
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
        sec
        sbc hoist_height_lut, y
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
        sec
        sbc hold_height_lut, y
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
        sec
        sbc toss_height_lut, y
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

.proc standard_bomb_party_init
CurrentBombIndex := R15
        ; setup sprite things!
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        set_static_02_sprite_y SPRITE_STATIC_02_BOMB_STANDARD
        lda #(SPRITE_ACTIVE | SPRITE_PAL_PURPLE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        ; Switch into "hoist" mode
        lda #BOMB_STATE_PARTY_GROUNDED
        sta bomb_entities + BombState::State, x
        ; And because we are hoisting already, run that state too
        jsr standard_bomb_party_grounded
        rts
.endproc

.proc standard_bomb_party_grounded
CurrentBombIndex := R15
        ; Apply our lerped position to the sprite, offset by the
        ; thrown height table
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda bomb_entities + BombState::CurrentPosX+1, x
        sta sprite_table + MetaSpriteState::PositionX, y
        lda bomb_entities + BombState::CurrentPosY+1, x
        ldy bomb_entities + BombState::PartyCounter, x
        sec
        sbc party_height_lut, y
        bcc off_top_of_screen
        jmp converge
off_top_of_screen:
        lda #$F8
converge:
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::PositionY, y
        ; update the party counter separately
        lda bomb_entities + BombState::PartyCounter, x
        clc
        adc #1
        cmp #31
        bcs done
        sta bomb_entities + BombState::PartyCounter, x
        ; and... that's it?
done:
        rts
.endproc

; X is the bomb index, etc
.proc _set_color_based_on_fuse_length_standard
        lda bomb_entities + BombState::FuseDuration, x
        beq hoist_pal
        cmp #3
        beq earth_shattering_pal
fuse_tick_pal:
        ldy bomb_entities + BombState::FrameCounter, x
        lda fuse_tick_pal_lut, y
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        rts
earth_shattering_pal:
        ldy bomb_entities + BombState::FrameCounter, x
        lda earth_shattering_pal_lut, y
        ldy bomb_entities + BombState::MetaspriteIndex, x
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        rts  
hoist_pal:
        ldy bomb_entities + BombState::MetaspriteIndex, x
        lda #(SPRITE_ACTIVE | SPRITE_PAL_PURPLE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, y
        rts
.endproc

; X is the bomb index, etc
.proc _set_sprite_based_on_fuse_length_standard
        lda bomb_entities + BombState::FuseDuration, x
        cmp #3
        beq earth_shattering_sprite
boring_sprite:
        ldy bomb_entities + BombState::MetaspriteIndex, x
        set_static_02_sprite_y SPRITE_STATIC_02_BOMB_STANDARD
        rts
earth_shattering_sprite:
        ldy bomb_entities + BombState::MetaspriteIndex, x
        set_static_02_sprite_y SPRITE_STATIC_02_BOMB_STANDARD_GROWING
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
        perform_zpcm_inc
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

pattern_3x3_lut:
        .byte <(-BATTLEFIELD_WIDTH - 1)
        .byte <(-BATTLEFIELD_WIDTH + 0)
        .byte <(-BATTLEFIELD_WIDTH + 1)
        .byte <(                 0 - 1)
        .byte <(                 0 + 0)
        .byte <(                 0 + 1)
        .byte <( BATTLEFIELD_WIDTH - 1)
        .byte <( BATTLEFIELD_WIDTH + 0)
        .byte <( BATTLEFIELD_WIDTH + 1)

.proc _explode_3x3_here
; Our current state
CurrentPatternIndex := R12
TargetPattern := R13
TargetAttribute := R14
CurrentBombIndex := R15
; For upstream explode func
AttackSquare := R3
; Upstream Clobbers:
; R0 - R2
EffectiveAttackSquare := R10
        
        ; For great testing, just explode 1x1 here. close enough?

        lda #<BG_TILE_EXPLOSION
        sta TargetPattern
        lda #>BG_TILE_EXPLOSION
        ora #PAL_AIR
        sta TargetAttribute
        lda #0
        sta CurrentPatternIndex

pattern_loop:
        perform_zpcm_inc
        ldx CurrentBombIndex
        ldy bomb_entities + BombState::CurrentRow, x
        lda row_number_to_tile_index_lut, y
        clc
        adc bomb_entities + BombState::CurrentCol, x
        ldy CurrentPatternIndex
        clc
        adc pattern_3x3_lut, y
        sta AttackSquare
        near_call FAR_explode_tile
        jsr draw_explosion_tile_here
no_explosion_tile:
        inc CurrentPatternIndex
        lda CurrentPatternIndex
        cmp #9
        bne pattern_loop
        perform_zpcm_inc
        rts
.endproc

PALETTE_MASK  := %11000000
LIGHTING_MASK := %00000011
CORNER_MASK   := %11111100

TOP_LEFT_BITS     := %00 ; not actually used
TOP_RIGHT_BITS    := %10
BOTTOM_LEFT_BITS  := %01
BOTTOM_RIGHT_BITS := %11

; Note: this is kinda slow! specialized
.proc draw_explosion_tile_here
TargetIndex := R3
TargetPattern := R13
TargetAttribute := R14

NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2
HighRowScratch := ActiveDrawingScratch+4
LowRowScratch := ActiveDrawingScratch+5

        perform_zpcm_inc

        ; If the current tile is a wall, skip drawing an explosion
        ; (todo: expand this for other problematic tiles as we encounter them)
        ldx TargetIndex
        lda battlefield, x
        cmp #TILE_WALL
        bne perform_draw
        rts
perform_draw:

        debug_color (TINT_G | LIGHTGRAY)

        ; init some scratch space
        lda #0
        sta HighRowScratch

        ; work out the high bits of the row, these are the top 4 bits of TargetIndex x64, so they
        ; are split across both nametable address bytes
        lda TargetIndex
        asl
        rol HighRowScratch
        asl
        rol HighRowScratch
        and #%11000000
        sta LowRowScratch
        ; now deal with the column, which here is x2 (we'll do a +32 later to skip over the row)
        lda TargetIndex
        asl
        and #%00011110
        ora LowRowScratch
        sta NametableAddr+0
        sta AttributeAddr+0

        lda active_battlefield
        bne second_nametable
        lda #$50
        ldy #$58
        jmp set_high_bytes
second_nametable:
        lda #$54
        ldy #$5C
set_high_bytes:
        ora HighRowScratch
        sta NametableAddr+1
        tya
        ora HighRowScratch
        sta AttributeAddr+1
        
        ; now actually draw the tile, here fixed to the TargetPattern we defined
        ldy #0

        ; top left tile
        lda TargetPattern
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ; ora #TOP_LEFT_BITS   ; this would be a nop
        sta (NametableAddr), y  ; store that to our regular nametable
        ; top-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora TargetAttribute  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny ; Y = Y + 1

        ; top right tile
        lda TargetPattern
        and #CORNER_MASK
        ora #TOP_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora TargetAttribute  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        
        ldy #32 ; skip to the start of the next row for this tile

        ; bottom left tile
        lda TargetPattern
        and #CORNER_MASK        ; clear out the low 2 bits, we'll use these to pick a corner tile
        ora #BOTTOM_LEFT_BITS
        sta (NametableAddr), y  ; store that to our regular nametable
        ; bottom-left attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits        
        ora TargetAttribute  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;
        iny

        ; bottom right tile
        lda TargetPattern
        and #CORNER_MASK
        ora #BOTTOM_RIGHT_BITS
        sta (NametableAddr), y
        ; top-right attribute
        lda (AttributeAddr), y
        and #LIGHTING_MASK      ; keep only lighting bits
        ora TargetAttribute  ; NEW apply palette and high tile bits
        sta (AttributeAddr), y  ;

        ; and with all that... we're done?
        debug_color LIGHTGRAY
        perform_zpcm_inc
        rts
.endproc
