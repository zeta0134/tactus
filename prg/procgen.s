        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "constants.inc"
        .include "balance.inc"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "floor_preservation.inc"
        .include "hud.inc"
        .include "items.inc"
        .include "levels.inc"
        .include "loot.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "torchlight.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage
BigFloorPtr: .res 2

.segment "RAM"

BigFloorBank: .res 1

room_ptr_low: .res ::FLOOR_SIZE
room_ptr_high: .res ::FLOOR_SIZE
room_bank: .res ::FLOOR_SIZE
room_flags: .res ::FLOOR_SIZE ; what did we spawn in here? what is the current status of those things?
room_floorplan: .res ::FLOOR_SIZE ; properties of this cell in the floor's maze layout
room_properties: .res ::FLOOR_SIZE ; properties of the selected room that populates this cell
room_population_order: .res ::FLOOR_SIZE
enemies_active: .res 1
first_beat_after_load: .res 1
chest_spawn_cooldown: .res 1

current_clear_status: .res 1
previous_clear_status: .res 1

rooms_rerolled: .res 2
floors_rerolled: .res 2

RoomIndexToGenerate: .res 1
LoadedRoomIndex: .res 1

        ; should match levels_structures.s! it relies on several of our functions,
        ; and the far-call overhead for those functions is significant
        .segment "CODE_2"

; Note: relies on PlayerRoomIndex to load the room seed and other room properties
; (this might become important if we later decide to initialize rooms in advance)
.proc initialize_battlefield
RoomPtr := R0
TileIdPtr := R2
TileAddrPtr := R4
BehaviorIdPtr := R6
FlagsPtr := R8
CurrentTileId := R10
        mov16 TileIdPtr, RoomPtr
        add16w TileIdPtr, #Room::TileIDsLow
        mov16 TileAddrPtr, RoomPtr
        add16w TileAddrPtr, #Room::TileAttrsHigh
        mov16 BehaviorIdPtr, RoomPtr
        add16w BehaviorIdPtr, #Room::BehaviorIDs
        mov16 FlagsPtr, RoomPtr
        add16w FlagsPtr, #Room::FlagBytes

        ldy #0
        sty CurrentTileId
loop:
        perform_zpcm_inc
        ; load static details for this tile
        ldy CurrentTileId
        lda (TileIdPtr), y
        sta tile_patterns, y   ; current tile ID (low byte)
        sta tile_detail, y     ; original, mostly for disco tiles
        lda (TileAddrPtr), y
        sta tile_attributes, y ; current attributes (palette, lighting, high tile ID, etc)
        lda (BehaviorIdPtr), y
        sta battlefield, y     ; behavior (indexes into AI lookup tables)
        ; initialize runtime state for this tile
        lda #0
        sta tile_data, y
        sta tile_flags, y
        ; check for special spawn behavior flags and run those as needed here
        lda (FlagsPtr), y
        and #TILE_FLAG_DETAIL
        beq no_detail
        near_call FAR_roll_for_detail
no_detail:
        ldy CurrentTileId
        lda (FlagsPtr), y
        and #TILE_FLAG_EXIT
        beq no_exit_flag
        near_call FAR_process_exit_data
no_exit_flag:
        inc CurrentTileId
        lda CurrentTileId
        cmp #::BATTLEFIELD_SIZE
        bne loop

        perform_zpcm_inc
        jsr draw_battlefield_overlays
        perform_zpcm_inc
        near_call FAR_spawn_structures_from_zonedef
        perform_zpcm_inc

        rts
.endproc

overlay_conditional_lut_low:
        .byte <invalid_conditional            ; %0000 = 0 exits
        .byte <cardinal_conditional_north     ; %0001 = North
        .byte <cardinal_conditional_east      ; %0010 = East
        .byte <diagonal_conditional_northeast ; %0011 = Northeast
        .byte <cardinal_conditional_south     ; %0100 = South
        .byte <invalid_conditional            ; %0101 = Invalid (northsouth??)
        .byte <diagonal_conditional_southeast ; %0110 = Southeast
        .byte <invalid_conditional            ; %0111 = Invalid (3 exits?)
        .byte <cardinal_conditional_west      ; %1000 = West
        .byte <diagonal_conditional_northwest ; %1001 = Northwest
        .byte <invalid_conditional            ; %1010 = Invalid (eastwest??)
        .byte <invalid_conditional            ; %1011 = Invalid (3 exits?)
        .byte <diagonal_conditional_southwest ; %1100 = Southwest
        .byte <invalid_conditional            ; %1101 = Invalid (3 exits?)
        .byte <invalid_conditional            ; %1110 = Invalid (3 exits?)
        .byte <invalid_conditional            ; %1111 = Invalid (4 exits?)

overlay_conditional_lut_high:
        .byte >invalid_conditional            ; %0000 = 0 exits
        .byte >cardinal_conditional_north     ; %0001 = North
        .byte >cardinal_conditional_east      ; %0010 = East
        .byte >diagonal_conditional_northeast ; %0011 = Northeast
        .byte >cardinal_conditional_south     ; %0100 = South
        .byte >invalid_conditional            ; %0101 = Invalid (northsouth??)
        .byte >diagonal_conditional_southeast ; %0110 = Southeast
        .byte >invalid_conditional            ; %0111 = Invalid (3 exits?)
        .byte >cardinal_conditional_west      ; %1000 = West
        .byte >diagonal_conditional_northwest ; %1001 = Northwest
        .byte >invalid_conditional            ; %1010 = Invalid (eastwest??)
        .byte >invalid_conditional            ; %1011 = Invalid (3 exits?)
        .byte >diagonal_conditional_southwest ; %1100 = Southwest
        .byte >invalid_conditional            ; %1101 = Invalid (3 exits?)
        .byte >invalid_conditional            ; %1110 = Invalid (3 exits?)
        .byte >invalid_conditional            ; %1111 = Invalid (4 exits?)

special_conditional_lut_low:
        .byte <invalid_conditional ; never taken (we skip this case with a beq)
        .byte <open_corner_ne
        .byte <open_corner_se
        .byte <open_corner_sw
        .byte <open_corner_nw

special_conditional_lut_high:
        .byte >invalid_conditional
        .byte >open_corner_ne
        .byte >open_corner_se
        .byte >open_corner_sw
        .byte >open_corner_nw

.proc draw_battlefield_overlays
RoomPtr := R0
OverlayPtr := R2
OverlayListPtr := R4
ConditionalPtr := R6
ConditionalByte := R8
ScratchByte := R9
; draw_single_battlefield_overlay will clobber these:
; CurrentTileId := R10
; R12 - R15 are scratch for the detail function

        ; setup and ~~kart select~~ init
        ldy #Room::OverlayList
        lda (RoomPtr), y
        sta OverlayListPtr+0
        iny
        lda (RoomPtr), y
        sta OverlayListPtr+1
loop:
        perform_zpcm_inc
        ldy #0
        lda (OverlayListPtr), y
        cmp #$FF ; $FF is our end-of-list terminator
        beq done
        sta ConditionalByte ; stash this for later

        ; first, check the exit mask for this overlay against the current floorplan. if this fails, then
        ; the overlay does not apply to this room configuration and all the complicated checks can be
        ; safely skipped
        lda ConditionalByte ; mask off everything but the exit conditions
        and #$0F
        sta ScratchByte
        ; the room needs to have at least the exits this overlay requires. it can have more, but not less
        ldx RoomIndexToGenerate
        lda room_floorplan, x
        and ScratchByte
        cmp ScratchByte
        bne reject_this_overlay

        ; now, based on the exit type for this overlay, choose a directional conditional function
        ldx ScratchByte
        lda overlay_conditional_lut_low, x
        sta ConditionalPtr+0
        lda overlay_conditional_lut_high, x
        sta ConditionalPtr+1
        jmp (ConditionalPtr) ; will jump to either "draw" or "reject" below
directional_conditions_passed:
        ; some overlays 
        ldy #1
        lda (OverlayListPtr), y
        beq special_conditions_passed ; most overlays don't have special conditions; early out here
        tax
        lda special_conditional_lut_low, x
        sta ConditionalPtr+0
        lda special_conditional_lut_high, x
        sta ConditionalPtr+1
        jmp (ConditionalPtr)
special_conditions_passed:
        add16b OverlayListPtr, #2 ; skip past both conditional bytes
        ; read the overlay pointer and prep for drawing
        ldy #0
        lda (OverlayListPtr), y
        sta OverlayPtr+0
        inc16 OverlayListPtr
        lda (OverlayListPtr), y
        sta OverlayPtr+1
        inc16 OverlayListPtr
        ; actually perform the draw
        jsr draw_single_battlefield_overlay
        ; at this point our pointer is already setup for the next entry, so get to it
        jmp loop
reject_this_overlay:
        ; just skip past the pointer and keep going
        add16b OverlayListPtr, #4
        jmp loop
done:
        rts
.endproc

.proc invalid_conditional
        ; we shouldn't ever get here. TODO: maybe call a crash handler? (we don't have one)
        ; for now, just refuse to draw this overlay
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc cardinal_conditional_north
ConditionalByte := R8
ScratchByte := R9
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc cardinal_conditional_east
ConditionalByte := R8
ScratchByte := R9
        lda RoomIndexToGenerate
        clc
        adc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc cardinal_conditional_south
ConditionalByte := R8
ScratchByte := R9
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc cardinal_conditional_west
ConditionalByte := R8
ScratchByte := R9
        lda RoomIndexToGenerate
        sec
        sbc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc diagonal_conditional_northeast
ConditionalByte := R8
ScratchByte := R9
        ; first, check the NORTH exit
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the NS exit (north in this case) uses the normal entry:
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        ; do it all again but now check the EAST exit
        lda RoomIndexToGenerate
        clc
        adc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the EW exit (east in this case) uses the next 2 bits up, so
        ; we need to shift those into place
        lda ConditionalByte
        lsr
        lsr
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc diagonal_conditional_southeast
ConditionalByte := R8
ScratchByte := R9
        ; first, check the SOUTH exit
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the NS exit (south in this case) uses the normal entry:
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        ; do it all again but now check the EAST exit
        lda RoomIndexToGenerate
        clc
        adc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the EW exit (east in this case) uses the next 2 bits up, so
        ; we need to shift those into place
        lda ConditionalByte
        lsr
        lsr
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc diagonal_conditional_southwest
ConditionalByte := R8
ScratchByte := R9
        ; first, check the SOUTH exit
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the NS exit (south in this case) uses the normal entry:
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        ; do it all again but now check the WEST exit
        lda RoomIndexToGenerate
        sec
        sbc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the EW exit (west in this case) uses the next 2 bits up, so
        ; we need to shift those into place
        lda ConditionalByte
        lsr
        lsr
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc diagonal_conditional_northwest
ConditionalByte := R8
ScratchByte := R9
        ; first, check the NORTH exit
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the NS exit (north in this case) uses the normal entry:
        lda ConditionalByte
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        ; do it all again but now check the WEST exit
        lda RoomIndexToGenerate
        sec
        sbc #1
        tax
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte
        ; the EW exit (west in this case) uses the next 2 bits up, so
        ; we need to shift those into place
        lda ConditionalByte
        lsr
        lsr
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject
        jmp draw_battlefield_overlays::directional_conditions_passed
reject:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

; Open corners require that the 3 adjacent rooms all have:
; - the same room category as this room
; - an open exit, collectively making a 2x2 fully navigable square
.proc open_corner_ne
ScratchByte := R9
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte

        ; NORTH!
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; EAST!
        lda RoomIndexToGenerate
        clc
        adc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; NORTH+EAST!
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        clc
        adc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; This overlay is valid!
        jmp draw_battlefield_overlays::special_conditions_passed
reject_this_overlay:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc open_corner_se
ScratchByte := R9
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte

        ; SOUTH!
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; EAST!
        lda RoomIndexToGenerate
        clc
        adc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; SOUTH+EAST!
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        clc
        adc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; This overlay is valid!
        jmp draw_battlefield_overlays::special_conditions_passed
reject_this_overlay:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc open_corner_sw
        ScratchByte := R9
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte

        ; SOUTH!
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; WEST!
        lda RoomIndexToGenerate
        sec
        sbc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; SOUTH+WEST!
        lda RoomIndexToGenerate
        clc
        adc #::FLOOR_WIDTH
        sec
        sbc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; This overlay is valid!
        jmp draw_battlefield_overlays::special_conditions_passed
reject_this_overlay:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc open_corner_nw
ScratchByte := R9
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        sta ScratchByte

        ; NORTH!
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+WEST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_WEST)
        bne reject_this_overlay

        ; WEST!
        lda RoomIndexToGenerate
        sec
        sbc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have NORTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_NORTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; NORTH+WEST!
        lda RoomIndexToGenerate
        sec
        sbc #::FLOOR_WIDTH
        sec
        sbc #1
        tax
        ; does our category match?
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp ScratchByte
        bne reject_this_overlay
        ; Does this chamber have SOUTH+EAST exits open?
        lda room_floorplan, x
        and #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        cmp #(ROOM_EXIT_FLAG_SOUTH | ROOM_EXIT_FLAG_EAST)
        bne reject_this_overlay

        ; This overlay is valid!
        jmp draw_battlefield_overlays::special_conditions_passed
reject_this_overlay:
        jmp draw_battlefield_overlays::reject_this_overlay
.endproc

.proc draw_single_battlefield_overlay
RoomPtr := R0
OverlayPtr := R2
CurrentTileId := R10
; R12 - R15 are scratch for the detail function
loop:
        perform_zpcm_inc
        ldy #0
        lda (OverlayPtr), y
        cmp #$FF
        beq done
        sta CurrentTileId
        inc16 OverlayPtr

        ldx CurrentTileId

        lda (OverlayPtr), y
        sta tile_patterns, x
        sta tile_detail, x
        inc16 OverlayPtr

        lda (OverlayPtr), y
        sta tile_attributes, x
        inc16 OverlayPtr

        lda (OverlayPtr), y
        sta battlefield, x
        inc16 OverlayPtr

        ; overlays can have detail too, so we need to roll for that here
        ; as we draw the things
        ldy #0
        lda (OverlayPtr), y
        and #TILE_FLAG_DETAIL
        beq no_detail
        near_call FAR_roll_for_detail
no_detail:
        ; I don't know when we'd use it, but we might as well allow overlays
        ; to include exits, and handle those properly. maybe warp zones?
        ldy #0
        lda (OverlayPtr), y
        and #TILE_FLAG_EXIT
        beq no_exit_flag
        near_call FAR_process_exit_data
no_exit_flag:
        inc16 OverlayPtr
        jmp loop

done:
        rts
.endproc

; indexed by the direct values above
detail_variants_table:
        .addr detail_sparse_grass
        .addr detail_sparse_shrooms
        .addr detail_sparse_grass_shrooms
        .addr detail_cave
        .addr detail_cave_shrooms
        .addr detail_sand
        .addr detail_grass_wall_lower_border
        .addr detail_grass_wall
        .addr detail_grass_wall_upper_border
        .addr detail_grass_wall_horiz_strip

; FOR NOW, every detail table has exactly 32 entries in it, which controls 
; overall detail density with a reasonable degree of fine-tuning
detail_sparse_grass:
        .repeat 27
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0014 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0014 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0015 ; 3-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0015 ; 3-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0025 ; thick grass tuft

detail_sparse_shrooms:
        .repeat 26
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; two mushrooms
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; two mushrooms

detail_sparse_grass_shrooms:
        .repeat 26
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; two mushrooms
        .word BG_TILE_DISCO_FLOOR_TILES_0014 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0015 ; 3-bladed grass tuft        
        .word BG_TILE_DISCO_FLOOR_TILES_0025 ; thick grass tuft

detail_cave:
        .repeat 16
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .repeat 11
        .word BG_TILE_DISCO_FLOOR_TILES_0010 ; pocked floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0022 ; round rock
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0026 ; two rocks

detail_cave_shrooms:
        .repeat 16
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .repeat 9
        .word BG_TILE_DISCO_FLOOR_TILES_0010 ; pocked floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0022 ; round rock
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0026 ; two rocks
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; two mushrooms

detail_sand:
        .repeat 29
        .word BG_TILE_DISCO_FLOOR_TILES_0020 ; plain sand
        .endrepeat
        .repeat 3
        .word BG_TILE_DISCO_FLOOR_TILES_0021 ; sand with seashell
        .endrepeat

detail_grass_wall_lower_border:
        .repeat 20
        .word BG_TILE_MAP_TILES_0161 ; plain grass wall lower border
        .endrepeat
        .word BG_TILE_MAP_TILES_0160 ; grass wall lower border w/ cattails
        .word BG_TILE_MAP_TILES_0160 ; grass wall lower border w/ cattails
        .word BG_TILE_MAP_TILES_0160 ; grass wall lower border w/ cattails
        .word BG_TILE_MAP_TILES_0160 ; grass wall lower border w/ cattails
        .word BG_TILE_MAP_TILES_0162 ; grass wall lower border w/ light flower
        .word BG_TILE_MAP_TILES_0162 ; grass wall lower border w/ light flower
        .word BG_TILE_MAP_TILES_0162 ; grass wall lower border w/ light flower
        .word BG_TILE_MAP_TILES_0162 ; grass wall lower border w/ light flower
        .word BG_TILE_MAP_TILES_0181 ; grass wall lower border w/ tall grass
        .word BG_TILE_MAP_TILES_0181 ; grass wall lower border w/ tall grass
        .word BG_TILE_MAP_TILES_0181 ; grass wall lower border w/ tall grass
        .word BG_TILE_MAP_TILES_0181 ; grass wall lower border w/ tall grass

detail_grass_wall:
        .repeat 16
        .word BG_TILE_MAP_TILES_0145 ; grass wall plain
        .endrepeat
        .word BG_TILE_MAP_TILES_0144 ; grass wall w/ short grass high
        .word BG_TILE_MAP_TILES_0144 ; grass wall w/ short grass high
        .word BG_TILE_MAP_TILES_0144 ; grass wall w/ short grass high
        .word BG_TILE_MAP_TILES_0164 ; grass wall w/ short grass low
        .word BG_TILE_MAP_TILES_0164 ; grass wall w/ short grass low
        .word BG_TILE_MAP_TILES_0164 ; grass wall w/ short grass low
        .word BG_TILE_MAP_TILES_0146 ; grass wall w/ tall grass
        .word BG_TILE_MAP_TILES_0146 ; grass wall w/ tall grass
        .word BG_TILE_MAP_TILES_0146 ; grass wall w/ tall grass
        .word BG_TILE_MAP_TILES_0147 ; grass wall w/ dark flower
        .word BG_TILE_MAP_TILES_0147 ; grass wall w/ dark flower
        .word BG_TILE_MAP_TILES_0163 ; grass wall w/ light square flower
        .word BG_TILE_MAP_TILES_0163 ; grass wall w/ light square flower
        .word BG_TILE_MAP_TILES_0148 ; grass wall w/ cattails
        .word BG_TILE_MAP_TILES_0165 ; grass wall w/ light spiral flower
        .word BG_TILE_MAP_TILES_0165 ; grass wall w/ light spiral flower

detail_grass_wall_upper_border:
        .repeat 20
        .word BG_TILE_MAP_TILES_0129 ; grass wall upper border plain
        .endrepeat
        .word BG_TILE_MAP_TILES_0128 ; grass wall upper border w/ light square flower
        .word BG_TILE_MAP_TILES_0128 ; grass wall upper border w/ light square flower
        .word BG_TILE_MAP_TILES_0128 ; grass wall upper border w/ light square flower
        .word BG_TILE_MAP_TILES_0128 ; grass wall upper border w/ light square flower
        .word BG_TILE_MAP_TILES_0130 ; grass wall upper border w/ cattails
        .word BG_TILE_MAP_TILES_0130 ; grass wall upper border w/ cattails
        .word BG_TILE_MAP_TILES_0130 ; grass wall upper border w/ cattails
        .word BG_TILE_MAP_TILES_0130 ; grass wall upper border w/ cattails
        .word BG_TILE_MAP_TILES_0149 ; grass wall upper border w/ tall grass
        .word BG_TILE_MAP_TILES_0149 ; grass wall upper border w/ tall grass
        .word BG_TILE_MAP_TILES_0149 ; grass wall upper border w/ tall grass
        .word BG_TILE_MAP_TILES_0149 ; grass wall upper border w/ tall grass

detail_grass_wall_horiz_strip:
        .repeat 20
        .word BG_TILE_MAP_TILES_0132 ; grass wall horiz strip
        .endrepeat
        .word BG_TILE_MAP_TILES_0131 ; grass wall horiz strip w/ short grass
        .word BG_TILE_MAP_TILES_0131 ; grass wall horiz strip w/ short grass
        .word BG_TILE_MAP_TILES_0131 ; grass wall horiz strip w/ short grass
        .word BG_TILE_MAP_TILES_0131 ; grass wall horiz strip w/ short grass
        .word BG_TILE_MAP_TILES_0133 ; grass wall horiz strip w/ cattails
        .word BG_TILE_MAP_TILES_0133 ; grass wall horiz strip w/ cattails
        .word BG_TILE_MAP_TILES_0133 ; grass wall horiz strip w/ cattails
        .word BG_TILE_MAP_TILES_0133 ; grass wall horiz strip w/ cattails
        .word BG_TILE_MAP_TILES_0180 ; grass wall horiz strip w/ light square flower
        .word BG_TILE_MAP_TILES_0180 ; grass wall horiz strip w/ light square flower
        .word BG_TILE_MAP_TILES_0180 ; grass wall horiz strip w/ light square flower
        .word BG_TILE_MAP_TILES_0180 ; grass wall horiz strip w/ light square flower

.proc FAR_roll_for_detail
; in-use by the battlefield routine, don't clobber these
RoomPtr := R0
TileIdPtr := R2
TileAddrPtr := R4
BehaviorIdPtr := R6
FlagsPtr := R8
CurrentTileId := R10
; scratch for this routine
DetailTablePtr := R12
ScratchPal := R14
        
        ; the detail index should have been copied to the current room index, so
        ; get that loaded
        ldy CurrentTileId
        lda tile_patterns, y
        ; use that to setup the detail pointer, from our fixed table
        tax
        lda detail_variants_table+0, x
        sta DetailTablePtr+0
        lda detail_variants_table+1, x
        sta DetailTablePtr+1

        ; now we roll for detail out of the selected table, always in
        ; a range from 0-31
        jsr next_room_rand ; result in A, clobbers Y
        and #$1F ; clamp to max of 31
        asl ; and multiply by 2, to index a table of words
        tay
        ldx CurrentTileId
        ; the first byte is the low byte of the pattern, use this directly
        lda (DetailTablePtr), y
        sta tile_patterns, x
        sta tile_detail, x
        ; the second byte is the high byte of the pattern, we'll need to
        ; preserve the attribute bits that are already in the table
        iny
        lda tile_attributes, x
        and #PAL_MASK
        sta ScratchPal
        lda (DetailTablePtr), y
        and #($FF - PAL_MASK)
        ora ScratchPal
        sta tile_attributes, x
        ; ... and we're done?

        rts
.endproc

.proc FAR_process_exit_data
; in-use by the battlefield routine, don't clobber these
RoomPtr := R0
TileIdPtr := R2
TileAddrPtr := R4
BehaviorIdPtr := R6
FlagsPtr := R8
CurrentTileId := R10
; scratch for this routine
DetailTablePtr := R12
ScratchPal := R14
        ; the desired exit ID ends up in tile patterns in this case
        ldy CurrentTileId
        lda tile_patterns, y
        sta tile_data, y

        ; now we need to pick the exit graphic; for now, hardcode these
        ; to stairs (later we might offer alternatives in the flags byte)
        lda #<BG_TILE_EXIT_STAIRS
        sta tile_patterns, y
        lda tile_attributes, y
        and #%11000000
        ora #>BG_TILE_EXIT_STAIRS
        sta tile_attributes, y

        rts
.endproc

; Randomize the visitation order for populating rooms on each floor
; This helps to ensure that things like player spawn locations and
; challenge chambers aren't biased to one side of the map
; TODO: replace this with either fisher-yates (ideal) or pseudo-yates,
; per https://discord.com/channels/352252932953079811/352436568062951427/1242390363411320904
.proc shuffle_room_order
SourceIndex := R2
DestIndex := R3
Iterations := R4
Temp := R5
        ldx #0
init_loop:
        perform_zpcm_inc
        txa
        sta room_population_order, x
        inx
        cpx #::FLOOR_SIZE
        bne init_loop

        lda #64 ; somewhat arbitrary
        sta Iterations
shuffle_loop:
        perform_zpcm_inc
        jsr next_floor_rand
        perform_zpcm_inc
        and #(::FLOOR_SIZE-1)
        sta SourceIndex
        jsr next_floor_rand
        perform_zpcm_inc
        and #(::FLOOR_SIZE-1)
        sta DestIndex
        ldx SourceIndex
        ldy DestIndex
        lda room_population_order, x
        sta Temp
        lda room_population_order, y
        sta room_population_order, x
        lda Temp
        sta room_population_order, y
        dec Iterations
        bne shuffle_loop

        perform_zpcm_inc
        rts
.endproc

.proc choose_rooms_for_floor

CurrentRoomIndex := R5
CurrentRoomCounter := R6
RoomPtr := R7
RoomBank := R9
ExitTemp := R10
ChallengeCount := R11
FloorExitCount := R12
MaxChallengeCount := R13
ShopCount := R14
MaxShopCount := R15
        jsr shuffle_room_order

        st16 floors_rerolled, 0
        st16 rooms_rerolled, 0

        ; we need to access some properties of the big floor while we have banked
        ; in other data, so cache that to scratch here
        ldy #BigFloor::MaxChallengeRooms
        lda (BigFloorPtr), y
        sta MaxChallengeCount
        ldy #BigFloor::MaxShopRooms
        lda (BigFloorPtr), y
        sta MaxShopCount

begin_floor_generation:
        ; initialize room flags and other state to a sensible starting value
        ldx #0
room_setup_loop:
        perform_zpcm_inc
        lda #0
        sta room_flags, x
        inx
        cpx #::FLOOR_SIZE
        bne room_setup_loop

        ; initialize the player room index to a nonsense value; later,
        ; we'll check for this and redo the whole floor if it's still nonsense
        lda #$FF
        sta PlayerRoomIndex

        lda #0
        sta ChallengeCount
        sta ShopCount
        sta FloorExitCount

        lda #0
        sta CurrentRoomCounter
room_loop:
        perform_zpcm_inc
        ldx CurrentRoomCounter
        lda room_population_order, x
        sta CurrentRoomIndex
begin_room_selection:
        ; populates RoomPtr and RoomBank
        far_call FAR_roll_room_from_floorplan_at_current_index

        ; TODO: load up the room pointer and check properties and such to update
        ; our counters. Right now we don't have those (or any rooms that would set them)
        ; so we can skip that work and just use whatever we rolled. Should the counter
        ; logic fail, we might need to roll the room again.
        access_data_bank RoomBank ; Note: hides BigFloorPtr! Do not read until we restore later!
        ; firstly, does this room support the exits this floorplan location requires?
        lda room_floorplan, x
        and #$0F
        sta ExitTemp
        ldy #Room::Exits
        lda (RoomPtr), y
        and ExitTemp
        cmp ExitTemp
        bne reject_this_room
        
        ; If this is a challenge room...
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_CHALLENGE
        bne done_considering_challenge_rooms
        ; ... have we already satisfied the challenge maximum for this floor?
        lda ChallengeCount
        cmp MaxChallengeCount
        bcs reject_this_room
        ; this is definitely a challenge chamber; increment the counter
        inc ChallengeCount
        ; TEMPORARY: also flag this as a "boss room" and, keeping with Action53 behavior,
        ; automatically reveal this room
        lda #(ROOM_FLAG_BOSS)
        ora room_flags, x
        sta room_flags, x
done_considering_challenge_rooms:

        ; If this is a shop room...
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        bne done_considering_shop_rooms
        ; ... have we already satisfied the shop maximum for this floor?
        lda ShopCount
        cmp MaxShopCount
        bcs reject_this_room
        ; this is definitely a shop chamber; increment the counter
        inc ShopCount
        ; Shop rooms begin "cleared" as they should never spawn actual monsters
        ; or enter disco mode. They also never spawn a treasure (TODO: which is an
        ; old mechanic that should go away) 
        lda #(ROOM_FLAG_CLEARED | ROOM_FLAG_TREASURE_SPAWNED)
        ora room_flags, x
        sta room_flags, x
done_considering_shop_rooms:

        ; handle player spawning: basically the first room we visit where the
        ; player **could** spawn, we put them there
        lda PlayerRoomIndex
        cmp #$FF
        bne done_with_player_spawning
        ; can this room handle player spawns?
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_PROPERTIES_NOSPAWN
        bne done_with_player_spawning
        ; can this floor tile handle player spawns?
        lda room_floorplan, x
        and #ROOM_PROPERTIES_NOSPAWN
        bne done_with_player_spawning
        ; we've found a room that the player **could** spawn in, and we haven't already
        ; picked one. this one works. use this one!
        stx PlayerRoomIndex
done_with_player_spawning:

        ; TEMPORARY: pick an exit location, which should basically be the first room
        ; we generate that (a) isn't the player's starting location, (b) is not out of
        ; bounds, and (c) is not a challenge room. Later we will be completely overhauling
        ; exit generation in general
        lda FloorExitCount
        bne done_picking_exits ; only pick one exit
        cpx PlayerRoomIndex
        beq done_picking_exits ; (a) it isn't  the player's starting location
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_PROPERTIES_NOSPAWN
        bne done_picking_exits ; (b) it is otherwise "spawnable", which also (c) excludes challenge rooms
        lda #ROOM_FLAG_EXIT_STAIRS
        ora room_flags, x
        sta room_flags, x
        inc FloorExitCount
done_picking_exits:

        jmp accept_this_room
reject_this_room:
        restore_previous_bank ; RoomBank
        inc16 rooms_rerolled
        jmp begin_room_selection
accept_this_room:
        ; Load in the chosen properties of this room, which we'll
        ; use later during chamber generation
        ldy #Room::Properties
        lda (RoomPtr), y
        sta room_properties, x
        ; Done reading room data for now
        restore_previous_bank ; RoomBank

        inc CurrentRoomCounter
        lda CurrentRoomCounter
        cmp #::FLOOR_SIZE
        jne room_loop
        
        ; If we failed to find a suitable spawn point, reject this floor
        lda PlayerRoomIndex
        cmp #$FF
        beq reject_floor

        ; If we failed to meet thresholds for the minimum number of special
        ; rooms, also reject this floor
        lda ChallengeCount
        ldy #BigFloor::MinChallengeRooms
        cmp (BigFloorPtr), y
        bcc reject_floor

        lda ShopCount
        ldy #BigFloor::MinShopRooms
        cmp (BigFloorPtr), y
        bcc reject_floor        

        lda FloorExitCount
        ldy #BigFloor::MinExitRooms
        cmp (BigFloorPtr), y
        bcc reject_floor        

accept_floor:
        rts
reject_floor:
        inc16 floors_rerolled
        jmp begin_floor_generation
.endproc

; Generate a maze layout, and pick the player, boss, and exit locations
.proc FAR_init_floor
        ; The player won't initially have navigated the floor at all, so reset
        ; the nav items set
        lda #0
        sta PlayerNavState

        ; We are about to kick off floor generation, so grab a fresh floor PRNG
        ; seed based on the current run seed
        jsr generate_floor_seed
        far_call FAR_reset_shop_tracker

        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        perform_zpcm_inc
        sta room_flags, x
        inx
        cpx #::FLOOR_SIZE
        bne flag_loop

        far_call FAR_roll_floorplan_from_active_zone_pool
        access_data_bank BigFloorBank

        ; Load in this floor's basic room properties
        lda #0
        ldx #0
        ldy #BigFloor::RoomProperties
room_floorplan_loop:
        perform_zpcm_inc
        lda (BigFloorPtr), y
        sta room_floorplan, x
        inx
        iny
        cpy #(BigFloor::RoomProperties + ::FLOOR_SIZE)
        bne room_floorplan_loop

        ; Pick which individual rooms we are going to use here
        jsr choose_rooms_for_floor

        ; Mark the player's room as cleared, so they don't load in surrounded by mobs
        ; TODO: the whole concept of "cleared" as a room-level flag might go away
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED
        sta room_flags, x

        ; if this is zone 1, floor 1, then allow the player to have one treasure when they start
        ; (it will spawn right away)
        ; TODO: move this into a zone flag, if we want the behavior back
        ; (or don't, it's kinda minor at this point)
        ;lda PlayerZone
        ;cmp #1
        ;bne no_starting_treasure
        ;lda PlayerFloor
        ;cmp #1
        ;bne no_starting_treasure
        ;jmp done_with_player
no_starting_treasure:
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_SPAWNED
        sta room_flags, x
done_with_player:

        ; Aaaand.... that's it? I think that's it
        perform_zpcm_inc

        restore_previous_bank
        rts
.endproc

.proc FAR_generate_rooms_for_floor
RoomIndexToPreserve := R0
        lda #0
        sta RoomIndexToGenerate
loop:
        perform_zpcm_inc
        jsr generate_room_seed
        jsr generate_room
        lda RoomIndexToGenerate
        sta RoomIndexToPreserve
        perform_zpcm_inc
        far_call FAR_preserve_room
        perform_zpcm_inc
        inc RoomIndexToGenerate
        lda RoomIndexToGenerate
        cmp #FLOOR_SIZE
        bne loop

        ; just in case state restoration gets called in a weird order, store the
        ; index of the last room we generated
        lda #(FLOOR_SIZE-1)
        sta LoadedRoomIndex

        rts
.endproc

.proc generate_room
RoomPtr := R0
RoomBank := R2
EntityList := R4
        ; NEW: the room pointer and associated bank are just part of the
        ; floor data now; load and use that
        ldx RoomIndexToGenerate
        lda room_bank, x
        sta RoomBank
        lda room_ptr_low, x
        sta RoomPtr+0
        lda room_ptr_high, x
        sta RoomPtr+1
        access_data_bank RoomBank
        jsr initialize_battlefield

        ; Is this room dark? If so, set the darkness flag
        ; (it may later change at runtime)
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_PROPERTIES_DARK
        beq not_dark
        ldx RoomIndexToGenerate
        lda room_flags, x
        ora #ROOM_FLAG_DARK
        sta room_flags, x
not_dark:
        restore_previous_bank

        ; Does this room have exit stairs? If so, spawn those first
        ldx RoomIndexToGenerate
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq no_exit_stairs
        jsr spawn_exit_block
        ldx RoomIndexToGenerate
no_exit_stairs:        

        ; Has the player already cleared this room?
        ; TODO: this check is redundant now?
        ldx RoomIndexToGenerate
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne room_cleared

        ; If this is a boss room, we need to use the boss pool
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne spawn_boss_enemies
spawn_basic_enemies:
        ; Basic rooms use the spawning pool defined in the player's
        ; current zone, and the difficulty settings therein
        far_call FAR_setup_spawn_pool_for_current_zone
        far_call FAR_spawn_entities_from_pool

        jmp room_cleared
spawn_boss_enemies:
        ; Challenge rooms roll a fixed set of encounters from the
        ; player's current zone
        far_call FAR_setup_spawn_set_for_current_zone
        far_call FAR_spawn_entities_from_spawn_set

        jmp room_cleared
room_cleared:
        perform_zpcm_inc

        ; If this is a shop room, roll shop loot
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        bne done_with_shop_rolls
        jsr roll_shop_loot
done_with_shop_rolls:

        perform_zpcm_inc
        rts
.endproc

.proc roll_shop_loot
LootTablePtr := R0
LootTableIndex := R2
ItemId := R2
; R3 is clobbered by the loot rolling function
CurrentTile := R4
NextLootIndex := R5

        perform_zpcm_inc

        jsr next_room_rand
        and #%00000011
        sta NextLootIndex

        ; Loop through the entire room, scanning for any item shadow tiles that aren't populated
        lda #0
        sta CurrentTile
loop:
        perform_zpcm_inc
        ldx CurrentTile
        lda battlefield, x
        cmp #TILE_ITEM_SHADOW
        bne done_with_tile
        lda tile_data, x   ; only roll an item if this slot actually has no item in it.
                           ; not sure if we'll use this, but it allows us to have the map data
                           ; specify a forced roll and control the purchase flag?
        bne done_with_tile

        lda NextLootIndex
        sta LootTableIndex
        far_call FAR_setup_shop_loot_ptrs_for_current_zone

        inc NextLootIndex
        lda NextLootIndex
        and #%00000011
        sta NextLootIndex

        far_call FAR_roll_shop_loot
        ldx CurrentTile
        lda ItemId
        sta tile_data, x
        lda tile_flags, x
        ora #ITEM_FOR_PURCHASE
        sta tile_flags, x

done_with_tile:
        inc CurrentTile
        lda CurrentTile
        cmp #BATTLEFIELD_SIZE
        bne loop

        ; et voila! items for sale!
        perform_zpcm_inc

        rts
.endproc

.proc FAR_load_current_room
RoomIndexToPreserve := R0

RoomPtr := R0
RoomBank := R2
EntityList := R4
        ; Store the previous room first, so we don't lose
        ; its state. First, prepare the room for suspension; some tiles
        ; need to perform cleanup
        far_call FAR_suspend_entire_room

        ; Now write the suspended room state into RAM so we don't lose it
        lda LoadedRoomIndex
        sta RoomIndexToPreserve
        far_call FAR_preserve_room

        ; Now we can overwrite the working set with the target room
        lda PlayerRoomIndex
        sta RoomIndexToPreserve
        far_call FAR_restore_preserved_room
        lda PlayerRoomIndex
        sta LoadedRoomIndex

        ; Some details are part of the original room pointer, so get that set up
        ldx PlayerRoomIndex
        lda room_bank, x
        sta RoomBank
        lda room_ptr_low, x
        sta RoomPtr+0
        lda room_ptr_high, x
        sta RoomPtr+1
        access_data_bank RoomBank

        ; load this room's palette data
        far_call FAR_load_room_palette

        ; If this room is darkened, apply torchlight
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        bne apply_darkness
apply_lightness:
        lda #30
        sta current_torchlight_radius
        sta target_torchlight_radius
        ; do not insta-lighten, we're doing that in the kernel now
        ;far_call FAR_lighten_entire_inactive_torchlight
        jmp done_with_torchlight
apply_darkness:
        lda target_torchlight_radius
        cmp #30
        bne no_instant_darkness
        lda #PLAYER_BASE_TORCHLIGHT
        sta current_torchlight_radius
no_instant_darkness:
        lda PlayerTorchlightRadius
        sta target_torchlight_radius
        ; do not insta-darken, we're doing that in the kernel now
        ;far_call FAR_darken_entire_inactive_torchlight
done_with_torchlight:

        restore_previous_bank

        ; Mark this room as visited
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_VISITED
        sta room_flags, x
        lda #1
        sta HudMapDirty

        ; Flag this as a freshly loaded room, which mostly affects room state
        lda #1
        sta first_beat_after_load

        rts
.endproc

; Called during gameplay, not during generation. Handles ongoing room flag
; state, and checks for any entities that need to spawn post-generation
.proc FAR_update_room_state
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
        ; safety: if we are currently paused, don't process any of this
        lda PlayerIsPaused
        beq not_paused
        rts
not_paused:

        ; sanity: if this room is freshly loaded, don't do any of this. the enemies
        ; haven't had a real processing round yet, and we are operating on incomplete
        ; information (possibly stale from the previous room)
        lda first_beat_after_load
        bne room_state_init

        lda current_clear_status
        sta previous_clear_status

        ldx PlayerRoomIndex
check_room_clear:
        lda enemies_active
        bne room_not_clear
room_is_clear:
        lda #1
        sta current_clear_status
        perform_zpcm_inc
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED ; set the clear flag
        sta room_flags, x
        jmp done_with_clear_checks
room_not_clear:
        lda #0
        sta current_clear_status
        perform_zpcm_inc
        lda room_flags, x
        and #($FF - ROOM_FLAG_CLEARED) ; unset the room clear flag
        sta room_flags, x
        lda #0
        sta chest_spawn_cooldown
done_with_clear_checks:

        ; If the room is clear, and we haven't spawned the chest yet,
        ; then do so
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq done_with_chest_spawns
        lda room_flags, x
        and #ROOM_FLAG_TREASURE_SPAWNED
        bne done_with_chest_spawns
        lda chest_spawn_cooldown
        cmp #2
        bcc done_with_chest_spawns
perform_chest_spawning:
        ; TODO: instead of rolling a random chest here, we should check for the
        ; hidden chest (if present) as part of the map data, and spawn in that
        ; specific chest. (this whole mechanic doesn't exist yet)
        perform_zpcm_inc

        ; spawn in a chest
        lda #TILE_TREASURE_CHEST
        sta EntityId
        lda #<BG_TILE_TREASURE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_TREASURE_CHEST | PAL_YELLOW)
        sta EntityAttribute
        jsr spawn_entity

        ; Flag this chest as spawned, so we don't try to spawn it again later
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_SPAWNED
        sta room_flags, x
done_with_chest_spawns:
        inc chest_spawn_cooldown
        
all_done:
        perform_zpcm_inc
        ; reset the enemies active counter for the next beat
        lda #0
        sta enemies_active
        rts

room_state_init:
        perform_zpcm_inc
        lda #0
        sta enemies_active
        lda #1
        sta previous_clear_status
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne init_room_clear
init_room_not_clear:
        lda #0
        sta current_clear_status
        rts
init_room_clear:
        lda #1
        sta current_clear_status
        rts
.endproc

; These are used to take a 5bit random number and pick something "in bounds" coordinate wise,
; with reasonable speed and fairness
random_row_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_HEIGHT - 6)))
        .endrepeat

random_col_table:
        .repeat 32, i
        .byte (3 + (i .MOD (::BATTLEFIELD_WIDTH - 6)))
        .endrepeat

; Spawn the provided entity somewhere "safe" in the room.
; Safe positions are: row >= 2, row <= height-2, col >= 2, col <= height-2
; The player's current location is not safe
; Only floor tiles (and disco floor tiles I suppose) are safe
; WARNING: If there are no safe floor tiles at all on this map, the function WILL lock up indefinitely.
; Try not to let this happen.
; Note: calls 
.proc spawn_entity
TempIndex := R0
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
TempRow := R9
TempCol := R10

find_safe_coordinate:
        jsr next_room_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta TempRow
        jsr next_room_rand
        and #%00011111
        tax
        lda random_col_table, x
        sta TempCol
check_player_coords:
        lda PlayerRow
        cmp TempRow
        bne check_floor
        lda PlayerCol
        cmp TempCol
        bne check_floor
        ; no good; this spawn would be on top of the player. Move it somewhere else
        ; TODO: Safety: if the list near/equal/larger than the number of safe tiles
        ; on a map, this can take a very long time or lock up entirely. We should maybe
        ; have a watchdog and bail after a very high number of attempts.
        jmp find_safe_coordinate
check_floor:
        ldx TempRow
        lda row_number_to_tile_index_lut, x
        clc
        adc TempCol
        sta TempIndex
        ldx TempIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        beq is_valid_space
        ; no good; this is not a floor tile. We cannot spawn anything here,
        ; try again
        jmp find_safe_coordinate
is_valid_space:
        ; conveniently, X is already our destination, so just write this
        ; tile there
        lda EntityId
        sta battlefield, x
        lda EntityPattern
        sta tile_patterns, x
        lda EntityAttribute
        sta tile_attributes, x
        ; draw the new tile to the active buffer right away
        jsr draw_active_tile
        ; zero out the other two properties
        ; (Not sure if this will ever be incorrect? unclear)
        ; (probably not, we'll use a spawn state if we need to set them)
        ldx TempIndex
        lda #0
        sta tile_data, x
        sta tile_flags, x
        ; all done!
        rts
.endproc

.proc spawn_entity_list
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
EntityList := R4
ListIndex := R6
ListLength := R7
EntityCount := R8
        ldy #0
        lda (EntityList), y
        beq done ; do not process an empty list
        sta ListLength
        iny
        sty ListIndex
list_loop:
        ldy ListIndex
        lda (EntityList), y
        sta EntityId
        iny
        lda (EntityList), y
        sta EntityPattern
        iny
        lda (EntityList), y
        sta EntityAttribute
        iny
        lda (EntityList), y
        sta EntityCount
        iny
        sty ListIndex
entity_loop:
        jsr spawn_entity
        dec EntityCount
        bne entity_loop
        dec ListLength
        bne list_loop
done:
        rts
.endproc

.proc spawn_exit_block
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
        lda #TILE_EXIT_BLOCK
        sta EntityId
        lda #<BG_TILE_EXIT_BLOCK
        sta EntityPattern
        lda #(>BG_TILE_EXIT_BLOCK | PAL_BLUE)
        sta EntityAttribute
        jsr spawn_entity
        rts
.endproc


