        .include "raster_table.inc"
        .include "nes.inc"
        .include "rainbow.inc"
        .include "zpcm.inc"

        .zeropage

; faster than the stack, and more convenient too
IrqPreserveA: .res 1
IrqPreserveX: .res 1

RasterTableIndex: .res 1

self_modifying_irq: .res 3

        .segment "PRGRAM"

.align 64
table_scanline_compare: .res 64
table_ppuscroll_x: .res 64
table_ppuscroll_y: .res 64
table_ppuaddr_first: .res 64
table_ppuaddr_second: .res 64
table_ppumask: .res 64
table_irq_high: .res 64

        .segment "CODE_0"
        
.proc FAR_initialize_irq_table
        lda #$4C               ; JMP opcode
        sta self_modifying_irq+0
        lda #<full_scroll_and_ppumask_irq ; should be $00 consistently
        sta self_modifying_irq+1
        lda #<full_scroll_and_ppumask_irq ; will change based on which vector we should run next
        sta self_modifying_irq+2
        rts
.endproc

        .segment "PRGFIXED_E000"

.align 256
.proc full_scroll_and_ppumask_irq   ; (7)
        perform_zpcm_inc ; (6)
        ; register preservation to zeropage (6)
        sta IrqPreserveA ; 3
        stx IrqPreserveX ; 3

        ; BEFORE the end of the scanline (mostly) (3)
        ldx RasterTableIndex     ; 3

        ; first, acknowledge the IRQ and set up for the next one (12)
        lda table_scanline_compare, x ; 4
        sta MAP_PPU_IRQ_LATCH         ; 4 (set new cmp value)
        lda MAP_PPU_IRQ_STATUS        ; 4 (acknowledge)

        ; now make the first two scrolling writes that are safe to perform early (16)
        lda table_ppuaddr_first, x ; 4
        sta PPUADDR                ; 4
        lda table_ppuscroll_y, x   ; 4
        sta PPUSCROLL              ; 4

        ; timed so that the first write is AFTER dot 256 or so (24)
        lda table_ppuscroll_x, x    ; 4
        sta PPUSCROLL               ; 4, sets fine_x
        lda table_ppuaddr_second, x ; 4
        sta PPUADDR                 ; 4, fully updates v
        lda table_ppumask, x        ; 4
        sta PPUMASK                 ; 4, sets color emphasis / greyscale

        ; cleanup, etc (5)
        inx                      ; 2
        ; set the IRQ function to run on the NEXT scanline here (high byte only)
        lda table_irq_high, x    ; 4
        sta self_modifying_irq+2 ; 3
        stx RasterTableIndex     ; 3

        ; register restoration from zeropage (6)
        lda IrqPreserveA ; 3
        ldx IrqPreserveX ; 3
        perform_zpcm_inc ; 6
        rti ; 6
.endproc