.global play_track
.global play_variant
.global fade_to_track
.global play_sfx_pulse1
.global play_sfx_pulse2
.global play_sfx_triangle
.global play_sfx_noise
.global play_sfx_dpcm

.global FAR_init_audio
.global FAR_update_audio

; rhythm game
.global sfx_defeat_enemy_noise
.global sfx_defeat_enemy_pulse
.global sfx_coin
.global sfx_heart_container
.global sfx_small_heart
.global sfx_key_pulse1
.global sfx_key_pulse2
.global sfx_weapon_slash

.global sfx_teleport
.global sfx_weak_hit_pulse
.global sfx_weak_hit_tri
.global sfx_weak_hit_noise
.global sfx_cash_flow

.global sfx_death_spin_pulse
.global sfx_death_spin_tri
.global sfx_death_splat_noise

.global sfx_equip_ability_pulse1
.global sfx_equip_ability_pulse2

.global sfx_move_cursor
.global sfx_select_cursor
.global sfx_too_poor_pulse1
.global sfx_too_poor_pulse2

.macro play_dpcm sample_addr, length
.scope
SampleAddr := R0
SampleLength := R1
SampleRate := R2
SampleBank := R3
SfxFrames := R4
        lda #<((sample_addr  - $C000) >> 6)
        sta SampleAddr
        lda #<(.bank(sample_addr))
        sta SampleBank

        lda #((length - 1) / 16)
        sta SampleLength
        lda #(length / 69)
        sta SfxFrames

        ; for now, all triggered dpcm SFX are at the max rate
        lda #$0F
        sta SampleRate
        jsr play_sfx_dpcm
.endscope
.endmacro

TRACK_SILENCE          = 0
TRACK_CLICK            = 1
TRACK_TITLE            = 2
TRACK_OPTIONS          = 3
TRACK_GAMEOVER         = 4
TRACK_SHOWER_GROOVE    = 5
TRACK_IN_ANOTHER_WORLD = 6
