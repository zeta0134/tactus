        .include "action53.inc"
        .include "bhop/bhop.inc"
        .include "chr.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"
CurrentChrBank: .res 1

.segment "PRG0_8000"

enemy_frame_0:
        .incbin "../art/raw_chr/enemies_frame0.chr"
enemy_frame_1:
        .incbin "../art/raw_chr/enemies_frame1.chr"
enemy_frame_2:
        .incbin "../art/raw_chr/enemies_frame2.chr"
enemy_frame_3:
        .incbin "../art/raw_chr/enemies_frame3.chr"

static_bg_tiles:
        .incbin "../art/raw_chr/static_bg_tiles.chr"

; note: set PPUADDR and PPUCTRL appropriately before calling
.proc memcpy_ppudata
SourceAddr := R0
Length := R2
        ldy #0
loop:
        lda (SourceAddr), y
        sta PPUDATA
        inc16 SourceAddr
        dec16 Length
        lda Length
        ora Length+1
        bne loop
        rts
.endproc

.proc FAR_initialize_chr_ram
SourceAddr := R0
Length := R2
CurrentStaticBank := R4
        lda #0
        sta PPUCTRL ; disable NMI, set VRAM increment to +1

        a53_set_chr #0
        st16 SourceAddr, enemy_frame_0
        st16 Length, $0800
        set_ppuaddr #$0000
        jsr memcpy_ppudata

        a53_set_chr #1
        st16 SourceAddr, enemy_frame_1
        st16 Length, $0800
        set_ppuaddr #$0000
        jsr memcpy_ppudata

        a53_set_chr #2
        st16 SourceAddr, enemy_frame_2
        st16 Length, $0800
        set_ppuaddr #$0000
        jsr memcpy_ppudata

        a53_set_chr #3
        st16 SourceAddr, enemy_frame_3
        st16 Length, $0800
        set_ppuaddr #$0000
        jsr memcpy_ppudata

        lda #0
        sta CurrentStaticBank
loop:
        a53_set_chr CurrentStaticBank
        st16 SourceAddr, static_bg_tiles
        st16 Length, $0800
        set_ppuaddr #$0800
        jsr memcpy_ppudata
        inc CurrentStaticBank
        lda CurrentStaticBank
        cmp #4
        bne loop

        a53_set_chr #0
        lda #0
        sta CurrentChrBank

        rts
.endproc

.proc FAR_init_nametables
Length := R0
        lda #0
        sta PPUCTRL ; disable NMI, set VRAM increment to +1
        st16 Length, $0800
        set_ppuaddr #$2000
loop:
        lda #$80 ; static tile 0
        sta PPUDATA
        dec16 Length
        lda Length
        ora Length+1
        bne loop
        rts
.endproc

; Until we have real playfield drawing, put any test tile drawing stuff here.
; Remember to remove this later.
.proc FAR_demo_nametable
        lda #0
        sta PPUCTRL ; disable NMI, set VRAM increment to +1        
        set_ppuaddr #($2000 + (32 * 8) + 8)
        lda #0
        sta PPUDATA
        lda #1
        sta PPUDATA
        set_ppuaddr #($2000 + (32 * 9) + 8)
        lda #16
        sta PPUDATA
        lda #17
        sta PPUDATA
        rts
.endproc

chr_frame_pacing:
        .byte 0, 0, 0, 1, 1, 2, 2, 3

.proc FAR_sync_chr_bank_to_music
        lda row_counter
        and #%00000111
        tax
        lda chr_frame_pacing, x
        sta CurrentChrBank
        rts
.endproc