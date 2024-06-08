    .include "bhop/bhop.inc"
    .include "beat_tracker.inc"
    .include "zeropage.inc"

.segment "PRGRAM"

tracked_row_buffer: .res 64
tracked_animation_frame: .res 64

TrackedMusicPos: .res 1
TrackedGameplayPos: .res 1
CurrentBeat: .res 1
TrackedBeatLength: .res 1

CurrentRow: .res 1
LastTrackedRow: .res 1



.segment "CODE_1"

.proc FAR_beat_tracker_init
    ldy #63
loop:
    lda #7
    sta tracked_row_buffer, y
    lda #3
    sta tracked_animation_frame, y
    dey
    bne loop

    lda #0
    sta TrackedMusicPos
    sta TrackedGameplayPos
    sta CurrentBeat

    lda #20 ; 180 BPM, sure, why not (this only affects cleared-room cooldowns)
    sta TrackedBeatLength

    rts
.endproc

.segment "PRGFIXED_E000"

; This is the animation frame we'll display on each tracked
; musical row. currently, we favor 8 tracker rows per beat,
; and we shorten the earlier frames to help the movements
; feel snappy. the final held frame is "anticipation" and its 
; duration will vary based on player input timing
beat_frame_pacing:
        .byte 0, 1, 1, 2, 2, 3, 3, 3
; note that for art purposes, our "key pose" for any given
; animation is nearly always frame 3, as it will be displayed
; the longest by far

.proc update_beat_tracker
    lda currently_playing_row ; from bhop
    and #%00000111
    sta CurrentRow
    bne increment_music_head
    ; if this is row 0, AND the LastTrackedRow is nonzero:
    lda LastTrackedRow
    beq increment_music_head
    ; then reset the music position (unconditionally)
    lda TrackedMusicPos
    sta TrackedBeatLength ; track the current beat length in ~frames
    lda #0
    sta TrackedMusicPos
    inc CurrentBeat
    jmp write_data
increment_music_head:
    inc TrackedMusicPos
    lda TrackedMusicPos
    cmp #64
    bcc write_data
    lda #63
    sta TrackedMusicPos
write_data:
    ldx TrackedMusicPos
    lda CurrentRow
    sta tracked_row_buffer, x
    sta LastTrackedRow
done_with_music:
    ; update the CHR animation frame while we're at it, no need to duplicate 
    ; this logic into call sites
    tay
    lda beat_frame_pacing, y
    sta tracked_animation_frame, x

    ; now update the gameplay position
    inc TrackedGameplayPos
    lda TrackedGameplayPos
    ; to simplify catchup, don't run quite to the end of the buffer
    ; (it's weird for tempo to be this slow anyway)
    cmp #62
    bcs gameplay_oob
    cmp TrackedMusicPos
    beq gameplay_reached_music_pos
    ; catchup mode: an extra increment on every other frame
    lda GameloopCounter
    and #%00000001
    beq done
    inc TrackedGameplayPos
done:
gameplay_reached_music_pos:
    rts
gameplay_oob:
    lda #62
    sta TrackedGameplayPos
    rts
.endproc