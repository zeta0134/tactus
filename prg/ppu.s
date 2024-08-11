        .setcpu "6502"
        .include "far_call.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "CODE_0"

bg_palette:
        .incbin "../art/test_palette.pal"
obj_palette:
        .incbin "../art/sprite_palette.pal"
hud_palette:
        .incbin "../art/hud_bg.pal"
        .incbin "../art/hud_obj.pal"

title_palette:
        .incbin "../art/title_bg_palette.pal"

.proc FAR_initialize_ppu
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
        perform_zpcm_inc
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

.proc FAR_initialize_palettes
        ;  Set the palettes up with a nice greyscale for everything

        ; disable rendering
        lda #$00
        sta PPUMASK

        ; Set OBJ and BG palettes to all black
        set_ppuaddr #$3F00
        lda #$0F
        ldx #0
palette_loop:
        perform_zpcm_inc
        sta PPUDATA
        inx
        cpx #32
        bne palette_loop

        near_call FAR_initialize_title_palettes

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

.proc FAR_initialize_game_palettes
        perform_zpcm_inc
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta ObjPaletteBuffer, x
        inx
        cpx #16
        bne obj_loop

        perform_zpcm_inc

        ldx #0
bg_loop:
        lda bg_palette, x
        sta BgPaletteBuffer, x
        inx
        cpx #16
        bne bg_loop

        ldx #0
hud_loop:
        perform_zpcm_inc
        lda hud_palette, x
        sta HudPaletteBuffer, x
        inx
        cpx #32
        bne hud_loop

        perform_zpcm_inc

        rts
.endproc

.proc FAR_initialize_title_palettes
        perform_zpcm_inc
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta ObjPaletteBuffer, x
        inx
        cpx #16
        bne obj_loop

        perform_zpcm_inc

        ldx #0
bg_loop:
        lda title_palette, x
        sta BgPaletteBuffer, x
        inx
        cpx #16
        bne bg_loop

        perform_zpcm_inc

        rts
.endproc