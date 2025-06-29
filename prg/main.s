        .setcpu "6502"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "dynamic_palette.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "main.inc"
        .include "memory_util.inc"
        .include "nes.inc"
        .include "pal.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "raster_table.inc"
        .include "rta_timer.inc"
        .include "slowam.inc"
        .include "sound.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.zeropage

DesiredPpuCtrl: .res 1

.segment "PRGFIXED_E000"

.proc quickly_clear_palettes
        ; Set OBJ and BG palettes to all black
        set_ppuaddr #$3F00
        lda #$0F
        ldx #0
palette_loop:
        sta PPUDATA
        inx
        cpx #32
        bne palette_loop
        rts
.endproc

start:
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; Quickly copy in a blank palette, just so we have something
        ; that isn't the default boot color
        jsr quickly_clear_palettes

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

        jsr detect_system_type
        jsr detect_ppu_type

        jsr init_far_calls

        far_call FAR_init_dynamic_palettes
        far_call FAR_initialize_palettes
        far_call FAR_initialize_ppu

        far_call FAR_init_audio
        far_call FAR_init_slowam

        ; disable unusual IRQ sources
        lda #%01000000
        sta $4017 ; APU frame counter
        lda #0
        sta $4010 ; DMC DMA

        jsr initialize_prng

        far_call FAR_initialize_irq_table
        far_call FAR_initialize_rta_timers
        ; now it should be safe to enable interrupts, in theory
        cli

        ; now enable rendering and proceed to the main game loop
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000 | OBJ_8X16 | NT_2000)
        sta DesiredPpuCtrl
        sta PPUCTRL

        ; Setup our initial kernel state
        st16 GameMode, init_engine

        ; hand control over to the kernel, which will manage game mode management
        ; for the rest of runtime
        far_call FAR_kernel_game_loop

        ; this should never be reached
panic_and_spin:
        jmp panic_and_spin

