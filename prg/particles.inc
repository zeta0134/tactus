PARTICLE_ACTIVE      = %10000000
PARTICLE_FLICKER     = %01000000

MAX_ACTIVE_PARTICLES = 16

; Any figure that is coprime with the number of displayed
; particles will do here, ideally around 2/3 of the total
PARTICLE_OAM_ADVANCE_AMOUNT = 5

.global FAR_init_particles ; also clear all previous particles, use sparingly
.global FAR_draw_particles
.global NextParticleIndex
.global particles, init_particle

.global a_test_particle

; Note: make sure this is an ODD number of bytes in size! This is important
; for flicker detection
.struct ParticleState
        BasePosX .byte
        BasePosY .byte
        Lifetime .byte
        Behavior .byte
        DataPtr .word
        ParityByte .byte
.endstruct

.struct ParticleDataEntry
        PosX .byte
        PosY .byte
        TileId .byte
        Attributes .byte
.endstruct

; clobbers A, X, Y
.macro spawn_particle particle_type, pos_x, pos_y
        ldx NextParticleIndex
        lda pos_x
        sta particles + ParticleState::BasePosX, x
        lda pos_y
        sta particles + ParticleState::BasePosY, x
.if (.match (.left (1, {particle_type}), #))
        lda #<(.right (.tcount ({particle_type})-1, {particle_type}))
        sta particles + ParticleState::DataPtr+0, x
        lda #>(.right (.tcount ({particle_type})-1, {particle_type}))
        sta particles + ParticleState::DataPtr+1, x
.else
        lda particle_type+0
        sta particles + ParticleState::DataPtr+0, x
        lda particle_type+1
        sta particles + ParticleState::DataPtr+1, x
.endif
        jsr init_particle
.endmacro
