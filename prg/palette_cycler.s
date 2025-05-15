        .include "battlefield.inc"
        .include "palette_cycler.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "PRGRAM"

; this is way too many honestly, but it's a reasonable upper bounds
; if we ACTUALLY queue up this many flashing tiles, we will probably lag
MAX_TILES_TO_CYCLE = 16
FRAMES_TO_CYCLE = 16

tiles_to_cycle: .res ::MAX_TILES_TO_CYCLE
num_tiles_to_cycle: .res 1
frames_remaining: .res 1

WarpTilePos: .res 1
WarpCycleCooldown: .res 1

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
        ; sanity: don't run on an empty list!!
        ldx num_tiles_to_cycle
        beq not_found
        ldx #0
scan_loop:
        perform_zpcm_inc
        cmp tiles_to_cycle, x
        beq fix_it_loop
        inx
        cpx num_tiles_to_cycle
        beq not_found
        jmp scan_loop
fix_it_loop:
        perform_zpcm_inc
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

        .segment "CODE_0"

; call this once, during beat_1, BEFORE resolving the player (who is generally
; indirectly triggering this logic via enemy routines)
.proc FAR_reset_palette_cycler
        lda #0
        sta num_tiles_to_cycle
        lda #FRAMES_TO_CYCLE
        sta frames_remaining
        rts
.endproc

; Generally call this when switching rooms, to clear out the
; previously-known warp tile. If there is a tile active, it'll
; set its index on its first update, which is typically immediately
; following the slide-in transition. That's good enough to fool the eye.
.proc FAR_reset_palette_warp_tile
        lda #0
        sta WarpCycleCooldown
        lda #$FF
        sta WarpTilePos
        rts
.endproc

.proc FAR_update_palette_cycler
CurrentTile := R0
TargetIndex := R1
AttributeAddr := R2

HighRowScratch := R4
LowRowScratch := R5
        lda WarpTilePos
        cmp #$FF
        beq skip_warp_tile_cycler
        sta TargetIndex
        lda WarpCycleCooldown
        beq perform_warp_update
        dec WarpCycleCooldown
        jmp skip_warp_tile_cycler
perform_warp_update:
        lda #2
        sta WarpCycleCooldown
        jsr _cycle_target_tile
skip_warp_tile_cycler:

        ; typically palette cycling should cease after 8 frames or so
        lda frames_remaining
        bne perform_update
        rts

perform_update:
        lda #0
        sta CurrentTile
loop:
        perform_zpcm_inc
        ldx CurrentTile
        cpx num_tiles_to_cycle
        beq done

        lda tiles_to_cycle, x
        sta TargetIndex

        jsr _cycle_target_tile

        ; onward!
        inc CurrentTile
        jmp loop

done:
        dec frames_remaining
        perform_zpcm_inc
        rts
.endproc

.proc _cycle_target_tile
TargetIndex := R1
AttributeAddr := R2

HighRowScratch := R4
LowRowScratch := R5
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
        rts
.endproc

; Call this when you've enabled palette cycling for an enemy, but it's
; after the "reset" beat. This will correct their active palette (right now) to match
; what it "should" be, so that the rest of the effect plays out in sync. Meant for when
; we need to start palette cycling in enemy logic rather than in response to player
; logic. Tile index in A as usual
.proc FAR_queue_late_cycle_phase
TempPal := R0
TargetIndex := R1
AttributeAddr := R2

HighRowScratch := R4
LowRowScratch := R5
        sta TargetIndex
        ; First up, queue this palette cycle normally
        jsr queue_palette_cycle
        ; Now we need to find that tile and fix its current attributes.
        ; This bit is just like _cycle_target_tile
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

        ; Now that we have this, work out the new attribute. The "frames remaining" counter
        ; works backwards, so first compute the number of ticks that have already run,
        ; mod 4
        lda #FRAMES_TO_CYCLE
        sec
        sbc frames_remaining
        and #%00000011
        ; now we need to add this to the palette bits, so get that shifted into place
        clc
        ror ; 0000000x x
        ror ; x0000000 x
        ror ; xx000000 0
        ; and stash it, we'll use it four times
        sta TempPal

        ; Now we just tickle the palette accordingly by adding our computed
        ; TempPal to the existing palette
        ldy #0
        lda TempPal
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #1
        lda TempPal
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #32
        lda TempPal
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y

        ldy #33
        lda TempPal
        clc
        adc (AttributeAddr), y
        sta (AttributeAddr), y
        rts
.endproc