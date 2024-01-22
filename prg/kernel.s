        .setcpu "6502"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
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
        .include "sound.inc"
        .include "sprites.inc"
        .include "static_screens.inc"
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
CurrentBeat: .res 1
LastBeat: .res 1
DisplayedRowCounter: .res 1
AccumulatedGameBeats: .res 2

.segment "PRGFIXED_E000"

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
        lda #0
        sta queued_bytes_counter
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop
        jsr update_beat_counters
        far_call FAR_sync_chr_bank_to_music

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

        ; copy the initial batch of graphics into CHR RAM
        far_call FAR_initialize_chr_ram_title
        far_call FAR_copy_title_nametable

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
        lda #SPRITES_PLAYER_IDLE
        sta sprite_table + MetaSpriteState::TileIndex, x


        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, run_title_screen
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL

        ; Play the title track on the title screen (duh)
        ;lda #3
        ;jsr play_track

        ; (actually play other tracks for debugging)
        lda #4
        jsr play_track

        rts
.endproc

.proc run_title_screen
        lda #0
        sta queued_bytes_counter

        jsr update_beat_counters_title
        far_call FAR_sync_chr_bank_to_music
        far_call FAR_draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        jsr update_title

        jsr wait_for_next_vblank
        rts
.endproc

.proc game_end_screen_prep
        lda #0
        sta tempo_adjustment

        ; Play lovely silence while we're loading
        lda #0
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

        far_call FAR_initialize_sprites
        jsr init_game_end_screen

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, run_game_end_screen
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL

        rts
.endproc

.proc run_game_end_screen
        lda #0
        sta queued_bytes_counter

        jsr update_beat_counters_title
        far_call FAR_sync_chr_bank_to_music
        far_call FAR_draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        jsr update_game_end_screen

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
        ; disable rendering, and soft-disable NMI (so music keeps playing)
        lda #$00
        sta PPUMASK

        lda #1
        sta NmiSoftDisable

        ; set the game palette
        jsr initialize_game_palettes
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        ; copy the initial batch of graphics into CHR RAM
        far_call FAR_initialize_chr_ram_game
        far_call FAR_init_nametables

        ; Enable NMI first (but not rendering)
        lda #0
        sta NmiSoftDisable

        st16 GameMode, game_init
        jsr wait_for_next_vblank

        ; NOW it is safe to re-enable rendering
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL

        rts
.endproc

.proc game_init
        lda #2
        jsr play_track
        lda #0
        sta DisplayedRowCounter
        sta CurrentBeat
        sta LastBeat
        sta CurrentBeatCounter
        sta AccumulatedGameBeats
        sta AccumulatedGameBeats+1

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
        jsr init_player

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
        far_call FAR_init_floor
        .endif

        st16 GameMode, room_init
        rts
.endproc

.proc room_init
        perform_zpcm_inc
        far_call FAR_init_current_room
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
        far_call FAR_init_floor
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
        lda #0
        sta DisplayedRowCounter
        ; - Swap the active and inactive buffers
        far_call FAR_swap_battlefield_buffers

        perform_zpcm_inc

        ; Set the next kernel mode early; the player might override this
        st16 GameMode, wait_for_player_draw_1

        ; - Resolve the player's action
        jsr update_player
        far_call FAR_handle_room_spawns

        perform_zpcm_inc

        ; - Queue up any changed squares to the **active** buffer
        ; - Begin playback of any sprite animations (?)

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        far_call FAR_clear_active_move_flags
        perform_zpcm_inc
        far_call FAR_age_sprites
        perform_zpcm_inc
        far_call FAR_refresh_hud
        perform_zpcm_inc
        jsr every_gameloop
        rts
.endproc

.proc wait_for_player_draw_1
StartingRow := R14
StartingTile := R15
        ; Do nothing! The player probably updated several rows, and
        ; we should give them a frame or two to draw before we do enemies again.
        ; If we draw enemies too quickly, we can get things slightly out of sync

        jsr every_gameloop
        st16 GameMode, wait_for_player_draw_2
        rts
.endproc

.proc wait_for_player_draw_2
StartingRow := R14
StartingTile := R15
        ; Do nothing! The player probably updated several rows, and
        ; we should give them a frame or two to draw before we do enemies again.
        ; If we draw enemies too quickly, we can get things slightly out of sync

        jsr every_gameloop
        st16 GameMode, update_enemies_1
        rts
.endproc

.proc update_enemies_1
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 0-3 of static enemies
        lda #0
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 0)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #1
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 1)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #2
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 2)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        jsr every_gameloop
        st16 GameMode, update_enemies_2
        rts
.endproc

.proc update_enemies_2
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 4-5 of static enemies, 0-1 of dynamic enemies, queue rows 0-1 to inactive buffer
        lda #4
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 4)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #5
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 5)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        jsr every_gameloop
        st16 GameMode, update_enemies_3
        rts
.endproc

.proc update_enemies_3
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 6-7 of static enemies, 2-3 of dynamic enemies, queue rows 2-3 to inactive buffer
        lda #6
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 6)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #7
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 7)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        jsr every_gameloop
        st16 GameMode, update_enemies_4
        rts
.endproc

.proc update_enemies_4
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 8-9 of static enemies, 4-5 of dynamic enemies, queue rows 4-5 to inactive buffer
        lda #8
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 8)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        lda #9
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 9)
        sta StartingTile
        far_call FAR_update_static_enemy_row

        jsr every_gameloop
        st16 GameMode, update_enemies_5
        rts
.endproc

.proc update_enemies_5
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 6-7 of dynamic enemies, queue rows 6-7 to inactive buffer
        jsr every_gameloop
        st16 GameMode, update_enemies_6
        rts
.endproc

.proc update_enemies_6
StartingRow := R14
StartingTile := R15
        ;- 1 frame: Update rows 8-9 of dynamic enemies, queue rows 8-9 to inactive buffer
        jsr every_gameloop
        st16 GameMode, wait_for_the_next_beat
        rts
.endproc

.proc wait_for_the_next_beat
        ;- Variable Frames: wait for the next "beat" to begin

        ; Special case: if the current room is marked as cleared, we do not need to wait
        ; for the next beat. Check for that here
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq normal_gameplay_beat_checking
room_cleared:
        ; If the player's input has arrived...
        lda PlayerNextDirection
        ; ... then go ahead and process this beat early
        bne process_next_beat_now
        ; otherwise treat things normally, so the visual beat is unchanged(ish)
        
normal_gameplay_beat_checking:
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
        ; an actual row of 3 or more, THEN process the beat without waiting any longer:
        lda row_counter
        and #%00000111
        cmp #2
        bcs process_next_beat_now
        ; Otherwise let the whole engine lag while the player makes up their damned mind :)
        jmp continue_waiting
process_next_beat_now:
        st16 GameMode, beat_frame_1
        rts ; do that now
continue_waiting:
        jsr every_gameloop
        rts
.endproc

.proc every_gameloop
        perform_zpcm_inc
        jsr update_beat_counters
        far_call FAR_sync_chr_bank_to_music
        perform_zpcm_inc
        far_call FAR_queue_battlefield_updates
        perform_zpcm_inc
        far_call FAR_queue_hud
        perform_zpcm_inc
        jsr determine_player_intent
        jsr draw_player
        perform_zpcm_inc
        far_call FAR_draw_sprites
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
        lda row_counter
        and #%00000111
        sta DisplayedRowCounter
        rts
.endproc

.proc update_beat_counters
        ; Don't update the displayed row counter if it's already >= 7
        lda DisplayedRowCounter
        cmp #7
        bcs done_with_displayed_row_counter
        ; If the displayed row counter does not equal the actual row counter
        lda row_counter
        and #%00000111
        cmp DisplayedRowCounter
        beq done_with_displayed_row_counter
        ; ... then increment it by one stage
        inc DisplayedRowCounter
done_with_displayed_row_counter:
        ; If the current row_counter is 0...
        lda row_counter
        and #%00000111
        bne done_with_current_beat
        ; ... and current and last beat ARE the same
        lda CurrentBeat
        cmp LastBeat
        bne done_with_current_beat
        ; and... to prevent hyper-beat speed, the displayed row counter is not STILL 0...
        lda DisplayedRowCounter
        beq done_with_current_beat
        ; ... then increment CurrentBeat
        inc CurrentBeat
done_with_current_beat:
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