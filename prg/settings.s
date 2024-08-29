    .include "settings.inc"

    .segment "RAM"

setting_disco_floor: .res 1

    .segment "CODE_1"

; This will eventually become much more involved. For now, settings
; are global and fixed. Set the ones we want here for testing.
.proc FAR_init_settings
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    ;lda #DISCO_FLOOR_OUTLINE
    ;lda #DISCO_FLOOR_NO_OUTLINE
    ;lda #DISCO_FLOOR_STATIC
    sta setting_disco_floor

    rts
.endproc