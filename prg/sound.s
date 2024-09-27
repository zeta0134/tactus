        .setcpu "6502"

        .macpack longbranch
        
        .include "bhop/bhop.inc"
        .include "debug.inc"
        .include "beat_tracker.inc"
        .include "far_call.inc"
        .include "pal.inc"
        .include "rainbow.inc"
        .include "slowam.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .import sfx_data_ntsc
        .import sfx_data_pal

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
        .proc zeta_options
        .include "../art/music/options.asm"
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

        .segment "PRGFIXED_E000"

; todo: figure out if we can move this elsewhere? it might grow

track_table_module_low:
        .lobytes zeta_silence
        .lobytes zeta_click_track
        .lobytes zeta_title
        .lobytes zeta_options
        .lobytes zeta_game_over
        .lobytes zeta_shower_groove
        .lobytes persune_in_another_world
        .lobytes zeta_bouncy

track_table_module_high:
        .hibytes zeta_silence
        .hibytes zeta_click_track
        .hibytes zeta_title
        .hibytes zeta_options
        .hibytes zeta_game_over
        .hibytes zeta_shower_groove
        .hibytes persune_in_another_world
        .hibytes zeta_bouncy

track_table_bank:
        .lobytes .bank(zeta_silence)
        .lobytes .bank(zeta_click_track)
        .lobytes .bank(zeta_title)
        .lobytes .bank(zeta_options)
        .lobytes .bank(zeta_game_over)
        .lobytes .bank(zeta_shower_groove)
        .lobytes .bank(persune_in_another_world)
        .lobytes .bank(zeta_bouncy)
        
track_table_song:
        .byte 0 ; silence (used for transitions)
        .byte 0 ; click track (meant for debugging)
        .byte 0 ; title
        .byte 0 ; options
        .byte 0 ; gameover
        .byte 0 ; shower groove
        .byte 0 ; in another world (warp zone)
        .byte 0 ; bouncy

track_table_num_variants:
        .byte 1 ; silence 
        .byte 1 ; click_track
        .byte 1 ; title music
        .byte 1 ; options music
        .byte 1 ; gameover music
        .byte 1 ; level music
        .byte 3 ; in another world (warp zone)
        .byte 3 ; bouncy

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
        ; set the PCM address to $5011 when doing slow OAM transfers
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
        ora #16
        sta MAP_PRG_8_LO

        lda #(3 + 16)
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


; interface functions should mostly live in fixed; we'll call these often, and several
; need A to remain unclobbered

.proc fade_to_track
        perform_zpcm_inc
        sta MusicTargetTrack
        lda #FADE_SPEED
        sta FadeCounter
        ; special case: is our current track 0, silence? If so, start playback immediately
        lda MusicCurrentTrack
        bne done
        lda MusicTargetTrack
        ldy #TRACK_VARIANT_NORMAL
        jsr play_track
done:
        rts
.endproc

; inputs: track number in A, initial variant in Y
.proc play_track
        perform_zpcm_inc
        .if ::DEBUG_DISABLE_MUSIC
        ; ignore the requested track, and queue up the click track instead
        lda #1
        .endif
        sty target_music_variant

        cmp MusicCurrentTrack
        jeq no_change
        sta MusicCurrentTrack
        sta MusicTargetTrack
        tax
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
        far_call bhop_init
        lda #0
        sta global_attenuation
        restore_previous_bank

        far_call FAR_beat_tracker_init

no_change:
        ; safely re-apply the current music variant (again)
        ; to be sure it is applied even if we did not actually change songs
        lda target_music_variant
        jsr play_variant

        rts
.endproc

; inputs: variant number in A
.proc play_variant
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

.proc play_sfx_pulse1
SfxPtr := R0
        perform_zpcm_inc

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
        far_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc play_sfx_pulse2
SfxPtr := R0
        perform_zpcm_inc

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
        far_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc play_sfx_triangle
SfxPtr := R0
        perform_zpcm_inc

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
        far_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

.proc play_sfx_noise
SfxPtr := R0
        perform_zpcm_inc

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
        far_call bhop_mute_channel
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

; Everything else goes in the switched bank
        .segment "CODE_SOUND"

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
        access_data_bank #<.bank(sfx_data_ntsc)
        jmp done_picking_sfx_bank
use_pal_sfx:
        access_data_bank #<.bank(sfx_data_pal)
        jmp done_picking_sfx_bank
done_picking_sfx_bank:

        near_call update_sfx
        restore_previous_bank_nmi

        perform_zpcm_inc
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
        jsr play_track
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
        rts
.endproc
