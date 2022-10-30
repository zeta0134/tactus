        .include "nes.inc"
        .include "action53.inc"

.zeropage
action53_shadow: .res 1

.segment "PRGFIXED_C000"

.proc init_action53
        ; We do this first thing, per nesdev-2022 rules
        ; (I'm a bit unclear what the outer bank *should* be; we only have 64k total)
        a53_write A53_REG_OUTER_BANK, #$FF
        a53_write A53_REG_MODE, #(A53_MIRRORING_VERTICAL | A53_PRG_BANK_MODE_FIXED_C000 | A53_PRG_OUTER_BANK_64K)
        a53_write A53_REG_CHR_BANK, #0
        a53_write A53_REG_INNER_BANK, #0
        rts
.endproc