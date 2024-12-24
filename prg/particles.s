        .include "../build/tile_defs.inc"

        .include "_globals.inc"
; Hoo boy. For now let's not do banking.
        .include "particles.inc"

        .include "far_call.inc"
        .include "kernel.inc"
        .include "slowam.inc"
        .include "sprites.inc"
        .include "rainbow.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "PRGRAM"

particles: .res ::MAX_ACTIVE_PARTICLES * .sizeof(ParticleState)

CurrentOamIndex: .res 1
NextParticleIndex: .res 1

        .segment "DATA_PARTICLES"
particle_data_segment:

        ; A coin which simply rises into the air over 30 frames
a_test_particle:
        .byte 30, (PARTICLE_ACTIVE | PARTICLE_FLICKER)
        .repeat 30, i
        .byte 0, <-i, <SPRITE_STATIC_00_PARTICLES_LIGHT_23 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat

particle_snow_a:
        .byte 60, (PARTICLE_ACTIVE | PARTICLE_FLICKER)
        .repeat 50, i
        .byte <-(i / 3), <(i / 3), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 5, i
        .byte <-((i+50) / 3), <((i+50) / 3), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 0 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 5, i
        .byte <-((i+55) / 3), <((i+55) / 3), <SPRITE_STATIC_00_PARTICLES_LIGHT_45 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat

particle_snow_b:
        .byte 60, (PARTICLE_ACTIVE | PARTICLE_FLICKER)
        .repeat 50, i
        .byte <-(i / 4), <(i / 3), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 0 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 10, i
        .byte <-((i+50) / 4), <((i+50) / 3), <SPRITE_STATIC_00_PARTICLES_LIGHT_45 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat

particle_snow_c:
        .byte 60, (PARTICLE_ACTIVE | PARTICLE_FLICKER)
        .repeat 50, i
        .byte <-(i / 3), <(i / 2), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 5, i
        .byte <-((i+50) / 3), <((i+50) / 2), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 0 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 5, i
        .byte <-((i+55) / 3), <((i+55) / 2), <SPRITE_STATIC_00_PARTICLES_LIGHT_45 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat

particle_snow_d:
        .byte 60, (PARTICLE_ACTIVE | PARTICLE_FLICKER)
        .repeat 50, i
        .byte <-(i / 4), <(i / 2), <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 0 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat
        .repeat 10, i
        .byte <-((i+50) / 4), <((i+50) / 2), <SPRITE_STATIC_00_PARTICLES_LIGHT_45 + 2 + SPRITE_OFFSET_STATIC_00, SPRITE_PAL_YELLOW
        .endrepeat

CONFETTI_ANIMATION_OFFSET_0 = 0
CONFETTI_ANIMATION_OFFSET_1 = 2
CONFETTI_ANIMATION_OFFSET_2 = 4
CONFETTI_ANIMATION_OFFSET_3 = 4
CONFETTI_ANIMATION_OFFSET_4 = 2
CONFETTI_ANIMATION_OFFSET_5 = 0

CONFETTI_FLIP_0 = 0
CONFETTI_FLIP_1 = 0
CONFETTI_FLIP_2 = 0
CONFETTI_FLIP_3 = SPRITE_HORIZ_FLIP
CONFETTI_FLIP_4 = SPRITE_HORIZ_FLIP
CONFETTI_FLIP_5 = SPRITE_HORIZ_FLIP

.macro confetti_particles horiz_speed, tile_base, color
        .byte 40, (PARTICLE_ACTIVE)
        .repeat 40, i
        animation_frame .set ((i / 2) .MOD 6)
        .byte <(i / horiz_speed)
        .byte <(i / 1)
        .byte <SPRITE_OFFSET_STATIC_00 + <tile_base + .ident(.concat("CONFETTI_ANIMATION_OFFSET_", .sprintf("%d", animation_frame)))
        .byte color + .ident(.concat("CONFETTI_FLIP_", .sprintf("%d", animation_frame)))
        .endrepeat
.endmacro

particle_confetti_a:
        confetti_particles -2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_PURPLE
particle_confetti_b:
        confetti_particles -5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_PURPLE
particle_confetti_c:
        confetti_particles  2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_PURPLE
particle_confetti_d:
        confetti_particles  5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_PURPLE

particle_confetti_e:
        confetti_particles -2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_RED
particle_confetti_f:
        confetti_particles -5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_RED
particle_confetti_g:
        confetti_particles  2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_RED
particle_confetti_h:
        confetti_particles  5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_RED

particle_confetti_i:
        confetti_particles -2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_YELLOW
particle_confetti_j:
        confetti_particles -5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_YELLOW
particle_confetti_k:
        confetti_particles  2, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_YELLOW
particle_confetti_l:
        confetti_particles  5, SPRITE_STATIC_00_PARTICLES_LIGHT_01, SPRITE_PAL_YELLOW

particle_confetti_m:
        confetti_particles -2, SPRITE_STATIC_00_PARTICLES_DARK_01, SPRITE_PAL_YELLOW
particle_confetti_n:
        confetti_particles -5, SPRITE_STATIC_00_PARTICLES_DARK_01, SPRITE_PAL_YELLOW
particle_confetti_o:
        confetti_particles  2, SPRITE_STATIC_00_PARTICLES_DARK_01, SPRITE_PAL_YELLOW
particle_confetti_p:
        confetti_particles  5, SPRITE_STATIC_00_PARTICLES_DARK_01, SPRITE_PAL_YELLOW


PETALS_ANIMATION_OFFSET_0 = 0
PETALS_ANIMATION_OFFSET_1 = 2
PETALS_ANIMATION_OFFSET_2 = 2
PETALS_ANIMATION_OFFSET_3 = 2
PETALS_ANIMATION_OFFSET_4 = 2
PETALS_ANIMATION_OFFSET_5 = 0

PETALS_FLIP_0 = 0
PETALS_FLIP_1 = 0
PETALS_FLIP_2 = 0
PETALS_FLIP_3 = SPRITE_HORIZ_FLIP
PETALS_FLIP_4 = SPRITE_HORIZ_FLIP
PETALS_FLIP_5 = SPRITE_HORIZ_FLIP

.macro petal_particles horiz_speed, tile_base, color
        .byte 120, (PARTICLE_ACTIVE)
        .repeat 110, i
        animation_frame .set ((i / 6) .MOD 6)
        .byte <(i / horiz_speed)
        .byte <(i / 5)
        .byte <SPRITE_OFFSET_STATIC_00 + <tile_base + .ident(.concat("PETALS_ANIMATION_OFFSET_", .sprintf("%d", animation_frame)))
        .byte color + .ident(.concat("PETALS_FLIP_", .sprintf("%d", animation_frame)))
        .endrepeat
        .repeat 5, i
        .byte <((i + 110) / horiz_speed)
        .byte <((i + 110) / 5) + 2
        .byte <SPRITE_OFFSET_STATIC_00 + <SPRITE_STATIC_00_PARTICLES_LIGHT_67 + 0
        .byte color
        .endrepeat
        .repeat 5, i
        .byte <((i + 115) / horiz_speed)
        .byte <((i + 115) / 5) + 2
        .byte <SPRITE_OFFSET_STATIC_00 + <SPRITE_STATIC_00_PARTICLES_LIGHT_45 + 2
        .byte color
        .endrepeat
.endmacro

particle_cherry_blossom_a:
        petal_particles -3, SPRITE_STATIC_00_PARTICLES_LIGHT_23 + 2, SPRITE_PAL_RED
particle_cherry_blossom_b:
        petal_particles -2, SPRITE_STATIC_00_PARTICLES_LIGHT_23 + 2, SPRITE_PAL_RED

zap_particle_white:
        .byte 33, (PARTICLE_ACTIVE)
        .byte 0, 21, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 0, 21, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 0, 21, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW

        .byte 1, 20, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1, 20, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1, 20, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW

        .byte 1, 16, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 1, 16, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1, 16, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW

        .byte 0, 14, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0, 14, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0, 14, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP

        .byte 0, 12, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 0, 12, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 0, 12, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW

        .byte 0, 10, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0, 10, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0, 10, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_45 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP

        .byte 1,  9, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1,  9, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1,  9, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW

        .byte 0,  6, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0,  6, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0,  6, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP

        .byte 1,  5, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1,  5, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW
        .byte 1,  5, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 2, SPRITE_PAL_YELLOW

        .byte 0,  2, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 0,  2, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW
        .byte 0,  2, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW

        .byte 0,  0, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0,  0, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_23 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP
        .byte 0,  0, <SPRITE_STATIC_01_PARTICLES_LIGHTNING_01 + SPRITE_OFFSET_STATIC_01 + 0, SPRITE_PAL_YELLOW | SPRITE_HORIZ_FLIP


        .segment "PRGFIXED_E000"

; Called immediately after writing new particle data
; into the active index, sets up some initial state
; and advances the index
; Input: Y = particle index to initialize
.proc init_particle
ParticlePtr := R0 ; TODO: not clobber R0 maybe?
        ; Read and initialize this particle's lifetime
        access_data_bank #<.bank(particle_data_segment)
        ; X is already our particle index at this point, so reuse that
        lda particles + ParticleState::DataPtr+0, x
        sta ParticlePtr+0
        lda particles + ParticleState::DataPtr+1, x
        sta ParticlePtr+1
        ldy #0
        lda (ParticlePtr), y
        sta particles + ParticleState::Lifetime, x
        ldy #1
        lda (ParticlePtr), y
        sta particles + ParticleState::Behavior, x ; sets behavior flags, mostly flicker, by particle type
advance_data_pointer:
        clc
        lda particles + ParticleState::DataPtr+0, x
        adc #2
        sta particles + ParticleState::DataPtr+0, x
        lda particles + ParticleState::DataPtr+1, x
        adc #0
        sta particles + ParticleState::DataPtr+1, x
        restore_previous_bank
advance_particle_index:
        clc
        lda NextParticleIndex
        adc #.sizeof(ParticleState)
        cmp #(::MAX_ACTIVE_PARTICLES * .sizeof(ParticleState))
        bne no_wraparound
        lda #0
no_wraparound:
        sta NextParticleIndex
        rts
.endproc

        .segment "CODE_PARTICLES"

.proc FAR_init_particles
        lda #0
        sta CurrentOamIndex
        sta NextParticleIndex
        .repeat ::MAX_ACTIVE_PARTICLES, i
        sta particles + (i * .sizeof(ParticleState)) + ParticleState::Behavior
        .endrepeat
        rts
.endproc

; Quickly-ish update and draw all the particles
.proc FAR_draw_particles
ParticlePtr := R0
SpritePtr := R2
CurrentParticleIndex := R4
        perform_zpcm_inc

        access_data_bank #<.bank(particle_data_segment)

        lda #0
        sta CurrentParticleIndex
particle_loop:
        perform_zpcm_inc
        ldx CurrentParticleIndex
        lda particles + ParticleState::Behavior, x
        bpl done_with_this_particle
        ; if this is a flicker-free particle, proceed to draw
        and #PARTICLE_FLICKER
        beq draw_this_paricle
        ; otherwise, only draw this particle if we are on an odd frame
        ; relative to its ID
        lda CurrentParticleIndex
        eor GameloopCounter
        and #%00000001
        beq age_this_particle
draw_this_paricle:
        ; Load this particle's data pointer
        lda particles + ParticleState::DataPtr+0, x
        sta ParticlePtr+0
        lda particles + ParticleState::DataPtr+1, x
        sta ParticlePtr+1
        ; Load the destination sprite pointer and advance
        ; its index (with wraparound)
        ldy CurrentOamIndex
        lda sprite_ptr_lut_low + PARTICLE_FIRST_OAM_INDEX, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high + PARTICLE_FIRST_OAM_INDEX, y
        sta SpritePtr+1
        lda CurrentOamIndex
        clc
        adc #PARTICLE_OAM_ADVANCE_AMOUNT
        and #(MAX_DISPLAYED_PARTICLES-1)
        sta CurrentOamIndex
        perform_zpcm_inc
        ; Copy the particle data into the sprite, accounting for particle offset
        ; Note: no overflow handling! Do that when spawning the particle; don't spawn
        ; particles in places that will look stupid when wrapping around the screen edges
        clc
        ldy #ParticleDataEntry::PosX
        lda (ParticlePtr), y
        adc particles + ParticleState::BasePosX, x
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        clc
        ldy #ParticleDataEntry::PosY
        lda (ParticlePtr), y
        adc particles + ParticleState::BasePosY, x
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #ParticleDataEntry::TileId
        lda (ParticlePtr), y
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        ldy #ParticleDataEntry::Attributes
        lda (ParticlePtr), y
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y
        perform_zpcm_inc
age_this_particle:
        ldx CurrentParticleIndex
        ; Advance this particle's data pointer
        clc
        lda particles + ParticleState::DataPtr+0, x
        adc #.sizeof(ParticleDataEntry)
        sta particles + ParticleState::DataPtr+0, x
        lda particles + ParticleState::DataPtr+1, x
        adc #0
        sta particles + ParticleState::DataPtr+1, x
        ; Decrement our lifetime and, if terminal, deactivate this particle
        dec particles + ParticleState::Lifetime, x
        bne done_with_this_particle
        lda #0
        sta particles + ParticleState::Behavior, x
done_with_this_particle:
        clc
        lda CurrentParticleIndex
        adc #.sizeof(ParticleState)
        cmp #(::MAX_ACTIVE_PARTICLES * .sizeof(ParticleState))
        beq all_done
        sta CurrentParticleIndex
        jmp particle_loop
all_done:

        restore_previous_bank

        perform_zpcm_inc
        rts
.endproc

