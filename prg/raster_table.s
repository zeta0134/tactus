        .include "../build/tile_defs.inc"

        .include "kernel.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
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
RasterEffectFinalizerIndex: .res 1

; very small bit of scratch space, because we
; shouldn't clobber R0-R31
RasterScratch: .res 8

delay_table_addr: .res 2
delay_routine_addr: .res 2

HudBgActual: .res 1
HudObjActual: .res 1

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
        .byte 0, 1, 2, 1, 0, $FF, $FE, $FF
rainbow_scrollx_frame_1:
        .byte 1, 2, 1, 0, $FF, $FE, $FF, 0
rainbow_scrollx_frame_2:
        .byte 2, 1, 0, $FF, $FE, $FF, 0, 1
rainbow_scrollx_frame_3:
        .byte 1, 0, $FF, $FE, $FF, 0, 1, 2
rainbow_scrollx_frame_4:
        .byte 0, $FF, $FE, $FF, 0, 1, 2, 1
rainbow_scrollx_frame_5:
        .byte $FF, $FE, $FF, 0, 1, 2, 1, 0
rainbow_scrollx_frame_6:
        .byte $FE, $FF, 0, 1, 2, 1, 0, $FF
rainbow_scrollx_frame_7:
        .byte $FF, 0, 1, 2, 1, 0, $FF, $FE
rainbow_scrolly_frame_0:
        .byte 0, 22, 44, 66, 88, 110, 132, 154
rainbow_scanline_frame_0:
        .byte 4, 26, 48, 70, 92, 114, 136, 158
rainbow_ppumask_frame_0:
        .byte NORMAL, NORMAL, NORMAL, NORMAL, NORMAL, NORMAL, NORMAL, NORMAL, NORMAL
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

.macro raster_frame frame_addr, scanlines
        .addr frame_addr
        .byte scanlines ; number of scanlines for this effect
        .byte <.bank(frame_addr)
.endmacro

rainbow_frames:
        raster_frame rainbow_frame_0, 8
        raster_frame rainbow_frame_0, 8
        raster_frame rainbow_frame_1, 8
        raster_frame rainbow_frame_1, 8
        raster_frame rainbow_frame_2, 8
        raster_frame rainbow_frame_2, 8
        raster_frame rainbow_frame_3, 8
        raster_frame rainbow_frame_3, 8
        raster_frame rainbow_frame_4, 8
        raster_frame rainbow_frame_4, 8
        raster_frame rainbow_frame_5, 8
        raster_frame rainbow_frame_5, 8
        raster_frame rainbow_frame_6, 8
        raster_frame rainbow_frame_6, 8
        raster_frame rainbow_frame_7, 8
        raster_frame rainbow_frame_7, 8

        .include "raster/underwater.incs"
        
        .segment "CODE_0"

; this is the one we should probably split into tables, if we
; find ourselves needing more than 64 effects. but for now
; this is fine
raster_effects_list:
        .addr underwater_frames
        .byte <.bank(underwater_frames) ; frame table bank
        .byte 64 ; duration in frames

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
        lda #2
        sta RasterEffectFinalizerIndex

        lda #<inverted_delay_table
        sta delay_table_addr+0
        lda #>inverted_delay_table
        sta delay_table_addr+1

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
FinalizerPtr := RasterScratch+0
        ; for now, just write $FF to the scanline compare for the last entry,
        ; which should disable any further splits.
        ; TODO: this is where we'll append the palette swap and maybe dialog system.
        ; we'll need a way to configure the finalizer depending on game state and UI mode!

        ; Y still holds the final entry in the table, so just reuse it
        ldx RasterEffectFinalizerIndex
        lda finalizer_table+0, x
        sta FinalizerPtr+0
        lda finalizer_table+1, x
        sta FinalizerPtr+1
        jmp (FinalizerPtr)
        ; tail call
.endproc

finalizer_table:
        .addr finalizer_none
        .addr finalizer_hud

; just clears out the very last entry, no additional work needed
.proc finalizer_none
        lda #$FF
        sta table_scanline_compare, y
        lda #>invalid_irq
        sta table_irq_high, y
        rts
.endproc

.proc finalizer_hud
        lda #0
        sta table_ppuscroll_x, y
        lda #176
        sta table_ppuscroll_y, y
        lda #180
        sta table_scanline_compare, y
        lda #>irq_hud_palette_swap
        sta table_irq_high, y
        ; ppumask bit isn't used

        ; do this during NMI, so we don't get a race condition and flickery beat transitions
        lda HudBgHighBank
        sta HudBgActual
        lda HudObjHighBank
        sta HudObjActual

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
.proc irq_hud_palette_swap
        perform_zpcm_inc ; 6
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
        jmp (delay_routine_addr)  ; 5 + 3 + [inverse of measured IRQ jitter, range: 10 - 0]
return_from_delay:
        ; worst case for the above takes 73 cycles
        ; if we trigger the interrupt on PPU dot 4, then at this exact moment we are at:

        ; ppu dot here: 223

        ; setup to disable rendering and switch palette memory to #$3F00
        lda PPUSTATUS ; 4, ensure w=0
        lda #$3F      ; 2 - PPUADDR
        ldx #$00      ; 2
        ldy #$00      ; 2 - PPUMASK

        ; ppu dot here: 253
        ; target dot: 311, 20 cycles
        ;perform_zpcm_inc ; 6
        ;jsr delay_12     ; 12
        ;nop              ; 2

        ; ppu dot here: 313

        sty PPUMASK ; 4, disable rendering, write lands on 322 at the earliest, 334 at the latest (due to DPCM jitter)
        sta PPUADDR ; 4, w=0
        stx PPUADDR ; 4, w=1, set palette address to #$3F00 (no visible change)

        ; ppu dot here: 8
        perform_zpcm_inc
        nop

        ; ppu dot here: 44
        ; wait until hblank (248)

        ; Fix the nametable mappings for the HUD: all in bank 0
        lda #0            ; 2
        sta MAP_NT_A_BANK ; 4
        sta MAP_NT_B_BANK ; 4
        sta MAP_NT_C_BANK ; 4
        sta MAP_NT_D_BANK ; 4
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT) ; 2
        sta MAP_NT_A_CONTROL ; 4
        sta MAP_NT_B_CONTROL ; 4
        sta MAP_NT_C_CONTROL ; 4
        sta MAP_NT_D_CONTROL ; 4

        ; prep the first round of palette updates
        lda HudPaletteBuffer+0 ; 4
        ldx HudPaletteBuffer+1 ; 4
        ldy HudPaletteBuffer+2 ; 4

        ; delay: 68 cycles
        jsr delay_12
        .repeat 6
        nop
        .endrepeat

        ; ppu dot here: 248

        ; write the palette entries for BG0 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudPaletteBuffer+3 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; prep the second round of palette updates
        lda HudPaletteBuffer+4 ; 4
        ldx HudPaletteBuffer+5 ; 4
        ldy HudPaletteBuffer+6 ; 4

        ; ppu dot here: 3

        ; wait until hblank (248)
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20
        nop ; 2

        ; ppu dot here: 249
        ; write the palette entries for BG1 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudPaletteBuffer+7 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 309

        ; prep the third round of palette updates
        lda HudPaletteBuffer+8  ; 4
        ldx HudPaletteBuffer+9  ; 4
        ldy HudPaletteBuffer+10 ; 4

        ; ppu dot here: 4

        ; wait until hblank (248)
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20
        nop ; 2

        ; ppu dot here: 250
        ; write the palette entries for BG2 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudPaletteBuffer+11 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 310

        ; prep the third round of palette updates
        lda HudPaletteBuffer+12  ; 4
        ldx HudPaletteBuffer+13  ; 4
        ldy HudPaletteBuffer+14  ; 4

        ; ppu dot here: 5

        ; wait until hblank (248)
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_12
        php ; 3
        plp ; 4
        nop ; 2

        ; ppu dot here: 248
        ; write the palette entries for BG3 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudPaletteBuffer+15 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; At this point the BG palette is written; for now we will stop here.
        ; We are parked on #$3F10, which mirrors BG0.0, so we can set up to re-enable rendering

        ; Draw the left-side nametable, starting at the top of the HUD graphics
HUD_SCROLL_X = 0
;HUD_SCROLL_Y = 182

;HUD_SCROLL_Y = 175 ; does not cause jitter (does cause a visible glitch)
HUD_SCROLL_Y = 176 ; the value I want, but this causes jitter
;HUD_SCROLL_Y = 177 ; causes neither jitter nor a visible glitch

HUD_NAMETABLE = 0
HUD_FUNNY_2006 = ((((HUD_SCROLL_Y & $F8) << 2) | (HUD_SCROLL_X >> 3)) & $FF)
        lda #HUD_NAMETABLE  ; 2
        sta $2006           ; 4
        lda #HUD_SCROLL_Y   ; 2
        sta $2005           ; 4
        lda #HUD_SCROLL_X   ; 2
        sta $2005           ; 4
        lda #HUD_FUNNY_2006 ; 2
        sta $2006           ; 4

        ; ppu dot here: 39

        ; since we have time to kill, we might as well compute the musical beat and set
        ; the new animation frame right here


        ; old cost: 16
        ;lda currently_playing_row ; 4
        ;and #%00000111            ; 2
        ;tax                       ; 2
        ;lda chr_frame_pacing, x   ; 4
        ;sta MAP_BG_EXT_BANK       ; 4

        ; new cost: 26
        lda HudBgActual         ; 4
        sta MAP_BG_EXT_BANK     ; 4
        lda HudObjActual        ; 4 - %......HL
        ror                     ; 2 - %.......H C:L
        ror                     ; 2 - %L....... C:H
        ror                     ; 2 - %HL......
        and #%11000000          ; 2 (safety)
        ora #SPRITE_REGION_BASE ; 2 (later: replace with HUD sprite base!)
        sta MAP_CHR_0_LO        ; 4

        ; ppu dot here: 117

        ; now we simply wait for hblank (256), then re-enable backgrounds:
        lda #BG_ON ; 2
        jsr delay_12
        jsr delay_12
        jsr delay_12
        .repeat 5 ; 10
        nop
        .endrepeat

        ; ppu dot here: 261
        sta PPUMASK ; 4

        ; and again, wait another *entire* scanline, so that we can re-enable
        ; sprites (since this scanline will have corrupted sprite evalutation)
        lda #(BG_ON | OBJ_ON) ; 2

        ; ppu dot here: 279
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20
        nop
        nop
        nop

        ; ppu dot here: 256
        sta PPUMASK

        ; END timing sensitive code
        ; cleanup and we're done!
        sta MAP_PPU_IRQ_DISABLE

        ; restore registers and return
        pla
        tay
        pla
        tax
        pla
        perform_zpcm_inc
        rti
.endproc

.proc delay_12 ; 6
        rts    ; 6
.endproc

.proc delay_20 ; 6
        perform_zpcm_inc ; 6
        nop    ; 2
        rts    ; 6
.endproc

; optimization note: once we're sure this is working properly, the jitter we need
; to erase can only feasibly span from 1-10 cycles. we could save ~6 cycles by having
; a shorter live section of the table, and using smaller delay amounts
.align 256
inverted_delay_table:
        .addr inv_delay_10 ; 7 cycles for the IRQ service routine
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10

        .addr inv_delay_10 ; 6 cycles for inc $4011
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10

        .addr inv_delay_10 ; 3 cycles to PHA
        .addr inv_delay_10
        .addr inv_delay_10

        .addr inv_delay_10 ; 4 cycles to LDA MAP_PPU_IRQ_M2_CNT
        .addr inv_delay_10
        .addr inv_delay_10
        .addr inv_delay_10 ; READ OCCURS HERE

        .addr inv_delay_10 ; first real entry in the table
        .addr inv_delay_9
        .addr inv_delay_8
        .addr inv_delay_7
        .addr inv_delay_6
        .addr inv_delay_5
        .addr inv_delay_4
        .addr inv_delay_3
        .addr inv_delay_2
        .addr inv_delay_0 ; we can't encode a delay amount of 1 cycle, but that's okay

        .repeat (128-7-6-3-4-10); fill out the rest of the table for safety
        .addr inv_delay_0
        .endrepeat


; various delay amounts, used in the inverted delay table
; not espeically optimal in terms of code size, but at
; the very least, chosen to avoid clobbering any state
.proc inv_delay_0
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_2
        nop ; 2
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_3
        jmp target ; 3
target:
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_4
        .repeat 2
        nop ; 4
        .endrepeat
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_5
        nop        ; 2
        jmp target ; 3
target:
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_6
        .repeat 3
        nop ; 6
        .endrepeat
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_7
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_8
        .repeat 4
        nop ; 8
        .endrepeat
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_9
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc


.proc inv_delay_10
        .repeat 5
        nop ; 10
        .endrepeat
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_11
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_12
        .repeat 6
        nop ; 12
        .endrepeat
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_13
        nop ; 2
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_14
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_15
        .repeat 4 ; 8
        nop
        .endrepeat
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.proc inv_delay_16
        nop ; 2
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap::return_from_delay
.endproc

.align 256
.proc invalid_irq   ; (7)
        ; this is a crash condition! how did we get here?
        ; in any case, acknowledge cart IRQ and exit
        bit MAP_PPU_IRQ_STATUS        ;
        rti
.endproc