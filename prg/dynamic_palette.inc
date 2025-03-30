HUE_COMPOSITE_GREY = 0
HUE_RGBPPU_GREY    = 13

PPU_MODE_COMPOSITE = %00000000
PPU_MODE_RGB       = %01000000

BRIGHTNESS_FULLY_DARK   = $00
BRIGHTNESS_MINUS_1      = $40
BRIGHTNESS_NORMAL       = $50
BRIGHTNESS_FULLY_BRIGHT = $A0

.globalzp staging_palette
.global HudStagingPalette
.global IncomingHwPalette

.global HudSeparatorPal
.global StagingBgPaletteDirty
.global StagingObjPaletteDirty
.global StagingHudPaletteDirty

.global CurrentPlayfieldBackdrop
.global CurrentPlayfieldBgPal0
.global CurrentPlayfieldBgPal1
.global CurrentPlayfieldBgPal2
.global CurrentPlayfieldBgPal3

.global TargetPlayfieldBackdrop
.global TargetPlayfieldBgPal0
.global TargetPlayfieldBgPal1
.global TargetPlayfieldBgPal2
.global TargetPlayfieldBgPal3

.global PlayfieldObjPal0
.global PlayfieldObjPal1
.global PlayfieldObjPal2
.global PlayfieldObjPal3

.global HudBackdrop
.global HudBgPal0
.global HudBgPal1
.global HudBgPal2
.global HudBgPal3
.global HudObjPal0

.global Brightness
.global TargetBrightness
.global BrightnessDelay
.global GlobalFadeSpeed

.global FAR_refresh_palettes_gameloop
.global set_brightness

.global FAR_init_dynamic_palettes
.global FAR_set_bg_target_palette_from_hw
.global FAR_set_bg_current_palette_from_target
.global FAR_set_obj_palette_from_hw
.global FAR_set_hud_bg_palette_from_hw
.global FAR_set_hud_obj_palette_from_hw
.global FAR_load_palette_by_colorspace
.global FAR_step_towards_target

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