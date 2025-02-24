        .include "items.inc"

        .include "../build/tile_defs.inc"
        
        .include "_globals.inc"

        .include "dialog.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "player.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "torchlight.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .zeropage

; for use during general purpose routines, since I don't want to delicately
; dance around scratch byte allocation
ItemPtr: .res 2
ItemFuncPtr: .res 2

        .segment "RAM"

item_bank_ids: .res 4
item_bank_refs: .res 4

        .segment "TEXT_STRINGS"

no_item_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "NO ITEM", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Huh? You shouldn't be", D_NEWLINE
        .byte "reading this!", D_WAIT, D_CLOSE

dagger_lv1_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "DAGGER", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "...kinda crummy!", D_WAIT, D_CLOSE

broadsword_lv1_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BROADSWORD", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 3 squares in front.", D_WAIT, D_CLOSE

broadsword_lv2_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BROADSWORD - L2", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 3 squares in front.", D_WAIT, D_CLOSE

broadsword_lv3_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BROADSWORD - L3", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 3 squares in front.", D_WAIT, D_CLOSE

longsword_lv1_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "LONGSWORD", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 2 squares ahead.", D_WAIT, D_CLOSE

longsword_lv2_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "LONGSWORD - L2", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 2 squares ahead.", D_WAIT, D_CLOSE

longsword_lv3_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "LONGSWORD - L3", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Hits 2 squares ahead.", D_WAIT, D_CLOSE

spear_lv1_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SPEAR", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike one foe up to", D_NEWLINE
        .byte "2 squares ahead.", D_WAIT, D_CLOSE

spear_lv2_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SPEAR - L2", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike one foe up to", D_NEWLINE
        .byte "2 squares ahead.", D_WAIT, D_CLOSE

spear_lv3_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SPEAR - L3", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike one foe up to", D_NEWLINE
        .byte "2 squares ahead.", D_WAIT, D_CLOSE

flail_lv1_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "FLAIL", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike adjacent foes", D_NEWLINE
        .byte "while moving.", D_WAIT, D_CLOSE

flail_lv2_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "FLAIL - L2", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike adjacent foes", D_NEWLINE
        .byte "while moving.", D_WAIT, D_CLOSE

flail_lv3_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "FLAIL - L3", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Strike adjacent foes", D_NEWLINE
        .byte "while moving.", D_WAIT, D_CLOSE

basic_torch_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "TORCH", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+1 Lighting Radius", D_WAIT, D_CLOSE

large_torch_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BIG OL' TORCH", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+4 Lighting Radius", D_WAIT, D_CLOSE

; Consumables don't display text in-game, but we might want
; to make a sortof in-game glossary, and that's where these
; could be used. Might as well populate them while we're on
; a roll with the things.
compass_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "COMPASS", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Locate special chambers.", D_WAIT, D_CLOSE

map_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "DUNGEON MAP", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Fully reveal the current", D_NEWLINE
        .byte "floor.", D_WAIT, D_CLOSE

small_fries_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SMALL FRIES", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+4 HP. Quite Salty.", D_WAIT, D_CLOSE

medium_fries_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "MEDIUM FRIES", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+8 HP. Best with ketchup.", D_WAIT, D_CLOSE

large_fries_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "LARGE FRIES", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Heals all HP! Satiating.", D_WAIT, D_CLOSE

go_go_boots_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "GO GO BOOTS", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Tap twice, move twice.", D_WAIT, D_CLOSE

gold_sack_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "GOLD SACK", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "One can never have too", D_NEWLINE
        .byte "much treasure!", D_WAIT, D_CLOSE

heart_container_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "HEART CONTAINER", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+4 Maximum HP", D_WAIT, D_CLOSE

temporary_heart_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BONUS HEART", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+4 Temporary HP", D_WAIT, D_CLOSE

heart_armor_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "HEART ARMOR", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Reduce incoming damage to", D_NEWLINE
        .byte "this heart.", D_WAIT, D_CLOSE

defensive_shield_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "DEFENSIVE SHIELD", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "-2 Incoming Damage.", D_WAIT, D_CLOSE

chain_link_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "CHAIN LINK", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "+2 Chain Duration.", D_WAIT, D_CLOSE

aloha_tshirt_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "ALOHA T-SHIRT", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "-1 Incoming Damage.", D_NEWLINE
        .byte "Tourists charged double!", D_WAIT, D_CLOSE

bombs_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BOMBS", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Explodes in a 3x3 area!", D_NEWLINE
        .byte "B to hold, + to throw", D_WAIT, D_CLOSE

spell_fire_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SCORCH", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Burns one entire chamber!", D_WAIT, D_CLOSE

spell_air_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "SHOCK", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Electrify one entire", D_NEWLINE
        .byte "chamber!", D_WAIT, D_CLOSE

spell_ice_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "CHILL", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Freeze one entire chamber!", D_WAIT, D_CLOSE

spell_earth_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "GROWTH", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Return one entire chamber", D_NEWLINE
        .byte "to nature!", D_WAIT, D_CLOSE

spell_bomb_fiesta_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "BOMB FIESTA", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "It's a party and the whole", D_NEWLINE
        .byte "chamber's invited!", D_WAIT, D_CLOSE

spell_life_description:
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_ATTR, (FONT_BANK | HUD_PURPLE_PAL)
        .byte "HEALING", D_NEWLINE
        .byte D_ATTR, (FONT_BANK | HUD_TEXT_PAL)
        .byte "Fully restore all hearts!", D_NEWLINE
        .byte "Tastes like strawberries.", D_WAIT, D_CLOSE

        .segment "DATA_0"

item_table:
        .word no_item
        .word dagger_lvl_1
        .word broadsword_lvl_1
        .word broadsword_lvl_2
        .word broadsword_lvl_3
        .word longsword_lvl_1
        .word longsword_lvl_2
        .word longsword_lvl_3
        .word spear_lvl_1
        .word spear_lvl_2
        .word spear_lvl_3
        .word flail_lvl_1
        .word flail_lvl_2
        .word flail_lvl_3
        .word basic_torch
        .word large_torch
        .word compass
        .word map
        .word small_fries
        .word medium_fries
        .word large_fries
        .word go_go_boots
        .word gold_sack
        .word heart_container
        .word temporary_heart
        .word heart_armor
        .word defensive_shield
        .word chain_link
        .word aloha_tshirt_1
        .word aloha_tshirt_2
        .word aloha_tshirt_3
        .word bomb_standard
        .word bomb_standard_one_pack
        .word bomb_standard_three_pack
        .word spell_fire
        .word spell_air
        .word spell_ice
        .word spell_earth
        .word spell_bomb_fiesta
        .word spell_healing

        ; safety
        .repeat 128
        .word no_item
        .endrepeat

no_item:
        .byte SLOT_WEAPON                     ; SlotId (irrelevant)
        .word SPRITE_ITEMS_04_INVALID_ITEM    ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 50                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)      ; DescriptionStringBank

dagger_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .word SPRITE_ITEMS_01_DAGGER          ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_DAGGER         ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 25                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr dagger_lv1_description          ; DescriptionStringPtr
        .byte <.bank(dagger_lv1_description)   ; DescriptionStringBank

broadsword_lvl_1:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_01_BROADSWORD        ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD       ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 75                                ; ShopCost
        .byte WEAPON_BROADSWORD                 ; WeaponShape
        .addr flat_1                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr broadsword_lv1_description        ; DescriptionStringPtr
        .byte <.bank(broadsword_lv1_description) ; DescriptionStringBank

broadsword_lvl_2:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_01_BROADSWORD        ; WorldSpriteTile
        .byte SPRITE_PAL_RED                    ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD       ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 250                               ; ShopCost
        .byte WEAPON_BROADSWORD                 ; WeaponShape
        .addr flat_2                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr broadsword_lv2_description        ; DescriptionStringPtr
        .byte <.bank(broadsword_lv2_description) ; DescriptionStringBank

broadsword_lvl_3:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_01_BROADSWORD        ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD       ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 1000                              ; ShopCost
        .byte WEAPON_BROADSWORD                 ; WeaponShape
        .addr flat_3                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr broadsword_lv3_description        ; DescriptionStringPtr
        .byte <.bank(broadsword_lv3_description) ; DescriptionStringBank

longsword_lvl_1:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_03_LONGSWORD         ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD        ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 75                                ; ShopCost
        .byte WEAPON_LONGSWORD                  ; WeaponShape
        .addr flat_1                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr longsword_lv1_description         ; DescriptionStringPtr
        .byte <.bank(longsword_lv1_description)  ; DescriptionStringBank

longsword_lvl_2:
        .byte SLOT_WEAPON                      ; SlotId
        .word SPRITE_ITEMS_03_LONGSWORD        ; WorldSpriteTile
        .byte SPRITE_PAL_RED                   ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD       ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)   ; HudBgAttr
        .byte 0                                ; HudSpriteTile
        .byte 0                                ; HudSpriteAttr
        .word 250                              ; ShopCost
        .byte WEAPON_LONGSWORD                 ; WeaponShape
        .addr flat_2                           ; DamageFunc
        .addr no_effect                        ; TorchlightFunc
        .addr do_nothing                       ; UseFunc
        .addr no_effect                        ; DmgReductionFunc
        .addr longsword_lv2_description        ; DescriptionStringPtr
        .byte <.bank(longsword_lv2_description) ; DescriptionStringBank

longsword_lvl_3:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_03_LONGSWORD         ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD        ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 1000                              ; ShopCost
        .byte WEAPON_LONGSWORD                  ; WeaponShape
        .addr flat_3                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr longsword_lv3_description         ; DescriptionStringPtr
        .byte <.bank(longsword_lv3_description)  ; DescriptionStringBank

spear_lvl_1:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_03_SPEAR             ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR            ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 50                                ; ShopCost
        .byte WEAPON_SPEAR                      ; WeaponShape
        .addr flat_1                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spear_lv1_description             ; DescriptionStringPtr
        .byte <.bank(spear_lv1_description)      ; DescriptionStringBank

spear_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .word SPRITE_ITEMS_03_SPEAR           ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR          ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 200                             ; ShopCost
        .byte WEAPON_SPEAR                    ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr spear_lv2_description           ; DescriptionStringPtr
        .byte <.bank(spear_lv2_description)    ; DescriptionStringBank

spear_lvl_3:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_03_SPEAR             ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR            ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 750                               ; ShopCost
        .byte WEAPON_SPEAR                      ; WeaponShape
        .addr flat_3                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spear_lv3_description             ; DescriptionStringPtr
        .byte <.bank(spear_lv3_description)      ; DescriptionStringBank

flail_lvl_1:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_02_FLAIL             ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL            ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 100                               ; ShopCost
        .byte WEAPON_FLAIL                      ; WeaponShape
        .addr flat_1                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr flail_lv1_description             ; DescriptionStringPtr
        .byte <.bank(flail_lv1_description)      ; DescriptionStringBank

flail_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .word SPRITE_ITEMS_02_FLAIL           ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL          ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 350                             ; ShopCost
        .byte WEAPON_FLAIL                    ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr flail_lv2_description           ; DescriptionStringPtr
        .byte <.bank(flail_lv2_description)    ; DescriptionStringBank

flail_lvl_3:
        .byte SLOT_WEAPON                       ; SlotId
        .word SPRITE_ITEMS_02_FLAIL             ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL            ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 1250                              ; ShopCost
        .byte WEAPON_FLAIL                      ; WeaponShape
        .addr flat_3                            ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr flail_lv3_description             ; DescriptionStringPtr
        .byte <.bank(flail_lv3_description)      ; DescriptionStringBank

basic_torch:
        .byte SLOT_TORCH                        ; SlotId
        .word SPRITE_ITEMS_01_BASIC_TORCH       ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_BASIC_TORCH             ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 50                                ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr flat_8                            ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr basic_torch_description           ; DescriptionStringPtr
        .byte <.bank(basic_torch_description)    ; DescriptionStringBank

large_torch:
        .byte SLOT_TORCH                        ; SlotId
        .word SPRITE_ITEMS_03_LARGE_TORCH       ; WorldSpriteTile
        .byte SPRITE_PAL_RED                    ; WorldSpriteAttr
        .byte EQUIPMENT_LARGE_TORCH             ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 150                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr flat_15                           ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr large_torch_description           ; DescriptionStringPtr
        .byte <.bank(large_torch_description)    ; DescriptionStringBank

compass:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_01_COMPASS         ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 75                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr identify_special_rooms          ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr compass_description             ; DescriptionStringPtr
        .byte <.bank(compass_description)      ; DescriptionStringBank

map:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_03_MAP             ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 150                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr map_all_rooms                   ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr map_description                 ; DescriptionStringPtr
        .byte <.bank(map_description)          ; DescriptionStringBank

small_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_03_SMALL_FRIES     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 25                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_4_hp                       ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr small_fries_description         ; DescriptionStringPtr
        .byte <.bank(small_fries_description)  ; DescriptionStringBank

medium_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_03_MEDIUM_FRIES    ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 75                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_8_hp                       ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr medium_fries_description        ; DescriptionStringPtr
        .byte <.bank(medium_fries_description) ; DescriptionStringBank

large_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_02_LARGE_FRIES     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 150                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_all_hp                     ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr large_fries_description         ; DescriptionStringPtr
        .byte <.bank(large_fries_description)  ; DescriptionStringBank

; Note: as an item with a custom effect, these are just special-case checked
; in the player movement code
go_go_boots:
        .byte SLOT_BOOTS                      ; SlotId
        .word SPRITE_ITEMS_02_GO_GO_BOOTS     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_GO_GO_BOOTS           ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 150                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr go_go_boots_description         ; DescriptionStringPtr
        .byte <.bank(go_go_boots_description)  ; DescriptionStringBank

gold_sack:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_02_GOLD_SACK       ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 0                               ; ShopCost (does not spawn in shops)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_100_gold                   ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr gold_sack_description           ; DescriptionStringPtr
        .byte <.bank(gold_sack_description)    ; DescriptionStringBank

heart_container:
        .byte SLOT_CONSUMABLE                    ; SlotId
        .word SPRITE_ITEMS_02_HEART_CONTAINER    ; WorldSpriteTile
        .byte SPRITE_PAL_RED                     ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                     ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS)    ; HudBgAttr (unused)
        .byte 0                                  ; HudSpriteTile (unused)
        .byte 0                                  ; HudSpriteAttr (unused)
        .word 250                                ; ShopCost
        .byte WEAPON_DAGGER                      ; WeaponShape (unused)
        .addr no_effect                          ; DamageFunc
        .addr no_effect                          ; TorchlightFunc
        .addr give_heart_container               ; UseFunc
        .addr no_effect                          ; DmgReductionFunc
        .addr heart_container_description        ; DescriptionStringPtr
        .byte <.bank(heart_container_description) ; DescriptionStringBank

temporary_heart:
        .byte SLOT_CONSUMABLE                    ; SlotId
        .word SPRITE_ITEMS_02_HEART_CONTAINER    ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                  ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                     ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS)    ; HudBgAttr (unused)
        .byte 0                                  ; HudSpriteTile (unused)
        .byte 0                                  ; HudSpriteAttr (unused)
        .word 50                                 ; ShopCost
        .byte WEAPON_DAGGER                      ; WeaponShape (unused)
        .addr no_effect                          ; DamageFunc
        .addr no_effect                          ; TorchlightFunc
        .addr FAR_give_temporary_heart           ; UseFunc
        .addr no_effect                          ; DmgReductionFunc
        .addr temporary_heart_description        ; DescriptionStringPtr
        .byte <.bank(temporary_heart_description) ; DescriptionStringBank

heart_armor:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_02_HEART_ARMOR     ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 100                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_heart_armor                ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr heart_armor_description         ; DescriptionStringPtr
        .byte <.bank(heart_armor_description)  ; DescriptionStringBank

; TODO: this really needs to be directional, and much stronger
defensive_shield:
        .byte SLOT_ARMOR                           ; SlotId
        .word SPRITE_ITEMS_03_SHIELD               ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                    ; WorldSpriteAttr
        .byte EQUIPMENT_ARMOR_SHIELD               ; HudBgTile (unused)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS)    ; HudBgAttr (unused)
        .byte 0                                    ; HudSpriteTile (unused)
        .byte 0                                    ; HudSpriteAttr (unused)
        .word 500                                  ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr no_effect                            ; DamageFunc
        .addr no_effect                            ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr flat_2                               ; DmgReductionFunc
        .addr defensive_shield_description         ; DescriptionStringPtr
        .byte <.bank(defensive_shield_description) ; DescriptionStringBank

; This item has a rather custom effect, so we'll check for
; it manually in the one spot where it would apply
chain_link:
        .byte SLOT_ACCESSORY                    ; SlotId
        .word SPRITE_ITEMS_01_CHAIN_LINK        ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_ACCESSORY_CHAIN_LINK    ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 150                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc        
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr chain_link_description            ; DescriptionStringPtr
        .byte <.bank(chain_link_description)    ; DescriptionStringBank

aloha_tshirt_1:
        .byte SLOT_ARMOR                        ; SlotId
        .word SPRITE_ITEMS_01_ALOHA_TSHIRT_TEXT ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_ARMOR_TSHIRT_TEXT       ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 99                                ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc        
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr flat_1                            ; DmgReductionFunc
        .addr aloha_tshirt_description          ; DescriptionStringPtr
        .byte <.bank(aloha_tshirt_description)  ; DescriptionStringBank

aloha_tshirt_2:
        .byte SLOT_ARMOR                          ; SlotId
        .word SPRITE_ITEMS_01_ALOHA_TSHIRT_FLORAL ; WorldSpriteTile
        .byte SPRITE_PAL_RED                      ; WorldSpriteAttr
        .byte EQUIPMENT_ARMOR_TSHIRT_FLORAL       ; HudBgTile (unused)
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)      ; HudBgAttr (unused)
        .byte 0                                   ; HudSpriteTile (unused)
        .byte 0                                   ; HudSpriteAttr (unused)
        .word 99                                  ; ShopCost
        .byte WEAPON_DAGGER                       ; WeaponShape (unused)
        .addr no_effect                           ; DamageFunc        
        .addr no_effect                           ; TorchlightFunc
        .addr do_nothing                          ; UseFunc
        .addr flat_1                              ; DmgReductionFunc
        .addr aloha_tshirt_description            ; DescriptionStringPtr
        .byte <.bank(aloha_tshirt_description)    ; DescriptionStringBank

aloha_tshirt_3:
        .byte SLOT_ARMOR                         ; SlotId
        .word SPRITE_ITEMS_01_ALOHA_TSHIRT_SKULL ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                  ; WorldSpriteAttr
        .byte EQUIPMENT_ARMOR_TSHIRT_SKULL       ; HudBgTile (unused)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS)  ; HudBgAttr (unused)
        .byte 0                                  ; HudSpriteTile (unused)
        .byte 0                                  ; HudSpriteAttr (unused)
        .word 99                                 ; ShopCost
        .byte WEAPON_DAGGER                      ; WeaponShape (unused)
        .addr no_effect                          ; DamageFunc        
        .addr no_effect                          ; TorchlightFunc
        .addr do_nothing                         ; UseFunc
        .addr flat_1                             ; DmgReductionFunc
        .addr aloha_tshirt_description           ; DescriptionStringPtr
        .byte <.bank(aloha_tshirt_description)   ; DescriptionStringBank

bomb_standard:
        .byte SLOT_ITEM                         ; SlotId
        .word SPRITE_ITEMS_04_INVALID_ITEM      ; WorldSpriteTile (unused)
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_BOMB_STANDARD           ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 0                                 ; ShopCost (unused)
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr bombs_description                 ; DescriptionStringPtr
        .byte <.bank(bombs_description)         ; DescriptionStringBank

bomb_standard_one_pack:
        .byte SLOT_CONSUMABLE                   ; SlotId
        .word SPRITE_ITEMS_02_ITEM_BOMB_SINGLE  ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_DAGGER           ; HudBgTile (unused)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 25                                ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr award_1_standard_bomb             ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr bombs_description                 ; DescriptionStringPtr
        .byte <.bank(bombs_description)         ; DescriptionStringBank

bomb_standard_three_pack:
        .byte SLOT_CONSUMABLE                   ; SlotId
        .word SPRITE_ITEMS_02_ITEM_BOMB_TRIO    ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_DAGGER           ; HudBgTile (unused)
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 75                                ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr award_3_standard_bombs            ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr bombs_description                 ; DescriptionStringPtr
        .byte <.bank(bombs_description)         ; DescriptionStringBank

; Spells all have pretty much fully custom behavior, so their item functions
; will go mostly unused.

spell_fire:
        .byte SLOT_SPELL                        ; SlotId
        .word SPRITE_ITEMS_04_SPELL_FIRE        ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_FIRE              ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 100                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr no_effect                         ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spell_fire_description            ; DescriptionStringPtr
        .byte <.bank(spell_fire_description)    ; DescriptionStringBank

spell_air:
        .byte SLOT_SPELL                        ; SlotId
        .word SPRITE_ITEMS_03_SPELL_AIR         ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_AIR               ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 100                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr no_effect                         ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spell_air_description             ; DescriptionStringPtr
        .byte <.bank(spell_air_description)     ; DescriptionStringBank

spell_ice:
        .byte SLOT_SPELL                        ; SlotId
        .word SPRITE_ITEMS_04_SPELL_ICE         ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_ICE               ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 100                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr no_effect                         ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spell_ice_description             ; DescriptionStringPtr
        .byte <.bank(spell_ice_description)     ; DescriptionStringBank

spell_earth:
        .byte SLOT_SPELL                        ; SlotId
        .word SPRITE_ITEMS_04_SPELL_EARTH       ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_EARTH             ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 100                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr no_effect                         ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spell_earth_description           ; DescriptionStringPtr
        .byte <.bank(spell_earth_description)   ; DescriptionStringBank

spell_bomb_fiesta:
        .byte SLOT_SPELL                            ; SlotId
        .word SPRITE_ITEMS_04_SPELL_BOMB_FIESTA     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                     ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_BOMB_FIESTA           ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)     ; HudBgAttr (unused)
        .byte 0                                     ; HudSpriteTile (unused)
        .byte 0                                     ; HudSpriteAttr (unused)
        .word 100                                   ; ShopCost
        .byte WEAPON_DAGGER                         ; WeaponShape (unused)
        .addr no_effect                             ; DamageFunc
        .addr no_effect                             ; TorchlightFunc
        .addr no_effect                             ; UseFunc
        .addr no_effect                             ; DmgReductionFunc
        .addr spell_bomb_fiesta_description         ; DescriptionStringPtr
        .byte <.bank(spell_bomb_fiesta_description) ; DescriptionStringBank

spell_healing:
        .byte SLOT_SPELL                        ; SlotId
        .word SPRITE_ITEMS_04_SPELL_LIFE        ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                 ; WorldSpriteAttr
        .byte EQUIPMENT_SPELL_LIFE              ; HudBgTile (unused)
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                                 ; HudSpriteTile (unused)
        .byte 0                                 ; HudSpriteAttr (unused)
        .word 250                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr no_effect                         ; TorchlightFunc
        .addr no_effect                         ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr spell_life_description            ; DescriptionStringPtr
        .byte <.bank(spell_life_description)    ; DescriptionStringBank

        .segment "CODE_ITEMS"

; Flat value functions. If these seem remarkably inefficient, that's because they are

.proc no_effect
        lda #0
        rts
.endproc

.proc flat_1
        lda #1
        rts
.endproc

.proc flat_2
        lda #2
        rts
.endproc

.proc flat_3
        lda #3
        rts
.endproc

.proc flat_4
        lda #4
        rts
.endproc

.proc flat_5
        lda #5
        rts
.endproc

.proc flat_6
        lda #6
        rts
.endproc

.proc flat_7
        lda #7
        rts
.endproc

.proc flat_8
        lda #8
        rts
.endproc

.proc flat_9
        lda #9
        rts
.endproc

.proc flat_10
        lda #10
        rts
.endproc

.proc flat_11
        lda #11
        rts
.endproc

.proc flat_12
        lda #12
        rts
.endproc

.proc flat_13
        lda #13
        rts
.endproc

.proc flat_14
        lda #14
        rts
.endproc

.proc flat_15
        lda #15
        rts
.endproc

.proc do_nothing
        rts
.endproc

; Reveal just "special" chambers! Meant for the compass
.proc identify_special_rooms
        ldx #0
loop:
        perform_zpcm_inc
        ; if this room has an exit, reveal it!
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        bne reveal_room
        ; if this room is a challenge chamber, reveal it!
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_CHALLENGE
        beq reveal_room
        ; if this room is a shop, reveal it!
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        beq reveal_room
        jmp done_with_this_room
reveal_room:
        lda room_minimap_state, x
        ora #ROOM_MINIMAP_FLAG_IDENTIFIED
        sta room_minimap_state, x
done_with_this_room:
        inx
        cpx #::FLOOR_SIZE
        bne loop

        lda #1
        sta HudMapDirty

        ; Play a SFX! Maybe a custom one later, but we'll use the same one for health
        ; containers just to have something
        queue_sfx_pulse1 sfx_heart_container

        lda #0 ; return success
        rts
.endproc

; Same deal but it's not picky; reveal the *entire* map!
.proc map_all_rooms
        ldx #0
loop:
        perform_zpcm_inc
        lda room_minimap_state, x
        ora #ROOM_MINIMAP_FLAG_MAPPED
        sta room_minimap_state, x
done_with_this_room:
        inx
        cpx #::FLOOR_SIZE
        bne loop

        lda #1
        sta HudMapDirty

        ; Play a SFX! Maybe a custom one later, but we'll use the same one for health
        ; containers just to have something
        queue_sfx_pulse1 sfx_heart_container

        lda #0 ; return success
        rts
.endproc

.proc heal_4_hp
        lda #4
        jmp _heal_player_common
.endproc

.proc heal_8_hp
        lda #8
        jmp _heal_player_common
.endproc

.proc heal_12_hp
        lda #12
        jmp _heal_player_common
.endproc

.proc heal_all_hp
        lda #128 ; all of it! (but not enough to overflow)
        jmp _heal_player_common
.endproc

; Healing amount in A
.proc _heal_player_common
HealingAmount := R0
        pha ; preserve the desired healing amount
        ; sanity check: does the player have any health to heal?
        far_call FAR_missing_health
        bne proceed_to_heal
        pla ; restore (and throw it away)
        ; this food item would do nothing! cancel the pickup/purchase
        lda #$FF ; return failure
        rts
proceed_to_heal:
        pla ; restore
        sta HealingAmount
        far_call FAR_receive_healing

        queue_sfx_triangle sfx_small_heart

        lda #0 ; return success
        rts
.endproc

.proc give_heart_container
NewHeartType := R0
HealingAmount := R0
        ; Can the player actually hold an additional heart?
        ldx #(MAX_REGULAR_HEARTS-1)
        lda heart_type, x
        cmp #HEART_TYPE_NONE      ; empty containers are fine
        beq okay_to_increase
        cmp #HEART_TYPE_TEMPORARY ; temporary containers are also fine
        beq okay_to_increase
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq okay_to_increase
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

okay_to_increase:
        ; Add one heart container to the player's maximum
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart

        ; Regular heart containers start empty (otherwise it looks weird)
        ; so heal the player 4 HP to award the health it contains
        lda #4
        sta HealingAmount
        far_call FAR_receive_healing
        ; TODO: these are kinda uncommon. Maybe they should award a full heal?

        ; And we're done!
        lda #0 ; return success
        rts
.endproc

.proc FAR_give_temporary_heart
NewHeartType := R0
        ; Can the player actually hold an additional temporary heart?
        ; For this routine we intentionally restrict the player to 1
        ; full temporary heart maximum. (The underlying HP system CAN
        ; handle more than one, so this is a balance choice that we 
        ; may later revisit.)

        ; Starting from the left, examime each heart we find
        ldx #0
find_heart_loop:
        lda heart_type, x
        ; If we encounter an empty heart slot, we can spawn
        ; a temporary heart here
        cmp #HEART_TYPE_NONE
        beq okay_to_add
        ; If we encounter a temporary heart slot, we may be able
        ; to refill its health
        cmp #HEART_TYPE_TEMPORARY
        beq okay_to_heal
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq okay_to_heal
        ; Otherwise keep checking
        inx
        cpx #TOTAL_HEART_SLOTS
        bne find_heart_loop

fail_to_collect:
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

okay_to_add:
        ; Add one heart container to the player's maximum
        lda #HEART_TYPE_TEMPORARY
        sta NewHeartType
        far_call FAR_add_heart
        ; And we're done!
        lda #0 ; return success
        rts

okay_to_heal:
        ; At this stage, X is pointing at the temporary heart
        ; If the temporary heart is full, we fail!
        lda heart_hp, x
        cmp #4
        beq fail_to_collect
        ; Otherwise, top it up.
        lda #4
        sta heart_hp, x
        ; Success!
        lda #0 ; return success
        rts
.endproc

.proc give_heart_armor
        ; Starting from the left, look for the first
        ; normal/temporary heart that is unarmored
        ldx #0
find_heart_loop:
        lda heart_type, x
        cmp #HEART_TYPE_REGULAR
        beq upgrade_to_armored
        cmp #HEART_TYPE_TEMPORARY
        beq upgrade_to_temporary_armored
        ; Otherwise keep checking
        inx
        cpx #TOTAL_HEART_SLOTS
        bne find_heart_loop
fail_to_collect:
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

upgrade_to_armored:
        lda #HEART_TYPE_REGULAR_ARMORED
        sta heart_type, x
        lda #0 ; return success
        rts

upgrade_to_temporary_armored:
        lda #HEART_TYPE_TEMPORARY_ARMORED
        sta heart_type, x
        lda #0 ; return success
        rts
.endproc

.proc give_100_gold
        add16w PlayerGold, #100
        clamp16 PlayerGold, #MAX_GOLD

        lda #0
        rts
.endproc

.proc FAR_init_item_bank_allocations
        lda #$FF
        .repeat 4, i
        sta item_bank_ids+i
        .endrepeat
        lda #0
        .repeat 4, i
        sta item_bank_refs+i
        .endrepeat
        rts
.endproc

item_bank_offset_lut:
        .byte SPRITE_OFFSET_ITEM_00
        .byte SPRITE_OFFSET_ITEM_01
        .byte SPRITE_OFFSET_ITEM_02
        .byte SPRITE_OFFSET_ITEM_03

.proc FAR_allocate_item_bank
ItemIndex := R1
ItemPtr := R2

BankId := R4     ; used during allocation checks
BankOffset := R4 ; returned to the caller

        ; We allocate by the bank ID, so we'll need that ready to go
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldy #ItemDef::WorldSpriteTile+1
        lda (ItemPtr), y
        sta BankId

        restore_previous_bank

        ldx #0
        ; First check for an existing allocation
        ; which matches this item
existing_loop:
        lda item_bank_ids, x
        cmp BankId
        beq increase_refs
        inx
        cpx #4
        bne existing_loop

        ; Failing that, try to allocate a new slot
        ldx #0
new_loop:
        lda item_bank_ids, x
        cmp #$FF
        beq allocate_new_slot
        inx
        cpx #4
        bne new_loop

        ; Failing THAT, the allocation as a whole fails,
        ; so set the resulting BankOffset to $FF to signify this
        lda #$FF
        sta BankOffset
        rts

allocate_new_slot:
        lda BankId
        sta item_bank_ids, x
        lda #1
        sta item_bank_refs, x
        jmp set_bank_offset

increase_refs:
        inc item_bank_refs, x
        jmp set_bank_offset

set_bank_offset:
        ; Actually apply the bank ID we read earlier
        lda BankId
        sta SPRITE_BANK_ITEM_00, x

        ; Now use the bank offset as the return value
        lda item_bank_offset_lut, x
        sta BankOffset
        rts
.endproc

.proc FAR_free_item_bank
ItemIndex := R1
ItemPtr := R1
BankId := R1
; TODO: check to see if R2 is used anywhere in call sites

        ; We allocate by the bank ID, so we'll need that ready to go
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldy #ItemDef::WorldSpriteTile+1
        lda (ItemPtr), y
        sta BankId

        restore_previous_bank

        ldx #0
loop:
        lda item_bank_ids, x
        cmp BankId
        bne done_with_this_offset
        lda item_bank_refs, x
        beq clear_item_slot ; shouldn't ever be taken !?
        dec item_bank_refs, x
        bne done_with_this_offset
clear_item_slot:
        lda #$FF
        sta item_bank_ids, x
done_with_this_offset:
        inx
        cpx #4
        bne loop
        rts
.endproc

.proc FAR_apply_item_world_metasprite
MetaSpriteIndex := R0
ItemIndex := R1
ItemPtr := R2
BankOffset := R4
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldx MetaSpriteIndex
        ldy #ItemDef::WorldSpriteTile
        lda (ItemPtr), y
        clc
        adc BankOffset
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldx MetaSpriteIndex
        ldy #ItemDef::WorldSpriteAttr
        lda (ItemPtr), y
        ora #SPRITE_ACTIVE
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        restore_previous_bank

        rts
.endproc

.proc FAR_apply_item_hud_metasprite
MetaSpriteIndex := R0
ItemIndex := R1
ItemPtr := R2
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldx MetaSpriteIndex
        ldy #ItemDef::HudSpriteTile
        lda (ItemPtr), y
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldx MetaSpriteIndex
        ldy #ItemDef::HudSpriteAttr
        lda (ItemPtr), y
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        restore_previous_bank

        rts
.endproc

.proc __item_logic_trampoline
        jmp (ItemFuncPtr)
.endproc


; TODO: maybe rework this to accept an item ID, to make it more generic?
.proc FAR_pickup_item
InputNewItem := R0
OutputOldItem := R0
ItemPtr := R16
NewItem := R18

player_equipment_by_index := current_save + SaveFile::PlayerEquipmentWeapon

        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        lda InputNewItem
        sta NewItem

        lda NewItem
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ; Play a joyous SFX
        ; TODO: should this be a different sound depending on the type of item? (yes, but how?)
        queue_sfx_pulse1 sfx_equip_ability_pulse1
        queue_sfx_pulse2 sfx_equip_ability_pulse2

        ldy #ItemDef::SlotId
        lda (ItemPtr), y
        cmp #SLOT_CONSUMABLE
        beq pickup_consumable_item
        ; TODO: bombs are a special case
        ; (spells are not really)
pickup_equipped_item:
        ; switcheroo!
        tay
        lda player_equipment_by_index, y
        tax
        lda NewItem
        sta player_equipment_by_index, y
        stx OutputOldItem
        restore_previous_bank
        perform_zpcm_inc
        rts

pickup_consumable_item:
        ldy #ItemDef::UseFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        perform_zpcm_inc
        jsr __item_logic_trampoline
        ; The return value in A indicates if the consumable item was consumed successfully
        beq successful_consumable_item
failed_consumable_item:
        perform_zpcm_inc
        ; Put the consumable item back in the square (the calling function can use this
        ; state as an error check)
        lda NewItem
        sta OutputOldItem
        restore_previous_bank
        perform_zpcm_inc
        rts
successful_consumable_item:
        perform_zpcm_inc
        ; Clear out the old item slot; we "consumed" the new item and left nothing behind
        lda #0
        sta OutputOldItem
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

; item index in A
.proc item_damage_common
DmgTotal := R0
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::DamageFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        clc
        adc DmgTotal
        sta DmgTotal
        rts
.endproc

; Returns weapon dmg amount in A, based on the currently loaded item
; Clobbers: TODO, probably at least X,Y
.proc FAR_weapon_dmg
DmgTotal := R0
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; Loop through all 5 equipment slots and keep a running sum of their damage
        ; contributions
        lda #0
        sta DmgTotal

        lda current_save + SaveFile::PlayerEquipmentWeapon
        jsr item_damage_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentTorch
        jsr item_damage_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentArmor
        jsr item_damage_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentBoots
        jsr item_damage_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentAccessory
        jsr item_damage_common
        perform_zpcm_inc

        restore_previous_bank
        lda DmgTotal
        rts
.endproc

; item index in A
.proc item_torchlight_common
TorchlightTotal := R0
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::TorchlightFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        clc
        adc TorchlightTotal
        sta TorchlightTotal
        rts
.endproc

; Returns weapon dmg amount in A, based on the currently loaded item
; Clobbers: TODO, probably at least X,Y
.proc FAR_equipment_torchlight
TorchlightTotal := R0
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; Loop through all 5 equipment slots and keep a running sum of their 
        ; torchlight contributions
        lda #0
        sta TorchlightTotal

        lda current_save + SaveFile::PlayerEquipmentWeapon
        jsr item_torchlight_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentTorch
        jsr item_torchlight_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentArmor
        jsr item_torchlight_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentBoots
        jsr item_torchlight_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentAccessory
        jsr item_torchlight_common
        perform_zpcm_inc

        ; safety: make sure the torchlight is at least the guaranteed minimum
        lda TorchlightTotal
        cmp #PLAYER_BASE_TORCHLIGHT
        bcs torchlight_mininum_satisfied
        lda #PLAYER_BASE_TORCHLIGHT
        sta TorchlightTotal
torchlight_mininum_satisfied:

        ; safety: make sure we aren't *above* the maximum torchlight we can render
        lda TorchlightTotal
        cmp #MAXIMUM_TORCHLIGHT_RADIUS
        bcc torchlight_maximum_satisfied
        lda #MAXIMUM_TORCHLIGHT_RADIUS
        sta TorchlightTotal
torchlight_maximum_satisfied:

        restore_previous_bank
        perform_zpcm_inc
        lda TorchlightTotal
        rts
.endproc

; item index in A
.proc item_damage_reduction_common
DmgReductionTotal := R0
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::DmgReductionFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        clc
        adc DmgReductionTotal
        sta DmgReductionTotal
        rts
.endproc

; Returns dmg reduction amount in A, based on the currently loaded item
; Clobbers: TODO, probably at least X,Y
.proc FAR_dmg_reduction
DmgReductionTotal := R0
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; Loop through all 5 equipment slots and keep a running sum of their damage
        ; contributions
        lda #0
        sta DmgReductionTotal

        lda current_save + SaveFile::PlayerEquipmentWeapon
        jsr item_damage_reduction_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentTorch
        jsr item_damage_reduction_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentArmor
        jsr item_damage_reduction_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentBoots
        jsr item_damage_reduction_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentAccessory
        jsr item_damage_reduction_common
        perform_zpcm_inc

        restore_previous_bank
        lda DmgReductionTotal
        rts
.endproc

; Item index in A
.proc FAR_display_item_description
        perform_zpcm_inc

        asl
        tay

        access_data_bank #<.bank(item_table)
        
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldy #ItemDef::SlotId
        lda (ItemPtr), y
        cmp #SLOT_CONSUMABLE
        beq done_with_display

        ldy #ItemDef::DescriptionStringPtr
        lda (ItemPtr), y
        sta DialogPassiveStringPtr+0
        iny
        lda (ItemPtr), y
        sta DialogPassiveStringPtr+1
        ldy #ItemDef::DescriptionStringBank
        lda (ItemPtr), y
        sta DialogPassiveStringBank
        lda #1
        sta DialogInitiatePassiveMode

done_with_display:
        restore_previous_bank
        rts
.endproc

.proc award_1_standard_bomb
        lda current_save + SaveFile::PlayerEquipmentBombs
        cmp #ITEM_BOMB_STANDARD
        beq not_newly_acquired

        lda #0
        sta current_save + SaveFile::PlayerBombCount
        lda #ITEM_BOMB_STANDARD
        sta current_save + SaveFile::PlayerEquipmentBombs
        near_call FAR_display_item_description

not_newly_acquired:
        lda current_save + SaveFile::PlayerBombCount
        clc
        adc #1 ; The only byte in this whole function that is different
        cmp #99
        bcc max_not_exceeded
max_exceeded:
        lda #99
max_not_exceeded:
        sta current_save + SaveFile::PlayerBombCount
        lda #0 ; return success
        rts
.endproc

.proc award_3_standard_bombs
        lda current_save + SaveFile::PlayerEquipmentBombs
        cmp #ITEM_BOMB_STANDARD
        beq not_newly_acquired

        lda #0
        sta current_save + SaveFile::PlayerBombCount
        lda #ITEM_BOMB_STANDARD
        sta current_save + SaveFile::PlayerEquipmentBombs
        near_call FAR_display_item_description

not_newly_acquired:
        lda current_save + SaveFile::PlayerBombCount
        clc
        adc #3 ; The only byte in this whole function that is different
        cmp #99
        bcc max_not_exceeded
max_exceeded:
        lda #99
max_not_exceeded:
        sta current_save + SaveFile::PlayerBombCount
        lda #0 ; return success
        rts
.endproc
