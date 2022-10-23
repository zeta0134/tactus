        .include "action53.inc"
        .include "bhop/bhop.inc"
        .include "chr.inc"
        .include "compression.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "RAM"
CurrentChrBank: .res 1

.segment "PRG0_8000"
        ; player
        .include "../build/animated_tiles/player.chr"
        ; weapons
        .include "../build/static_tiles/dagger.chr"
        .include "../build/static_tiles/broadsword.chr"
        .include "../build/static_tiles/longsword.chr"
        .include "../build/static_tiles/spear.chr"
        .include "../build/static_tiles/flail.chr"
        ; sprite effects
        .include "../build/animated_tiles/death_skull.chr"

        ; enemies
        .include "../build/animated_tiles/slime_idle.chr"
        .include "../build/animated_tiles/smoke_puff.chr"

        ; static level geometry
        .include "../build/static_tiles/floor.chr"
        .include "../build/static_tiles/disco_floor.chr"
        .include "../build/static_tiles/wall_face.chr"
        .include "../build/static_tiles/wall_top.chr"
        .include "../build/static_tiles/pit_edge.chr"

        ; hud
        .include "../build/static_tiles/empty_heart.chr"
        .include "../build/static_tiles/half_heart.chr"
        .include "../build/static_tiles/full_heart.chr"

hud_font:
        .incbin "../art/raw_chr/font_chicago_reduced.chr"

ANIMATED_TILE_TABLE_LENGTH = 4
animated_tile_table:
        .word $0000, smoke_puff
        .word $0040, slime_idle

        .word $1000, player
        .word $1040, death_skull


STATIC_TILE_TABLE_LENGTH = 14
static_tile_table:
        ; level geometry, ascending
        .word $0800, floor
        .word $0840, disco_floor
        .word $0880, wall_top
        .word $08C0, wall_face
        .word $0900, pit_edge
        .word $0940, floor
        ; hud, descending
        .word $0CC0, full_heart
        .word $0C80, half_heart
        .word $0C40, empty_heart
        ; weapon sprites
        .word $1080, dagger
        .word $10C0, broadsword
        .word $1100, longsword
        .word $1140, spear
        .word $1180, flail


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

.proc decompress_animated_tiles_to_chr_ram
MemcpySourceAddr := R0
DecompressionSourceAddr := R0

MemcpyLength := R2
DecompressionTargetAddr := R2

SpriteTableAddr := R4
SpriteTableLength := R6
SpriteTableIndex := R7

ChrBank := R8
        lda #ANIMATED_TILE_TABLE_LENGTH
        sta SpriteTableLength
        lda #0
        sta SpriteTableIndex
tile_loop:
        ldx SpriteTableIndex
        lda animated_tile_table + 2, x
        sta DecompressionSourceAddr
        lda animated_tile_table + 3, x
        sta DecompressionSourceAddr + 1

        st16 DecompressionTargetAddr, $0200 ; clobber shadow OAM since these are only 256 bytes each
        jsr decompress ; clobbers R0 - R3, R14-R15

        lda #0
        sta ChrBank
bank_loop:
        a53_set_chr ChrBank
        lda #$02
        sta MemcpySourceAddr+1
        lda ChrBank
        .repeat 6
        asl
        .endrepeat
        sta MemcpySourceAddr
        st16 MemcpyLength, 64
        ldx SpriteTableIndex
        lda animated_tile_table + 1, x
        sta PPUADDR
        lda animated_tile_table + 0, x
        sta PPUADDR
        jsr memcpy_ppudata
        inc ChrBank
        lda ChrBank
        cmp #4
        bne bank_loop

        dec SpriteTableLength
        beq done
        lda SpriteTableIndex
        clc
        adc #4
        sta SpriteTableIndex
        jmp tile_loop
done:
        rts
.endproc

.proc decompress_static_tiles_to_chr_ram
MemcpySourceAddr := R0
DecompressionSourceAddr := R0

MemcpyLength := R2
DecompressionTargetAddr := R2

SpriteTableAddr := R4
SpriteTableLength := R6
SpriteTableIndex := R7

ChrBank := R8
        lda #STATIC_TILE_TABLE_LENGTH
        sta SpriteTableLength
        lda #0
        sta SpriteTableIndex
tile_loop:
        ldx SpriteTableIndex
        lda static_tile_table + 2, x
        sta DecompressionSourceAddr
        lda static_tile_table + 3, x
        sta DecompressionSourceAddr + 1

        st16 DecompressionTargetAddr, $0200 ; clobber shadow OAM since these are only 256 bytes each
        jsr decompress ; clobbers R0 - R3, R14-R15

        lda #0
        sta ChrBank
bank_loop:
        a53_set_chr ChrBank
        ; for static tiles, duplicate the decompressed result four times
        st16 MemcpySourceAddr, $0200
        st16 MemcpyLength, 64
        ldx SpriteTableIndex
        lda static_tile_table + 1, x
        sta PPUADDR
        lda static_tile_table + 0, x
        sta PPUADDR
        jsr memcpy_ppudata
        inc ChrBank
        lda ChrBank
        cmp #4
        bne bank_loop

        dec SpriteTableLength
        beq done
        lda SpriteTableIndex
        clc
        adc #4
        sta SpriteTableIndex
        jmp tile_loop
done:
        rts
.endproc

.proc copy_hud_font_to_chr_ram
SourceAddr := R0
Length := R2
ChrBank := R8
        lda #0
        sta ChrBank
bank_loop:
        a53_set_chr ChrBank
        st16 SourceAddr, hud_font
        st16 Length, $0300
        set_ppuaddr #$0D00
        jsr memcpy_ppudata
        inc ChrBank
        lda ChrBank
        cmp #4
        bne bank_loop
        rts
.endproc

.proc FAR_initialize_chr_ram
SourceAddr := R0
Length := R2
        lda #0
        sta PPUCTRL ; disable NMI, set VRAM increment to +1

        ; THING!
        jsr decompress_animated_tiles_to_chr_ram
        jsr decompress_static_tiles_to_chr_ram
        jsr copy_hud_font_to_chr_ram

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

chr_frame_pacing:
        .byte 0, 1, 1, 2, 2, 3, 3, 3

.proc FAR_sync_chr_bank_to_music
        lda row_counter
        and #%00000111
        tax
        lda chr_frame_pacing, x
        sta CurrentChrBank
        rts
.endproc