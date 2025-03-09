.include "dynamic_palette.inc"


.zeropage
; Copied in during NMI where every cycle is precious. Spare no expense!
staging_palette: .res 32

        .segment "RAM"


        .segment "CODE_PALETTES"

dynamic_palette_brightness_minus_5:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_minus_4:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_minus_3:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_minus_2:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_minus_1:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_normal:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
dynamic_palette_brightness_plus_1:
    .byte $2D, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $00, $0F, $0F
dynamic_palette_brightness_plus_2:
    .byte $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $0F, $0F
dynamic_palette_brightness_plus_3:
    .byte $10, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $10, $0F, $0F
dynamic_palette_brightness_plus_4:
    .byte $3D, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $10, $0F, $0F
dynamic_palette_brightness_plus_5:
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F



; Format of entries:
; index: XY where X is the target hue, Y is the current hue
; value: target hue + 1 step towards current hue
; note: this table prefers hue=0 for greyscale steps
hue_shift_lut:
    ;Src: GSC   x1   x2,  x3   x4   x5   x6   x7   x8   x9   xA   xB   xC  RGB, ---, --- 
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: GSC
    .byte $01, $01, $01, $02, $03, $04, $05, $06, $09, $0A, $0B, $0C, $01, $01, $01, $01 ; Dest: x1
    .byte $02, $02, $02, $02, $03, $04, $05, $06, $07, $0A, $0B, $0C, $01, $02, $02, $02 ; Dest: x2
    .byte $03, $02, $03, $03, $03, $04, $05, $06, $07, $08, $0B, $0C, $01, $03, $03, $03 ; Dest: x3
    .byte $04, $02, $03, $04, $04, $04, $05, $06, $07, $08, $09, $0C, $01, $04, $04, $04 ; Dest: x4
    .byte $05, $02, $03, $04, $05, $05, $05, $06, $07, $08, $09, $0A, $01, $05, $05, $05 ; Dest: x5
    .byte $06, $02, $03, $04, $05, $06, $06, $06, $07, $08, $09, $0A, $0B, $06, $06, $06 ; Dest: x6
    .byte $07, $0C, $03, $04, $05, $06, $07, $07, $07, $08, $09, $0A, $0B, $07, $07, $07 ; Dest: x7
    .byte $08, $0C, $01, $04, $05, $06, $07, $08, $08, $08, $09, $0A, $0B, $08, $08, $08 ; Dest: x8
    .byte $09, $0C, $01, $02, $05, $06, $07, $08, $09, $09, $09, $0A, $0B, $09, $09, $09 ; Dest: x9
    .byte $0A, $0C, $01, $02, $03, $06, $07, $08, $09, $0A, $0A, $0A, $0B, $0A, $0A, $0A ; Dest: xA
    .byte $0B, $0C, $01, $02, $03, $04, $07, $08, $09, $0A, $0B, $0B, $0B, $0B, $0B, $0B ; Dest: xB
    .byte $0C, $0C, $01, $02, $03, $04, $05, $08, $09, $0A, $0B, $0C, $0C, $0C, $0C, $0C ; Dest: xC
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: RGB (converted later)
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---




.proc FAR_set_bg_palette

    
.endproc