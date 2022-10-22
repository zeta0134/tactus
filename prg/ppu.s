        .setcpu "6502"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "PRGFIXED_C000"

bg_palette:
        .incbin "../art/test_palette.pal"
obj_palette:
        .incbin "../art/sprite_palette.pal"

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

        ; Sprites
        set_ppuaddr #$3F10

        ldx #0
obj_loop:
        lda obj_palette, x
        sta PPUDATA
        inx
        cpx #16
        bne obj_loop

        ; Backgrounds
        set_ppuaddr #$3F00

        ldx #0
bg_loop:
        lda bg_palette, x
        sta PPUDATA
        inx
        cpx #16
        bne bg_loop

        ; Reset PPUADDR to 0,0
        lda #$00
        sta PPUADDR
        sta PPUADDR

        rts
.endproc
