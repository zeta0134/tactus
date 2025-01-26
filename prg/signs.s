        .include "signs.inc"

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "dialog.inc"
        .include "player.inc"
        .include "procgen.inc"
        .include "prng.inc"
        .include "zpcm.inc"

        .segment "TEXT_STRINGS"

sign_text_bank:

sign_placeholder:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Hello World! I'm just a", D_NEWLINE
        .byte "placeholder sign with", D_NEWLINE
        .byte "nothing important to say!", D_WAIT, D_CLOSE

sign_snowy_shop_festivus:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_RED
        .byte "HAPPY FESTIVUS", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte " Need to air grievances?", D_NEWLINE
        .byte "  We've got just the thing!", D_WAIT, D_CLOSE

sign_snowy_shop_happy_holidays:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_RED
        .byte "HAPPY HOLIDAYS", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "  From all of us at", D_NEWLINE
        .byte "    Boxgirl Studios!", D_WAIT, D_CLOSE

sign_snowy_shop_ho_ho_ho:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_RED
        .byte "HO - HO - HO", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "   Now I have", D_NEWLINE
        .byte "      a machine gun!", D_WAIT, D_CLOSE

sign_shop_generic:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "GENERAL STORE", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "  All sales final.", D_NEWLINE
        .byte "    ", D_DQ, "WHAT A DEAL!", D_DQ, "  ", D_WAIT, D_CLOSE

shop_mike_tv:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Surprise your friends,", D_NEWLINE
        .byte " amaze your family,", D_NEWLINE
        .byte "  annoy perfect strangers!", D_WAIT, D_CLOSE

shop_bizzare_bazaar:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "BIZARRE BAZAAR", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "  If you have to ask,", D_NEWLINE
        .byte "    you don't wanna know.", D_WAIT, D_CLOSE

shop_wicked_wares:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "WICKED WARES", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "  Guaranteed to knock", D_NEWLINE
        .byte "    their socks off!", D_WAIT, D_CLOSE


; SIGN_WELCOME_TO_DEBUG = $02

sign_welcome_to_debug:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Welcome to Debug Zone!", D_NEWLINE
        .byte D_ATTR, COLOR_MM_GREY
        .byte "(Sorry, no fancy music.)", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Rooms are sorted by order", D_NEWLINE
        .byte "of appearance. This room is", D_NEWLINE
        .byte "Zone 1, which is always the", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte "starting zone. Each room to", D_NEWLINE
        .byte "the north has the potential", D_NEWLINE
        .byte "zones that may follow.", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte "Grab some items to gear up", D_NEWLINE
        .byte "as needed. Nothing in here", D_NEWLINE
        .byte "is sacred, etc.", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_1 = $03

sign_debug_zone_1:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 1: Grasslands", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_2A = $04

sign_debug_zone_2a:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 2A: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_2B = $05

sign_debug_zone_2b:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 2B: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_2C = $06

sign_debug_zone_2c:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 2C: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_2W = $07

sign_debug_zone_2w:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 2W: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_3A = $08

sign_debug_zone_3a:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 3A: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_3B = $09

sign_debug_zone_3b:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 3B: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_3C = $0A

sign_debug_zone_3c:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 3C: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_3W = $0B

sign_debug_zone_3w:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 3W: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_4A = $0C

sign_debug_zone_4a:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 4A: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_4B = $0D

sign_debug_zone_4b:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 4B: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_4C = $0E

sign_debug_zone_4c:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 4C: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_4W = $0F

sign_debug_zone_4w:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 4W: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Boss         F4  F3  F2  F1", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_5S = $10

sign_debug_zone_5s:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_RED
        .byte "Zone 5S: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "F1  F2  F3  F4         Boss", D_WAIT, D_CLOSE

; SIGN_DEBUG_ZONE_5w = $11

sign_debug_zone_5w:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_RED
        .byte "Zone 5W: Placeholder", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "F1  F2  F3  F4         Boss", D_WAIT, D_CLOSE

sign_debug_misc_1:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, COLOR_MM_YELLOW
        .byte "Zone 1-2 but fast!", D_NEWLINE
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "An early speed, this is", D_NEWLINE
        .byte "largely obsolte.", D_WAIT, D_CLOSE

sign_debug_misc_2:
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Reserved for future use.", D_WAIT, D_CLOSE

sign_debug_misc_3:
        .byte D_ATTR, COLOR_MM_WHITE
        .byte "Reserved for future use.", D_WAIT, D_CLOSE

        .segment "CODE_0"

sign_text_table:
        .word sign_placeholder      ; SIGN_PLACEHOLDER      = $00
        .word sign_shop_generic     ; SIGN_SHOP             = $01 (secretly indexes into shop text instead!)
        .word sign_welcome_to_debug ; SIGN_WELCOME_TO_DEBUG = $02
        .word sign_debug_zone_1     ; SIGN_DEBUG_ZONE_1     = $03
        .word sign_debug_zone_2a    ; SIGN_DEBUG_ZONE_2A    = $04
        .word sign_debug_zone_2b    ; SIGN_DEBUG_ZONE_2B    = $05
        .word sign_debug_zone_2c    ; SIGN_DEBUG_ZONE_2C    = $06
        .word sign_debug_zone_2w    ; SIGN_DEBUG_ZONE_2W    = $07
        .word sign_debug_zone_3a    ; SIGN_DEBUG_ZONE_3A    = $08
        .word sign_debug_zone_3b    ; SIGN_DEBUG_ZONE_3B    = $09
        .word sign_debug_zone_3c    ; SIGN_DEBUG_ZONE_3C    = $0A
        .word sign_debug_zone_3w    ; SIGN_DEBUG_ZONE_3W    = $0B
        .word sign_debug_zone_4a    ; SIGN_DEBUG_ZONE_4A    = $0C
        .word sign_debug_zone_4b    ; SIGN_DEBUG_ZONE_4B    = $0D
        .word sign_debug_zone_4c    ; SIGN_DEBUG_ZONE_4C    = $0E
        .word sign_debug_zone_4w    ; SIGN_DEBUG_ZONE_4W    = $0F
        .word sign_debug_zone_5s    ; SIGN_DEBUG_ZONE_5S    = $10
        .word sign_debug_zone_5w    ; SIGN_DEBUG_ZONE_5A    = $11
        .word sign_debug_misc_1     ; SIGN_DEBUG_MISC_1     = $12
        .word sign_debug_misc_2     ; SIGN_DEBUG_MISC_2     = $13
        .word sign_debug_misc_3     ; SIGN_DEBUG_MISC_3     = $14

shop_text_table:
        .word sign_shop_generic
        .word shop_mike_tv
        .word shop_bizzare_bazaar
        .word shop_wicked_wares
NUM_SHOP_SIGNS = 4

sign_text_table_snowy:
        .word sign_snowy_shop_festivus
        .word sign_snowy_shop_happy_holidays
        .word sign_snowy_shop_ho_ho_ho
NUM_SNOWY_SHOP_SIGNS = 3

.proc shop_sign_rng
        ; we actually want this to be really deterministic, so base it
        ; on the floor seed's lowest byte
        lda floor_seed+0
        rts
.endproc

; Sign ID in A
.proc FAR_display_sign_text
        cmp #SIGN_SHOP
        beq shop_sign
        asl
        tax
        lda sign_text_table+0, x
        sta DialogActiveStringPtr+0
        lda sign_text_table+1, x
        sta DialogActiveStringPtr+1
        jmp converge
shop_sign:
        ldx PlayerRoomIndex
        lda room_palette_variant, x
        cmp #ROOM_PALETTE_ICE
        beq roll_random_holiday_sign
roll_random_regular_sign:
        in_range_smol shop_sign_rng, #NUM_SHOP_SIGNS
        asl
        tax
        lda shop_text_table+0, x
        sta DialogActiveStringPtr+0
        lda shop_text_table+1, x
        sta DialogActiveStringPtr+1
        jmp converge
roll_random_holiday_sign:
        in_range_smol shop_sign_rng, #NUM_SNOWY_SHOP_SIGNS
        asl
        tax
        lda sign_text_table_snowy+0, x
        sta DialogActiveStringPtr+0
        lda sign_text_table_snowy+1, x
        sta DialogActiveStringPtr+1
converge:
        lda #<.bank(sign_text_bank)
        sta DialogActiveStringBank
        lda #1
        sta DialogInitiateActiveMode
        rts
.endproc
