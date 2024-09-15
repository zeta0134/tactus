.global FAR_init_settings

.global setting_disco_floor
.global setting_player_palette
.global setting_game_mode

; the actual color values that will be copied into the PPU
.global setting_personal_color_phones
.global setting_personal_color_pajamas
.global setting_personal_color_pigment
; the position of the various sliders in the UI to pick those values
.global setting_player_palette_preset
.global setting_personal_color_index_phones
.global setting_personal_color_index_pajamas
.global setting_personal_color_index_pigment
; the LUT those sliders index into:
.global player_colors_face_clothing_lut
.global player_colors_shoes_accessories_lut
.global palette_preset_lut_phones
.global palette_preset_lut_pajamas
.global palette_preset_lut_pigment

DISCO_FLOOR_SOLID_INSTANT_SQUARES   = 0
DISCO_FLOOR_SOLID_FROZEN_SQUARES    = 1
DISCO_FLOOR_OUTLINE_INSTANT_SQUARES = 2
DISCO_FLOOR_OUTLINE_FROZEN_SQUARES  = 3
DISCO_FLOOR_JUST_GROOVEMENT         = 4
DISCO_FLOOR_REDUCED_MOTION          = 5

GAME_MODE_STANDARD   = 0
GAME_MODE_PATIENT    = 1
GAME_MODE_DOUBLETIME = 2