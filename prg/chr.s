        .include "chr.inc"
        .include "compression.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"
CurrentChrBank: .res 1

.segment "CHR_ROM"
        .incbin "../build/output_chr.bin"

.segment "DATA_0"

title_nametable:
        .incbin "../art/raw_nametables/title_screen.nam"

.segment "CODE_0"

; note: set PPUADDR and PPUCTRL appropriately before calling
.proc memcpy_ppudata
SourceAddr := R0
Length := R2
        ldy #0
loop:
        perform_zpcm_inc
        lda (SourceAddr), y
        sta PPUDATA
        inc16 SourceAddr
        dec16 Length
        lda Length
        ora Length+1
        bne loop
        rts
.endproc

.proc FAR_init_nametables
Length := R0
        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL ; set VRAM increment to +1
        st16 Length, $0800
        set_ppuaddr #$2000
loop:
        perform_zpcm_inc
        lda #$80 ; static tile 0
        sta PPUDATA
        dec16 Length
        lda Length
        ora Length+1
        bne loop
        rts
.endproc

.proc write_nametable
DataAddr := R0
Length := R2
        st16 Length, $0400
        
        ldy #0
loop:
        perform_zpcm_inc
        lda (DataAddr), y ; static tile 0
        sta PPUDATA
        dec16 Length
        inc16 DataAddr
        lda Length
        ora Length+1
        bne loop
        perform_zpcm_inc
        rts
.endproc

.proc FAR_copy_title_nametable
DataAddr := R0
        access_data_bank #<.bank(title_nametable)

        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL ; set VRAM increment to +1

        ; HACK alert:
        ; NMI is not getting touched; copy this to both nametables
        ; redundantly and let whichever one is active be displayed.
        ; It's fine.
        set_ppuaddr #$2000
        st16 DataAddr, title_nametable
        jsr write_nametable

        set_ppuaddr #$2400
        st16 DataAddr, title_nametable
        jsr write_nametable

        restore_previous_bank
        rts
.endproc

chr_frame_pacing:
        .byte 0, 1, 1, 2, 2, 3, 3, 3

.proc FAR_sync_chr_bank_to_music
        lda DisplayedRowCounter
        and #%00000111
        tax
        lda chr_frame_pacing, x
        sta CurrentChrBank
        rts
.endproc