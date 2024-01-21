.global launch_far_call, launch_nmi_far_call
.globalzp TargetBank, CurrentBank, CurrentDataBank, JumpTarget, FarCallScratchA
.globalzp NmiTargetBank, NmiCurrentBank, NmiJumpTarget, NmiFarCallScratchA


; for calls from banked code to other banked code
.macro far_call label
.scope
        .assert .bank(*) <> .bank(label), error, "unnecessary far call"

        ; preserve A, which we are about to clobber
        sta FarCallScratchA
        
        lda #<.BANK(label)
        sta TargetBank
        lda #<(label)
        sta JumpTarget
        lda #>(label)
        sta JumpTarget+1
        jsr launch_far_call
.endscope
.endmacro

; same deal but it's from NMI, which needs an entirely different stack frame
.macro far_call_nmi label
.scope
        .assert .bank(*) <> .bank(label), error, "unnecessary far call"

        ; preserve A, which we are about to clobber
        sta NmiFarCallScratchA
        
        lda #<.BANK(label)
        sta NmiTargetBank
        lda #<(label)
        sta NmiJumpTarget
        lda #>(label)
        sta NmiJumpTarget+1
        jsr launch_nmi_far_call
.endscope
.endmacro

; for calls from banked code to other code within the same bank only
; try to use this instead of jsr for banked routines
.macro near_call label
.scope
        .assert .bank(*) = .bank(label), error, "unsafe near call"
        jsr label
.endscope
.endmacro

.macro access_data_bank TargetDataBank
        lda CurrentDataBank
        pha
        rainbow_set_data_bank TargetDataBank
        lda TargetDataBank
        sta CurrentDataBank
.endmacro

.macro restore_previous_bank
        pla
        sta CurrentDataBank
        rainbow_set_data_bank CurrentDataBank
.endmacro
