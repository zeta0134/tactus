    .include "coins.inc"
    .include "loot.inc"
    .include "player.inc"
    .include "prng.inc"
    .include "word_util.inc"

    .zeropage

LootTable: .res 2
DropTablePtr: .res 2
CoinTablePtr: .res 2

    .segment "RAM"

LootPosition: .res 1

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

chain_offset_lut:
    .byte 0, 10, 20, 30, 40, 50, 60, 70, 80
combo_offset_lut:
    .byte 0, 2, 4, 6, 8

MAX_CHAIN = 8
MAX_COMBO = 4 ; actually 5, but we need to decrement

; Note: defaults to tiny_loot_table, and resets to this after each call. Set
; LootTable to the desired table for all non-basic enemies.
.proc FAR_roll_loot
    ; TODO: combo and chain! (compute Y based on this)
    ; FOR NOW, just grab the base entry in the list
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

    ; Load up the relevant drop table
    lda (LootTable), y
    sta DropTablePtr+0
    iny
    lda (LootTable), y
    sta DropTablePtr+1

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

    rts
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







