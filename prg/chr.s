        .include "../build/tile_defs.inc"
        .include "chr.inc"
        .include "far_call.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "CHR_ROM"
        .incbin "../build/output_chr.bin"

.segment "DATA_0"

title_nametable:
        .incbin "../art/raw_nametables/title_screen.nam"

.segment "CODE_2"

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
        lda #$00 ; static tile 0
        sta PPUDATA
        dec16 Length
        lda Length
        ora Length+1
        bne loop
        rts
.endproc

.proc write_nametable
SourceAddr := R0
DestAddr := R2
Length := R4
        st16 Length, $0400
        
        ldy #0
loop:
        perform_zpcm_inc
        lda (SourceAddr), y
        sta (DestAddr), y
        dec16 Length
        inc16 SourceAddr
        inc16 DestAddr
        lda Length
        ora Length+1
        bne loop
        perform_zpcm_inc
        rts
.endproc

.proc FAR_copy_title_nametable
SourceAddr := R0
DestAddr := R2
        access_data_bank #<.bank(title_nametable)

        lda #(VBLANK_NMI | BG_0000 | OBJ_1000)
        sta PPUCTRL ; set VRAM increment to +1

        ; HACK alert:
        ; NMI is not getting touched; copy this to both nametables
        ; redundantly and let whichever one is active be displayed.
        ; It's fine.
        st16 DestAddr, $5000
        st16 SourceAddr, title_nametable
        jsr write_nametable

        st16 DestAddr, $5400
        st16 SourceAddr, title_nametable
        jsr write_nametable

        restore_previous_bank
        rts
.endproc

.proc FAR_set_title_exbg
DestAddrLeft := R0
DestAddrRight := R2
Length := R4

st16 DestAddrLeft, $5800
st16 DestAddrRight, $5C00
st16 Length, $0400
        
        ldy #0
loop:
        perform_zpcm_inc
        lda #CHR_BANK_TITLE
        sta (DestAddrLeft), y
        sta (DestAddrRight), y
        dec16 Length
        inc16 DestAddrLeft
        inc16 DestAddrRight
        lda Length
        ora Length+1
        bne loop
        perform_zpcm_inc
        rts
.endproc

.proc FAR_set_old_chr_exbg
DestAddrLeft := R0
DestAddrRight := R2
Length := R4

st16 DestAddrLeft, $5800
st16 DestAddrRight, $5C00
st16 Length, $0400
        
        ldy #0
loop:
        perform_zpcm_inc
        lda #CHR_BANK_OLD_CHRRAM
        sta (DestAddrLeft), y
        sta (DestAddrRight), y
        dec16 Length
        inc16 DestAddrLeft
        inc16 DestAddrRight
        lda Length
        ora Length+1
        bne loop
        perform_zpcm_inc
        rts
.endproc