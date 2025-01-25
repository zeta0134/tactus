; IDs into the sign text table
; Use hex here to match what's in the technical tileset
; prefer to leave holes, it's a pain to rearrange these later
SIGN_PLACEHOLDER       = $00
SIGN_SHOP              = $01
SIGN_WELCOME_TO_DEBUG  = $02
SIGN_DEBUG_ZONE_1      = $03
SIGN_DEBUG_ZONE_2A     = $04
SIGN_DEBUG_ZONE_2B     = $05
SIGN_DEBUG_ZONE_2C     = $06
SIGN_DEBUG_ZONE_2W     = $07
SIGN_DEBUG_ZONE_3A     = $08
SIGN_DEBUG_ZONE_3B     = $09
SIGN_DEBUG_ZONE_3C     = $0A
SIGN_DEBUG_ZONE_3W     = $0B
SIGN_DEBUG_ZONE_4A     = $0C
SIGN_DEBUG_ZONE_4B     = $0D
SIGN_DEBUG_ZONE_4C     = $0E
SIGN_DEBUG_ZONE_4W     = $0F
SIGN_DEBUG_ZONE_5S     = $10
SIGN_DEBUG_ZONE_5W     = $11
SIGN_DEBUG_ZONE_MISC_1 = $12
SIGN_DEBUG_ZONE_MISC_2 = $13
SIGN_DEBUG_ZONE_MISC_3 = $14

; that table
.global sign_text_table

; a function to activate / advance a given sign by index
.global FAR_display_sign_text
