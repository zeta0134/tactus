        .setcpu "6502"

        .macpack longbranch

        .include "_globals.inc"
        
        .include "bhop/bhop.inc"
        .include "debug.inc"
        .include "beat_tracker.inc"
        .include "far_call.inc"
        .include "pal.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "slowam.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .import sfx_data_ntsc
        .import sfx_data_pal

        .segment "PRGRAM"
Pulse1RowCounter: .res 1
Pulse2RowCounter: .res 1
TriangleRowCounter: .res 1
NoiseRowCounter: .res 1
Pulse1DelayCounter: .res 1
Pulse2DelayCounter: .res 1
TriangleDelayCounter: .res 1
NoiseDelayCounter: .res 1

Pulse1Priority: .res 1
Pulse2Priority: .res 1
TrianglePriority: .res 1
NoisePriority: .res 1

MusicCurrentTrack: .res 1
MusicCurrentBank: .res 1
MusicTargetTrack: .res 1
FadeCounter: .res 1

CandidateSfxPtr: .res 2
CandidateSfxPriority: .res 1

DeferredSfxPtrPulse1: .res 2
DeferredSfxPriorityPulse1: .res 1
DeferredSfxPtrPulse2: .res 2
DeferredSfxPriorityPulse2: .res 1
DeferredSfxPtrTriangle: .res 2
DeferredSfxPriorityTriangle: .res 1
DeferredSfxPtrNoise: .res 2
DeferredSfxPriorityNoise: .res 1

UpdateBeatTrackerDuringNmi: .res 1

        .zeropage
Pulse1SfxPtr: .res 2
Pulse2SfxPtr: .res 2
TriangleSfxPtr: .res 2
NoiseSfxPtr: .res 2

NmiSafePtr: .res 2

FADE_SPEED = 8

        .segment "MUSIC_0"
        .proc zeta_silence
        .include "../art/music/silence.asm"
        .endproc
        
        .segment "MUSIC_0"
        .proc zeta_click_track
        .include "../art/music/click_track.asm"
        .endproc

        .segment "MUSIC_0"
        .proc zeta_title
        .include "../art/music/title.asm"
        .endproc

        .segment "MUSIC_0"
        .proc zeta_game_over
        .include "../art/music/game_over.asm"
        .endproc

        .segment "MUSIC_1"
        ; and MUSIC_2
        ; and MUSIC_3
        .proc persune_in_another_world
        .include "../art/music/in_another_world_edit.asm"
        .endproc

        .segment "MUSIC_4"
        .proc zeta_shower_groove
        .include "../art/music/shower_groove.asm"
        .endproc

        .segment "MUSIC_5"
        .proc zeta_bouncy
        .include "../art/music/bouncy.asm"
        .endproc

        .segment "MUSIC_6"
        ; and MUSIC_7
        .proc zeta_echoes
        .include "../art/music/echoes.asm"
        .endproc

        .segment "MUSIC_8"
        .proc zeta_options
        .include "../art/music/options.asm"
        .endproc

        .segment "PRGFIXED_E000"

; bhop calls these functions for bank swapping and ZPCM tomfoolery
.proc bhop_enable_zpcm
ScratchPtr := NmiSafePtr
        ; set the PCM address to $4011 when doing slow OAM transfers
        st16 ScratchPtr, SPRITE_TRANSFER_BASE
        ldx #16
        ldy #(SpriteRunWithSample::__zpcm_addr + 1)
loop:
        perform_zpcm_inc
        lda #$40
        sta (ScratchPtr), y
        add16b ScratchPtr, #.sizeof(SpriteRunWithSample)
        dex
        bne loop

        ; switch both the current code bank and the fixed code bank
        ; to the zpcm-enabled universe
        lda code_bank_shadow
        and #<__BANK_MASK__
        ora #0
        sta MAP_PRG_8_LO

        lda #(3 + 0)
        sta MAP_PRG_E_LO

        perform_zpcm_inc

        rts
.endproc
.export bhop_enable_zpcm

.proc bhop_disable_zpcm
ScratchPtr := NmiSafePtr
        ; set the PCM address to $FF11 when doing slow OAM transfers
        st16 ScratchPtr, SPRITE_TRANSFER_BASE
        ldx #16
        ldy #(SpriteRunWithSample::__zpcm_addr + 1)
loop:
        perform_zpcm_inc
        lda #$FF
        sta (ScratchPtr), y
        add16b ScratchPtr, #.sizeof(SpriteRunWithSample)
        dex
        bne loop

        ; switch both the current code bank and the fixed code bank
        ; to the zpcm-enabled universe
        lda code_bank_shadow
        and #<__BANK_MASK__
        ora #32
        sta MAP_PRG_8_LO

        lda #(3 + 32)
        sta MAP_PRG_E_LO

        perform_zpcm_inc

        rts
.endproc
.export bhop_disable_zpcm

.proc bhop_apply_music_bank
        sta MAP_PRG_A_LO
        rts
.endproc
.export bhop_apply_music_bank

.proc bhop_apply_dpcm_bank
        sta MAP_PRG_C_LO
        rts
.endproc
.export bhop_apply_dpcm_bank

; stubbed
.proc _play_sfx_pulse1
        far_call FAR_play_sfx_pulse1
        rts
.endproc

.proc _play_sfx_pulse2
        far_call FAR_play_sfx_pulse2
        rts
.endproc

.proc _play_sfx_triangle
        far_call FAR_play_sfx_triangle
        rts
.endproc

.proc _play_sfx_noise
        far_call FAR_play_sfx_noise
        rts
.endproc

; Everything else goes in the switched bank
        .segment "CODE_SOUND"

track_table_module_low:
        .lobytes zeta_silence
        .lobytes zeta_click_track
        .lobytes zeta_title
        .lobytes zeta_options
        .lobytes zeta_game_over
        .lobytes zeta_shower_groove
        .lobytes persune_in_another_world
        .lobytes zeta_bouncy
        .lobytes zeta_echoes
        .lobytes zeta_options
        .lobytes zeta_options

track_table_module_high:
        .hibytes zeta_silence
        .hibytes zeta_click_track
        .hibytes zeta_title
        .hibytes zeta_options
        .hibytes zeta_game_over
        .hibytes zeta_shower_groove
        .hibytes persune_in_another_world
        .hibytes zeta_bouncy
        .hibytes zeta_echoes
        .hibytes zeta_options
        .hibytes zeta_options

track_table_bank:
        .lobytes .bank(zeta_silence)
        .lobytes .bank(zeta_click_track)
        .lobytes .bank(zeta_title)
        .lobytes .bank(zeta_options)
        .lobytes .bank(zeta_game_over)
        .lobytes .bank(zeta_shower_groove)
        .lobytes .bank(persune_in_another_world)
        .lobytes .bank(zeta_bouncy)
        .lobytes .bank(zeta_echoes)
        .lobytes .bank(zeta_options)
        .lobytes .bank(zeta_options)
        
track_table_song:
        .byte 0 ; silence (used for transitions)
        .byte 0 ; click track (meant for debugging)
        .byte 0 ; title
        .byte 0 ; options
        .byte 0 ; gameover
        .byte 0 ; shower groove
        .byte 0 ; in another world (warp zone)
        .byte 0 ; bouncy
        .byte 0 ; echoes
        .byte 0 ; options
        .byte 0 ; options

track_table_num_variants:
        .byte 5 ; silence 
        .byte 5 ; click_track
        .byte 5 ; title music
        .byte 5 ; options music
        .byte 5 ; gameover music
        .byte 5 ; shower groove
        .byte 5 ; in another world (warp zone)
        .byte 5 ; bouncy
        .byte 5 ; echoes
        .byte 5 ; options music
        .byte 5 ; options music

track_table_heartbeat_offset:
        .byte 0 ; silence 
        .byte 0 ; click_track
        .byte 0 ; title music
        .byte 0 ; options music
        .byte 0 ; gameover music
        .byte 0 ; level music
        .byte 4 ; in another world (warp zone)
        .byte 0 ; bouncy
        .byte 0 ; echoes
        .byte 0 ; options music
        .byte 0 ; options music

track_table_heartbeat_period:
        .byte 0 ; silence 
        .byte 8 ; click_track
        .byte 8 ; title music
        .byte 8 ; options music
        .byte 8 ; gameover music
        .byte 8 ; level music
        .byte 8 ; in another world (initial, switches to 6 partway through)
        .byte 8 ; bouncy
        .byte 8 ; echoes
        .byte 8 ; options music
        .byte 8 ; options music

; interface functions should mostly live in fixed; we'll call these often, and several
; need A to remain unclobbered

.proc FAR_fade_to_track
        perform_zpcm_inc
        sta MusicTargetTrack
        lda #FADE_SPEED
        sta FadeCounter
        ; special case: is our current track 0, silence? If so, start playback immediately
        lda MusicCurrentTrack
        bne done
        lda MusicTargetTrack
        ldy #TRACK_VARIANT_NORMAL
        near_call FAR_play_track
done:
        rts
.endproc

; inputs: track number in A, initial variant in Y
.proc FAR_play_track
        perform_zpcm_inc
        sty target_music_variant

        cmp MusicCurrentTrack
        jeq no_change
        sta MusicCurrentTrack
        sta MusicTargetTrack
        tax
        lda track_table_bank, x
        sta MusicCurrentBank
        access_data_bank MusicCurrentBank

        lda target_music_variant
        near_call FAR_play_variant

        ldx MusicCurrentTrack
        lda track_table_module_low, x
        ldy track_table_module_high, x
        far_call bhop_set_module_addr

        ldx MusicCurrentTrack
        lda track_table_bank, x
        far_call bhop_set_module_bank

        perform_zpcm_inc

        ldx MusicCurrentTrack
        lda track_table_song, x
        near_call bhop_init
        lda #0
        sta global_attenuation
        restore_previous_bank

        far_call FAR_beat_tracker_init
        rts

no_change:
        ; safely re-apply the current music variant (again)
        ; to be sure it is applied even if we did not actually change songs
        lda target_music_variant
        near_call FAR_play_variant

        rts
.endproc

; inputs: variant number in A
.proc FAR_play_variant
        ; First, check to see if we need to replace this variant based on the music mode
        ldx current_save + SaveFile::OptionMusicMode
        cpx #OPTION_MUSIC_CLICK
        beq force_click_track
        cpx #OPTION_MUSIC_DISABLED
        beq force_silent_track
        jmp use_supplied_variant
force_click_track:
        lda #TRACK_VARIANT_CLICK
        jmp use_supplied_variant
force_silent_track:
        lda #TRACK_VARIANT_SILENT
        ; fall through to use supplied
use_supplied_variant:
        ldx MusicCurrentTrack
        cmp track_table_num_variants, x
        beq invalid_variant ; variant index must be LESS than the total count
        bcs invalid_variant
        ; this variant is valid, so apply it
        sta target_music_variant
        rts
invalid_variant:
        ; switch to variant 0 instead, which is always present and safe
        lda #0
        sta target_music_variant
        rts
.endproc

; TODO: do these REALLY need to be in fixed? surely we could far_call without too much
; of a performance penalty, non?

.proc FAR_play_sfx_pulse1
        perform_zpcm_inc

        lda current_save + SaveFile::OptionSfxMode
        cmp #OPTION_SFX_ENABLED
        beq sfx_enabled
        perform_zpcm_inc
        rts
sfx_enabled:

        ; Check our candidate priority against the channel's active priority.
        ; If the candidate is lower (<) than the current priority, bail without
        ; doing anything.
        lda CandidateSfxPriority
        cmp Pulse1Priority
        bcs candidate_check_succeeded
        rts
candidate_check_succeeded:
        sta Pulse1Priority

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_sfx
use_ntsc_sfx:
        access_data_bank #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        lda CandidateSfxPtr
        sta Pulse1SfxPtr
        lda CandidateSfxPtr+1
        sta Pulse1SfxPtr+1
        ldy #0
        lda (Pulse1SfxPtr), y
        sta Pulse1RowCounter
        inc16 Pulse1SfxPtr
        lda #0
        sta Pulse1DelayCounter
        lda #0
        near_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_play_sfx_pulse2
        perform_zpcm_inc

        lda current_save + SaveFile::OptionSfxMode
        cmp #OPTION_SFX_ENABLED
        beq sfx_enabled
        perform_zpcm_inc
        rts
sfx_enabled:

        ; Check our candidate priority against the channel's active priority.
        ; If the candidate is lower (<) than the current priority, bail without
        ; doing anything.
        lda CandidateSfxPriority
        cmp Pulse2Priority
        bcs candidate_check_succeeded
        rts
candidate_check_succeeded:
        sta Pulse2Priority

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_sfx
use_ntsc_sfx:
        access_data_bank #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        lda CandidateSfxPtr
        sta Pulse2SfxPtr
        lda CandidateSfxPtr+1
        sta Pulse2SfxPtr+1
        ldy #0
        lda (Pulse2SfxPtr), y
        sta Pulse2RowCounter
        inc16 Pulse2SfxPtr
        lda #0
        sta Pulse2DelayCounter
        lda #1
        near_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_play_sfx_triangle
        perform_zpcm_inc

        lda current_save + SaveFile::OptionSfxMode
        cmp #OPTION_SFX_ENABLED
        beq sfx_enabled
        perform_zpcm_inc
        rts
sfx_enabled:

        ; Check our candidate priority against the channel's active priority.
        ; If the candidate is lower (<) than the current priority, bail without
        ; doing anything.
        lda CandidateSfxPriority
        cmp TrianglePriority
        bcs candidate_check_succeeded
        rts
candidate_check_succeeded:
        sta TrianglePriority

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_sfx
use_ntsc_sfx:
        access_data_bank #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        lda CandidateSfxPtr
        sta TriangleSfxPtr
        lda CandidateSfxPtr+1
        sta TriangleSfxPtr+1
        ldy #0
        lda (TriangleSfxPtr), y
        sta TriangleRowCounter
        inc16 TriangleSfxPtr
        lda #0
        sta TriangleDelayCounter
        lda #2
        near_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_play_sfx_noise
        perform_zpcm_inc

        lda current_save + SaveFile::OptionSfxMode
        cmp #OPTION_SFX_ENABLED
        beq sfx_enabled
        perform_zpcm_inc
        rts
sfx_enabled:

        ; Check our candidate priority against the channel's active priority.
        ; If the candidate is lower (<) than the current priority, bail without
        ; doing anything.
        lda CandidateSfxPriority
        cmp NoisePriority
        bcs candidate_check_succeeded
        rts
candidate_check_succeeded:
        sta NoisePriority

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_sfx
use_ntsc_sfx:
        access_data_bank #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        lda CandidateSfxPtr
        sta NoiseSfxPtr
        lda CandidateSfxPtr+1
        sta NoiseSfxPtr+1
        ldy #0
        lda (NoiseSfxPtr), y
        sta NoiseRowCounter
        inc16 NoiseSfxPtr
        lda #0
        sta NoiseDelayCounter
        lda #3
        near_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc FAR_init_audio
        perform_zpcm_inc
        ; Always initialize the music engine with track 0 of the first module. This will
        ; be the first song that begins playing immediately; ideally fill it with silence.
        lda #0
        sta MusicCurrentTrack
        sta MusicTargetTrack

        ldx MusicCurrentTrack
        lda track_table_bank, x
        sta MusicCurrentBank

        access_data_bank MusicCurrentBank

        ldx MusicCurrentTrack
        lda track_table_module_low, x
        ldy track_table_module_high, x
        far_call bhop_set_module_addr

        ldx MusicCurrentTrack
        lda track_table_bank, x
        far_call bhop_set_module_bank

        perform_zpcm_inc

        ldx MusicCurrentTrack
        lda track_table_song, x
        near_call bhop_init

        ; init some custom bhop features here as well
        lda #0
        sta target_music_variant
        lda #0
        sta global_attenuation

        lda #0
        sta UpdateBeatTrackerDuringNmi

        lda #$FF
        sta DeferredSfxPriorityPulse1
        sta DeferredSfxPriorityPulse2
        sta DeferredSfxPriorityTriangle
        sta DeferredSfxPriorityNoise

        restore_previous_bank

        rts
.endproc

.proc FAR_update_audio
        near_call update_fade
        
        access_data_bank_nmi MusicCurrentBank
        perform_zpcm_inc
        far_call_nmi bhop_play
        restore_previous_bank_nmi

        perform_zpcm_inc

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_sfx
use_ntsc_sfx:
        access_data_bank_nmi #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank_nmi #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        near_call update_sfx
        restore_previous_bank_nmi
        perform_zpcm_inc

        lda UpdateBeatTrackerDuringNmi
        beq skip_beat_tracker
        jsr update_beat_tracker
        perform_zpcm_inc
skip_beat_tracker:

        rts
.endproc

.proc FAR_queue_deferred_sounds
        lda DeferredSfxPriorityPulse1
        cmp #$FF
        beq skip_pulse_1
        sta CandidateSfxPriority
        lda DeferredSfxPtrPulse1+0
        sta CandidateSfxPtr+0
        lda DeferredSfxPtrPulse1+1
        sta CandidateSfxPtr+1
        jsr _play_sfx_pulse1
        lda #$FF
        sta DeferredSfxPriorityPulse1
skip_pulse_1:

        lda DeferredSfxPriorityPulse2
        cmp #$FF
        beq skip_pulse_2
        sta CandidateSfxPriority
        lda DeferredSfxPtrPulse2+0
        sta CandidateSfxPtr+0
        lda DeferredSfxPtrPulse2+1
        sta CandidateSfxPtr+1
        jsr _play_sfx_pulse2
        lda #$FF
        sta DeferredSfxPriorityPulse2
skip_pulse_2:

        lda DeferredSfxPriorityTriangle
        cmp #$FF
        beq skip_triangle
        sta CandidateSfxPriority
        lda DeferredSfxPtrTriangle+0
        sta CandidateSfxPtr+0
        lda DeferredSfxPtrTriangle+1
        sta CandidateSfxPtr+1
        jsr _play_sfx_triangle
        lda #$FF
        sta DeferredSfxPriorityTriangle
skip_triangle:

        lda DeferredSfxPriorityNoise
        cmp #$FF
        beq skip_noise
        sta CandidateSfxPriority
        lda DeferredSfxPtrNoise+0
        sta CandidateSfxPtr+0
        lda DeferredSfxPtrNoise+1
        sta CandidateSfxPtr+1
        jsr _play_sfx_noise
        lda #$FF
        sta DeferredSfxPriorityNoise
skip_noise:
        rts
.endproc

.proc update_fade
        perform_zpcm_inc
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
        ldy #TRACK_VARIANT_NORMAL
        near_call FAR_play_track
done_with_fade:
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
        near_call bhop_unmute_channel
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
        near_call bhop_unmute_channel
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
        near_call bhop_unmute_channel
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
        near_call bhop_unmute_channel
done:
        rts
.endproc

.proc update_sfx
        perform_zpcm_inc
        near_call update_pulse1
        perform_zpcm_inc
        near_call update_pulse2
        perform_zpcm_inc
        near_call update_triangle
        perform_zpcm_inc
        near_call update_noise
        perform_zpcm_inc

        lda #0
        sta Pulse1Priority
        sta Pulse2Priority
        sta TrianglePriority
        sta NoisePriority

        rts
.endproc
