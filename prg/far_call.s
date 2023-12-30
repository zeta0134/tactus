        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"
        .include "rainbow.inc"

        .zeropage
TargetBank: .byte $00
CurrentBank: .byte $00
JumpTarget: .word $0000

        .segment "PRGFIXED_C000"

.proc launch_far_call
        ; preserve the current bank
        lda CurrentBank
        pha

        rainbow_set_16k_prg TargetBank

        lda TargetBank
        sta CurrentBank
        
        ; setup indirect jump to the far call address
        lda #>(return_from_indirect-1)
        pha
        lda #<(return_from_indirect-1)
        pha
        jmp (JumpTarget)
return_from_indirect:
        ; (rts removes return address)
        ; restore the original bank
        pla
        sta CurrentBank
        rainbow_set_16k_prg CurrentBank

finished:
        rts
.endproc
