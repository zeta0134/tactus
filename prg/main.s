        .setcpu "6502"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "main.inc"
        .include "memory_util.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "raster_tricks.inc"
        .include "slowam.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "PRGFIXED_E000"

start:
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; Clear out large memory regions (the reset vector handles zp/stack)
        st16 R0, ($0200) ; internal RAM from 0x200 - 0x7FF
        st16 R2, ($0600)
        jsr clear_memory
        st16 R0, ($5000) ; FPGA RAM from 0x5000 - 0x5FFF
        st16 R2, ($1000)
        jsr clear_memory
        st16 R0, ($6000) ; PRG RAM from 0x6000 - 0x7FFF
        st16 R2, ($2000)
        jsr clear_memory

        jsr initialize_palettes
        jsr initialize_ppu
        jsr init_irq_subsystem

        far_call FAR_init_audio
        far_call FAR_init_slowam

        ; disable unusual IRQ sources
        lda #%01000000
        sta $4017 ; APU frame counter
        lda #0
        sta $4010 ; DMC DMA

        ; initialize the prng seed to a nonzero value
        lda #1
        sta seed
        sta fixed_seed

        far_call FAR_init_nametables
        far_call FAR_init_palettes

        ; now enable rendering and proceed to the main game loop
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000)
        sta PPUCTRL

        cli ; enable interrupts


        ; Setup our initial kernel state
        st16 GameMode, init_engine

        ; hand control over to the kernel, which will manage game mode management
        ; for the rest of runtime
        far_call FAR_kernel_game_loop

        ; this should never be reached
panic_and_spin:
        jmp panic_and_spin

