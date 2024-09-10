        .setcpu "6502"

        .include "beat_tracker.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "kernel.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "slowam.inc"
        .include "sprites.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage
current_sprite_ptr: .res 2

.segment "RAM"
sprite_table:
        .repeat MAX_METASPRITES
        .tag MetaSpriteState
        .endrepeat
starting_oam_index: .res 1

SHUFFLE_NEXT_SPRITE = (11 * 2)
SHUFFLE_NEXT_FRAME = (19 * 2)
SHUFFLE_MASK = %00011111

.segment "CODE_0"

floaty_sprite_lut:
        ; 8 entries for rising
        .byte 2, 2, 2, 2, 2, 2, 1, 1
        ; 8 entries for falling
        .byte 0, 0, 0, 0, 0, 0, 1, 1

.proc FAR_initialize_sprites
MetaSpriteIndex := R0
        perform_zpcm_inc
        lda #0
        sta MetaSpriteIndex
loop:
        perform_zpcm_inc
        ldx MetaSpriteIndex
        lda #0
        sta sprite_table + MetaSpriteState::PositionX, x
        sta sprite_table + MetaSpriteState::PositionY, x
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        sta sprite_table + MetaSpriteState::TileIndex, x
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        sta sprite_table + MetaSpriteState::SpecialBehavior, x
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        perform_zpcm_inc
        rts
.endproc

.proc FAR_disable_all_oam_entries
        lda #$F8
        perform_zpcm_inc
        .repeat 4, z
        .repeat 4, j
        .repeat 4, i
        sta SPRITE_TRANSFER_BASE + (20 * i) + (83 * (j + (z * 4))) + SelfModifiedSprite::PosY
        .endrepeat
        .endrepeat
        perform_zpcm_inc
        .endrepeat
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
        perform_zpcm_inc
        ldy CurrentOamIndex
        lda sprite_ptr_lut_low, y
        sta current_sprite_ptr+0
        lda sprite_ptr_lut_high, y
        sta current_sprite_ptr+1

        ; X position is always a straight copy for the left tile
        lda sprite_table + MetaSpriteState::PositionX, x

        ;sta SHADOW_OAM + OAM_X_POS, y
        ldy #SelfModifiedSprite::PosX
        sta (current_sprite_ptr), y

        ; And that same position +8 for the right tile
        clc
        adc #8

        ;sta SHADOW_OAM + ONE_SPRITE + OAM_X_POS, y
        ldy #(SelfModifiedSprite::PosX + .sizeof(SelfModifiedSprite))
        sta (current_sprite_ptr), y

        perform_zpcm_inc

        ; Y position might be modified if we are in RISE mode
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_RISE
        bne rising_sprite_y
        ; Y position might be modified differently if we are in FLOAT mode (items use this)
        lda sprite_table + MetaSpriteState::SpecialBehavior, x
        and #SPRITE_FLOAT
        bne floating_sprite_y
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

        ldy TrackedGameplayPos
        lda tracked_row_buffer, y
        sta ScratchByte

        pla
        sec
        sbc ScratchByte
        jmp write_sprite_y
floating_sprite_y:
        ; Sprite position is the original position minus an entry in the
        ; float lut, which is itself indexed by the current musical beat and
        ; the tracked row within that beat
        lda CurrentBeat
        asl ; x2
        asl ; x4
        asl ; x8
        and #%00001000 ; isolate that bit
        sta ScratchByte
        ldy TrackedMusicPos
        lda tracked_row_buffer, y
        and #%00000111
        ora ScratchByte
        ; Index
        tay
        lda sprite_table + MetaSpriteState::PositionY, x
        sec
        sbc floaty_sprite_lut, y
        ; jmp write_sprite_y ; fall through

write_sprite_y:
        ; -1 for the screen, +4 for the raster split
        clc
        adc #3
        ; perform the write

        ;sta SHADOW_OAM + OAM_Y_POS, y
        ldy #SelfModifiedSprite::PosY
        sta (current_sprite_ptr), y

        ;sta SHADOW_OAM + ONE_SPRITE + OAM_Y_POS, y
        ldy #(SelfModifiedSprite::PosY + .sizeof(SelfModifiedSprite))
        sta (current_sprite_ptr), y

        perform_zpcm_inc

        ; Sprite tile may be inverted if we are horizontally flipped
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_HORIZ_FLIP
        bne horizontal_flip
no_horizontal_flip:
        lda sprite_table + MetaSpriteState::TileIndex, x
        
        ;sta SHADOW_OAM + OAM_TILE, y
        ldy #SelfModifiedSprite::TileId
        sta (current_sprite_ptr), y

        clc
        adc #2
        
        ;sta SHADOW_OAM + ONE_SPRITE + OAM_TILE, y
        ldy #(SelfModifiedSprite::TileId + .sizeof(SelfModifiedSprite))
        sta (current_sprite_ptr), y

        perform_zpcm_inc

        jmp attribute_byte
horizontal_flip:
        lda sprite_table + MetaSpriteState::TileIndex, x
        
        ;sta SHADOW_OAM + ONE_SPRITE + OAM_TILE, y
        ldy #(SelfModifiedSprite::TileId + .sizeof(SelfModifiedSprite))
        sta (current_sprite_ptr), y

        clc
        adc #2
        
        ;sta SHADOW_OAM + OAM_TILE, y
        ldy #SelfModifiedSprite::TileId
        sta (current_sprite_ptr), y

        perform_zpcm_inc

attribute_byte:
        ; The attribute byte is always a straight copy
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        
        ;sta SHADOW_OAM + OAM_ATTRIBUTES, y
        ldy #SelfModifiedSprite::Attributes
        sta (current_sprite_ptr), y

        ;sta SHADOW_OAM + ONE_SPRITE + OAM_ATTRIBUTES, y
        ldy #(SelfModifiedSprite::Attributes + .sizeof(SelfModifiedSprite))
        sta (current_sprite_ptr), y

        perform_zpcm_inc

        ; finally, we did a draw, so advance the OAM index
        lda CurrentOamIndex
        clc
        adc #SHUFFLE_NEXT_SPRITE
        and #SHUFFLE_MASK
        sta CurrentOamIndex
done:
        rts
.endproc

.proc FAR_draw_sprites
MetaSpriteIndex := R0
CurrentOamIndex := R1
        near_call FAR_disable_all_oam_entries
        lda #0
        sta MetaSpriteIndex
        lda starting_oam_index
        sta CurrentOamIndex
loop:
        perform_zpcm_inc
        jsr draw_sprite
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        perform_zpcm_inc
        ; shuffle our starting OAM index every frame
        lda starting_oam_index
        clc
        adc #SHUFFLE_NEXT_FRAME
        and #SHUFFLE_MASK
        sta starting_oam_index
        rts 
.endproc

; Locates the next inactive sprite slot in the table, starting
; from the beginning. If a sprite is found, its index will be returned in
; R0. If no sprite is found, $FF is returned instead; check for this if you
; need to handle failure.
.proc FAR_find_unused_sprite
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
loop:
        perform_zpcm_inc
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
        rts
found:
        ; initialize some things
        ldx MetaSpriteIndex
        lda #0
        sta sprite_table + MetaSpriteState::SpecialBehavior, x
        rts
.endproc

; Call this at the start of each beat
.proc FAR_age_sprites
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
loop:
        perform_zpcm_inc
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
        perform_zpcm_inc
        rts
.endproc

; If it's not the player sprite or a hud sprite, kill it with fire
.proc FAR_despawn_unimportant_sprites
MetaSpriteIndex := R0
        lda #0
        sta MetaSpriteIndex
        ldy #0
loop:
        perform_zpcm_inc
        lda MetaSpriteIndex
        cmp PlayerSpriteIndex
        beq skip

        ; TODO: populate this with any sprites spawned by the HUD
        ; oooooorrrrr, we could add an "important" flag to the sprite's
        ; metadata... y'know. *fix this*

        ;cmp HudWeaponSpriteIndex
        ;beq skip

        lda #0
        ldx MetaSpriteIndex
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
skip:
        lda #.sizeof(MetaSpriteState)
        clc
        adc MetaSpriteIndex
        cmp #(.sizeof(MetaSpriteState) * MAX_METASPRITES)
        beq done
        sta MetaSpriteIndex
        jmp loop
done:
        perform_zpcm_inc
        rts
.endproc