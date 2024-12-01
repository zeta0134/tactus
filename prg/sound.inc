.global play_track
.global play_variant
.global fade_to_track

.global _play_sfx_pulse1
.global _play_sfx_pulse2
.global _play_sfx_triangle
.global _play_sfx_noise

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

.global sfx_pause

.global sfx_dialog_text_variant_1
.global sfx_dialog_text_variant_2
.global sfx_dialog_text_variant_3
.global sfx_dialog_advance
.global sfx_dialog_close
.global sfx_cursor_fail

.global sfx_siren_pulse_1
.global sfx_siren_pulse_2

.global sfx_kaboom_pulse_1
.global sfx_kaboom_pulse_2
.global sfx_kaboom_noise
.global sfx_hoist_pulse
.global sfx_throw_pulse

.global CandidateSfxPtr
.global CandidateSfxPriority

TRACK_SILENCE          = 0
TRACK_CLICK            = 1
TRACK_TITLE            = 2
TRACK_OPTIONS          = 3
TRACK_GAMEOVER         = 4
TRACK_SHOWER_GROOVE    = 5
TRACK_IN_ANOTHER_WORLD = 6
TRACK_BOUNCY           = 7

TRACK_VARIANT_NORMAL   = 0 ; every track has this
TRACK_VARIANT_INTERIOR = 1 ; most level themes have these
TRACK_VARIANT_PAUSE    = 2

; 0 is the lowest priority, which seems like a reasonable default.
; For many games this is sufficient; the newest sound wins. Priority
; is helpful in complex situations where you need to choose between
; several otherwise conflicting candidate sounds on the same frame.

.macro queue_sfx_pulse1_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda priority
        sta CandidateSfxPriority
        jsr _play_sfx_pulse1
.endmacro

.macro queue_sfx_pulse1_with_priority_ptr sound_ptr, priority
        lda sound_ptr+0
        sta CandidateSfxPtr+0
        lda sound_ptr+1
        sta CandidateSfxPtr+1
        lda priority
        sta CandidateSfxPriority
        jsr _play_sfx_pulse1
.endmacro

.macro queue_sfx_pulse1 sound_ptr
        queue_sfx_pulse1_with_priority sound_ptr, #0
.endmacro

.macro queue_sfx_pulse1_ptr sound_ptr
        queue_sfx_pulse1_with_priority_ptr sound_ptr, #0
.endmacro

.macro queue_sfx_pulse2_with_priority sound_ptr, priority
lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda priority
        sta CandidateSfxPriority
        jsr _play_sfx_pulse2
.endmacro

.macro queue_sfx_pulse2 sound_ptr
        queue_sfx_pulse2_with_priority sound_ptr, #0
.endmacro

.macro queue_sfx_triangle_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda priority
        sta CandidateSfxPriority
        jsr _play_sfx_triangle
.endmacro

.macro queue_sfx_triangle sound_ptr
        queue_sfx_triangle_with_priority sound_ptr, #0
.endmacro

.macro queue_sfx_noise_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda priority
        sta CandidateSfxPriority
        jsr _play_sfx_noise
.endmacro

.macro queue_sfx_noise sound_ptr
        queue_sfx_noise_with_priority sound_ptr, #0
.endmacro
