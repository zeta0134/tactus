    .macpack longbranch

    .include "_globals.inc"

    .include "battlefield.inc"
    .include "coins.inc"
    .include "enemies.inc"
    .include "far_call.inc"
    .include "items.inc"
    .include "loot.inc"
    .include "player.inc"
    .include "prng.inc"
    .include "rainbow.inc"
    .include "saves.inc"
    .include "text_util.inc"
    .include "word_util.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .zeropage

LootTable: .res 2
DropTablePtr: .res 2
CoinTablePtr: .res 2

    .segment "RAM"

LootPosition: .res 1

ShopRollsCount: .res 1
shop_rolls_tracker: .res 16

price_buffer_low: .res 8
price_buffer_high: .res 8
price_buffer_pos: .res 8
price_buffer_attr: .res 8 ; sets the CHR bank and the color
PriceBufferPos: .res 1

    .segment "CODE_3"

; ========================================================
;                       COIN TABLES
; ========================================================

; All entries in the coin tables have 8 rows, meaning
; four separate coin denominations can be selected. Use
; NON for a chance at nothing.

; For now, all entries also drop a consistent amount of loot.
; While the system could in theory support randomization, right now
; it is too tricky to balance, and we need to get standard play
; feeling good before we introduce spice.

; It's absolutely nothing
loot_00_000:
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON

; Biased towards "normal" looking coins
loot_01_000:
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK

; Always drops a higher value coin (no particular bias)
loot_02_000:
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR
    .byte COIN_02_GMR

; 100% chance to drop a higher value coin (biased against nugs/stacks)
loot_03_000:
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMP

loot_05_000:
    .byte COIN_05_JWR
    .byte COIN_05_JWR
    .byte COIN_05_JWR
    .byte COIN_05_JWR
    .byte COIN_05_JWP
    .byte COIN_05_JWP
    .byte COIN_05_JWP
    .byte COIN_05_JWP

loot_10_000:
    .byte COIN_10_OBL
    .byte COIN_10_OBL
    .byte COIN_10_OBL
    .byte COIN_10_OBL
    .byte COIN_10_PRL
    .byte COIN_10_PRL
    .byte COIN_10_PRL
    .byte COIN_10_PRL

; Notable: the highest possible reward for any single slot
loot_25_000:
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD
    .byte COIN_25_DMD

; ========================================================
;                       DROP TABLES
; ========================================================

; Each entry in the drop table corresponds to a trio of 
; three coin entries. Any time we need to generate loot 
; for an enemy, we will ultimately be rolling against one
; of these tables. 

; We denote the expected average payout, which is the sum
; of the average payout of all three coin slots. "base" is the
; guaranteed output, and "plus" is what the RNG provides
; on average.

; Guaranteed basic drops, biased to generate the largest number
; of unique coins for each payout stage
base00: .word loot_00_000, loot_00_000, loot_00_000
base01: .word loot_01_000, loot_00_000, loot_00_000
base02: .word loot_01_000, loot_01_000, loot_00_000
base03: .word loot_01_000, loot_01_000, loot_01_000
base04: .word loot_02_000, loot_01_000, loot_01_000
base05: .word loot_02_000, loot_02_000, loot_01_000
base06: .word loot_02_000, loot_02_000, loot_02_000
base07: .word loot_03_000, loot_02_000, loot_02_000
base08: .word loot_03_000, loot_03_000, loot_02_000
base09: .word loot_03_000, loot_03_000, loot_03_000
base10: .word loot_05_000, loot_03_000, loot_02_000
base11: .word loot_05_000, loot_03_000, loot_03_000
base12: .word loot_05_000, loot_05_000, loot_02_000
base13: .word loot_05_000, loot_05_000, loot_03_000
base14: .word loot_10_000, loot_02_000, loot_02_000
base15: .word loot_05_000, loot_05_000, loot_05_000
base16: .word loot_10_000, loot_05_000, loot_01_000
base17: .word loot_10_000, loot_05_000, loot_02_000
base18: .word loot_10_000, loot_05_000, loot_03_000
; b19 can't be guaranteed
base20: .word loot_10_000, loot_05_000, loot_05_000
base21: .word loot_10_000, loot_10_000, loot_01_000
base22: .word loot_10_000, loot_10_000, loot_02_000
base23: .word loot_10_000, loot_10_000, loot_03_000
; b24 can't be guaranteed
base25: .word loot_10_000, loot_10_000, loot_05_000
base26: .word loot_25_000, loot_01_000, loot_00_000
base27: .word loot_25_000, loot_01_000, loot_01_000
base28: .word loot_25_000, loot_02_000, loot_01_000
base29: .word loot_25_000, loot_02_000, loot_02_000
base30: .word loot_25_000, loot_03_000, loot_02_000
base31: .word loot_25_000, loot_03_000, loot_03_000
base32: .word loot_25_000, loot_05_000, loot_02_000
base33: .word loot_25_000, loot_05_000, loot_03_000
; b34 can't be guaranteed
base35: .word loot_25_000, loot_05_000, loot_05_000
base36: .word loot_25_000, loot_10_000, loot_01_000
base37: .word loot_25_000, loot_10_000, loot_02_000
base38: .word loot_25_000, loot_10_000, loot_03_000
; b39 can't be guaranteed
base40: .word loot_25_000, loot_10_000, loot_05_000
; b41-b44 can't be guaranteed
base45: .word loot_25_000, loot_10_000, loot_10_000
; b46-b49 can't be guaranteed
base50: .word loot_25_000, loot_25_000, loot_00_000
base51: .word loot_25_000, loot_25_000, loot_01_000
base52: .word loot_25_000, loot_25_000, loot_02_000
base53: .word loot_25_000, loot_25_000, loot_03_000
; b54 can't be guaranteed
base55: .word loot_25_000, loot_25_000, loot_05_000
; b56-b59 can't be guaranteed
base60: .word loot_25_000, loot_25_000, loot_10_000
; b61-b74 can't be guaranteed
base75: .word loot_25_000, loot_25_000, loot_25_000 ; Note: maximum possible loot

special_one_diamond:    .word loot_25_000, loot_00_000, loot_00_000
special_two_diamonds:   .word loot_25_000, loot_25_000, loot_00_000
special_three_diamonds: .word loot_25_000, loot_25_000, loot_25_000

; 

; ========================================================
;                       LOOT TABLES
; ========================================================

; Each loot table is ordered by CHAIN, then COMBO. Each
; row is the next level of the chain, while each column
; is the next level of the combo at that particular chain
; level. Combo goes up to 5, any higher combo scored by the
; player (how!?) is capped. Similarly, chain ends at 10 and
; is capped accordingly.

; General guidance:
; - Even for skilled players, scoring high chain is fairly
;   inconsistent and can reward quite high payouts
; - On the flip side, it's not THAT hard to score a high
;   chain once, especially with earlygame slimes that die to
;   one hit. Be stingy with diamonds for weaker enemies
; - Combos should generally add a roughly FLAT bonus to that
;   row, regardless of the current chain. It's okay to fudge
;   this a little.
; - Above CHAIN 3, just use basic payouts; the random factor isn't
;   very fun at that point.

; For when an enemy needs to use the shared damage routine, but should
; never drop anything ever. Mostly meant for spawners and enemies that
; clone (bits of) themselves.
no_loot_table:
    ; COMBO x1 (+0), x2 (+1), x3 (+2), x4 (+3), x5 (+5)
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 1
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 2
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 3
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 4
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 5
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 6
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 7
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN 8
    .word    base00,  base00,  base00,  base00,  base00 ; CHAIN WOW

; For the weakest of the weak. Drops nothing at the base level. Meant primarily
; for slimes and other weak enemies that tend to die in one hit. Slow chain and
; combo growth on purpose, though high chains will still award reasonably decent
; payouts.
tiny_loot_table:
    ; COMBO x1 (+0), x2 (+1), x3 (+2), x4 (+3), x5 (+5)
    .word    base00,  base01,  base02,  base03,  base05 ; CHAIN 1
    .word    base01,  base02,  base03,  base04,  base06 ; CHAIN 2
    .word    base03,  base04,  base05,  base06,  base08 ; CHAIN 3
    .word    base05,  base06,  base07,  base08,  base10 ; CHAIN 4
    .word    base07,  base08,  base09,  base10,  base12 ; CHAIN 5
    .word    base10,  base11,  base12,  base13,  base15 ; CHAIN 6
    .word    base15,  base20,  base25,  base30,  base35 ; CHAIN 7
    .word    base20,  base25,  base30,  base35,  base40 ; CHAIN 8
    .word    base25,  base30,  base35,  base40,  base45 ; CHAIN WOW

; The following are the "standard" loot tables used by most regular
; enemies. They provide a consistent growth boost, and the base payout
; is increased based on enemy difficulty. Once base10 is reached, the
; payout grows *quite* quickly with respect to combo/chain.

; For basic enemies at their least threatening stage.
basic_loot_table:
    ; COMBO x1 (+0), x2 (+1), x3 (+2), x4 (+3), x5 (+5)
    .word    base02,  base03,  base04,  base05,  base07 ; CHAIN 1
    .word    base03,  base04,  base05,  base06,  base08 ; CHAIN 2
    .word    base05,  base06,  base07,  base08,  base10 ; CHAIN 3
    .word    base07,  base08,  base09,  base10,  base15 ; CHAIN 4
    .word    base10,  base15,  base20,  base25,  base30 ; CHAIN 5
    .word    base15,  base20,  base25,  base30,  base35 ; CHAIN 6
    .word    base20,  base25,  base30,  base35,  base40 ; CHAIN 7
    .word    base25,  base30,  base35,  base40,  base45 ; CHAIN 8
    .word    base30,  base35,  base40,  base45,  base50 ; CHAIN WOW

; For basic medium strength enemies.
intermediate_loot_table:
    ; COMBO x1 (+0), x2 (+1), x3 (+2), x4 (+3), x5 (+5)
    .word    base03,  base04,  base05,  base06,  base08 ; CHAIN 1
    .word    base05,  base06,  base07,  base08,  base10 ; CHAIN 2
    .word    base07,  base08,  base09,  base10,  base15 ; CHAIN 3
    .word    base10,  base15,  base20,  base25,  base30 ; CHAIN 4
    .word    base15,  base20,  base25,  base30,  base35 ; CHAIN 5
    .word    base20,  base25,  base30,  base35,  base40 ; CHAIN 6
    .word    base25,  base30,  base35,  base40,  base45 ; CHAIN 7
    .word    base30,  base35,  base40,  base45,  base50 ; CHAIN 8
    .word    base35,  base40,  base45,  base50,  base55 ; CHAIN WOW

; For strong enemies. Large payouts, especially at high chain levels
advanced_loot_table:
    ; COMBO x1 (+0), x2 (+1), x3 (+2), x4 (+3), x5 (+5)
    .word    base05,  base06,  base07,  base08,  base10 ; CHAIN 1
    .word    base07,  base08,  base09,  base10,  base15 ; CHAIN 2
    .word    base10,  base15,  base20,  base25,  base30 ; CHAIN 3
    .word    base15,  base20,  base25,  base30,  base35 ; CHAIN 4
    .word    base20,  base25,  base30,  base35,  base40 ; CHAIN 5
    .word    base25,  base30,  base35,  base40,  base45 ; CHAIN 6
    .word    base30,  base35,  base40,  base45,  base50 ; CHAIN 7
    .word    base35,  base40,  base45,  base50,  base55 ; CHAIN 8
    .word    base40,  base45,  base50,  base60,  base75 ; CHAIN WOW

; For game mechanics that need to force a single gem
one_diamond_loot_table:    .word special_one_diamond
two_diamonds_loot_table:   .word special_two_diamonds
three_diamonds_loot_table: .word special_three_diamonds
three_coins_loot_table:    .word base03

chain_offset_lut:
    .byte 0, 10, 20, 30, 40, 50, 60, 70, 80
combo_offset_lut:
    .byte 0, 2, 4, 6, 8

; ========================================================
;                    TREASURE TABLES
; ========================================================

; Exactly what it says on the tin. Typically used in the very early game
; to force weapon spawns, so players can reliably get a build going
weapons_only_treasure_table:
    .byte 5
    .byte ITEM_BROADSWORD
    .byte ITEM_LONGSWORD
    .byte ITEM_SPEAR
    .byte ITEM_FLAIL
    .byte ITEM_COMBAT_ANCHOR

; heavily weighted towards L1 weapons, but occasionally has some L2 and other interesting stuff
common_treasure_table:
    ; Sometimes we need the shop to carry three specific items. Here's how to do that:
    ;.byte 3
    ;.byte ITEM_SPELL_LIFE
    ;.byte ITEM_INFERNAL_LANTERN
    ;.byte ITEM_CHARGE_A_BULB

    .byte 42
    .byte ITEM_BROADSWORD
    .byte ITEM_BROADSWORD
    .byte ITEM_BROADSWORD
    .byte ITEM_LONGSWORD
    .byte ITEM_LONGSWORD
    .byte ITEM_LONGSWORD
    .byte ITEM_SPEAR
    .byte ITEM_SPEAR
    .byte ITEM_SPEAR
    .byte ITEM_FLAIL
    .byte ITEM_FLAIL
    .byte ITEM_FLAIL
    .byte ITEM_COMBAT_ANCHOR
    .byte ITEM_COMBAT_ANCHOR
    .byte ITEM_COMBAT_ANCHOR
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_UPGRADE_EARTH
    .byte ITEM_UPGRADE_ICE
    .byte ITEM_UPGRADE_AIR
    .byte ITEM_UPGRADE_FIRE
    .byte ITEM_GO_GO_BOOTS
    .byte ITEM_NINJA_FOOTWRAPS
    .byte ITEM_INFERNAL_LANTERN
    .byte ITEM_CHARGE_A_BULB
    .byte ITEM_HEART_ARMOR
    .byte ITEM_HEART_ARMOR
    .byte ITEM_CHAIN_LINK
    .byte ITEM_CHAIN_LINK
    .byte ITEM_ALOHA_TSHIRT_1
    .byte ITEM_ALOHA_TSHIRT_2
    .byte ITEM_ALOHA_TSHIRT_3
    .byte ITEM_SPELL_FIRE
    .byte ITEM_SPELL_AIR
    .byte ITEM_SPELL_ICE
    .byte ITEM_SPELL_EARTH
    .byte ITEM_OBSIDIAN_RING
    .byte ITEM_RUBY_NECKLACE
    .byte ITEM_TOPAZ_EARRINGS
    .byte ITEM_SAPPHIRE_BRACELET
    .byte ITEM_AMULET_OF_YENDOR

; heavily weighted towards upgrade crystals, contains lots of other powerful items
rare_treasure_table:
    .byte 36
    .byte ITEM_UPGRADE_EARTH
    .byte ITEM_UPGRADE_ICE
    .byte ITEM_UPGRADE_AIR
    .byte ITEM_UPGRADE_FIRE
    .byte ITEM_UPGRADE_EARTH
    .byte ITEM_UPGRADE_ICE
    .byte ITEM_UPGRADE_AIR
    .byte ITEM_UPGRADE_FIRE
    .byte ITEM_UPGRADE_EARTH
    .byte ITEM_UPGRADE_ICE
    .byte ITEM_UPGRADE_AIR
    .byte ITEM_UPGRADE_FIRE
    .byte ITEM_UPGRADE_EARTH
    .byte ITEM_UPGRADE_ICE
    .byte ITEM_UPGRADE_AIR
    .byte ITEM_UPGRADE_FIRE
    .byte ITEM_LARGE_TORCH
    .byte ITEM_INFERNAL_LANTERN
    .byte ITEM_LARGE_TORCH
    .byte ITEM_CHARGE_A_BULB
    .byte ITEM_NINJA_FOOTWRAPS
    .byte ITEM_HEART_CONTAINER
    .byte ITEM_HEART_CONTAINER
    .byte ITEM_HEART_CONTAINER
    .byte ITEM_HEART_CONTAINER
    .byte ITEM_SHIELD
    .byte ITEM_SHIELD
    .byte ITEM_SHIELD
    .byte ITEM_SHIELD
    .byte ITEM_SPELL_FIRE
    .byte ITEM_SPELL_AIR
    .byte ITEM_SPELL_ICE
    .byte ITEM_SPELL_EARTH
    .byte ITEM_SPELL_BOMB
    .byte ITEM_SPELL_LIFE
    .byte ITEM_LUCKY_PENNY


consumable_treasure_table:
    ; FOOOOOOOOOOD! (Also should have bombs, heart containers, etc)
    .byte 12
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_LARGE_FRIES
    .byte ITEM_HEART_ARMOR
    .byte ITEM_HEART_ARMOR
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3

common_chest_treasure_table: ; TODO: remove this label
standard_chest_treasure_table:
    .byte 43
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BASIC_TORCH
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_BOMB_STANDARD_X3
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_SMALL_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_MEDIUM_FRIES
    .byte ITEM_HEART_ARMOR
    .byte ITEM_HEART_ARMOR
    .byte ITEM_HEART_ARMOR
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_GOLD_SACK
    .byte ITEM_SPELL_FIRE
    .byte ITEM_SPELL_AIR
    .byte ITEM_SPELL_ICE
    .byte ITEM_SPELL_EARTH
    .byte ITEM_SPELL_BOMB
    .byte ITEM_SPELL_LIFE
    
rare_chest_treasure_table:
    ; So very placeholder
    .byte 16
    .repeat 16
    .byte ITEM_UPGRADE_FIRE
    .endrepeat
    
legendary_chest_treasure_table:
    ; So very placeholder
    .byte 16
    .repeat 16
    .byte ITEM_UPGRADE_EARTH
    .endrepeat

MAX_CHAIN = 8
MAX_COMBO = 4 ; actually 5, but we need to decrement

; Note: defaults to tiny_loot_table, and resets to this after each call. Set
; LootTable to the desired table for all non-basic enemies.
.proc FAR_roll_loot
    perform_zpcm_inc
    ldx PlayerChain
    cpx #MAX_CHAIN
    bcc chain_in_range
    ldx #MAX_CHAIN
chain_in_range:
    ldy PlayerCombo
    dey
    cpy #MAX_COMBO
    bcc combo_in_range
    ldy #MAX_COMBO
combo_in_range:
    lda chain_offset_lut, x
    clc
    adc combo_offset_lut, y
    tay

initialize_drop_table:
    ; Load up the relevant drop table
    lda (LootTable), y
    sta DropTablePtr+0
    iny
    lda (LootTable), y
    sta DropTablePtr+1

    perform_zpcm_inc

    ; Each drop table has three coin entries, so get those going
    ldy #0
    lda (DropTablePtr), y
    sta CoinTablePtr+0
    ldy #1
    lda (DropTablePtr), y
    sta CoinTablePtr+1
    jsr roll_coin
    ldy #2
    lda (DropTablePtr), y
    sta CoinTablePtr+0
    ldy #3
    lda (DropTablePtr), y
    sta CoinTablePtr+1
    jsr roll_coin
    ldy #4
    lda (DropTablePtr), y
    sta CoinTablePtr+0
    ldy #5
    lda (DropTablePtr), y
    sta CoinTablePtr+1
    jsr roll_coin

    ; And that... should be it?

    ; As a safety, always revert to the tiny loot table after spawning loot
    ; (if an enemy forgets to set it, this becomes our default)
    st16 LootTable, tiny_loot_table

    perform_zpcm_inc

    rts
.endproc

; For when we need to roll a really specific small loot table
; and ignore player chain/combo, typically for enemies that have
; special defeat conditions (one-armed bandits, bosses, etc)
.proc FAR_roll_base_loot
    perform_zpcm_inc
    ldy #0
    jmp FAR_roll_loot::initialize_drop_table
.endproc

.proc roll_coin
    jsr next_gameplay_rand
    and #%00000111
    tay
    lda (CoinTablePtr), y
    ; if this is a 0 entry, there is no coin. we're done.
    beq done
    ; otherwise, queue up this specific coin!
    ldx LootPosition
    jsr FIXED_spawn_coin
done:
    rts
.endproc

; place the loot table of your choice in R0, result in R2
; TODO: detect excessive rerolls and draw from a "known acceptable"
; set, which is allowed to contain duplicates, as a fallback.
.proc FAR_roll_shop_loot
LootTablePtr := R0
TableLength := R2
ItemId := R2
    access_data_bank #<.bank(item_table)

roll_acceptable_item_loop:
    perform_zpcm_inc
    ldy #0
    lda (LootTablePtr), y
    sta TableLength
    jsr next_room_rand
fix_index_loop:
    perform_zpcm_inc
    cmp TableLength
    bcc item_index_in_range
    sec
    sbc TableLength
    jmp fix_index_loop
item_index_in_range:
    tay
    iny ; move past length byte
    lda (LootTablePtr), y
    sta ItemId
    ; sanity checks here
    jsr check_for_duplicate_shop_roll
    bne roll_acceptable_item_loop
    jsr check_for_duplicate_player_equipment
    bne roll_acceptable_item_loop
    far_call FAR_item_is_considered_valid_loot
    cmp #0
    bne roll_acceptable_item_loop
    ; we'll keep this item then; add it to the set that we've rolled so far
    jsr add_to_shop_rolls
    ; and... done?

    restore_previous_bank
    perform_zpcm_inc
    rts
.endproc

; same deal but it uses the gameplay LFSR, for when we need to
; spawn treasure on the fly
; TODO: detect excessive rerolls and draw from a "known acceptable"
; set, which is allowed to contain duplicates, as a fallback.
; for gameplay loot this can be just treasure items, which we always
; consider helpful anyway.
.proc FAR_roll_gameplay_loot
LootTablePtr := R16
ItemId       := R18
TableLength  := R19
    access_data_bank #<.bank(item_table)

roll_acceptable_item_loop:
    ldy #0
    lda (LootTablePtr), y
    sta TableLength
    jsr next_gameplay_rand
fix_index_loop:
    cmp TableLength
    bcc item_index_in_range
    sec
    sbc TableLength
    jmp fix_index_loop
item_index_in_range:
    tay
    iny ; move past length byte
    lda (LootTablePtr), y
    sta ItemId
    ; gameplay treasures (these come out of "standard chests") run the helpful
    ; loot sanity check, and will continue to roll until they land on a helpful
    ; item.
    far_call FAR_item_is_considered_helpful_loot
    cmp #0
    bne roll_acceptable_item_loop

    restore_previous_bank
    rts
.endproc

; returns 0 on success, nonzero on failure
.proc check_for_duplicate_shop_roll
LootTablePtr := R0
ItemId := R2
    ldx #0
loop:
    cpx ShopRollsCount
    beq accept ; if we reach the end of the list (which may be empty) we're done!
    lda shop_rolls_tracker, x
    cmp ItemId ; only reject on exact ItemId match
    beq reject
    inx
    jmp loop
accept:
    lda #0
    rts
reject:
    lda #$FF
    rts
.endproc

; intentionally ignores the bomb and spell slot, as duplicates there are
; generally acceptable. also intentionally ignores special mechanics and rules,
; which should be covered by the item's "is valid" logic instead
.proc check_for_duplicate_player_equipment
ItemId := R2
    lda ItemId
    cmp current_save + SaveFile::PlayerEquipmentWeapon
    beq is_dupliate
    cmp current_save + SaveFile::PlayerEquipmentTorch
    beq is_dupliate
    cmp current_save + SaveFile::PlayerEquipmentArmor
    beq is_dupliate
    cmp current_save + SaveFile::PlayerEquipmentBoots
    beq is_dupliate
    cmp current_save + SaveFile::PlayerEquipmentAccessory
    beq is_dupliate
is_unique:
    lda #0
    rts
is_dupliate:
    lda #$FF
    rts
.endproc

.proc add_to_shop_rolls
ItemId := R2
    ldx ShopRollsCount
    lda ItemId
    sta shop_rolls_tracker, x
    inc ShopRollsCount
    rts
.endproc

.proc FAR_reset_shop_tracker
    lda #0
    sta ShopRollsCount
    rts
.endproc

.proc FAR_reset_price_tracker
    lda #0
    sta PriceBufferPos
    rts
.endproc

; I don't really have a better place to put this: we need to track which
; tiles want to display a number underneath themselves, and draw those numbers.
; This pair of functions keeps a running tally of that
.proc FAR_draw_prices
NumberWord := T0
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5 ; we're not supporting shop prices higher than 9999

CurrentPos := R0
CurrentAttr := R1

NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2
HighRowScratch := ActiveDrawingScratch+4
LowRowScratch := ActiveDrawingScratch+5

    ; bail early if there's nothing to do
    lda PriceBufferPos
    bne proceed_to_draw
    rts

proceed_to_draw:
    lda #0
    sta CurrentPos
loop:
    perform_zpcm_inc
    ; workout the base 10 numerals for this price
    ldx CurrentPos
    lda price_buffer_attr, x
    sta CurrentAttr ; stash for later so we free up X during drawing
    lda price_buffer_low, x
    sta NumberWord+0
    lda price_buffer_high, x
    sta NumberWord+1
    far_call FAR_base_10


    ; figure out the starting tile for price drawing
    lda #0
    sta HighRowScratch

    ldx CurrentPos
    lda price_buffer_pos, x

    ; work out the high bits of the row, these are the top 4 bits of TargetIndex x64, so they
    ; are split across both nametable address bytes
    asl
    rol HighRowScratch
    asl
    rol HighRowScratch
    and #%11000000
    sta LowRowScratch
    ; now deal with the column, which here is x2
    lda price_buffer_pos, x
    asl
    and #%00011110
    ora LowRowScratch
    sta NametableAddr+0
    sta AttributeAddr+0

    perform_zpcm_inc

    lda active_battlefield
    beq second_nametable ; use the INACTIVE buffer here
    lda #$50
    ldy #$58
    jmp set_high_bytes
second_nametable:
    lda #$54
    ldy #$5C
set_high_bytes:
    ora HighRowScratch
    sta NametableAddr+1
    tya
    ora HighRowScratch
    sta AttributeAddr+1

    ; now we have the position of the top-left corner of the shop tile. we need to move
    ; down by 3 rows, and left by 1 column. we don't worry too much about wraparound here
    add16b NametableAddr, #(32*3)
    dec16 NametableAddr
    add16b AttributeAddr, #(32*3)
    dec16 AttributeAddr

    ; now, depending on how large the number is, call one of the drawing routines
check_thousands:
    lda ThousandsDigit
    beq check_hundreds
    jsr draw_thousands_centered
    jmp converge
check_hundreds:
    lda HundredsDigit
    beq check_tens
    jsr draw_hundreds_centered
    jmp converge
check_tens:
    lda TensDigit
    beq draw_ones
    jsr draw_tens_centered
    jmp converge
draw_ones:
    jsr draw_ones_centered
converge:
    inc CurrentPos
    lda CurrentPos
    cmp PriceBufferPos
    jne loop

    ; and done!
    perform_zpcm_inc
    rts
.endproc

LEFT_HALF_DIGIT_BASE = $10
RIGHT_HALF_DIGIT_BASE = $20

tens_place_tile_lut:
    .byte $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0

.proc draw_thousands_centered
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5

CurrentAttr := R1
NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2

    ldy #0
    lda ThousandsDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #1
    lda HundredsDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #2
    lda TensDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #3
    lda OnesDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    rts
.endproc

.proc draw_hundreds_centered
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5

CurrentAttr := R1
NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2

    ldy #0
    lda HundredsDigit
    ora #LEFT_HALF_DIGIT_BASE
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #1
    ldx HundredsDigit
    lda tens_place_tile_lut, x
    ora TensDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #2
    ldx TensDigit
    lda tens_place_tile_lut, x
    ora OnesDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #3
    lda OnesDigit
    ora #RIGHT_HALF_DIGIT_BASE
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    rts
.endproc

.proc draw_tens_centered
OnesDigit := T2
TensDigit := T3

CurrentAttr := R1
NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2

    ldy #1
    lda TensDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #2
    lda OnesDigit
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    rts
.endproc

.proc draw_ones_centered
OnesDigit := T2

CurrentAttr := R1
NametableAddr := ActiveDrawingScratch+0
AttributeAddr := ActiveDrawingScratch+2

    ldy #1
    lda OnesDigit
    ora #LEFT_HALF_DIGIT_BASE
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    ldy #2
    lda OnesDigit
    ora #RIGHT_HALF_DIGIT_BASE
    sta (NametableAddr), y
    lda CurrentAttr
    sta (AttributeAddr), y

    rts
.endproc

.proc FAR_queue_price_tile_here
ItemCost        := R2
PriceColor      := R4
CurrentTile := R15
    ldx PriceBufferPos
    lda ItemCost+0
    sta price_buffer_low, x
    lda ItemCost+1
    sta price_buffer_high, x
    lda PriceColor
    sta price_buffer_attr, x
    lda CurrentTile
    sta price_buffer_pos, x
    inc PriceBufferPos
    ;safety
    lda PriceBufferPos
    and #%111
    sta PriceBufferPos
    rts
.endproc
