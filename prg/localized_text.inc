
LANGUAGE_ID_ENGLISH                  = 0
LANGUAGE_ID_TOKI_PONA_SITELEN_LASINA = 1
LANGUAGE_ID_TOKI_PONA_SITELEN_PONA   = 2


.macro localized_str string_addr
    .byte D_LOCALIZE, <string_addr, >string_addr, <.bank(string_addr)
.endmacro


.global hello_world_localized