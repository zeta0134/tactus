.global init_dialog
.global update_dialog
.global update_rhythm_assist

.global DialogHeight

.global DialogInitiatePassiveMode
.global DialogDismissPassiveMode
.global DialogPassiveStringPtr
.global DialogPassiveStringBank
.global DialogInitiateActiveMode
.global DialogDismissActiveMode
.global DialogActiveStringPtr
.global DialogActiveStringBank

FONT_BANK = CHR_BANK_0_FONT_MARSHMALLOW
DIALOG_NAMETABLE_BASE = $56C0
DIALOG_ATTRIBUTE_BASE = $5EC0

DIALOG_PAL_WHITE     = (HUD_TEXT_PAL   | 0)
DIALOG_PAL_GREY      = (HUD_TEXT_PAL   | 1)
; No light yellow, that's a copy of white
DIALOG_PAL_YELLOW    = (HUD_YELLOW_PAL | 1)
DIALOG_PAL_BLUE      = (HUD_PURPLE_PAL | 0)
DIALOG_PAL_DARK_BLUE = (HUD_PURPLE_PAL | 1)
DIALOG_PAL_PEACH     = (HUD_RED_PAL    | 0)
DIALOG_PAL_RED       = (HUD_RED_PAL    | 1)

; for UI, only "white" is the same, everything else is
; totally different. those differences are loosely encoded here:
UI_STRING_PAL_WHITE         = (UI_PAL_BG1     | 0)
UI_STRING_PAL_LIGHT_BLUE    = (UI_PAL_BG1     | 1)
UI_STRING_PAL_LIGHT_THEME   = (UI_PAL_BG2     | 0)
UI_STRING_PAL_MID_THEME     = (UI_PAL_BG2     | 1)
; bg0:bank0 is reliably a duplicate of bg2:bank1, so we don't include that twice
UI_STRING_PAL_DARK_THEME    = (UI_PAL_BG0     | 1)
; for now, bg3 isn't used or set in the UI. it is solid black. this may change!

FONT_ASCII         = CHR_BANK_0_FONT_MARSHMALLOW
FONT_SITELEN_PONA  = CHR_BANK_0_FONT_SITELEN_PONA_LEKO_MAJUNA

; Standard English font definitions, with convenient colors
; Also generally used for languages that draw in a latin or mostly-latin character set.
COLOR_MM_WHITE = (CHR_BANK_0_FONT_MARSHMALLOW | HUD_TEXT_PAL)
COLOR_MM_GREY = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_TEXT_PAL)
COLOR_MM_YELLOW = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_YELLOW_PAL)
COLOR_MM_BLUE = (CHR_BANK_0_FONT_MARSHMALLOW | HUD_PURPLE_PAL)
COLOR_MM_DARK_BLUE = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_PURPLE_PAL)
COLOR_MM_PEACH = (CHR_BANK_0_FONT_MARSHMALLOW | HUD_RED_PAL)
COLOR_MM_RED = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_RED_PAL)

; Sitelen Pona font set, for use with toki pona
COLOR_SP_WHITE = (CHR_BANK_0_FONT_SITELEN_PONA_LEKO_MAJUNA | HUD_TEXT_PAL)
COLOR_SP_GREY = (CHR_BANK_0_FONT_SITELEN_PONA_LEKO_MAJUNA_DARK | HUD_TEXT_PAL)
COLOR_SP_YELLOW = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_YELLOW_PAL)
COLOR_SP_BLUE = (CHR_BANK_0_FONT_SITELEN_PONA_LEKO_MAJUNA_DARK | HUD_PURPLE_PAL)
COLOR_SP_DARK_BLUE = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_PURPLE_PAL)
COLOR_SP_PEACH = (CHR_BANK_0_FONT_SITELEN_PONA_LEKO_MAJUNA_DARK | HUD_RED_PAL)
COLOR_SP_RED = (CHR_BANK_0_FONT_MARSHMALLOW_DARK | HUD_RED_PAL)

D_NEWLINE     = $80
D_WAIT        = $81
D_CLEAR       = $82
D_CLOSE       = $83
D_ATTR        = $84 ; Set color and font together. Note that we start with white+ascii
D_LOCALIZE    = $85 ; Do not nest these! Only has enough state to return once.
D_RETURN      = $86 ; Return from the localized string back to the original string
D_EXT_CHAR    = $87 ; draw a character from the   0-255 range, one time. (does not affect state)
D_LOW_PAGE    = $88 ; switch permanently to drawing from the   0-127 range
D_HI_PAGE     = $89 ; switch permanently to drawing from the 128-255 range
D_PAL         = $8A ; Set color only, preserving font
D_FONT        = $8B ; Set font only, preserving color
D_PLAYER_NAME = $8C ; Draw the player's name, right here!
D_DQ = $22
