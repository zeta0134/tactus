        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "procgen.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "saves.inc"
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

        sprite_palette_overworld_pal:
                .incbin "../art/sprite_palette_overworld.pal"
        sprite_palette_underworld_pal:
                .incbin "../art/sprite_palette.pal"

        oob_palette:
oob_pal_default_base:      .incbin "../art/oob_palette.pal"

        test_palette:
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"
                .incbin "../art/test_palette.pal"


; common palettes shared by many rooms, mostly monochrome
greyscale_pal:  .incbin "../art/palettes/greyscale.pal"
greenscale_pal: .incbin "../art/palettes/greenscale.pal"

; TODO: Remove unused palettes, and especially duplicates, since we're migrating to a table.
; Also, make sure the table entry supports a bank specification, we may end up with more than
; 8k of palette data :/

grasslands_pal_default_base:      .incbin "../art/palettes/grasslands/base.pal"
grasslands_pal_default_scorched:  .incbin "../art/palettes/grasslands/scorched.pal"
grasslands_pal_default_frozen:    .incbin "../art/palettes/grasslands/frozen.pal"
grasslands_pal_default_shocked:   .incbin "../art/palettes/grasslands/shocked.pal"
grasslands_pal_default_overgrown: .incbin "../art/palettes/grasslands/overgrown.pal"
grasslands_pal_protan_base:       .incbin "../art/palettes/grasslands/protan.pal"
grasslands_pal_tritan_base:       .incbin "../art/palettes/grasslands/tritan.pal"

cave_pal_default_base:      .incbin "../art/palettes/caves/base.pal"
cave_pal_default_scorched:  .incbin "../art/palettes/caves/scorched.pal"
cave_pal_default_frozen:    .incbin "../art/palettes/caves/frozen.pal"
cave_pal_default_shocked:   .incbin "../art/palettes/caves/shocked.pal"
cave_pal_default_overgrown: .incbin "../art/palettes/caves/overgrown.pal"
cave_pal_protan_base:       .incbin "../art/palettes/caves/protan.pal"
cave_pal_tritan_base:       .incbin "../art/palettes/caves/tritan.pal"

challenge_pit_darkred_pal_default_base:      .incbin "../art/palettes/challenge_darkred/base.pal"
challenge_pit_darkred_pal_default_scorched:  .incbin "../art/palettes/challenge_darkred/scorched.pal"
challenge_pit_darkred_pal_default_frozen:    .incbin "../art/palettes/challenge_darkred/frozen.pal"
challenge_pit_darkred_pal_default_shocked:   .incbin "../art/palettes/challenge_darkred/shocked.pal"
challenge_pit_darkred_pal_default_overgrown: .incbin "../art/palettes/challenge_darkred/overgrown.pal"
challenge_pit_darkred_pal_protan_base:       .incbin "../art/palettes/challenge_darkred/protan.pal"
challenge_pit_darkred_pal_tritan_base:       .incbin "../art/palettes/challenge_darkred/tritan.pal"

shop_pal_default_base:      .incbin "../art/palettes/shop/base.pal"
shop_pal_default_scorched:  .incbin "../art/palettes/shop/base.pal"
shop_pal_default_frozen:    .incbin "../art/palettes/shop/base.pal"
shop_pal_default_shocked:   .incbin "../art/palettes/shop/base.pal"
shop_pal_default_overgrown: .incbin "../art/palettes/shop/base.pal"
shop_pal_protan_base:       .incbin "../art/palettes/shop/protan.pal"
shop_pal_tritan_base:       .incbin "../art/palettes/shop/tritan.pal"

hub_world_pal_default_base:      .incbin "../art/hub_world_palette.pal"
hub_world_pal_default_scorched:  .incbin "../art/hub_world_palette.pal"
hub_world_pal_default_frozen:    .incbin "../art/hub_world_palette.pal"
hub_world_pal_default_shocked:   .incbin "../art/hub_world_palette.pal"
hub_world_pal_default_overgrown: .incbin "../art/hub_world_palette.pal"

blocking_exterior_pal_default_base:      .incbin "../art/palettes/blocking_exterior/base.pal"
blocking_exterior_pal_default_scorched:  .incbin "../art/palettes/blocking_exterior/scorched.pal"
blocking_exterior_pal_default_frozen:    .incbin "../art/palettes/blocking_exterior/frozen.pal"
blocking_exterior_pal_default_shocked:   .incbin "../art/palettes/blocking_exterior/shocked.pal"
blocking_exterior_pal_default_overgrown: .incbin "../art/palettes/blocking_exterior/overgrown.pal"
blocking_exterior_pal_protan_base:       .incbin "../art/palettes/blocking_exterior/protan.pal"
blocking_exterior_pal_tritan_base:       .incbin "../art/palettes/blocking_exterior/tritan.pal"
        
blocking_interior_pal_default_base:      .incbin "../art/palettes/blocking_interior/base.pal"
blocking_interior_pal_default_scorched:  .incbin "../art/palettes/blocking_interior/scorched.pal"
blocking_interior_pal_default_frozen:    .incbin "../art/palettes/blocking_interior/frozen.pal"
blocking_interior_pal_default_shocked:   .incbin "../art/palettes/blocking_interior/shocked.pal"
blocking_interior_pal_default_overgrown: .incbin "../art/palettes/blocking_interior/overgrown.pal"
blocking_interior_pal_protan_base:       .incbin "../art/palettes/blocking_interior/protan.pal"
blocking_interior_pal_tritan_base:       .incbin "../art/palettes/blocking_interior/tritan.pal"

warp_pal_default_base:       .incbin "../art/palettes/warp_zone/base.pal"
warp_pal_default_scorched:   .incbin "../art/palettes/warp_zone/scorched.pal"
warp_pal_default_frozen:     .incbin "../art/palettes/warp_zone/frozen.pal"
warp_pal_default_shocked:    .incbin "../art/palettes/warp_zone/shocked.pal"
warp_pal_default_overgrown:  .incbin "../art/palettes/warp_zone/overgrown.pal"
warp_pal_protan_tritan_base: .incbin "../art/palettes/warp_zone/protan_tritan.pal"

; TODO: Right now, only grasslands is accessible, and only in the room's default state. Make all the other palettes!
grasslands_exterior_palette_table:
        .addr grasslands_pal_default_base,      grasslands_pal_protan_base,       grasslands_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr grasslands_pal_default_scorched,  grasslands_pal_default_scorched,  grasslands_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr grasslands_pal_default_frozen,    grasslands_pal_default_frozen,    grasslands_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr grasslands_pal_default_shocked,   grasslands_pal_default_shocked,   grasslands_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr grasslands_pal_default_overgrown, grasslands_pal_default_overgrown, grasslands_pal_default_overgrown, greenscale_pal, greyscale_pal

cave_interior_palette_table:
        .addr cave_pal_default_base,      cave_pal_protan_base ,      cave_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr cave_pal_default_scorched,  cave_pal_default_scorched,  cave_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr cave_pal_default_frozen,    cave_pal_default_frozen,    cave_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr cave_pal_default_shocked,   cave_pal_default_shocked,   cave_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr cave_pal_default_overgrown, cave_pal_default_overgrown, cave_pal_default_overgrown, greenscale_pal, greyscale_pal

challenge_pit_darkred_palette_table:
        .addr challenge_pit_darkred_pal_default_base,      challenge_pit_darkred_pal_protan_base,       challenge_pit_darkred_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr challenge_pit_darkred_pal_default_scorched,  challenge_pit_darkred_pal_default_scorched,  challenge_pit_darkred_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr challenge_pit_darkred_pal_default_frozen,    challenge_pit_darkred_pal_default_frozen,    challenge_pit_darkred_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr challenge_pit_darkred_pal_default_shocked,   challenge_pit_darkred_pal_default_shocked,   challenge_pit_darkred_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr challenge_pit_darkred_pal_default_overgrown, challenge_pit_darkred_pal_default_overgrown, challenge_pit_darkred_pal_default_overgrown, greenscale_pal, greyscale_pal

shop_palette_table:
        .addr shop_pal_default_base,      shop_pal_protan_base,       shop_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr shop_pal_default_scorched,  shop_pal_default_scorched,  shop_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr shop_pal_default_frozen,    shop_pal_default_frozen,    shop_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr shop_pal_default_shocked,   shop_pal_default_shocked,   shop_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr shop_pal_default_overgrown, shop_pal_default_overgrown, shop_pal_default_overgrown, greenscale_pal, greyscale_pal

hub_world_palette_table:
        .addr hub_world_pal_default_base,      hub_world_pal_default_base,      hub_world_pal_default_base,      greenscale_pal, greyscale_pal
        .addr hub_world_pal_default_scorched,  hub_world_pal_default_scorched,  hub_world_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr hub_world_pal_default_frozen,    hub_world_pal_default_frozen,    hub_world_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr hub_world_pal_default_shocked,   hub_world_pal_default_shocked,   hub_world_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr hub_world_pal_default_overgrown, hub_world_pal_default_overgrown, hub_world_pal_default_overgrown, greenscale_pal, greyscale_pal

blocking_exterior_palette_table:
        .addr blocking_exterior_pal_default_base,      blocking_exterior_pal_protan_base,       blocking_exterior_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr blocking_exterior_pal_default_scorched,  blocking_exterior_pal_default_scorched,  blocking_exterior_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr blocking_exterior_pal_default_frozen,    blocking_exterior_pal_default_frozen,    blocking_exterior_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr blocking_exterior_pal_default_shocked,   blocking_exterior_pal_default_shocked,   blocking_exterior_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr blocking_exterior_pal_default_overgrown, blocking_exterior_pal_default_overgrown, blocking_exterior_pal_default_overgrown, greenscale_pal, greyscale_pal

blocking_interior_palette_table:
        .addr blocking_interior_pal_default_base,      blocking_interior_pal_protan_base,       blocking_interior_pal_tritan_base,       greenscale_pal, greyscale_pal
        .addr blocking_interior_pal_default_scorched,  blocking_interior_pal_default_scorched,  blocking_interior_pal_default_scorched,  greenscale_pal, greyscale_pal
        .addr blocking_interior_pal_default_frozen,    blocking_interior_pal_default_frozen,    blocking_interior_pal_default_frozen,    greenscale_pal, greyscale_pal
        .addr blocking_interior_pal_default_shocked,   blocking_interior_pal_default_shocked,   blocking_interior_pal_default_shocked,   greenscale_pal, greyscale_pal
        .addr blocking_interior_pal_default_overgrown, blocking_interior_pal_default_overgrown, blocking_interior_pal_default_overgrown, greenscale_pal, greyscale_pal

warp_palette_table:
        .addr warp_pal_default_base,      warp_pal_protan_tritan_base, warp_pal_protan_tritan_base, greenscale_pal, greyscale_pal
        .addr warp_pal_default_scorched,  warp_pal_default_scorched,   warp_pal_default_scorched,   greenscale_pal, greyscale_pal
        .addr warp_pal_default_frozen,    warp_pal_default_frozen,     warp_pal_default_frozen,     greenscale_pal, greyscale_pal
        .addr warp_pal_default_shocked,   warp_pal_default_shocked,    warp_pal_default_shocked,    greenscale_pal, greyscale_pal
        .addr warp_pal_default_overgrown, warp_pal_default_overgrown,  warp_pal_default_overgrown,  greenscale_pal, greyscale_pal

oob_palette_table:
        .addr oob_pal_default_base, oob_pal_default_base, oob_pal_default_base, greenscale_pal, greyscale_pal
        .addr oob_pal_default_base, oob_pal_default_base, oob_pal_default_base, greenscale_pal, greyscale_pal
        .addr oob_pal_default_base, oob_pal_default_base, oob_pal_default_base, greenscale_pal, greyscale_pal
        .addr oob_pal_default_base, oob_pal_default_base, oob_pal_default_base, greenscale_pal, greyscale_pal
        .addr oob_pal_default_base, oob_pal_default_base, oob_pal_default_base, greenscale_pal, greyscale_pal

; TODO: this, properly!
sprite_palette_overworld_table:
        .addr sprite_palette_overworld_pal, sprite_palette_overworld_pal, sprite_palette_overworld_pal, sprite_palette_overworld_pal, sprite_palette_overworld_pal
sprite_palette_underworld_table:
        .addr sprite_palette_underworld_pal, sprite_palette_underworld_pal, sprite_palette_underworld_pal, sprite_palette_underworld_pal, sprite_palette_underworld_pal

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

palette_offset_by_room_variant_lut:
        .repeat 8, i
        .byte i * 2 * 5 ; two bytes per address, 5 colorspaces total
        .endrepeat

.proc FAR_load_room_palette
RoomPtr := R0
PalettePtr := R2
PaletteTablePtr := R4
PaletteTableBank := R6
PaletteOffset := R8
        perform_zpcm_inc

        ; Prep the table pointer from the room data structure
        ldy #Room::BgPaletteTablePtr
        lda (RoomPtr), y
        sta PaletteTablePtr+0
        iny
        lda (RoomPtr), y
        sta PaletteTablePtr+1

        ldy #Room::BgPaletteTableBank
        lda (RoomPtr), y
        sta PaletteTableBank+0
        iny
        lda (RoomPtr), y
        sta PaletteTableBank+1

        ; Use the current colorspace as the initial variant index
        lda current_save + SaveFile::OptionColorspace
        asl
        sta PaletteOffset
        ; Now use the room index to shift ahead in this table for magic spells and stuff
        ldy PlayerRoomIndex
        lda room_palette_variant, y
        tay
        lda palette_offset_by_room_variant_lut, y
        clc
        adc PaletteOffset
        sta PaletteOffset

        ; Now we're ready to bank in the data table and read the palette pointer
        access_data_bank PaletteTableBank
        ldy PaletteOffset
        lda (PaletteTablePtr), y
        sta PalettePtr+0
        iny
        lda (PaletteTablePtr), y
        sta PalettePtr+1

        perform_zpcm_inc
        
        ; The palette data is always colocated with its table, so copy that into place here:

        ldy #0
bg_loop:
        perform_zpcm_inc
        lda (PalettePtr), y
        sta IncomingHwPalette, y
        iny
        cpy #16
        bne bg_loop

        far_call FAR_set_bg_target_palette_from_hw

        restore_previous_bank

        perform_zpcm_inc

        ; Do it all again for the obj palette
        ; Prep the table pointer from the room data structure
        ldy #Room::ObjPaletteTablePtr
        lda (RoomPtr), y
        sta PaletteTablePtr+0
        iny
        lda (RoomPtr), y
        sta PaletteTablePtr+1

        ldy #Room::ObjPaletteTableBank
        lda (RoomPtr), y
        sta PaletteTableBank+0
        iny
        lda (RoomPtr), y
        sta PaletteTableBank+1

        ; Use the current colorspace as the initial variant index
        lda current_save + SaveFile::OptionColorspace
        asl
        sta PaletteOffset
        ; The object palette isn't affected by magic spells, so we're done with that.
        ; Proceed to load the data

        perform_zpcm_inc

        ; Now we're ready to bank in the data table and read the palette pointer
        access_data_bank PaletteTableBank
        ldy PaletteOffset
        lda (PaletteTablePtr), y
        sta PalettePtr+0
        iny
        lda (PaletteTablePtr), y
        sta PalettePtr+1

        ldy #0
obj_loop:
        perform_zpcm_inc
        lda (PalettePtr), y
        sta IncomingHwPalette, y
        iny
        cpy #16
        bne obj_loop

        far_call FAR_set_obj_palette_from_hw

        restore_previous_bank

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


