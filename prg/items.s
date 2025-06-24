        .macpack longbranch

        .include "items.inc"

        .include "../build/tile_defs.inc"
        
        .include "_globals.inc"

        .include "battlefield.inc"
        .include "dialog.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "localized_text.inc"
        .include "loot.inc"
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
ItemScratch0: .res 1
ItemScratch1: .res 1

        .segment "RAM"

item_bank_ids: .res 4
item_bank_refs: .res 4

        .segment "TEXT_STRINGS"

.macro localized_item_description name_str, description_str
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_PAL, HUD_PURPLE_PAL
        .byte D_LOCALIZE, <name_str, >name_str, <.bank(name_str), D_NEWLINE
        .byte D_PAL, HUD_TEXT_PAL
        .byte D_LOCALIZE, <description_str, >description_str, <.bank(description_str), D_WAIT, D_CLOSE
.endmacro

; TODO: not this. We want to remove the concept of L2/L3 weapons. But for now, we're translating
; all mechanics as they stand. (This particular setup is quite awkward; if we later decide to keep these,
; they should become separate items with bespoke translations. But the weapon upgrade system really ought
; to replace this entirely.)
.macro localized_l2_weapon_description name_str, description_str
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_PAL, HUD_PURPLE_PAL
        .byte D_LOCALIZE, <name_str, >name_str, <.bank(name_str), D_FONT, FONT_ASCII, "- L2", D_NEWLINE
        .byte D_PAL, HUD_TEXT_PAL
        .byte D_LOCALIZE, <description_str, >description_str, <.bank(description_str), D_WAIT, D_CLOSE
.endmacro

.macro localized_l3_weapon_description name_str, description_str
        ;     0123456789012345678901234567 ; 28-char width
        .byte D_PAL, HUD_PURPLE_PAL
        .byte D_LOCALIZE, <name_str, >name_str, <.bank(name_str), D_FONT, FONT_ASCII, "- L3", D_NEWLINE
        .byte D_PAL, HUD_TEXT_PAL
        .byte D_LOCALIZE, <description_str, >description_str, <.bank(description_str), D_WAIT, D_CLOSE
.endmacro

; Dummy / Debug Entries
no_item_description:        localized_item_description no_item_name_localized, no_item_description_localized

; Weapons
dagger_description:        localized_item_description      dagger_name_localized,        dagger_description_localized
broadsword_description:    localized_item_description      broadsword_name_localized,    broadsword_description_localized
longsword_description:     localized_item_description      longsword_name_localized,     longsword_description_localized
spear_description:         localized_item_description      spear_name_localized,         spear_description_localized
flail_description:         localized_item_description      flail_name_localized,         flail_description_localized
combat_anchor_description: localized_item_description      combat_anchor_name_localized, combat_anchor_description_localized

; Light Sources
basic_torch_description:       localized_item_description basic_torch_name_localized,      basic_torch_description_localized
large_torch_description:       localized_item_description large_torch_name_localized,      large_torch_description_localized
infernal_lantern_description:  localized_item_description infernal_lantern_name_localized, infernal_lantern_description_localized
charge_a_bulb_description:     localized_item_description charge_a_bulb_name_localized,    charge_a_bulb_description_localized

; Consumables
compass_description:           localized_item_description compass_name_localized,           compass_description_localized
map_description:               localized_item_description map_name_localized,               map_description_localized
small_fries_description:       localized_item_description small_fries_name_localized,       small_fries_description_localized
medium_fries_description:      localized_item_description medium_fries_name_localized,      medium_fries_description_localized
large_fries_description:       localized_item_description large_fries_name_localized,       large_fries_description_localized
gold_sack_description:         localized_item_description gold_sack_name_localized,         gold_sack_description_localized
heart_container_description:   localized_item_description heart_container_name_localized,   heart_container_description_localized
temporary_heart_description:   localized_item_description temporary_heart_name_localized,   temporary_heart_description_localized
heart_armor_description:       localized_item_description heart_armor_name_localized,       heart_armor_description_localized

; Footwear
go_go_boots_description:       localized_item_description go_go_boots_name_localized,       go_go_boots_description_localized
ninja_footwraps_description:   localized_item_description ninja_footwraps_name_localized,   ninja_footwraps_description_localized

; Armor
defensive_shield_description:  localized_item_description defensive_shield_name_localized,  defensive_shield_description_localized
aloha_tshirt_description:      localized_item_description aloha_tshirt_name_localized,      aloha_tshirt_description_localized

; Accessories
chain_link_description:               localized_item_description chain_link_name_localized,        chain_link_description_localized
obsidian_ring_description:            localized_item_description obsidian_ring_name_localized,     obsidian_ring_description_localized
ruby_necklace_description:            localized_item_description ruby_necklace_name_localized,     ruby_necklace_description_localized
topaz_earrings_description:           localized_item_description topaz_earrings_name_localized,    topaz_earrings_description_localized
sapphire_bracelet_description:        localized_item_description sapphire_bracelet_name_localized, sapphire_bracelet_description_localized
amulet_of_yendor_description:         localized_item_description amulet_of_yendor_name_localized,  amulet_of_yendor_description_localized
lucky_penny_description:              localized_item_description lucky_penny_name_localized,       lucky_penny_description_localized
cheap_plastic_imitation_of_the_amulet_of_yendor_description:  localized_item_description cheap_plastic_imitation_of_the_amulet_of_yendor_name_localized,  cheap_plastic_imitation_of_the_amulet_of_yendor_description_localized

; Bombs
bombs_description:             localized_item_description bombs_name_localized,             bombs_description_localized

; Spells
spell_fire_description:        localized_item_description spell_fire_name_localized,        spell_fire_description_localized
spell_air_description:         localized_item_description spell_air_name_localized,         spell_air_description_localized
spell_ice_description:         localized_item_description spell_ice_name_localized,         spell_ice_description_localized
spell_earth_description:       localized_item_description spell_earth_name_localized,       spell_earth_description_localized
spell_bomb_fiesta_description: localized_item_description spell_bomb_fiesta_name_localized, spell_bomb_fiesta_description_localized
spell_life_description:        localized_item_description spell_life_name_localized,        spell_life_description_localized

        .segment "DATA_0"

item_table:
        .word no_item
        .word dagger
        .word broadsword
        .word combat_anchor
        .word no_item
        .word longsword
        .word no_item
        .word no_item
        .word spear
        .word no_item
        .word no_item
        .word flail
        .word no_item
        .word no_item
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
        .word upgrade_crystal_earth
        .word upgrade_crystal_ice
        .word upgrade_crystal_air
        .word upgrade_crystal_fire
        .word obsidian_ring
        .word ruby_necklace
        .word topaz_earrings
        .word sapphire_bracelet
        .word ninja_footwraps
        .word amulet_of_yendor
        .word lucky_penny
        .word cheap_plastic_imitation_of_the_amulet_of_yendor
        .word infernal_lantern
        .word charge_a_bulb

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr never_valid                     ; IsValidLootFunc
        .addr never_helpful                   ; IsConsideredHelpfulFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)     ; DescriptionStringBank

dagger:
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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr dagger_description              ; DescriptionStringPtr
        .byte <.bank(dagger_description)      ; DescriptionStringBank

broadsword:
        .byte SLOT_WEAPON                        ; SlotId
        .word SPRITE_ITEMS_01_BROADSWORD         ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD        ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                                  ; HudSpriteTile
        .byte 0                                  ; HudSpriteAttr
        .word 75                                 ; ShopCost
        .byte WEAPON_BROADSWORD                  ; WeaponShape
        .addr flat_1                             ; DamageFunc
        .addr no_effect                          ; TorchlightFunc
        .addr do_nothing                         ; UseFunc
        .addr no_effect                          ; DmgReductionFunc
        .addr do_nothing                         ; ApplyPassivesFunc
        .addr always_valid                       ; IsValidLootFunc
        .addr always_helpful                     ; IsConsideredHelpfulFunc
        .addr broadsword_description             ; DescriptionStringPtr
        .byte <.bank(broadsword_description)     ; DescriptionStringBank

combat_anchor:
        .byte SLOT_WEAPON                        ; SlotId
        .word SPRITE_ITEMS_06_COMBAT_ANCHOR      ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                  ; WorldSpriteAttr
        .byte EQUIPMENT_COMBAT_ANCHOR            ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                                  ; HudSpriteTile
        .byte 0                                  ; HudSpriteAttr
        .word 75                                 ; ShopCost
        .byte WEAPON_ANCHOR                      ; WeaponShape
        .addr flat_1                             ; DamageFunc
        .addr no_effect                          ; TorchlightFunc
        .addr do_nothing                         ; UseFunc
        .addr no_effect                          ; DmgReductionFunc
        .addr do_nothing                         ; ApplyPassivesFunc
        .addr always_valid                       ; IsValidLootFunc
        .addr always_helpful                     ; IsConsideredHelpfulFunc
        .addr combat_anchor_description          ; DescriptionStringPtr
        .byte <.bank(combat_anchor_description)  ; DescriptionStringBank

longsword:
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
        .addr longsword_description             ; DescriptionStringPtr
        .byte <.bank(longsword_description)     ; DescriptionStringBank

spear:
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
        .addr spear_description                 ; DescriptionStringPtr
        .byte <.bank(spear_description)         ; DescriptionStringBank

flail:
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
        .addr flail_description                 ; DescriptionStringPtr
        .byte <.bank(flail_description)         ; DescriptionStringBank

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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr valid_if_torchless                ; IsValidLootFunc
        .addr helpful_if_torchless_in_the_dark  ; IsConsideredHelpfulFunc
        .addr basic_torch_description           ; DescriptionStringPtr
        .byte <.bank(basic_torch_description)   ; DescriptionStringBank

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
        .addr dmg_plus_1_to_ice                 ; DamageFunc
        .addr flat_15                           ; TorchlightFunc
        .addr do_nothing                        ; UseFunc
        .addr no_effect                         ; DmgReductionFunc
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr helpful_if_torchless_in_the_dark  ; IsConsideredHelpfulFunc
        .addr large_torch_description           ; DescriptionStringPtr
        .byte <.bank(large_torch_description)   ; DescriptionStringBank

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr compass_description             ; DescriptionStringPtr
        .byte <.bank(compass_description)     ; DescriptionStringBank

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr map_description                 ; DescriptionStringPtr
        .byte <.bank(map_description)         ; DescriptionStringBank

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr helpful_if_health_is_not_full   ; IsConsideredHelpfulFunc
        .addr small_fries_description         ; DescriptionStringPtr
        .byte <.bank(small_fries_description) ; DescriptionStringBank

medium_fries:
        .byte SLOT_CONSUMABLE                  ; SlotId
        .word SPRITE_ITEMS_03_MEDIUM_FRIES     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                   ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS)  ; HudBgAttr (unused)
        .byte 0                                ; HudSpriteTile (unused)
        .byte 0                                ; HudSpriteAttr (unused)
        .word 75                               ; ShopCost
        .byte WEAPON_DAGGER                    ; WeaponShape    (unused)
        .addr no_effect                        ; DamageFunc     (unused)
        .addr no_effect                        ; TorchlightFunc (unused)
        .addr heal_8_hp                        ; UseFunc
        .addr no_effect                        ; DmgReductionFunc
        .addr do_nothing                       ; ApplyPassivesFunc
        .addr always_valid                     ; IsValidLootFunc
        .addr helpful_if_health_is_not_full    ; IsConsideredHelpfulFunc
        .addr medium_fries_description         ; DescriptionStringPtr
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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr helpful_if_health_is_not_full   ; IsConsideredHelpfulFunc
        .addr large_fries_description         ; DescriptionStringPtr
        .byte <.bank(large_fries_description) ; DescriptionStringBank

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr go_go_boots_description         ; DescriptionStringPtr
        .byte <.bank(go_go_boots_description) ; DescriptionStringBank

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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr gold_sack_description           ; DescriptionStringPtr
        .byte <.bank(gold_sack_description)   ; DescriptionStringBank

heart_container:
        .byte SLOT_CONSUMABLE                     ; SlotId
        .word SPRITE_ITEMS_02_HEART_CONTAINER     ; WorldSpriteTile
        .byte SPRITE_PAL_RED                      ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                      ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS)     ; HudBgAttr (unused)
        .byte 0                                   ; HudSpriteTile (unused)
        .byte 0                                   ; HudSpriteAttr (unused)
        .word 250                                 ; ShopCost
        .byte WEAPON_DAGGER                       ; WeaponShape (unused)
        .addr no_effect                           ; DamageFunc
        .addr no_effect                           ; TorchlightFunc
        .addr give_heart_container                ; UseFunc
        .addr no_effect                           ; DmgReductionFunc
        .addr do_nothing                          ; ApplyPassivesFunc
        .addr always_valid                        ; IsValidLootFunc
        .addr always_helpful                      ; IsConsideredHelpfulFunc
        .addr heart_container_description         ; DescriptionStringPtr
        .byte <.bank(heart_container_description) ; DescriptionStringBank

temporary_heart:
        .byte SLOT_CONSUMABLE                     ; SlotId
        .word SPRITE_ITEMS_02_HEART_CONTAINER     ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                   ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                      ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS)     ; HudBgAttr (unused)
        .byte 0                                   ; HudSpriteTile (unused)
        .byte 0                                   ; HudSpriteAttr (unused)
        .word 50                                  ; ShopCost
        .byte WEAPON_DAGGER                       ; WeaponShape (unused)
        .addr no_effect                           ; DamageFunc
        .addr no_effect                           ; TorchlightFunc
        .addr FAR_give_temporary_heart            ; UseFunc
        .addr no_effect                           ; DmgReductionFunc
        .addr do_nothing                          ; ApplyPassivesFunc
        .addr always_valid                        ; IsValidLootFunc
        .addr always_helpful                      ; IsConsideredHelpfulFunc
        .addr temporary_heart_description         ; DescriptionStringPtr
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
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr always_valid                    ; IsValidLootFunc
        .addr helpful_if_unarmored_heart      ; IsConsideredHelpfulFunc
        .addr heart_armor_description         ; DescriptionStringPtr
        .byte <.bank(heart_armor_description) ; DescriptionStringBank

; TODO: this really needs to be directional, and much stronger
; For now, it matches the t-shirt, which is fine-ish as it is overpowered
; otherwise. The high cost is offset by NOT having the t-shirt's detrimental
; side effect, making it firmly a mid to late game purchase (and ideally a
; weak / boring one at that)
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
        .addr flat_1                               ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr always_valid                         ; IsValidLootFunc
        .addr always_helpful                       ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr award_air_resistance              ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr award_fire_resistance               ; ApplyPassivesFunc
        .addr always_valid                        ; IsValidLootFunc
        .addr always_helpful                      ; IsConsideredHelpfulFunc
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
        .addr award_earth_resistance             ; ApplyPassivesFunc
        .addr always_valid                       ; IsValidLootFunc
        .addr always_helpful                     ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr helpful_if_low_on_bombs           ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr helpful_if_low_on_bombs           ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr helpful_if_low_on_bombs           ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
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
        .addr do_nothing                            ; ApplyPassivesFunc
        .addr always_valid                          ; IsValidLootFunc
        .addr always_helpful                        ; IsConsideredHelpfulFunc
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
        .addr do_nothing                        ; ApplyPassivesFunc
        .addr always_valid                      ; IsValidLootFunc
        .addr always_helpful                    ; IsConsideredHelpfulFunc
        .addr spell_life_description            ; DescriptionStringPtr
        .byte <.bank(spell_life_description)    ; DescriptionStringBank

upgrade_crystal_earth:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_05_UPGRADE_EARTH   ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost (base)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_upgrade_earth              ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr weapon_upgrade_considered_valid ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)     ; DescriptionStringBank

upgrade_crystal_ice:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_05_UPGRADE_ICE     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost (base)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_upgrade_ice                ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr weapon_upgrade_considered_valid ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)     ; DescriptionStringBank

upgrade_crystal_air:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_05_UPGRADE_AIR     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost (base)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_upgrade_air                ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr weapon_upgrade_considered_valid ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)     ; DescriptionStringBank

upgrade_crystal_fire:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .word SPRITE_ITEMS_05_UPGRADE_FIRE    ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost (base)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_upgrade_fire               ; UseFunc
        .addr no_effect                       ; DmgReductionFunc
        .addr do_nothing                      ; ApplyPassivesFunc
        .addr weapon_upgrade_considered_valid ; IsValidLootFunc
        .addr always_helpful                  ; IsConsideredHelpfulFunc
        .addr no_item_description             ; DescriptionStringPtr
        .byte <.bank(no_item_description)     ; DescriptionStringBank

obsidian_ring:
        .byte SLOT_ACCESSORY                             ; SlotId
        .word SPRITE_ITEMS_05_OBSIDIAN_RING              ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                          ; WorldSpriteAttr
        .byte EQUIPMENT_OBSIDIAN_RING                    ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS)          ; HudBgAttr
        .byte 0                                          ; HudSpriteTile (unused)
        .byte 0                                          ; HudSpriteAttr (unused)
        .word 150                                        ; ShopCost (base)
        .byte WEAPON_DAGGER                              ; WeaponShape (unused)
        .addr no_effect                                  ; DamageFunc
        .addr no_effect                                  ; TorchlightFunc
        .addr no_effect                                  ; UseFunc
        .addr no_effect                                  ; DmgReductionFunc
        .addr award_earth_resistance_and_protection      ; ApplyPassivesFunc
        .addr always_valid                               ; IsValidLootFunc
        .addr always_helpful                             ; IsConsideredHelpfulFunc
        .addr obsidian_ring_description                  ; DescriptionStringPtr
        .byte <.bank(obsidian_ring_description)          ; DescriptionStringBank

ruby_necklace:
        .byte SLOT_ACCESSORY                             ; SlotId
        .word SPRITE_ITEMS_05_RUBY_NECKLACE              ; WorldSpriteTile
        .byte SPRITE_PAL_RED                             ; WorldSpriteAttr
        .byte EQUIPMENT_RUBY_NECKLACE                    ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)             ; HudBgAttr
        .byte 0                                          ; HudSpriteTile (unused)
        .byte 0                                          ; HudSpriteAttr (unused)
        .word 150                                        ; ShopCost (base)
        .byte WEAPON_DAGGER                              ; WeaponShape (unused)
        .addr no_effect                                  ; DamageFunc
        .addr no_effect                                  ; TorchlightFunc
        .addr no_effect                                  ; UseFunc
        .addr no_effect                                  ; DmgReductionFunc
        .addr award_fire_resistance_and_protection       ; ApplyPassivesFunc
        .addr always_valid                               ; IsValidLootFunc
        .addr always_helpful                             ; IsConsideredHelpfulFunc
        .addr ruby_necklace_description                  ; DescriptionStringPtr
        .byte <.bank(ruby_necklace_description)          ; DescriptionStringBank

topaz_earrings:
        .byte SLOT_ACCESSORY                             ; SlotId
        .word SPRITE_ITEMS_05_TOPAZ_EARRINGS             ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                          ; WorldSpriteAttr
        .byte EQUIPMENT_TOPAZ_EARRINGS                   ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)          ; HudBgAttr
        .byte 0                                          ; HudSpriteTile (unused)
        .byte 0                                          ; HudSpriteAttr (unused)
        .word 150                                        ; ShopCost (base)
        .byte WEAPON_DAGGER                              ; WeaponShape (unused)
        .addr no_effect                                  ; DamageFunc
        .addr no_effect                                  ; TorchlightFunc
        .addr no_effect                                  ; UseFunc
        .addr no_effect                                  ; DmgReductionFunc
        .addr award_air_resistance_and_protection        ; ApplyPassivesFunc
        .addr always_valid                               ; IsValidLootFunc
        .addr always_helpful                             ; IsConsideredHelpfulFunc
        .addr topaz_earrings_description                 ; DescriptionStringPtr
        .byte <.bank(topaz_earrings_description)         ; DescriptionStringBank

sapphire_bracelet:
        .byte SLOT_ACCESSORY                             ; SlotId
        .word SPRITE_ITEMS_05_SAPPHIRE_BRACELET          ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                          ; WorldSpriteAttr
        .byte EQUIPMENT_SAPPHIRE_BRACELET                ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS)          ; HudBgAttr
        .byte 0                                          ; HudSpriteTile (unused)
        .byte 0                                          ; HudSpriteAttr (unused)
        .word 150                                        ; ShopCost (base)
        .byte WEAPON_DAGGER                              ; WeaponShape (unused)
        .addr no_effect                                  ; DamageFunc
        .addr no_effect                                  ; TorchlightFunc
        .addr no_effect                                  ; UseFunc
        .addr no_effect                                  ; DmgReductionFunc
        .addr award_ice_resistance_and_protection        ; ApplyPassivesFunc
        .addr always_valid                               ; IsValidLootFunc
        .addr always_helpful                             ; IsConsideredHelpfulFunc
        .addr sapphire_bracelet_description              ; DescriptionStringPtr
        .byte <.bank(sapphire_bracelet_description)      ; DescriptionStringBank

; Note: as an item with a custom effect, these are just special-case checked
; in the player damage code. The HUD icon also has bonus logic that is not represented here.
ninja_footwraps:
        .byte SLOT_BOOTS                          ; SlotId
        .word SPRITE_ITEMS_06_NINJA_FOOTWRAPS     ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                   ; WorldSpriteAttr
        .byte EQUIPMENT_NINJA_FOOTWRAPS           ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS)   ; HudBgAttr
        .byte 0                                   ; HudSpriteTile
        .byte 0                                   ; HudSpriteAttr
        .word 200                                 ; ShopCost
        .byte WEAPON_DAGGER                       ; WeaponShape (unused)
        .addr no_effect                           ; DamageFunc
        .addr no_effect                           ; TorchlightFunc
        .addr do_nothing                          ; UseFunc
        .addr no_effect                           ; DmgReductionFunc
        .addr do_nothing                          ; ApplyPassivesFunc
        .addr always_valid                        ; IsValidLootFunc
        .addr always_helpful                      ; IsConsideredHelpfulFunc
        .addr ninja_footwraps_description         ; DescriptionStringPtr
        .byte <.bank(ninja_footwraps_description) ; DescriptionStringBank

; Ditto for both of these, which are checked for in the "player death" routine.
amulet_of_yendor:
        .byte SLOT_ACCESSORY                       ; SlotId
        .word SPRITE_ITEMS_06_AMULET_OF_YENDOR     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                    ; WorldSpriteAttr
        .byte EQUIPMENT_AMULET_OF_YENDOR           ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                    ; HudSpriteTile
        .byte 0                                    ; HudSpriteAttr
        .word 500                                  ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr no_effect                            ; DamageFunc
        .addr no_effect                            ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr no_effect                            ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr always_valid                         ; IsValidLootFunc
        .addr always_helpful                       ; IsConsideredHelpfulFunc
        .addr amulet_of_yendor_description         ; DescriptionStringPtr
        .byte <.bank(amulet_of_yendor_description) ; DescriptionStringBank

; Ditto for both of these, which are checked for in the "player death" routine.
lucky_penny:
        .byte SLOT_ACCESSORY                       ; SlotId
        .word SPRITE_ITEMS_06_LUCKY_PENNY          ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                    ; WorldSpriteAttr
        .byte EQUIPMENT_LUCKY_PENNY                ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                    ; HudSpriteTile
        .byte 0                                    ; HudSpriteAttr
        .word 2000                                 ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr no_effect                            ; DamageFunc
        .addr no_effect                            ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr no_effect                            ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr always_valid                         ; IsValidLootFunc
        .addr always_helpful                       ; IsConsideredHelpfulFunc
        .addr lucky_penny_description              ; DescriptionStringPtr
        .byte <.bank(lucky_penny_description)      ; DescriptionStringBank

; This item only exists for tombstone purposes, so that we can "identify" the amulet upon
; a failed activation. It never appears in game and has no effect. The player can only have
; this in their inventory upon DEFEAT.
cheap_plastic_imitation_of_the_amulet_of_yendor:
        .byte SLOT_ACCESSORY                       ; SlotId
        .word SPRITE_ITEMS_06_AMULET_OF_YENDOR     ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                    ; WorldSpriteAttr
        .byte EQUIPMENT_AMULET_OF_YENDOR           ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                    ; HudSpriteTile
        .byte 0                                    ; HudSpriteAttr
        .word 0                                    ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr no_effect                            ; DamageFunc
        .addr no_effect                            ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr no_effect                            ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr never_valid                          ; IsValidLootFunc
        .addr never_helpful                        ; IsConsideredHelpfulFunc
        .addr cheap_plastic_imitation_of_the_amulet_of_yendor_description              ; DescriptionStringPtr
        .byte <.bank(cheap_plastic_imitation_of_the_amulet_of_yendor_description)      ; DescriptionStringBank

infernal_lantern:
        .byte SLOT_TORCH                           ; SlotId
        .word SPRITE_ITEMS_06_INFERNAL_LANTERN     ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                    ; WorldSpriteAttr
        .byte EQUIPMENT_INFERNAL_LANTERN           ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)       ; HudBgAttr
        .byte 0                                    ; HudSpriteTile
        .byte 0                                    ; HudSpriteAttr
        .word 250                                  ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr dmg_plus_1_to_ice                    ; DamageFunc
        .addr bonus_torchlight_from_charge         ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr no_effect                            ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr always_valid                         ; IsValidLootFunc
        .addr helpful_if_torchless_in_the_dark     ; IsConsideredHelpfulFunc
        .addr infernal_lantern_description         ; DescriptionStringPtr
        .byte <.bank(infernal_lantern_description) ; DescriptionStringBank

charge_a_bulb:
        .byte SLOT_TORCH                           ; SlotId
        .word SPRITE_ITEMS_06_CHARGE_A_BULB        ; WorldSpriteTile
        .byte SPRITE_PAL_YELLOW                    ; WorldSpriteAttr
        .byte EQUIPMENT_CHARGE_A_BULB              ; HudBgTile
        .byte (HUD_YELLOW_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                    ; HudSpriteTile
        .byte 0                                    ; HudSpriteAttr
        .word 250                                  ; ShopCost
        .byte WEAPON_DAGGER                        ; WeaponShape (unused)
        .addr dmg_plus_1_to_earth                  ; DamageFunc
        .addr bonus_torchlight_from_charge         ; TorchlightFunc
        .addr do_nothing                           ; UseFunc
        .addr no_effect                            ; DmgReductionFunc
        .addr do_nothing                           ; ApplyPassivesFunc
        .addr always_valid                         ; IsValidLootFunc
        .addr helpful_if_torchless_in_the_dark     ; IsConsideredHelpfulFunc
        .addr charge_a_bulb_description            ; DescriptionStringPtr
        .byte <.bank(charge_a_bulb_description)    ; DescriptionStringBank

        .segment "CODE_ITEMS"

; Functions to teach the shop/loot rolling systems special properties of certain items.
; First off, valid/invalid, for whether an item may spawn at all. Note that we always
; refuse to spawn: duplicates AND items the player has equipped into an inventory slot,
; so we don't need to redundantly check for those here. #0 indicates success, anything else
; indicates failure.

.proc always_valid
        lda #0
        rts
.endproc

.proc never_valid
        lda #$FF
        rts
.endproc

; Weapon upgrades start to become available after the player is holding anything other
; than the starting dagger, as they are otherwise unable to slot in. If the player doesn't
; have any upgrades yet, then we further restrict the total loot quantity (of any upgrades)
; to just one, so they can't double-dip and spike in power. The second upgrade becomes
; available starting in Zone 1-4 for now, and we'll bump this to much later in the retail
; build for game balance reasons.
.proc weapon_upgrade_considered_valid
        ; Easy check: if the player is currently holding the starting dagger, then no
        ; upgrades for you. :P
        lda current_save + SaveFile::PlayerEquipmentWeapon
        cmp #ITEM_DAGGER
        beq spawn_is_invalid

        ; TODO: all those other checks. In particular, I haven't decided how the
        ; "current zone" check is going to work.
        lda #0
        rts

spawn_is_invalid:
        lda #$FF
        rts
.endproc

; Similarly, use these functions for the "helpful items" subsystem. Standard chests use
; these primarily. These should inspect game state and make a balance-related decision as
; to whether the player "needs" this particular item at the moment. Helpful chests will
; reroll several times trying to generate some item that passes these checks.

.proc always_helpful
        lda #0
        rts
.endproc

.proc never_helpful
        lda #$FF
        rts
.endproc

.proc helpful_if_health_is_not_full
        far_call FAR_missing_health
        beq not_helpful
helpful:
        lda #0
        rts
not_helpful:
        lda #$FF
        rts
.endproc

.proc valid_if_torchless
        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_NONE
        bne not_valid
valid:
        lda #0
        rts
not_valid:
        lda #$FF
        rts
.endproc

.proc helpful_if_torchless_in_the_dark
        ldx PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_DARK
        beq not_helpful
        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_NONE
        bne not_helpful
helpful:
        lda #0
        rts
not_helpful:
        lda #$FF
        rts
.endproc

.proc helpful_if_low_on_bombs
        lda current_save + SaveFile::PlayerEquipmentBombs
        cmp #ITEM_NONE
        beq bomb_base_item_valid
        cmp #ITEM_BOMB_STANDARD
        beq bomb_base_item_valid
        jmp not_helpful
bomb_base_item_valid:
        lda current_save + SaveFile::PlayerBombCount
        cmp #10
        bcs not_helpful
helpful:
        lda #0
        rts
not_helpful:
        lda #$FF
        rts
.endproc

; For heart armor only, pretty much. Stop spawning heart armor from regular
; chests if the player can't actually put it on in their current state.
.proc helpful_if_unarmored_heart
        ; Starting from the left, look for the first
        ; normal/temporary heart that is unarmored AND
        ; which has more than 0 HP
        ldx #0
find_heart_loop:
        lda current_save + SaveFile::HeartSlotHp, x
        beq is_empty
        lda current_save + SaveFile::HeartSlotType, x
        cmp #HEART_TYPE_REGULAR
        beq is_helpful
        cmp #HEART_TYPE_TEMPORARY
        beq is_helpful
is_empty:
        ; Otherwise keep checking
        inx
        cpx #TOTAL_HEART_SLOTS
        bne find_heart_loop
not_helpful:
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts
is_helpful:
        lda #0
        rts
.endproc

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

.proc dmg_plus_1_to_ice
; don't clobber
;DmgTotal := R0

; available because we are in the middle of a weapon strike when this
; routine is called
EffectiveAttackSquare := R10

        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_ICE
        bne no_bonus
yes_bonus:
        lda #1
        rts
no_bonus:
        lda #0
        rts
.endproc

.proc dmg_plus_1_to_earth
; don't clobber
;DmgTotal := R0

; available because we are in the middle of a weapon strike when this
; routine is called
EffectiveAttackSquare := R10

        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        bne no_bonus
yes_bonus:
        lda #1
        rts
no_bonus:
        lda #0
        rts
.endproc

.proc bonus_torchlight_from_charge
        lda #8 ; minimum is always a "basic torch"
        clc
        adc PlayerTorchlightBonus
        cmp #TORCHLIGHT_MAX_CHARGE_BRIGHTNESS
        bcc not_too_bright
        lda #TORCHLIGHT_MAX_CHARGE_BRIGHTNESS
not_too_bright:
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
        ; Note: sanity check removed, healing is always allowed.
        ; Buyer beware in shops, etc.
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
        lda current_save + SaveFile::HeartSlotType, x
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
        lda current_save + SaveFile::HeartSlotType, x
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
        lda current_save + SaveFile::HeartSlotHp, x
        cmp #4
        beq fail_to_collect
        ; Otherwise, top it up.
        lda #4
        sta current_save + SaveFile::HeartSlotHp, x
        ; Success!
        lda #0 ; return success
        rts
.endproc

.proc give_heart_armor
        ; Starting from the left, look for the first
        ; normal/temporary heart that is unarmored AND
        ; which has more than 0 HP
        ldx #0
find_heart_loop:
        lda current_save + SaveFile::HeartSlotHp, x
        beq is_empty
        lda current_save + SaveFile::HeartSlotType, x
        cmp #HEART_TYPE_REGULAR
        beq upgrade_to_armored
        cmp #HEART_TYPE_TEMPORARY
        beq upgrade_to_temporary_armored
is_empty:
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
        sta current_save + SaveFile::HeartSlotType, x
        lda #0 ; return success
        rts

upgrade_to_temporary_armored:
        lda #HEART_TYPE_TEMPORARY_ARMORED
        sta current_save + SaveFile::HeartSlotType, x
        lda #0 ; return success
        rts
.endproc

.proc give_100_gold
        add16w current_save + SaveFile::PlayerGold, #100
        clamp16 current_save + SaveFile::PlayerGold, #MAX_GOLD

        lda #0
        rts
.endproc

.proc give_upgrade_earth
        ldx #ITEM_UPGRADE_EARTH
        jmp _give_upgrade_common
.endproc

.proc give_upgrade_ice
        ldx #ITEM_UPGRADE_ICE
        jmp _give_upgrade_common
.endproc

.proc give_upgrade_air
        ldx #ITEM_UPGRADE_AIR
        jmp _give_upgrade_common
.endproc

.proc give_upgrade_fire
        ldx #ITEM_UPGRADE_FIRE
        jmp _give_upgrade_common
.endproc

; Call with X set to the upgrade item
.proc _give_upgrade_common
        ; The starting dagger does not support upgrades!
        lda current_save + SaveFile::PlayerEquipmentWeapon
        cmp #ITEM_DAGGER
        beq failure
        ; Otherwise, whichever slot is free, put it there
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot1
        cmp #ITEM_NONE
        beq use_slot_1
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot2
        cmp #ITEM_NONE
        beq use_slot_2
failure:
        ; failure: this weapon is fully upgraded
        lda #$FF
        rts
use_slot_1:
        stx current_save + SaveFile::PlayerWeaponUpgradeSlot1
        jmp converge
use_slot_2:
        stx current_save + SaveFile::PlayerWeaponUpgradeSlot2
converge:
        ; play a fancy equip sfx
        ; TODO: make this even fancier?
        queue_sfx_pulse1 sfx_equip_ability_pulse1
        queue_sfx_pulse2 sfx_equip_ability_pulse2

        ; Our crystal arrangement has changed, so recalc damage (yay!)
        far_call FAR_calculate_weapon_damage

        ; "Dirty" the weapon in the hud, forcing a redraw of the equip slots
        lda #$FF
        sta WeaponDisplayCurrent

        lda #0 ; return success
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
        jeq pickup_consumable_item
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

        ; special case: if this was a weapon, then we need to also deal with upgrades
        cpy #SLOT_WEAPON
        bne not_a_weapon
        ; ... (sigh) and because external logic will "reject" the pickup if the item doesn't
        ; actually change, and we don't guard against this spawn condition... check for THAT
        ; as well
        lda NewItem
        cmp OutputOldItem
        beq not_a_weapon
        ; we're gonna change the upgrade slots, so force the HUD to redraw when it has a chance
        lda #ITEM_NONE
        sta WeaponDisplayCurrent
        ; are we standing on the backup spot? if so, switcheroo!
        lda BackupWeaponUpgradeRoomIndex
        cmp PlayerRoomIndex
        bne no_valid_backup
        lda BackupWeaponUpgradeRow
        cmp PlayerRow
        bne no_valid_backup
        lda BackupWeaponUpgradeCol
        cmp PlayerCol
        bne no_valid_backup
standing_on_a_valid_backup:
        ; switcheroo!
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot1
        ldx BackupWeaponUpgradeSlot1
        stx current_save + SaveFile::PlayerWeaponUpgradeSlot1
        sta BackupWeaponUpgradeSlot1
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot2
        ldx BackupWeaponUpgradeSlot2
        stx current_save + SaveFile::PlayerWeaponUpgradeSlot2
        sta BackupWeaponUpgradeSlot2
        jmp done_with_crystal_management
no_valid_backup:
        ; backup current, initialize new
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot1
        sta BackupWeaponUpgradeSlot1
        lda current_save + SaveFile::PlayerWeaponUpgradeSlot2
        sta BackupWeaponUpgradeSlot2
        lda PlayerRoomIndex
        sta BackupWeaponUpgradeRoomIndex
        lda PlayerRow
        sta BackupWeaponUpgradeRow
        lda PlayerCol
        sta BackupWeaponUpgradeCol
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot1
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot2
done_with_crystal_management:
        far_call FAR_calculate_weapon_damage
not_a_weapon:
        near_call FAR_compute_player_passives
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

; Returns weapon dmg amount in A, based on the currently loaded item.
; This is called by enemy attack processing code, and expects:
; - EffectiveAttackSquare in R10
; Clobbers: TODO, probably at least X,Y
.proc FAR_weapon_dmg
TempIndex := R0
DmgTotal := R0
EffectiveAttackSquare := R10
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        
        lda #0
        sta DmgTotal

        ; First, process the base weapon. This is mostly already cached for us, but we
        ; need to factor in whether this is a "strong hit" and also the elemental affinity
        ; of the enemy we're attacking. Do that now.
        ; TODO: how will we handle non-elemental affinity? Figure that out when the time comes,
        ; for now ignore it.
        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        .repeat 6
        lsr
        .endrepeat
        clc
        adc #1
        tax
        ; if this is a strong hit, add that offset
        lda WeaponProperties
        and #WEAPON_STRONG_HIT
        bne strong_hit
weak_hit:
        lda PlayerWeaponDmgWeak, x
        jmp base_dmg_converge
strong_hit:
        lda PlayerWeaponDmgStrong, x
base_dmg_converge:
        sta DmgTotal

        ; Run through all 4 equipment slots and add their damage calculations to our sum
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

; The four basic resistances just ORA right in, neat as you please
.proc award_earth_resistance
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_EARTH
        sta PlayerResistances
        rts
.endproc

.proc award_ice_resistance
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_ICE
        sta PlayerResistances
        rts
.endproc

.proc award_air_resistance
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_AIR
        sta PlayerResistances
        rts
.endproc

.proc award_fire_resistance
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_FIRE
        sta PlayerResistances
        rts
.endproc

.proc award_earth_resistance_and_protection
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_EARTH
        sta PlayerResistances
        lda PlayerProtections
        ora #PLAYER_RESISTANCE_MASK_EARTH
        sta PlayerProtections
        rts
.endproc

.proc award_ice_resistance_and_protection
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_ICE
        sta PlayerResistances
        lda PlayerProtections
        ora #PLAYER_RESISTANCE_MASK_ICE
        sta PlayerProtections
        rts
.endproc

.proc award_air_resistance_and_protection
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_AIR
        sta PlayerResistances
        lda PlayerProtections
        ora #PLAYER_RESISTANCE_MASK_AIR
        sta PlayerProtections
        rts
.endproc

.proc award_fire_resistance_and_protection
        lda PlayerResistances
        ora #PLAYER_RESISTANCE_MASK_FIRE
        sta PlayerResistances
        lda PlayerProtections
        ora #PLAYER_RESISTANCE_MASK_FIRE
        sta PlayerProtections
        rts
.endproc

.proc _item_passive_common
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::ApplyPassivesFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        rts
.endproc

; Call this after loading, and then again each time the player's equipment changes
.proc FAR_compute_player_passives
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; First, clear all passive information from the player's cached state
        lda #0
        sta PlayerResistances
        sta PlayerProtections
        sta PlayerImmunities
        sta PlayerWeaknesses
        sta PlayerAbsorbtions

        ; Now run through each equipped item and compute any passive effects it may award.
        ; Exclusive effects depend on item evaluation order, so let's settle on left-to-right.
        ; Weapons, then Torches, then Armor, then Boots, then Accessories.
        lda current_save + SaveFile::PlayerEquipmentWeapon
        jsr _item_passive_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentTorch
        jsr _item_passive_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentArmor
        jsr _item_passive_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentBoots
        jsr _item_passive_common
        perform_zpcm_inc
        lda current_save + SaveFile::PlayerEquipmentAccessory
        jsr _item_passive_common
        perform_zpcm_inc

        ; Neither bombs nor spells apply passives currently. I don't think I want them to, as
        ; they would be tricky to re-evaluate constantly for an odd mechanical interaction.

        restore_previous_bank
        rts
.endproc

; some items proc specifically when enemies are defeated. These are so few that we just
; special case the whole lot of them right here.
.proc FAR_proc_items_on_enemy_slain
EffectiveAttackSquare := R10

        lda current_save + SaveFile::PlayerEquipmentBoots
        cmp #ITEM_NINJA_FOOTWRAPS
        bne no_ninja_footwraps
        ; if the ninja footwraps are currently on cooldown...
        lda PlayerNinjaFootwrapsCooldown
        beq no_ninja_footwraps
        ; ... then decrease that cooldown by 1 charge
        dec PlayerNinjaFootwrapsCooldown
        ; if the charge is now 0, signal this to the player with a SFX
        bne no_ninja_footwraps
        queue_sfx_triangle sfx_item_recharge_tri
        ; that's it, the HUD will automatically update itself.
no_ninja_footwraps:

        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_INFERNAL_LANTERN
        bne no_infernal_lantern
        ; first off, did we slay a matching foe? if not, we don't care
        ; about any of the other complicated checks
        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_FIRE
        bne no_infernal_lantern
        ; if we happen to be in a warp zone, then increase warp stability
        ldx PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_WARP
        beq not_a_warp_room_infernal
        increase_warp_stability
        jmp no_infernal_lantern ; and done
not_a_warp_room_infernal:
        ; only try to increase torchlight charge if we are actually in a
        ; dark room. otherwise leave it alone!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_infernal_lantern
        ; range check
        lda PlayerTorchlightBonus
        cmp #TORCHLIGHT_MAX_CHARGE_BRIGHTNESS
        bcs no_infernal_lantern
        inc PlayerTorchlightBonus
        ; and done.
no_infernal_lantern:

        lda current_save + SaveFile::PlayerEquipmentTorch
        cmp #ITEM_CHARGE_A_BULB
        bne no_charge_a_bulb
        ; first off, did we slay a matching foe? if not, we don't care
        ; about any of the other complicated checks
        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_AIR
        bne no_charge_a_bulb
        ; if we happen to be in a warp zone, then increase warp stability
        ldx PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_WARP
        beq not_a_warp_room_charge_a_bulb
        increase_warp_stability
        jmp no_charge_a_bulb ; and done
not_a_warp_room_charge_a_bulb:
        ; only try to increase torchlight charge if we are actually in a
        ; dark room. otherwise leave it alone!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_charge_a_bulb
        ; range check
        lda PlayerTorchlightBonus
        cmp #TORCHLIGHT_MAX_CHARGE_BRIGHTNESS
        bcs no_charge_a_bulb
        inc PlayerTorchlightBonus
        ; and done.
no_charge_a_bulb:

        rts
.endproc

; Called each time we enter a new room. Any items that need to reset state
; between room boundaries should do that here.
.proc FAR_init_room_item_state
        ; For torchlight bonus, is this a dark room?
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq room_is_lit
room_is_dark:
        ; for dark rooms, decrement the torchlight brightness by 1
        lda PlayerTorchlightBonus
        beq done_with_torchlight_bonus
        dec PlayerTorchlightBonus
        jmp done_with_torchlight_bonus
room_is_lit:
        ; The light! It burns! Clear out and reset the torchlight bonus.
        lda #0
        sta PlayerTorchlightBonus
        jmp done_with_torchlight_bonus
done_with_torchlight_bonus:

        rts
.endproc

.proc FAR_item_is_considered_valid_loot
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        lda ResultItemId
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::IsValidLootFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        sta ItemScratch0        

        restore_previous_bank
        lda ItemScratch0
        rts
.endproc

.proc FAR_item_is_considered_helpful_loot
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        lda ResultItemId
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::IsConsideredHelpfulFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        sta ItemScratch0        

        restore_previous_bank
        lda ItemScratch0
        rts
.endproc