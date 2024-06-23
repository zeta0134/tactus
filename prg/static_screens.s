        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "charmap.inc"
        .include "debug.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "raster_tricks.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "static_screens.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"

TitleCursorIndex: .res 1


.segment "CODE_1"

BLANK_TILE = 250

; Expects PPUADDR and PPUCTRL to be configured beforehand
.proc draw_string_imm
StringPtr := R0
VramIndex := R2
        sty VramIndex ; preserve
loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        sta PPUDATA
        inc16 StringPtr
        jmp loop
end_of_string:
        rts
.endproc

.proc draw_single_digit_imm
Digit := R0
        lda #NUMBERS_BASE
        clc
        adc Digit
        sta PPUDATA
        perform_zpcm_inc
        rts
.endproc

.proc draw_16bit_number_imm
NumberWord := R0
CurrentDigit := R2
LeadingCounter := R3
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
        sta PPUDATA

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
        sta PPUDATA

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
        sta PPUDATA

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
        sta PPUDATA

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
        sta PPUDATA

        perform_zpcm_inc

        rts
.endproc

game_over_text: .asciiz "GAME OVER"
victory_text: .asciiz "VICTORY!"
demo_end_text: .asciiz "(END OF DEMO)"
lowest_floor_text: .asciiz "LOWEST FLOOR:"
gold_text:         .asciiz "GOLD COLLECTED:"
time_text:         .asciiz "STEPS TAKEN:"
hyphen_text: .asciiz "-"
thank_you_text: .asciiz "THANK YOU FOR PLAYING!"


; This is called with rendering already disabled
.proc FAR_init_game_end_screen
StringPtr := R0
NumberWord := R0
Digit := R0
        far_call FAR_init_nametables

        ; We don't know which nametable will be active, so
        ; all drawing commands will be run twice, once for each half

        lda PlayerHealth
        jeq game_over
victory:
        set_ppuaddr #($2000 + $010C)
        st16 StringPtr, victory_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $010C)
        st16 StringPtr, victory_text
        jsr draw_string_imm

        set_ppuaddr #($2000 + $014A)
        st16 StringPtr, demo_end_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $014A)
        st16 StringPtr, demo_end_text
        jsr draw_string_imm

        set_ppuaddr #($2000 + $02C5)
        st16 StringPtr, thank_you_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $02C5)
        st16 StringPtr, thank_you_text
        jsr draw_string_imm

        ; TODO; replace this with the victory track, when and if we have one
        lda #0
        jsr play_track

        jmp converge
game_over:
        set_ppuaddr #($2000 + $010C)
        st16 StringPtr, game_over_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $010C)
        st16 StringPtr, game_over_text
        jsr draw_string_imm

        st16 R0, sfx_death_splat_noise
        jsr play_sfx_noise

        ; TODO; replace this with the game over jingle, when and if we have one
        lda #0
        jsr play_track

converge:
        ; Text labels for progress through the dungeon
        set_ppuaddr #($2000 + $01C7)
        st16 StringPtr, lowest_floor_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $01C7)
        st16 StringPtr, lowest_floor_text
        jsr draw_string_imm        

        set_ppuaddr #($2000 + $205)
        st16 StringPtr, gold_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $205)
        st16 StringPtr, gold_text
        jsr draw_string_imm   

        set_ppuaddr #($2000 + $0248)
        st16 StringPtr, time_text
        jsr draw_string_imm
        set_ppuaddr #($2400 + $0248)
        st16 StringPtr, time_text
        jsr draw_string_imm

        ; Zone counter
        set_ppuaddr #($2000 + $01D8)
        lda PlayerZone ; TODO: use the actual world number
        sta Digit
        jsr draw_single_digit_imm
        st16 StringPtr, hyphen_text
        jsr draw_string_imm
        lda PlayerFloor ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit_imm

        set_ppuaddr #($2400 + $01D8)
        lda PlayerZone ; TODO: use the actual world number
        sta Digit
        jsr draw_single_digit_imm
        st16 StringPtr, hyphen_text
        jsr draw_string_imm
        lda PlayerFloor ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit_imm

        ; Gold Counter
        set_ppuaddr #($2000 + $0216)
        mov16 NumberWord, PlayerGold
        jsr draw_16bit_number_imm
        set_ppuaddr #($2400 + $0216)
        mov16 NumberWord, PlayerGold
        jsr draw_16bit_number_imm

        ; Step Counter
        set_ppuaddr #($2000 + $0256)
        mov16 NumberWord, AccumulatedGameBeats
        jsr draw_16bit_number_imm
        set_ppuaddr #($2400 + $0256)
        mov16 NumberWord, AccumulatedGameBeats
        jsr draw_16bit_number_imm

        ; Finally, fix all the attributes to use palette 2, which still has our blue/white
        set_ppuaddr #$23C0
        lda #%01010101
        ldx #64
attribute_loop_left:
        perform_zpcm_inc
        sta PPUDATA
        dex
        bne attribute_loop_left

        set_ppuaddr #$27C0
        lda #%01010101
        ldx #64
attribute_loop_right:
        perform_zpcm_inc
        sta PPUDATA
        dex
        bne attribute_loop_right

        rts
.endproc

.proc FAR_update_game_end_screen
        ; For now, the same as the title screen; just wait for START then proceed,
        ; in this case back to the title

        lda #KEY_START
        and ButtonsDown
        beq stay_here

        ; TODO: fade out to game prep?
        st16 FadeToGameMode, title_prep
        st16 GameMode, fade_to_game_mode

stay_here:
        rts
.endproc