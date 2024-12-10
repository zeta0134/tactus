PARTICLE_ACTIVE      = %10000000
PARTICLE_FLICKER     = %01000000

MAX_ACTIVE_PARTICLES = 16

; Any figure that is coprime with the number of displayed
; particles will do here, ideally around 2/3 of the total
PARTICLE_OAM_ADVANCE_AMOUNT = 5

; Note: make sure this is an even number of bytes in size! This is important
; for flicker detection
.struct ParticleState
        BasePosX .byte
        BasePosY .byte
        Lifetime .byte
        Behavior .byte
        DataPtr .word
.endstruct

.struct ParticleDataEntry
        PosX .byte
        PosY .byte
        TileId .byte
        Attributes .byte
.endstruct

.global FAR_init_particles ; also clear all previous particles, use sparingly
.global FAR_draw_particles
