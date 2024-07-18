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

; Generic treasure, divided merely by denomination and
; reward chance. This first group has inbetween variants
; which reward half-coins on average

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


; 50% chance to drop nothing (useful for weaker enemies)
loot_00_500:
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_00_NON
    .byte COIN_01_STK
    .byte COIN_01_SNW
    .byte COIN_01_SNO
    .byte COIN_01_NUG

; Biased towards "normal" looking coins
loot_01_000:
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_STK
    .byte COIN_01_SNW
    .byte COIN_01_SNW
    .byte COIN_01_SNW
    .byte COIN_01_SNO
    .byte COIN_01_NUG

; 50% chance to drop a higher value coin
loot_01_500:
    .byte COIN_01_STK
    .byte COIN_01_SNW
    .byte COIN_01_SNO
    .byte COIN_01_NUG
    .byte COIN_02_STK
    .byte COIN_02_SNG
    .byte COIN_02_NGA
    .byte COIN_02_NGB

; Always drops a higher value coin (no particular bias)
loot_02_000:
    .byte COIN_02_STK
    .byte COIN_02_STK
    .byte COIN_02_SNG
    .byte COIN_02_SNG
    .byte COIN_02_NGA
    .byte COIN_02_NGA
    .byte COIN_02_NGB
    .byte COIN_02_NGB

; 50% chance to drop a higher value coin (no stacks though)
loot_02_500:
    .byte COIN_02_STK
    .byte COIN_02_SNG
    .byte COIN_02_NGA
    .byte COIN_02_NGB
    .byte COIN_03_SNG
    .byte COIN_03_NUG
    .byte COIN_03_GMP
    .byte COIN_03_GMO

; 100% chance to drop a higher value coin (biased against nugs/stacks)
loot_03_000:
    .byte COIN_03_STK
    .byte COIN_03_NUG
    .byte COIN_03_SNG
    .byte COIN_03_SNG
    .byte COIN_03_GMP
    .byte COIN_03_GMP
    .byte COIN_03_GMO
    .byte COIN_03_GMO

; That's enough small-value shenanigans, so the following
; groups will be more utilitarian. First, we have a crowd
; favorite, "rare chance of treasure"
; (the number here is always the average expected payout)

rare_03_625:
    .byte COIN_02_STK
    .byte COIN_02_SNG
    .byte COIN_02_NGA
    .byte COIN_02_NGB
    .byte COIN_03_GMP
    .byte COIN_03_GMO
    .byte COIN_05_MTH
    .byte COIN_10_PRL

rare_07_125:
    .byte COIN_03_SNG
    .byte COIN_03_NUG
    .byte COIN_03_GMP
    .byte COIN_03_GMO
    .byte COIN_05_GOA
    .byte COIN_05_GPB
    .byte COIN_10_CWA
    .byte COIN_25_DMD

rare_09_375:
    .byte COIN_05_GPA
    .byte COIN_05_GOA
    .byte COIN_05_GPB
    .byte COIN_05_GOB
    .byte COIN_10_CPA
    .byte COIN_10_CWB
    .byte COIN_10_PRL
    .byte COIN_25_DMD

; (much less spready; biased heavily towards 10)
rare_11_875:
    .byte COIN_10_CPA
    .byte COIN_10_CWA
    .byte COIN_10_COA
    .byte COIN_10_CPB
    .byte COIN_10_CWB
    .byte COIN_10_COB
    .byte COIN_10_PRL
    .byte COIN_25_DMD

; Rounding out the generic treasure category, for those
; times when you'd like to consistently force one particular
; denomination:

loot_05_000:
    .byte COIN_05_GPA
    .byte COIN_05_GPA
    .byte COIN_05_GOA
    .byte COIN_05_GPB
    .byte COIN_05_GPB
    .byte COIN_05_GOB
    .byte COIN_05_GOB
    .byte COIN_05_MTH

loot_10_000:
    .byte COIN_10_CPA
    .byte COIN_10_CWA
    .byte COIN_10_COA
    .byte COIN_10_CPB
    .byte COIN_10_CWB
    .byte COIN_10_COB
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
b00_p00_000: .word loot_00_000, loot_00_000, loot_00_000
b01_p00_000: .word loot_01_000, loot_00_000, loot_00_000
b02_p00_000: .word loot_01_000, loot_01_000, loot_00_000
b03_p00_000: .word loot_01_000, loot_01_000, loot_01_000
b04_p00_000: .word loot_02_000, loot_01_000, loot_01_000
b05_p00_000: .word loot_02_000, loot_02_000, loot_01_000
b06_p00_000: .word loot_02_000, loot_02_000, loot_02_000
b07_p00_000: .word loot_03_000, loot_02_000, loot_02_000
b08_p00_000: .word loot_03_000, loot_03_000, loot_02_000
b09_p00_000: .word loot_03_000, loot_03_000, loot_03_000
b10_p00_000: .word loot_05_000, loot_03_000, loot_02_000
b11_p00_000: .word loot_05_000, loot_03_000, loot_03_000
b12_p00_000: .word loot_05_000, loot_05_000, loot_02_000
b13_p00_000: .word loot_05_000, loot_05_000, loot_03_000
b14_p00_000: .word loot_10_000, loot_02_000, loot_02_000
b15_p00_000: .word loot_05_000, loot_05_000, loot_05_000
b16_p00_000: .word loot_10_000, loot_05_000, loot_01_000
b17_p00_000: .word loot_10_000, loot_05_000, loot_02_000
b18_p00_000: .word loot_10_000, loot_05_000, loot_03_000
; b19 can't be guaranteed
b20_p00_000: .word loot_10_000, loot_05_000, loot_05_000
b21_p00_000: .word loot_10_000, loot_10_000, loot_01_000
b22_p00_000: .word loot_10_000, loot_10_000, loot_02_000
b23_p00_000: .word loot_10_000, loot_10_000, loot_03_000
; b24 can't be guaranteed
b25_p00_000: .word loot_10_000, loot_10_000, loot_05_000
b26_p00_000: .word loot_25_000, loot_01_000, loot_00_000
b27_p00_000: .word loot_25_000, loot_01_000, loot_01_000
b28_p00_000: .word loot_25_000, loot_02_000, loot_01_000
b29_p00_000: .word loot_25_000, loot_02_000, loot_02_000
b30_p00_000: .word loot_25_000, loot_03_000, loot_02_000
b31_p00_000: .word loot_25_000, loot_03_000, loot_03_000
b32_p00_000: .word loot_25_000, loot_05_000, loot_02_000
b33_p00_000: .word loot_25_000, loot_05_000, loot_03_000
; b34 can't be guaranteed
b35_p00_000: .word loot_25_000, loot_05_000, loot_05_000
b36_p00_000: .word loot_25_000, loot_10_000, loot_01_000
b37_p00_000: .word loot_25_000, loot_10_000, loot_02_000
b38_p00_000: .word loot_25_000, loot_10_000, loot_03_000
; b39 can't be guaranteed
b40_p00_000: .word loot_25_000, loot_10_000, loot_05_000
; b41-b44 can't be guaranteed
b45_p00_000: .word loot_25_000, loot_10_000, loot_10_000
; b46-b49 can't be guaranteed
b50_p00_000: .word loot_25_000, loot_25_000, loot_00_000
b51_p00_000: .word loot_25_000, loot_25_000, loot_01_000
b52_p00_000: .word loot_25_000, loot_25_000, loot_02_000
b53_p00_000: .word loot_25_000, loot_25_000, loot_03_000
; b54 can't be guaranteed
b55_p00_000: .word loot_25_000, loot_25_000, loot_05_000
; b56-b59 can't be guaranteed
b60_p00_000: .word loot_25_000, loot_25_000, loot_10_000
; b61-b74 can't be guaranteed
b75_p00_000: .word loot_25_000, loot_25_000, loot_25_000 ; Note: maximum possible loot

; pure spread, mostly meant for weaker enemies
b00_p00_500: .word loot_00_500, loot_00_000, loot_00_000
b00_p01_000: .word loot_00_500, loot_00_500, loot_00_000
b00_p01_500: .word loot_00_500, loot_00_500, loot_00_500

; guaranteed baseline with a chance of bonus
; notably, these coin entries have the following base+spread amounts:
; loot_01_500 ; b01_p00_500
; loot_02_500 ; b02_p00_500
; rare_03_625 ; b02_p01_625
; rare_07_125 ; b03_p04_125
; rare_09_375 ; b05_p04_375
; rare_11_875 ; b10_p01_875

; pure spread + baseline for a few baseline levels, meant for use in combos
b01_p00_500: .word loot_01_000, loot_00_500, loot_00_000
b01_p01_000: .word loot_01_000, loot_00_500, loot_00_500
b01_p01_500: .word loot_01_000, loot_00_500, loot_00_500
b02_p00_500: .word loot_02_000, loot_00_500, loot_00_000
b02_p01_000: .word loot_02_000, loot_00_500, loot_00_500
b03_p00_500: .word loot_03_000, loot_00_500, loot_00_000
b03_p01_000: .word loot_03_000, loot_00_500, loot_00_500
b05_p00_500: .word loot_05_000, loot_00_500, loot_00_000
b05_p01_000: .word loot_05_000, loot_00_500, loot_00_500
b10_p00_500: .word loot_10_000, loot_00_500, loot_00_000
b10_p01_000: .word loot_10_000, loot_00_500, loot_00_500

; rare drops; these use all the wacky loot tables and have significant spread. Mostly
; use these for uncommon, difficult enemies
b04_p02_625: .word rare_03_625, loot_01_500, loot_01_500
b05_p03_750: .word rare_03_625, rare_03_625, loot_01_500
b06_p04_875: .word rare_03_625, rare_03_625, rare_03_625
b09_p12_375: .word rare_07_125, rare_07_125, rare_07_125
b15_p13_125: .word rare_09_375, rare_09_375, rare_09_375
b30_p05_625: .word rare_11_875, rare_11_875, rare_11_875 ; extremely rare chance for maximum payout

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

; For the weakest of the weak. Very low maximum payout, often
; drops nothing for basic hits, etc. (This is primarily meant for slimes)
; Not very spready at higher levels; slimes are a weak but reliable source
; of income for players that can work them into extended chains.
tiny_loot_table:
    ; COMBO   x1 (+0),     x2 (+1),     x3 (+2),     x4 (+3),     x5 (+5)
    .word b00_p00_500, b01_p00_500, b02_p00_500, b03_p00_500, b05_p00_500 ; CHAIN 1
    .word b00_p01_000, b01_p01_000, b02_p01_000, b03_p01_000, b05_p01_000 ; CHAIN 2
    .word b01_p00_500, b02_p00_500, b03_p00_500, b04_p00_000, b06_p00_000 ; CHAIN 3
    .word b02_p01_000, b03_p00_000, b04_p00_000, b05_p00_000, b07_p00_000 ; CHAIN 4
    .word b03_p01_000, b04_p00_000, b05_p00_000, b06_p00_000, b08_p00_000 ; CHAIN 5
    .word b04_p00_000, b05_p00_000, b06_p00_000, b07_p00_000, b09_p00_000 ; CHAIN 6
    .word b06_p00_000, b07_p00_000, b08_p00_000, b09_p00_000, b11_p00_000 ; CHAIN 7
    .word b08_p00_000, b09_p00_000, b10_p00_000, b11_p00_000, b13_p00_000 ; CHAIN 8
    .word b10_p00_000, b11_p00_000, b12_p00_000, b13_p00_000, b15_p00_000 ; CHAIN WOW

; For standard enemies at their least threatening
; (for all non-slimes at the moment)
standard_loot_table:
    ; COMBO   x1 (+0),     x2 (+1),     x3 (+3),     x4 (+5),     x5 (+7)
    .word b00_p01_000, b01_p01_000, b04_p00_000, b05_p00_000, b08_p00_000 ; CHAIN 1
    .word b01_p01_000, b02_p01_000, b05_p00_000, b07_p00_000, b09_p00_000 ; CHAIN 2
    .word b02_p01_000, b04_p00_000, b06_p00_000, b08_p00_000, b10_p00_000 ; CHAIN 3
    .word b04_p00_000, b05_p00_000, b07_p00_000, b09_p00_000, b11_p00_000 ; CHAIN 4
    .word b05_p00_000, b06_p00_000, b08_p00_000, b10_p00_000, b12_p00_000 ; CHAIN 5
    .word b07_p00_000, b08_p00_000, b09_p00_000, b11_p00_000, b13_p00_000 ; CHAIN 6
    .word b10_p00_000, b11_p00_000, b13_p00_000, b15_p00_000, b17_p00_000 ; CHAIN 7
    .word b12_p00_000, b13_p00_000, b15_p00_000, b17_p00_000, b20_p00_000 ; CHAIN 8
    .word b15_p00_000, b16_p00_000, b18_p00_000, b20_p00_000, b22_p00_000 ; CHAIN WOW

; For medium strength enemies. Heavily random on purpose
uncommon_loot_table:
    ; TODO!

; For strong enemies. Large payouts, especially at high chain levels
rare_loot_table:
    ; TODO!


chain_offset_lut:
    .byte 0, 0, 10, 20, 30, 40, 50, 60, 70, 80
combo_offset_lut:
    .byte 0, 2, 4, 6, 8

MAX_CHAIN = 9
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
    jsr next_rand
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







