        .include "../build/tile_defs.inc"

        .include "enemies.inc"
        .include "far_call.inc"
        .include "levels.inc"
        .include "palette.inc"
        .include "procgen.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "LEVEL_DATA_ROOMS_0"

        .include "../build/rooms/Grasslands_Standard.incs"
        .include "../build/rooms/Caves_Standard.incs"
        .include "../build/rooms/OutOfBounds.incs"
        .include "../build/rooms/ChallengeArena_Standard.incs"

        .segment "LEVEL_DATA_ROOMS_1"

        .include "../build/rooms/Grasslands_Round.incs"
        .include "../build/rooms/Shop_Standard.incs"

        .segment "CODE_4"

room_pools_lut:
        .word room_pool_out_of_bounds
        .word room_pool_grassy_exterior
        .word room_pool_cave_interior

.macro room_entry room_label
        .addr room_label
        .byte <.bank(room_label), >.bank(room_label)
.endmacro

; =================================
; Room Pools - collections of rooms
; =================================

; these are what the floors will reference for their room pools
; 16 entries each

room_pool_out_of_bounds:
        ; You **really** shouldn't be here
        .repeat 16
        room_entry room_OutOfBounds
        .endrepeat

room_pool_grassy_exterior:
        .repeat 4
        room_entry room_Grasslands_Standard
        .endrepeat
        .repeat 4
        room_entry room_Grasslands_Round
        .endrepeat
        .repeat 4
        room_entry room_Shop_Standard
        .endrepeat
        .repeat 4
        room_entry room_ChallengeArena_Standard
        .endrepeat

room_pool_cave_interior:
        .repeat 8
        room_entry room_Caves_Standard
        .endrepeat
        .repeat 4
        room_entry room_Shop_Standard
        .endrepeat
        .repeat 4
        room_entry room_ChallengeArena_Standard
        .endrepeat

        sprite_palette_overworld:
        .incbin "../art/sprite_palette_overworld.pal"
        sprite_palette_underworld:
                .incbin "../art/sprite_palette.pal"

        oob_palette:
                .incbin "../art/oob_palette.pal"
        test_palette:
                .incbin "../art/test_palette.pal"
        grassy_palette:
                .incbin "../art/extra_grassy_palette.pal"
        dank_cave_palette:
                .incbin "../art/dank_cave.pal"
        challenge_pit_darkblue:
                .incbin "../art/challenge_pit_darkblue.pal"
        challenge_pit_darkred:
                .incbin "../art/challenge_pit_darkred.pal"
        shop_palette:
                .incbin "../art/shop_palette.pal"

; note: utility function, assumes the room data is already banked in, etc
; this code is colocated with the palettes so a simple far call is all that
; is needed to operate it
.proc FAR_load_room_palette
RoomPtr := R0
PalettePtr := R2
        ldy #Room::BgPalette
        lda (RoomPtr), y
        sta PalettePtr+0
        iny
        lda (RoomPtr), y
        sta PalettePtr+1

        ldy #0
bg_loop:
        perform_zpcm_inc
        lda (PalettePtr), y
        sta BgPaletteBuffer, y
        iny
        cpy #16
        bne bg_loop

        ldy #Room::ObjPalette
        lda (RoomPtr), y
        sta PalettePtr+0
        iny
        lda (RoomPtr), y
        sta PalettePtr+1

        ldy #0
obj_loop:
        perform_zpcm_inc
        lda (PalettePtr), y
        sta ObjPaletteBuffer, y
        iny
        cpy #16
        bne obj_loop

        lda #1
        sta BgPaletteDirty
        sta ObjPaletteDirty

        ; dirty fix: copy $0F into all three HUD colors, for parking between the raster split
        lda #$0F
        sta BgPaletteBuffer+4
        sta BgPaletteBuffer+8
        sta BgPaletteBuffer+12

        perform_zpcm_inc
        rts
.endproc

.proc FAR_roll_room_from_floorplan_at_current_index
RoomPoolPtr := R2
RoomPoolBank := R4
CurrentRoomIndex := R5
RoomPtr := R7
RoomBank := R9
        access_data_bank BigFloorBank

        perform_zpcm_inc
        ldy CurrentRoomIndex
        lda (BigFloorPtr), y ; read the room pool index from the floor plan
        asl
        tax
        lda room_pools_lut+0, x
        sta RoomPoolPtr+0
        lda room_pools_lut+1, x
        sta RoomPoolPtr+1

        jsr next_floor_rand
        and #$0F ; 0-15
        asl
        asl
        tay
        ldx CurrentRoomIndex
        lda (RoomPoolPtr), y
        sta room_ptr_low, x
        sta RoomPtr+0
        iny
        lda (RoomPoolPtr), y
        sta room_ptr_high, x
        sta RoomPtr+1
        iny
        lda (RoomPoolPtr), y
        sta room_bank, x
        sta RoomBank

        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc


