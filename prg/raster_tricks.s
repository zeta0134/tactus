.include "nes.inc"

.include "bhop/bhop.inc"
.include "chr.inc"
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

; this bit might get more complicated later XD
raster_tricks_enabled: .res 1

        .segment "PRGFIXED_E000"

.proc init_irq_subsystem
        lda #<inverted_delay_table
        sta delay_table_addr+0
        lda #>inverted_delay_table
        sta delay_table_addr+1

        lda #1
        sta raster_tricks_enabled

        rts
.endproc

.proc setup_irq_during_nmi
        lda raster_tricks_enabled
        beq disabled

        lda #176
        sta MAP_PPU_IRQ_LATCH
        lda #0
        sta MAP_PPU_IRQ_OFFSET
        lda #$FF ; "any value"
        sta MAP_PPU_IRQ_ENABLE  

disabled:
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
        ; worst case for the above takes 73 cycles
        ; if we trigger the interrupt on PPU dot 4, then at this exact moment we are at:

        ; ppu dot here: 223

        ; setup to disable rendering and switch palette memory to #$3F00
        lda PPUSTATUS ; 4, ensure w=0
        lda #$3F      ; 2
        ldx #$00      ; 2
        ldy #(LIGHTGRAY) ; 2

        ; ppu dot here: 247
        ; target dot: 311, need to delay: 64 dots, 22 cycles
        jsr delay_20

        ; ppu dot here: 313

        sty PPUMASK ; 4, disable rendering, write lands on 322 at the earliest, 334 at the latest (due to DPCM jitter)
        sta PPUADDR ; 4, w=0
        stx PPUADDR ; 4, w=1, set palette address to #$3F00 (no visible change)

        ; ppu dot here: 8

        ; prep the first round of palette updates
        
        lda HudPaletteBuffer+0 ; 4
        ldx HudPaletteBuffer+1 ; 4
        ldy HudPaletteBuffer+2 ; 4

        ; ppu dot here: 44
        ; wait until hblank (248)

        ; delay: 68 cycles
        jsr delay_20
        jsr delay_20
        jsr delay_20
        .repeat 4
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
HUD_SCROLL_Y = 194
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
        lda row_counter         ; 4
        and #%00000111          ; 2
        tax                     ; 2
        lda chr_frame_pacing, x ; 4
        sta MAP_BG_EXT_BANK     ; 4

        ; ppu dot here: 87

        ; now we simply wait for hblank (256), then re-enable backgrounds:
        lda #BG_ON ; 2
        jsr delay_20
        jsr delay_20
        jsr delay_12
        nop ; 2
        nop ; 2

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
        rti
.endproc

.proc delay_12 ; 6
        rts    ; 6
.endproc

.proc delay_20 ; 6
        .repeat 4
        nop    ; 2
        .endrepeat
        rts    ; 6
.endproc


; optimization note: once we're sure this is working properly, the jitter we need
; to erase can only feasibly span from 1-10 cycles. we could save ~6 cycles by having
; a shorter live section of the table, and using smaller delay amounts
.align 256
inverted_delay_table:
        .addr inv_delay_16 ; 7 cycles for the IRQ service routine
        .addr inv_delay_16
        .addr inv_delay_16
        .addr inv_delay_16
        .addr inv_delay_16
        .addr inv_delay_16
        .addr inv_delay_16

        .addr inv_delay_16 ; 3 cycles to PHA
        .addr inv_delay_16
        .addr inv_delay_16

        .addr inv_delay_16 ; 4 cycles to LDA MAP_PPU_IRQ_M2_CNT
        .addr inv_delay_16
        .addr inv_delay_16
        .addr inv_delay_16 ; READ OCCURS HERE

        .addr inv_delay_15 ; first real entry in the table
        .addr inv_delay_14
        .addr inv_delay_13
        .addr inv_delay_12
        .addr inv_delay_11
        .addr inv_delay_10
        .addr inv_delay_9
        .addr inv_delay_8
        .addr inv_delay_7
        .addr inv_delay_6
        .addr inv_delay_5
        .addr inv_delay_4
        .addr inv_delay_3
        .addr inv_delay_2
        .addr inv_delay_0 ; we can't encode a delay amount of 1 cycle, but that's okay

        .repeat (128-7-3-4-15); fill out the rest of the table for safety
        .addr inv_delay_0
        .endrepeat


; various delay amounts, used in the inverted delay table
; not espeically optimal in terms of code size, but at
; the very least, chosen to avoid clobbering any state
.proc inv_delay_0
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_2
        nop ; 2
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_3
        jmp target ; 3
target:
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_4
        .repeat 2
        nop ; 4
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_5
        nop        ; 2
        jmp target ; 3
target:
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_6
        .repeat 3
        nop ; 6
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_7
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_8
        .repeat 4
        nop ; 8
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_9
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc


.proc inv_delay_10
        .repeat 5
        nop ; 10
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_11
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_12
        .repeat 6
        nop ; 12
        .endrepeat
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_13
        nop ; 2
        nop ; 2
        nop ; 2
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_14
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_15
        .repeat 4 ; 8
        nop
        .endrepeat
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc

.proc inv_delay_16
        nop ; 2
        php ; 3
        plp ; 4
        php ; 3
        plp ; 4
        jmp irq_palette_swap::return_from_delay
.endproc