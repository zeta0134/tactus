; general purpose scratch, clobber mostly at will. (often used
; to build a stack frame, preserve that as needed, etc)
.globalzp R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15

; mostly used for scratch space in tile update routines, which are
; otherwise short on ZP due to all the engine state higher up in the
; stack frame
.globalzp R16,R17,R18,R19,R20

.globalzp GameloopCounter, LastNmi, NmiSoftDisable