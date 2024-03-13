        .setcpu "6502"

        .include "battlefield.inc" ; for queued bytes counter
        .include "branch_util.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "ppu.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .zeropage
staging_palette: .res 32

        .segment "RAM"
BgPaletteDirty: .res 1
ObjPaletteDirty: .res 1
BgPaletteBuffer: .res 16
ObjPaletteBuffer: .res 16
Brightness: .res 1
TargetBrightness: .res 1
BrightnessDelay: .res 1

hud_palette: .res 32

        .segment "CODE_0"

white_palette:
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30

light_palette_3:
        .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $10, $10, $10
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $10, $10
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $10, $10
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $10, $10

light_palette_2:
        .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $00, $00, $00
        .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $00, $00, $00
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $10, $00, $00
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $00, $00

light_palette_1:
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $2d, $2d, $2d
        .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2d, $2d
        .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $00, $2d, $2d
        .byte $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $2d, $2d

standard_palette:
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0f, $0e, $0f
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
        .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
        .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f

dark_palette_1:
        .byte $2d, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0f, $0e, $0f
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
        .byte $10, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f

dark_palette_2:
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $2d, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0f, $0e, $0f
        .byte $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f

dark_palette_3:
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $2d, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $2d, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0f, $0e, $0f

black_palette:
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
        .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f        

brightness_table:
        .word black_palette
        .word dark_palette_3
        .word dark_palette_2
        .word dark_palette_1
        .word standard_palette
        .word light_palette_1
        .word light_palette_2
        .word light_palette_3
        .word white_palette


.segment "PRGFIXED_E000"

; call with desired brightness in a
.proc set_brightness
        sta Brightness
        lda #1
        sta BgPaletteDirty
        sta ObjPaletteDirty
        rts
.endproc

.proc refresh_palettes_nmi 
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    perform_zpcm_inc
    .repeat 16,i
    lda staging_palette+i
    sta PPUDATA
    .endrepeat
    perform_zpcm_inc
    .repeat 16,i
    lda staging_palette+i+16
    sta PPUDATA
    .endrepeat
    perform_zpcm_inc
    rts
.endproc

.segment "CODE_0"

.proc FAR_init_palettes
        lda #$0F
        ldx #0
loop:
        perform_zpcm_inc
        sta staging_palette, x
        inx
        cpx #32
        bne loop

        rts
.endproc

.proc FAR_refresh_palettes_gameloop
PalAddr := R0
SourcePalIndex := R2
DestPalIndex := R3
        perform_zpcm_inc
        lda BgPaletteDirty
        ora ObjPaletteDirty
        jeq done

        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 32)
        bcc continue
        rts ; the queue is full; bail immediately
continue:
        perform_zpcm_inc

        lda Brightness
        asl
        tax
        lda brightness_table, x
        sta PalAddr
        lda brightness_table+1, x
        sta PalAddr+1

        lda BgPaletteDirty
        beq check_obj_palette

        
        lda #0
        sta SourcePalIndex
        sta DestPalIndex
bg_loop:
        perform_zpcm_inc
        ; for the first entry, always use the global BG color
        ldx SourcePalIndex     ; From the original buffer
        ldy BgPaletteBuffer, x ; Grab a palette color
        lda (PalAddr), y       ; And use it to index the brightness table we picked
        ldx DestPalIndex
        sta staging_palette, x
        inc SourcePalIndex
        inc DestPalIndex

        ; for subsequent entries, use the palette colors
        .repeat 3
        ldx SourcePalIndex           ; From the original buffer
        ldy BgPaletteBuffer, x ; Grab a palette color
        lda (PalAddr), y       ; And use it to index the brightness table we picked
        ldx DestPalIndex
        sta staging_palette, x
        inc SourcePalIndex
        inc DestPalIndex
        .endrepeat

        lda #16
        cmp SourcePalIndex
        bne bg_loop

check_obj_palette:
        lda ObjPaletteDirty
        beq done

        lda #0
        sta SourcePalIndex
        lda #16
        sta DestPalIndex
obj_loop:
        perform_zpcm_inc
       ; for the first entry, always use the global *BG* color
        ldx SourcePalIndex
        ldy BgPaletteBuffer, x ; Grab a palette color
        lda (PalAddr), y       ; And use it to index the brightness table we picked
        ldx DestPalIndex
        sta staging_palette, x
        inc SourcePalIndex
        inc DestPalIndex

        ; for subsequent entries, use the Obj palette colors
        .repeat 3
        ldx SourcePalIndex           ; From the original buffer
        ldy ObjPaletteBuffer, x ; Grab a palette color
        lda (PalAddr), y       ; And use it to index the brightness table we picked
        ldx DestPalIndex
        sta staging_palette, x
        inc SourcePalIndex
        inc DestPalIndex
        .endrepeat

        lda #16
        cmp SourcePalIndex
        bne obj_loop

done:
        perform_zpcm_inc
        lda #0
        sta BgPaletteDirty
        sta ObjPaletteDirty

        lda queued_bytes_counter
        clc
        adc #32
        sta queued_bytes_counter

        rts
.endproc

.proc FAR_update_brightness
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
        inc Brightness
        jmp converge
target_lower:
        dec Brightness
converge:
        lda #1
        sta BgPaletteDirty
        sta ObjPaletteDirty
        lda #GLOBAL_PALETTE_FADE_SPEED
        sta BrightnessDelay
done:
        rts
.endproc
