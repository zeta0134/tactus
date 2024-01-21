        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"
        .include "rainbow.inc"

        .zeropage
TargetBank: .byte $00
CurrentBank: .byte $00
CurrentDataBank: .byte $00
JumpTarget: .word $0000
FarCallScratchA: .byte $00

; a second copy of all of that state, for creating a temporary
; NMI stack frame. This will be completely torn down between
; calls to NMI, so the final bank we arrive at is irrelevant
NmiTargetBank: .byte $00
NmiCurrentBank: .byte $00
NmiJumpTarget: .word $0000
NmiFarCallScratchA: .byte $00


        .segment "PRGFIXED_E000"

.proc launch_far_call
        ; preserve the current bank
        lda CurrentBank
        pha

        rainbow_set_code_bank TargetBank

        lda TargetBank
        sta CurrentBank
        
        ; setup indirect jump to the far call address
        lda #>(return_from_indirect-1)
        pha
        lda #<(return_from_indirect-1)
        pha

        ; just before making the call, restore A
        ; (we preserved this in the macro that got us here)
        lda FarCallScratchA

        jmp (JumpTarget)
return_from_indirect:
        ; (rts removes return address)
        ; restore the original bank
        pla
        sta CurrentBank
        rainbow_set_code_bank CurrentBank

finished:
        rts
.endproc

.proc launch_nmi_far_call
        ; preserve the current bank
        lda NmiCurrentBank
        pha

        rainbow_set_code_bank NmiTargetBank

        lda NmiTargetBank
        sta NmiCurrentBank
        
        ; setup indirect jump to the far call address
        lda #>(return_from_indirect-1)
        pha
        lda #<(return_from_indirect-1)
        pha

        ; just before making the call, restore A
        ; (we preserved this in the macro that got us here)
        lda NmiFarCallScratchA

        jmp (NmiJumpTarget)
return_from_indirect:
        ; (rts removes return address)
        ; restore the original bank
        pla
        sta NmiCurrentBank
        rainbow_set_code_bank NmiCurrentBank

finished:
        rts
.endproc