.include "nes.inc"

.include "../build/tile_defs.inc"

.include "battlefield.inc"
.include "beat_tracker.inc"
.include "bhop/bhop.inc"
.include "chr.inc"
.include "debug.inc"
.include "far_call.inc"
.include "kernel.inc"
.include "input.inc"
.include "main.inc"
.include "memory_util.inc"
.include "palette.inc"
.include "prng.inc"
.include "rainbow.inc"
.include "raster_tricks.inc"
.include "slowam.inc"
.include "sound.inc"
.include "zeropage.inc"
.include "zpcm.inc"

        .segment "PRGFIXED_E000"

.macro spinwait_for_vblank
.scope
loop:
        bit PPUSTATUS
        bpl loop
.endscope
.endmacro

.proc null_irq
        rti
.endproc

.proc reset
        cld            ; make sure decimal mode is off (not that it does anything)
        sei            ; Disable interrupts
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
.endproc

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

        lda GameloopCounter
        cmp LastNmi
        beq lag_frame

        ; ===========================================================
        ; Tasks which should be guarded by a successful gameloop
        ;   - Running these twice (or in the middle of the gameloop)
        ;     could break things
        ; ===========================================================

        ; Slow OAM, which will take nearly all of the budget
        perform_zpcm_inc
        lda #$00
        sta $2003
        ;debug_color (TINT_G | LIGHTGRAY)
        jsr SPRITE_TRANSFER_BASE
        ;debug_color 0
        ; Update palette memory very quickly
        jsr refresh_palettes_nmi        
        ; This signals to the gameloop that it may continue
        lda GameloopCounter
        sta LastNmi
        jmp all_frames

lag_frame:
        ; If necessary: actions to be performed only on lag frames
        
        ; Update palette memory, even on lag frames, because we may
        ; have clobbered it during the raster split (if we are partway
        ; through a palette update and we cause lag, oh well! try not
        ; to do that.)
        jsr refresh_palettes_nmi

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
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000 | OBJ_8X16 | NT_2000)
        jmp write_ppuctrl
right_nametable:
        lda #(VBLANK_NMI | BG_1000 | OBJ_0000 | OBJ_8X16 | NT_2400)
write_ppuctrl:
        sta PPUCTRL
       
        lda PpuScrollX
        sta PPUSCROLL
        lda PpuScrollY
        sta PPUSCROLL

        rainbow_set_upper_bg_chr PlayfieldBgHighBank
        rainbow_set_upper_obj_chr PlayfieldObjHighBank, #SPRITE_REGION_BASE

        ; re-enable rendering (the IRQ may have disabled it, if it ran)
        lda #$1E
        sta PPUMASK

        ; poll for input *after* setting the scroll position
        ; TODO: move this to the game loop
        ;debug_color (TINT_B | LIGHTGRAY)
        jsr poll_input
        ; Advance the gameplay pRNG once every frame
        jsr next_gameplay_rand

        debug_color (TINT_R | LIGHTGRAY)

        ; always run this (whether it does anything meaningful is controlled with a flag)
        jsr setup_irq_during_nmi
        cli ; always enable interrupts; whether they get generated is up to the routine above

nmi_soft_disable:
        ; Here we *only* update the audio engine, nothing else. This is mostly to
        ; smooth over transitions when loading a new level.
        
        ; because bhop will potentially change the current code and data bank,
        ; first preserve them to the stack
        lda code_bank_shadow
        sta NmiCurrentBank ; might as well initialize the NMI call stack with the current bank
        pha
        lda data_bank_low_shadow
        pha
        lda data_bank_high_shadow
        pha

        far_call_nmi FAR_update_audio
        perform_zpcm_inc
        jsr update_beat_tracker
        perform_zpcm_inc

        pla
        sta data_bank_high_shadow
        sta MAP_PRG_A_HI
        pla
        sta data_bank_low_shadow
        sta MAP_PRG_A_LO
        pla
        sta code_bank_shadow
        sta MAP_PRG_8_LO


        ; restore registers
        pla
        tay
        pla
        tax
        pla
        ; all done
        perform_zpcm_inc
        rti
.endproc

        ;
        ; Labels nmi/reset/irq are part of prg3_e000.s
        ;
        .segment "VECTORS"
        .addr nmi
        .addr reset
        .addr irq_palette_swap
