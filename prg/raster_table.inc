.global FAR_initialize_irq_table
.global FAR_setup_raster_table_for_frame
.globalzp self_modifying_irq

.global RasterEffectFrame, RasterEffectIndex

.struct RasterEffectEntry
    FramesListPtr .addr
    BankIndex .byte
    Duration .byte
.endstruct

.macro set_raster_effect_safely effect_index
    lda #0
    sta RasterEffectFrame
    lda effect_index
    sta RasterEffectIndex
.endmacro

RASTER_EFFECT_RAINBOW = 0

RASTER_FINALIZER_NONE = 0
RASTER_FINALIZER_PLAIN_HUD = 2