    .include "settings.inc"

    .segment "RAM"

setting_disco_floor: .res 1
setting_player_palette: .res 1
setting_game_mode: .res 1

    .segment "CODE_1"

; This will eventually become much more involved. For now, settings
; are global and fixed. Set the ones we want here for testing.
.proc FAR_init_settings
    ; TODO: Is this our default? We should honestly probably
    ; let the player choose in a one-time SRAM setup screen
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    sta setting_disco_floor

    lda #0
    sta setting_player_palette
    lda #GAME_MODE_STANDARD
    sta setting_game_mode

    rts
.endproc