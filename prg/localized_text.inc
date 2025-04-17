
LANGUAGE_ID_ENGLISH                  = 0
LANGUAGE_ID_TOKI_PONA_SITELEN_LASINA = 1
LANGUAGE_ID_TOKI_PONA_SITELEN_PONA   = 2


.macro localized_embed string_name
    .byte D_LOCALIZE
    .byte <(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte >(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte <.bank((.ident(.sprintf("%s_localized", .string(string_name)))))
.endmacro

; Handy in the UI, where we are often localizing short strings that should terminate
; after the localized component. Keeps things compact and tidy.
.macro localized_str string_name
    .byte D_LOCALIZE
    .byte <(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte >(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte <.bank((.ident(.sprintf("%s_localized", .string(string_name)))))
    .byte D_CLOSE
.endmacro

; Same deal but with a non-default color, useful for all sorts of stuff
.macro localized_color_str color, string_name
    .byte D_PAL, color
    .byte D_LOCALIZE
    .byte <(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte >(.ident(.sprintf("%s_localized", .string(string_name))))
    .byte <.bank((.ident(.sprintf("%s_localized", .string(string_name)))))
    .byte D_CLOSE
.endmacro

.global hello_world_localized

.include "../build/localization/text_strings.inc"