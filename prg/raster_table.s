        .include "raster_table.inc"
        .include "nes.inc"
        .include "rainbow.inc"
        .include "zpcm.inc"

        .zeropage

; faster than the stack, and more convenient too
IrqPreserveA: .res 1
IrqPreserveX: .res 1
ScrollXOffset: .res 1
ScrollYOffset: .res 1

RasterTableIndex: .res 1

self_modifying_irq: .res 3


TableScanlineCmpPtr: .res 2
TablePpuScrollXPtr: .res 2
TablePpuScrollYPtr: .res 2
TablePpuAddrSecondPtr: .res 2  ; we're gonna try computing this on the fly!
TablePpuMaskPtr: .res 2
TableIrqHighPtr: .res 2

        .segment "PRGRAM"

.align 32
table_scanline_compare: .res 32
table_ppuscroll_x:      .res 32
table_ppuscroll_y:      .res 32
table_ppuaddr_second:   .res 32
table_ppumask:          .res 32
table_irq_high:         .res 32

        .segment "CODE_0"

nametable_lut_x:
        .repeat 256, i
        .byte (i >> 3)
        .endrepeat
nametable_lut_y:
        .repeat 256, i
        .byte <((i & $F8) << 3)
        .endrepeat
scroll_y_wraparound_lut:
        .repeat 176, i
        .byte i
        .endrepeat
        .repeat 40, i
        .byte i
        .endrepeat
        .repeat 40, i
        .byte (136 + i)
        .endrepeat

.proc FAR_initialize_irq_table
        lda #$4C               ; JMP opcode
        sta self_modifying_irq+0
        lda #<full_scroll_and_ppumask_irq ; should be $00 consistently
        sta self_modifying_irq+1
        lda #<full_scroll_and_ppumask_irq ; will change based on which vector we should run next
        sta self_modifying_irq+2
        rts
.endproc

; set up the source pointers before calling this
.proc copy_raster_table
        ldy #0
loop:
        ; naive: put all the data in a big precomputed table, no screen shake
        lda (TableScanlineCmpPtr), y    ; 5
        sta table_scanline_compare, y   ; 5
        lda (TablePpuScrollXPtr), y     ; 5
        sta table_ppuscroll_x, y        ; 5
        lda (TablePpuScrollYPtr), y     ; 5
        sta table_ppuscroll_y, y        ; 5
        lda (TablePpuAddrSecondPtr), y  ; 5
        sta table_ppuaddr_second, y     ; 5
        lda (TablePpuMaskPtr), y        ; 5
        sta table_ppumask, y            ; 5
        lda (TableIrqHighPtr), y        ; 5
        sta table_irq_high, y           ; 5
        ; total to copy one scanline in: 60 cycles (!)

        ; comparison:
        ; insane: one fully unrolled routine for the whole damn copy, still no screen shake:
        lda #0                       ; 2
        sta table_ppuscroll_x+0      ; 4
        lda #0                       ; 2
        sta table_ppuscroll_y+0      ; 4
        lda #0                       ; 2
        sta table_ppuaddr_second+0   ; 4
        lda #0                       ; 2
        sta table_irq_high+0         ; 4
        lda #0                       ; 2
        sta table_scanline_compare+0 ; 4
        lda #0                       ; 2
        sta table_ppumask+0          ; 4
        ; total: 36 cycles, saving min 24 cycles per scanline (plus pointer setup and loop overhead)

        ; now with screen shake! it's... a bit expensive, but at least only the playfield scanlines need this?
        ; note that we can bake this down to lda scroll_x_offset any time the constant is 0, to save time and data
        lda #0                         ; 2
        clc                            ; 2
        adc ScrollXOffset              ; 3
        sta table_ppuscroll_x+0        ; 4
        tax                            ; 2
        lda #0                         ; 2
        clc                            ; 2
        adc ScrollYOffset              ; 3
        tay                            ; 2
        lda scroll_y_wraparound_lut, y ; 4
        sta table_ppuscroll_y+0        ; 4
        tay                            ; 2
        lda nametable_lut_y, y         ; 4
        ora nametable_lut_x, x         ; 4
        sta table_ppuaddr_second+0     ; 4
        ; total so far: 42 cycles
        lda #0                       ; 2
        sta table_irq_high+0         ; 4
        lda #0                       ; 2
        sta table_scanline_compare+0 ; 4
        lda #0                       ; 2
        sta table_ppumask+0          ; 4
        ; grand total: 62 cycles
        ; ... not bad really.

        ; for comparison, let's try the less stupid, but slower version
        lda (TablePpuScrollXPtr), y    ; 5
        clc                            ; 2
        adc ScrollXOffset              ; 3
        sta table_ppuscroll_x, y       ; 5
        lda (TablePpuScrollYPtr), y    ; 5
        clc                            ; 2
        adc ScrollYOffset              ; 3
        tax                            ; 2
        lda scroll_y_wraparound_lut, x ; 4
        sta table_ppuscroll_y, y       ; 5
        tax                            ; 2
        lda nametable_lut_y, x         ; 4
        ldx table_ppuscroll_x, y       ; 4
        ora nametable_lut_x, x         ; 4
        sta table_ppuaddr_second, y    ; 4
        ; total so far: 54 cycles
        lda (TableScanlineCmpPtr), y    ; 5
        sta table_scanline_compare, y   ; 5
        lda (TablePpuMaskPtr), y        ; 5
        sta table_ppumask, y            ; 5
        lda (TableIrqHighPtr), y        ; 5
        sta table_irq_high, y           ; 5
        ; grand total: 84 cycles
        ; ... not bad really.





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

        ; now make the first two scrolling writes that are safe to perform early (12)
        sta PPUADDR                ; 4 (1-screen mirroring: we don't care about the value)
        lda table_ppuscroll_y, x   ; 4
        sta PPUSCROLL              ; 4

        ; timed so that the first write is AFTER dot 256 or so (24)
        lda table_ppuscroll_x, x    ; 4
        sta PPUSCROLL               ; 4, sets fine_x
        lda table_ppuaddr_second, x ; 4
        sta PPUADDR                 ; 4, fully updates v
        lda table_ppumask, x        ; 4
        sta PPUMASK                 ; 4, sets color emphasis / greyscale

        ; cleanup, etc (12)
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