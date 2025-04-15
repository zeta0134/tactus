    .macpack longbranch

    .include "../build/tile_defs.inc"

    .include "_globals.inc"

    .include "dynamic_palette.inc"
    .include "far_call.inc"
    .include "prng.inc"
    .include "rainbow.inc"
    .include "saves.inc"
    .include "settings.inc"
    .include "word_util.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .segment "PRGRAM"

; Computed from the slider lookup tables. Our "base" palette
; to which most states return. Everything else is derived from
; this as a starting point.

player_palettes_pigment: .res 64
player_palettes_phones:  .res 64
player_palettes_pajamas: .res 64

    .segment "PRGFIXED_E000"

; because we need to access these quickly from several different places,
; and they are not large
; TODO okay that is a lie, can we move these to a data segment?

; new, with a shared lut
palette_preset_lut_phones:  .byte  0, 14, 24,  5, 18, 17
palette_preset_lut_pajamas: .byte  0, 31, 50, 28, 32, 26
palette_preset_lut_pigment: .byte  0, 45, 32, 18, 43, 44

    .segment "CODE_2"

player_colors_lut:
    .byte $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C ;  (-)  (0)
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $20 ;  (0) (13)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (13) (26)
    .byte $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $50 ; (26) (39)

player_title_base_phones_lut:
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C ;  (-)  (0)
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $20 ;  (0) (13)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (13) (26)
    .byte $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $40 ; (26) (39)

player_title_base_pajamas_lut:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C ;  (-)  (0)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ;  (0) (13)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (13) (26)
    .byte $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $50 ; (26) (39)

player_title_base_pigment_lut:
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C ;  (-)  (0)
    .byte $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $20 ;  (0) (13)
    .byte $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $30 ; (13) (26)
    .byte $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $40 ; (26) (39)

; For the actively loaded file, initialize all options to their
; default values. This is meant to be used just after clicking
; start on a brand new file, as the settings should otherwise
; persist as part of that file.
.proc FAR_init_file_options
    ; Default to solid frozen squares. This is by far the most
    ; accessible option. New players will be sent to the options
    ; screen before starting the game proper, so they can flip
    ; this to their preference as they like.
    lda #DISCO_FLOOR_SOLID_FROZEN_SQUARES
    sta current_save + SaveFile::OptionDiscoFloor

    lda #GAME_MODE_STANDARD
    sta current_save + SaveFile::OptionRhythmMode

    ; TODO: pick a random preset from the range of possible presets
    in_range_smol next_gameplay_rand, #(NEW_FILE_PALETTE_MAX-NEW_FILE_PALETTE_MIN)
    clc
    adc #NEW_FILE_PALETTE_MIN
    sta current_save + SaveFile::PlayerPalettePreset
    ; Use this to initialize the personalized sliders, just to avoid some dumb
    ; problems with defaults when these disagree
    ldx current_save + SaveFile::PlayerPalettePreset
    lda palette_preset_lut_phones, x 
    sta current_save + SaveFile::PlayerPalettePhonesIndex
    lda palette_preset_lut_pajamas, x 
    sta current_save + SaveFile::PlayerPalettePajamasIndex
    lda palette_preset_lut_pigment, x 
    sta current_save + SaveFile::PlayerPalettePigmentIndex

    near_call FAR_compute_player_colors

    rts
.endproc

.proc FAR_compute_player_colors
    perform_zpcm_inc
    lda current_save + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pajamas, x
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pigment, x
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors
    
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_save + SaveFile::PlayerPalettePhonesIndex
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldy current_save + SaveFile::PlayerPalettePajamasIndex
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldy current_save + SaveFile::PlayerPalettePigmentIndex
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts
.endproc

; Uses a smaller color set, skips initializing many of the extra colors
; that we don't actually need. This helps performance primarily, so we aren't
; lagging too terribly after the player moves the custom color sliders around.
.proc FAR_compute_player_colors_for_options
    perform_zpcm_inc
    lda current_save + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pajamas, x
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldx current_save + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pigment, x
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_options_derived_colors
    
    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_save + SaveFile::PlayerPalettePhonesIndex
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldy current_save + SaveFile::PlayerPalettePajamasIndex
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldy current_save + SaveFile::PlayerPalettePigmentIndex
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_options_derived_colors

    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_1_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pajamas, x
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pigment, x
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePhonesIndex
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePajamasIndex
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot1 + SaveFile::PlayerPalettePigmentIndex
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_2_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pajamas, x
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pigment, x
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePhonesIndex
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePajamasIndex
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot2 + SaveFile::PlayerPalettePigmentIndex
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts
.endproc

.proc _compute_file_3_colors
    perform_zpcm_inc
    lda current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    cmp #PLAYER_PALETTE_PERSONALIZED
    beq use_custom_palette

use_preset_palette:
    ldx current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_phones, x
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pajamas, x
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldx current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePreset
    ldy palette_preset_lut_pigment, x
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts

use_custom_palette:
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePhonesIndex
    lda player_colors_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_NORMAL
    lda player_title_base_phones_lut, y
    sta player_palettes_phones+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePajamasIndex
    lda player_colors_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_NORMAL
    lda player_title_base_pajamas_lut, y
    sta player_palettes_pajamas+PLAYER_PALETTE_TITLE_BASE
    ldy current_block + SaveBlock::SaveSlot3 + SaveFile::PlayerPalettePigmentIndex
    lda player_colors_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_NORMAL
    lda player_title_base_pigment_lut, y
    sta player_palettes_pigment+PLAYER_PALETTE_TITLE_BASE

    jsr _compute_derived_colors

    perform_zpcm_inc
    rts
.endproc

; save slot in A
.proc FAR_compute_colors_for_save_slot
    cmp #0
    beq compute_file_1
    cmp #1
    beq compute_file_2
    cmp #2
    beq compute_file_3
    ; should not be reachable
compute_file_1:
    jsr _compute_file_1_colors
    rts
compute_file_2:
    jsr _compute_file_2_colors
    rts
compute_file_3:
    jsr _compute_file_3_colors
    rts
.endproc

COLOR_0_BY = $00
COLOR_1_BY = $01
COLOR_2_BY = $02
COLOR_3_BY = $03
COLOR_4_BY = $04
COLOR_5_BY = $05
COLOR_6_BY = $06
COLOR_7_BY = $07
COLOR_8_BY = $08
COLOR_9_BY = $09
COLOR_A_BY = $0A
COLOR_B_BY = $0B
COLOR_C_BY = $0C

LUM_0 = $00
LUM_1 = $10
LUM_2 = $20
LUM_3 = $30
LUM_4 = $40
LUM_5 = $50

DARKEN_BY  = $00
LIGHTEN_BY = $50

derived_color_mod_table:
          ; PHONES                  PAJAMAS                  PIGMENT
          ; target, h.step, l.step  target, h.step, l.step   target, h.step, l.step
    .byte      $55,      6,      2,    $55,      6,      2,     $55,      6,      2 ; Damage Light
    .byte      $05,      6,      1,    $05,      6,      1,     $05,      6,      1 ; Damage Dark

    ; A basic pulse to the beat. We allow this to fade all the way down to nothing.
    .byte      $50,      0,      3,    $50,      0,      3,     $50,      0,      3 ; Rhythm Assist - 0
    .byte      $50,      0,      2,    $50,      0,      2,     $50,      0,      2 ; Rhythm Assist - 1
    .byte      $50,      0,      1,    $50,      0,      1,     $50,      0,      1 ; Rhythm Assist - 2
    .byte      $50,      0,      1,    $50,      0,      1,     $50,      0,      1 ; Rhythm Assist - 3
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 4
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 5
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 6
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 7

    ; Delightful pink strawberries. This status doesn't linger so it can fade to nothing.
    .byte      $45,      6,      3,    $45,      6,      3,     $45,      6,      3 ; Just Healed - 0
    .byte      $45,      6,      2,    $45,      6,      2,     $45,      6,      2 ; Just Healed - 1
    .byte      $45,      5,      1,    $45,      5,      1,     $45,      5,      1 ; Just Healed - 2
    .byte      $45,      4,      1,    $45,      4,      1,     $45,      4,      1 ; Just Healed - 3
    .byte      $45,      3,      0,    $45,      3,      0,     $45,      3,      0 ; Just Healed - 4
    .byte      $45,      2,      0,    $45,      2,      0,     $45,      2,      0 ; Just Healed - 5
    .byte      $45,      1,      0,    $45,      1,      0,     $45,      1,      0 ; Just Healed - 6
    .byte      $45,      0,      0,    $45,      0,      0,     $45,      0,      0 ; Just Healed - 7

    ; Sickly Lime Green. Gross! This lingers, so we'll stay off-color and quite green
    .byte      $4A,      6,      2,    $4A,      6,      2,     $4A,      6,      2 ; Poisoned - 0
    .byte      $4A,      6,      1,    $4A,      6,      1,     $4A,      6,      1 ; Poisoned - 1
    .byte      $4A,      6,      0,    $4A,      6,      0,     $4A,      6,      0 ; Poisoned - 2
    .byte      $4A,      6,      0,    $4A,      6,      0,     $4A,      6,      0 ; Poisoned - 3
    .byte      $4A,      5,      0,    $4A,      5,      0,     $4A,      5,      0 ; Poisoned - 4
    .byte      $0A,      5,      1,    $0A,      5,      1,     $0A,      5,      1 ; Poisoned - 5
    .byte      $0A,      4,      1,    $0A,      4,      1,     $0A,      4,      1 ; Poisoned - 6
    .byte      $0A,      4,      1,    $0A,      4,      1,     $0A,      4,      1 ; Poisoned - 7

    ; Frozen solid! A mix of blue, and purple shades, with the lightest little flash right on the beat
    .byte      $42,      6,      3,    $51,      6,      3,     $5C,      6,      3 ; Frozen - 0
    .byte      $42,      6,      1,    $51,      6,      1,     $5C,      6,      1 ; Frozen - 1
    .byte      $42,      6,      1,    $51,      6,      1,     $5C,      6,      1 ; Frozen - 2
    .byte      $42,      6,      1,    $51,      6,      1,     $5C,      6,      1 ; Frozen - 3
    .byte      $42,      6,      1,    $51,      5,      1,     $5C,      6,      1 ; Frozen - 4
    .byte      $42,      6,      1,    $51,      5,      1,     $5C,      6,      1 ; Frozen - 5
    .byte      $42,      6,      1,    $51,      4,      1,     $5C,      6,      1 ; Frozen - 6
    .byte      $42,      6,      1,    $51,      4,      1,     $5C,      6,      1 ; Frozen - 7

    ; Shocked! This is the ramp down from very bright yellow, the flashes are applied separately
    .byte      $47,      6,      3,    $47,      6,      3,     $47,      6,      3 ; Shocked - 0
    .byte      $47,      6,      2,    $47,      6,      2,     $47,      6,      2 ; Shocked - 1
    .byte      $47,      5,      1,    $47,      5,      1,     $47,      5,      1 ; Shocked - 2
    .byte      $47,      4,      0,    $47,      4,      0,     $47,      4,      0 ; Shocked - 3
    .byte      $47,      3,      0,    $47,      3,      0,     $47,      3,      0 ; Shocked - 4
    .byte      $07,      2,      0,    $07,      2,      0,     $07,      2,      0 ; Shocked - 5
    .byte      $07,      1,      1,    $07,      1,      1,     $07,      1,      1 ; Shocked - 6
    .byte      $07,      1,      1,    $07,      1,      1,     $07,      1,      1 ; Shocked - 7

    ; On fire! Deep red all the way down to ashen soot, very high contrast
    .byte      $46,      6,      1,    $46,      6,      1,     $46,      6,      1 ; Burned - 0
    .byte      $46,      6,      0,    $46,      6,      0,     $46,      6,      0 ; Burned - 1
    .byte      $46,      6,      0,    $46,      6,      0,     $46,      6,      0 ; Burned - 2
    .byte      $06,      6,      1,    $06,      6,      1,     $06,      6,      1 ; Burned - 3
    .byte      $06,      5,      1,    $06,      5,      1,     $06,      5,      1 ; Burned - 4
    .byte      $06,      5,      1,    $06,      5,      1,     $06,      5,      1 ; Burned - 5
    .byte      $06,      4,      1,    $06,      4,      1,     $06,      4,      1 ; Burned - 6
    .byte      $06,      4,      1,    $06,      4,      1,     $06,      4,      1 ; Burned - 7

    .byte $FF ; end of list

abbreviated_derived_color_mod_table:
          ; PHONES                  PAJAMAS                  PIGMENT
          ; target, h.step, l.step  target, h.step, l.step   target, h.step, l.step
    .byte      $55,      6,      2,    $55,      6,      2,     $55,      6,      2 ; Damage Light
    .byte      $05,      6,      1,    $05,      6,      1,     $05,      6,      1 ; Damage Dark

    ; A basic pulse to the beat. We allow this to fade all the way down to nothing.
    .byte      $50,      0,      3,    $50,      0,      3,     $50,      0,      3 ; Rhythm Assist - 0
    .byte      $50,      0,      2,    $50,      0,      2,     $50,      0,      2 ; Rhythm Assist - 1
    .byte      $50,      0,      1,    $50,      0,      1,     $50,      0,      1 ; Rhythm Assist - 2
    .byte      $50,      0,      1,    $50,      0,      1,     $50,      0,      1 ; Rhythm Assist - 3
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 4
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 5
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 6
    .byte      $50,      0,      0,    $50,      0,      0,     $50,      0,      0 ; Rhythm Assist - 7

    .byte $FF ; end of list

.proc _compute_derived_colors
TablePtr   := R4
    st16 TablePtr, derived_color_mod_table
    jmp _compute_derived_colors_common
.endproc

; A shorter set, to not be quite so terrible for performance
.proc _compute_options_derived_colors
TablePtr   := R4
    st16 TablePtr, abbreviated_derived_color_mod_table
    jmp _compute_derived_colors_common
.endproc

.proc _compute_derived_colors_common
; used by hue/luminence stepping functions
CurrentColor := R0
TargetColor := R1
HueSteps := R2
LuminenceSteps := R3

TablePtr   := R4
PaletteIndex := R6
; R15 is used/clobbered by hue stepping routines

    
    lda #2 ; skip past entry 0, which is our "normal" palette, and 1 which is our "title base" palette
    sta PaletteIndex
loop:
    ; Phones!
    lda player_palettes_phones+0
    sta CurrentColor
    ldy #0
    lda (TablePtr), y
    sta TargetColor
    iny
    lda (TablePtr), y
    sta HueSteps
    iny
    lda (TablePtr), y
    sta LuminenceSteps
    far_call FAR_step_towards_target
    lda CurrentColor
    ldx PaletteIndex
    sta player_palettes_phones, x
    ; Pajamas!
    lda player_palettes_pajamas+0
    sta CurrentColor
    ldy #3
    lda (TablePtr), y
    sta TargetColor
    iny
    lda (TablePtr), y
    sta HueSteps
    iny
    lda (TablePtr), y
    sta LuminenceSteps
    far_call FAR_step_towards_target
    lda CurrentColor
    ldx PaletteIndex
    sta player_palettes_pajamas, x
    ; Pigment!
    lda player_palettes_pigment+0
    sta CurrentColor
    ldy #6
    lda (TablePtr), y
    sta TargetColor
    iny
    lda (TablePtr), y
    sta HueSteps
    iny
    lda (TablePtr), y
    sta LuminenceSteps
    far_call FAR_step_towards_target
    lda CurrentColor
    ldx PaletteIndex
    sta player_palettes_pigment, x
    ; Looping!
    add16b TablePtr, #9
    inc PaletteIndex
    ldy #0
    lda (TablePtr), y
    cmp #$FF
    jne loop

    ; Whew!

    rts
.endproc
