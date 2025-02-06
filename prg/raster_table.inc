.global FAR_initialize_irq_table
.global FAR_setup_raster_table_for_frame
.global FAR_apply_room_global_color_emphasis
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
;RASTER_EFFECT_NONE        = $3C

RASTER_EFFECT_UNDERWATER  = $04
RASTER_EFFECT_SLIDE_RIGHT = $08
RASTER_EFFECT_SLIDE_LEFT  = $0C
RASTER_EFFECT_SLIDE_DOWN  = $10
RASTER_EFFECT_SLIDE_UP    = $14
RASTER_EFFECT_VS_MINUS_1  = $18
RASTER_EFFECT_VS_MINUS_2  = $1C
RASTER_EFFECT_VS_MINUS_3  = $20
RASTER_EFFECT_VS_MINUS_4  = $24
RASTER_EFFECT_VS_PLUS_1   = $28
RASTER_EFFECT_VS_PLUS_2   = $2C
RASTER_EFFECT_VS_PLUS_3   = $30
RASTER_EFFECT_OPTIONS     = $34
RASTER_EFFECT_SCORCHED    = $38
RASTER_EFFECT_WARP_IN     = $3C

; note: 2-indexed!
RASTER_FINALIZER_NONE = 0
RASTER_FINALIZER_PLAIN_HUD = 2