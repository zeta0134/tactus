        .macpack longbranch

        .include "../build/tile_defs.inc"

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

.segment "RAM"

room_ptr_low: .res ::FLOOR_SIZE
room_ptr_high: .res ::FLOOR_SIZE
room_bank: .res ::FLOOR_SIZE
room_flags: .res ::FLOOR_SIZE ; what did we spawn in here? what is the current status of those things?
room_floorplan: .res ::FLOOR_SIZE ; properties of this cell in the floor's maze layout
room_properties: .res ::FLOOR_SIZE ; properties of the selected room that populates this cell
room_population_order: .res ::FLOOR_SIZE
enemies_active: .res 1

rooms_rerolled: .res 2
floors_rerolled: .res 2

RoomIndexToGenerate: .res 1
LoadedRoomIndex: .res 1

.segment "CODE_1"

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

.proc load_room_palette
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
        jsr roll_for_detail
no_detail:
        inc CurrentTileId
        lda CurrentTileId
        cmp #::BATTLEFIELD_SIZE
        bne loop

        perform_zpcm_inc
        jsr draw_battlefield_overlays
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

        ; now, based on the exit type for this overlay, choose a conditional function
        ldx ScratchByte
        lda overlay_conditional_lut_low, x
        sta ConditionalPtr+0
        lda overlay_conditional_lut_high, x
        sta ConditionalPtr+1
        jmp (ConditionalPtr) ; will jump to either "draw" or "reject" below

draw_this_overlay:
        inc16 OverlayListPtr ; skip past the conditional byte
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
        inc16 OverlayListPtr
        inc16 OverlayListPtr
        inc16 OverlayListPtr
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
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
        jmp draw_battlefield_overlays::draw_this_overlay
reject:
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
        lda (OverlayPtr), y
        and #TILE_FLAG_DETAIL
        beq no_detail
        jsr roll_for_detail
no_detail:
        inc16 OverlayPtr
        jmp loop

done:
        rts
.endproc

TILE_FLAG_DETAIL = %10000000

DETAIL_SPARSE_GRASS            = 0
DETAIL_SPARSE_SHROOMS          = 2
DETAIL_SPARSE_GRASS_SHROOMS    = 4
DETAIL_CAVE                    = 6
DETAIL_CAVE_SHROOMS            = 8
DETAIL_SAND                    = 10
DETAIL_GRASS_WALL_LOWER_BORDER = 12
DETAIL_GRASS_WALL              = 14
DETAIL_GRASS_WALL_UPPER_BORDER = 16
DETAIL_GRASS_WALL_HORIZ_STRIP  = 18

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
        .word BG_TILE_DISCO_FLOOR_TILES_0022 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0022 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; 3-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; 3-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; thick grass tuft

detail_sparse_shrooms:
        .repeat 26
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0008 ; two mushrooms
        .word BG_TILE_DISCO_FLOOR_TILES_0008 ; two mushrooms

detail_sparse_grass_shrooms:
        .repeat 26
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0008 ; two mushrooms
        .word BG_TILE_DISCO_FLOOR_TILES_0022 ; 2-bladed grass tuft
        .word BG_TILE_DISCO_FLOOR_TILES_0023 ; 3-bladed grass tuft        
        .word BG_TILE_DISCO_FLOOR_TILES_0024 ; thick grass tuft

detail_cave:
        .repeat 16
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .repeat 11
        .word BG_TILE_DISCO_FLOOR_TILES_0018 ; pocked floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0038 ; round rock
        .word BG_TILE_DISCO_FLOOR_TILES_0039 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0039 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0039 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0040 ; two rocks

detail_cave_shrooms:
        .repeat 16
        .word BG_TILE_DISCO_FLOOR_TILES_0000 ; blank floor
        .endrepeat
        .repeat 9
        .word BG_TILE_DISCO_FLOOR_TILES_0018 ; pocked floor
        .endrepeat
        .word BG_TILE_DISCO_FLOOR_TILES_0038 ; round rock
        .word BG_TILE_DISCO_FLOOR_TILES_0039 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0039 ; many pocks
        .word BG_TILE_DISCO_FLOOR_TILES_0040 ; two rocks
        .word BG_TILE_DISCO_FLOOR_TILES_0006 ; plain mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0007 ; tall mushroom
        .word BG_TILE_DISCO_FLOOR_TILES_0008 ; two mushrooms

detail_sand:
        .repeat 29
        .word BG_TILE_DISCO_FLOOR_TILES_0036 ; plain sand
        .endrepeat
        .repeat 3
        .word BG_TILE_DISCO_FLOOR_TILES_0018 ; sand with seashell
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

.proc roll_for_detail
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
BigFloorPtr := R0
RoomPoolPtr := R2
RoomPoolBank := R4
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
setup_room_generation_state:
        ldy CurrentRoomIndex
        lda (BigFloorPtr), y
        tax
        lda room_pools_banks, x
        sta RoomPoolBank
        lda (BigFloorPtr), y
        asl
        tax
        lda room_pools_lut+0, x
        sta RoomPoolPtr+0
        lda room_pools_lut+1, x
        sta RoomPoolPtr+1
        access_data_bank RoomPoolBank ; this hides the big floor! do NOT read from BigFloorPtr until we restore!
begin_room_selection:
        jsr next_floor_rand
        perform_zpcm_inc
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

        ; TODO: load up the room pointer and check properties and such to update
        ; our counters. Right now we don't have those (or any rooms that would set them)
        ; so we can skip that work and just use whatever we rolled. Should the counter
        ; logic fail, we might need to roll the room again.
        access_data_bank RoomBank
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
        restore_previous_bank ; RoomPoolBank ; Now we may read from BigFloorPtr again

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

        ; Temporary: if we failed to pick an exit for some weird reason, reject
        ; the whole floor
        lda FloorExitCount
        beq reject_floor

accept_floor:
        rts
reject_floor:
        inc16 floors_rerolled
        jmp begin_floor_generation
.endproc

; Generate a maze layout, and pick the player, boss, and exit locations
.proc FAR_init_floor
BigFloorPtr := R0
        ; The player won't initially have navigated the floor at all, so reset
        ; the nav items set
        lda #0
        sta PlayerNavState

        ; We are about to kick off floor generation, so grab a fresh floor PRNG
        ; seed based on the current run seed
        jsr generate_floor_seed
        far_call FAR_reset_shop_tracker

        access_data_bank #<.bank(test_floor_layout_pool)

        ; clear out the room flags entirely
        lda #0
        ldx #0
flag_loop:
        perform_zpcm_inc
        sta room_flags, x
        inx
        cpx #::FLOOR_SIZE
        bne flag_loop

        ; pick a random maze layout and load it in
        ; TODO: maybe this could use a global seed? it'd be nice to have a game-level seed
        jsr next_floor_rand

        ; FOR NOW, pull from the only test pool we have
        ; TODO: pick the pool to draw from based on the zone and level
        and #$0F
        asl
        tax
        lda test_floor_layout_pool, x
        sta BigFloorPtr
        lda test_floor_layout_pool+1, x
        sta BigFloorPtr+1

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
        lda PlayerZone
        cmp #1
        bne no_starting_treasure
        lda PlayerFloor
        cmp #1
        bne no_starting_treasure
        jmp done_with_player
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
        far_call FAR_preserve_room
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

; TEMPORARY
; TODO: Remove these and move them into the Zone definitions instead!!

; difficulty settings for regular spawning
spawn_pool_floor_min_lut:
        .byte 0, 0, 16, 48
spawn_pool_floor_max_lut:
        .byte 32, 64, 96, 128
spawn_pool_population_lut:
        .byte 8, 10, 12, 16
; sets of enemies to use in challenge rooms
spawn_set_low_lut:
        .byte <(spawnset_a53_z1_f1), <(spawnset_a53_z1_f2), <(spawnset_a53_z1_f3), <(spawnset_a53_z1_f4)
spawn_set_high_lut:
        .byte >(spawnset_a53_z1_f1), >(spawnset_a53_z1_f2), >(spawnset_a53_z1_f3), >(spawnset_a53_z1_f4)

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

        st16 SpawnPoolPtr, spawn_pool_generic
        ; for now, fudge the settings based on floor?
        ; TODO: read this out of the ZONE settings instead!
        lda #0
        sta SpawnPoolMin
        lda PlayerFloor
        tax
        dex ; make it 0-based
        lda spawn_pool_floor_min_lut, x
        sta SpawnPoolMin
        lda spawn_pool_floor_max_lut, x
        sta SpawnPoolMax
        lda spawn_pool_population_lut, x
        sta PopulationLimit
        ; fingers crossed!
        near_call FAR_spawn_entities_from_pool

        jmp room_cleared
spawn_boss_enemies:

        ; for now, fudge the settings based on floor?
        ; TODO: read this out of the ZONE settings instead!
        lda PlayerFloor
        tax
        dex ; make it 0-based
        lda spawn_set_low_lut, x
        sta SpawnSetPtr+0
        lda spawn_set_high_lut, x
        sta SpawnSetPtr+1
        ; that should be enough!
        near_call FAR_spawn_entities_from_spawn_set

        jmp room_cleared
room_cleared:

        ; If this is a shop room, roll shop loot
        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        bne done_with_shop_rolls
        jsr roll_shop_loot
done_with_shop_rolls:

        rts
.endproc

.proc roll_shop_loot
LootTablePtr := R0
ItemId := R2
; R3 is clobbered by the loot rolling function
CurrentTile := R4 
        perform_zpcm_inc

        ; TODO: pick the loot table based on the zone? maybe based on some
        ; data from the room too. undecided!
        ;st16 LootTablePtr, test_treasure_table

        lda PlayerFloor
        cmp #3
        bcs pick_rare_loot
pick_common_loot:
        st16 LootTablePtr, common_treasure_table
        jmp done_picking_loot
pick_rare_loot:
        st16 LootTablePtr, rare_treasure_table
done_picking_loot:

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
        jsr load_room_palette

        ; If this room is darkened, apply torchlight
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        bne apply_darkness
apply_lightness:
        lda #30
        sta current_torchlight_radius
        sta target_torchlight_radius
        far_call FAR_lighten_entire_inactive_torchlight
        jmp done_with_torchlight
apply_darkness:
        lda target_torchlight_radius
        cmp #30
        bne no_instant_darkness
        lda #0
        sta current_torchlight_radius
no_instant_darkness:
        lda PlayerTorchlightRadius
        sta target_torchlight_radius
        far_call FAR_darken_entire_inactive_torchlight
done_with_torchlight:

        restore_previous_bank

        ; Mark this room as visited
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_VISITED
        sta room_flags, x
        lda #1
        sta HudMapDirty

        ; set the initial enemies active counter to nonzero,
        ; so we process at least one full beat before considering the room to be "empty"
        lda #1
        sta enemies_active

        rts
.endproc

; Called during gameplay, not during generation. Handles ongoing room flag
; state, and checks for any entities that need to spawn post-generation
.proc FAR_handle_room_spawns
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
check_room_clear:
        lda enemies_active
        bne all_done

        perform_zpcm_inc

        ; Is this room already cleared?
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne check_chest_spawn

        ; This room is freshly cleared! Mark it so
        lda room_flags, x
        ora #ROOM_FLAG_CLEARED
        sta room_flags, x
        lda #1
        sta HudMapDirty
        jmp all_done

check_chest_spawn:
        lda room_flags, x
        and #ROOM_FLAG_TREASURE_SPAWNED
        bne all_done

        perform_zpcm_inc

        ; spawn in a chest
        lda #TILE_TREASURE_CHEST
        sta EntityId
        lda #<BG_TILE_TREASURE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_TREASURE_CHEST | PAL_YELLOW)
        sta EntityAttribute
        jsr spawn_entity

        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_SPAWNED
        sta room_flags, x
        
all_done:
        perform_zpcm_inc
        ; reset the enemies active counter for the next beat
        lda #0
        sta enemies_active

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

OUT_OF_BOUNDS = 0
GRASSY_EXTERIOR = 1
CAVE_INTERIOR = 2

.segment "DATA_4"

        .include "../build/rooms/Grasslands_Standard.incs"
        .include "../build/rooms/Caves_Standard.incs"
        .include "../build/rooms/OutOfBounds.incs"
        .include "../build/rooms/ChallengeArena_Standard.incs"

.segment "DATA_6"

        .include "../build/rooms/Grasslands_Round.incs"
        .include "../build/rooms/Shop_Standard.incs"

.segment "DATA_3"

room_pools_lut:
        .word room_pool_out_of_bounds
        .word room_pool_grassy_exterior
        .word room_pool_cave_interior
room_pools_banks:
        .byte <.bank(room_pool_out_of_bounds)
        .byte <.bank(room_pool_grassy_exterior)
        .byte <.bank(room_pool_cave_interior)

.macro room_entry room_label
        .addr room_label
        .byte <.bank(room_label), >.bank(room_label)
.endmacro

; =============================
; Floors - collections of rooms
; =============================

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

.include "../build/floors/grass_cave_mix_01.incs"
.include "../build/floors/grass_cave_mix_02.incs"
.include "../build/floors/grass_cave_mix_03.incs"
.include "../build/floors/grass_cave_mix_04.incs"
.include "../build/floors/grass_cave_mix_05.incs"
.include "../build/floors/grass_cave_mix_06.incs"
.include "../build/floors/grass_cave_mix_07.incs"
.include "../build/floors/grass_cave_mix_08.incs"
.include "../build/floors/grass_cave_mix_09.incs"
.include "../build/floors/grass_cave_mix_10.incs"

.include "../build/floors/test_floor_corner_cases.incs"

; eventually we'll want a whole big list of these
; for now, 16 entries just like the floor mazes
test_floor_layout_pool:
        ; draw a specific floor for testing
        
        ;.repeat 16
        ;.word floor_test_floor_corner_cases
        ;.endrepeat    

        ; the real floor data
        
        .word floor_grass_cave_mix_01
        .word floor_grass_cave_mix_01
        .word floor_grass_cave_mix_02
        .word floor_grass_cave_mix_03
        .word floor_grass_cave_mix_04
        .word floor_grass_cave_mix_04
        .word floor_grass_cave_mix_05
        .word floor_grass_cave_mix_05
        .word floor_grass_cave_mix_06
        .word floor_grass_cave_mix_06
        .word floor_grass_cave_mix_07
        .word floor_grass_cave_mix_08
        .word floor_grass_cave_mix_08
        .word floor_grass_cave_mix_09
        .word floor_grass_cave_mix_10
        .word floor_grass_cave_mix_10


