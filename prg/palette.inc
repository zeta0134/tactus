
.global BgPaletteDirty
.global ObjPaletteDirty
.global BgPaletteBuffer
.global ObjPaletteBuffer
.global Brightness
.global TargetBrightness

.global FAR_refresh_palettes_gameloop
.global FAR_update_brightness
.global FAR_init_palettes
.global set_brightness
.global refresh_palettes_nmi
.globalzp staging_palette

GLOBAL_PALETTE_FADE_SPEED = 4
