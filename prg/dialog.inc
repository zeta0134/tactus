.global init_dialog
.global update_dialog

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

D_NEWLINE = $80
D_WAIT    = $81
D_CLEAR   = $82
D_CLOSE   = $83
D_ATTR    = $84

