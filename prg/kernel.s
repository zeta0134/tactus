        .setcpu "6502"

        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "bombs.inc"
        .include "coins.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "indicators.inc"
        .include "input.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "main.inc"
        .include "nes.inc"
        .include "palette_cycler.inc"
        .include "particles.inc"
        .include "player.inc"
        .include "player_distance.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "saves.inc"
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
ScreenShakeX: .res 1
ScreenShakeY: .res 1

.segment "RAM"
CurrentBeatCounter: .res 1
LastBeat: .res 1
AccumulatedGameBeats: .res 2

PlayfieldBgHighBank: .res 1
PlayerObjHighBank: .res 1      ; for sprite banks that should be synced to the player when off-beat
PlayfieldBgObjHighBank: .res 1 ; for sprite animations that should be synced to the background, always
HudBgHighBank: .res 1
HudObjHighBank: .res 1 ; ditto

ClearedRoomCooldown: .res 1
RoomTransitionType: .res 1

PlayfieldObjBanks: .res 16
HudObjBanks: .res 8

HeldInputCooldown: .res 1
WarpTransitionTimer: .res 1

CurrentlyActiveSpell: .res 1
MonsterRequestsSpellCast: .res 1

.segment "CODE_KERNEL"

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
.proc fade_to_game_mode_from_gameplay
        lda #0
        sta ScreenShakeX
        sta ScreenShakeY

        lda #BRIGHTNESS_FULLY_DARK
        sta TargetBrightness
        lda Brightness
        cmp #BRIGHTNESS_FULLY_DARK
        bne continue_waiting

        lda FadeToGameMode
        sta GameMode
        lda FadeToGameMode+1
        sta GameMode+1

continue_waiting:
        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc
        jsr update_beat_counters

        jsr wait_for_next_vblank
        rts
.endproc

; === Special game mode: fade brightness to 0 and THEN run the next state ===
.proc fade_to_game_mode_from_ui
        lda #0
        sta ScreenShakeX
        sta ScreenShakeY

        lda #BRIGHTNESS_FULLY_DARK
        sta TargetBrightness
        lda Brightness
        cmp #BRIGHTNESS_FULLY_DARK
        bne continue_waiting

        lda FadeToGameMode
        sta GameMode
        lda FadeToGameMode+1
        sta GameMode+1

continue_waiting:
        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc
        ; jsr update_beat_counters_title

        jsr wait_for_next_vblank
        rts
.endproc

; === Game Mode Functions Follow ===

.proc init_engine
        lda #BRIGHTNESS_FULLY_DARK
        jsr set_brightness
        lda #BRIGHTNESS_FULLY_DARK
        sta TargetBrightness
        ; We'll be in UI mode to start with, so use that as our initial fade speed
        lda #FADE_SPEED_UI
        sta GlobalFadeSpeed

        lda #0
        .repeat 16, i
        sta PlayfieldObjBanks + i
        .endrepeat
        .repeat 8, i
        sta HudObjBanks + i
        .endrepeat

        far_call FAR_disable_all_oam_entries_playfield
        far_call FAR_disable_all_oam_entries_hud

        far_call FAR_init_save_subsystem
        far_call FAR_compute_player_colors

        ; NORMAL: start on the title screen
        ; TODO: add the studio logo, and any other "first run" screens here
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

.proc file_select_prep
LayoutPtr := R0
        ; setup the UI subsystem with the options screen layout
        st16 LayoutPtr, file_select_ui_layout
        far_call FAR_initialize_widgets

        ; the rest of UI subsystem prep is shared, so do that now
        st16 GameMode, initialize_ui_subsystem

        rts
.endproc

.proc name_entry_prep
LayoutPtr := R0
        ; setup the UI subsystem with the options screen layout
        st16 LayoutPtr, name_entry_ui_layout
        far_call FAR_initialize_widgets

        ; the rest of UI subsystem prep is shared, so do that now
        st16 GameMode, initialize_ui_subsystem

        rts
.endproc

.proc file_details_prep
LayoutPtr := R0
        ; setup the UI subsystem with the options screen layout
        st16 LayoutPtr, file_details_ui_layout
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

        ; Clear this out in case some other UI subscreen fiddled with it (title mostly)
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000 | OBJ_8X16 | NT_2000)
        sta DesiredPpuCtrl
        lda #0
        jsr set_hi_chr_bank

        ; Setup a fade to black into the target mode
        ; NO! This was causing us to draw before the controller had a chance
        ; to fully initialize itself. Each controller widget will be in charge
        ; of deciding when to run this logic.

        ; clear FPGA RAM
        jsr clear_fpga_ram

        ; Most UI screens use standard 512-byte banking windows, exceptions will switch
        ; modes in widget logic
        lda #(CHR_CHIP_ROM | CHR_MODE_4)
        sta MAP_CHR_CONTROL

        ; set up our usual extended attributes, which is necessary to properly
        ; display fonts
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG)
        sta LeftNametableAttr
        sta RightNametableAttr

        ; make sure to clear any leftover HUD sprites, if we are entering
        ; from the game world
        far_call FAR_disable_all_oam_entries_hud

        ; the UI subsystem may override this, but this'll be a sane starting set for testing
        far_call FAR_initialize_title_palettes
        far_call FAR_initialize_sprites
        set_raster_effect_safely #RASTER_EFFECT_NONE, #RASTER_FINALIZER_NONE, #0
        set_raster_playback_speed #1, #0

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        ; Set the initial color emphasis to none (which the UI controllers
        ; may of course override at their leisure)
        lda #0
        far_call FAR_apply_room_global_color_emphasis

        ; Set the initial sprite banks for the UI, which will animate as usual
        jsr set_ui_banks

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
        far_call FAR_refresh_palettes_gameloop

        jsr update_beat_counters_title

        far_call FAR_update_widgets

        jsr wait_for_next_vblank
        rts
.endproc

; TODO: remove this entirely, make it a UI subscreen instead
.proc game_end_screen_prep
        lda #0
        sta tempo_adjustment

        ; Play lovely silence while we're loading
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        far_call FAR_play_track
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        lda #BRIGHTNESS_FULLY_DARK
        jsr set_brightness
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness

        ; the end screens use typical 16x16 attributes for now, so set those up again
        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG)
        sta LeftNametableAttr
        sta RightNametableAttr

        ; make sure to clear any leftover HUD sprites, if we are entering
        ; from the game world
        far_call FAR_disable_all_oam_entries_hud

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
        far_call FAR_refresh_palettes_gameloop

        far_call FAR_update_game_end_screen

        jsr wait_for_next_vblank
        rts
.endproc

.proc set_gameplay_static_banks
        ; During main gameplay, we have a fixed set of static
        ; banks, so get those all loaded in. The rest are unspecified;
        ; other gameplay systems will set them as needed
        lda #>SPRITE_STATIC_00_PARTICLES_DARK_01
        sta SPRITE_BANK_STATIC_00
        lda #>SPRITE_STATIC_01_DAMAGE_FLASHING_SQUARE
        sta SPRITE_BANK_STATIC_01
        lda #>SPRITE_STATIC_02_BOMB_STANDARD
        sta SPRITE_BANK_STATIC_02
        lda #>SPRITE_STATIC_03_PLACEHOLDER
        sta SPRITE_BANK_STATIC_03
        lda #>SPRITE_STATIC_04_PLACEHOLDER
        sta SPRITE_BANK_STATIC_04
        lda #>SPRITE_STATIC_05_PLACEHOLDER
        sta SPRITE_BANK_STATIC_05
        lda #>SPRITE_STATIC_06_PLACEHOLDER
        sta SPRITE_BANK_STATIC_06
        lda #>SPRITE_STATIC_07_DISKETTE
        sta SPRITE_BANK_STATIC_07

        lda #>SPRITE_HUD_STATIC_00_COUNTER_01S_01
        sta SPRITE_BANK_HUD_STATIC_00
        lda #>SPRITE_HUD_STATIC_01_COUNTER_10S_67
        sta SPRITE_BANK_HUD_STATIC_01
        lda #>SPRITE_HUD_STATIC_02_PLACEHOLDER
        sta SPRITE_BANK_HUD_STATIC_02
        lda #>SPRITE_HUD_STATIC_03_PLACEHOLDER
        sta SPRITE_BANK_HUD_STATIC_03
        lda #>SPRITE_HUD_STATIC_04_PLACEHOLDER
        sta SPRITE_BANK_HUD_STATIC_04
        lda #>SPRITE_HUD_STATIC_05_PLACEHOLDER
        sta SPRITE_BANK_HUD_STATIC_05
        rts
.endproc

.proc set_ui_banks
        ; For now, the UI uses an entirely fixed set of banks. Set all the others
        ; to "blank" to simplify raster splits if those are needed
        lda #>SPRITE_UI_00_MENU_CURSOR_SPIN
        sta SPRITE_BANK_UI_00
        sta SPRITE_BANK_UI_HUD_00
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_01
        sta SPRITE_BANK_UI_HUD_01
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_02
        sta SPRITE_BANK_UI_HUD_02
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_03
        sta SPRITE_BANK_UI_HUD_03
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_04
        sta SPRITE_BANK_UI_HUD_04
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_05
        sta SPRITE_BANK_UI_HUD_05
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_06
        sta SPRITE_BANK_UI_HUD_06
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_UI_07
        sta SPRITE_BANK_UI_HUD_07

        ; The UI shouldn't use the $1000 table at all, so blank
        ; that out entirely.
        lda #>SPRITE_000_BLANK_NOTHING
        sta SPRITE_BANK_STATIC_00
        sta SPRITE_BANK_STATIC_01
        sta SPRITE_BANK_STATIC_02
        sta SPRITE_BANK_STATIC_03
        sta SPRITE_BANK_STATIC_04
        sta SPRITE_BANK_STATIC_05
        sta SPRITE_BANK_STATIC_06
        sta SPRITE_BANK_STATIC_07
        rts
.endproc

.proc game_prep
        lda #0
        sta tempo_adjustment
        lda #0
        sta RoomTransitionType

        ; play lovely silence while we load
        ; (this also ensures the music / beat counter are in a deterministic spot when we fade back in)
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        far_call FAR_play_track
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        ; Make sure this is sane
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000 | OBJ_8X16 | NT_2000)
        sta DesiredPpuCtrl
        lda #0
        jsr set_hi_chr_bank

        far_call FAR_init_torchlight
        far_call FAR_init_coins

        ; During gameplay, we want our CHR ROM accessible in little tiny 512b chunks:
        lda #(CHR_CHIP_ROM | CHR_MODE_4)
        sta MAP_CHR_CONTROL

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
        lda #BRIGHTNESS_FULLY_DARK
        jsr set_brightness
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness

        ; copy the initial batch of graphics into CHR RAM
        jsr clear_fpga_ram
        far_call FAR_init_nametables

        ; Initially the game enables just the HUD and nothing else. Game logic
        ; will shift these around as necessary.
        jsr set_raster_effect_for_room

        jsr set_gameplay_static_banks

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
        sta PlayerObjHighBank
        sta PlayfieldBgObjHighBank
        sta HudBgHighBank
        sta HudObjHighBank
        sta MonsterRequestsSpellCast
        sta CurrentlyActiveSpell
        lda #4
        sta PlayfieldBgHighBank
        lda #FADE_SPEED_GAMEPLAY
        sta GlobalFadeSpeed

        lda #$FF
        sta ClearedRoomCooldown

        far_call FAR_initialize_sprites
        far_call FAR_init_player

        lda current_save + SaveFile::RunFlags
        and #RUN_FLAGS_SUSPENDED
        beq normal_load
suspended_load:
        ; We're loading a suspended game, so don't touch the player state. Just get
        ; that new zone loaded. (We'll clear the suspend flag later when re-saving after
        ; zone generation.) Note that we also leave the run seed alone, so that the
        ; un-suspended game in theory generates the same floor. (This may not work very
        ; well in practice while we are actively dev'ing on the procgen stuff, 
        ; but it shouldn't break anything.)
        lda current_save + SaveFile::PlayerZoneId
        jmp zone_select_converge
normal_load:
        ; For a new game, the player starts in the HUB world with a freshly
        ; cleared inventory.
        far_call FAR_init_player_inventory_new_game
        ; We also need to generate a new seed on the spot
        ; TODO: don't do this if the player is in fixed seed mode.
.if ::DEBUG_FORCE_SEED
        lda #.lobyte(.loword(DEBUG_SEED))
        sta current_save + SaveFile::RunSeed + 3
        lda #.hibyte(.loword(DEBUG_SEED))
        sta current_save + SaveFile::RunSeed + 2
        lda #.lobyte(.hiword(DEBUG_SEED))
        sta current_save + SaveFile::RunSeed + 1
        lda #.hibyte(.hiword(DEBUG_SEED))
        sta current_save + SaveFile::RunSeed + 0
.else
        jsr generate_run_seed_for_save
.endif

        lda #ZONE_HUB_WORLD
        ; fall through to converge
zone_select_converge:
        far_call FAR_set_zone_ptr_from_id
        mov16 DestinationZonePtr, PlayerZonePtr

        ; (The HUD depends on the seed we just generated, though it may not necessarily
        ; actually display it.)
        far_call FAR_init_hud

        st16 GameMode, zone_init
        rts
.endproc

.proc zone_init
        perform_zpcm_inc

        ; Clear out any gameplay state that will look odd over the zone transition
        .global FAR_init_particles

        lda #0
        sta HeldInputCooldown
        sta PlayerHeldDirection

        ; Generate proper mazes and randomize player, exit, and boss
        ; This **will** lag badly, so switch our beat tracker to update during NMI
        ; while we're busy with level gen. If we don't do this we get a strangely wrong
        ; first beat and break the heart counter.
        lda #1
        sta UpdateBeatTrackerDuringNmi
        far_call FAR_init_floor
        far_call FAR_generate_rooms_for_floor
        lda #0
        sta UpdateBeatTrackerDuringNmi

        ; Grab the zone we've just initialized and write it to the save file
        far_call FAR_get_zone_id_from_zone_ptr
        sta current_save + SaveFile::PlayerZoneId
        ; Also since we're loading into a new area, go ahead and clear the suspended flag.
        ; (we'll save again if we actually suspend.)
        lda current_save + SaveFile::RunFlags
        and #($FF - RUN_FLAGS_SUSPENDED)
        sta current_save + SaveFile::RunFlags

        ; Now that we've generated this floor, go ahead and save right here, as it is convenient
        ; to do so. This will be the "commit point" for any gameplay state unlocked during a given
        ; run, including in-game options the player might have tweaked. This includes loading into
        ; the game for the first time, as the HUB is a "floor" from the engine's point of view.
        far_call FAR_save_current_file

        ; We faded out to get here, so fade right back in
        lda #BRIGHTNESS_FULLY_DARK
        jsr set_brightness
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness
        lda #FADE_SPEED_GAMEPLAY
        sta GlobalFadeSpeed

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
        far_call FAR_init_room_coordination_state

        ; If the music for this room has changed, get that queued up
        ; TODO: should we try to detect a track change and fade out early?
        far_call FAR_play_music_for_current_room

        ; Despawn any remnant sprites from the previous room
        ; (stuff like death sprites and item shadows)
        perform_zpcm_inc
        far_call FAR_despawn_unimportant_sprites
        perform_zpcm_inc
        far_call FAR_init_item_bank_allocations
        perform_zpcm_inc

        ; Clear out any other lingering state
        far_call FAR_init_bomb_state
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

        jsr set_color_emphasis_for_room

        far_call FAR_reset_palette_warp_tile

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
        far_call FAR_init_room_coordination_state

        ; Set this room's color emphasis
        jsr set_color_emphasis_for_room

        ; switch music track/variant if necessary
        far_call FAR_play_music_for_current_room

        ; Despawn any remnant sprites from the previous room
        ; (stuff like death sprites and item shadows)
        perform_zpcm_inc
        far_call FAR_despawn_unimportant_sprites
        perform_zpcm_inc
        far_call FAR_init_item_bank_allocations
        perform_zpcm_inc

        ; Clear out any other lingering state
        far_call FAR_init_bomb_state
        perform_zpcm_inc

        far_call FAR_reset_price_tracker
        perform_zpcm_inc

        far_call FAR_reset_palette_warp_tile
        perform_zpcm_inc

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
        cmp #ROOM_TRANSITION_WARP_ENTRANCE
        jeq setup_warp_entrance
        cmp #ROOM_TRANSITION_WARP_EJECT
        jeq setup_warp_eject
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
        st16 GameMode, wait_for_sliding_room_transition
        rts
setup_slide_left:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_LEFT, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_sliding_room_transition
        rts
setup_slide_down:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_DOWN, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_sliding_room_transition
        rts
setup_slide_up:
        far_call FAR_reset_torchlight_raster_slide_updater
        far_call FAR_update_torchlight_over_raster_slide_updater ; just runs the init code
        jsr setup_nametables_for_slide_transition
        jsr set_slide_speed
        set_raster_effect_safely #RASTER_EFFECT_SLIDE_UP, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_sliding_room_transition
        rts
setup_warp_entrance:
        ; We'll be doing a fancy distortion but not showing the new screen right away.
        ; Also the target lighting mode is fully lit, so don't fuss about torchlight over
        ; the seam. If we get some glitchy jank for THESE transitions it kinda helps more
        ; than it hinders.
        lda #0
        sta SuppressTorchlight
        ; Over the warp transition we'll fade slowly to white!
        lda #BRIGHTNESS_FULLY_BRIGHT
        sta TargetBrightness
        lda #FADE_SPEED_WARP_ENTRANCE
        sta GlobalFadeSpeed
        lda #24
        sta BrightnessDelay
        ; reset our delay counter, etc
        lda #0
        sta WarpTransitionTimer
        ; TODO: something fancier than this
        set_raster_effect_safely #RASTER_EFFECT_WARP_IN, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_warp_entrance_room_transition
        rts

setup_warp_eject:
        ; We'll be doing a fancy distortion but not showing the new screen right away.
        ; Also the target lighting mode is fully lit, so don't fuss about torchlight over
        ; the seam. If we get some glitchy jank for THESE transitions it kinda helps more
        ; than it hinders.
        lda #0
        sta SuppressTorchlight
        ; When being ejected from the warp, we'll fade to black somewhat more quickly
        lda #BRIGHTNESS_FULLY_DARK
        sta TargetBrightness
        lda #6
        sta BrightnessDelay
        lda #FADE_SPEED_WARP_EXIT
        sta GlobalFadeSpeed
        ; reset our delay counter, etc
        lda #0
        sta WarpTransitionTimer
        ; TODO: if we're going to queue up a fancy "you got spat out of the warp" SFX,
        ; this would be the place to do it.
        ; For now, just a death spin will do
        queue_sfx_pulse1 sfx_death_spin_pulse
        queue_sfx_triangle sfx_death_spin_tri
        ; TODO: something fancier than this
        set_raster_effect_safely #RASTER_EFFECT_WARP_IN, #RASTER_FINALIZER_PLAIN_HUD, #30
        st16 GameMode, wait_for_warp_eject_room_transition
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

.proc wait_for_warp_entrance_room_transition
        inc WarpTransitionTimer
        lda WarpTransitionTimer
        cmp #90
        bne continue_waiting

        ; Force the player's position to the center of the new room
        lda #6
        sta PlayerCol
        sta PlayerRow

        ; Fade back down to regular brightness, and also reset the global fade speed
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness
        lda #3
        sta BrightnessDelay
        lda #FADE_SPEED_GAMEPLAY
        sta GlobalFadeSpeed

        jsr set_raster_effect_for_room

        set_raster_playback_speed #1, #0
        lda #0
        sta SuppressTorchlight
        st16 GameMode, beat_frame_1
        rts
continue_waiting:
        jmp _wait_for_transition_common

        rts
.endproc

.proc wait_for_warp_eject_room_transition
HealingAmount := R0

        inc WarpTransitionTimer
        lda WarpTransitionTimer
        cmp #30
        bne continue_waiting

        ; Force the player's position to the tile before they stepped into the warp portal
        lda PlayerWarpEjectCol
        sta PlayerCol
        lda PlayerWarpEjectRow
        sta PlayerRow

        ; Heal the player to full health, otherwise they may insta-die in the new location
        ; depending on what kicked them out
        lda #128
        sta HealingAmount
        far_call FAR_receive_healing

        ; Fade back up to regular brightness, and also reset the global fade speed
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness
        lda #3
        sta BrightnessDelay
        lda #FADE_SPEED_GAMEPLAY
        sta GlobalFadeSpeed

        jsr set_raster_effect_for_room

        set_raster_playback_speed #1, #0
        lda #0
        sta SuppressTorchlight
        st16 GameMode, beat_frame_1
        rts
continue_waiting:
        jmp _wait_for_transition_common

        rts
.endproc

; Ha, this needs to do a dozen other things too, but ignore all that for now
.proc wait_for_sliding_room_transition
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

        jsr set_raster_effect_for_room

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
        jmp _wait_for_transition_common
.endproc

.proc _wait_for_transition_common
        ; This is most of every_gameloop, but with some alterations and omissions to help the transition out
        jsr poll_input

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
        far_call FAR_draw_particles

        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc

        jsr update_screen_shake
        perform_zpcm_inc

        perform_zpcm_inc
        jsr update_beat_counters
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
        lda #BRIGHTNESS_FULLY_DARK
        sta set_brightness
        lda #BRIGHTNESS_NORMAL
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

        ; If a monster is requesting a spellcast, do that setup and set the
        ; appropriate game mode. (If the player casts their own spell, it will
        ; run after these take effect. Conflicts in mechanics resolve in the
        ; player's favor. Effects and SFX may overlap somewhat.)
        lda MonsterRequestsSpellCast
        beq no_monster_spells
        st16 GameMode, update_spells_1
        far_call FAR_monster_spellcasting_dispatch
no_monster_spells:
        lda #0
        sta MonsterRequestsSpellCast

        ; If any monsters deferred SFX to the start of the next beat, process those now
        ; TODO: should we clean these out between rooms or game modes?
        far_call FAR_queue_deferred_sounds

        ; - First, tick any non-player entities that need to update before
        ;   the player's inputs are processed
        far_call FAR_tick_bomb_fuses

        ; - Resolve the player's action
        debug_color (TINT_B | LIGHTGRAY)
        far_call FAR_update_player
        perform_zpcm_inc
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

        decrease_warp_stability_each_beat

        perform_zpcm_inc
        far_call FAR_age_sprites
        perform_zpcm_inc
        far_call FAR_refresh_hud
        perform_zpcm_inc
        jsr every_gameloop
        rts
.endproc

; Like update enemies in every sense, but we do the spellcasting logic instead
.proc update_spells_1
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

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #0
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 0)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #1
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 1)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #2
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 2)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

        jsr every_gameloop
        st16 GameMode, update_spells_2
        rts
.endproc

.proc update_spells_2
StartingRow := R14
StartingTile := R15

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #4
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 4)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #5
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 5)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #6
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 6)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

        jsr every_gameloop
        st16 GameMode, update_spells_3
        rts
.endproc

.proc update_spells_3
StartingRow := R14
StartingTile := R15

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #7
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 7)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #8
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 8)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #9
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 9)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #10
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 10)
        sta StartingTile
        far_call FAR_cast_spell_on_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

        lda #0
        sta MonsterRequestsSpellCast

        jsr every_gameloop
        st16 GameMode, draw_battlefield_A
        rts
.endproc

.proc update_enemies_1
StartingRow := R14
StartingTile := R15

        debug_color (TINT_B | TINT_R | LIGHTGRAY)

        far_call FAR_reset_price_tracker
        perform_zpcm_inc
        far_call FAR_init_beat_coordination_state
        perform_zpcm_inc

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_clear_active_move_flags
        debug_color LIGHTGRAY

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #0
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 0)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #1
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 1)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #2
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 2)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

        jsr every_gameloop
        st16 GameMode, update_enemies_2
        rts
.endproc

.proc update_enemies_2
StartingRow := R14
StartingTile := R15

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #4
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 4)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #5
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 5)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #6
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 6)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

        jsr every_gameloop
        st16 GameMode, update_enemies_3
        rts
.endproc

.proc update_enemies_3
StartingRow := R14
StartingTile := R15

        access_data_bank #<.bank(player_distance_luts)

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #7
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 7)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #8
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 8)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #9
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 9)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        debug_color (TINT_B | TINT_R | LIGHTGRAY)
        lda #10
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 10)
        sta StartingTile
        jsr FIXED_update_static_enemy_row
        debug_color LIGHTGRAY

        restore_previous_bank

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
        lda current_save + SaveFile::OptionRhythmMode
        cmp #GAME_MODE_PATIENT
        beq patient_mode
standard_mode:
        st16 GameMode, wait_for_the_next_standard_gameplay_beat
        rts
patient_mode:
        st16 GameMode, wait_for_the_next_indefinite_gameplay_beat
        rts
.endproc

.proc compute_synthetic_held_intent_cleared
SyntheticHeldIntent := R2
        lda PlayerHeldDirection
        beq not_holding_anything

        lda HeldInputCooldown
        cmp #$FF
        beq skip_inc
        inc HeldInputCooldown
skip_inc:

        ; For the held threshold in clear mode, we'll use
        ; the full duration of one entire musical beat
        lda HeldInputCooldown
        cmp TrackedBeatLength
        bcs threshold_met
threshold_not_met:
        lda #0
        sta SyntheticHeldIntent
        rts
threshold_met:
        ; Finally, apply the player's held intent and return
        lda PlayerHeldDirection
        sta SyntheticHeldIntent
        rts

not_holding_anything:
        lda #0
        sta SyntheticHeldIntent
        sta HeldInputCooldown
        rts
.endproc

.proc compute_synthetic_held_intent_patient
SyntheticHeldIntent := R2
        lda PlayerHeldDirection
        beq not_holding_anything

        lda HeldInputCooldown
        cmp #$FF
        beq skip_inc
        inc HeldInputCooldown
skip_inc:

        ; For the held threshold in patient mode, we'll also use
        ; the full duration of one entire musical beat
        lda HeldInputCooldown
        cmp TrackedBeatLength
        bcs threshold_met
threshold_not_met:
        lda #0
        sta SyntheticHeldIntent
        rts
threshold_met:
        ; Now, for patient mode, we will only apply HELD intent on beat boundaries
        lda CurrentBeat
        cmp LastBeat
        beq not_yet
get_on_with_it_already:
        lda PlayerHeldDirection
        sta SyntheticHeldIntent
        rts
not_yet:
        lda #0
        sta SyntheticHeldIntent
        rts

not_holding_anything:
        lda #0
        sta SyntheticHeldIntent
        sta HeldInputCooldown
        rts
.endproc

.proc wait_for_the_next_cleared_room_beat
SyntheticHeldIntent := R2
        jsr compute_synthetic_held_intent_cleared

        ; If the player's input has arrived...
        lda PlayerNextDirection
        ora SyntheticHeldIntent
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
        ; Take the opportunity here to advance the cached PRNG function
        debug_color (TINT_R | TINT_B | LIGHTGRAY)
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
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
        ; Make sure when we transition OUT of standard gameplay we don't
        ; insta-buffer a held repeat, as this can be quite awkward and fast
        lda #0
        sta HeldInputCooldown

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
        ora PlayerHeldDirection
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
        ; Take the opportunity here to advance the cached PRNG function
        debug_color (TINT_R | TINT_B | LIGHTGRAY)
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
        debug_color LIGHTGRAY

        jsr every_gameloop
        rts
.endproc

.proc wait_for_the_next_indefinite_gameplay_beat
SyntheticHeldIntent := R2
        jsr compute_synthetic_held_intent_patient

        ; always track the last beat, as repeat inputs need to key on this
        lda CurrentBeat
        sta LastBeat

        ; when we transition from standard -> cleared, do take the first on-beat
        ; transition right away. this eliminates a delay cycle with disco tiles still
        ; visible
        lda #$FF
        sta ClearedRoomCooldown

        ; Process a beat transition whenever. We are not synced to the rhythm at all!
        ; If the player's input HAS arrived:
        lda PlayerNextDirection
        ora SyntheticHeldIntent
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
        ; Take the opportunity here to advance the cached PRNG function
        debug_color (TINT_R | TINT_B | LIGHTGRAY)
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
        jsr advance_prng_table
        debug_color LIGHTGRAY

        jsr every_gameloop
        rts
.endproc

.proc every_gameloop
        jsr poll_input

        far_call FAR_update_palette_cycler

        perform_zpcm_inc
        far_call FAR_update_active_bombs
        perform_zpcm_inc
        far_call FAR_determine_player_intent
        far_call FAR_draw_player
        perform_zpcm_inc

        debug_color (TINT_G | TINT_B | LIGHTGRAY)
        far_call FAR_draw_sprites
        debug_color LIGHTGRAY

        perform_zpcm_inc
        far_call FAR_queue_hud
        perform_zpcm_inc

        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_update_torchlight
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY

        far_call FAR_update_coins
        far_call FAR_update_indicators
        far_call FAR_update_room_effects
        far_call FAR_draw_particles

        perform_zpcm_inc
        far_call FAR_refresh_palettes_gameloop
        perform_zpcm_inc
        jsr update_screen_shake
        perform_zpcm_inc
        jsr set_raster_effect_for_room
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

        perform_zpcm_inc
        jsr update_beat_counters
        perform_zpcm_inc

        jsr wait_for_next_vblank
        rts
.endproc

; Utility Functions

.proc update_beat_counters_title
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta PlayfieldBgHighBank
        sta PlayerObjHighBank
        sta PlayfieldBgObjHighBank
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
        sta PlayfieldBgObjHighBank
        ora #$04
        sta PlayfieldBgHighBank
        ; the sprite layer meanwhile continues to follow the player
        ldx TrackedGameplayPos
        lda tracked_animation_frame, x
        sta PlayerObjHighBank
        rts
normal_gameplay:
        ; when the room is not clear, everything tracks the gameplay timing so the player and enemies
        ; remain in perfect sync, even if the player's inputs are a little late
        ldx TrackedGameplayPos
        lda tracked_animation_frame, x
        sta PlayerObjHighBank
        sta PlayfieldBgObjHighBank
        ora #$04
        sta PlayfieldBgHighBank
        rts
paused_gameplay:
        ; During a pause state, the sprite layer continues to update (so the player's idle animaton works)
        ; but the background layer is permanently frozen on frame 0, freezing enemies in place
        lda #$00
        sta PlayfieldBgObjHighBank
        lda #$04
        sta PlayfieldBgHighBank
        ldx TrackedMusicPos
        lda tracked_animation_frame, x
        sta PlayerObjHighBank
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

        ; X can use the rand value directly
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
        jmp done_with_x
minus_x:
        eor #$FF
        clc
        adc #1
done_with_x:
        sta ScreenShakeX

        ; And for this implementation, Y can *also* use the rand value directly, so do that
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
        eor #$FF
        clc
        adc #1
done_with_y:
        sta ScreenShakeY

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
        sta ScreenShakeX
        sta ScreenShakeY
        rts
.endproc

; Only shake depth of -4 to +3 is actually programmed in
; at the moment, so we'll need to clamp accordingly. We might
; eventually want a stronger depth.
screen_shake_raster_lut:
        .byte RASTER_EFFECT_VS_MINUS_4
        .byte RASTER_EFFECT_VS_MINUS_3
        .byte RASTER_EFFECT_VS_MINUS_2
        .byte RASTER_EFFECT_VS_MINUS_1
        .byte RASTER_EFFECT_NONE
        .byte RASTER_EFFECT_VS_PLUS_1
        .byte RASTER_EFFECT_VS_PLUS_2
        .byte RASTER_EFFECT_VS_PLUS_3

.proc set_color_emphasis_for_room
        ; This is kinda expensive, don't call it too often
        ldx PlayerRoomIndex
        lda room_color_emphasis, x
        far_call FAR_apply_room_global_color_emphasis
        rts
.endproc

.proc set_raster_effect_for_room
        ldx PlayerRoomIndex
        lda room_raster_effect, x
        cmp #RASTER_EFFECT_NONE
        beq apply_screen_shake_effect
        ; TODO: temporary spell effects?
        jmp apply_room_specific_effect
apply_screen_shake_effect:
        lda ScreenShakeY
        clc
        adc #4    ; center on half the table size
        and #%111 ; mask to the number of table elements (larger shake will simply wrap around)
        tax
        set_raster_effect_safely {screen_shake_raster_lut, x}, #RASTER_FINALIZER_PLAIN_HUD, #0
        rts

apply_room_specific_effect:
        ; Only apply the room specific effect if it differs from the current effect
        ; (otherwise we continually reset the animation timing)
        cmp RasterEffectIndex
        beq keep_current_effect
        set_raster_effect_safely {room_raster_effect, x}, #RASTER_FINALIZER_PLAIN_HUD, #0
keep_current_effect:   
        rts
.endproc

.proc suspend_current_game
        lda current_save + SaveFile::RunFlags
        ora #RUN_FLAGS_SUSPENDED
        sta current_save + SaveFile::RunFlags

        far_call FAR_save_current_file

        st16 FadeToGameMode, title_prep
        st16 GameMode, fade_to_game_mode_from_gameplay

        rts
.endproc