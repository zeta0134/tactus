        .include "../build/tile_defs.inc"        
        .include "_globals.inc"

        .include "dialog.inc"
        .include "localized_text.inc"
        .include "localization_defines.inc"

; The actual textual data the game will be using, translated
; into the user's selected target language. These are the string
; tables pointed to by the LOCALIZED_STR command, indexed by that
; language's ID. Comments will establish context (for future
; translation efforts) and any requirements, like maximum length,
; that must be adhered to.

.include "../build/localization/text_strings.asm"
