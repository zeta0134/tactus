        .include "battlefield.inc"
        .include "palette_cycler.inc"
        .include "zeropage.inc"

        .segment "PRGRAM"

; this is way too many honestly, but it's a reasonable upper bounds
; if we ACTUALLY queue up this many flashing tiles, we will probably lag
MAX_TILES_TO_CYCLE = 16
FRAMES_TO_CYCLE = 16

tiles_to_cycle: .res ::MAX_TILES_TO_CYCLE
num_tiles_to_cycle: .res 1
frames_remaining: .res 1

        .segment "PRGFIXED_E000"

; this routine is tiny, and enemies will be calling it often-ish
; put the tile index to cycle in A
; clobbers X
.proc queue_palette_cycle
        ldx num_tiles_to_cycle
        cpx #MAX_TILES_TO_CYCLE
        beq full
        sta tiles_to_cycle, x
        inc num_tiles_to_cycle
full:
        rts
.endproc

; for those situations when you need to go "oh no, wait, it's over here now"
; tile to unqueue in A, for heck's sake we assume it only exists once in the list,
; don't expect this to work correctly if it's not
; clobbers A, X
.proc unqueue_palette_cycle
        ldx #0
scan_loop:
        cmp tiles_to_cycle, x
        beq fix_it_loop
        inx
        cpx num_tiles_to_cycle
        beq not_found
        jmp scan_loop
fix_it_loop:
        lda tiles_to_cycle+1, x
        sta tiles_to_cycle, x
        inx
        cpx num_tiles_to_cycle
        bne fix_it_loop
        dec num_tiles_to_cycle
        lda #$00 ; 0 = success
        rts
not_found:
        lda #$FF ; nonzero = failure
        rts
.endproc

; like unqueue, but immediately queues a new destination stored in Y
.proc move_palette_cycle
        jsr unqueue_palette_cycle
        ; at this point, if A is #$00 then we found an entry to remove
        ; in that case, go ahead and queue up the unclobbered index in Y
        bne done
        tya
        jsr queue_palette_cycle
done:
        rts
.endproc

        .segment "CODE_1"

; call this once, during beat_1, BEFORE resolving the player (who is generally
; indirectly triggering this logic via enemy routines)
.proc FAR_reset_palette_cycler
        lda #0
        sta num_tiles_to_cycle
        lda #FRAMES_TO_CYCLE
        sta frames_remaining
        rts
.endproc

.proc FAR_update_palette_cycler
CurrentTile := R0
TargetIndex := R1
AttributeAddr := R2

HighRowScratch := R4
LowRowScratch := R5
        ; typically palette cycling should cease after 8 frames or so
        lda frames_remaining
        bne perform_update
        rts

perform_update:
        lda #0
        sta CurrentTile
loop:
        ldx CurrentTile
        cpx num_tiles_to_cycle
        beq done

        lda tiles_to_cycle, x
        sta TargetIndex

        ; we always cycle the active buffer. the initial setup looks very similar to
        ; drawing a tile, except we only care about the attribute pointer

        ; work out the high bits of the row, these are the top 4 bits of TargetIndex x64, so they
        ; are split across both nametable address bytes
        lda #0
        sta HighRowScratch

        lda TargetIndex
        asl
        rol HighRowScratch
        asl
        rol HighRowScratch
        and #%11000000
        sta LowRowScratch
        ; now deal with the column, which here is x2 (we'll do a +32 later to skip over the row)
        lda TargetIndex
        asl
        and #%00011110
        ora LowRowScratch
        sta AttributeAddr+0

        lda active_battlefield
        bne second_nametable
        lda #$58
        jmp set_high_byte
second_nametable:
        lda #$5C
set_high_byte:
        ora HighRowScratch
        sta AttributeAddr+1

        ; now all we need to do is tickle the attribute bytes by adding #64 to them
        ldy #0
        lda #64
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #1
        lda #64
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #32
        lda #64
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #33
        lda #64
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ; onward!
        inc CurrentTile
        jmp loop

done:
        dec frames_remaining
        rts
.endproc