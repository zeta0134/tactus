HUE_COMPOSITE_GREY = 0
HUE_RGBPPU_GREY    = 13

PPU_MODE_COMPOSITE = %00000000
PPU_MODE_RGB       = %01000000

BRIGHTNESS_FULLY_DARK   = $00
BRIGHTNESS_NORMAL       = $50
BRIGHTNESS_FULLY_BRIGHT = $A0

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