    .include "math_util.inc"
    .include "zpcm.inc"

    .zeropage
prodlo: .res 1
factor2: .res 1

quotient: ; low byte of dividend
dividend: .res 2
divisor: .res 1

    .segment "PRGFIXED_E000"
    
; Credit Tepples, taken from https://www.nesdev.org/wiki/8-bit_Multiply
; @param A one factor
; @param Y another factor
; @return low 8 bits in A; high 8 bits in Y
mul8_multiply:
    lsr
    sta prodlo
    tya
    beq mul8_early_return
    dey
    sty factor2
    lda #0
.repeat 8, i
    perform_zpcm_inc
    .if i > 0
        ror prodlo
    .endif
    bcc :+
    adc factor2
:
    ror
.endrepeat
    tay
    lda prodlo
    ror
mul8_early_return:
    rts


; Adapted from http://6502org.wikidot.com/software-math-intdiv
div16_divide:
   LDA dividend+1
   LDX #8
   ASL dividend+0
L1:
   ROL
   BCS L2
   CMP divisor
   BCC L3
L2:
   SBC divisor
;
; The SEC is needed when the BCS L2 branch above was taken
;
   SEC
L3:
   ROL dividend+0
   perform_zpcm_inc
   DEX
   BNE L1
   RTS