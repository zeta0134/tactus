.global FAR_initialize_irq_table
.global FAR_setup_raster_table_for_frame
.globalzp self_modifying_irq

.globalzp RasterEffectFrame, RasterEffectIndex, RasterEffectFinalizerIndex, RasterLoopPoint
.globalzp LeftNametableBank, RightNametableBank, LeftNametableAttr, RightNametableAttr, RasterEffectFractionalFrame
.global RasterPlaybackSpeedHigh, RasterPlaybackSpeedLow

.struct RasterEffectEntry
    FramesListPtr .addr
    BankIndex .byte
    Duration .byte
.endstruct

.macro set_raster_effect_safely effect_index, finalizer_index, loop_point
    lda #0
    sta RasterLoopPoint ; for extra safety
    sta RasterEffectFrame
    lda effect_index
    sta RasterEffectIndex
    lda finalizer_index
    sta RasterEffectFinalizerIndex
    lda loop_point
    sta RasterLoopPoint
.endmacro

.macro set_raster_playback_speed speed_high, speed_low
    lda speed_high
    sta RasterPlaybackSpeedHigh
    lda speed_low
    sta RasterPlaybackSpeedLow
    lda #0
    sta RasterEffectFractionalFrame
.endmacro

; note: 4-indexed!
RASTER_EFFECT_NONE        = $00
RASTER_EFFECT_UNDERWATER  = $04
RASTER_EFFECT_SLIDE_RIGHT = $08
RASTER_EFFECT_SLIDE_LEFT  = $0C
RASTER_EFFECT_SLIDE_DOWN  = $10
RASTER_EFFECT_SLIDE_UP    = $14

; note: 2-indexed!
RASTER_FINALIZER_NONE = 0
RASTER_FINALIZER_PLAIN_HUD = 2