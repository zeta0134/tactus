    .include "../build/tile_defs.inc"

    .include "_globals.inc"

    .include "far_call.inc"
    .include "prng.inc"
    .include "rainbow.inc"
    .include "saves.inc"
    .include "settings.inc"
    .include "zpcm.inc"

    .segment "RAM"

player_ingame_palette_pigment: .res 1
player_ingame_palette_phones: .res 1
player_ingame_palette_pajamas: .res 1

player_damage_light_palette_pigment: .res 1
player_damage_light_palette_phones: .res 1
player_damage_light_palette_pajamas: .res 1

player_damage_dark_palette_pigment: .res 1
player_damage_dark_palette_phones: .res 1
player_damage_dark_palette_pajamas: .res 1

player_title_palette_pigment_dark: .res 1
player_title_palette_pigment_medium: .res 1
player_title_palette_phones_dark: .res 1
player_title_palette_phones_medium: .res 1
player_title_palette_phones_light: .res 1
player_title_palette_pajamas_dark: .res 1
player_title_palette_pajamas_medium: .res 1
player_title_palette_pajamas_light: .res 1

    .segment "PRGFIXED_E000"

; because we need to access these quickly from several different places,
; and they are not large
; TODO okay that is a lie, can we move these to a data segment?

; From this original set:
;    .byte 0, 10, 19, 21 ; orig: $0f,$12,$26,$37  ; Peony
;    .byte 0, 50, 36, 22 ; orig: $0f,$1c,$3c,$27  ; Periwinkle
;    .byte 0, 23, 10, 20 ; orig: $0f,$05,$23,$16  ; Petunia
;    .byte 0, 26, 22, 15 ; orig: $0f,$16,$27,$35  ; Protea
; Indexing into the above tables as appropriate, we obtain:
palette_preset_lut_pajamas: .byte 0, 18, 37, 15, 19, 13
palette_preset_lut_phones:  .byte 0, 14, 24,  5, 18, 17
palette_preset_lut_pigment: .byte 0, 32, 19,  5, 30, 31

;palette_preset_lut_phones:  .byte 10, 50, 23, 26
;palette_preset_lut_pajamas: .byte 19, 36, 10, 22
;palette_preset_lut_pigment: .byte 21, 22, 20, 15

    .segment "CODE_2"

player_colors_shoes_accessories_lut:
    .byte $0F, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C ;  (-)  (0)
player_colors_face_clothing_lut:
    .byte $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00 ;  (0) (13)
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10 ; (13) (26)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (26) (39)

player_dmg_dark_colors_shoes_accessories_lut:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
player_dmg_dark_colors_face_clothing_lut:
    .byte $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05 ;  (-)  (0)
    .byte $15, $15, $15, $15, $15, $15, $15, $15, $15, $15, $15, $15, $15 ;  (0) (13)
    .byte $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25 ; (13) (26)

; Old: +1 stage
;player_dmg_light_colors_shoes_accessories_lut:
;    .byte $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16 ;  (-)  (0)
;player_dmg_light_colors_face_clothing_lut:
;    .byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26 ;  (0) (13)
;    .byte $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $30 ; (13) (26)
;    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30 ; (26) (39)

; New: +2 stages
player_dmg_light_colors_shoes_accessories_lut:
    .byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26, $26 ;  (-)  (0)
player_dmg_light_colors_face_clothing_lut:
    .byte $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $36, $36 ;  (0) (13)
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30 ; (13) (26)
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30 ; (26) (39)

; Each of these is a two-tone ramp. We prefer to darken the lower shade by one stage
player_title_colors_face_lut:
    .byte $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $2D, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10 
    .byte $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 

; Clothing uses the same ramp as the face but with an added light shade
player_title_colors_clothing_lut:
    .byte $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $2D, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $00 
    .byte $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $10 
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30 

; Accessories span the full range, and we cheat significantly on the luminence to avoid using $0F anywhere in the set
; (even if the player has chosen actually-black, it'll render at $2D at the darkest on the title screen)
player_title_colors_accessories_lut:
    .byte $2D, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $2D, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $00 
    .byte $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D 
    .byte $10, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30 

; For the actively loaded file, initialize all options to their
; default values. This is meant to be used just after clicking
; start on a brand new file, as the settings should otherwise
; persist as part of that file.
.proc FAR_init_file_options
    ; Default to solid frozen squares. This is by far the most
    ; accessible option. New players will be sent to the options
    ; screen before starting the game proper, so they can flip
    ; this to their preference as they like.
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    sta current_save + SaveFile::OptionDiscoFloor

    lda #GAME_MODE_STANDARD
    sta current_save + SaveFile::OptionRhythmMode

    ; TODO: pick a random preset from the range of possible presets
    in_range_smol next_gameplay_rand, #(NEW_FILE_PALETTE_MAX-NEW_FILE_PALETTE_MIN)
    clc
    adc #NEW_FILE_PALETTE_MIN
    sta current_save + SaveFile::PlayerPalettePreset
    ; Use this to initialize the personalized sliders, just to avoid some dumb
    ; problems with defaults when these disagree
    ldx current_save + SaveFile::PlayerPalettePreset
    lda palette_preset_lut_phones, x 
    sta current_save + SaveFile::PlayerPalettePhonesIndex
    lda palette_preset_lut_pajamas, x 
    sta current_save + SaveFile::PlayerPalettePajamasIndex
    lda palette_preset_lut_pigment, x 
    sta current_save + SaveFile::PlayerPalettePigmentIndex

    near_call FAR_compute_player_colors

    rts
.endproc

.proc FAR_compute_player_colors
    perform_zpcm_inc
    lda current_save + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    jsr _set_phones_color
    ldy palette_preset_lut_pajamas, x
    jsr _set_pajamas_color
    ldy palette_preset_lut_pigment, x
    jsr _set_pigment_color
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_save + SaveFile::PlayerPalettePhonesIndex
    jsr _set_phones_color
    ldy current_save + SaveFile::PlayerPalettePajamasIndex
    jsr _set_pajamas_color
    ldy current_save + SaveFile::PlayerPalettePigmentIndex
    jsr _set_pigment_color
    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_1_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    jsr _set_phones_color
    ldy palette_preset_lut_pajamas, x
    jsr _set_pajamas_color
    ldy palette_preset_lut_pigment, x
    jsr _set_pigment_color
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePhonesIndex
    jsr _set_phones_color
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePajamasIndex
    jsr _set_pajamas_color
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePigmentIndex
    jsr _set_pigment_color
    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_2_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    jsr _set_phones_color
    ldy palette_preset_lut_pajamas, x
    jsr _set_pajamas_color
    ldy palette_preset_lut_pigment, x
    jsr _set_pigment_color
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePhonesIndex
    jsr _set_phones_color
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePajamasIndex
    jsr _set_pajamas_color
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePigmentIndex
    jsr _set_pigment_color
    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_3_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    jsr _set_phones_color
    ldy palette_preset_lut_pajamas, x
    jsr _set_pajamas_color
    ldy palette_preset_lut_pigment, x
    jsr _set_pigment_color
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePhonesIndex
    jsr _set_phones_color
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePajamasIndex
    jsr _set_pajamas_color
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePigmentIndex
    jsr _set_pigment_color
    perform_zpcm_inc
    rts
.endproc

; save slot in A
.proc FAR_compute_colors_for_save_slot
    cmp #0
    beq compute_file_1
    cmp #1
    beq compute_file_2
    cmp #2
    beq compute_file_3
    ; should not be reachable
compute_file_1:
    jsr _compute_file_1_colors
    rts
compute_file_2:
    jsr _compute_file_2_colors
    rts
compute_file_3:
    jsr _compute_file_3_colors
    rts
.endproc

; LUT index in Y
.proc _set_phones_color
    perform_zpcm_inc
    ; normal colors for gameplay sprites
    lda player_colors_shoes_accessories_lut, y
    sta player_ingame_palette_phones
    lda player_dmg_dark_colors_shoes_accessories_lut, y
    sta player_damage_dark_palette_phones
    lda player_dmg_light_colors_shoes_accessories_lut, y
    sta player_damage_light_palette_phones
    ; title colors have several shading variants and we need to
    ; skip ahead between rows
    lda player_title_colors_accessories_lut, y
    sta player_title_palette_phones_dark
    tya
    clc
    adc #13
    tay
    lda player_title_colors_accessories_lut, y
    sta player_title_palette_phones_medium
    tya
    clc
    adc #13
    tay
    lda player_title_colors_accessories_lut, y
    sta player_title_palette_phones_light
    perform_zpcm_inc
    rts
.endproc

; LUT index in Y
.proc _set_pajamas_color
    perform_zpcm_inc
    ; normal colors for gameplay sprites
    lda player_colors_face_clothing_lut, y
    sta player_ingame_palette_pajamas
    lda player_dmg_dark_colors_face_clothing_lut, y
    sta player_damage_dark_palette_pajamas
    lda player_dmg_light_colors_face_clothing_lut, y
    sta player_damage_light_palette_pajamas
    ; title colors have several shading variants and we need to
    ; skip ahead between rows
    lda player_title_colors_clothing_lut, y
    sta player_title_palette_pajamas_dark
    tya
    clc
    adc #13
    tay
    lda player_title_colors_clothing_lut, y
    sta player_title_palette_pajamas_medium
    tya
    clc
    adc #13
    tay
    lda player_title_colors_clothing_lut, y
    sta player_title_palette_pajamas_light
    perform_zpcm_inc
    rts
.endproc

; LUT index in Y
.proc _set_pigment_color
    perform_zpcm_inc
    ; normal colors for gameplay sprites
    lda player_colors_face_clothing_lut, y
    sta player_ingame_palette_pigment
    lda player_dmg_dark_colors_face_clothing_lut, y
    sta player_damage_dark_palette_pigment
    lda player_dmg_light_colors_face_clothing_lut, y
    sta player_damage_light_palette_pigment
    ; title colors have several shading variants and we need to
    ; skip ahead between rows
    lda player_title_colors_face_lut, y
    sta player_title_palette_pajamas_dark
    tya
    clc
    adc #13
    tay
    lda player_title_colors_face_lut, y
    sta player_title_palette_pajamas_medium
    ; face ramp doesn't have a light shade, it's used for the whites of eyes instead
    perform_zpcm_inc
    rts
.endproc