        .setcpu "6502"
        .include "memory_util.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "PRGFIXED_E000"

; Arguments:
; R0 - starting address (16bit)
; R2 - length (16bit)
; Both are clobbered
.proc clear_memory
MemoryAddress := R0
Length := R2
        ldy #0
        ; decrement once to start, since we exit when the counter reaches -1
        dec16 Length
loop:
        lda #0
        sta (MemoryAddress),y
        inc16 MemoryAddress
        dec16 Length ; sets A to 0xFF
        cmp Length+1 ; check if the high byte has rolled around to 0xFF; if so, terminate the loop
        bne loop
        rts
.endproc
