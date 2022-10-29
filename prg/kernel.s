        .setcpu "6502"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .zeropage
GameMode: .res 2

.segment "RAM"
CurrentBeatCounter: .res 1
CurrentBeat: .res 1
LastBeat: .res 1
DisplayedRowCounter: .res 1

.segment "PRGFIXED_C000"

; === Utility Functions ===
.proc wait_for_next_vblank
        debug_color 0
        inc GameloopCounter
@loop:
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

; === Game Mode Functions Follow ===

.proc init_engine
        ; TODO: pretty much everyting in this little section is debug demo stuff
        ; Later, organize this so that it loads the title screen, initial levels, etc
        lda #1
        jsr play_track
        lda #0
        sta DisplayedRowCounter
        sta CurrentBeat
        sta LastBeat
        sta CurrentBeatCounter

        st16 GameMode, game_init
        jsr wait_for_next_vblank
        rts
.endproc

.proc game_init
        jsr next_rand
        ora #%00000001
        sta global_rng_seed

        far_call FAR_init_hud
        jsr init_player

        st16 GameMode, zone_init
        rts
.endproc

.proc zone_init
        ; FOR NOW, do a demo init that generates a static floor
        far_call FAR_demo_init_floor
        st16 GameMode, room_init
        rts
.endproc

.proc room_init
        far_call FAR_init_current_room
        jsr despawn_unimportant_sprites
        st16 GameMode, beat_frame_1
        rts
.endproc

.proc beat_frame_1
        inc CurrentBeatCounter
        lda CurrentBeat
        sta LastBeat
        lda #0
        sta DisplayedRowCounter
        ; - Swap the active and inactive buffers
        far_call FAR_swap_battlefield_buffers

        ; Set the next kernel mode early; the player might override this
        st16 GameMode, update_enemies_1

        ; - Resolve the player's action
        jsr update_player
        far_call FAR_handle_room_spawns

        ; - Queue up any changed squares to the **active** buffer
        ; - Begin playback of any sprite animations (?)

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        jsr clear_active_move_flags
        jsr age_sprites
        far_call FAR_refresh_hud
        jsr every_gameloop
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
        jsr update_static_enemy_row

        lda #1
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 1)
        sta StartingTile
        jsr update_static_enemy_row

        lda #2
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 2)
        sta StartingTile
        jsr update_static_enemy_row

        lda #3
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 3)
        sta StartingTile
        jsr update_static_enemy_row

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
        jsr update_static_enemy_row

        lda #5
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 5)
        sta StartingTile
        jsr update_static_enemy_row

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
        jsr update_static_enemy_row

        lda #7
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 7)
        sta StartingTile
        jsr update_static_enemy_row

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
        jsr update_static_enemy_row

        lda #9
        sta StartingRow
        lda #(::BATTLEFIELD_WIDTH * 9)
        sta StartingTile
        jsr update_static_enemy_row

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
        jsr update_beat_counters
        far_call FAR_sync_chr_bank_to_music
        far_call FAR_queue_battlefield_updates
        far_call FAR_queue_hud
        jsr determine_player_intent
        jsr draw_player
        jsr draw_sprites
        far_call FAR_update_brightness
        far_call FAR_refresh_palettes_gameloop

        jsr wait_for_next_vblank
        rts
.endproc

; Utility Functions

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