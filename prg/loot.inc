; External code doesn't really use these, but I want a list
; sorted by average payout
.global loot_00_000
.global loot_00_500
.global loot_01_000
.global loot_01_500
.global loot_02_000
.global loot_02_500
.global loot_03_000
.global rare_03_625
.global loot_05_000
.global rare_07_125
.global rare_09_375
.global loot_10_000
.global rare_11_875
.global loot_25_000

.global LootTable
.global LootPosition
.global FAR_roll_loot

.global tiny_loot_table
.global standard_loot_table

.macro set_loot_table loot_table
    st16 LootTable, loot_table
.endmacro

.macro roll_loot_at pos
    lda pos
    sta LootPosition
    far_call FAR_roll_loot
.endmacro