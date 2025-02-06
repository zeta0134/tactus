        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "levels.inc"
        .include "player.inc"
        .include "procgen.inc"
        .include "prng.inc"
        .include "rainbow.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .segment "LEVEL_DATA_STRUCTURES_0"

        .include "../build/structures/GrassMonomino.incs"
        .include "../build/structures/GrassDominoR0.incs"
        .include "../build/structures/GrassDominoR1.incs"
        .include "../build/structures/GrassTrominoI_R0.incs"
        .include "../build/structures/GrassTrominoI_R1.incs"
        .include "../build/structures/GrassTrominoL_R0.incs"
        .include "../build/structures/GrassTrominoL_R1.incs"
        .include "../build/structures/GrassTrominoL_R2.incs"
        .include "../build/structures/GrassTrominoL_R3.incs"

        .include "../build/structures/BigGrass3x3.incs"
        .include "../build/structures/BigGrassDoubleSquare_R0.incs"
        .include "../build/structures/BigGrassDoubleSquare_R1.incs"
        .include "../build/structures/BigGrassWideU.incs"

        .include "../build/structures/AbsolutelyNothing.incs"

        .include "../build/structures/GrassyWarpWall.incs"
        .include "../build/structures/GrassyWarpStructure.incs"
        .include "../build/structures/CaveWarpWall.incs"
        .include "../build/structures/CaveWarpStructure.incs"
        .include "../build/structures/BlockingWarpWall.incs"
        .include "../build/structures/BlockingWarpStructure.incs"
        .include "../build/structures/FairyRingWarp.incs"

.macro structure_entry structure_label
        .addr structure_label
        .byte <.bank(structure_label), >.bank(structure_label)
.endmacro

; used for data bank targeting
; (keep all structure lists in a single bank. doesn't matter which one really)
all_structure_lists:

empty_structure_set:
        ; It's Bucket o' Nothing!
        .byte $0 ; RNG Mask
        structure_entry structure_AbsolutelyNothing
        ; Free for only 99.99.99!!!

test_structure_set_small:
        .byte $F ; RNG Mask
        structure_entry structure_GrassMonomino
        structure_entry structure_GrassDominoR0
        structure_entry structure_GrassDominoR1
        structure_entry structure_GrassDominoR1
        structure_entry structure_GrassTrominoI_R0
        structure_entry structure_GrassTrominoI_R0
        structure_entry structure_GrassTrominoI_R1
        structure_entry structure_GrassTrominoI_R1
        structure_entry structure_GrassTrominoL_R0
        structure_entry structure_GrassTrominoL_R0
        structure_entry structure_GrassTrominoL_R1
        structure_entry structure_GrassTrominoL_R1
        structure_entry structure_GrassTrominoL_R2
        structure_entry structure_GrassTrominoL_R2
        structure_entry structure_GrassTrominoL_R3
        structure_entry structure_GrassTrominoL_R3

test_structure_set_big:
        .byte $3 ; RNG Mask
        structure_entry structure_BigGrass3x3
        structure_entry structure_BigGrassDoubleSquare_R0
        structure_entry structure_BigGrassDoubleSquare_R1
        structure_entry structure_BigGrassWideU 

grassy_warp_structure_set:
        .byte $F
        .repeat 14
        structure_entry structure_GrassyWarpWall ; we reeeeally want this to be picked
        .endrepeat
        structure_entry structure_FairyRingWarp ; but we'll settle for one of these sometimes
        structure_entry structure_GrassyWarpStructure

cave_warp_structure_set:
        .byte $F
        .repeat 14
        structure_entry structure_CaveWarpWall ; we reeeeally want this to be picked
        .endrepeat
        structure_entry structure_FairyRingWarp ; but we'll settle for one of these sometimes
        structure_entry structure_CaveWarpStructure

blocking_warp_structure_set:
        .byte $F
        .repeat 15
        structure_entry structure_BlockingWarpWall ; we reeeeally want this to be picked
        .endrepeat
        structure_entry structure_BlockingWarpStructure ; but we'll settle for this if we have to


        ; should match procgen.s! we rely on several of its functions, and the far call overhead
        ; would be rather significant
        .segment "CODE_2"

; Very similar to draw_single_battlefield_overlay, but accounting for an
; additional offset for the top-left corner
.proc draw_structure
; RoomPtr := R0 - from call site
; Inputs
StructureList := R2
MaxStructures := R4
StructurePtr := R5
MapOffset := R7
; Extra state for this routine
OverlayPtr := R18

; roll_for_detail and process_exit_data both need this
; to be in a specific spot 
CurrentTileId := R10
; ... and will clobber these
DetailTablePtr := R12
ScratchPal := R14

PatternTemp := R12
AttrTemp := R13

        ldy #StructureDefinition::TileList
        lda (StructurePtr), y
        sta OverlayPtr+0
        iny
        lda (StructurePtr), y
        sta OverlayPtr+1

loop:
        perform_zpcm_inc
        ldy #0
        lda (OverlayPtr), y
        cmp #$FF
        jeq done

        ; basically the only necessary change for structure gen
        clc
        adc MapOffset
        tax

        sta CurrentTileId
        inc16 OverlayPtr

        ; for warp tile reasons, preserve pattern/att for a sec
        lda tile_patterns, x
        sta PatternTemp
        lda tile_attributes, x
        sta AttrTemp

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

        ; If this was a warp tile write the preserved pattern/attr out
        cmp #TILE_HIDDEN_WARP_FLOOR
        beq preserve_warp
        cmp #TILE_CRACKED_WARP_WALL
        beq preserve_warp
        jmp do_not_preserve_warp
preserve_warp:
        lda PatternTemp
        sta WarpOverlayPattern
        lda AttrTemp
        sta WarpOverlayAttr
        jsr _choose_warp_wall_tile
do_not_preserve_warp:

        ; structures can have detail too, so we need to roll for that here
        ; as we draw the things. (generally, maps, structures, and overlays
        ; can all do all the things. no limitations)
        ldy #0
        lda (OverlayPtr), y
        and #TILE_FLAG_DETAIL
        beq no_detail
        perform_zpcm_inc
        near_call FAR_roll_for_detail
no_detail:
        ; I don't know when we'd use it, but we might as well allow structures
        ; to include exits, and handle those properly. maybe warp zones?
        ldy #0
        lda (OverlayPtr), y
        and #TILE_FLAG_EXIT
        beq no_exit_flag
        perform_zpcm_inc
        near_call FAR_process_exit_data
no_exit_flag:
        ldy #0
        lda (OverlayPtr), y
        and #TILE_FLAG_SIGN
        beq no_sign_flag
        near_call FAR_process_sign_data
no_sign_flag:
        inc16 OverlayPtr
        jmp loop
done:
        perform_zpcm_inc
        rts
.endproc

; returns #0 for success, any other value for failure
; TODO: optimize the **crap** out of this, it'll be a big giant
; performance bottleneck for structures that have a high
; failure chance (complex requirements, densely packed rooms, etc)
.proc can_draw_structure_here
; RoomPtr := R0 - from call site
; Inputs
StructureList := R2
MaxStructures := R4
StructurePtr := R5
MapOffset := R7
; Extra state for this routine
RequirementsPtr := R18
        ldy #StructureDefinition::Requirements
        lda (StructurePtr), y
        sta RequirementsPtr+0
        iny
        lda (StructurePtr), y
        sta RequirementsPtr+1

loop:
        perform_zpcm_inc
        ldy #0
        lda (RequirementsPtr), y
        cmp #$FF
        beq success
        clc
        adc MapOffset
        tax
        inc16 RequirementsPtr
        lda (RequirementsPtr), y
        cmp battlefield, x
        bne failure
        inc16 RequirementsPtr
        jmp loop
failure:
        perform_zpcm_inc
        lda #$FF
        rts
success:
        perform_zpcm_inc
        lda #0
        rts
.endproc

.proc roll_for_structure_position
; RoomPtr := R0 - from call site
; Inputs
StructureList := R2
MaxStructures := R4
StructurePtr := R5
; Outputs
MapOffset := R7
; Scratch
RngRange := R18
TempPosX := R19
TempPosY := R20
        
        ; X pos!
        ldy #StructureDefinition::MinPosX
        lda (StructurePtr), y
        sta TempPosX
        ldy #StructureDefinition::MaxPosX
        lda (StructurePtr), y
        sec
        sbc TempPosX
        beq use_x_directly
        bcc invalid_range
        sta RngRange
        in_range_smol next_room_rand, RngRange
        clc
        adc TempPosX
        sta TempPosX
use_x_directly:
        perform_zpcm_inc

        ; Y pos!
        ldy #StructureDefinition::MinPosY
        lda (StructurePtr), y
        sta TempPosY
        ldy #StructureDefinition::MaxPosY
        lda (StructurePtr), y
        sec
        sbc TempPosY
        beq use_y_directly
        bcc invalid_range
        sta RngRange
        in_range_smol next_room_rand, RngRange
        clc
        adc TempPosY
        sta TempPosY
use_y_directly:
        perform_zpcm_inc

        ldx TempPosY
        lda row_number_to_tile_index_lut, x
        clc
        adc TempPosX
        sta MapOffset
        rts

invalid_range:
        ; how did this happen? well, try to spawn it extreme top-left, which
        ; will probably fail. (quickly though.) oh well!
        ; (as written, the exporter should be making this branch unreachable)
        lda #0
        sta MapOffset
        rts
.endproc

 ; somewhat arbitrary! for regular structures, we break out of structure gen
 ; if we're spending too much time on placements, so the game doesn't lock up
 ; for a long time between floors. Better to have the occasional sparse room
 ; than to suffer long loads. If this is happening a lot, consider altering the
 ; set of structures for a given area to include more things with a high chance
 ; of succeeding in their spawn attempts.
MAX_STRUCTURE_SPAWN_FAILURES = 32

.proc roll_structures_from_list
; RoomPtr := R0 - from call site
; Inputs
StructureList := R2
MaxStructures := R4
; Outputs
StructurePtr := R5
; Generally clobbered by other stuff: R6-R14
; Scratch:
StructureBank := R16
FailedSpawnAttempts := R17

        lda #0
        sta FailedSpawnAttempts

        access_data_bank #<.bank(all_structure_lists)

        ; sanity
        lda MaxStructures
        jeq done
loop:
        perform_zpcm_inc
        ; pick a structure out of the list at random
        jsr next_room_rand
        ldy #0
        and (StructureList), y
        ; expand to the size of a structure entry
        asl
        asl
        ; prep for reading
        tay
        iny ; skip over the RNG Mask byte
        ; aww yiss
        lda (StructureList), y
        sta StructurePtr+0
        iny
        lda (StructureList), y
        sta StructurePtr+1
        iny
        lda (StructureList), y
        sta StructureBank

        perform_zpcm_inc
        access_data_bank StructureBank
        ; first, pick a random location for this structure
        jsr roll_for_structure_position
        ; now check to see if the structure can actually fit there
        jsr can_draw_structure_here
        bne structure_spawn_failure
        ; finally, draw the structure in place
        jsr draw_structure
        dec MaxStructures
        jmp converge
structure_spawn_failure:
        inc FailedSpawnAttempts
converge:
        restore_previous_bank ; Structure
        lda MaxStructures
        beq done
        lda FailedSpawnAttempts
        cmp #MAX_STRUCTURE_SPAWN_FAILURES ; arbitrary!
        bcs done
        jmp loop
done:
        restore_previous_bank ; StructureList
        rts
.endproc

; Used to spawn warp points, and maybe in the future for reeeeally
; important structures that we need to make absolutely sure don't fail
; to spawn.
; Obviously this is a lockup risk if we ever try to force a structure
; set that, for whatever reason, CANNOT succeed. Try not to do that!
.proc force_single_structure_from_list
; RoomPtr := R0 - from call site
; Inputs
StructureList := R2
MaxStructures := R4
FailedSpawnAttempts := R17

keep_looping_darn_it:
        lda #1
        sta MaxStructures
        jsr roll_structures_from_list
        perform_zpcm_inc
        lda FailedSpawnAttempts
        ; If ALL of the spawn attempts failed, keep trying
        ; until they don't!
        cmp #MAX_STRUCTURE_SPAWN_FAILURES
        bcs keep_looping_darn_it
        ; Otherwise, we know exactly one structure spawned from the list,
        ; which is all we ever wanted.
        rts
.endproc

; Used to camoflauge wall warp tiles properly, according
; to the tile they displaced
warp_equivalence_tile_lut:
        ; Grasslands
        .word BG_TILE_MAP_TILES_0176, BG_TILE_MAP_TILES_0239
        .word BG_TILE_MAP_TILES_0177, BG_TILE_MAP_TILES_0239
        .word BG_TILE_MAP_TILES_0178, BG_TILE_MAP_TILES_0239
        .word BG_TILE_MAP_TILES_0179, BG_TILE_MAP_TILES_0239
        ; Caves
        .word BG_TILE_MAP_TILES_0246, BG_TILE_MAP_TILES_0255
        .word BG_TILE_MAP_TILES_0247, BG_TILE_MAP_TILES_0255
        .word BG_TILE_MAP_TILES_0248, BG_TILE_MAP_TILES_0255
        .word BG_TILE_MAP_TILES_0249, BG_TILE_MAP_TILES_0255
        ; For now, everything else uses basic bricks. Deal with it.
MAX_EQUIVALENCE_TILE = 8
DEFAULT_WARP_TILE = BG_TILE_MAP_TILES_0223

; Because we can't choose which wall tile we displace, we also can't
; predict what the replacement graphic needs to be. Here we fix it, yes!
; Clobbers Y, expects X to be the target tile, etc
.proc _choose_warp_wall_tile        
        ldy #0
loop:
        lda WarpOverlayPattern
        cmp warp_equivalence_tile_lut + 0, y
        bne nope
        lda WarpOverlayAttr
        and #($FF - PAL_MASK)
        cmp warp_equivalence_tile_lut + 1, y
        bne nope
yup:
        lda warp_equivalence_tile_lut + 2, y
        sta tile_patterns, x
        lda WarpOverlayAttr
        and #PAL_MASK
        ora warp_equivalence_tile_lut + 3, y
        sta tile_attributes, x
        rts
nope:
        iny
        iny
        iny
        iny
        cpy #(MAX_EQUIVALENCE_TILE * 4)
        bcc loop
no_match:
        lda #<DEFAULT_WARP_TILE
        sta tile_patterns, x
        lda WarpOverlayAttr
        and #PAL_MASK
        ora #>DEFAULT_WARP_TILE
        sta tile_attributes, x
        rts
.endproc

.proc FAR_spawn_structures_from_zonedef
; RoomPtr := R0 - from call site
StructureList := R2
MaxStructures := R4
        ; the player's starting chamber should never
        ; spawn structures (as they might intersect with the
        ; player's spawn coordinates, and we don't currently
        ; prevent this)
        lda PlayerRoomIndex
        cmp RoomIndexToGenerate
        beq skip_structure_spawning
        lda WarpEntranceRoomIndex
        cmp RoomIndexToGenerate
        beq skip_structure_spawning

        ldx RoomIndexToGenerate
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_INTERIOR
        beq roll_interior_sets
        cmp #ROOM_CATEGORY_EXTERIOR
        jeq roll_exterior_sets
        ; shops and challenge rooms should never spawn structures
skip_structure_spawning:
        rts

roll_interior_sets:
        perform_zpcm_inc
        access_data_bank #<.bank(all_zones_data_page)
        ldy #ZoneDefinition::InteriorStructureLargeMaxMax
        lda (PlayerZonePtr), y
        beq done_with_interior_large_structures ; please don't divide by zero
        sta MaxStructures
        inc MaxStructures  ; in_range rolls from 0 - N-1
        perform_zpcm_inc
        in_range_smol next_room_rand, MaxStructures
        sta MaxStructures
        ldy #ZoneDefinition::InteriorStructureLargeSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr roll_structures_from_list
done_with_interior_large_structures:
        ldy #ZoneDefinition::InteriorStructureSmallMaxMax
        lda (PlayerZonePtr), y
        beq done_with_interior_small_structures ; please don't divide by zero
        sta MaxStructures
        inc MaxStructures  ; in_range rolls from 0 - N-1
        perform_zpcm_inc
        in_range_smol next_room_rand, MaxStructures
        sta MaxStructures
        ldy #ZoneDefinition::InteriorStructureSmallSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr roll_structures_from_list
done_with_interior_small_structures:
        perform_zpcm_inc
        ; If this room should have the warp portal, spawn that here
        lda RoomIndexToGenerate
        cmp WarpPortalRoomIndex
        bne skip_interior_warp_structures
        ; FORCE exactly one interior warp structure to spawn from the provided set
        ldy #ZoneDefinition::InteriorStructureWarpSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr force_single_structure_from_list
skip_interior_warp_structures:
        restore_previous_bank
        rts

roll_exterior_sets:
        access_data_bank #<.bank(all_zones_data_page)
        ldy #ZoneDefinition::ExteriorStructureLargeMaxMax
        lda (PlayerZonePtr), y
        beq done_with_exterior_large_structures ; please don't divide by zero
        sta MaxStructures
        inc MaxStructures  ; in_range rolls from 0 - N-1
        perform_zpcm_inc
        in_range_smol next_room_rand, MaxStructures
        sta MaxStructures
        ldy #ZoneDefinition::ExteriorStructureLargeSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr roll_structures_from_list
done_with_exterior_large_structures:
        ldy #ZoneDefinition::ExteriorStructureSmallMaxMax
        lda (PlayerZonePtr), y
        beq done_with_exterior_small_structures ; please don't divide by zero
        sta MaxStructures
        inc MaxStructures  ; in_range rolls from 0 - N-1
        perform_zpcm_inc
        in_range_smol next_room_rand, MaxStructures
        sta MaxStructures
        ldy #ZoneDefinition::ExteriorStructureSmallSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr roll_structures_from_list
done_with_exterior_small_structures:
        perform_zpcm_inc
        ; If this room should have the warp portal, spawn that here
        lda RoomIndexToGenerate
        cmp WarpPortalRoomIndex
        bne skip_exterior_warp_structures
        ; FORCE exactly one interior warp structure to spawn from the provided set
        ldy #ZoneDefinition::ExteriorStructureWarpSet
        lda (PlayerZonePtr), y
        sta StructureList+0
        iny
        lda (PlayerZonePtr), y
        sta StructureList+1
        jsr force_single_structure_from_list
skip_exterior_warp_structures:
        restore_previous_bank
        rts
.endproc