    .include "rta_timer.inc"    

    .include "far_call.inc"
    .include "hud.inc"
    .include "pal.inc"
    .include "player.inc"
    .include "saves.inc"
    .include "word_util.inc"

.segment "PRGRAM"

; For various gameplay reasons we may wish to pause these, this is how to do so.
RtaTimeBase: .res 1
RtaTimerEnabled: .res 1
PedometerEnabled: .res 1

; Because we call this at the end of vblank, spend the fixed and make
; it FAST. (it is not very large.)
.segment "PRGFIXED_E000"

.proc FIXED_advance_rta_timer
    lda RtaTimerEnabled
    beq done
    lda PlayerIsPaused
    bne done
    
    ; Advance subframes
    add16b current_save + SaveFile::RunTimeFrames, RtaTimeBase
    cmp16 current_save + SaveFile::RunTimeFrames, #300
    bcc done
    sec
    sub16w current_save + SaveFile::RunTimeFrames, 300
    ; Advance seconds
    inc current_save + SaveFile::RunTimeSeconds
    lda current_save + SaveFile::RunTimeSeconds
    cmp #60
    bcc done
    lda #0
    sta current_save + SaveFile::RunTimeSeconds
    ; Advance minutes
    inc current_save + SaveFile::RunTimeMinutes
    lda current_save + SaveFile::RunTimeMinutes
    cmp #60
    bcc done
    lda #0
    sta current_save + SaveFile::RunTimeMinutes
    ; Advance hours
    inc current_save + SaveFile::RunTimeHours
done:
    rts
.endproc

.proc FIXED_advance_pedometer
    lda PedometerEnabled
    beq done
    lda PlayerIsPaused
    bne done
    lda #1
    sta HudPedometerDirty
    inc current_save + SaveFile::RunBeatsElapsed+0
    bne done
    inc current_save + SaveFile::RunBeatsElapsed+1
done:
    rts
.endproc

.segment "CODE_C"

; Generally call this when starting a brand new run, and also
; when initializing the runtime. Clears all timers and disables
; both of the counters.
.proc FAR_initialize_rta_timers
    lda #0
    sta current_save + SaveFile::RunBeatsElapsed+0
    sta current_save + SaveFile::RunBeatsElapsed+1
    sta current_save + SaveFile::RunTimeFrames+0
    sta current_save + SaveFile::RunTimeFrames+1
    sta current_save + SaveFile::RunTimeSeconds
    sta current_save + SaveFile::RunTimeMinutes
    sta current_save + SaveFile::RunTimeHours
    lda #0
    sta RtaTimerEnabled
    sta PedometerEnabled
    lda #1
    sta HudPedometerDirty

    ; NTSC and PAL have different fractions of a frame here,
    ; so handle that gracefully
    lda system_type
    cmp #SYSTEM_TYPE_PAL
    beq use_pal_timing
    cmp #SYSTEM_TYPE_DENDY
    beq use_pal_timing
use_ntsc_timing:
    lda #5
    jmp done_choosing_time_base
use_pal_timing:
    lda #6
done_choosing_time_base:
    sta RtaTimeBase

    rts
.endproc
