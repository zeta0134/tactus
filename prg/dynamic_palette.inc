HUE_COMPOSITE_GREY = 0
HUE_RGBPPU_GREY    = 13

.globalzp staging_palette

.macro INLINE_refresh_palettes_nmi 
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    perform_zpcm_inc
    .repeat 16,i
    lda staging_palette+i
    sta PPUDATA
    .endrepeat
    perform_zpcm_inc
    .repeat 16,i
    lda staging_palette+i+16
    sta PPUDATA
    .endrepeat
    perform_zpcm_inc
.endmacro