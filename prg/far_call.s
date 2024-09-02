        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"
        .include "rainbow.inc"

        .zeropage
TargetBank: .byte $00
CurrentBank: .byte $00
CurrentDataBankLow: .byte $00
CurrentDataBankHigh: .byte $00
FarCallScratchA: .byte $00

; a second copy of all of that state, for creating a temporary
; NMI stack frame. This will be completely torn down between
; calls to NMI, so the final bank we arrive at is irrelevant
NmiTargetBank: .byte $00
NmiCurrentBank: .byte $00
NmiFarCallScratchA: .byte $00

NmiCurrentDataBankLow: .byte $00
NmiCurrentDataBankHigh: .byte $00

; SMC targets for jumps
gameloop_trampoline: .res 1
JumpTarget: .word $0000
nmi_trampoline: .res 1
NmiJumpTarget: .word $0000

        .segment "PRGFIXED_E000"

JMP_ABS_OPCODE = $4C

.proc init_far_calls
        lda #JMP_ABS_OPCODE
        sta gameloop_trampoline
        sta nmi_trampoline
        rts
.endproc

.proc launch_far_call
        ; preserve the current bank
        lda CurrentBank
        pha

        rainbow_set_code_bank TargetBank

        lda TargetBank
        sta CurrentBank

        ; just before making the call, restore A
        ; (we preserved this in the macro that got us here)
        lda FarCallScratchA

        jsr gameloop_trampoline
return_from_indirect:
        sta FarCallScratchA
        ; (rts removes return address)
        ; restore the original bank
        pla
        sta CurrentBank
        rainbow_set_code_bank CurrentBank

        lda FarCallScratchA
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

        ; just before making the call, restore A
        ; (we preserved this in the macro that got us here)
        lda NmiFarCallScratchA

        jsr nmi_trampoline
return_from_indirect:
        sta NmiFarCallScratchA
        ; (rts removes return address)
        ; restore the original bank
        pla
        sta NmiCurrentBank
        rainbow_set_code_bank NmiCurrentBank

        lda NmiFarCallScratchA
finished:
        rts
.endproc