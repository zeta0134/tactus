.global FAR_beat_tracker_init
.global update_beat_tracker

.global tracked_row_buffer
.global tracked_animation_frame

.global TrackedMusicPos
.global TrackedGameplayPos
.global TrackedBeatLength
.global CurrentBeat

.macro MACRO_reset_gameplay_position
    lda #0
    sta TrackedGameplayPos
.endmacro