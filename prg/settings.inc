.global FAR_init_file_options
.global FAR_compute_player_colors
.global FAR_compute_colors_for_save_slot

; the LUT those sliders index into:
.global palette_preset_lut_phones
.global palette_preset_lut_pajamas
.global palette_preset_lut_pigment

; The computed palette data for each sprite index, in a big lovely list
.global player_palettes_pigment
.global player_palettes_phones
.global player_palettes_pajamas

; And the indices into the list for various effects and whatnot

PLAYER_PALETTE_NORMAL        = 0
PLAYER_PALETTE_TITLE_BASE    = 1
PLAYER_PALETTE_DAMAGE_LIGHT  = 2
PLAYER_PALETTE_DAMAGE_DARK   = 3
PLAYER_PALETTE_RHYTHM_ASSIST = 4
PLAYER_PALETTE_JUST_HEALED   = 12
PLAYER_PALETTE_POISONED      = 20
PLAYER_PALETTE_FROZEN        = 28
PLAYER_PALETTE_SHOCKED       = 36
PLAYER_PALETTE_BURNED        = 44

DISCO_FLOOR_SOLID_INSTANT_SQUARES   = 0
DISCO_FLOOR_SOLID_FROZEN_SQUARES    = 1
DISCO_FLOOR_OUTLINE_INSTANT_SQUARES = 2
DISCO_FLOOR_OUTLINE_FROZEN_SQUARES  = 3
DISCO_FLOOR_JUST_GROOVEMENT         = 4
DISCO_FLOOR_REDUCED_MOTION          = 5

GAME_MODE_STANDARD   = 0
GAME_MODE_PATIENT    = 1
GAME_MODE_DOUBLETIME = 2