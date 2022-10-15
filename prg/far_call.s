        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"

        .zeropage
TargetBank: .byte $00
CurrentBank: .byte $00
JumpTarget: .word $0000

        .segment "PRGFIXED_C000"

.proc launch_far_call
        ; crash on purpose
        brk
        rts ; never reached
.endproc
