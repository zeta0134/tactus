        .setcpu "6502"
        .include "action53.inc"
        .include "debug.inc"
        .include "bhop/bhop.inc"
        .include "far_call.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "RAM"
Pulse1RowCounter: .res 1
Pulse2RowCounter: .res 1
TriangleRowCounter: .res 1
NoiseRowCounter: .res 1
Pulse1DelayCounter: .res 1
Pulse2DelayCounter: .res 1
TriangleDelayCounter: .res 1
NoiseDelayCounter: .res 1

MusicCurrentTrack: .res 1
MusicCurrentBank: .res 1
MusicTargetTrack: .res 1
FadeCounter: .res 1

        .zeropage
Pulse1SfxPtr: .res 2
Pulse2SfxPtr: .res 2
TriangleSfxPtr: .res 2
NoiseSfxPtr: .res 2

FADE_SPEED = 8

        .segment "PRG2_8000"

.export bhop_music_data
bhop_music_data: ; TODO: deprecated label, remove later

music_module:
        .scope
        .include "../art/music/music.asm"
        .endscope

        .segment "PRGFIXED_C000"

track_table_bank:
        .repeat 3
        .lobytes .bank(music_module)
        .endrepeat
        
track_table_song:
        .byte 0 ; silence (used for transitions)
        .byte 1 ; click track (meant for debugging)
        .byte 2 ; level music

track_table_num_variants:
        .byte 1 ; silence 
        .byte 1 ; click_track
        .byte 1 ; level music

track_table_variant_length:
        .byte 0 ; silence
        .byte 0 ; click_track
        .byte 0 ; level music

.proc init_audio
        ; Always initialize the music engine with track 0 of the first module. This will
        ; be the first song that begins playing immediately; ideally fill it with silence.
        lda #0
        sta MusicCurrentTrack
        sta MusicTargetTrack

        ldx MusicCurrentTrack
        lda track_table_bank, x
        sta MusicCurrentBank

        access_data_bank MusicCurrentBank
        ; TODO: if music lives on a different bank, swap that in

        lda track_table_song, x
        jsr bhop_init

        restore_previous_bank

        ; init some custom bhop features here as well
        lda #0
        sta target_music_variant
        lda #0
        sta global_attenuation

        rts
.endproc

.proc update_audio
        jsr update_fade
        access_data_bank MusicCurrentBank
        jsr bhop_play
        jsr update_sfx
        restore_previous_bank
        rts
.endproc

.proc update_fade
        ; If there is no track to switch to, don't bother fading to it
        lda MusicTargetTrack
        cmp MusicCurrentTrack
        beq done_with_fade
        ; Handle fade speed
        dec FadeCounter
        bne done_with_fade
        lda #FADE_SPEED
        sta FadeCounter
        ; Each tick, increase global attenuation by one
        inc global_attenuation
        lda global_attenuation
        ; If we aren't fully attenuated yet, we're done
        cmp #8
        bne done_with_fade
        ; Otherwise, switch to the target track
        lda MusicTargetTrack
        jsr play_track
done_with_fade:
        rts
.endproc

; inputs: track number in A
.proc fade_to_track
        sta MusicTargetTrack
        lda #FADE_SPEED
        sta FadeCounter
        ; special case: is our current track 0, silence? If so, start playback immediately
        lda MusicCurrentTrack
        bne done
        lda MusicTargetTrack
        jsr play_track
done:
        rts
.endproc

; inputs: track number in A
.proc play_track
        .if ::DEBUG_DISABLE_MUSIC
        ; ignore the requested track, and queue up the click track instead
        lda #1
        .endif
        cmp MusicCurrentTrack
        beq no_change
        sta MusicCurrentTrack
        sta MusicTargetTrack
        tax
        lda track_table_bank, x
        sta MusicCurrentBank
        access_data_bank MusicCurrentBank
        lda track_table_song, x
        jsr bhop_init
        restore_previous_bank
        ; all new tracks should start with variant 0
        ; (the map load routine might override this immediately, but if it
        ; doesn't, we still need to clear the state from the previous track)
        lda #0
        sta target_music_variant
        lda #0
        sta global_attenuation
no_change:
        rts
.endproc

; inputs: variant number in A
.proc play_variant
        ldx MusicCurrentTrack
        cmp track_table_num_variants, x
        bcs invalid_variant
                
        ; use the variant index as a loop counter
        tay
        lda #0
loop:
        clc
        adc track_table_variant_length, x
        dey
        bne loop
        sta target_music_variant

invalid_variant:
        ; ignore this variant and do nothing
        rts
.endproc

.proc play_sfx_pulse1
SfxPtr := R0
        lda SfxPtr
        sta Pulse1SfxPtr
        lda SfxPtr+1
        sta Pulse1SfxPtr+1
        ldy #0
        lda (Pulse1SfxPtr), y
        sta Pulse1RowCounter
        inc16 Pulse1SfxPtr
        lda #0
        sta Pulse1DelayCounter
        lda #0
        jsr bhop_mute_channel
        rts
.endproc

.proc play_sfx_pulse2
SfxPtr := R0
        lda SfxPtr
        sta Pulse2SfxPtr
        lda SfxPtr+1
        sta Pulse2SfxPtr+1
        ldy #0
        lda (Pulse2SfxPtr), y
        sta Pulse2RowCounter
        inc16 Pulse2SfxPtr
        lda #0
        sta Pulse2DelayCounter
        lda #1
        jsr bhop_mute_channel
        rts
.endproc

.proc play_sfx_triangle
SfxPtr := R0
        lda SfxPtr
        sta TriangleSfxPtr
        lda SfxPtr+1
        sta TriangleSfxPtr+1
        ldy #0
        lda (TriangleSfxPtr), y
        sta TriangleRowCounter
        inc16 TriangleSfxPtr
        lda #0
        sta Pulse2DelayCounter
        lda #2
        jsr bhop_mute_channel
        rts
.endproc

.proc play_sfx_noise
SfxPtr := R0
        lda SfxPtr
        sta NoiseSfxPtr
        lda SfxPtr+1
        sta NoiseSfxPtr+1
        ldy #0
        lda (NoiseSfxPtr), y
        sta NoiseRowCounter
        inc16 NoiseSfxPtr
        lda #0
        sta Pulse2DelayCounter
        lda #3
        jsr bhop_mute_channel
        rts
.endproc

.proc update_pulse1
        lda Pulse1DelayCounter
        beq advance
        dec Pulse1DelayCounter
        jmp done
advance:
        lda Pulse1RowCounter
        beq silence
        dec Pulse1RowCounter
        
        ldy #0
loop:
        lda (Pulse1SfxPtr), y
        bmi last_command
        ;clc
        ;adc #0
        tax
        inc16 Pulse1SfxPtr
        lda (Pulse1SfxPtr), y
        sta $4000, x
        inc16 Pulse1SfxPtr
        jmp loop
last_command:
        and #%01111111
        sta Pulse1DelayCounter
        inc16 Pulse1SfxPtr
        jmp done

silence:
        lda #0
        jsr bhop_unmute_channel
done:
        rts
.endproc

.proc update_pulse2
        lda Pulse2DelayCounter
        beq advance
        dec Pulse2DelayCounter
        jmp done
advance:
        lda Pulse2RowCounter
        beq silence
        dec Pulse2RowCounter
        
        ldy #0
loop:
        lda (Pulse2SfxPtr), y
        bmi last_command
        clc
        adc #4
        tax
        inc16 Pulse2SfxPtr
        lda (Pulse2SfxPtr), y
        sta $4000, x
        inc16 Pulse2SfxPtr
        jmp loop
last_command:
        and #%01111111
        sta Pulse2DelayCounter
        inc16 Pulse2SfxPtr
        jmp done

silence:
        lda #1
        jsr bhop_unmute_channel
done:
        rts
.endproc

.proc update_triangle
        lda TriangleDelayCounter
        beq advance
        dec TriangleDelayCounter
        jmp done
advance:
        lda TriangleRowCounter
        beq silence
        dec TriangleRowCounter
        
        ldy #0
loop:
        lda (TriangleSfxPtr), y
        bmi last_command
        clc
        adc #8
        tax
        inc16 TriangleSfxPtr
        lda (TriangleSfxPtr), y
        sta $4000, x
        inc16 TriangleSfxPtr
        jmp loop
last_command:
        and #%01111111
        sta TriangleDelayCounter
        inc16 TriangleSfxPtr
        jmp done

silence:
        lda #2
        jsr bhop_unmute_channel
done:
        rts
.endproc

.proc update_noise
        lda NoiseDelayCounter
        beq advance
        dec NoiseDelayCounter
        jmp done
advance:
        lda NoiseRowCounter
        beq silence
        dec NoiseRowCounter
        
        ldy #0
loop:
        lda (NoiseSfxPtr), y
        bmi last_command
        clc
        adc #$C
        tax
        inc16 NoiseSfxPtr
        lda (NoiseSfxPtr), y
        sta $4000, x
        inc16 NoiseSfxPtr
        jmp loop
last_command:
        and #%01111111
        sta NoiseDelayCounter
        inc16 NoiseSfxPtr
        jmp done

silence:
        lda #3
        jsr bhop_unmute_channel
done:
        rts
.endproc

.proc update_sfx
        jsr update_pulse1
        jsr update_pulse2
        jsr update_triangle
        jsr update_noise
        rts
.endproc

.include "sfx.incs"