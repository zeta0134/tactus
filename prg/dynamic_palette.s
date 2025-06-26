    
    .include "../build/tile_defs.inc"
    .include "_globals.inc"

    .include "dynamic_palette.inc"

    .include "far_call.inc"
    .include "rainbow.inc"
    .include "pal.inc"
    .include "saves.inc"
    .include "zeropage.inc"
    .include "word_util.inc"
    .include "zpcm.inc"

.zeropage
; Copied in during NMI where every cycle is precious. Spare no expense!
staging_palette: .res 32


        .segment "PRGRAM"
PaletteStateFunc: .res 2

; For setting a base palette when the original is in hw format. We need to
; convert it to our intermediate format. How this gets used depends on the
; loader function.
IncomingHwPalette: .res 32

CurrentPlayfieldBackdrop: .res 1
CurrentPlayfieldBgPal0: .res 3
CurrentPlayfieldBgPal1: .res 3
CurrentPlayfieldBgPal2: .res 3
CurrentPlayfieldBgPal3: .res 3

TargetPlayfieldBackdrop: .res 1
TargetPlayfieldBgPal0: .res 3
TargetPlayfieldBgPal1: .res 3
TargetPlayfieldBgPal2: .res 3
TargetPlayfieldBgPal3: .res 3

PlayfieldObjPal0: .res 3
PlayfieldObjPal1: .res 3
PlayfieldObjPal2: .res 3
PlayfieldObjPal3: .res 3

HudBackdrop: .res 1
HudBgPal0: .res 3
HudBgPal1: .res 3
HudBgPal2: .res 3
HudBgPal3: .res 3
HudObjPal0: .res 3 ; Note: the HUD swap only changes OBJ0, we leave 1-3 alone
HudSeparatorPal: .res 3 ; Displayed DURING the hud palette swap, as thin lines

StagingBgPaletteDirty: .res 1
StagingObjPaletteDirty: .res 1
StagingHudPaletteDirty: .res 1

; Copied in during a raster effect which needs lots of delay anyway, so regular RAM
; is just fine. 
HudStagingPalette: .res 32

Brightness: .res 1
TargetBrightness: .res 1
BrightnessDelay: .res 1
GlobalFadeSpeed: .res 1

.segment "PRGFIXED_E000"

; call with desired brightness in a
.proc set_brightness
        sta Brightness
        lda #1
        sta StagingBgPaletteDirty
        sta StagingObjPaletteDirty
        sta StagingHudPaletteDirty
        rts
.endproc

        .segment "CODE_PALETTES"

dynamic_palette_normal:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $2D, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0F, $0F, $0F
    .byte $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $0F, $0F, $0F
    .byte $10, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $0F, $0F, $0F
    .byte $3D, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

dynamic_palette_greyscale:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $0F, $0F, $0F
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0F, $0F, $0F
    .byte $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $0F, $0F, $0F
    .byte $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

dynamic_palette_greenscale:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0F, $0F, $0F
    .byte $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $0F, $0F, $0F
    .byte $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $0F, $0F, $0F
    .byte $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

dynamic_palette_rgbppu:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $01, $02, $02, $04, $05, $16, $07, $08, $09, $09, $0A, $0C, $0F, $0F, $0F
    .byte $00, $11, $12, $13, $24, $15, $06, $17, $18, $19, $1A, $1B, $1C, $0F, $0F, $0F
    .byte $10, $21, $22, $23, $23, $25, $26, $27, $28, $29, $2A, $2C, $2C, $0F, $0F, $0F
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $2B, $3C, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

; it's kinda blue, but whatever. I'd rather it be blue than _broken._
dynamic_palette_rgbppu_greyscale:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $0F, $0F, $0F
    .byte $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $0F, $0F, $0F
    .byte $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $0F, $0F, $0F
    .byte $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

dynamic_palette_rgbppu_greenscale:
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    .byte $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0F, $0F, $0F
    .byte $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $0F, $0F, $0F
    .byte $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $29, $0F, $0F, $0F
    .byte $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $0F, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F
    .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $0F, $0F

; Format of entries:
; index: XY where X is the target hue, Y is the current hue
; value: target hue + 1 step towards current hue
hue_shift_lut:
    ;Src: GSC   x1   x2,  x3   x4   x5   x6   x7   x8   x9   xA   xB   xC  ---, ---, --- 
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: GSC
    .byte $01, $01, $01, $02, $03, $04, $05, $06, $09, $0A, $0B, $0C, $01, $01, $01, $01 ; Dest: x1
    .byte $02, $02, $02, $02, $03, $04, $05, $06, $09, $0A, $0B, $0C, $01, $02, $02, $02 ; Dest: x2
    .byte $03, $02, $03, $03, $03, $04, $05, $06, $07, $0A, $0B, $0C, $01, $03, $03, $03 ; Dest: x3
    .byte $04, $02, $03, $04, $04, $04, $05, $06, $07, $08, $0B, $0C, $01, $04, $04, $04 ; Dest: x4
    .byte $05, $02, $03, $04, $05, $05, $05, $06, $07, $08, $09, $0A, $01, $05, $05, $05 ; Dest: x5
    .byte $06, $02, $03, $04, $05, $06, $06, $06, $07, $08, $09, $0A, $01, $06, $06, $06 ; Dest: x6
    .byte $07, $02, $03, $04, $05, $06, $07, $07, $07, $08, $09, $0A, $0B, $07, $07, $07 ; Dest: x7
    .byte $08, $0C, $01, $04, $05, $06, $07, $08, $08, $08, $09, $0A, $0B, $08, $08, $08 ; Dest: x8
    .byte $09, $0C, $01, $02, $05, $06, $07, $08, $09, $09, $09, $0A, $0B, $09, $09, $09 ; Dest: x9
    .byte $0A, $0C, $01, $02, $03, $06, $07, $08, $09, $0A, $0A, $0A, $0B, $0A, $0A, $0A ; Dest: xA
    .byte $0B, $0C, $01, $02, $03, $06, $07, $08, $09, $0A, $0B, $0B, $0B, $0B, $0B, $0B ; Dest: xB
    .byte $0C, $0C, $01, $02, $03, $04, $05, $08, $09, $0A, $0B, $0C, $0C, $0C, $0C, $0C ; Dest: xC
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---

hw_to_intermediate_equivalence_lut:
    ; Composite (uses $x0 for greyscale)
    .byte $20, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $00, $00
    .byte $30, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $00, $00, $00
    .byte $50, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $10, $00, $00
    .byte $50, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $40, $00, $00

.proc FAR_init_dynamic_palettes
        ; Initialize all hardware palettes to solid black
        lda #$0F
        ldx #0
hw_pal_loop:
        perform_zpcm_inc
        sta staging_palette+0, x
        sta staging_palette+16, x
        sta HudStagingPalette+0, x
        sta HudStagingPalette+16, x
        inx
        cpx #16
        bne hw_pal_loop

        ; Initialize all colorspace palettes to solid black, greyscale hue
        lda #0
        sta CurrentPlayfieldBackdrop
        sta TargetPlayfieldBackdrop
        sta HudBackdrop
        ldx #0
intermediate_pal_loop:
        perform_zpcm_inc
        sta CurrentPlayfieldBgPal0, x
        sta CurrentPlayfieldBgPal1, x
        sta CurrentPlayfieldBgPal2, x
        sta CurrentPlayfieldBgPal3, x
        sta TargetPlayfieldBgPal0, x
        sta TargetPlayfieldBgPal1, x
        sta TargetPlayfieldBgPal2, x
        sta TargetPlayfieldBgPal3, x
        sta PlayfieldObjPal0, x
        sta PlayfieldObjPal1, x
        sta PlayfieldObjPal2, x
        sta PlayfieldObjPal3, x
        sta HudBgPal0, x
        sta HudBgPal1, x
        sta HudBgPal2, x
        sta HudBgPal3, x
        sta HudObjPal0, x
        sta HudSeparatorPal, x
        inx
        cpx #3
        bne intermediate_pal_loop
        perform_zpcm_inc

        sta BrightnessDelay
        lda #BRIGHTNESS_FULLY_DARK
        sta Brightness
        sta TargetBrightness

        lda #FADE_SPEED_GAMEPLAY
        sta GlobalFadeSpeed

        st16 PaletteStateFunc, palette_state_bgstep_01

        perform_zpcm_inc
        rts
.endproc


; For these, we assume the hardware palette has been preloaded into the RAM location.
; We do this to make bank switching saner, and because we don't really care too much
; about performance for this part of the code.

; Set the target when you want to smoothly fade from the current palette
.proc FAR_set_bg_target_palette_from_hw
    perform_zpcm_inc
    lda IncomingHwPalette+0
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBackdrop

    ldx IncomingHwPalette+1
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+0
    ldx IncomingHwPalette+2
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+1
    ldx IncomingHwPalette+3
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+2

    ldx IncomingHwPalette+5
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+0
    ldx IncomingHwPalette+6
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+1
    ldx IncomingHwPalette+7
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+2

    perform_zpcm_inc

    ldx IncomingHwPalette+9
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+0
    ldx IncomingHwPalette+10
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+1
    ldx IncomingHwPalette+11
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+2

    ldx IncomingHwPalette+13
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+0
    ldx IncomingHwPalette+14    
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+1
    ldx IncomingHwPalette+15
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+2

    perform_zpcm_inc
    rts
.endproc

; Set both when you need the change to be instant (ish)
.proc FAR_set_bg_current_palette_from_target
    perform_zpcm_inc
    lda TargetPlayfieldBackdrop
    sta CurrentPlayfieldBackdrop
    lda TargetPlayfieldBgPal0+0
    sta CurrentPlayfieldBgPal0+0
    lda TargetPlayfieldBgPal0+1
    sta CurrentPlayfieldBgPal0+1
    lda TargetPlayfieldBgPal0+2
    sta CurrentPlayfieldBgPal0+2
    lda TargetPlayfieldBgPal1+0
    sta CurrentPlayfieldBgPal1+0
    lda TargetPlayfieldBgPal1+1
    sta CurrentPlayfieldBgPal1+1
    perform_zpcm_inc
    lda TargetPlayfieldBgPal1+2
    sta CurrentPlayfieldBgPal1+2
    lda TargetPlayfieldBgPal2+0
    sta CurrentPlayfieldBgPal2+0
    lda TargetPlayfieldBgPal2+1
    sta CurrentPlayfieldBgPal2+1
    lda TargetPlayfieldBgPal2+2
    sta CurrentPlayfieldBgPal2+2
    lda TargetPlayfieldBgPal3+0
    sta CurrentPlayfieldBgPal3+0
    lda TargetPlayfieldBgPal3+1
    sta CurrentPlayfieldBgPal3+1
    lda TargetPlayfieldBgPal3+2
    sta CurrentPlayfieldBgPal3+2

    inc StagingBgPaletteDirty
    perform_zpcm_inc
    rts
.endproc

; Obj and HUD palettes don't have a current/target setup, it's too expensive
.proc FAR_set_obj_palette_from_hw
    perform_zpcm_inc
    ldx IncomingHwPalette+1
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+0
    ldx IncomingHwPalette+2
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+1
    ldx IncomingHwPalette+3
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+2

    ldx IncomingHwPalette+5
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+0
    ldx IncomingHwPalette+6
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+1
    ldx IncomingHwPalette+7
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+2

    perform_zpcm_inc

    ldx IncomingHwPalette+9
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+0
    ldx IncomingHwPalette+10    
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+1
    ldx IncomingHwPalette+11
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+2

    ldx IncomingHwPalette+13    
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+0
    ldx IncomingHwPalette+14
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+1
    ldx IncomingHwPalette+15
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+2

    inc StagingObjPaletteDirty
    perform_zpcm_inc
    rts
.endproc

.proc FAR_set_hud_bg_palette_from_hw
    perform_zpcm_inc
    ldx IncomingHwPalette+0
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBackdrop

    ldx IncomingHwPalette+1
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+0
    ldx IncomingHwPalette+2
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+1
    ldx IncomingHwPalette+3
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+2

    ldx IncomingHwPalette+5
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+0
    ldx IncomingHwPalette+6
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+1
    ldx IncomingHwPalette+7
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+2

    perform_zpcm_inc

    ldx IncomingHwPalette+9
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+0
    ldx IncomingHwPalette+10
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+1
    ldx IncomingHwPalette+11
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+2

    ldx IncomingHwPalette+13    
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+0
    ldx IncomingHwPalette+14
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+1
    ldx IncomingHwPalette+15    
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+2

    inc StagingHudPaletteDirty
    perform_zpcm_inc
    rts
.endproc

.proc FAR_set_hud_obj_palette_from_hw
    perform_zpcm_inc
    ldx IncomingHwPalette+1
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+0
    ldx IncomingHwPalette+2
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+1
    ldx IncomingHwPalette+3    
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+2

    inc StagingHudPaletteDirty
    perform_zpcm_inc
    rts
.endproc

.proc FAR_set_hud_separator_palette_from_hw
    perform_zpcm_inc
    ldx IncomingHwPalette+1
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+0
    ldx IncomingHwPalette+2
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+1
    ldx IncomingHwPalette+3
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+2
    inc StagingHudPaletteDirty
    perform_zpcm_inc
    rts
.endproc

.proc step_hue
CurrentColor := R0
TargetColor := R1
Scratch := R15
    lda TargetColor
    asl
    asl
    asl
    asl
    sta Scratch ; stash
    lda CurrentColor
    and #$0F
    ora Scratch
    tax
    lda hue_shift_lut, x
    sta Scratch
    lda CurrentColor
    and #$F0
    ora Scratch
    sta CurrentColor
    rts
.endproc

.proc step_luminence
CurrentColor := R0
TargetColor := R1
Scratch := R15
    lda CurrentColor
    and #$70
    sta Scratch
    lda TargetColor
    and #$70
    cmp Scratch
    beq no_change
    bcs increase_luminence
decrease_luminence:
    lda CurrentColor
    sec
    sbc #$10
    sta CurrentColor
    rts
increase_luminence:
    lda CurrentColor
    clc
    adc #$10
    sta CurrentColor
no_change:
    rts
.endproc

; Utility function for arbitrary color manipulation, mostly used when
; working out the player's effect colors while loading their save.
.proc FAR_step_towards_target
; used by hue/luminence stepping functions
CurrentColor := R0
TargetColor := R1
HueSteps := R2
LuminenceSteps := R3

; clobbered by those functions
Scratch := R15

hue_loop:
    perform_zpcm_inc
    lda HueSteps
    beq done_with_hue
    jsr step_hue
    dec HueSteps
    jmp hue_loop
done_with_hue:

luminence_loop:
    perform_zpcm_inc
    lda LuminenceSteps
    beq done_with_luminence
    jsr step_luminence
    dec LuminenceSteps
    jmp luminence_loop
done_with_luminence:

    perform_zpcm_inc
    rts
.endproc

; these are used by the per-frame palette update routine, itself a state machine,
; to eventually step all regions of the screen towards the desired target colors. note
; that brightness is handled in a later step (and applied instantly)
.proc step_bg0_color
CurrentColor := R0
TargetColor := R1
    lda CurrentPlayfieldBackdrop
    cmp TargetPlayfieldBackdrop
    beq done_with_backdrop
    sta CurrentColor
    lda TargetPlayfieldBackdrop
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBackdrop
    inc StagingBgPaletteDirty
done_with_backdrop:
    
    lda CurrentPlayfieldBgPal0+0
    cmp TargetPlayfieldBgPal0+0
    beq done_with_entry_0
    sta CurrentColor
    lda TargetPlayfieldBgPal0+0
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal0+0
    inc StagingBgPaletteDirty
done_with_entry_0:

    perform_zpcm_inc

    lda CurrentPlayfieldBgPal0+1
    cmp TargetPlayfieldBgPal0+1
    beq done_with_entry_1
    sta CurrentColor
    lda TargetPlayfieldBgPal0+1
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal0+1
    inc StagingBgPaletteDirty
done_with_entry_1:

    lda CurrentPlayfieldBgPal0+2
    cmp TargetPlayfieldBgPal0+2
    beq done_with_entry_2
    sta CurrentColor
    lda TargetPlayfieldBgPal0+2
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal0+2
    inc StagingBgPaletteDirty
done_with_entry_2:
    
    rts
.endproc

.proc step_bg1_color
CurrentColor := R0
TargetColor := R1
    lda CurrentPlayfieldBgPal1+0
    cmp TargetPlayfieldBgPal1+0
    beq done_with_entry_0
    sta CurrentColor
    lda TargetPlayfieldBgPal1+0
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal1+0
    inc StagingBgPaletteDirty
done_with_entry_0:

    lda CurrentPlayfieldBgPal1+1
    cmp TargetPlayfieldBgPal1+1
    beq done_with_entry_1
    sta CurrentColor
    lda TargetPlayfieldBgPal1+1
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal1+1
    inc StagingBgPaletteDirty
done_with_entry_1:

    perform_zpcm_inc

    lda CurrentPlayfieldBgPal1+2
    cmp TargetPlayfieldBgPal1+2
    beq done_with_entry_2
    sta CurrentColor
    lda TargetPlayfieldBgPal1+2
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal1+2
    inc StagingBgPaletteDirty
done_with_entry_2:
    
    rts
.endproc

.proc step_bg2_color
CurrentColor := R0
TargetColor := R1
    lda CurrentPlayfieldBgPal2+0
    cmp TargetPlayfieldBgPal2+0
    beq done_with_entry_0
    sta CurrentColor
    lda TargetPlayfieldBgPal2+0
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal2+0
    inc StagingBgPaletteDirty
done_with_entry_0:

    lda CurrentPlayfieldBgPal2+1
    cmp TargetPlayfieldBgPal2+1
    beq done_with_entry_1
    sta CurrentColor
    lda TargetPlayfieldBgPal2+1
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal2+1
    inc StagingBgPaletteDirty
done_with_entry_1:

    perform_zpcm_inc

    lda CurrentPlayfieldBgPal2+2
    cmp TargetPlayfieldBgPal2+2
    beq done_with_entry_2
    sta CurrentColor
    lda TargetPlayfieldBgPal2+2
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal2+2
    inc StagingBgPaletteDirty
done_with_entry_2:
    
    rts
.endproc

.proc step_bg3_color
CurrentColor := R0
TargetColor := R1
    lda CurrentPlayfieldBgPal3+0
    cmp TargetPlayfieldBgPal3+0
    beq done_with_entry_0
    sta CurrentColor
    lda TargetPlayfieldBgPal3+0
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal3+0
    inc StagingBgPaletteDirty
done_with_entry_0:

    lda CurrentPlayfieldBgPal3+1
    cmp TargetPlayfieldBgPal3+1
    beq done_with_entry_1
    sta CurrentColor
    lda TargetPlayfieldBgPal3+1
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal3+1
    inc StagingBgPaletteDirty
done_with_entry_1:

    perform_zpcm_inc

    lda CurrentPlayfieldBgPal3+2
    cmp TargetPlayfieldBgPal3+2
    beq done_with_entry_2
    sta CurrentColor
    lda TargetPlayfieldBgPal3+2
    sta TargetColor
    jsr step_hue
    jsr step_luminence
    lda CurrentColor
    sta CurrentPlayfieldBgPal3+2
    inc StagingBgPaletteDirty
done_with_entry_2:
    
    rts
.endproc

.proc _compute_palette_ptr
HardwarePalLutPtr := R0
    ; The current brightness is specified in 16-entry rows, so we
    ; just need to add it to our base pointer here. Which base pointer
    ; we use depends on the current colorspace

    lda current_save + SaveFile::OptionPpuType
    cmp #OPTION_PPU_TYPE_COMPOSITE
    beq composite_colorspaces
    cmp #OPTION_PPU_TYPE_RGB
    beq rgb_colorspaces
    lda ppu_type
    cmp #PPU_TYPE_COMPOSITE
    beq composite_colorspaces
    ; fall through to rgb
rgb_colorspaces:
    lda current_save + SaveFile::OptionColorspace
    cmp #COLORSPACE_GREENSCALE
    beq use_rgb_greenscale
    cmp #COLORSPACE_GREYSCALE
    beq use_rgb_greyscale
use_rgb_normal:
    clc
    lda #<dynamic_palette_rgbppu
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_rgbppu
    adc #0
    sta HardwarePalLutPtr+1
    rts
use_rgb_greenscale:
    clc
    lda #<dynamic_palette_rgbppu_greenscale
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_rgbppu_greenscale
    adc #0
    sta HardwarePalLutPtr+1
    rts
use_rgb_greyscale:
    clc
    lda #<dynamic_palette_rgbppu_greyscale
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_rgbppu_greyscale
    adc #0
    sta HardwarePalLutPtr+1
    rts

composite_colorspaces:
    lda current_save + SaveFile::OptionColorspace
    cmp #COLORSPACE_GREENSCALE
    beq use_greenscale
    cmp #COLORSPACE_GREYSCALE
    beq use_greyscale
use_normal:
    clc
    lda #<dynamic_palette_normal
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_normal
    adc #0
    sta HardwarePalLutPtr+1
    rts
use_greenscale:
    clc
    lda #<dynamic_palette_greenscale
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_greenscale
    adc #0
    sta HardwarePalLutPtr+1
    rts
use_greyscale:
    clc
    lda #<dynamic_palette_greyscale
    adc Brightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_greyscale
    adc #0
    sta HardwarePalLutPtr+1
    rts
.endproc

.proc compute_staging_bg_palette
HardwarePalLutPtr := R0
    perform_zpcm_inc

    lda StagingBgPaletteDirty
    bne do_the_work
    rts
do_the_work:
    lda #0
    sta StagingBgPaletteDirty

    jsr _compute_palette_ptr

    ; Now run through and work out what the staging palette should be for
    ; the entire set of colors. Don't overcomplicate this, just do the whole
    ; thing reeeeally fast.

    ldy CurrentPlayfieldBackdrop
    lda (HardwarePalLutPtr), y
    sta staging_palette+0  ; TODO: redundant?
    sta staging_palette+16
    ldy CurrentPlayfieldBgPal0+0 ; 4
    lda (HardwarePalLutPtr), y   ; 5
    sta staging_palette+1        ; 3
    ldy CurrentPlayfieldBgPal0+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+2
    ldy CurrentPlayfieldBgPal0+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+3

    ldy CurrentPlayfieldBgPal1+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+5
    ldy CurrentPlayfieldBgPal1+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+6
    ldy CurrentPlayfieldBgPal1+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+7

    perform_zpcm_inc


    ldy CurrentPlayfieldBgPal2+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+9
    ldy CurrentPlayfieldBgPal2+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+10
    ldy CurrentPlayfieldBgPal2+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+11

    ldy CurrentPlayfieldBgPal3+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+13
    ldy CurrentPlayfieldBgPal3+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+14
    ldy CurrentPlayfieldBgPal3+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+15

    perform_zpcm_inc
    rts
.endproc

; Separated out because the HUD often doesn't need to
.proc compute_staging_obj_palette
HardwarePalLutPtr := R0
    perform_zpcm_inc
    lda StagingObjPaletteDirty
    bne do_the_work
    rts
do_the_work:
    lda #0
    sta StagingObjPaletteDirty
    
    jsr _compute_palette_ptr

    ; Now run through and work out what the staging palette should be for
    ; the entire set of colors. Don't overcomplicate this, just do the whole
    ; thing reeeeally fast.

    ldy PlayfieldObjPal0+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+17
    ldy PlayfieldObjPal0+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+18
    ldy PlayfieldObjPal0+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+19

    ldy PlayfieldObjPal1+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+21
    ldy PlayfieldObjPal1+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+22
    ldy PlayfieldObjPal1+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+23

    perform_zpcm_inc

    ldy PlayfieldObjPal2+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+25
    ldy PlayfieldObjPal2+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+26
    ldy PlayfieldObjPal2+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+27

    ldy PlayfieldObjPal3+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+29
    ldy PlayfieldObjPal3+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+30
    ldy PlayfieldObjPal3+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+31

    perform_zpcm_inc

    rts
.endproc

.proc compute_staging_hud_palette
HardwarePalLutPtr := R0
    perform_zpcm_inc

    lda StagingHudPaletteDirty
    bne do_the_work
    rts
do_the_work:
    lda #0
    sta StagingHudPaletteDirty
    
    jsr _compute_palette_ptr

    ; Now run through and work out what the staging palette should be for
    ; the entire set of colors. Don't overcomplicate this, just do the whole
    ; thing reeeeally fast.

    ldy HudBackdrop
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+0  ; TODO: redundant?
    sta HudStagingPalette+16
    ldy HudBgPal0+0 ; 4
    lda (HardwarePalLutPtr), y   ; 5
    sta HudStagingPalette+1        ; 3
    ldy HudBgPal0+1
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+2
    ldy HudBgPal0+2
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+3

    ldy HudBgPal1+0
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+5
    ldy HudBgPal1+1
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+6
    ldy HudBgPal1+2
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+7

    perform_zpcm_inc

    ldy HudBgPal2+0
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+9
    ldy HudBgPal2+1
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+10
    ldy HudBgPal2+2
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+11

    ldy HudBgPal3+0
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+13
    ldy HudBgPal3+1
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+14
    ldy HudBgPal3+2
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+15

    ldy HudObjPal0+0
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+17
    ldy HudObjPal0+1
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+18
    ldy HudObjPal0+2
    lda (HardwarePalLutPtr), y
    sta HudStagingPalette+19

    ldy HudSeparatorPal+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+4  ; TODO: redundant?
    sta staging_palette+20
    ldy HudSeparatorPal+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+8  ; TODO: redundant?
    sta staging_palette+24
    ldy HudSeparatorPal+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+12 ; TODO: redundant?
    sta staging_palette+28

    perform_zpcm_inc
    rts
.endproc

.proc update_brightness
        lda BrightnessDelay
        beq continue
        dec BrightnessDelay
        rts
continue:        
        lda TargetBrightness
        cmp Brightness
        beq done ; nothing to do
        bcc target_lower
target_higher:
        lda Brightness
        clc
        adc #$10
        sta Brightness
        jmp converge
target_lower:
        lda Brightness
        sec
        sbc #$10
        sta Brightness
converge:
        lda #1
        sta StagingBgPaletteDirty
        sta StagingObjPaletteDirty
        sta StagingHudPaletteDirty
        lda GlobalFadeSpeed
        sta BrightnessDelay
done:
        rts
.endproc

.proc palette_state_bgstep_01
    perform_zpcm_inc
    jsr step_bg0_color
    perform_zpcm_inc
    jsr step_bg1_color
    perform_zpcm_inc
    jsr update_brightness
    perform_zpcm_inc
    jsr compute_staging_bg_palette
    jsr compute_staging_obj_palette
    jsr compute_staging_hud_palette
    st16 PaletteStateFunc, palette_state_bgstep_23
    perform_zpcm_inc
    rts
.endproc

.proc palette_state_bgstep_23
    perform_zpcm_inc
    jsr step_bg2_color
    perform_zpcm_inc
    jsr step_bg3_color
    perform_zpcm_inc
    jsr update_brightness
    perform_zpcm_inc
    jsr compute_staging_bg_palette
    jsr compute_staging_obj_palette
    jsr compute_staging_hud_palette
    st16 PaletteStateFunc, palette_state_bgstep_01
    perform_zpcm_inc
    rts
.endproc

.proc FAR_refresh_palettes_gameloop
        jmp (PaletteStateFunc)
.endproc

; To use: preload PaletteTablePtr/PaletteTableBank with the desired palette
; table. This preps IncomingHwPalette, which should then be followed by
; one of the region specific loading routines. Note that this does not
; handle room variants, for that use the level_rooms routine.
.proc FAR_load_palette_by_colorspace
PaletteOffset    := R0
PalettePtr       := R2
PaletteTablePtr  := R4
PaletteTableBank := R6

        lda current_save + SaveFile::OptionColorspace
        asl
        sta PaletteOffset

        access_data_bank PaletteTableBank
        ldy PaletteOffset
        lda (PaletteTablePtr), y
        sta PalettePtr+0
        iny
        lda (PaletteTablePtr), y
        sta PalettePtr+1

        ldy #0
bg_loop:
        perform_zpcm_inc
        lda (PalettePtr), y
        sta IncomingHwPalette, y
        iny
        cpy #16
        bne bg_loop

        restore_previous_bank

        rts
.endproc