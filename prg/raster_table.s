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
RED     = NORMAL | LIGHTGRAY | TINT_R
GREEN   = NORMAL | LIGHTGRAY | TINT_G
BLUE    = NORMAL | LIGHTGRAY | TINT_B
YELLOW  = NORMAL | LIGHTGRAY | TINT_R | TINT_G
CYAN    = NORMAL | LIGHTGRAY | TINT_G | TINT_B
MAGENTA = NORMAL | LIGHTGRAY | TINT_R | TINT_B
DARK    = NORMAL | LIGHTGRAY | TINT_R | TINT_G | TINT_B

; For debugging, mostly. Eventually we want to automate generation
rainbow_scrollx_frame_0:
        .byte 0, 1, 2, 1, 0, $FF, $FE, $FF, 0
rainbow_scrollx_frame_1:
        .byte 1, 2, 1, 0, $FF, $FE, $FF, 0, 0
rainbow_scrollx_frame_2:
        .byte 2, 1, 0, $FF, $FE, $FF, 0, 1, 0
rainbow_scrollx_frame_3:
        .byte 1, 0, $FF, $FE, $FF, 0, 1, 2, 0
rainbow_scrollx_frame_4:
        .byte 0, $FF, $FE, $FF, 0, 1, 2, 1, 0
rainbow_scrollx_frame_5:
        .byte $FF, $FE, $FF, 0, 1, 2, 1, 0, 0
rainbow_scrollx_frame_6:
        .byte $FE, $FF, 0, 1, 2, 1, 0, $FF, 0
rainbow_scrollx_frame_7:
        .byte $FF, 0, 1, 2, 1, 0, $FF, $FE, 0
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

rainbow_frame_1:
        .addr rainbow_scrollx_frame_1
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_2:
        .addr rainbow_scrollx_frame_2
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_3:
        .addr rainbow_scrollx_frame_3
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_4:
        .addr rainbow_scrollx_frame_4
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_5:
        .addr rainbow_scrollx_frame_5
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_6:
        .addr rainbow_scrollx_frame_6
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frame_7:
        .addr rainbow_scrollx_frame_7
        .addr rainbow_scrolly_frame_0
        .addr rainbow_scanline_frame_0
        .addr rainbow_ppumask_frame_0
        .addr rainbow_irq_frame_0

rainbow_frames:
        .addr rainbow_frame_0
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_0)
        .addr rainbow_frame_1
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_1)
        .addr rainbow_frame_2
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_2)
        .addr rainbow_frame_3
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_3)
        .addr rainbow_frame_4
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_4)
        .addr rainbow_frame_5
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_5)
        .addr rainbow_frame_6
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_6)
        .addr rainbow_frame_7
        .byte 9 ; number of scanlines for this effect
        .byte <.bank(rainbow_frame_7)

        .segment "CODE_0"

; this is the one we should probably split into tables, if we
; find ourselves needing more than 64 effects. but for now
; this is fine
raster_effects_list:
        .addr rainbow_frames
        .byte <.bank(rainbow_frames) ; frame table bank
        .byte 8 ; duration in frames

nametable_lut_x:
        .repeat 256, i
        .byte (i >> 3)
        .endrepeat
nametable_lut_y:
        .repeat 256, i
        .byte <((i & $F8) << 2)
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
ScanlineCount := RasterScratch+6
        ; Note: this ends up being called **during** the last scanline of vblank!
        ; We might be able to clean up a liiiitle bit of the code that comes before,
        ; but the timings are extremely close. Be careful!

        lda #0
        sta RasterTableIndex

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
        asl
        tay
        lda (FrameListPtr), y
        sta FramePtr+0
        iny
        lda (FrameListPtr), y
        sta FramePtr+1
        iny
        lda (FrameListPtr), y
        sta ScanlineCount
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
        ; Here we enable IRQs (hopefully we are still in vblank at this point)
        lda #32
        sta MAP_PPU_IRQ_OFFSET
        lda #$FF ; "any value"
        sta MAP_PPU_IRQ_ENABLE
        cli
        ; Now we are prepped, and may copy the rest of the table
        jmp copy_raster_table
        ; TAIL CALL
.endproc

; set up the source pointers before calling this
.proc copy_raster_table
Duration := RasterScratch+5
ScanlineCount := RasterScratch+6
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
        cpy ScanlineCount
        bne loop

        ; advance the animation pointer
        inc RasterEffectFrame
        lda RasterEffectFrame
        cmp Duration
        bne done
        lda #0
        sta RasterEffectFrame
done:

        jmp finalize_irq_table
        ; TAIL CALL
.endproc

.proc finalize_irq_table
        ; for now, just write $FF to the scanline compare for the last entry,
        ; which should disable any further splits.
        ; TODO: this is where we'll append the palette swap and maybe dialog system.
        ; we'll need a way to configure the finalizer depending on game state and UI mode!

        ; Y still holds the final entry in the table, so just reuse it
        lda #$FF
        sta table_scanline_compare, y
        lda #>invalid_irq
        sta table_irq_high, y

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
        lda table_scanline_compare+1, x ; 4
        sta MAP_PPU_IRQ_LATCH         ; 4 (set new cmp value)
        lda MAP_PPU_IRQ_STATUS        ; 4 (acknowledge)

        ; now make the first two scrolling writes that are safe to perform early (12)
        sta PPUADDR                ; 4 (1-screen mirroring: we don't care about the value)
        lda table_ppuscroll_y, x   ; 4
        sta PPUSCROLL              ; 4

        ; set the IRQ function to run on the NEXT scanline here (high byte only)
        ; this also gives us a bit of margin to avoid dot 256-257 more reliably
        lda table_irq_high+1, x     ; 4
        sta self_modifying_irq+2    ; 3

        ; timed so that the first write is AFTER dot 256 or so (24)
        lda table_ppuscroll_x, x    ; 4
        sta PPUSCROLL               ; 4, sets fine_x
        lda table_ppuaddr_second, x ; 4
        sta PPUADDR                 ; 4, fully updates v
        lda table_ppumask, x        ; 4
        sta PPUMASK                 ; 4, sets color emphasis / greyscale

        inc RasterTableIndex

        ; register restoration from zeropage (6)
        lda IrqPreserveA ; 3
        ldx IrqPreserveX ; 3
        
        perform_zpcm_inc ; 6
        rti ; 6
.endproc

.align 256
.proc invalid_irq   ; (7)
        ; this is a crash condition! how did we get here?
        ; in any case, acknowledge cart IRQ and exit
        bit MAP_PPU_IRQ_STATUS        ;
        rti
.endproc