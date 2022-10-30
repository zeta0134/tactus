        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .segment "PRGFIXED_C000"

bg_palette:
        .incbin "../art/test_palette.pal"
obj_palette:
        .incbin "../art/sprite_palette.pal"

title_palette:
        .incbin "../art/title_bg_palette.pal"

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

        ; Set OBJ and BG palettes to all black
        set_ppuaddr #$3F00
        lda #$0F
        ldx #0
palette_loop:
        sta PPUDATA
        inx
        cpx #32
        bne palette_loop

        jsr initialize_title_palettes

        ; Reset PPUADDR to 0,0
        lda #$00
        sta PPUADDR
        sta PPUADDR

        ; Initialize brightness to 0 (fully black) so we can fade it in
        lda #0
        jsr set_brightness
        lda #4
        sta TargetBrightness

        rts
.endproc

.proc initialize_game_palettes
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta ObjPaletteBuffer, x
        inx
        cpx #16
        bne obj_loop

        ldx #0
bg_loop:
        lda bg_palette, x
        sta BgPaletteBuffer, x
        inx
        cpx #16
        bne bg_loop
        rts
.endproc

.proc initialize_title_palettes
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta ObjPaletteBuffer, x
        inx
        cpx #16
        bne obj_loop

        ldx #0
bg_loop:
        lda title_palette, x
        sta BgPaletteBuffer, x
        inx
        cpx #16
        bne bg_loop
        rts
.endproc