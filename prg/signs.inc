; IDs into the sign text table
; Use hex here to match what's in the technical tileset
; prefer to leave holes, it's a pain to rearrange these later
SIGN_PLACEHOLDER    = $00
SIGN_SHOP           = $01
SIGN_HUB_ZONE_1     = $02
SIGN_HUB_ZONE_2     = $03
SIGN_HUB_ZONE_3     = $04
SIGN_HUB_ZONE_4     = $05
SIGN_MULTILINE_TEST = $06

; that table
.global sign_text_table

; a function to activate / advance a given sign by index
.global FAR_display_sign_text
