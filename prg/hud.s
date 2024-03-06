        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"
HudState: .res 2

.segment "CODE_0"

HUD_TOP_BORDER_ROW_LEFT    = $52E2
HUD_TOPMOST_ROW_LEFT       = $5302
HUD_UPPER_ROW_LEFT         = $5342
HUD_MIDDLE_ROW_LEFT        = $5362
HUD_LOWER_ROW_LEFT         = $5322
HUD_LOWER_BORDER_ROW_LEFT  = $52E2

HUD_TOP_BORDER_ROW_RIGHT   = $57E2
HUD_TOPMOST_ROW_RIGHT      = $5702
HUD_UPPER_ROW_RIGHT        = $5742
HUD_MIDDLE_ROW_RIGHT       = $5762
HUD_LOWER_ROW_RIGHT        = $5722
HUD_LOWER_BORDER_ROW_RIGHT = $57E2

HUD_ATTR_OFFSET = $0800

HEART_FULL_TILE     = 204
HEART_HALF_TILE     = 200
HEART_EMPTY_TILE    = 196
BLANK_TILE          = 250
MAP_ICON_UNEXPLORED = 192
MAP_ICON_SPECIAL    = 193
MAP_ICON_EXPLORED   = 194
MAP_ICON_CURRENT    = 195

WORLD_PAL  = %00000000 | CHR_BANK_OLD_CHRRAM
TEXT_PAL   = %01000000 | CHR_BANK_OLD_CHRRAM ; text and blue are the same, the blue palette will
BLUE_PAL   = %01000000 | CHR_BANK_OLD_CHRRAM ; always contain white in slot 3 for simple UI elements
YELLOW_PAL = %10000000 | CHR_BANK_OLD_CHRRAM
RED_PAL    = %11000000 | CHR_BANK_OLD_CHRRAM

weapon_palette_table:
        .byte %00, %01, %10, %11

; Called once when entering the main gameplay mode. Called
; again each time this mode is entered from another mode.
; Let's assume it may be called multiple times in a given
; play session.
.proc FAR_init_hud
        st16 HudState, hud_state_init
        rts
.endproc

; Called just after the player has finished their update, on
; the first frame of a given beat. Use this to update any state
; related to the player's most recent activities
.proc FAR_refresh_hud
        rts
.endproc

; Called once on every frame. Mostly use this to draw the HUD and
; operate its per-frame timings for animations.
.proc FAR_queue_hud
        jmp (HudState)
.endproc

; States!

.proc hud_state_init
        ; For now, do NOTHING!
        rts
.endproc




; OLD CODE BELOW!!



; This is here mostly because it relies on the string drawing functions
nametable_2000_string: .asciiz "NAMETABLE AT $2000"
nametable_2400_string: .asciiz "NAMETABLE AT $2400"

.proc FAR_debug_nametable_header
StringPtr := R0
NametableAddr := R12
AttributeAddr := R14
        st16 NametableAddr, $5020
        st16 AttributeAddr, $5820
        st16 StringPtr, nametable_2000_string
        ldy #0
        jsr draw_string

        st16 NametableAddr, $5420
        st16 AttributeAddr, $5C20
        st16 StringPtr, nametable_2400_string
        ldy #0
        jsr draw_string

        rts
.endproc

.proc draw_padding
PaddingAmount := R0

NametableAddr := R12
AttributeAddr := R14

        lda PaddingAmount
        beq skip
loop:
        perform_zpcm_inc
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny
        dec PaddingAmount
        bne loop
skip:
        rts
.endproc

.proc draw_string
StringPtr := R0
VramIndex := R2

NametableAddr := R12
AttributeAddr := R14

        sty VramIndex ; preserve
loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        ldy VramIndex
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        inc VramIndex
        inc16 StringPtr
        jmp loop
end_of_string:
        ldy VramIndex
        rts
.endproc

.proc draw_single_digit
Digit := R0

NametableAddr := R12
AttributeAddr := R14
        lda #NUMBERS_BASE
        clc
        adc Digit
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny
        rts
.endproc

.macro sub16w addr, value
        sec
        lda addr
        sbc #<value
        sta addr
        lda addr+1
        sbc #>value
        sta addr+1
.endmacro

.proc draw_16bit_number
NumberWord := R0
CurrentDigit := R2
LeadingCounter := R3

NametableAddr := R12
AttributeAddr := R14

        perform_zpcm_inc
        lda #0
        sta CurrentDigit
        sta LeadingCounter
tens_of_thousands_loop:
        cmp16 NumberWord, #10000
        bcc display_tens_of_thousands
        inc CurrentDigit
        sub16w NumberWord, 10000
        jmp tens_of_thousands_loop
display_tens_of_thousands:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_ten_thousands
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_ten_thousands
blank_ten_thousands:
        lda #BLANK_TILE
draw_ten_thousands:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
thousands_loop:
        cmp16 NumberWord, #1000
        bcc display_thousands
        inc CurrentDigit
        sub16w NumberWord, 1000
        jmp thousands_loop
display_thousands:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_thousands
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_thousands
blank_thousands:
        lda #BLANK_TILE
draw_thousands:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
hundreds_loop:
        cmp16 NumberWord, #100
        bcc display_hundreds
        inc CurrentDigit
        sub16w NumberWord, 100
        jmp hundreds_loop
display_hundreds:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_hundreds
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_hundreds
blank_hundreds:
        lda #BLANK_TILE
draw_hundreds:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
tens_loop:
        cmp16 NumberWord, #10
        bcc display_tens
        inc CurrentDigit
        sub16w NumberWord, 10
        jmp tens_loop
display_tens:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_tens
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_tens
blank_tens:
        lda #BLANK_TILE
draw_tens:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
ones_loop:
        cmp16 NumberWord, #1
        bcc display_ones
        inc CurrentDigit
        sub16w NumberWord, 1
        jmp ones_loop
display_ones:
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        rts
.endproc