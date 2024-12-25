        .include "../build/tile_defs.inc"
        .include "_globals.inc"

        .include "dialog.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "pal.inc"
        .include "palette.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "zpcm.inc"

        .zeropage

; faster than the stack, and more convenient too
IrqPreserveA: .res 1
IrqPreserveX: .res 1
;ScrollXOffset: .res 1
ScrollYOffset: .res 1

RasterTableIndex: .res 1
RasterLoopPoint: .res 1

self_modifying_irq: .res 3

TableScanlineCmpPtr: .res 2
TablePpuScrollXPtr: .res 2
TablePpuScrollYPtr: .res 2
TablePpuMaskPtr: .res 2
TableIrqHighPtr: .res 2

RasterEffectIndex: .res 1
RasterEffectFrame: .res 1
RasterEffectFractionalFrame: .res 1
RasterEffectFinalizerIndex: .res 1

; very small bit of scratch space, because we
; shouldn't clobber R0-R31
RasterScratch: .res 8

delay_table_addr_ntsc: .res 2
delay_table_addr_pal: .res 2
delay_routine_addr: .res 2

HudBgActual: .res 1
HudObjActual: .res 1

LeftNametableBank: .res 1
RightNametableBank: .res 1
LeftNametableAttr: .res 1
RightNametableAttr: .res 1

HudNametable: .res 1
HudAttr: .res 1

        .segment "PRGRAM"

.align 32
table_scanline_compare: .res 32
table_ppuscroll_x:      .res 32
table_ppuscroll_y:      .res 32
table_ppuaddr_second:   .res 32
table_ppumask:          .res 32
table_irq_high:         .res 32
; For raster effects to point to as a source for data to copy
; This is how we change the global ppumask for room-specific
; color emphasis and other effects. Be sure it is initialized
; to (and ORA'd with) $1E or the raster system may break entirely!
room_global_ppumask:    .res 32

RasterPlaybackSpeedHigh: .res 1
RasterPlaybackSpeedLow: .res 1


        .segment "DATA_4"

        .include "raster/options.incs"
        .include "raster/none.incs"
        .include "raster/screen_slide.incs"
        .include "raster/underwater.incs"
        .include "raster/vertical_shift.incs"

        .segment "DATA_2"

        .include "raster/heat.incs"

        .segment "CODE_1"

; this is the one we should probably split into tables, if we
; find ourselves needing more than 64 effects. but for now
; this is fine
raster_effects_list:
        .addr none_frames
        .byte <.bank(none_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr underwater_frames
        .byte <.bank(underwater_frames) ; frame table bank
        .byte 64 ; duration in frames
        .addr slide_right_frames
        .byte <.bank(slide_right_frames) ; frame table bank
        .byte 31 ; duration in frames
        .addr slide_left_frames
        .byte <.bank(slide_left_frames) ; frame table bank
        .byte 31 ; duration in frames
        .addr slide_down_frames
        .byte <.bank(slide_down_frames) ; frame table bank
        .byte 31 ; duration in frames
        .addr slide_up_frames
        .byte <.bank(slide_up_frames) ; frame table bank
        .byte 31 ; duration in frames
        .addr minus_1_frames
        .byte <.bank(minus_1_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr minus_2_frames
        .byte <.bank(minus_2_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr minus_3_frames
        .byte <.bank(minus_3_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr minus_4_frames
        .byte <.bank(minus_4_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr plus_1_frames
        .byte <.bank(plus_1_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr plus_2_frames
        .byte <.bank(plus_2_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr plus_3_frames
        .byte <.bank(plus_3_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr options_frames
        .byte <.bank(options_frames) ; frame table bank
        .byte 1 ; duration in frames
        .addr heat_frames
        .byte <.bank(heat_frames) ; frame table bank
        .byte 128 ; duration in frames

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
        lda #<invalid_irq ; should be $00 consistently
        sta self_modifying_irq+1
        lda #<invalid_irq ; will change based on which vector we should run next
        sta self_modifying_irq+2

        lda #0
        sta RasterEffectIndex
        lda #2
        sta RasterEffectFinalizerIndex
        lda #0
        sta RasterLoopPoint
        sta RasterEffectFrame

        lda #1
        sta RasterPlaybackSpeedHigh
        lda #0
        sta RasterPlaybackSpeedLow
        sta RasterEffectFractionalFrame

        lda #<inverted_delay_table_ntsc
        sta delay_table_addr_ntsc+0
        lda #>inverted_delay_table_ntsc
        sta delay_table_addr_ntsc+1
        lda #<inverted_delay_table_pal
        sta delay_table_addr_pal+0
        lda #>inverted_delay_table_pal
        sta delay_table_addr_pal+1
        ; for initial safety, fill out the IRQ table with valid IRQ vectors
        ; none of the real vectors are truly problematic if called at a bad time (they'll exit eventually)
        ; but $0000 is unfortunate!
        perform_zpcm_inc
        .repeat 32, i
        sta table_irq_high+i
        .endrepeat
        perform_zpcm_inc

        lda #0
        sta LeftNametableBank
        sta RightNametableBank
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)        
        sta LeftNametableAttr
        sta RightNametableAttr

        lda #0
        near_call FAR_apply_room_global_color_emphasis

        perform_zpcm_inc

        rts
.endproc

; Desired color emphasis bits in A
; (we'll ORA with the other flags as needed)
.proc FAR_apply_room_global_color_emphasis
        ; TODO: if we're going to disable emphasis effects with an option,
        ; do it right here!
        ; TODO: if we're running on PAL we need to xor the emphasis bits
        ; to fix the wrong coloration!

        ; First for safety, mask the input byte
        ; to include only the color emphasis properties
        and #(TINT_R|TINT_G|TINT_B|LIGHTGRAY)
        ; now set the rendering enable bits
        ora #(BG_ON|OBJ_ON)

        ; and finally, write this into place. we can be a little
        ; slow here for size reasons, this won't be called all
        ; that often
        ldy #0
loop:
        sta room_global_ppumask, y
        iny
        cpy #32
        bne loop

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

        perform_zpcm_inc

        ; first, setup global properties for the top of the frame. this is before vblank
        ; ends
        lda LeftNametableBank
        sta MAP_NT_A_BANK
        sta MAP_NT_C_BANK
        lda RightNametableBank
        sta MAP_NT_B_BANK
        sta MAP_NT_D_BANK
        lda LeftNametableAttr
        sta MAP_NT_A_CONTROL
        sta MAP_NT_C_CONTROL
        lda RightNametableAttr
        sta MAP_NT_B_CONTROL
        sta MAP_NT_D_CONTROL

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
        rainbow_set_data_bank_noshadow {raster_effects_list + RasterEffectEntry::BankIndex, x}, #PRG_CHIPSEL_ROM
        ; From the frame list, read in the specific frame that we are on
        lda RasterEffectFrame
        asl
        bcc no_double_inc
        inc FrameListPtr+1
        inc FrameListPtr+1
no_double_inc:
        asl
        bcc no_inc
        inc FrameListPtr+1
no_inc:
        tay
        lda (FrameListPtr), y
        sta FramePtr+0
        iny
        lda (FrameListPtr), y
        sta FramePtr+1
        iny
        lda (FrameListPtr), y
        sta ScanlineCount
        perform_zpcm_inc
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
        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq pal_offset
nstc_offset:
        lda #32
        sta MAP_PPU_IRQ_OFFSET
        jmp done_with_offset
pal_offset:
        lda #20
        sta MAP_PPU_IRQ_OFFSET
done_with_offset:
        lda #$FF ; "any value"
        sta MAP_PPU_IRQ_ENABLE
        cli
        perform_zpcm_inc
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
        perform_zpcm_inc
        ; for comparison, let's try the less stupid, but slower version
        lda (TablePpuScrollXPtr), y    ; 5
        clc                            ; 2
        adc ScreenShakeX               ; 3
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
        clc
        lda RasterPlaybackSpeedLow
        adc RasterEffectFractionalFrame
        sta RasterEffectFractionalFrame
        lda RasterPlaybackSpeedHigh
        adc RasterEffectFrame
        sta RasterEffectFrame

        lda RasterEffectFrame
        cmp Duration
        bcc done
        lda RasterLoopPoint
        sta RasterEffectFrame
done:
        perform_zpcm_inc

        jmp finalize_irq_table
        ; TAIL CALL
.endproc

.proc finalize_irq_table
FinalizerPtr := RasterScratch+0
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
; Note: Y still holds the final entry in the table
.proc finalizer_none
        lda #$FF
        sta table_scanline_compare, y
        lda #>invalid_irq
        sta table_irq_high, y
        perform_zpcm_inc
        rts
.endproc

.proc finalizer_hud
        lda DialogHeight
        beq finalizer_hud_alone
        jmp finalizer_hud_with_dialog
        ; bye!
.endproc

; Note: Y still holds the final entry in the table
.proc finalizer_hud_alone
        lda #0
        sta table_ppuscroll_x, y
        lda #176
        sta table_ppuscroll_y, y
        lda #180
        sta table_scanline_compare, y

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_routine
use_ntsc_routine:
        lda #>irq_hud_palette_swap_ntsc
        sta table_irq_high, y
        jmp done_picking_routine
use_pal_routine:
        lda #>irq_hud_palette_swap_pal
        sta table_irq_high, y
done_picking_routine:

        lda #(BG_ON | OBJ_ON)
        sta table_ppumask, y

        ; do this during NMI, so we don't get a race condition and flickery beat transitions
        lda HudBgHighBank
        sta HudBgActual
        lda HudObjHighBank
        sta HudObjActual

        lda #0
        sta HudNametable
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT)
        sta HudAttr

        ; We don't use any splits after this, but we're going to have the palette swap
        ; set them up anyway, so make sure our last split is unreachable / no effect
        iny
        jsr finalizer_none

        perform_zpcm_inc
        rts
.endproc

; Note: Y still holds the final entry in the table
.proc finalizer_hud_with_dialog
TargetY := RasterScratch+0
        lda #180
        sec
        sbc DialogHeight
        sta TargetY
        jsr remove_entries_after_target_y
        ; setup the palette swap on this scanline
        lda #0
        sta table_ppuscroll_x, y
        lda #176
        sta table_ppuscroll_y, y
        lda TargetY
        sta table_scanline_compare, y

        lda system_type
        cmp #SYSTEM_TYPE_PAL
        beq use_pal_routine
use_ntsc_routine:
        lda #>irq_hud_palette_swap_ntsc
        sta table_irq_high, y
        jmp done_picking_routine
use_pal_routine:
        lda #>irq_hud_palette_swap_pal
        sta table_irq_high, y
done_picking_routine:

        ; no sprites over the dialog region
        ; (we turn them on manually later with a different finalizer)
        lda #(BG_ON)
        sta table_ppumask, y

        ; do this during NMI, so we don't get a race condition and flickery beat transitions
        lda HudBgHighBank
        sta HudBgActual
        lda HudObjHighBank
        sta HudObjActual

        lda #1
        sta HudNametable
        lda #(NT_FPGA_RAM | NT_EXT_BANK_3 | NT_EXT_BG_AT)
        sta HudAttr

        ; Now, when rendering is re-enabled the scanline counter starts at 0 again
        ; so our first split to re-enable the HUD needs to come after DialogHeight
        ; scanlines have been drawn. do that here
        iny
        lda DialogHeight
        sta table_scanline_compare, y
        lda #0
        sta table_ppuscroll_x, y
        lda #177
        sta table_ppuscroll_y, y
        lda #((((177 & $F8) << 2) | (0 >> 3)) & $FF)
        sta table_ppuaddr_second, y
        lda #>full_scroll_and_ppumask_irq
        sta table_irq_high, y
        ; We're still on the dialog nametable, so have ppumask disable backgrounds for one scanline
        lda #(OBJ_ON)
        sta table_ppumask, y

        ; The last split in the table needs to fix the nametable and enable bg rendering, so
        ; the HUD graphics can display properly. This is always +1 from the previous split
        iny
        lda DialogHeight
        clc
        adc #1
        sta table_scanline_compare, y
        lda #>dialog_to_hud_finalizer_irq
        sta table_irq_high, y
        ; the final split doesn't use any of the other settings, and disables IRQ, so
        ; we should be finished. yay?

        perform_zpcm_inc
        rts
.endproc

.proc remove_entries_after_target_y
TargetY := RasterScratch+0
        ; Y holds what would be our target scanline
        ; if the previous   
loop:
        ; if at any point Y becomes 0, we are done
        cpy #0
        beq done
        ; if the scanline above us is LESS than TargetY, we are done
        lda table_scanline_compare - 1, y
        cmp TargetY
        bcc done
        ; otherwise, delete this scanline and keep searching
        dey
        jmp loop
done:
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
.proc left_nametable_split_irq   ; (7)
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
        lda #$00                     ; 2 (left nametable)
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
.proc right_nametable_split_irq   ; (7)
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
        lda #$04                     ; 2 (left nametable)
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
.proc irq_hud_palette_swap_ntsc
        perform_zpcm_inc ; 6
        ; very quickly read the delay jitter register
        pha                    ; 3
        lda MAP_PPU_IRQ_M2_CNT ; 4
        asl                    ; 2
        sta delay_table_addr_ntsc+0 ; 3
        ; finish preserving other registers
        txa ; 2
        pha ; 3
        tya ; 2
        pha ; 3
        ; load up the delay pointer and jump there (somewhat inefficiently)
        ldy #0 ; 2
        lda (delay_table_addr_ntsc), y ; 5
        sta delay_routine_addr+0  ; 3
        iny                       ; 2
        lda (delay_table_addr_ntsc), y ; 5
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

        ; Fix the nametable mappings for the HUD
        lda HudNametable  ; 3
        sta MAP_NT_A_BANK ; 4
        sta MAP_NT_B_BANK ; 4
        sta MAP_NT_C_BANK ; 4
        sta MAP_NT_D_BANK ; 4
        lda HudAttr ; 3
        sta MAP_NT_A_CONTROL ; 4
        sta MAP_NT_B_CONTROL ; 4
        sta MAP_NT_C_CONTROL ; 4
        sta MAP_NT_D_CONTROL ; 4

        ; prep the first round of palette updates
        lda HudStagingPalette+0 ; 4
        ldx HudStagingPalette+1 ; 4
        ldy HudStagingPalette+2 ; 4

        ; delay: 22 cycles
        jsr delay_12
        .repeat 5
        nop
        .endrepeat

        ; ppu dot here: 248

        ; write the palette entries for BG0 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+3 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; prep the second round of palette updates
        lda HudStagingPalette+4 ; 4
        ldx HudStagingPalette+5 ; 4
        ldy HudStagingPalette+6 ; 4

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
        lda HudStagingPalette+7 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 309

        ; prep the third round of palette updates
        lda HudStagingPalette+8  ; 4
        ldx HudStagingPalette+9  ; 4
        ldy HudStagingPalette+10 ; 4

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
        lda HudStagingPalette+11 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 310

        ; hud obj first quarter: write our chosen banks into CHR at $0000
        ; adjusted for the desired animation timing
        .repeat 4, i ; 44
        lda HudObjBanks+i  ; 4
        ora HudObjActual   ; 3
        sta MAP_CHR_0_LO+i ; 4
        .endrepeat

        ; prep the third round of palette updates
        lda HudStagingPalette+12  ; 4
        ldx HudStagingPalette+13  ; 4
        ldy HudStagingPalette+14  ; 4

        ; ppu dot here: 5

        ; wait until hblank (248)
        ; total: 37
        jsr delay_12
        jsr delay_12
        php ; 3
        plp ; 4
        .repeat 3 ; 6
        nop ; 2
        .endrepeat

        ; ppu dot here: 248
        ; write the palette entries for BG3 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+15 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; hud obj second quarter: write our chosen banks into CHR at $0800
        ; adjusted for the desired animation timing
        .repeat 4, i ; 44
        lda HudObjBanks+4+i  ; 4
        ora HudObjActual     ; 3
        sta MAP_CHR_0_LO+4+i ; 4
        .endrepeat

        ; prep the fourth round of palette updates
        lda HudStagingPalette+16  ; 4
        ldx HudStagingPalette+17  ; 4
        ldy HudStagingPalette+18  ; 4

        ; ppu dot here: 3

        ; wait until hblank (251)
        ; total: 38
        jsr delay_20
        jsr delay_12
        .repeat 3 ; (6)
        nop
        .endrepeat

        ; ppu dot here: 249
        ; write the palette entries for OBJ0 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+19 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 309

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

        ; set the animated BG bank for the HUD here

        ; cost: 8
        lda HudBgActual         ; 4 
        sta MAP_BG_EXT_BANK     ; 4

        ; set the animated OBJ banks for the HUD? (might not have time)

        ; hud obj second half: write all blank banks to CHR at $1000
        ; we don't need these, and they're used to render the first 3
        ; BG slivers after the split, which we always want to be 
        ; completely empty
        .repeat 8, i ; 48
        lda #>SPRITE_000_BLANK_NOTHING ; 2
        sta MAP_CHR_0_LO+8+i           ; 4
        .endrepeat

        ; new delay: 15
        php ; 3
        plp ; 4
        .repeat 4 ; 8
        nop
        .endrepeat

        lda #BG_ON ; 2

        ; ppu dot here: 261
        sta PPUMASK ; 4

        ; and again, wait another *entire* scanline, so that we can re-enable
        ; sprites (since this scanline will have corrupted sprite evalutation)
        ldx RasterTableIndex ; 3
        lda table_ppumask, x ; 4

        ; ppu dot here: 279
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20

        ; new: 21
        jsr delay_12
        php ; 3
        plp ; 4
        nop ; 2

        ; previously: 26
        ;jsr delay_20
        ;nop
        ;nop
        ;nop

        ; ppu dot here: 256
        sta PPUMASK

        ; END timing sensitive code
        ; cleanup and we're done!

        ;acknowledge the IRQ and set up for the next one (12)
        ldx RasterTableIndex
        lda table_scanline_compare+1, x
        sta MAP_PPU_IRQ_LATCH         ; (set new cmp value)
        lda MAP_PPU_IRQ_STATUS        ; (acknowledge)
        lda table_irq_high+1, x     
        sta self_modifying_irq+2    
        inc RasterTableIndex

        ; restore registers and return
        pla
        tay
        pla
        tax
        pla
        perform_zpcm_inc
        rti
.endproc

.align 256 
.proc irq_hud_palette_swap_pal
        perform_zpcm_inc ; 6
        ; very quickly read the delay jitter register
        pha                    ; 3
        lda MAP_PPU_IRQ_M2_CNT ; 4
        asl                    ; 2
        sta delay_table_addr_pal+0 ; 3
        ; finish preserving other registers
        txa ; 2
        pha ; 3
        tya ; 2
        pha ; 3
        ; load up the delay pointer and jump there (somewhat inefficiently)
        ldy #0 ; 2
        lda (delay_table_addr_pal), y ; 5
        sta delay_routine_addr+0  ; 3
        iny                       ; 2
        lda (delay_table_addr_pal), y ; 5
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
        lda HudNametable  ; 3
        sta MAP_NT_A_BANK ; 4
        sta MAP_NT_B_BANK ; 4
        sta MAP_NT_C_BANK ; 4
        sta MAP_NT_D_BANK ; 4
        lda HudAttr ; 3
        sta MAP_NT_A_CONTROL ; 4
        sta MAP_NT_B_CONTROL ; 4
        sta MAP_NT_C_CONTROL ; 4
        sta MAP_NT_D_CONTROL ; 4

        ; prep the first round of palette updates
        lda HudStagingPalette+0 ; 4
        ldx HudStagingPalette+1 ; 4
        ldy HudStagingPalette+2 ; 4

        ; delay: 68 cycles

        ; NTSC: was 24 cycles
        ; PAL: should be 20 cycles (-4 for nicer alignment)
        jsr delay_12
        .repeat 3
        nop
        .endrepeat

        ; ppu dot here: 248

        ; write the palette entries for BG0 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+3 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; prep the second round of palette updates
        lda HudStagingPalette+4 ; 4
        ldx HudStagingPalette+5 ; 4
        ldy HudStagingPalette+6 ; 4

        ; ppu dot here: 3

        ; wait until hblank (248)
        ; NTSC: was 82
        ; PAL: should be 75
        jsr delay_20
        jsr delay_20
        jsr delay_20
        php ; 3
        plp ; 4
        .repeat 4
        nop
        .endrepeat

        ; ppu dot here: 249
        ; write the palette entries for BG1 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+7 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 309

        ; hud obj first quarter: write our chosen banks into CHR at $0000
        ; adjusted for the desired animation timing
        .repeat 4, i ; 44
        lda HudObjBanks+i  ; 4
        ora HudObjActual   ; 3
        sta MAP_CHR_0_LO+i ; 4
        .endrepeat

        ; prep the third round of palette updates
        lda HudStagingPalette+8  ; 4
        ldx HudStagingPalette+9  ; 4
        ldy HudStagingPalette+10 ; 4

        ; ppu dot here: 4

        ; wait until hblank (248)

        ; PAL: 31
        jsr delay_20
        php ; 3
        plp ; 4
        .repeat 2
        nop
        .endrepeat

        ; ppu dot here: 250
        ; write the palette entries for BG2 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+11 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 310

        ; prep the third round of palette updates
        lda HudStagingPalette+12  ; 4
        ldx HudStagingPalette+13  ; 4
        ldy HudStagingPalette+14  ; 4

        ; ppu dot here: 5

        ; wait until hblank (248)
        ; NTSC: was 81
        ; PAL: should be 74
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_12
        nop ; 2

        ; ppu dot here: 248
        ; write the palette entries for BG3 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+15 ; 4
        sta PPUDATA ; 4

        ; ppu dot here: 308

        ; hud obj second quarter: write our chosen banks into CHR at $0800
        ; adjusted for the desired animation timing
        .repeat 4, i ; 44
        lda HudObjBanks+4+i  ; 4
        ora HudObjActual     ; 3
        sta MAP_CHR_0_LO+4+i ; 4
        .endrepeat

        ; prep the fourth round of palette updates
        lda HudStagingPalette+16  ; 4
        ldx HudStagingPalette+17  ; 4
        ldy HudStagingPalette+18  ; 4

        ; ppu dot here: 3

        ; wait until hblank (248)
        ; PAL: 31
        jsr delay_20
        php ; 3
        plp ; 4
        .repeat 2
        nop
        .endrepeat

        ; ppu dot here: 248
        ; write the palette entries for BG3 0-3
        sta PPUDATA ; 4
        stx PPUDATA ; 4
        sty PPUDATA ; 4
        lda HudStagingPalette+19 ; 4
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

        ; new cost: 8
        lda HudBgActual         ; 4
        sta MAP_BG_EXT_BANK     ; 4

        ; hud obj second half: write all blank banks to CHR at $1000
        ; we don't need these, and they're used to render the first 3
        ; BG slivers after the split, which we always want to be 
        ; completely empty
        .repeat 8, i ; 48
        lda #>SPRITE_000_BLANK_NOTHING ; 2
        sta MAP_CHR_0_LO+8+i           ; 4
        .endrepeat

        ; to remove: 25
        ;lda HudObjActual        ; 3 - %......HL
        ;ror                     ; 2 - %.......H C:L
        ;ror                     ; 2 - %L....... C:H
        ;ror                     ; 2 - %HL......
        ;and #%11000000          ; 2 (safety)
        ;ora #CHR_BANK_ZONES_OBJ ; 2 (later: replace with HUD sprite base!)
        ;sta MAP_CHR_0_LO        ; 4
        ;and #%11000000          ; 2
        ;ora #CHR_BANK_HUD       ; 2 (also used to draw background tiles for 3 visible slivers!)
        ;sta MAP_CHR_1_LO        ; 4

        ; ppu dot here: 117

        ; now we simply wait for hblank (256), then re-enable backgrounds:
        ; PAL: should be 8
        .repeat 4
        nop
        .endrepeat

        lda #BG_ON ; 2
        ; ppu dot here: 261
        sta PPUMASK ; 4

        ; and again, wait another *entire* scanline, so that we can re-enable
        ; sprites (since this scanline will have corrupted sprite evalutation)
        ldx RasterTableIndex ; 3
        lda table_ppumask, x ; 4

        ; ppu dot here: 279
        ; NTSC: was 106

        ; PAL: should be 99
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_20
        jsr delay_12
        nop

        ; ppu dot here: 256
        sta PPUMASK

        ; END timing sensitive code
        ; cleanup and we're done!

        ;acknowledge the IRQ and set up for the next one (12)
        ldx RasterTableIndex
        lda table_scanline_compare+1, x ; 4
        sta MAP_PPU_IRQ_LATCH         ; 4 (set new cmp value)
        lda MAP_PPU_IRQ_STATUS        ; 4 (acknowledge)
        lda table_irq_high+1, x     ; 4
        sta self_modifying_irq+2    ; 3
        inc RasterTableIndex

        ; restore registers and return
        pla
        tay
        pla
        tax
        pla
        perform_zpcm_inc
        rti
.endproc

.align 256 
.proc dialog_to_hud_finalizer_irq
        perform_zpcm_inc ; (6)
        ; register preservation to zeropage (6)
        sta IrqPreserveA ; 3
        stx IrqPreserveX ; 3

        ; fix the nametables to point back to the HUD region
        lda #0  ; 2
        sta MAP_NT_A_BANK ; 4
        sta MAP_NT_B_BANK ; 4
        sta MAP_NT_C_BANK ; 4
        sta MAP_NT_D_BANK ; 4
        lda #(NT_FPGA_RAM | NT_EXT_BANK_2 | NT_EXT_BG_AT) ; 2
        sta MAP_NT_A_CONTROL ; 4
        sta MAP_NT_B_CONTROL ; 4
        sta MAP_NT_C_CONTROL ; 4
        sta MAP_NT_D_CONTROL ; 4

        ; turn backgrounds back on
        lda #(BG_ON | OBJ_ON)
        sta PPUMASK

        ; this is always the last split, so disable IRQs entirely
        sta MAP_PPU_IRQ_DISABLE

        lda IrqPreserveA ; 3
        ldx IrqPreserveX ; 3
        perform_zpcm_inc ; (6)
        rti
.endproc

.align 256 
; mostly used by various options screens, JUST applies hud-style banking
.proc hud_chr_banks_only_irq
        perform_zpcm_inc ; (6)
        ; register preservation to zeropage (6)
        sta IrqPreserveA ; 3
        stx IrqPreserveX ; 3

        ; BEFORE the end of the scanline (mostly) (3)
        ldx RasterTableIndex     ; 3

        ; first, acknowledge the IRQ and set up for the next one (12)
        lda table_scanline_compare+1, x ; 4
        sta MAP_PPU_IRQ_LATCH           ; 4 (set new cmp value)
        lda MAP_PPU_IRQ_STATUS          ; 4 (acknowledge)

        jsr delay_20

        ; Apply the hud animation bank, and do little else
        ; (use the real value because it is synced well enough)
        lda HudBgHighBank       ; 4
        sta MAP_BG_EXT_BANK     ; 4

        inc RasterTableIndex ; ... 5?

        lda IrqPreserveA ; 3
        ldx IrqPreserveX ; 3
        perform_zpcm_inc ; (6)
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
inverted_delay_table_ntsc:
        .addr inv_delay_10_ntsc ; 7 cycles for the IRQ service routine
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc ; 3 cycles for the JMP abs
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc ; 6 cycles for inc $4011
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc ; 3 cycles to PHA
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc ; 4 cycles to LDA MAP_PPU_IRQ_M2_CNT
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc
        .addr inv_delay_10_ntsc ; READ OCCURS HERE ?
        .addr inv_delay_10_ntsc ; first real entry in the table
        .addr inv_delay_9_ntsc
        .addr inv_delay_8_ntsc
        .addr inv_delay_7_ntsc
        .addr inv_delay_6_ntsc
        .addr inv_delay_5_ntsc
        .addr inv_delay_4_ntsc
        .addr inv_delay_3_ntsc
        .addr inv_delay_2_ntsc
        .addr inv_delay_0_ntsc ; we can't encode a delay amount of 1 cycle, but that's okay

        .repeat (128-7-3-6-3-4-10); fill out the rest of the table for safety
        .addr inv_delay_0_ntsc
        .endrepeat


; various delay amounts, used in the inverted delay table
; not espeically optimal in terms of code size, but at
; the very least, chosen to avoid clobbering any state
.proc inv_delay_0_ntsc
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_2_ntsc
        nop ; 2
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_3_ntsc
        jmp target ; 3
target:
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_4_ntsc
        .repeat 2
        nop ; 4
        .endrepeat
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_5_ntsc
        nop        ; 2
        jmp target ; 3
target:
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_6_ntsc
        .repeat 3
        nop ; 6
        .endrepeat
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_7_ntsc
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_8_ntsc
        .repeat 4
        nop ; 8
        .endrepeat
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

.proc inv_delay_9_ntsc
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc


.proc inv_delay_10_ntsc
        .repeat 5
        nop ; 10
        .endrepeat
        jmp irq_hud_palette_swap_ntsc::return_from_delay
.endproc

; optimization note: once we're sure this is working properly, the jitter we need
; to erase can only feasibly span from 1-10 cycles. we could save ~6 cycles by having
; a shorter live section of the table, and using smaller delay amounts
.align 256
inverted_delay_table_pal:
        ; $00
        .addr inv_delay_10_pal ; 7 cycles for the IRQ service routine
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal ; 3 cycles for the JMP abs
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal ; 6 cycles for inc $4011
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        ; $10
        .addr inv_delay_10_pal ; 3 cycles to PHA
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal ; 4 cycles to LDA MAP_PPU_IRQ_M2_CNT
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal
        .addr inv_delay_10_pal ; READ OCCURS HERE ?
        .addr inv_delay_10_pal ; first real entry in the table
        .addr inv_delay_9_pal
        .addr inv_delay_8_pal
        .addr inv_delay_7_pal
        .addr inv_delay_6_pal
        .addr inv_delay_5_pal
        .addr inv_delay_4_pal
        .addr inv_delay_3_pal
        .addr inv_delay_2_pal
        .addr inv_delay_0_pal ; we can't encode a delay amount of 1 cycle, but that's okay

        .repeat (128-7-3-6-3-4-10); fill out the rest of the table for safety
        .addr inv_delay_0_pal
        .endrepeat


; various delay amounts, used in the inverted delay table
; not espeically optimal in terms of code size, but at
; the very least, chosen to avoid clobbering any state
.proc inv_delay_0_pal
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_2_pal
        nop ; 2
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_3_pal
        jmp target ; 3
target:
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_4_pal
        .repeat 2
        nop ; 4
        .endrepeat
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_5_pal
        nop        ; 2
        jmp target ; 3
target:
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_6_pal
        .repeat 3
        nop ; 6
        .endrepeat
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_7_pal
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_8_pal
        .repeat 4
        nop ; 8
        .endrepeat
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.proc inv_delay_9_pal
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc


.proc inv_delay_10_pal
        .repeat 5
        nop ; 10
        .endrepeat
        jmp irq_hud_palette_swap_pal::return_from_delay
.endproc

.align 256
.proc invalid_irq   ; (7)
        ; this is a crash condition! how did we get here?
        ; in any case, acknowledge cart IRQ and exit
        bit MAP_PPU_IRQ_STATUS        ;
        rti
.endproc