.global FAR_init_file_options
.global FAR_compute_player_colors
.global FAR_compute_colors_for_save_slot

; the LUT those sliders index into:
.global palette_preset_lut_phones
.global palette_preset_lut_pajamas
.global palette_preset_lut_pigment

; the actual palette colors, which are expensive to compute
; so we do it way ahead of gameplay
.global player_ingame_palette_pigment
.global player_ingame_palette_phones
.global player_ingame_palette_pajamas
.global player_damage_light_palette_pigment
.global player_damage_light_palette_phones
.global player_damage_light_palette_pajamas
.global player_damage_dark_palette_pigment
.global player_damage_dark_palette_phones
.global player_damage_dark_palette_pajamas
.global player_title_palette_pigment_dark
.global player_title_palette_pigment_medium
.global player_title_palette_phones_dark
.global player_title_palette_phones_medium
.global player_title_palette_phones_light
.global player_title_palette_pajamas_dark
.global player_title_palette_pajamas_medium
.global player_title_palette_pajamas_light

DISCO_FLOOR_SOLID_INSTANT_SQUARES   = 0
DISCO_FLOOR_SOLID_FROZEN_SQUARES    = 1
DISCO_FLOOR_OUTLINE_INSTANT_SQUARES = 2
DISCO_FLOOR_OUTLINE_FROZEN_SQUARES  = 3
DISCO_FLOOR_JUST_GROOVEMENT         = 4
DISCO_FLOOR_REDUCED_MOTION          = 5

GAME_MODE_STANDARD   = 0
GAME_MODE_PATIENT    = 1
GAME_MODE_DOUBLETIME = 2