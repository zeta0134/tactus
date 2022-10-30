        .macpack longbranch

        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "input.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "sprites.inc"
        .include "static_screens.inc"
        .include "vram_buffer.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.segment "PRGFIXED_C000"

.proc update_title
        lda #KEY_START
        and ButtonsDown
        beq stay_here

        ; TODO: fade out to game prep?
        st16 FadeToGameMode, game_prep
        st16 GameMode, fade_to_game_mode

stay_here:
        rts
.endproc

; Expects PPUADDR and PPUCTRL to be configured beforehand
.proc draw_string_imm
StringPtr := R0
VramIndex := R2
        sty VramIndex ; preserve
loop:
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        sta PPUDATA
        inc16 StringPtr
        jmp loop
end_of_string:
        rts
.endproc

.proc init_game_end_screen

.endproc

.proc update_game_end_screen
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