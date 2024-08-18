.global FAR_initialize_irq_table
.global FAR_setup_raster_table_for_frame
.globalzp self_modifying_irq

.globalzp RasterEffectFrame, RasterEffectIndex, RasterEffectFinalizerIndex, RasterLoopPoint
.globalzp LeftNametableBank, RightNametableBank, LeftNametableAttr, RightNametableAttr

.struct RasterEffectEntry
    FramesListPtr .addr
    BankIndex .byte
    Duration .byte
.endstruct

.macro set_raster_effect_safely effect_index, finalizer_index, loop_point
    lda #0
    sta RasterEffectFrame
    lda effect_index
    sta RasterEffectIndex
    lda finalizer_index
    sta RasterEffectFinalizerIndex
    lda loop_point
    sta RasterLoopPoint
.endmacro

; note: 4-indexed!
RASTER_EFFECT_NONE        = $00
RASTER_EFFECT_UNDERWATER  = $04
RASTER_EFFECT_SLIDE_RIGHT = $08
RASTER_EFFECT_SLIDE_LEFT  = $0C

; note: 2-indexed!
RASTER_FINALIZER_NONE = 0
RASTER_FINALIZER_PLAIN_HUD = 2