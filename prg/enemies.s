        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "kernel.inc"
        .include "zeropage.inc"


.segment "RAM"

.segment "PRGFIXED_C000"

static_behaviors:
        .word no_behavior     ; $00 - clock face
        .repeat 31
        .word no_behavior ; unimplemented
        .endrepeat
        .word draw_disco_tile ; $80 - plain floor
        .word draw_disco_tile ; $84 - disco floor
        .word no_behavior     ; $88 - wall top
        .word no_behavior     ; $8C - wall face
        .word no_behavior     ; $90 - pit edge
        ; safety: fill out the rest of the table
        .repeat 27
        .word no_behavior
        .endrepeat

; input tile in A
.proc draw_tile_here
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        sta battlefield, x
        ldx CurrentRow
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        sta inactive_attribute_queue
        rts
.endproc

.proc no_behavior
        ; does what it says on the tin
        rts
.endproc

.proc draw_disco_tile
CurrentRow := R14
CurrentTile := R15
        ; TODO: maybe if the player's combo gauge is empty, we don't do the disco thing?

        ; here we want to draw a checkerboard pattern, which alternates every time the beat advances
        ; we can do this with an XOR of these low bits: X coordinate, Y coordinate, Beat Counter
        lda CurrentRow
        eor CurrentTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile
regular_tile:
        lda #TILE_DISCO_FLOOR
        jsr draw_tile_here
        rts
disco_tile:
        lda #TILE_REGULAR_FLOOR
        jsr draw_tile_here
        rts
.endproc

.proc __trampoline
DestPtr := R0
        jmp (DestPtr)
        ; tail call
.endproc

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc update_static_enemy_row
DestPtr := R0
Length := R13
CurrentRow := R14
StartingTile := R15
        lda #::BATTLEFIELD_WIDTH
        sta Length
loop:
        ldx StartingTile
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda static_behaviors, x
        sta DestPtr
        lda static_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline
        inc StartingTile
        dec Length
        bne loop
        rts
.endproc

.proc update_dynamic_enemy_row
        ; TODO. Will have the same interface as static, and since these run later, they can have
        ; somewhat more intelligent selection of their destination without stepping on anyone's
        ; toes
        rts
.endproc