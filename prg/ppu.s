        .setcpu "6502"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "PRGFIXED_C000"

bg_palette:
        .incbin "../art/test_palette.pal"

.proc initialize_ppu
        ; disable rendering
        lda #$00
        sta PPUMASK
        sta PPUCTRL

        ; Set PPUADDR to 0,0
        set_ppuaddr #$2000

        ; Zero out all four nametables
        st16 R0, ($1000)
        dec16 R0
loop:
        lda #0
        sta PPUDATA
        dec16 R0 ; sets A to 0xFF
        cmp R0+1
        bne loop

        ; Re-Set PPUADDR to 0,0
        lda #$00
        sta PPUADDR
        sta PPUADDR

        rts
.endproc

.proc initialize_palettes
        ;  Set the palettes up with a nice greyscale for everything

        ; disable rendering
        lda #$00
        sta PPUMASK

        ; Backgrounds
        set_ppuaddr #$3F00

        ldx #0
loop:
        lda bg_palette, x
        sta PPUDATA
        inx
        cpx #16
        bne loop

        ; Sprites
        ; gray!
        set_ppuaddr #$3F11
        lda #$0F
        sta PPUDATA
        lda #$10
        sta PPUDATA
        lda #$20
        sta PPUDATA

        ; red!
        set_ppuaddr #$3F15
        lda #$06
        sta PPUDATA
        lda #$26
        sta PPUDATA
        lda #$36
        sta PPUDATA

        ; blue!
        set_ppuaddr #$3F19
        lda #$01
        sta PPUDATA
        lda #$21
        sta PPUDATA
        lda #$31
        sta PPUDATA

        ; green(ish)!
        set_ppuaddr #$3F1D
        lda #$09
        sta PPUDATA
        lda #$29
        sta PPUDATA
        lda #$39
        sta PPUDATA

        ; Reset PPUADDR to 0,0
        lda #$00
        sta PPUADDR
        sta PPUADDR

        rts
.endproc
