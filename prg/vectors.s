.include "nes.inc"

.include "battlefield.inc"
.include "bhop/bhop.inc"
.include "chr.inc"
.include "kernel.inc"
.include "input.inc"
.include "main.inc"
.include "memory_util.inc"
.include "prng.inc"
.include "rainbow.inc"
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

        jsr rainbow_init

        ; Wait for the PPU to finish warming up
        spinwait_for_vblank
        spinwait_for_vblank

        ; Initialize zero page and stack
        clear_page $0000
        clear_page $0100

        ; Jump to main
        jmp start


.proc nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        ; is NMI disabled? if so get outta here fast
        lda NmiSoftDisable
        bne nmi_soft_disable

perform_oam_dma:
        ; do the sprite thing
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAM_DMA

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

        rainbow_set_8k_chr CurrentChrBank

        ; poll for input *after* setting the scroll position
        jsr poll_input
        ; Advance the global pRNG once every frame
        jsr next_rand

nmi_soft_disable:
        ; Here we *only* update the audio engine, nothing else. This is mostly to
        ; smooth over transitions when loading a new level.
        jsr update_audio

        ; restore registers
        pla
        tay
        pla
        tax
        pla
        ; all done
        rti
.endproc

        ;
        ; Labels nmi/reset/irq are part of prg3_e000.s
        ;
        .segment "VECTORS"
        .addr nmi
        .addr reset
        .addr irq
