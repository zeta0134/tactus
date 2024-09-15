    .include "settings.inc"

    .segment "RAM"

setting_disco_floor: .res 1
setting_game_mode: .res 1

; the actual colors that will be drawn
setting_personal_color_phones:  .res 1
setting_personal_color_pajamas: .res 1
setting_personal_color_pigment: .res 1
; TODO: should we have a corresponding damage color lut?
; the positions of the sliders and such in the UI
setting_player_palette_preset:        .res 1
setting_personal_color_index_phones:  .res 1
setting_personal_color_index_pajamas: .res 1
setting_personal_color_index_pigment: .res 1

    .segment "PRGFIXED_E000"

; because we need to access these quickly from several different places,
; and they are not large
; TODO okay that is a lie, can we move these to a data segment?

player_colors_shoes_accessories_lut:
    .byte $0F, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C ;  (-)  (0)
player_colors_face_clothing_lut:
    .byte $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00 ;  (0) (13)
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10 ; (13) (26)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (26) (39)

; From this original set:
;    .byte 0, 10, 19, 21 ; orig: $0f,$12,$26,$37  ; Peony
;    .byte 0, 50, 36, 22 ; orig: $0f,$1c,$3c,$27  ; Periwinkle
;    .byte 0, 23, 10, 20 ; orig: $0f,$05,$23,$16  ; Petunia
;    .byte 0, 26, 22, 15 ; orig: $0f,$16,$27,$35  ; Protea
; Indexing into the above tables as appropriate, we obtain:
palette_preset_lut_pajamas: .byte 18, 37, 15, 19, 13
palette_preset_lut_phones:  .byte 14, 24,  5, 18, 17
palette_preset_lut_pigment: .byte 32, 19,  5, 30, 31

;palette_preset_lut_phones:  .byte 10, 50, 23, 26
;palette_preset_lut_pajamas: .byte 19, 36, 10, 22
;palette_preset_lut_pigment: .byte 21, 22, 20, 15

    .segment "CODE_1"

; This will eventually become much more involved. For now, settings
; are global and fixed. Set the ones we want here for testing.
.proc FAR_init_settings
    ; TODO: Is this our default? We should honestly probably
    ; let the player choose in a one-time SRAM setup screen
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    sta setting_disco_floor

    lda #GAME_MODE_STANDARD
    sta setting_game_mode

    ldx #0
    stx setting_player_palette_preset

    ldy palette_preset_lut_phones, x
    sty setting_personal_color_index_phones
    lda player_colors_shoes_accessories_lut, y
    sta setting_personal_color_phones

    ldy palette_preset_lut_pajamas, x
    sty setting_personal_color_index_pajamas
    lda player_colors_face_clothing_lut, y
    sta setting_personal_color_pajamas

    ldy palette_preset_lut_pigment, x
    sty setting_personal_color_index_pigment
    lda player_colors_face_clothing_lut, y
    sta setting_personal_color_pigment

    rts
.endproc