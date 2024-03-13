.include "nes.inc"

.include "bhop/bhop.inc"
.include "debug.inc"
.include "far_call.inc"
.include "palette.inc"
.include "rainbow.inc"
.include "raster_tricks.inc"
.include "sound.inc"
.include "zeropage.inc"
.include "zpcm.inc"

        .zeropage
delay_table_addr: .res 2
delay_routine_addr: .res 2

        .segment "PRGFIXED_E000"

.proc init_irq_subsystem
        lda #<inverted_delay_table
        sta delay_table_addr+0
        lda #>inverted_delay_table
        sta delay_table_addr+1
        rts
.endproc

.proc irq_palette_swap
        ; very quickly read the delay jitter register
        pha                    ; 3
        lda MAP_PPU_IRQ_M2_CNT ; 4
        asl                    ; 2
        sta delay_table_addr+0 ; 3
        ; finish preserving other registers
        txa ; 2
        pha ; 3
        tya ; 2
        pha ; 3
        ; load up the delay pointer and jump there (somewhat inefficiently)
        ldy #0 ; 2
        lda (delay_table_addr), y ; 5
        sta delay_routine_addr+0  ; 3
        iny                       ; 2
        lda (delay_table_addr), y ; 5
        sta delay_routine_addr+1  ; 3
        jmp (delay_routine_addr)  ; 5 + 3 + [inverse of measured IRQ jitter, range: 16 - 0]
return_from_delay:
        ; worst case for the above takes 66 cycles
        ; if we trigger the interrupt on PPU dot 4, then at this exact moment we are at:

        ; ppu dot here: 202

        ; setup to disable rendering and switch palette memory to #$3F00
        lda PPUSTATUS ; 4, ensure w=0
        lda #$3F      ; 2
        ldx #$00      ; 2

        ; ppu dot here: 226
        ; target dot: 311, need to delay: 85 dots, 29 cycles
        .repeat 3 ; 21
        php ; 3
        plp ; 4
        .endrepeat
        .repeat 4 ; 8
        nop ; 2
        .endrepeat

        ; ppu dot here: 313

        stx PPUMASK ; 4, disable rendering, write lands on 322 at the earliest, 334 at the latest (due to DPCM jitter)
        sta PPUADDR ; 4, w=0
        stx PPUADDR ; 4, w=1, set palette address to #$3F00 (no visible change)

        ; ppu dot here: 8

        ; prep the first round of palette updates
        ; TODO: you were here
        ; TODO ALSO: fixed is filling up fast; you need to move some stuff elsewhere

        



.endproc


; optimization note: once we're sure this is working properly, the jitter we need
; to erase can only feasibly span from 1-10 cycles. we could save ~6 cycles by having
; a shorter live section of the table, and using smaller delay amounts
.align 256
inverted_delay_table:
        .addr delay_16 ; 7 cycles for the IRQ service routine
        .addr delay_16
        .addr delay_16
        .addr delay_16
        .addr delay_16
        .addr delay_16
        .addr delay_16

        .addr delay_16 ; 3 cycles to PHA
        .addr delay_16
        .addr delay_16

        .addr delay_16 ; 4 cycles to LDA MAP_PPU_IRQ_M2_CNT
        .addr delay_16
        .addr delay_16
        .addr delay_16

        .addr delay_15 ; first real entry in the table
        .addr delay_14
        .addr delay_13
        .addr delay_12
        .addr delay_11
        .addr delay_10
        .addr delay_9
        .addr delay_8
        .addr delay_7
        .addr delay_6
        .addr delay_5
        .addr delay_4
        .addr delay_3
        .addr delay_2
        .addr delay_0 ; we can't encode a delay amount of 1 cycle, but that's okay

        .repeat (128-7-3-4-15); fill out the rest of the table for safety
        .addr delay_0
        .endrepeat


; various delay amounts, used in the inverted delay table
; not espeically optimal in terms of code size, but at
; the very least, chosen to avoid clobbering any state
.proc delay_0
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_2
        nop ; 2
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_3
        jmp target ; 3
target:
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_4
        .repeat 2
        nop ; 4
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_5
        nop        ; 2
        jmp target ; 3
target:
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_6
        .repeat 3
        nop ; 6
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_7
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_8
        .repeat 4
        nop ; 8
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_9
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc


.proc delay_10
        .repeat 5
        nop ; 10
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_11
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_12
        .repeat 6
        nop ; 12
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_13
        nop ; 2
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_14
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_15
        .repeat 4 ; 8
        nop
        .endrepeat
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc delay_16
        nop ; 2
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc