        .macpack longbranch

        .include "far_call.inc"
        .include "chr.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"

.segment "PRG0_8000"

HUD_UPPER_HALF = $2342
HUD_LOWER_HALF = $2362

