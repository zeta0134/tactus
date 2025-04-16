
LANGUAGE_ID_ENGLISH                  = 0
LANGUAGE_ID_TOKI_PONA_SITELEN_LASINA = 1
LANGUAGE_ID_TOKI_PONA_SITELEN_PONA   = 2


.macro localized_str string_addr
    .byte D_LOCALIZE, <string_addr, >string_addr, <.bank(string_addr)
.endmacro

; Handy in the UI, where we are often localizing short strings that should terminate
; after the localized component. Keeps things compact and tidy.
.macro localized_str_close string_addr
    .byte D_LOCALIZE, <string_addr, >string_addr, <.bank(string_addr), D_CLOSE
.endmacro

.global hello_world_localized

.include "../art/text/header.asm"