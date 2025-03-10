    .include "dynamic_palette.inc"

    .include "far_call.inc"
    .include "rainbow.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

.zeropage
; Copied in during NMI where every cycle is precious. Spare no expense!
staging_palette: .res 32

        .segment "RAM"

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

PpuModeOffset: .res 1

StagingPaletteDirty: .res 1
CurrentBrightness: .res 1

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
    .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D ; Dest: RGB
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Dest: ---

hw_to_intermediate_equivalence_lut:
    ; Composite (uses $x0 for greyscale)
    .byte $20, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $00, $00, $00
    .byte $30, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $00, $00, $00
    .byte $50, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $10, $00, $00
    .byte $50, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $40, $00, $00
    ; RGB PPU (uses $xD for greyscale)
    .byte $2D, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $0D, $0D, $0D
    .byte $3D, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $0D, $0D, $0D
    .byte $5D, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $1D, $0D, $0D
    .byte $5D, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $0D, $0D

; For these, we assume the hardware palette has been preloaded into the RAM location.
; We do this to make bank switching saner, and because we don't really care too much
; about performance for this part of the code.

; Set the target when you want to smoothly fade from the current palette
.proc FAR_set_bg_target_palette_from_hw
    lda IncomingHwPalette+0
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBackdrop

    lda IncomingHwPalette+1
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+0
    lda IncomingHwPalette+2
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+1
    lda IncomingHwPalette+3
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal0+2

    lda IncomingHwPalette+5
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+0
    lda IncomingHwPalette+6
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+1
    lda IncomingHwPalette+7
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal1+2

    lda IncomingHwPalette+9
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+0
    lda IncomingHwPalette+10
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+1
    lda IncomingHwPalette+11
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal2+2

    lda IncomingHwPalette+13
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+0
    lda IncomingHwPalette+14
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+1
    lda IncomingHwPalette+15
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta TargetPlayfieldBgPal3+2

    inc StagingPaletteDirty
    rts
.endproc

; Set both when you need the change to be instant (ish)
.proc FAR_set_bg_current_palette_from_hw
    near_call FAR_set_bg_target_palette_from_hw
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

    inc StagingPaletteDirty
    rts
.endproc

; Obj and HUD palettes don't have a current/target setup, it's too expensive
.proc FAR_set_obj_palette_from_hw
    lda IncomingHwPalette+1
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+0
    lda IncomingHwPalette+2
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+1
    lda IncomingHwPalette+3
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal0+2

    lda IncomingHwPalette+5
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+0
    lda IncomingHwPalette+6
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+1
    lda IncomingHwPalette+7
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal1+2

    lda IncomingHwPalette+9
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+0
    lda IncomingHwPalette+10
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+1
    lda IncomingHwPalette+11
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal2+2

    lda IncomingHwPalette+13
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+0
    lda IncomingHwPalette+14
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+1
    lda IncomingHwPalette+15
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta PlayfieldObjPal3+2

    inc StagingPaletteDirty
    rts
.endproc

.proc FAR_set_hud_bg_palette_from_hw
    lda IncomingHwPalette+0
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBackdrop

    lda IncomingHwPalette+1
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+0
    lda IncomingHwPalette+2
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+1
    lda IncomingHwPalette+3
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal0+2

    lda IncomingHwPalette+5
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+0
    lda IncomingHwPalette+6
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+1
    lda IncomingHwPalette+7
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal1+2

    lda IncomingHwPalette+9
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+0
    lda IncomingHwPalette+10
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+1
    lda IncomingHwPalette+11
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal2+2

    lda IncomingHwPalette+13
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+0
    lda IncomingHwPalette+14
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+1
    lda IncomingHwPalette+15
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudBgPal3+2
    inc StagingPaletteDirty
    rts
.endproc

.proc FAR_set_hud_obj_palette_from_hw
    lda IncomingHwPalette+1
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+0
    lda IncomingHwPalette+2
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+1
    lda IncomingHwPalette+3
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudObjPal0+2
    inc StagingPaletteDirty
    rts
.endproc

.proc FAR_set_hud_separator_palette_from_hw
    lda IncomingHwPalette+1
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+0
    lda IncomingHwPalette+2
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+1
    lda IncomingHwPalette+3
    ora PpuModeOffset
    tax
    lda hw_to_intermediate_equivalence_lut, x
    sta HudSeparatorPal+2
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
done_with_entry_0:

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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
done_with_entry_1:

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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
done_with_entry_1:

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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
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
    inc StagingPaletteDirty
done_with_entry_1:

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
    inc StagingPaletteDirty
done_with_entry_2:
    
    rts
.endproc

.proc compute_staging_palette
HardwarePalLutPtr := R0
    lda StagingPaletteDirty
    bne do_the_work
    rts
do_the_work:
    lda #0
    sta StagingPaletteDirty
    
    ; The current brightness is specified in 16-entry rows, so we
    ; just need to add it to our base pointer here
    clc
    lda #<dynamic_palette_brightness_minus_5
    adc CurrentBrightness
    sta HardwarePalLutPtr+0
    lda #>dynamic_palette_brightness_minus_5
    adc #0
    sta HardwarePalLutPtr+1

    ; Now run through and work out what the staging palette should be for
    ; the entire set of colors. Don't overcomplicate this, just do the whole
    ; thing reeeeally fast.

    ldy CurrentPlayfieldBackdrop
    lda (HardwarePalLutPtr), y
    sta staging_palette+0  ; TODO: redundant?
    sta staging_palette+16
    ldy CurrentPlayfieldBgPal0+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+1
    ldy CurrentPlayfieldBgPal0+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+2
    ldy CurrentPlayfieldBgPal0+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+3

    ldy HudSeparatorPal+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+4  ; TODO: redundant?
    sta staging_palette+20
    ldy CurrentPlayfieldBgPal1+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+5
    ldy CurrentPlayfieldBgPal1+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+6
    ldy CurrentPlayfieldBgPal1+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+7

    ldy HudSeparatorPal+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+8  ; TODO: redundant?
    sta staging_palette+24
    ldy CurrentPlayfieldBgPal2+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+9
    ldy CurrentPlayfieldBgPal2+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+10
    ldy CurrentPlayfieldBgPal2+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+11

    ldy HudSeparatorPal+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+12 ; TODO: redundant?
    sta staging_palette+28
    ldy CurrentPlayfieldBgPal3+0
    lda (HardwarePalLutPtr), y
    sta staging_palette+13
    ldy CurrentPlayfieldBgPal3+1
    lda (HardwarePalLutPtr), y
    sta staging_palette+14
    ldy CurrentPlayfieldBgPal3+2
    lda (HardwarePalLutPtr), y
    sta staging_palette+15

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

    rts
.endproc