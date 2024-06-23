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

        .segment "PRGFIXED_E000"

; The most generic string drawing routine possible
; supports a max length up to 256, don't exceed this
; (really, don't exceed a max length of 32, since that
; may wrap poorly; do that manually elsewhere)
.proc FIXED_draw_string
NametableAddr := T0
AttributeAddr := T2
StringPtr := T4
TileBase := T6
PaletteIndex := T7
        ldy #0
loop:
        perform_zpcm_inc
        lda (StringPtr), y
        beq end_of_string
        sta (NametableAddr), y
        lda TileBase
        ora PaletteIndex
        sta (AttributeAddr), y
        iny
        jmp loop
end_of_string:
        rts
.endproc

; for when you need to erase a string and don't feel like futzing about
; with loads of extra padding
.proc FIXED_erase_string
NametableAddr := T0
AttributeAddr := T2
StringPtr := T4
TileBase := T6
PaletteIndex := T7
        ldy #0
loop:
        perform_zpcm_inc
        lda (StringPtr), y
        beq end_of_string
        lda #0
        sta (NametableAddr), y
        lda TileBase
        ora PaletteIndex
        sta (AttributeAddr), y
        iny
        jmp loop
end_of_string:
        rts
.endproc

; oh boy, this certainly won't cause memory corruption, no sir
; caveats: will infini-loop if it doesn't find a zero byte within a page
; maybe don't point it at bad data, etc. max length 255 bytes, etc etc
.proc FIXED_strlen
StringPtr := T0
Length := T2
        ldy #0
loop:
        perform_zpcm_inc
        lda (StringPtr), y
        beq end_of_string
        iny
        jmp loop
end_of_string:
        sty Length
        rts       
.endproc

        ; TODO: should we move smaller utilities into fixed?
        .segment "CODE_0"

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

        rts
.endproc