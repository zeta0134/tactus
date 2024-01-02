; what one copy of the sprite copy code looks like, with all the bytes indexed
.struct SelfModifiedSprite
    __lda1 .byte
    PosY .byte 
    __sta1 .byte 
    __oamdata1 .word 
    __lda2 .byte 
    TileId .byte 
    __sta2 .byte 
    __oamdata2 .word 
    __lda3 .byte 
    Attributes .byte 
    __sta3 .byte 
    __oamdata3 .word 
    __lda4 .byte 
    PosX .byte 
    __sta4 .byte 
    __oamdata4 .word 
.endstruct

.global run_slowam, slowam_irq, setup_slowam_irq
.global FAR_init_slowam
.global sprite_ptr_lut_low, sprite_ptr_lut_high