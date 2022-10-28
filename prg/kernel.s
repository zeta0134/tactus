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
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .zeropage
GameMode: .res 2

.segment "RAM"
CurrentBeatCounter: .res 1

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

        far_call FAR_init_hud
        far_call FAR_demo_init_floor
        jsr init_player

        st16 GameMode, room_init
        jsr wait_for_next_vblank
        rts
.endproc

.proc game_init
        rts
.endproc

.proc zone_init
        rts
.endproc

.proc room_init
        far_call FAR_init_current_room
        st16 GameMode, beat_frame_1
        rts
.endproc

.proc beat_frame_1
        inc CurrentBeatCounter
        ; - Swap the active and inactive buffers
        far_call FAR_swap_battlefield_buffers

        ; - Resolve the player's action
        jsr update_player

        ; - Queue up any changed squares to the **active** buffer
        ; - Begin playback of any sprite animations (?)

        ; - clear "moved this frame" flags from all tiles, permitting
        ;   the updates we will perform over the next few frames
        jsr clear_active_move_flags
        jsr age_sprites
        far_call FAR_refresh_hud
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

        ; for now, ignore player input and transition to the next beat when the row counter becomes 0
        lda row_counter
        and #%00000111
        bne continue_waiting
        st16 GameMode, beat_frame_1
        rts ; do that now
continue_waiting:
        jsr every_gameloop
        rts
.endproc

.proc every_gameloop
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

