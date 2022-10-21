        .setcpu "6502"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "main.inc"
        .include "memory_util.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "PRGFIXED_C000"

start:
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; Clear out main memory regions
        st16 R0, ($0000)
        st16 R2, ($0100)
        jsr clear_memory
        st16 R0, ($0200)
        st16 R2, ($0600)
        jsr clear_memory

        jsr initialize_palettes
        jsr initialize_ppu
        jsr init_audio

        ; disable unusual IRQ sources
        lda #%01000000
        sta $4017 ; APU frame counter
        lda #0
        sta $4010 ; DMC DMA

        ; initialize the prng seed to a nonzero value
        lda #1
        sta seed

        ; copy the initial batch of graphics into CHR RAM
        far_call FAR_initialize_chr_ram
        far_call FAR_init_nametables
        far_call FAR_demo_nametable

        ; now enable rendering and proceed to the main game loop
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL

        cli ; enable interrupts


        ; Setup our initial kernel state
        st16 GameMode, init_engine

        ; hand control over to the kernel, which will manage game mode management
        ; for the rest of runtime
main_loop:
        debug_color LIGHTGRAY
        jsr run_kernel
        jmp main_loop


