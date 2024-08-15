.global FAR_initialize_irq_table
.global FAR_setup_raster_table_for_frame
.globalzp self_modifying_irq

.global RasterEffectFrame, RasterEffectIndex, RasterEffectFinalizerIndex

.struct RasterEffectEntry
    FramesListPtr .addr
    BankIndex .byte
    Duration .byte
.endstruct

.macro set_raster_effect_safely effect_index, finalizer_index
    lda #0
    sta RasterEffectFrame
    lda effect_index
    sta RasterEffectIndex
    lda finalizer_index
    sta RasterEffectFinalizerIndex
.endmacro

; note: 4-indexed!
RASTER_EFFECT_NONE = 0
RASTER_EFFECT_UNDERWATER = 4

; note: 2-indexed!
RASTER_FINALIZER_NONE = 0
RASTER_FINALIZER_PLAIN_HUD = 2