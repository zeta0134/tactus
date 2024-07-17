.include "nes.inc"
.include "rainbow.inc"
.include "slowam.inc"
.include "word_util.inc"
.include "zeropage.inc"
.include "zpcm.inc"

; Cursed Slow OAM "DMA", in 1632 cycles
; Drink responsibly

.segment "PRGFIXED_E000"

; to access an individual sprite quickly
sprite_ptr_lut_low:
.repeat 16, j
.repeat 4, i
    .byte <((20 * i) + (83 * j) + SPRITE_TRANSFER_BASE)
.endrepeat
.endrepeat

sprite_ptr_lut_high:
.repeat 16, j
.repeat 4, i
    .byte >((20 * i) + (83 * j) + SPRITE_TRANSFER_BASE)
.endrepeat
.endrepeat

.segment "CODE_0"

one_sprite_byte:
    lda #0 ; 2 bytes
    sta $2004 ; 3 bytes
one_zpcm_op:
    perform_zpcm_inc
the_rts_at_the_end:
    rts

; to generate the routine/table (assuming RAM is located at SPRITE_TRANSFER_BASE)
.proc FAR_init_slowam
DestPtr := R0
BlockCounter := R2
ByteCounter := R3
    perform_zpcm_inc
    st16 DestPtr, SPRITE_TRANSFER_BASE
    lda #16
    sta BlockCounter
    ldy #0
block_loop:
    ; for each block, copy in 16 OAM bytes
    lda #16
    sta ByteCounter
byte_loop:
    perform_zpcm_inc
    .repeat 5, i
    lda one_sprite_byte+i
    sta (DestPtr), y
    inc16 DestPtr
    .endrepeat
    dec ByteCounter
    bne byte_loop
    ; now copy in one ZPCM operation, then proceed to the next block
    .repeat 3, i
    lda one_zpcm_op+i
    sta (DestPtr), y
    inc16 DestPtr
    .endrepeat
    dec BlockCounter
    bne block_loop
    ; now at the end, finally copy in the RTS and we're done
    lda the_rts_at_the_end
    sta (DestPtr), y
    perform_zpcm_inc
    rts
.endproc


