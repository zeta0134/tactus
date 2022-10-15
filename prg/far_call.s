        .setcpu "6502"
        .include "action53.inc"
        .include "far_call.inc"
        .include "nes.inc"

        .zeropage
TargetBank: .byte $00
CurrentBank: .byte $00
JumpTarget: .word $0000

        .segment "PRGFIXED_C000"

.proc launch_far_call
        ; preserve the current bank
        lda CurrentBank
        pha

        a53_set_prg TargetBank

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
        a53_set_prg CurrentBank

finished:
        rts
.endproc
