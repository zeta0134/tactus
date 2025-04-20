        .include "../build/tile_defs.inc"

        .include "charmap.inc"
        .include "text_util.inc"
        .include "word_util.inc"
        .include "zpcm.inc"

        .zeropage
; Scratch bytes exclusive to text-drawing utilities. About 8 should be plenty
; This keeps these utilities global, permitting call sites to not clobber their
; own stack frames
T0: .res 1
T1: .res 1
T2: .res 1
T3: .res 1
T4: .res 1
T5: .res 1
T6: .res 1
T7: .res 1

        ; TODO: should we move smaller utilities into fixed?
        .segment "CODE_0"

; given a 16bit number, computes the individual digit tiles (in base 10)
; does not actually draw the number, meant to be consumed by other routines
; that perform this task
.proc FAR_base_10_old_chrram
NumberWord := T0
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5
TenThousandsDigit := T6
        perform_zpcm_inc

        lda #NUMBERS_BASE
        sta TenThousandsDigit
ten_thousands_loop:
        cmp16 NumberWord, #10000
        bcc compute_thousands
        inc TenThousandsDigit
        sub16w NumberWord, 10000
        jmp ten_thousands_loop

compute_thousands:
        lda #NUMBERS_BASE
        sta ThousandsDigit
thousands_loop:
        cmp16 NumberWord, #1000
        bcc compute_hundreds
        inc ThousandsDigit
        sub16w NumberWord, 1000
        jmp thousands_loop

compute_hundreds:
        lda #NUMBERS_BASE
        sta HundredsDigit
hundreds_loop:
        cmp16 NumberWord, #100
        bcc compute_tens
        inc HundredsDigit
        sub16w NumberWord, 100
        jmp hundreds_loop

compute_tens:
        lda #NUMBERS_BASE
        sta TensDigit
tens_loop:
        cmp16 NumberWord, #10
        bcc compute_ones
        inc TensDigit
        sub16w NumberWord, 10
        jmp tens_loop

compute_ones:
        ; at this stage, NumberWord's lowest byte is already
        ; between 0 and 9, so just use it directly
        lda NumberWord+0
        clc
        adc #NUMBERS_BASE
        sta OnesDigit

        rts
.endproc

; given a 16bit number, computes the individual digit tiles (in base 10)
; does not actually draw the number, meant to be consumed by other routines
; that perform this task
.proc FAR_base_10
NumberWord := T0
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5
TenThousandsDigit := T6
        perform_zpcm_inc

        lda #0
        sta TenThousandsDigit
ten_thousands_loop:
        cmp16 NumberWord, #10000
        bcc compute_thousands
        inc TenThousandsDigit
        sub16w NumberWord, 10000
        jmp ten_thousands_loop

compute_thousands:
        perform_zpcm_inc
        lda #0
        sta ThousandsDigit
thousands_loop:
        cmp16 NumberWord, #1000
        bcc compute_hundreds
        inc ThousandsDigit
        sub16w NumberWord, 1000
        jmp thousands_loop

compute_hundreds:
        perform_zpcm_inc
        lda #0
        sta HundredsDigit
hundreds_loop:
        cmp16 NumberWord, #100
        bcc compute_tens
        inc HundredsDigit
        sub16w NumberWord, 100
        jmp hundreds_loop

compute_tens:
        perform_zpcm_inc
        lda #0
        sta TensDigit
tens_loop:
        cmp16 NumberWord, #10
        bcc compute_ones
        inc TensDigit
        sub16w NumberWord, 10
        jmp tens_loop

compute_ones:
        perform_zpcm_inc
        ; at this stage, NumberWord's lowest byte is already
        ; between 0 and 9, so just use it directly
        lda NumberWord+0
        sta OnesDigit

        perform_zpcm_inc
        rts
.endproc

; put the coordinate base in T4,T5
; resulting nametable offset is ADDED to T0, T2
; (so you should seed those with the base addresses)
.proc FAR_nametable_from_coordinates
NametableAddr := T0
AttributeAddr := T2
TileX := T4
TileY := T5
OffsetScratch := T6
        lda TileY
        sta OffsetScratch+0
        lda #0
        sta OffsetScratch+1

        .repeat 5
        asl OffsetScratch+0
        rol OffsetScratch+1
        .endrepeat

        clc
        lda TileX
        adc OffsetScratch+0
        sta OffsetScratch+0

        clc
        lda NametableAddr+0
        adc OffsetScratch+0
        sta NametableAddr+0
        lda NametableAddr+1
        adc OffsetScratch+1
        sta NametableAddr+1

        clc
        lda AttributeAddr+0
        adc OffsetScratch+0
        sta AttributeAddr+0
        lda AttributeAddr+1
        adc OffsetScratch+1
        sta AttributeAddr+1

        perform_zpcm_inc
        rts
.endproc