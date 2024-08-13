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
TablePpuMaskPtr: .res 2
TableIrqHighPtr: .res 2

RasterEffectIndex: .res 1
RasterEffectFrame: .res 1

; very small bit of scratch space, because we
; shouldn't clobber R0-R31
RasterScratch: .res 8

        .segment "PRGRAM"

.align 32
table_scanline_compare: .res 32
table_ppuscroll_x:      .res 32
table_ppuscroll_y:      .res 32
table_ppuaddr_second:   .res 32
table_ppumask:          .res 32
table_irq_high:         .res 32

        .segment "DATA_4"

NORMAL  = $1E
RED     = NORMAL | TINT_R
GREEN   = NORMAL | TINT_G
BLUE    = NORMAL | TINT_B
YELLOW  = NORMAL | TINT_R | TINT_G
CYAN    = NORMAL | TINT_G | TINT_B
MAGENTA = NORMAL | TINT_R | TINT_B
DARK    = NORMAL | TINT_R | TINT_G | TINT_B

; For debugging, mostly. Eventually we want to automate generation
rainbow_scrollx_frame_0:
        .byte 0, 1, 2, 1, 0, $FF, $FE, $FF, 0
rainbow_scrolly_frame_0:
        .byte 0, 16, 32, 48, 64, 80, 96, 112, 176
rainbow_scanline_frame_0:
        .byte 4, 20, 36, 52, 68, 84, 100, 116, 180
rainbow_ppumask_frame_0:
        .byte NORMAL, RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA, DARK, NORMAL
rainbow_irq_frame_0:
        .byte >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq
        .byte >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq, >full_scroll_and_ppumask_irq
        .byte >full_scroll_and_ppumask_irq

rainbow_frame_0:
        .addr rainbow_scrollx_frame_0
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frames:
        .addr rainbow_frame_0

; this is the one we should probably split into tables, if we
; find ourselves needing more than 64 effects. but for now
; this is fine
raster_effects_list:
        .addr rainbow_frames
        .byte <.bank(rainbow_frames) ; frame table bank
        .byte 1 ; duration in frames

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

        lda #0
        sta RasterEffectIndex
        sta RasterEffectFrame

        rts
.endproc

.proc FAR_setup_raster_table_for_frame
FrameListPtr := RasterScratch+0
FramePtr := RasterScratch+2
BankNumber := RasterScratch+4
Duration := RasterScratch+5
        ; First, read the frame list for the currently chosen raster effect
        ldx RasterEffectIndex
        lda raster_effects_list + RasterEffectEntry::FramesListPtr + 0, x
        sta FrameListPtr+0
        lda raster_effects_list + RasterEffectEntry::FramesListPtr + 1, x
        sta FrameListPtr+1
        ; Read in the duration, we'll need this during the copy and it's quickest to grab it here
        lda raster_effects_list + RasterEffectEntry::Duration, x
        sta Duration
        ; Swap in the bank that contains this effect data, quickly and without
        ; using the usual stack mechanism (we'll restore this clobber at the end of NMI)
        rainbow_set_data_bank {raster_effects_list + RasterEffectEntry::BankIndex, x}, #PRG_CHIPSEL_ROM
        ; From the frame list, read in the specific frame that we are on
        lda RasterEffectFrame
        asl
        tay
        lda (FrameListPtr), y
        sta FramePtr
        iny
        lda (FrameListPtr), y
        sta FramePtr
        ; Now copy the table pointers from the frame list
        ldy #0
        lda (FramePtr), y
        sta TablePpuScrollXPtr+0
        iny
        lda (FramePtr), y
        sta TablePpuScrollXPtr+1
        iny
        lda (FramePtr), y
        sta TablePpuScrollYPtr+0
        iny
        lda (FramePtr), y
        sta TablePpuScrollYPtr+1
        iny
        lda (FramePtr), y
        sta TableScanlineCmpPtr+0
        iny
        lda (FramePtr), y
        sta TableScanlineCmpPtr+1
        iny
        lda (FramePtr), y
        sta TablePpuMaskPtr+0
        iny
        lda (FramePtr), y
        sta TablePpuMaskPtr+1
        iny
        lda (FramePtr), y
        sta TableIrqHighPtr+0
        iny
        lda (FramePtr), y
        sta TableIrqHighPtr+1
        ; Before we start the copy, set up the very first IRQ using the first
        ; entry in the table. It may well interrupt the copy, so we need to get ahead of that here
        ldy #0
        lda (TableIrqHighPtr), y
        sta self_modifying_irq+2 ; select the IRQ vector for the very first scanline
        lda (TableScanlineCmpPtr), y
        sta MAP_PPU_IRQ_LATCH    ; select the scanline on which it will fire (probably not 0)
        ; Now we are prepped, and may copy the rest of the table
        jmp copy_raster_table
        ; TAIL CALL
.endproc

; set up the source pointers before calling this
.proc copy_raster_table
Duration := RasterScratch+5
        ldy #0
loop:
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
        iny
        cpy Duration
        bne loop
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
