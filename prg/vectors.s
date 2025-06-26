.macpack longbranch

.include "nes.inc"

.include "../build/tile_defs.inc"

.include "_globals.inc"

.include "battlefield.inc"
.include "beat_tracker.inc"
.include "bhop/bhop.inc"
.include "chr.inc"
.include "debug.inc"
.include "dynamic_palette.inc"
.include "far_call.inc"
.include "kernel.inc"
.include "input.inc"
.include "main.inc"
.include "memory_util.inc"
.include "prng.inc"
.include "rainbow.inc"
.include "raster_table.inc"
.include "slowam.inc"
.include "sound.inc"
.include "zeropage.inc"
.include "zpcm.inc"

        .segment "PRGFIXED_E000"

.macro spinwait_for_vblank
.scope
loop:
        nop
        bit PPUSTATUS
        bpl loop
.endscope
.endmacro

.proc null_irq
        rti
.endproc

.proc reset
        inc NmiSoftDisable ; no! (earliest possible nonzero)

        sei            ; Disable interrupts
        cld            ; make sure decimal mode is off (not that it does anything)
        ldx #$ff       ; initialize stack
        txs

        lda #1
        sta NmiSoftDisable ; no really! (set it to the sane expected value)

        jsr rainbow_init

        ; Silence 2A03 audio early
        lda #0
        sta $4015

        ; Wait for the PPU to finish warming up
        spinwait_for_vblank
        spinwait_for_vblank

        ; Disable NMI properly
        lda #0
        sta PPUCTRL

        ; Initialize zero page and stack (which clears NmiSoftDisable)
        clear_page $0000
        clear_page $0100

        ; Jump to main
        jmp start
.endproc

.proc nmi
        perform_zpcm_inc
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        ; is NMI disabled? if so get outta here fast
        lda NmiSoftDisable
        jne nmi_soft_disable

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
        ;lda #$00
        ;sta $2003
        ;jsr SPRITE_TRANSFER_BASE
        ;jmp all_frames (currently not needed)
lag_frame:
        ; If necessary: actions to be performed only on lag frames        
all_frames:
        ; Update palette memory, even on lag frames, because we may
        ; have clobbered it during the raster split (if we are partway
        ; through a palette update and we cause lag, oh well! try not
        ; to do that.)
        INLINE_refresh_palettes_nmi
        ; ===========================================================
        ; Tasks which MUST be performed every frame
        ;   - Mostly IRQ setup here, if we miss doing this the render
        ;     will glitch pretty badly
        ; ===========================================================

        ; scroll nametable doesn't matter, so we're really just setting
        ; up consistent rendering primitives here in case they were clobbered
        ; during loading or something
        lda DesiredPpuCtrl
        sta PPUCTRL

        ; Set the one (1) upper background register
        rainbow_set_upper_bg_chr PlayfieldBgHighBank
        
        ; for sprites, set all (all) 16 sprite registers, including their
        ; current animation frame. yay, 176 cycles!
        ; TODO: see if we can't break this up into high priority, low priority
        ; blocks, to move some of this logic out of actual vblank. we are in a
        ; race condition against the start of raster splits, after all
        .repeat 4, i
        lda PlayfieldObjBanks+i  ; 4
        ora PlayerObjHighBank    ; 3
        sta MAP_CHR_0_LO + i     ; 4
        .endrepeat
        .repeat 12, i
        lda PlayfieldObjBanks+4+i  ; 4
        ora PlayfieldBgObjHighBank ; 3
        sta MAP_CHR_0_LO + 4 + i   ; 4
        .endrepeat

        ; re-enable rendering (the IRQ may have disabled it, if it ran)
        ; note: sans backgrounds! we'll turn those on with a raster effect later
        lda #(OBJ_ON | BG_OFF)
        sta PPUMASK

        ; TODO: can we make this not a far call? it'll save quite a lot of cycles
        ;far_call_nmi FAR_setup_raster_table_for_frame
        lda #<((.bank(FAR_setup_raster_table_for_frame) & __BANK_MASK__) | __BANK_OFFSET__)
        sta MAP_PRG_8_LO
        jsr FAR_setup_raster_table_for_frame

        ; This signals to the gameloop that it may continue
        lda GameloopCounter
        sta LastNmi

        debug_color (TINT_R | LIGHTGRAY)

nmi_soft_disable:
        ; Here we *only* update the audio engine, nothing else. This is mostly to
        ; smooth over transitions when loading a new level.

        ; because far calls will potentially change the current code and data bank,
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
        
        ; why are we running this a second time?
        ; ... this is LOAD BEARING? Zeta why!?
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

irq_none:
        rti

        ;
        ; Labels nmi/reset/irq are part of prg3_e000.s
        ;
        .segment "VECTORS"
        .addr nmi
        .addr reset        
        .addr self_modifying_irq
