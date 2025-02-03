        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "enemies.inc"
        .include "far_call.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "procgen.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "signs.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "LEVEL_DATA_ROOMS_0"

        .include "../build/rooms/Grasslands/Grasslands_Standard.incs"
        .include "../build/rooms/Caves/Caves_Standard.incs"
        .include "../build/rooms/Misc/OutOfBounds.incs"

        .segment "LEVEL_DATA_ROOMS_1"

        .include "../build/rooms/Challenge/ChallengeArena_Standard.incs"
        .include "../build/rooms/Grasslands/Grasslands_Round.incs"
        .include "../build/rooms/Misc/Shop_Standard.incs"        

        .segment "LEVEL_DATA_ROOMS_2"

        .include "../build/rooms/Blocking/Blocking_Chamber.incs"
        .include "../build/rooms/Blocking/Blocking_Cave.incs"
        .include "../build/rooms/Hub/SpawnRoom.incs"
        .include "../build/rooms/Hub/BigDoorRoom.incs"
        .include "../build/rooms/Hub/DebugRoom1.incs"
        .include "../build/rooms/Hub/DebugRoom2.incs"
        .include "../build/rooms/Hub/DebugRoom3.incs"
        .include "../build/rooms/Hub/DebugRoom4.incs"
        .include "../build/rooms/Hub/DebugRoom5.incs"

        .segment "LEVEL_DATA_ROOMS_3"

        .include "../build/rooms/Blocking/Blocking_Boss.incs"

        .include "../build/rooms/Blocking/Blocking_NormalExit_Zone2.incs"
        .include "../build/rooms/Blocking/Blocking_NormalExit_Zone3.incs"
        .include "../build/rooms/Blocking/Blocking_NormalExit_Zone4.incs"
        .include "../build/rooms/Blocking/Blocking_NormalExit_Zone5.incs"

        .include "../build/rooms/Blocking/Blocking_WarpExit_Zone2.incs"

        .segment "LEVEL_DATA_ROOMS_4"

        .include "../build/rooms/Blocking/Blocking_WarpExit_Zone3.incs"
        .include "../build/rooms/Blocking/Blocking_WarpExit_Zone4.incs"
        .include "../build/rooms/Blocking/Blocking_WarpExit_Zone5.incs"
        .include "../build/rooms/Blocking/Blocking_WarpChamber.incs"

        .segment "CODE_4"

room_pools_lut:
        .word room_pool_out_of_bounds
        .word room_pool_grassy_exterior
        .word room_pool_cave_interior
        .word room_pool_hub_world_set_spawn
        .word room_pool_blocking_chamber
        .word room_pool_blocking_cave
        .word room_pool_hub_world_set_big_door
        .word room_pool_hub_world_set_debug1
        .word room_pool_hub_world_set_debug2
        .word room_pool_hub_world_set_debug3
        .word room_pool_hub_world_set_debug4
        .word room_pool_hub_world_set_debug5
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_1_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_2A_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_2B_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_2C_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_2W_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_3A_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_3B_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_3C_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_3W_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_4A_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_4B_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_4C_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_4W_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_5S_BOSS
        .word room_pool_blocking_boss      ; ROOM_POOL_ZONE_5W_BOSS
        .word room_pool_zone_2_normal_exit
        .word room_pool_zone_3_normal_exit
        .word room_pool_zone_4_normal_exit
        .word room_pool_zone_5_normal_exit
        .word room_pool_zone_2_warp
        .word room_pool_zone_3_warp
        .word room_pool_zone_4_warp
        .word room_pool_zone_5_warp

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
        .byte 1 ; Length
        room_entry room_OutOfBounds

room_pool_grassy_exterior:
        .byte 4 ; Length
        room_entry room_Grasslands_Standard
        room_entry room_Grasslands_Round
        room_entry room_Shop_Standard
        room_entry room_ChallengeArena_Standard

room_pool_cave_interior:
        .byte 4 ; Length
        room_entry room_Caves_Standard
        room_entry room_Caves_Standard
        room_entry room_Shop_Standard
        room_entry room_ChallengeArena_Standard

room_pool_hub_world_set_spawn:
        .byte 1 ; Length
        room_entry room_SpawnRoom

room_pool_hub_world_set_big_door:
        .byte 1 ; Length
        room_entry room_BigDoorRoom

room_pool_hub_world_set_debug1:
        .byte 1 ; Length
        room_entry room_DebugRoom1
        
room_pool_hub_world_set_debug2:
        .byte 1 ; Length
        room_entry room_DebugRoom2

room_pool_hub_world_set_debug3:
        .byte 1 ; Length
        room_entry room_DebugRoom3

room_pool_hub_world_set_debug4:
        .byte 1 ; Length
        room_entry room_DebugRoom4

room_pool_hub_world_set_debug5:
        .byte 1 ; Length
        room_entry room_DebugRoom5

room_pool_blocking_chamber:
        .byte 4
        room_entry room_Blocking_Chamber
        room_entry room_Blocking_Chamber
        room_entry room_Shop_Standard
        room_entry room_ChallengeArena_Standard

room_pool_blocking_cave:
        .byte 4
        room_entry room_Blocking_Cave
        room_entry room_Blocking_Cave
        room_entry room_Shop_Standard
        room_entry room_ChallengeArena_Standard

room_pool_blocking_boss:
        .byte 1 ; Length
        room_entry room_Blocking_Boss

room_pool_zone_2_normal_exit:
        .byte 1 ; Length
        room_entry room_Blocking_NormalExit_Zone2

room_pool_zone_3_normal_exit:
        .byte 1 ; Length
        room_entry room_Blocking_NormalExit_Zone3

room_pool_zone_4_normal_exit:
        .byte 1 ; Length
        room_entry room_Blocking_NormalExit_Zone4

room_pool_zone_5_normal_exit:
        .byte 1 ; Length
        room_entry room_Blocking_NormalExit_Zone5

room_pool_zone_2_warp:
        .byte 4 ; Length
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpExit_Zone2

room_pool_zone_3_warp:
        .byte 4 ; Length
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpExit_Zone3

room_pool_zone_4_warp:
        .byte 4 ; Length
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpExit_Zone4

room_pool_zone_5_warp:
        .byte 4 ; Length
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpChamber
        room_entry room_Blocking_WarpExit_Zone5

        sprite_palette_overworld:
                .incbin "../art/sprite_palette_overworld.pal"
        sprite_palette_underworld:
                .incbin "../art/sprite_palette.pal"

        oob_palette:
                .incbin "../art/oob_palette.pal"
                .incbin "../art/oob_palette.pal"
                .incbin "../art/oob_palette.pal"
                .incbin "../art/oob_palette.pal"
                .incbin "../art/oob_palette.pal"
        test_palette:
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
        grassy_palette:
                .incbin "../art/palettes/grasslands/base.pal"
                .incbin "../art/palettes/grasslands/scorched.pal"
                .incbin "../art/palettes/grasslands/frozen.pal"
                .incbin "../art/palettes/grasslands/shocked.pal"
                .incbin "../art/palettes/grasslands/overgrown.pal"
        dank_cave_palette:
                .incbin "../art/palettes/caves/base.pal"
                .incbin "../art/palettes/caves/scorched.pal"
                .incbin "../art/palettes/caves/frozen.pal"
                .incbin "../art/palettes/caves/shocked.pal"
                .incbin "../art/palettes/caves/overgrown.pal"
        challenge_pit_darkblue:
                .incbin "../art/challenge_pit_darkblue.pal"
                .incbin "../art/challenge_pit_darkblue.pal"
                .incbin "../art/challenge_pit_darkblue.pal"
                .incbin "../art/challenge_pit_darkblue.pal"
                .incbin "../art/challenge_pit_darkblue.pal"
        challenge_pit_darkred:
                .incbin "../art/palettes/challenge_darkred/base.pal"
                .incbin "../art/palettes/challenge_darkred/scorched.pal"
                .incbin "../art/palettes/challenge_darkred/frozen.pal"
                .incbin "../art/palettes/challenge_darkred/shocked.pal"
                .incbin "../art/palettes/challenge_darkred/overgrown.pal"
        shop_palette:
                .incbin "../art/shop_palette.pal"
                .incbin "../art/shop_palette.pal"
                .incbin "../art/shop_palette.pal"
                .incbin "../art/shop_palette.pal"
                .incbin "../art/shop_palette.pal"
        hub_world_palette:
                .incbin "../art/hub_world_palette.pal"
                .incbin "../art/hub_world_palette.pal"
                .incbin "../art/hub_world_palette.pal"
                .incbin "../art/hub_world_palette.pal"
                .incbin "../art/hub_world_palette.pal"
        blocking_exterior_palette:
                .incbin "../art/palettes/blocking_exterior/base.pal"
                .incbin "../art/palettes/blocking_exterior/scorched.pal"
                .incbin "../art/palettes/blocking_exterior/frozen.pal"
                .incbin "../art/palettes/blocking_exterior/shocked.pal"
                .incbin "../art/palettes/blocking_exterior/overgrown.pal"
        blocking_interior_palette:
                .incbin "../art/palettes/blocking_interior/base.pal"
                .incbin "../art/palettes/blocking_interior/scorched.pal"
                .incbin "../art/palettes/blocking_interior/frozen.pal"
                .incbin "../art/palettes/blocking_interior/shocked.pal"
                .incbin "../art/palettes/blocking_interior/overgrown.pal"

        warp_palette:
                .incbin "../art/palettes/warp_zone/base.pal"
                .incbin "../art/palettes/warp_zone/scorched.pal"
                .incbin "../art/palettes/warp_zone/frozen.pal"
                .incbin "../art/palettes/warp_zone/shocked.pal"
                .incbin "../art/palettes/warp_zone/overgrown.pal"

; more general variant: assumes nothing, sets thing up, etc etc
.proc FAR_load_palette_for_current_room
RoomPtr := R0
RoomBank := R2
        ldx PlayerRoomIndex
        lda room_bank, x
        sta RoomBank
        lda room_ptr_low, x
        sta RoomPtr+0
        lda room_ptr_high, x
        sta RoomPtr+1
        access_data_bank RoomBank 
        near_call FAR_load_room_palette
        restore_previous_bank
        rts
.endproc

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

        ldy PlayerRoomIndex
        lda room_palette_variant, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc PalettePtr+0
        sta PalettePtr+0
        lda #0
        adc PalettePtr+1
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

; TODO: Rework this so that rooms can be drawn from a pool
; of any length. Trying to cram everything into 16-length lists
; was fine during the compo, but isn't flexible enough for the
; final game we are heading towards.
.proc FAR_roll_room_from_floorplan_at_current_index
RoomPoolPtr := R2
RoomPoolBank := R4
CurrentRoomIndex := R5
RoomPtr := R7
RoomBank := R9

ListLengthTemp := R9

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

        ; The first byte of every room pool denotes the number of entries,
        ; which is the modulus we'll perform when rolling a chamber
        ldy #0
        lda (RoomPoolPtr), y
        sta ListLengthTemp
        inc16 RoomPoolPtr

        in_range_smol next_floor_rand, ListLengthTemp
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


