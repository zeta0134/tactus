        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "torchlight.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"

global_rng_seed: .res 1
room_ptr_low: .res ::FLOOR_SIZE
room_ptr_high: .res ::FLOOR_SIZE
room_bank: .res ::FLOOR_SIZE
room_flags: .res ::FLOOR_SIZE ; what did we spawn in here? what is the current status of those things?
room_seeds: .res ::FLOOR_SIZE
room_floorplan: .res ::FLOOR_SIZE ; properties of this cell in the floor's maze layout
room_properties: .res ::FLOOR_SIZE ; properties of the selected room that populates this cell
chest_spawned: .res 1
enemies_active: .res 1

room_population_order: .res ::FLOOR_SIZE

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
        ; Detail needs to be regenerated the same for each room when we (re-)enter, so
        ; set that here
        jsr set_fixed_room_seed

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

        jsr draw_battlefield_overlays

        far_call FAR_reset_inactive_queue
        rts
.endproc

.proc draw_battlefield_overlays
RoomPtr := R0
OverlayPtr := R2

check_north:
        ldx PlayerRoomIndex
        lda room_floorplan, x
        and #ROOM_EXIT_FLAG_NORTH
        beq check_east

        lda PlayerRoomIndex
        sec
        sbc #::FLOOR_WIDTH
        tax
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_chamber_north
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        beq interior_chamber_north
        ; TODO: Shop, Chamber as category
exterior_chamber_north:
        ldy #Room::ExteriorOverlayNorth        
        jmp draw_overlay_north
interior_chamber_north:
        ldy #Room::InteriorOverlayNorth
        jmp draw_overlay_north
boss_chamber_north:
        ldy #Room::ChallengeOverlayNorth
        jmp draw_overlay_north
draw_overlay_north:
        lda (RoomPtr), y
        sta OverlayPtr+0
        iny
        lda (RoomPtr), y
        ; Sanity check: is this a valid pointer? If not, bail
        beq check_east
        sta OverlayPtr+1
        jsr draw_single_battlefield_overlay

check_east:
        ldx PlayerRoomIndex
        lda room_floorplan, x
        and #ROOM_EXIT_FLAG_EAST
        beq check_south

        lda PlayerRoomIndex
        clc
        adc #1
        tax
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_chamber_east
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        beq interior_chamber_east
        ; TODO: Shop, Chamber as category
exterior_chamber_east:
        ldy #Room::ExteriorOverlayEast
        jmp draw_overlay_east
interior_chamber_east:
        ldy #Room::InteriorOverlayEast
        jmp draw_overlay_east
boss_chamber_east:
        ldy #Room::ChallengeOverlayEast
        jmp draw_overlay_east
draw_overlay_east:
        lda (RoomPtr), y
        sta OverlayPtr+0
        iny
        lda (RoomPtr), y
        ; Sanity check: is this a valid pointer? If not, bail
        beq check_south
        sta OverlayPtr+1
        jsr draw_single_battlefield_overlay

check_south:
        ldx PlayerRoomIndex
        lda room_floorplan, x
        and #ROOM_EXIT_FLAG_SOUTH
        beq check_west

        lda PlayerRoomIndex
        clc
        adc #::FLOOR_WIDTH
        tax
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_chamber_south
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        beq interior_chamber_south
        ; TODO: Shop, Chamber as category
exterior_chamber_south:
        ldy #Room::ExteriorOverlaySouth
        jmp draw_overlay_south
interior_chamber_south:
        ldy #Room::InteriorOverlaySouth
        jmp draw_overlay_south
boss_chamber_south:
        ldy #Room::ChallengeOverlaySouth
        jmp draw_overlay_south
draw_overlay_south:
        lda (RoomPtr), y
        sta OverlayPtr+0
        iny
        lda (RoomPtr), y
        ; Sanity check: is this a valid pointer? If not, bail
        beq check_west
        sta OverlayPtr+1
        jsr draw_single_battlefield_overlay

check_west:
        ldx PlayerRoomIndex
        lda room_floorplan, x
        and #ROOM_EXIT_FLAG_WEST
        beq done

        lda PlayerRoomIndex
        sec
        sbc #1
        tax
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_chamber_west
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        beq interior_chamber_west
        ; TODO: Shop, Chamber as category
exterior_chamber_west:
        ldy #Room::ExteriorOverlayWest
        jmp draw_overlay_west
interior_chamber_west:
        ldy #Room::InteriorOverlayWest
        jmp draw_overlay_west
boss_chamber_west:
        ldy #Room::ChallengeOverlayWest
        jmp draw_overlay_west
draw_overlay_west:
        lda (RoomPtr), y
        sta OverlayPtr+0
        iny
        lda (RoomPtr), y
        ; Sanity check: is this a valid pointer? If not, bail
        beq done
        sta OverlayPtr+1
        jsr draw_single_battlefield_overlay

done:
        rts
.endproc

.proc draw_single_battlefield_overlay
RoomPtr := R0
OverlayPtr := R2
CurrentTileId := R10
; R12 - R15 are scratch for the detail function
loop:
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

DETAIL_SPARSE_GRASS         = 0
DETAIL_SPARSE_SHROOMS       = 2
DETAIL_SPARSE_GRASS_SHROOMS = 4
DETAIL_CAVE                 = 6
DETAIL_CAVE_SHROOMS         = 8
DETAIL_SAND                 = 10
DETAIL_GRASS_WALL_BORDER    = 12
DETAIL_GRASS_WALL           = 14

; indexed by the direct values above
detail_variants_table:
        .addr detail_sparse_grass
        .addr detail_sparse_shrooms
        .addr detail_sparse_grass_shrooms
        .addr detail_cave
        .addr detail_cave_shrooms
        .addr detail_sand
        .addr detail_grass_wall_border
        .addr detail_grass_wall

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

detail_grass_wall_border:
        .repeat 19
        .word BG_TILE_MAP_TILES_0018 ; plain grass wall border
        .endrepeat
        .word BG_TILE_MAP_TILES_0019 ; grass wall border w/ cattails
        .word BG_TILE_MAP_TILES_0019 ; grass wall border w/ cattails
        .word BG_TILE_MAP_TILES_0023 ; grass wall border w/ dancing flower
        .word BG_TILE_MAP_TILES_0023 ; grass wall border w/ dancing flower
        .word BG_TILE_MAP_TILES_0020 ; grass wall border w/ short grass, low
        .word BG_TILE_MAP_TILES_0020 ; grass wall border w/ short grass, low
        .word BG_TILE_MAP_TILES_0020 ; grass wall border w/ short grass, low
        .word BG_TILE_MAP_TILES_0021 ; grass wall border w/ tall grass
        .word BG_TILE_MAP_TILES_0021 ; grass wall border w/ tall grass
        .word BG_TILE_MAP_TILES_0021 ; grass wall border w/ tall grass
        .word BG_TILE_MAP_TILES_0022 ; grass wall border w/ short grass, high
        .word BG_TILE_MAP_TILES_0022 ; grass wall border w/ short grass, high
        .word BG_TILE_MAP_TILES_0022 ; grass wall border w/ short grass, high

detail_grass_wall:
        .repeat 19
        .word BG_TILE_MAP_TILES_0002 ; plain light grey solid
        .endrepeat
        .word BG_TILE_MAP_TILES_0024 ; light grey w/ cattails
        .word BG_TILE_MAP_TILES_0024 ; light grey w/ cattails
        .word BG_TILE_MAP_TILES_0028 ; light grey w/ dancing flower
        .word BG_TILE_MAP_TILES_0028 ; light grey w/ dancing flower
        .word BG_TILE_MAP_TILES_0025 ; light grey w/ short grass, low
        .word BG_TILE_MAP_TILES_0025 ; light grey w/ short grass, low
        .word BG_TILE_MAP_TILES_0025 ; light grey w/ short grass, low
        .word BG_TILE_MAP_TILES_0026 ; light grey w/ tall grass
        .word BG_TILE_MAP_TILES_0026 ; light grey w/ tall grass
        .word BG_TILE_MAP_TILES_0026 ; light grey w/ tall grass
        .word BG_TILE_MAP_TILES_0027 ; light grey w/ short grass, high
        .word BG_TILE_MAP_TILES_0027 ; light grey w/ short grass, high
        .word BG_TILE_MAP_TILES_0027 ; light grey w/ short grass, high

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
        jsr next_fixed_rand ; result in A, clobbers Y
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
        txa
        sta room_population_order, x
        inx
        cpx #::FLOOR_SIZE
        bne init_loop

        lda #64 ; somewhat arbitrary
        sta Iterations
shuffle_loop:
        jsr next_fixed_rand
        and #(::FLOOR_SIZE-1)
        sta SourceIndex
        jsr next_fixed_rand
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
; TODO: pay attention to these
; ChallengeCount := R?
; ShopCount := R?
; SpawnFoundCount := R?
        jsr shuffle_room_order

begin_floor_generation:
        lda #0
        sta CurrentRoomCounter
room_loop:
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
        access_data_bank RoomPoolBank
begin_room_selection:
        jsr next_fixed_rand
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
        ; TODO: special feature counters
        jmp accept_this_room
reject_this_room:
        restore_previous_bank ; RoomBank
        jmp begin_room_selection
accept_this_room:
        ; Load in the chosen properties of this room, which we'll
        ; use later during chamber generation
        ldy #Room::Properties
        lda (RoomPtr), y
        sta room_properties, x
        ; Done reading room data for now
        restore_previous_bank ; RoomBank
        restore_previous_bank ; RoomPoolBank

        inc CurrentRoomCounter
        lda CurrentRoomCounter
        cmp #::FLOOR_SIZE
        jne room_loop

        rts
.endproc

; Generate a maze layout, and pick the player, boss, and exit locations
.proc FAR_init_floor
BigFloorPtr := R0
BossIndex := R2
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

        ; set each room up with its own RNG low byte
        ; TODO: should this be based on the floor's fixed seed?
        ldx #0
seed_loop:
        perform_zpcm_inc
        jsr next_rand
        sta room_seeds, x
        inx
        cpx #::FLOOR_SIZE
        bne seed_loop

        ; pick a random maze layout and load it in
        ; TODO: maybe this could use a global seed? it'd be nice to have a game-level seed
        ; ... though I guess also todo: write a 6502 maze generator
        jsr next_rand

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

        ; Okay now, pick a random room for the player to spawn in
        jsr next_rand
        and #(::FLOOR_SIZE-1)
        ; TODO: check that this is a valid spawning location (at the very least, not out of bounds)
        sta PlayerRoomIndex
        ; Mark the player's room as cleared, so they don't load in surrounded by mobs
        tax
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
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x
done_with_player:

        ; Next choose the boss location; importantly this should NOT be the
        ; same room the player spawned in
        ; TODO: check that this is a valid spawning location (at the very least, not out of bounds)
        ; TODO: remove this and use an explicit challenge-room instead, with min/max as appropriate
        ; (also TODO: not all challenge rooms spawn the big key, etc. we might need a treasure populating
        ; loop in here)
boss_loop:
        perform_zpcm_inc
        jsr next_rand
        and #(::FLOOR_SIZE-1)
        cmp PlayerRoomIndex
        beq boss_loop
        tax
        lda #(ROOM_FLAG_BOSS | ROOM_FLAG_REVEALED)
        sta room_flags, x
        stx BossIndex

        ; Choose the exit stairs location; this should again not be the same
        ; location as the player OR the boss
        ; TODO: check that this is a valid spawning location (at the very least, not out of bounds)
exit_loop:
        perform_zpcm_inc
        jsr next_rand
        and #(::FLOOR_SIZE-1)
        cmp PlayerRoomIndex
        beq exit_loop
        cmp BossIndex
        beq exit_loop
        tax
        lda #ROOM_FLAG_EXIT_STAIRS
        sta room_flags, x

        ; Aaaand.... that's it? I think that's it
        perform_zpcm_inc

        restore_previous_bank
        rts
.endproc

.proc FAR_init_current_room
RoomPtr := R0
RoomBank := R2
EntityList := R4

        ; NEW: the room pointer and associated bank are just part of the
        ; floor data now; load and use that
        ldx PlayerRoomIndex
        lda room_bank, x
        sta RoomBank
        lda room_ptr_low, x
        sta RoomPtr+0
        lda room_ptr_high, x
        sta RoomPtr+1
        access_data_bank RoomBank
        jsr initialize_battlefield
        jsr load_room_palette

        ; If this room is darkened, apply torchlight
        ldy #Room::Properties
        lda (RoomPtr), y
        and #ROOM_PROPERTIES_DARK
        bne apply_darkness
apply_lightness:
        lda #30
        sta current_torchlight_radius
        sta target_torchlight_radius
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
done_with_torchlight:

        restore_previous_bank

        ; Mark this room as visited
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_VISITED
        sta room_flags, x
        lda #1
        sta HudMapDirty

        ; If the player has already collected this room's treausre, then don't allow
        ; another one to spawn
        lda room_flags, x
        and #ROOM_FLAG_TREASURE_COLLECTED
        bne treasure_already_collected
        lda #0
        sta chest_spawned
        jmp converge_treasure
treasure_already_collected:
        lda #1
        sta chest_spawned
converge_treasure:

        ; set the initial enemies active counter to nonzero, so we process at least one full beat before considering the room to be "empty"
        lda #1
        sta enemies_active

        ; Does this room have exit stairs? If so, spawn those first
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq no_exit_stairs
        jsr spawn_exit_block
        ldx PlayerRoomIndex
no_exit_stairs:        

        ; Has the player already cleared this room?
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne room_cleared
        ; If this is a boss room, we need to use the boss pool
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne spawn_boss_enemies
spawn_basic_enemies:
        jsr spawn_basic_enemies_from_pool
        jmp room_cleared
spawn_boss_enemies:
        jsr spawn_boss_enemies_from_pool
        jmp room_cleared
room_cleared:

        rts
.endproc

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
        lda chest_spawned
        bne all_done

        perform_zpcm_inc

        ; load the fixed seed for the players current room
        jsr set_fixed_room_seed
        ; spawn in a chest
        lda #TILE_TREASURE_CHEST
        sta EntityId
        lda #<BG_TILE_TREASURE_CHEST
        sta EntityPattern
        lda #(>BG_TILE_TREASURE_CHEST | PAL_YELLOW)
        sta EntityAttribute
        jsr spawn_entity
        lda #1
        sta chest_spawned
        
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
        jsr next_fixed_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta TempRow
        jsr next_fixed_rand
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
        cmp #TILE_REGULAR_FLOOR
        beq is_valid_space
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

.proc spawn_basic_enemies_from_pool
CollectionPtr := R0
PoolPtr := R2
EntityList := R4
        ; Everything we are about to do depends on the room seed, so fix that in place before we start
        jsr set_fixed_room_seed

        ; First find the pool collection for this zone
        lda PlayerZone
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tax

        

        .if ::DEBUG_TEST_FLOOR
        access_data_bank #<.bank(debug_zone_list)
        ; DEBUG: use a fake list for testing new enemy types
        lda debug_zone_list, x
        sta CollectionPtr
        lda debug_zone_list+1, x
        sta CollectionPtr+1
        .else
        access_data_bank #<.bank(zone_list_basic)
        ; Use the real list
        lda zone_list_basic, x
        sta CollectionPtr
        lda zone_list_basic+1, x
        sta CollectionPtr+1
        .endif

        ; Now load the appropriate pool list for this floor from the collection
        lda PlayerFloor
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tay
        lda (CollectionPtr), y
        sta PoolPtr
        iny
        lda (CollectionPtr), y
        sta PoolPtr+1
        ; Here we need to pick a random number from 0-15, and use that to index the pool to select
        ; one of the enemy lists
        jsr next_fixed_rand ; clobbers Y
        and #%00001111
        asl ; still indexing words
        tay
        lda (PoolPtr), y
        sta EntityList
        iny
        lda (PoolPtr), y
        sta EntityList+1
        ; Finally, now that we have the entity list, spawn random enemies from it
        jsr spawn_entity_list
done:

        restore_previous_bank

        rts
.endproc

.proc spawn_boss_enemies_from_pool
CollectionPtr := R0
PoolPtr := R2
EntityList := R4
        ; Everything we are about to do depends on the room seed, so fix that in place before we start
        jsr set_fixed_room_seed

        ; First find the pool collection for this zone
        lda PlayerZone
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tax

        .if ::DEBUG_TEST_FLOOR
        access_data_bank #<.bank(debug_boss_zone_list)
        ; DEBUG: use a fake list for testing new enemy types
        lda debug_boss_zone_list, x
        sta CollectionPtr
        lda debug_boss_zone_list+1, x
        sta CollectionPtr+1
        .else
        ; Use the real list
        access_data_bank #<.bank(zone_list_boss)
        lda zone_list_boss, x
        sta CollectionPtr
        lda zone_list_boss+1, x
        sta CollectionPtr+1
        .endif

        ; Now load the appropriate pool list for this floor from the collection
        lda PlayerFloor
        sec
        sbc #1 ; the lists are 0-based, but zones are 1-based
        asl ; the lists contain words
        tay
        lda (CollectionPtr), y
        sta PoolPtr
        iny
        lda (CollectionPtr), y
        sta PoolPtr+1
        ; Here we need to pick a random number from 0-3, and use that to index the pool to select
        ; one of the enemy lists
        jsr next_fixed_rand ; clobbers Y
        and #%00000011
        asl ; still indexing words
        tay
        lda (PoolPtr), y
        sta EntityList
        iny
        lda (PoolPtr), y
        sta EntityList+1
        ; Finally, now that we have the entity list, spawn random enemies from it
        jsr spawn_entity_list
done:
        
        restore_previous_bank

        rts
.endproc

.proc spawn_exit_block
EntityId := R1
EntityPattern := R2
EntityAttribute := R3
        jsr set_fixed_room_seed
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

room_pools_lut:
        .word room_pool_out_of_bounds
        .word room_pool_grassy_exterior
        .word room_pool_cave_interior
room_pools_banks:
        .byte <.bank(room_pool_out_of_bounds)
        .byte <.bank(room_pool_grassy_exterior)
        .byte <.bank(room_pool_cave_interior)

        .segment "DATA_3"

.include "../build/rooms/GrassyTest_Standard.incs"
.include "../build/rooms/CaveTest_Standard.incs"
.include "../build/rooms/OutOfBounds.incs"
.include "../build/rooms/ChallengeArena_Standard.incs"

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
        .repeat 12
        room_entry room_GrassyTest_Standard
        .endrepeat
        .repeat 4
        room_entry room_ChallengeArena_Standard
        .endrepeat

room_pool_cave_interior:
        .repeat 12
        room_entry room_CaveTest_Standard
        .endrepeat
        .repeat 4
        room_entry room_ChallengeArena_Standard
        .endrepeat

.include "../build/floors/test_floor_wide_open.incs"
.include "../build/floors/test_floor_grass_with_caves.incs"

; eventually we'll want a whole big list of these
; for now, 16 entries just like the floor mazes
test_floor_layout_pool:
        .repeat 16
        .word floor_test_floor_grass_with_caves
        .endrepeat

; =============================================
; Enemies - Pools of spawns for rooms to select
; =============================================

; Enemy lists have an arbitrary length, and can house any number
; of spawns. ALL spawns will appear in a room that uses a list, so
; if you want to vary the amount, make several similar lists

; Each pool is a FIXED length:
; - Basic pools have 16 entries
; - Boss pools have 4 entries
; If including fewer unique enemy lists, be sure
; to duplicate the list so that it is the full size

; =============================================
;                Zone 1 - Basic
; =============================================
el_intermediate_slimes:
        .byte 2 ; length
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   3
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 4

el_zombies_and_slimes:
        .byte 3 ; length
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  3
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   3
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1

el_spiders_and_slimes:
        .byte 3 ; length
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE),   3
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 2

el_zombies_and_spiders:
        .byte 2 ; length
        .byte TILE_SPIDER_BASIC, <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),  2
        .byte TILE_ZOMBIE_BASIC, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD), 3

el_basic_mix:
        .byte 4 ; length
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  2
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2

basic_pool_zone_1_floor_1:
        ; Make sure all sections add up to 16
        .repeat 3
        .word el_intermediate_slimes
        .endrepeat

        .repeat 4
        .word el_zombies_and_slimes
        .endrepeat

        .repeat 3
        .word el_spiders_and_slimes
        .endrepeat

        .repeat 3
        .word el_zombies_and_spiders
        .endrepeat

        .repeat 3
        .word el_basic_mix
        .endrepeat

; =============================================
;                Zone 1 - Boss
; =============================================

el_slime_pit:
        .byte 3 ; length
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 6
        .byte TILE_ADVANCED_SLIME,     <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),    4


boss_pool_zone_1_floor_1:
        ; Make sure sections add up to 4
        .repeat 4
        .word el_slime_pit
        .endrepeat

; =============================================
;                Zone 2 - Basic
; =============================================

el_zombies_and_spiders2:
        .byte 4 ; length
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   3
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  5

el_birds_and_spiders:
        .byte 3
        .byte TILE_BIRB_LEFT_BASIC,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_YELLOW), 2
        .byte TILE_BIRB_RIGHT_BASIC, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,     <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_BLUE),   3

el_hello_mr_mole:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,    <BG_TILE_MOLE_HOLE,   (>BG_TILE_MOLE_HOLE   | PAL_RED),    2
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  3

el_full_mix:
        .byte 6
        .byte TILE_MOLE_HOLE_BASIC,    <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    1
        .byte TILE_BASIC_SLIME,        <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_BLUE),   2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_YELLOW), 1
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  2
        .byte TILE_SPIDER_BASIC,       <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_BIRB_LEFT_BASIC,    <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_YELLOW), 1

el_zombie_hoard:
        .byte 2
        .byte TILE_INTERMEDIATE_SLIME, <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,       <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  7

basic_pool_zone_1_floor_2:
        ; Make sure all sections add up to 16
        .repeat 3
        .word el_zombies_and_spiders2
        .endrepeat

        .repeat 3
        .word el_birds_and_spiders
        .endrepeat

        .repeat 4
        .word el_hello_mr_mole
        .endrepeat

        .repeat 3
        .word el_full_mix
        .endrepeat

        .repeat 3
        .word el_zombie_hoard
        .endrepeat

; =============================================
;                Zone 2 - Boss
; =============================================

el_scary_scary_spiders:
        .byte 3
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,    (>BG_TILE_SPIDER    | PAL_BLUE),   2
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,    (>BG_TILE_SPIDER    | PAL_YELLOW), 4
        .byte TILE_MOLE_HOLE_BASIC,     <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_RED),    4

el_rockin_flock:
        .byte 7
        .byte TILE_ZOMBIE_INTERMEDIATE,     <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_YELLOW), 4
        .byte TILE_BIRB_LEFT_BASIC,         <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_YELLOW), 1
        .byte TILE_BIRB_RIGHT_BASIC,        <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_YELLOW), 1
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),   2
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE),   2
        .byte TILE_BIRB_LEFT_ADVANCED,      <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_RED),    1
        .byte TILE_BIRB_RIGHT_ADVANCED,     <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    1

boss_pool_zone_1_floor_2:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_scary_scary_spiders
        .endrepeat
        .repeat 2
        .word el_rockin_flock
        .endrepeat


; =============================================
;                Zone 3 - Basic
; =============================================

el_slimes_and_imm_zombies:
        .byte 5
        .byte TILE_BASIC_SLIME,         <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED),    1
        .byte TILE_ZOMBIE_BASIC,        <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 3

el_mole_and_friends:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,         <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_RED),   4
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),  1
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE),  1
        .byte TILE_ZOMBIE_BASIC,            <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_WORLD), 3

el_mix3:
        .byte 6
        .byte TILE_MOLE_HOLE_BASIC,        <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    2
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_BLUE),   1
        .byte TILE_ZOMBIE_BASIC,           <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,           <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_YELLOW), 2

el_adv_slimes_and_spiders:
        .byte 3
        .byte TILE_ADVANCED_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),  3
        .byte TILE_SPIDER_BASIC,    <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE), 3
        .byte TILE_MOLE_HOLE_BASIC, <BG_TILE_MOLE_HOLE,  (>BG_TILE_MOLE_HOLE  | PAL_RED),  2

basic_pool_zone_1_floor_3:
        ; Make sure all sections add up to 16
        .repeat 4
        .word el_slimes_and_imm_zombies
        .endrepeat

        .repeat 4
        .word el_mole_and_friends
        .endrepeat

        .repeat 4
        .word el_mix3
        .endrepeat

        .repeat 4
        .word el_adv_slimes_and_spiders
        .endrepeat

; =============================================
;                Zone 3 - Boss
; =============================================

el_aaaaaahhh_spiders:
        .byte 4
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_BLUE),   4
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_YELLOW), 5
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_RED),    3

el_mr_whiskers:
        .byte 4
        .byte TILE_MOLE_HOLE_BASIC,         <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_RED),  6
        .byte TILE_MOLE_HOLE_ADVANCED,      <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_BLUE), 4
        .byte TILE_BIRB_LEFT_INTERMEDIATE,  <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE), 1
        .byte TILE_BIRB_RIGHT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_BLUE), 1

boss_pool_zone_1_floor_3:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_aaaaaahhh_spiders
        .endrepeat
        .repeat 2
        .word el_mr_whiskers
        .endrepeat

; =============================================
;                Zone 4 - Basic
; =============================================

el_advanced_slimes_and_zombies:
        .byte 4
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 4
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED), 2
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED), 2
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 2

el_oops_all_chasers:
        .byte 6
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_ADVANCED,        <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_RED),    2
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_YELLOW), 2
        .byte TILE_SPIDER_ADVANCED,        <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_RED),    3
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT,  (>BG_TILE_BIRB_IDLE_LEFT  | PAL_BLUE),   1
        .byte TILE_BIRB_RIGHT_ADVANCED,    <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    1

el_advanced_moles_and_friends:
        .byte 5
        .byte TILE_MOLE_HOLE_ADVANCED,  <BG_TILE_MOLE_HOLE,  (>BG_TILE_MOLE_HOLE  | PAL_BLUE),   4
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_RED),    2
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,     (>BG_TILE_SPIDER     | PAL_YELLOW), 1
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED),    2

el_zombie_hoard_round_2:
        .byte 3
        .byte TILE_INTERMEDIATE_SLIME,  <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_YELLOW), 3
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 5
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED),    6

el_extra_healthy_mix4:
        .byte 6
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE,     (>BG_TILE_ZOMBIE_IDLE     | PAL_RED),    3
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,      (>BG_TILE_SLIME_IDLE      | PAL_RED),    1
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_RED),    1
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,          (>BG_TILE_SPIDER          | PAL_YELLOW), 2
        .byte TILE_BIRB_RIGHT_ADVANCED, <BG_TILE_BIRB_IDLE_RIGHT, (>BG_TILE_BIRB_IDLE_RIGHT | PAL_RED),    2
        .byte TILE_MOLE_HOLE_ADVANCED,  <BG_TILE_MOLE_HOLE,       (>BG_TILE_MOLE_HOLE       | PAL_BLUE),   2

basic_pool_zone_1_floor_4:
        ; Make sure all sections add up to 16
        .repeat 4
        .word el_advanced_slimes_and_zombies
        .endrepeat

        .repeat 3
        .word el_oops_all_chasers
        .endrepeat

        .repeat 3
        .word el_advanced_moles_and_friends
        .endrepeat

        .repeat 3
        .word el_zombie_hoard_round_2
        .endrepeat

        .repeat 3
        .word el_extra_healthy_mix4
        .endrepeat

; =============================================
;                Zone 4 - Boss
; =============================================

el_reinforcements:
        .byte 7
        .byte TILE_ZOMBIE_ADVANCED,     <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_RED),    6
        .byte TILE_ZOMBIE_INTERMEDIATE, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_YELLOW), 2
        .byte TILE_ZOMBIE_BASIC,        <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD),  2
        .byte TILE_SPIDER_ADVANCED,     <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_RED),    4
        .byte TILE_SPIDER_INTERMEDIATE, <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_YELLOW), 2
        .byte TILE_SPIDER_BASIC,        <BG_TILE_SPIDER,      (>BG_TILE_SPIDER      | PAL_BLUE),   1
        .byte TILE_ADVANCED_SLIME,      <BG_TILE_SLIME_IDLE,  (>BG_TILE_SLIME_IDLE  | PAL_RED),    2

el_family_reunion:
        .byte 14
        .byte TILE_BASIC_SLIME,            <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_BLUE),   1
        .byte TILE_INTERMEDIATE_SLIME,     <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_YELLOW), 1
        .byte TILE_ADVANCED_SLIME,         <BG_TILE_SLIME_IDLE,     (>BG_TILE_SLIME_IDLE     | PAL_RED),    2
        .byte TILE_ZOMBIE_BASIC,           <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_WORLD),  1
        .byte TILE_ZOMBIE_INTERMEDIATE,    <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_YELLOW), 1
        .byte TILE_ZOMBIE_ADVANCED,        <BG_TILE_ZOMBIE_IDLE,    (>BG_TILE_ZOMBIE_IDLE    | PAL_RED),    3
        .byte TILE_SPIDER_BASIC,           <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_BLUE),   1
        .byte TILE_SPIDER_INTERMEDIATE,    <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_YELLOW), 1
        .byte TILE_SPIDER_ADVANCED,        <BG_TILE_SPIDER,         (>BG_TILE_SPIDER         | PAL_RED),    2
        .byte TILE_MOLE_HOLE_BASIC,        <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_RED),    1
        .byte TILE_MOLE_HOLE_ADVANCED,     <BG_TILE_MOLE_HOLE,      (>BG_TILE_MOLE_HOLE      | PAL_BLUE),   2
        .byte TILE_BIRB_LEFT_BASIC,        <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_YELLOW), 1
        .byte TILE_BIRB_LEFT_INTERMEDIATE, <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_BLUE),   1
        .byte TILE_BIRB_LEFT_ADVANCED,     <BG_TILE_BIRB_IDLE_LEFT, (>BG_TILE_BIRB_IDLE_LEFT | PAL_RED),    2

boss_pool_zone_1_floor_4:
        ; Make sure sections add up to 4
        .repeat 2
        .word el_reinforcements
        .endrepeat
        .repeat 2
        .word el_family_reunion
        .endrepeat

; Each zone is a collection of pools, one pool for each floor

zone_1_basic_pools:
        .word basic_pool_zone_1_floor_1 ; floor 1
        .word basic_pool_zone_1_floor_2 ; floor 2
        .word basic_pool_zone_1_floor_3 ; floor 3
        .word basic_pool_zone_1_floor_4 ; floor 4

zone_1_boss_pools:
        .word boss_pool_zone_1_floor_1 ; floor 1
        .word boss_pool_zone_1_floor_2 ; floor 2
        .word boss_pool_zone_1_floor_3 ; floor 3
        .word boss_pool_zone_1_floor_4 ; floor 4

; And finally, here is the list of zone collections
; (Note: for demo purposes, only zone 1 actually exists; this
; list is mostly useless as a result.)
zone_list_basic:
        .word zone_1_basic_pools ; zone 1
        .word zone_1_basic_pools ; zone 2
        .word zone_1_basic_pools ; zone 3
        .word zone_1_basic_pools ; zone 4

zone_list_boss:
        .word zone_1_boss_pools ; zone 1
        .word zone_1_boss_pools ; zone 2
        .word zone_1_boss_pools ; zone 3
        .word zone_1_boss_pools ; zone 4


; ============================================================================================
;                                     DEBUG ZONES BELOW
; ============================================================================================

el_debug_enemies:
        .byte 1
        .byte TILE_BASIC_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_BLUE), 1
        ;.byte TILE_ZOMBIE_BASIC, <BG_TILE_ZOMBIE_IDLE, (>BG_TILE_ZOMBIE_IDLE | PAL_WORLD), 4
        ;.byte TILE_MOLE_HOLE_BASIC, <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_RED), 2
        ;.byte TILE_MOLE_HOLE_ADVANCED, <BG_TILE_MOLE_HOLE, (>BG_TILE_MOLE_HOLE | PAL_BLUE), 2

el_debug_boss_enemies:
        .byte 1
        .byte TILE_ADVANCED_SLIME, <BG_TILE_SLIME_IDLE, (>BG_TILE_SLIME_IDLE | PAL_RED), 1

debug_pool:
        .repeat 16
        .word el_debug_enemies
        .endrepeat

debug_pool_collection:
        .word debug_pool
        .word debug_pool
        .word debug_pool
        .word debug_pool

debug_zone_list:
        .word debug_pool_collection        
        .word debug_pool_collection
        .word debug_pool_collection
        .word debug_pool_collection

debug_boss_pool:
        .repeat 16
        .word el_debug_boss_enemies
        .endrepeat

debug_boss_pool_collection:
        .word debug_boss_pool
        .word debug_boss_pool
        .word debug_boss_pool
        .word debug_boss_pool

debug_boss_zone_list:
        .word debug_boss_pool_collection        
        .word debug_boss_pool_collection
        .word debug_boss_pool_collection
        .word debug_boss_pool_collection


