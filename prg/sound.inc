.global FAR_play_track
.global FAR_play_variant
.global FAR_fade_to_track

; fixed stubs
.global _play_sfx_pulse1
.global _play_sfx_pulse2
.global _play_sfx_triangle
.global _play_sfx_noise

.global FAR_init_audio
.global FAR_update_audio
.global FAR_queue_deferred_sounds

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

.global sfx_cast_pulse

.global sfx_party_pulse1
.global sfx_party_pulse2
.global sfx_cartoony_fall_tri

.global sfx_low_noise
.global sfx_scorch_noise

.global sfx_shock_noise
.global sfx_shock_pulse

.global sfx_fae_pulse1
.global sfx_fae_pulse2

.global sfx_chill_pulse1
.global sfx_chill_pulse2

.global sfx_go_go_pulse

.global sfx_puzzle_success_pulse
.global sfx_puzzle_success_tri

.global sfx_stealthy_pulse

.global sfx_item_recharge_tri

.global sfx_weapon_charging_pulse

.global sfx_dingbat

.global sfx_roar_pulse1
.global sfx_roar_pulse2

.global CandidateSfxPtr
.global CandidateSfxPriority

.global Pulse1RowCounter
.global Pulse2RowCounter
.global Pulse1DelayCounter
.global Pulse2DelayCounter

.global DeferredSfxPtrPulse1
.global DeferredSfxPriorityPulse1
.global DeferredSfxPtrPulse2
.global DeferredSfxPriorityPulse2
.global DeferredSfxPtrTriangle
.global DeferredSfxPriorityTriangle
.global DeferredSfxPtrNoise
.global DeferredSfxPriorityNoise

.global UpdateBeatTrackerDuringNmi

TRACK_SILENCE          = 0
TRACK_CLICK            = 1
TRACK_TITLE            = 2
;TRACK_TITLE            = 8 ; useful if we need an in-engine piano roll render
TRACK_OPTIONS          = 3
TRACK_GAMEOVER         = 4
TRACK_SHOWER_GROOVE    = 5
TRACK_IN_ANOTHER_WORLD = 6
TRACK_BOUNCY           = 7
TRACK_ECHOES           = 8
TRACK_OPTIONS_DUP_1    = 9  ; these exist as a cheap way to force a track re-init when changing BGM modes
TRACK_OPTIONS_DUP_2    = 10 ; these exist as a cheap way to force a track re-init when changing BGM modes

TRACK_VARIANT_NORMAL   = 0 ; every track has this
TRACK_VARIANT_INTERIOR = 1 ; most level themes have these
TRACK_VARIANT_PAUSE    = 2 ; and these
TRACK_VARIANT_CLICK    = 3 ; replaces the debug click track song. these still respect the intended tempo
TRACK_VARIANT_SILENT   = 4 ; same deal but it's absolute silence.

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

.macro defer_sfx_pulse1_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta DeferredSfxPtrPulse1+0
        lda #>sound_ptr
        sta DeferredSfxPtrPulse1+1
        lda priority
        sta DeferredSfxPriorityPulse1
.endmacro

; This macro is even more cautious: if any other sound is playing,
; regardless of when it started, back off and do nothing. Good for
; short flavor sounds that should never interrupt longer gameplay
; relevant things.

.macro queue_sfx_pulse1_with_lowest_priority sound_ptr
.scope
        lda Pulse1RowCounter
        ora Pulse1DelayCounter
        bne skip
        lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda #0
        sta CandidateSfxPriority
        jsr _play_sfx_pulse1
skip:
.endscope
.endmacro

.macro queue_sfx_pulse1 sound_ptr
        queue_sfx_pulse1_with_priority sound_ptr, #0
.endmacro

.macro queue_sfx_pulse1_ptr sound_ptr
        queue_sfx_pulse1_with_priority_ptr sound_ptr, #0
.endmacro

.macro defer_sfx_pulse1 sound_ptr
        defer_sfx_pulse1_with_priority sound_ptr, #0
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

.macro defer_sfx_pulse2_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta DeferredSfxPtrPulse2+0
        lda #>sound_ptr
        sta DeferredSfxPtrPulse2+1
        lda priority
        sta DeferredSfxPriorityPulse2
.endmacro

.macro queue_sfx_pulse2_with_lowest_priority sound_ptr
.scope
        lda Pulse2RowCounter
        ora Pulse2DelayCounter
        bne skip
        lda #<sound_ptr
        sta CandidateSfxPtr+0
        lda #>sound_ptr
        sta CandidateSfxPtr+1
        lda #0
        sta CandidateSfxPriority
        jsr _play_sfx_pulse2
skip:
.endscope
.endmacro

.macro queue_sfx_pulse2 sound_ptr
        queue_sfx_pulse2_with_priority sound_ptr, #0
.endmacro

.macro defer_sfx_pulse2 sound_ptr
        defer_sfx_pulse2_with_priority sound_ptr, #0
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

.macro defer_sfx_triangle_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta DeferredSfxPtrTriangle+0
        lda #>sound_ptr
        sta DeferredSfxPtrTriangle+1
        lda priority
        sta DeferredSfxPriorityTriangle
.endmacro

.macro queue_sfx_triangle sound_ptr
        queue_sfx_triangle_with_priority sound_ptr, #0
.endmacro

.macro defer_sfx_triangle sound_ptr
        defer_sfx_triangle_with_priority sound_ptr, #0
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

.macro defer_sfx_noise_with_priority sound_ptr, priority
        lda #<sound_ptr
        sta DeferredSfxPtrNoise+0
        lda #>sound_ptr
        sta DeferredSfxPtrNoise+1
        lda priority
        sta DeferredSfxPriorityNoise
.endmacro

.macro queue_sfx_noise sound_ptr
        queue_sfx_noise_with_priority sound_ptr, #0
.endmacro

.macro defer_sfx_noise sound_ptr
        defer_sfx_noise_with_priority sound_ptr, #0
.endmacro