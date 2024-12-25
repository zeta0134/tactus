
.global BgPaletteDirty
.global ObjPaletteDirty
.global BgPaletteBuffer
.global ObjPaletteBuffer
.global HudPaletteBuffer
.global HudStagingPalette
.global Brightness
.global TargetBrightness

.global FAR_refresh_palettes_gameloop
.global FAR_update_brightness
.global FAR_init_palettes
.global set_brightness
.globalzp staging_palette
.global refresh_palettes_nmi

GLOBAL_PALETTE_FADE_SPEED = 4

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