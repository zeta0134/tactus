.include "nes.inc"

.include "action53.inc"
.include "battlefield.inc"
.include "bhop/bhop.inc"
.include "chr.inc"
.include "kernel.inc"
.include "input.inc"
.include "main.inc"
.include "memory_util.inc"
.include "prng.inc"
.include "sound.inc"
.include "vram_buffer.inc"
.include "zeropage.inc"

        .segment "PRGFIXED_C000"

.macro spinwait_for_vblank
.scope
loop:
        bit PPUSTATUS
        bpl loop
.endscope
.endmacro

irq:
        rti

reset:
        sei            ; Disable interrupts
        cld            ; make sure decimal mode is off (not that it does anything)
        ldx #$ff       ; initialize stack
        txs

        jsr init_action53

        ; Wait for the PPU to finish warming up
        spinwait_for_vblank
        spinwait_for_vblank

        ; Initialize zero page and stack
        clear_page $0000
        clear_page $0100

        ; Jump to main
        jmp start


.proc nmi
        bit irq_active
        bpl safe_to_run_nmi
        dec manual_nmi_needed
        rti ; exit immediately; IRQ will continue and call NMI when it is done
safe_to_run_nmi:
        jsr manual_nmi_handler
        rti
.endproc

.proc manual_nmi_handler
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        ; is NMI disabled? if so get outta here fast
        lda NmiSoftDisable
        bne nmi_soft_disable

        bit irq_enabled
        bpl perform_oam_dma
        dec manual_oam_needed ; Perform OAM DMA during the IRQ routine
        ; allow interrupts during nmi as early as possible
        cli
        jmp done_with_oam
perform_oam_dma:
        ; do the sprite thing
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAM_DMA
done_with_oam:

        lda GameloopCounter
        cmp LastNmi
        beq lag_frame

        ; ===========================================================
        ; Tasks which should be guarded by a successful gameloop
        ;   - Running these twice (or in the middle of the gameloop)
        ;     could break things
        ; ===========================================================

        ; Copy buffered PPU bytes into PPU address space, as quickly as possible
        jsr vram_zipper
        ; Update palette memory if required
        ;jsr refresh_palettes
        ; Read controller registers and update button status
        ; This signals to the gameloop that it may continue
        lda GameloopCounter
        sta LastNmi
        jmp all_frames

lag_frame:
        ; If necessary: actions to be performed only on lag frames
        ; (Currently nothing)

all_frames:
        ; ===========================================================
        ; Tasks which MUST be performed every frame
        ;   - Mostly IRQ setup here, if we miss doing this the render
        ;     will glitch pretty badly
        ; ===========================================================

        lda active_battlefield
        eor PpuScrollNametable
        bne right_nametable
left_nametable:
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000 | OBJ_8X16 | NT_2000)
        jmp write_ppuctrl
right_nametable:
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000 | OBJ_8X16 | NT_2400)
write_ppuctrl:
        sta PPUCTRL
       
        ;lda #00
        ;sta PPUSCROLL
        ;sta PPUSCROLL
        lda PpuScrollX
        sta PPUSCROLL
        lda PpuScrollY
        sta PPUSCROLL

        a53_set_chr CurrentChrBank

        ; poll for input *after* setting the scroll position
        jsr poll_input
        ; Advance the global pRNG once every frame
        jsr next_rand

nmi_soft_disable:
        ; because audio can trigger bank switching, here we read and preserve the action53 shadow register
        lda action53_shadow
        pha

        ; Here we *only* update the audio engine, nothing else. This is mostly to
        ; smooth over transitions when loading a new level.
        jsr update_audio

        ; And now we re-write that shadow, just in case
        pla
        sta action53_shadow
        sta A53_REG_SELECT

        ; restore registers
        pla
        tay
        pla
        tax
        pla
        ; all done
        rts
.endproc

.export manual_nmi_handler

; TODO: Pick one of these, probably
.align 64
all_00_byte: .byte $00
.align 64
all_ff_byte: .byte $FF

.export all_00_byte, all_ff_byte

        ; This region is unused, and reserved for potential nesdev-2022 compo purposes
        .org $FFD0
        .res 30 

        ;
        ; Labels nmi/reset/irq are part of prg3_e000.s
        ;
        .segment "VECTORS"
        .addr nmi
        .addr reset
        .addr zetasaw_irq
