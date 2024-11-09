        .include "signs.inc"

        .include "../build/tile_defs.inc"

        .include "hud.inc"
        .include "dialog.inc"
        .include "prng.inc"
        .include "zpcm.inc"

        .segment "TEXT_STRINGS"

sign_text_bank:

sign_placeholder:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hello World! I'm just a", D_NEWLINE
        .byte "placeholder sign with", D_NEWLINE
        .byte "nothing important to say!", D_WAIT, D_CLOSE

sign_shop_generic:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_YELLOW_PAL)
        .byte "GENERAL STORE", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "  All sales final.", D_NEWLINE
        .byte "    ", D_DQ, "WHAT A DEAL!", D_DQ, "  ", D_WAIT, D_CLOSE

shop_mike_tv:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Surprise your friends,", D_NEWLINE
        .byte " amaze your family,", D_NEWLINE
        .byte "  annoy perfect strangers!", D_WAIT, D_CLOSE

shop_bizzare_bazaar:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_YELLOW_PAL)
        .byte "BIZARRE BAZAAR", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "  If you have to ask,", D_NEWLINE
        .byte "    you don't wanna know.", D_WAIT, D_CLOSE

shop_wicked_wares:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_YELLOW_PAL)
        .byte "WICKED WARES", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "  Guaranteed to knock", D_NEWLINE
        .byte "    their socks off!", D_WAIT, D_CLOSE

sign_hub_zone_1:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "ZONE 1 - GRASSLANDS", D_WAIT, D_CLOSE

sign_hub_zone_2:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "ZONE 2 - BEACH", D_NEWLINE
        .byte "(very WIP)", D_WAIT, D_CLOSE

sign_hub_zone_3:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "ZONE 1 - GRASSLANDS", D_NEWLINE
        .byte "DEBUG: Fast Tempo!", D_WAIT, D_CLOSE

sign_hub_zone_4:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "ZONE 1-2 - GRASSLANDS", D_NEWLINE
        .byte "(for testing spawns)", D_WAIT, D_CLOSE

sign_multiline_test:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hello World!", D_NEWLINE
        .byte "I'm a sign with a whole", D_NEWLINE
        .byte "bunch of text!", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_RED_PAL)
        .byte "Ph'nglui mglw'nafh ", D_ATTR, (FONT_BANK | HUD_TEXT_PAL), "Cthulhu", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_RED_PAL)
        .byte "R'lyeh wgah'nagl fhtagn.", D_NEWLINE
        .byte "Nyarlathotep throd f'ghft", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte "ftaghu sgn'wahl, shugg", D_NEWLINE
        .byte "hlirgh h'shagg ", D_ATTR, (FONT_BANK | HUD_PURPLE_PAL), "Yoggoth", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_RED_PAL)
        .byte "hlirgh h'sll'ha shagg naep", D_WAIT, D_CLEAR
        ;     0123456789012345678901234567 ; 28-char width
        .byte "tharanak uaaah, hai goka", D_NEWLINE
        .byte "'bthnk nnnsgn'wahl", D_NEWLINE
        .byte "nnnvulgtlagln ooboshu.", D_WAIT, D_CLOSE

        .segment "CODE_0"

sign_text_table:
        .word sign_placeholder
        .word sign_shop_generic ; secretly indexes into shop text instead!
        .word sign_hub_zone_1
        .word sign_hub_zone_2
        .word sign_hub_zone_3
        .word sign_hub_zone_4
        .word sign_multiline_test

shop_text_table:
        .word sign_shop_generic
        .word shop_mike_tv
        .word shop_bizzare_bazaar
        .word shop_wicked_wares
NUM_SHOP_SIGNS = 4

.proc shop_sign_rng
        ; we actually want this to be really deterministic, so base it
        ; on the floor seed's lowest byte
        lda floor_seed+0
        rts
.endproc

; Sign ID in A
.proc FAR_display_sign_text
        cmp #SIGN_SHOP
        beq roll_random_shop_sign
        asl
        tax
        lda sign_text_table+0, x
        sta DialogActiveStringPtr+0
        lda sign_text_table+1, x
        sta DialogActiveStringPtr+1
        jmp converge
roll_random_shop_sign:
        in_range_smol shop_sign_rng, #NUM_SHOP_SIGNS
        asl
        tax
        lda shop_text_table+0, x
        sta DialogActiveStringPtr+0
        lda shop_text_table+1, x
        sta DialogActiveStringPtr+1
converge:
        lda #<.bank(sign_text_bank)
        sta DialogActiveStringBank
        lda #1
        sta DialogInitiateActiveMode
        rts
.endproc
