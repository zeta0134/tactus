        .setcpu "6502"

        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "raster_tricks.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "static_screens.inc"
        .include "torchlight.inc"
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
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop
        jsr update_beat_counters

        jsr wait_for_next_vblank
        rts
.endproc

; === Game Mode Functions Follow ===

.proc init_engine
        ; TODO: pretty much everyting in this little section is debug demo stuff
        ; Later, organize this so that it loads the title screen, initial levels, etc

        st16 GameMode, title_prep
        jsr wait_for_next_vblank
        rts
.endproc

.proc title_prep
MetaSpriteIndex := R0
        lda #0
        sta tempo_adjustment

        ; Play lovely silence while we're loading
        lda #0
        jsr play_track
        near_call FAR_beat_tracker_init
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        jsr initialize_title_palettes

        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; the title screen for now doesn't use extended attributes, so
        ; turn those off
        lda #(NT_FPGA_RAM | NT_NO_EXT)
        sta MAP_NT_A_CONTROL
        sta MAP_NT_B_CONTROL
        sta MAP_NT_C_CONTROL
        sta MAP_NT_D_CONTROL
        lda #CHR_BANK_TITLE
        sta MAP_CHR_1_LO

        ; copy the initial batch of graphics into CHR RAM
        jsr clear_fpga_ram
        far_call FAR_copy_title_nametable

        .if ::DEBUG_NAMETABLES
        far_call FAR_debug_nametable_header
        .endif

        ; Set up a player sprite, which will act as our cursor
        far_call FAR_initialize_sprites
        far_call FAR_find_unused_sprite
        ; this runs on an empty set, so it ought to succeed
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #72
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #71
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #<SPRITE_TILE_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x

        ; The title screen does not (currently) use IRQs
        lda #0
        sta raster_tricks_enabled

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, run_title_screen
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000)
        sta PPUCTRL

        ; Play the title track on the title screen (duh)
        lda #3
        jsr play_track
        near_call FAR_beat_tracker_init

        ; (actually play other tracks for debugging)
        ;lda #4
        ;jsr play_track
        ;near_call FAR_beat_tracker_init

        rts
.endproc

.proc run_title_screen
        jsr update_beat_counters_title
        far_call FAR_draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        near_call FAR_update_title

        jsr wait_for_next_vblank
        rts
.endproc

.proc game_end_screen_prep
        lda #0
        sta tempo_adjustment

        ; Play lovely silence while we're loading
        lda #0
        jsr play_track
        near_call FAR_beat_tracker_init
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
        lda #(NT_FPGA_RAM | NT_NO_EXT)
        sta MAP_NT_A_CONTROL
        sta MAP_NT_B_CONTROL
        sta MAP_NT_C_CONTROL
        sta MAP_NT_D_CONTROL
        lda #CHR_BANK_OLD_CHRRAM
        sta MAP_CHR_1_LO

        jsr clear_fpga_ram
        far_call FAR_initialize_sprites
        near_call FAR_init_game_end_screen

        .if ::DEBUG_NAMETABLES
        far_call FAR_debug_nametable_header
        .endif

        ; The end screens do not (currently) use IRQs
        lda #0
        sta raster_tricks_enabled

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
        jsr update_beat_counters_title
        far_call FAR_draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        near_call FAR_update_game_end_screen

        jsr wait_for_next_vblank
        rts
.endproc

.proc game_prep
        lda #0
        sta tempo_adjustment

        ; play lovely silence while we load
        ; (this also ensures the music / beat counter are in a deterministic spot when we fade back in)
        lda #0
        jsr play_track
        near_call FAR_beat_tracker_init
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        near_call FAR_init_settings

        far_call FAR_init_torchlight

        ; the game screen uses ExAttr for palette access, so set that up here
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta MAP_NT_A_CONTROL
        sta MAP_NT_C_CONTROL
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta MAP_NT_B_CONTROL
        sta MAP_NT_D_CONTROL        

        ; set the game palette
        jsr initialize_game_palettes
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; copy the initial batch of graphics into CHR RAM
        jsr clear_fpga_ram
        far_call FAR_init_nametables

        .if ::DEBUG_NAMETABLES
        far_call FAR_debug_nametable_header
        .endif

        ; Gameplay does use IRQs
        lda #1
        sta raster_tricks_enabled

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
        lda #2 ; shower groove
        ;lda #4 ; in another world

        jsr play_track
        near_call FAR_beat_tracker_init

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

        .if ::DEBUG_TEST_FLOOR
        lda #%00000001
        sta global_rng_seed
        .else
        jsr next_rand
        ora #%00000001
        sta global_rng_seed
        .endif

        far_call FAR_initialize_sprites
        far_call FAR_init_hud
        near_call FAR_init_player

        st16 GameMode, zone_init
        rts
.endproc

.proc zone_init
        lda #0
        sta tempo_adjustment

        perform_zpcm_inc

        
        .if ::DEBUG_TEST_FLOOR
        ; Generate an open debug floor plan, with fixed spawn locations
        far_call FAR_demo_init_floor
        .else
        ; Generate proper mazes and randomize player, exit, and boss
        near_call FAR_init_floor
        .endif

        st16 GameMode, room_init
        rts
.endproc

.proc room_init
        perform_zpcm_inc
        near_call FAR_init_current_room
        perform_zpcm_inc
        far_call FAR_despawn_unimportant_sprites
        perform_zpcm_inc
        st16 GameMode, beat_frame_1
        rts
.endproc

.proc advance_to_next_floor
        ; If we were on the final floor, it's a victory!
        lda PlayerZone
        cmp #1 ; only the first floor is implemented for the demo
        bne not_victory
        lda PlayerFloor
        cmp #4
        bne not_victory

        st16 FadeToGameMode, game_end_screen_prep
        st16 GameMode, fade_to_game_mode
        rts

not_victory:
        inc PlayerFloor
        
        .if ::DEBUG_TEST_FLOOR
        ; Generate an open debug floor plan, with fixed spawn locations
        far_call FAR_demo_init_floor
        .else
        ; Generate proper mazes and randomize player, exit, and boss
        near_call FAR_init_floor
        .endif

        ; reset the player's position to the center of the room
        lda #6
        sta PlayerRow
        sta PlayerCol
        ; take away the player's key
        lda #0
        sta PlayerKeys
        ; We faded out to get here, so fade back in
        lda #0
        sta set_brightness
        lda #4
        sta TargetBrightness

        ; Add a small boost to the music tempo based on the player's current floor
        ; This causes the music to speed up (and thus gameplay to get more difficult)
        ; as the player makes progress in the dungeon
        lda PlayerFloor
        sec
        sbc #1 ; adjust to 0-3
        asl
        asl ; multiply by 4
        sta tempo_adjustment

        ; Now run room init and... we're good for now?
        st16 GameMode, room_init

        rts
.endproc

.proc beat_frame_1
        perform_zpcm_inc
        inc16 AccumulatedGameBeats
        inc CurrentBeatCounter
        lda CurrentBeat
        sta LastBeat

        ; reset animation tracking to the start of the musical row
        MACRO_reset_gameplay_position

        ; - Swap the active and inactive buffers
        far_call FAR_swap_battlefield_buffers

        perform_zpcm_inc

        ; Set the next kernel mode early; the player might override this
        st16 GameMode, update_enemies_1

        ; - Resolve the player's action
        debug_color (TINT_B | LIGHTGRAY)
        near_call FAR_update_player
        near_call FAR_handle_room_spawns
        debug_color LIGHTGRAY

        perform_zpcm_inc

        ; - Queue up any changed squares to the **active** buffer
        ; - Begin playback of any sprite animations (?)

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_clear_active_move_flags
        debug_color LIGHTGRAY
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

        ;- 1 frame: Update rows 0-3 of static enemies
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

        debug_color (TINT_B | TINT_R | LIGHTGRAY)

        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
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

        ;- 1 frame: Update rows 4-5 of static enemies, 0-1 of dynamic enemies, queue rows 0-1 to inactive buffer
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

        ;- 1 frame: Update rows 6-7 of static enemies, 2-3 of dynamic enemies, queue rows 2-3 to inactive buffer
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

        ;- 1 frame: Update rows 8-9 of static enemies, 4-5 of dynamic enemies, queue rows 4-5 to inactive buffer
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

        jsr every_gameloop
        st16 GameMode, draw_battlefield_A
        rts
.endproc

.proc draw_battlefield_A
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_A
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, draw_battlefield_B
        rts
.endproc

.proc draw_battlefield_B
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_B
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, draw_battlefield_C
        rts
.endproc


.proc draw_battlefield_C
StartingRow := R14
StartingTile := R15

        debug_color (TINT_G | LIGHTGRAY)
        far_call FAR_draw_battlefield_block_C
        debug_color LIGHTGRAY

        jsr every_gameloop
        st16 GameMode, decide_how_to_wait_for_the_next_beat
        rts
.endproc

.proc decide_how_to_wait_for_the_next_beat
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq normal_gameplay_beat_checking
room_cleared:
        st16 GameMode, wait_for_the_next_cleared_room_beat
        rts
normal_gameplay_beat_checking:
        st16 GameMode, wait_for_the_next_standard_gameplay_beat
        rts
.endproc

.proc wait_for_the_next_cleared_room_beat
        ; If the player's input has arrived...
        lda PlayerNextDirection
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
        beq no_input_received
input_received:
        ; Then immediatly process this beat
        jmp process_next_beat_now
no_input_received:        
        ; The player's input might arrive late, so give them some time. If we get to
        ; an actual row of 2 or more, THEN process the beat without waiting any longer:
        lda currently_playing_row
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

.proc every_gameloop
        perform_zpcm_inc
        jsr update_beat_counters
        perform_zpcm_inc

        perform_zpcm_inc
        far_call FAR_queue_hud
        perform_zpcm_inc
        near_call FAR_determine_player_intent
        near_call FAR_draw_player
        perform_zpcm_inc

        debug_color (TINT_G | TINT_B | LIGHTGRAY)
        far_call FAR_draw_sprites
        debug_color LIGHTGRAY

        debug_color (TINT_R | TINT_G | LIGHTGRAY)
        far_call FAR_update_torchlight
        far_call FAR_draw_torchlight
        debug_color LIGHTGRAY

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
        jsr next_rand
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
        jsr next_rand
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