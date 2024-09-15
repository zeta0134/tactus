    .include "settings.inc"

    .segment "RAM"

setting_disco_floor: .res 1
setting_player_palette: .res 1
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

; basically anything except black and the darkest shades, to guarantee that the player
; is mostly visible on top of any valid floor tile in the game
player_colors_face_clothing_lut:
    .byte $30, $10, $00 ; (0) greyscale light(ish) shades
    .byte $31, $21, $11 ; (3) very blue
    .byte $32, $22, $12 ; (6)
    .byte $33, $23, $13 ; (9)
    .byte $34, $24, $14 ; (12) quite pink
    .byte $35, $25, $15 ; (15) plausibly human skin tones start
    .byte $36, $26, $16 ; (18)
    .byte $37, $27, $17 ; (21)
    .byte $38, $28, $18 ; (24) plausibly human skin tones end
    .byte $39, $29, $19 ; (27) rather green
    .byte $3A, $2A, $1A ; (30)
    .byte $3B, $2B, $1B ; (33) 
    .byte $3C, $2C, $1C ; (36) gosh, it's blue

; the accessory layer gets basically the full range of colors
player_colors_shoes_accessories_lut:
    .byte $30, $10, $00, $0F ; (0) greyscale shades, including actually black this time
    .byte $31, $21, $11, $01 ; (4) very blue
    .byte $32, $22, $12, $02 ; (8)
    .byte $33, $23, $13, $03 ; (12)
    .byte $34, $24, $14, $04 ; (16) quite pink
    .byte $35, $25, $15, $05 ; (20)
    .byte $36, $26, $16, $06 ; (24)
    .byte $37, $27, $17, $07 ; (28)
    .byte $38, $28, $18, $08 ; (32)
    .byte $39, $29, $19, $09 ; (36) rather green
    .byte $3A, $2A, $1A, $0A ; (40)
    .byte $3B, $2B, $1B, $0B ; (44)
    .byte $3C, $2C, $1C, $0C ; (48) gosh, it's blue

; From this original set:
;    .byte 0, 10, 19, 21 ; orig: $0f,$12,$26,$37  ; Peony
;    .byte 0, 50, 36, 22 ; orig: $0f,$1c,$3c,$27  ; Periwinkle
;    .byte 0, 23, 10, 20 ; orig: $0f,$05,$23,$16  ; Petunia
;    .byte 0, 26, 22, 15 ; orig: $0f,$16,$27,$35  ; Protea
; Indexing into the above tables as appropriate, we obtain:
palette_preset_lut_phones:  .byte 10, 50, 23, 26
palette_preset_lut_pajamas: .byte 19, 36, 10, 22
palette_preset_lut_pigment: .byte 21, 22, 20, 15

    .segment "CODE_1"

; This will eventually become much more involved. For now, settings
; are global and fixed. Set the ones we want here for testing.
.proc FAR_init_settings
    ; TODO: Is this our default? We should honestly probably
    ; let the player choose in a one-time SRAM setup screen
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    sta setting_disco_floor

    lda #0
    sta setting_player_palette ; OLD, going away!
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