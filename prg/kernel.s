        .setcpu "6502"

        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "coins.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "indicators.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "palette_cycler.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "static_screens.inc"
        .include "torchlight.inc"
        .include "ui.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .zeropage
GameMode: .res 2
FadeToGameMode: .res 2

ScreenShakeDepth: .res 1
ScreenShakeSpeed: .res 1
ScreenShakeDecayCounter: .res 1
PpuScrollX: .res 1
PpuScrollY: .res 1
PpuScrollNametable: .res 1

.segment "RAM"
CurrentBeatCounter: .res 1
LastBeat: .res 1
AccumulatedGameBeats: .res 2

PlayfieldBgHighBank: .res 1
PlayfieldObjHighBank: .res 1
HudBgHighBank: .res 1
HudObjHighBank: .res 1

ClearedRoomCooldown: .res 1
RoomTransitionType: .res 1

.segment "CODE_1"

; === Utility Functions ===
.proc wait_for_next_vblank
        debug_color 0
        inc GameloopCounter
@loop:
        perform_zpcm_inc
        lda LastNmi
        cmp GameloopCounter
        bne @loop
        rts
.endproc

; === Kernel Entrypoint ===
.proc FAR_kernel_game_loop
main_loop:
        debug_color LIGHTGRAY
        jsr run_kernel
        jmp main_loop
.endproc

.proc run_kernel
        ; whatever game mode we are currently in, run one loop of that and exit
        jmp (GameMode)
        ; the game state function will exit
.endproc

; === Special game mode: fade brightness to 0 and THEN run the next state ===
.proc fade_to_game_mode
        lda #0
        sta PpuScrollX
        sta PpuScrollY
        sta PpuScrollNametable

        lda #0
        sta TargetBrightness
        lda Brightness
        bne continue_waiting

        lda FadeToGameMode
        sta GameMode
        lda FadeToGameMode+1
        sta GameMode+1

continue_waiting:
        perform_zpcm_inc
        far_call FAR_update_brightness
        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc
        jsr update_beat_counters

        jsr wait_for_next_vblank
        rts
.endproc

; === Game Mode Functions Follow ===

.proc init_engine
        near_call FAR_init_settings

        far_call FAR_disable_all_oam_entries

        ; NORMAL: start on the title screen
        ; TODO: add the boxgirl productions logo, and any other "first run" screens here
        st16 GameMode, title_prep

        jsr wait_for_next_vblank
        rts
.endproc

.proc title_prep
LayoutPtr := R0
        ; setup the UI subsystem with the options screen layout
        st16 LayoutPtr, title_ui_layout
        far_call FAR_initialize_widgets

        ; the rest of UI subsystem prep is shared, so do that now
        st16 GameMode, initialize_ui_subsystem

        rts
.endproc

.proc options_prep
LayoutPtr := R0
        ; setup the UI subsystem with the options screen layout
        st16 LayoutPtr, options_ui_layout
        far_call FAR_initialize_widgets

        ; the rest of UI subsystem prep is shared, so do that now
        st16 GameMode, initialize_ui_subsystem

        rts
.endproc

.proc initialize_ui_subsystem
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK
        lda #1
        sta NmiSoftDisable

        ; Setup a fade to black into the target mode
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; clear FPGA RAM
        jsr clear_fpga_ram

        ; set up our usual extended attributes, which is necessary to properly
        ; display fonts
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG)
        sta LeftNametableAttr
        sta RightNametableAttr

        ; the UI subsystem may override this, but this'll be a sane starting set for testing
        far_call FAR_initialize_title_palettes
        far_call FAR_initialize_sprites
        set_raster_effect_safely #RASTER_EFFECT_NONE, #RASTER_FINALIZER_NONE, #0
        set_raster_playback_speed #1, #0

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, run_ui_subsystem
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000)
        sta PPUCTRL

        rts
.endproc

; shared runner for all UI screens using the widget system
; (the widget logic contains all customizations, that's the point)
.proc run_ui_subsystem
        jsr poll_input
        perform_zpcm_inc
        far_call FAR_draw_sprites
        perform_zpcm_inc
        far_call FAR_update_brightness
        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop

        far_call FAR_update_widgets
        jsr update_beat_counters_title

        jsr wait_for_next_vblank
        rts
.endproc

.proc game_end_screen_prep
        lda #0
        sta tempo_adjustment

        ; Play lovely silence while we're loading
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        jsr play_track
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; the end screens use typical 16x16 attributes for now, so set those up again
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG)
        sta LeftNametableAttr
        sta RightNametableAttr

        ; Jank: actually apply those right now, since the endscreen drawing routines
        ; expect to be able to use PPUDATA for some reason
        ; (they're getting redone soon)
        lda LeftNametableBank
        sta MAP_NT_A_BANK
        sta MAP_NT_C_BANK
        lda RightNametableBank
        sta MAP_NT_B_BANK
        sta MAP_NT_D_BANK
        lda LeftNametableAttr
        sta MAP_NT_A_CONTROL
        sta MAP_NT_C_CONTROL
        lda RightNametableAttr
        sta MAP_NT_B_CONTROL
        sta MAP_NT_D_CONTROL

        jsr clear_fpga_ram
        far_call FAR_initialize_sprites
        far_call FAR_init_game_end_screen
        far_call FAR_set_old_chr_exbg
        far_call FAR_initialize_title_palettes
        set_raster_effect_safely #RASTER_EFFECT_NONE, #RASTER_FINALIZER_NONE, #0
        set_raster_playback_speed #1, #0

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, run_game_end_screen
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000)
        sta PPUCTRL

        rts
.endproc

.proc run_game_end_screen
        jsr poll_input
        jsr update_beat_counters_title
        far_call FAR_draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        far_call FAR_update_game_end_screen

        jsr wait_for_next_vblank
        rts
.endproc

.proc game_prep
        ; copy the run seed before we use it to generate the game state
        ; (we'll display this in the debug HUD / game end screens, etc)
        ; TODO: if we're going to do fixed seed things, do that here?
        .repeat 4, i
        lda run_seed+i
        sta initial_run_seed+i
        .endrepeat

        lda #0
        sta tempo_adjustment
        lda #0
        sta RoomTransitionType

        ; play lovely silence while we load
        ; (this also ensures the music / beat counter are in a deterministic spot when we fade back in)
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        jsr play_track
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        far_call FAR_init_torchlight
        far_call FAR_init_coins

        ; the game screen uses ExAttr for palette access, so set that up here
        ; we'll start on the left nametable
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        sta RightNametableAttr

        ; set the game palette
        far_call FAR_initialize_game_palettes
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; copy the initial batch of graphics into CHR RAM
        jsr clear_fpga_ram
        far_call FAR_init_nametables

        ; Initially the game enables just the HUD and nothing else. Game logic
        ; will shift these around as necessary.

        set_raster_effect_safely #RASTER_EFFECT_NONE, #RASTER_FINALIZER_PLAIN_HUD, #0
        ; For debugging lag, let's turn on an expensive underwater-y distortion
        ; Later, let's have rooms specify this, kay? it's irritating to change the build just to see it
        ;set_raster_effect_safely #RASTER_EFFECT_UNDERWATER, #RASTER_FINALIZER_PLAIN_HUD, #0
        ;set_raster_effect_safely #RASTER_EFFECT_SLIDE_LEFT, #RASTER_FINALIZER_PLAIN_HUD, #30

        set_raster_playback_speed #1, #0
        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, game_init
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000)
        sta PPUCTRL

        ; because background slivers fetch from normal CHR during the palette swap for
        ; 3 slivers, make those 3 slivers blank tiles:
        lda #$FF
        sta MAP_CHR_1_LO

        rts
.endproc

.proc game_init
        lda #0
        sta LastBeat
        sta CurrentBeatCounter
        sta AccumulatedGameBeats
        sta AccumulatedGameBeats+1
        sta PlayfieldBgHighBank
        sta PlayfieldObjHighBank
        sta HudBgHighBank
        sta HudObjHighBank

        lda #$FF
        sta ClearedRoomCooldown

        ; For a new game, the player starts in zone 1-1
        ; TODO: we'll actually almost certainly load into the HUB world here,
        ; when we have that, and allow the hub exits to kick off the game proper.
        ; (from the kernel's point of view, the hub is standard gameplay)
        
        ;st16 PlayerZonePtr, zone_grasslands_floor_1
        ;st16 DestinationZonePtr, zone_grasslands_floor_1
        st16 PlayerZonePtr, zone_hub_world
        st16 DestinationZonePtr, zone_hub_world

        ; TODO: if we are in fixed seed mode, set that here.

        far_call FAR_initialize_sprites
        far_call FAR_init_hud
        far_call FAR_init_player

        st16 GameMode, zone_init
        rts
.endproc

.proc zone_init
        perform_zpcm_inc

        ; Generate proper mazes and randomize player, exit, and boss
        far_call FAR_init_floor
        far_call FAR_generate_rooms_for_floor

        ; We faded out to get here, so fade right back in
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        st16 GameMode, room_init
        rts
.endproc

; A standard, boring room init, no transition. This is typically
; our target after a floor transition (including the first spawn)
; but it can also be used after a fade to black
.proc room_init
        perform_zpcm_inc
        
        ; Load the current room (which is now pregenerated)
        far_call FAR_load_current_room

        ; If the music for this room has changed, get that queued up
        ; TODO: should we try to detect a track change and fade out early?
        far_call FAR_play_music_for_current_room

        ; Despawn any remnant sprites from the previous room
        ; (stuff like death sprites and item shadows)
        perform_zpcm_inc
        far_call FAR_despawn_unimportant_sprites
        perform_zpcm_inc

        ; As a hack, draw the entire floor right now (we don't have
        ; the usual active_queue to draw for us)
        ; This will cause a couple of frames of lag!
        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_A_inline
        far_call FAR_draw_battlefield_block_B_inline
        debug_color LIGHTGRAY
        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_C_inline
        far_call FAR_draw_battlefield_block_D_inline
        debug_color LIGHTGRAY
        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_E_inline
        debug_color LIGHTGRAY

        far_call FAR_reset_price_tracker

        st16 GameMode, beat_frame_1
        rts
.endproc

; All sliding transitions put the active nametable at $2000
; and the inactive nametable at $2400, with matching exattr.
; we'll restore single-screen mirroring at the end when we
; process the first gameloop
.proc setup_nametables_for_slide_transition
        lda active_battlefield
        bne right_nametable_active
left_nametable_active:
        lda #0
        sta LeftNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        lda #1
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta RightNametableAttr
        rts
right_nametable_active:
        lda #1
        sta LeftNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        lda #0
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta RightNametableAttr
        rts
.endproc

.proc reset_nametables_post_transition
        lda active_battlefield
        bne right_nametable_active
left_nametable_active:
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        sta RightNametableAttr
        rts
right_nametable_active:
        lda #1
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        sta RightNametableAttr
        rts
.endproc

; indexed by the number of frames we want the slide effect to complete in
; (not really useful for anything else)
slide_speed_lut_high:
        .byte  31, 15, 10,  7,  6,  5,  4,  3,  3,  3,  2,  2,  2,  2,  2,  1
        .byte   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0
        .byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        .byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
slide_speed_lut_low:
        .byte   0,128, 85,192, 51, 42,109,224,113, 25,209,149, 98, 54, 17,240
        .byte 210,184,161,140,121,104, 89, 74, 61, 49, 37, 27, 17,  8,  0,248
        .byte 240,233,226,220,214,208,203,198,193,188,184,180,176,172,168,165
        .byte 161,158,155,152,149,146,144,141,139,136,134,132,130,128,125,124

.proc set_slide_speed
        ; the slide should complete in around 75% of the duration of one frame
        ; this gives the 3 frames of wiggle room for early setup, and the remaining
        ; 25% of beat timing room for the player to send in their next input
        
        ; note that beat length caps out at 63, so this math should be safeish
        lda TrackedBeatLength
        lsr ; 50%
        ;clc
        ;adc TrackedBeatLength ; 150%
        ;lsr ; 75%

        ; sanity checks: if we are below about 4 frames, clamp there
        cmp #4
        bcs not_too_low
        lda #4
not_too_low:
        ; if we have escaped the bounds of the table (how!?) reel it in
        cmp #63
        bcc not_too_high
        lda #63
not_too_high:
        ; index into the speed table and set the thing
        tax
        set_raster_playback_speed {slide_speed_lut_high, x}, {slide_speed_lut_low, x}
        rts
.endproc

; A transition! How exciting...
; Note: this is now functionally identical to room init in the default case. Maybe remove
; the former?
.proc room_transition
        ; Load the current room (which is now pregenerated)
        far_call FAR_load_current_room

        ; switch music track/variant if necessary
        far_call FAR_play_music_for_current_room

        ; Despawn any remnant sprites from the previous room
        ; (stuff like death sprites and item shadows)
        perform_zpcm_inc
        far_call FAR_despawn_unimportant_sprites
        perform_zpcm_inc

        far_call FAR_reset_price_tracker

        ; Draw the entire target floor right now!
        ; This will cause a couple of frames of lag. We should
        ; measure the time this takes and compensate for it with
        ; the scroll split timings

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_A_inline
        far_call FAR_draw_battlefield_block_B_inline
        debug_color LIGHTGRAY
        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_C_inline
        far_call FAR_draw_battlefield_block_D_inline
        debug_color LIGHTGRAY
        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_E_inline
        debug_color LIGHTGRAY

        ; TODO: figure out what we're going to do about torchlight here
        ; Do we need to wait for vblank here? (probably?)

detect_transition_type:
        lda RoomTransitionType
        cmp #ROOM_TRANSITION_SLIDE_RIGHT
        beq setup_slide_right
        cmp #ROOM_TRANSITION_SLIDE_LEFT
        beq setup_slide_left
        cmp #ROOM_TRANSITION_SLIDE_DOWN
        jeq setup_slide_down
        cmp #ROOM_TRANSITION_SLIDE_UP
        jeq setup_slide_up
        ; This is an unrecognized transition type! Fall back to a standard init and
        ; do not attempt any bespoke transition. (Later: can we choose a default here
        ; anyway? a fade to black would be less awful than intentional jank)

        ; ... but for now, treat it like a room init
        jmp setup_default_transition
setup_slide_right:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_RIGHT, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_room_transition
        rts
setup_slide_left:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_LEFT, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_room_transition
        rts
setup_slide_down:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_DOWN, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_room_transition
        rts
setup_slide_up:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_UP, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_room_transition
        rts

setup_default_transition:
        ; No transition at all! Instantly load that room, jank and all. This is the usual
        ; target after a floor init, as the "fade the palette in" logic hides the seams, and
        ; we tend to spawn in a cleared room anyway.
        lda #0
        sta SuppressTorchlight
        st16 GameMode, beat_frame_1
        rts
.endproc

; Ha, this needs to do a dozen other things too, but ignore all that for now
.proc wait_for_room_transition
        lda RasterEffectFrame
        cmp #30
        bne continue_waiting
        ; catchup ALL the torchlight, right now!
        far_call FAR_catchup_and_finalize_torchlight_raster_slide
        ; finalize the player and prepare for the next gameplay frame
        far_call FAR_finalize_player_pos_after_slide
        ; TODO: should we set the target nametable to both slots here? otherwise
        ; a laggy beat_frame_1 seems to briefly render the wrong nametable at
        ; fast tempo. Investigate!

        set_raster_effect_safely #RASTER_EFFECT_NONE, #RASTER_FINALIZER_PLAIN_HUD, #0
        ; For great debugging!
        ;set_raster_effect_safely #RASTER_EFFECT_UNDERWATER, #RASTER_FINALIZER_PLAIN_HUD, #0

        set_raster_playback_speed #1, #0
        lda #0
        sta SuppressTorchlight
        st16 GameMode, beat_frame_1
        rts
continue_waiting:
        ; TODO: update torchlight seams here! (do this as many times as we can afford)
        ; (right now we're testing with 6 calls, which is rather conservative!)
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_update_torchlight_over_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater
        debug_color LIGHTGRAY

        ; This is most of every_gameloop, but with some alterations and omissions to help the transition out
        jsr poll_input

        perform_zpcm_inc
        jsr update_beat_counters
        perform_zpcm_inc

        perform_zpcm_inc
        far_call FAR_queue_hud
        perform_zpcm_inc

        far_call FAR_determine_player_intent
        far_call FAR_draw_player
        far_call FAR_correct_player_pos_during_slide
        perform_zpcm_inc

        debug_color (TINT_G | TINT_B | LIGHTGRAY)
        far_call FAR_draw_sprites
        debug_color LIGHTGRAY

        far_call FAR_update_coins
        far_call FAR_update_indicators

        perform_zpcm_inc
        far_call FAR_update_brightness
        perform_zpcm_inc

        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc

        jsr update_screen_shake
        perform_zpcm_inc

        jsr wait_for_next_vblank
        rts
.endproc

.proc advance_to_next_floor
        ; The exit condition that sent us here will have set a destination,
        ; so load that in
        mov16 PlayerZonePtr, DestinationZonePtr

        ; reset the player's position to the center of the room
        lda #6
        sta PlayerRow
        lda #7
        sta PlayerCol
        ; take away the player's key
        lda #0
        sta PlayerKeys
        ; We faded out to get here, so fade back in
        lda #0
        sta set_brightness
        lda #4
        sta TargetBrightness

        ; Now run the regular zone init logic from here
        st16 GameMode, zone_init

        rts
.endproc

.proc beat_frame_1
        perform_zpcm_inc

        ; reset animation tracking to the start of the musical row
        MACRO_reset_gameplay_position

        ; - Swap the active and inactive buffers
        far_call FAR_swap_battlefield_buffers

        ; Reset special effects that depend on the current beat
        far_call FAR_reset_palette_cycler

        perform_zpcm_inc

        ; Set the next kernel mode early; the player might override this
        st16 GameMode, update_enemies_1

        ; - Resolve the player's action
        debug_color (TINT_B | LIGHTGRAY)
        far_call FAR_update_player
        far_call FAR_update_room_state
        debug_color LIGHTGRAY

        perform_zpcm_inc
        far_call FAR_reset_hearts_for_beat
        perform_zpcm_inc
        
        inc16 AccumulatedGameBeats
        inc CurrentBeatCounter
        lda CurrentBeat
        sta LastBeat

        ; - Queue up any changed squares to the **active** buffer
        ; - Begin playback of any sprite animations (?)

        perform_zpcm_inc
        far_call FAR_age_sprites
        perform_zpcm_inc
        far_call FAR_refresh_hud
        perform_zpcm_inc
        jsr every_gameloop
        rts
.endproc

.proc update_enemies_1
StartingRow := R14
StartingTile := R15

        debug_color (TINT_B | TINT_R | LIGHTGRAY)

        far_call FAR_reset_price_tracker
        perform_zpcm_inc

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_clear_active_move_flags
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #0
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 0)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #1
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 1)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #2
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 2)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, update_enemies_2
        rts
.endproc

.proc update_enemies_2
StartingRow := R14
StartingTile := R15

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #4
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 4)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #5
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 5)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #6
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 6)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, update_enemies_3
        rts
.endproc

.proc update_enemies_3
StartingRow := R14
StartingTile := R15

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #7
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 7)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #8
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 8)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #9
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 9)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #10
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 10)
        sta StartingTile
        far_call FAR_update_static_enemy_row
        debug_color LIGHTGRAY

        ; Now that we have run all enemy logic, it is safe to run clear checks and such
        lda #0
        sta first_beat_after_load

        jsr every_gameloop
        st16 GameMode, draw_battlefield_A
        rts
.endproc

.proc draw_battlefield_A
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_A_inline
        far_call FAR_draw_battlefield_block_B_inline
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, draw_battlefield_B
        rts
.endproc

.proc draw_battlefield_B
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_C_inline
        far_call FAR_draw_battlefield_block_D_inline
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, draw_battlefield_C
        rts
.endproc


.proc draw_battlefield_C
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_E_inline
        debug_color LIGHTGRAY

        far_call FAR_draw_prices

        jsr every_gameloop
        st16 GameMode, decide_how_to_wait_for_the_next_beat
        rts
.endproc

.proc decide_how_to_wait_for_the_next_beat
        lda current_clear_status
        and previous_clear_status
        beq room_not_cleared
room_cleared:
        st16 GameMode, wait_for_the_next_cleared_room_beat
        rts
room_not_cleared:
        lda setting_game_mode
        cmp #GAME_MODE_PATIENT
        beq patient_mode
standard_mode:
        st16 GameMode, wait_for_the_next_standard_gameplay_beat
        rts
patient_mode:
        st16 GameMode, wait_for_the_next_indefinite_gameplay_beat
        rts
.endproc

.proc wait_for_the_next_cleared_room_beat
        ; If the player's input has arrived...
        lda PlayerNextDirection
        ora PlayerIntendsToPause
        ora PlayerIntendsToWait
        ora PlayerIntendsToBomb
        ora PlayerIntendsToCast
        ; ... then go ahead and process this beat!
        jne player_input_forces_a_beat

        ; Firstly, if the next beat haven't arrived yet, do nothing
        lda CurrentBeat
        cmp LastBeat
        beq continue_waiting

        ; Second, to work around a beat alignment problem that can eat player inputs,
        ; if the player has forced an update less than a quarter of one beat (+8 frames) ago,
        ; refuse to advance

        lda TrackedBeatLength
        lsr ; divide by 2
        lsr ; divide by 4 !?
        cmp ClearedRoomCooldown
        bcs cooldown_forces_us_to_wait

        ; otherwise, on this beat boundary, advance!
        jmp process_next_beat_now

cooldown_forces_us_to_wait:
        lda CurrentBeat
        sta LastBeat

continue_waiting:
        inc ClearedRoomCooldown
        bne cooldown_is_fine
        lda #$FF
        sta ClearedRoomCooldown
cooldown_is_fine:
        ; We have LOTS of time on this particular frame, so update the torchlight a whole
        ; heck of a bunch to catch it up with the player's current location
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        jsr every_gameloop
        rts
player_input_forces_a_beat:
        lda #0
        sta ClearedRoomCooldown
process_next_beat_now:
        st16 GameMode, beat_frame_1
        rts ; right now!
.endproc

.proc wait_for_the_next_standard_gameplay_beat
        ; when we transition from standard -> cleared, do take the first on-beat
        ; transition right away. this eliminates a delay cycle with disco tiles still
        ; visible
        lda #$FF
        sta ClearedRoomCooldown

        ; If it's not time for the next beat yet, then continue waiting no matter what
        lda CurrentBeat
        cmp LastBeat
        beq continue_waiting
        ; The time for the next beat has come.
        ; If the player's input HAS arrived:
        lda PlayerNextDirection
        ora PlayerIntendsToPause
        ora PlayerIntendsToWait
        ora PlayerIntendsToBomb
        ora PlayerIntendsToCast
        beq no_input_received
input_received:
        ; Then immediatly process this beat
        jmp process_next_beat_now
no_input_received:        
        ; The player's input might arrive late, so give them some time. If we get to
        ; an actual row of 2 or more, THEN process the beat without waiting any longer:
        lda CurrentRowForMode
        and #%00000111
        cmp #2
        bcs process_next_beat_now
        ; Otherwise let the whole engine lag while the player makes up their damned mind :)
        jmp continue_waiting
process_next_beat_now:
        st16 GameMode, beat_frame_1
        rts ; do that now
continue_waiting:
        ; We have LOTS of time on this particular frame, so update the torchlight a whole
        ; heck of a bunch to catch it up with the player's current location
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY

        jsr every_gameloop
        rts
.endproc

.proc wait_for_the_next_indefinite_gameplay_beat
        ; when we transition from standard -> cleared, do take the first on-beat
        ; transition right away. this eliminates a delay cycle with disco tiles still
        ; visible
        lda #$FF
        sta ClearedRoomCooldown

        ; Process a beat transition whenever. We are not synced to the rhythm at all!
        ; If the player's input HAS arrived:
        lda PlayerNextDirection
        ora PlayerIntendsToPause
        ora PlayerIntendsToWait
        ora PlayerIntendsToBomb
        ora PlayerIntendsToCast
        beq continue_waiting
input_received:
        ; Then immediatly process this beat
        st16 GameMode, beat_frame_1
        rts ; do that now
continue_waiting:
        ; Unlike the standard mode, we will continue waiting *indefinitely.* The whole game
        ; pauses here and patiently waits for our input, whenever it arrives

        ; We have LOTS of time on this particular frame, so update the torchlight a whole
        ; heck of a bunch to catch it up with the player's current location
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY

        jsr every_gameloop
        rts
.endproc

.proc every_gameloop
        jsr poll_input

        perform_zpcm_inc
        jsr update_beat_counters
        perform_zpcm_inc

        far_call FAR_update_palette_cycler

        perform_zpcm_inc
        far_call FAR_queue_hud
        perform_zpcm_inc
        far_call FAR_determine_player_intent
        far_call FAR_draw_player
        perform_zpcm_inc

        debug_color (TINT_G | TINT_B | LIGHTGRAY)
        far_call FAR_draw_sprites
        debug_color LIGHTGRAY

        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_update_torchlight
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY

        far_call FAR_update_coins
        far_call FAR_update_indicators

        perform_zpcm_inc
        far_call FAR_update_brightness
        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc
        jsr update_screen_shake
        perform_zpcm_inc

        ; this stops the incompletely-drawn active battlefield from being displayed
        ; if we lag on the first frame of a new beat, which can mostly occur during
        ; room transitions
        lda active_battlefield
        bne right_nametable
left_nametable:
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        sta RightNametableAttr
        jmp done_with_nametables
right_nametable:
        lda #1
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta LeftNametableAttr
        sta RightNametableAttr
done_with_nametables:
        jsr wait_for_next_vblank
        rts
.endproc

; Utility Functions

.proc update_beat_counters_title
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta PlayfieldBgHighBank
        sta PlayfieldObjHighBank
        ; the title screen doesn't actually use these, but we
        ; still might as well update them. maybe it will gain a palette
        ; swap later?
        sta HudBgHighBank
        sta HudObjHighBank

        rts
.endproc

.proc update_beat_counters
        ; for the HUD, we'll always sync directly to the music, no funny business
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta HudBgHighBank
        sta HudObjHighBank

        ; how we determine the beat sync for the playfield depends on the current game mode,
        ; so check that here
        lda PlayerIsPaused
        bne paused_gameplay
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq normal_gameplay
cleared_gameplay:
        ; when the room is clear, the background always tracks the music regardless of what the player is doing.
        ; this helps prevent the player's off-tempo movements from causing animation glitchiness in otherwise
        ; static elements (like flickering torchlight, dancing flowers, etc)
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta PlayfieldBgHighBank
        ; the sprite layer meanwhile continues to follow the player
        ldx TrackedGameplayPos
        lda tracked_animation_frame, x
        sta PlayfieldObjHighBank
        rts
normal_gameplay:
        ; when the room is not clear, everything tracks the gameplay timing so the player and enemies
        ; remain in perfect sync, even if the player's inputs are a little late
        ldx TrackedGameplayPos
        lda tracked_animation_frame, x
        sta PlayfieldBgHighBank
        sta PlayfieldObjHighBank
        rts
paused_gameplay:
        ; During a pause state, the sprite layer continues to update (so the player's idle animaton works)
        ; but the background layer is permanently frozen on frame 0, freezing enemies in place
        lda #0
        sta PlayfieldBgHighBank
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta PlayfieldObjHighBank
        rts
.endproc

.proc update_screen_shake
DepthTemp := R0
RandTemp := R1
        lda ScreenShakeDepth
        beq no_screen_shake
        lda #8
        sec
        sbc ScreenShakeDepth
        sta DepthTemp

        ; X can use the rand value almost directly
        jsr next_gameplay_rand
        perform_zpcm_inc
        sta RandTemp
        ldx DepthTemp
x_loop:
        lsr
        dex
        bne x_loop
        bit RandTemp
        bmi minus_x
positive_x:
        ldx #0
        stx PpuScrollNametable
        jmp done_with_x
minus_x:
        eor #$FF
        clc
        adc #1
        ldx #1
        stx PpuScrollNametable
done_with_x:
        sta PpuScrollX

        ; Y should remain in the range 0-240, so the minus case is handled diffrently
        jsr next_gameplay_rand
        perform_zpcm_inc
        sta RandTemp
        ldx DepthTemp
y_loop:
        lsr
        dex
        bne y_loop
        bit RandTemp
        bmi minus_y
        jmp done_with_y
minus_y:
        sta RandTemp
        lda #239
        sec
        sbc RandTemp
done_with_y:
        sta PpuScrollY

        ; Now process the decay speed for this screen shake
        dec ScreenShakeDecayCounter
        bne done
        dec ScreenShakeDepth
        lda ScreenShakeSpeed
        sta ScreenShakeDecayCounter
done:
        rts

no_screen_shake:
        lda #0
        sta PpuScrollX
        sta PpuScrollY
        sta PpuScrollNametable
        rts
.endproc