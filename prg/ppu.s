        .setcpu "6502"
        .include "dynamic_palette.inc"
        .include "far_call.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "CODE_0"

bg_palette:
        .incbin "../art/test_palette.pal"
obj_palette:
        .incbin "../art/sprite_palette.pal"
hud_palette_bg:
        .incbin "../art/hud_bg.pal"
hud_palette_obj:
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

        near_call FAR_initialize_title_palettes        

        ; Initialize brightness to 0 (fully black) so we can fade it in
        lda #BRIGHTNESS_FULLY_DARK
        jsr set_brightness
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness

        rts
.endproc

.proc FAR_initialize_game_palettes
        perform_zpcm_inc
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne obj_loop

        perform_zpcm_inc
        far_call FAR_set_obj_palette_from_hw
        perform_zpcm_inc

        ldx #0
bg_loop:
        lda bg_palette, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne bg_loop

        perform_zpcm_inc
        far_call FAR_set_bg_target_palette_from_hw
        far_call FAR_set_bg_current_palette_from_target
        perform_zpcm_inc

        ldx #0
hud_bg_loop:
        perform_zpcm_inc
        lda hud_palette_bg, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne hud_bg_loop

        perform_zpcm_inc
        far_call FAR_set_hud_bg_palette_from_hw
        perform_zpcm_inc

        ldx #0
hud_obj_loop:
        perform_zpcm_inc
        lda hud_palette_obj, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne hud_obj_loop

        perform_zpcm_inc
        far_call FAR_set_hud_obj_palette_from_hw
        perform_zpcm_inc

        rts
.endproc

.proc FAR_initialize_title_palettes
        perform_zpcm_inc
        ; Copy palette data into the palette manager

        ldx #0
obj_loop:
        lda obj_palette, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne obj_loop

        perform_zpcm_inc
        far_call FAR_set_obj_palette_from_hw
        perform_zpcm_inc

        ldx #0
bg_loop:
        lda title_palette, x
        sta IncomingHwPalette, x
        inx
        cpx #16
        bne bg_loop

        perform_zpcm_inc
        far_call FAR_set_bg_target_palette_from_hw
        far_call FAR_set_bg_current_palette_from_target
        perform_zpcm_inc

        rts
.endproc
