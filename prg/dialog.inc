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

FONT_BANK = CHR_BANK_FONT_MARSHMALLOW
DIALOG_NAMETABLE_BASE = $56C0
DIALOG_ATTRIBUTE_BASE = $5EC0

COLOR_MM_WHITE = (CHR_BANK_FONT_MARSHMALLOW | HUD_TEXT_PAL)
COLOR_MM_GREY = (CHR_BANK_FONT_MARSHMALLOW_DARK | HUD_TEXT_PAL)
COLOR_MM_YELLOW = (CHR_BANK_FONT_MARSHMALLOW_DARK | HUD_YELLOW_PAL)
COLOR_MM_BLUE = (CHR_BANK_FONT_MARSHMALLOW | HUD_PURPLE_PAL)
COLOR_MM_DARK_BLUE = (CHR_BANK_FONT_MARSHMALLOW_DARK | HUD_PURPLE_PAL)
COLOR_MM_PEACH = (CHR_BANK_FONT_MARSHMALLOW | HUD_RED_PAL)
COLOR_MM_RED = (CHR_BANK_FONT_MARSHMALLOW_DARK | HUD_RED_PAL)

D_NEWLINE = $80
D_WAIT    = $81
D_CLEAR   = $82
D_CLOSE   = $83
D_ATTR    = $84


D_DQ = $22
