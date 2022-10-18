        .setcpu "6502"

        .include "bhop/bhop.inc"
        .include "nes.inc"
        .include "sprites.inc"
        .include "zeropage.inc"

.segment "RAM"
sprite_table:
        .repeat MAX_METASPRITES
        .tag MetaSpriteState
        .endrepeat
starting_oam_index: .res 1

SHUFFLE_NEXT_SPRITE = (11 * 8)
SHUFFLE_NEXT_FRAME = (19 * 8)

.segment "PRGFIXED_C000"

.proc initialize_sprites
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
loop:
        ldx MetaSpriteIndex
        lda #0
        sta sprite_table + MetaSpriteState::PositionX, x
        sta sprite_table + MetaSpriteState::PositionY, x
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        sta sprite_table + MetaSpriteState::TileIndex, x
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        rts
.endproc

.proc disable_all_oam_entries
        ldx #0
        lda #$F8
loop:
        sta SHADOW_OAM + OAM_Y_POS, x
        inx
        inx
        inx
        inx
        bne loop
        rts
.endproc

; Attempts to draw a single metasprite into OAM
.proc draw_sprite
MetaSpriteIndex := R0
CurrentOamIndex := R1
ScratchByte := R2
        ldx MetaSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ACTIVE
        bne check_beat_counter
do_not_draw:
        rts
check_beat_counter:
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ONE_BEAT
        beq draw
        lda sprite_table + MetaSpriteState::LifetimeBeats, x
        bne do_not_draw
draw:
        ldy CurrentOamIndex
        ; X position is always a straight copy for the left tile
        lda sprite_table + MetaSpriteState::PositionX, x
        sta SHADOW_OAM + OAM_X_POS, y
        ; And that same position +8 for the right tile
        clc
        adc #8
        sta SHADOW_OAM + ONE_SPRITE + OAM_X_POS, y
        ; Y position might be modified if we are in RISE mode
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_RISE
        bne rising_sprite_y
normal_sprite_y:
        lda sprite_table + MetaSpriteState::PositionY, x
        jmp write_sprite_y
rising_sprite_y:
        ; Sprite position is original Position Y, minus the number
        ; of rows this sprite has been alive.
        ; Each beat is 8 rows:
        lda sprite_table + MetaSpriteState::LifetimeBeats, x
        asl ; x2
        asl ; x4
        asl ; x8
        sta ScratchByte
        lda sprite_table + MetaSpriteState::PositionY, x
        sec
        sbc ScratchByte
        pha
        lda row_counter
        and #%00000111        
        sta ScratchByte
        pla
        sec
        sbc ScratchByte
write_sprite_y:
        sta SHADOW_OAM + OAM_Y_POS, y
        sta SHADOW_OAM + ONE_SPRITE + OAM_Y_POS, y
        ; Sprite tile may be inverted if we are horizontally flipped
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_HORIZ_FLIP
        bne horizontal_flip
no_horizontal_flip:
        lda sprite_table + MetaSpriteState::TileIndex, x
        sta SHADOW_OAM + OAM_TILE, y
        clc
        adc #2
        sta SHADOW_OAM + ONE_SPRITE + OAM_TILE, y
        jmp attribute_byte
horizontal_flip:
        lda sprite_table + MetaSpriteState::TileIndex, x
        sta SHADOW_OAM + ONE_SPRITE + OAM_TILE, y
        clc
        adc #2
        sta SHADOW_OAM + OAM_TILE, y
attribute_byte:
        ; The attribute byte is always a straight copy
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        sta SHADOW_OAM + OAM_ATTRIBUTES, y
        sta SHADOW_OAM + ONE_SPRITE + OAM_ATTRIBUTES, y
        ; finally, we did a draw, so advance the OAM index
        lda CurrentOamIndex
        clc
        adc #SHUFFLE_NEXT_SPRITE
        sta CurrentOamIndex
done:
        rts
.endproc

.proc draw_sprites
MetaSpriteIndex := R0
CurrentOamIndex := R1
        jsr disable_all_oam_entries
        lda #0
        sta MetaSpriteIndex
        lda starting_oam_index
        sta CurrentOamIndex
loop:
        jsr draw_sprite
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        ; shuffle our starting OAM index every frame
        lda starting_oam_index
        clc
        adc #SHUFFLE_NEXT_FRAME
        sta starting_oam_index
        rts 
.endproc

; Locates the next inactive sprite slot in the table, starting
; from the beginning. If a sprite is found, its index will be returned in
; R0. If no sprite is found, $FF is returned instead; check for this if you
; need to handle failure.
.proc find_unused_sprite
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
loop:
        ldx MetaSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ACTIVE
        beq found
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq table_is_full
        sta MetaSpriteIndex
        jmp loop
table_is_full:
        lda #$FF
        sta MetaSpriteIndex
found:
        rts
.endproc

; Call this at the start of each beat
.proc age_sprites
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
loop:
        ldx MetaSpriteIndex
        ; first off, if this sprite isn't active, do nothing
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ACTIVE
        beq skip
        ; Increment the beat counter unconditionally
        inc sprite_table + MetaSpriteState::LifetimeBeats, x
        ; If this sprite should only live for "one beat"...
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ONE_BEAT
        beq skip
        ; then check to see if we are now exactly "one" beat old...
        lda sprite_table + MetaSpriteState::LifetimeBeats, x
        cmp #1
        bne skip
        ; ... and if so, mark this sprite inactive
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        ; side note: only sprites with a beat lifetime of 0 beats are actually drawn,
        ; so you can use a beat lifeitme of $FF to spawn a sprite, but not *display* it
        ; until the start of the next beat, and still have it despawn on the following beat
skip:
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        rts
.endproc