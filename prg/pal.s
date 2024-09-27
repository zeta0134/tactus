; Credit to lidnariq, sourced from:
; https://forums.nesdev.org/viewtopic.php?p=140778#p140778
    .include "pal.inc"

    .segment "RAM"
system_type: .res 1

    .segment "PRGFIXED_E000"

.align 32
.proc detect_system_type
        ;;; the "nice" thing is that I'm using the PPU power-on wait to detect the video system-
        ;; A,X,Y are all 0 at entry

        ; Zeta: "Okay that's cute but I don't want to rely on it, and 
        ; "we have time to burn anyway so...."
        lda #0
        ldx #0
        ldy #0
@vwait1:
        bit $2002
        bpl @vwait1  ; at this point, about 27384 cycles have passed
@vwait2:
        inx
        bne @noincy
        iny
@noincy:
        bit $2002
        bpl @vwait2  ; at this point, about 57165 cycles have passed

;;; BUT because of a hardware oversight, we might have missed a vblank flag.
;;;  so we need to both check for 1Vbl and 2Vbl
;;; NTSC NES: 29780 cycles / 12.005 -> $9B0 or $1361 (Y:X)
;;; PAL NES:  33247 cycles / 12.005 -> $AD1 or $15A2
;;; Dendy:    35464 cycles / 12.005 -> $B8A or $1714

        tya
        cmp #16
        bcc @nodiv2
        lsr
@nodiv2:
        clc
        adc #<-9
        cmp #3
        bcc @noclip3
        lda #3
@noclip3:
;;; Right now, A contains 0,1,2,3 for NTSC,PAL,Dendy,Bad
        sta system_type
        rts
.endproc
