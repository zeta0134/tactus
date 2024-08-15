; proper organization eventually; let me get the skeleton of this 
; mess written before I commit to subfolders
    .macpack longbranch

    .include "../build/tile_defs.inc"

    .include "battlefield.inc"
    .include "enemies.inc"
    .include "far_call.inc"
    .include "levels.inc"
    .include "prng.inc"
    .include "rainbow.inc"
    .include "word_util.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"

    .zeropage

; TODO: see if we can move these into scratch, they should mostly only
; be used in a few spots
EntityPtr: .res 2
SpawnListPtr: .res 2
ConditionalPtr: .res 2
SpawnPoolPtr: .res 2
SpawnSetPtr: .res 2

    .segment "RAM"
; populated when an entity is spawned, call sites can
; read this to perform further processing as required
SpawnedEntityIndex: .res 1

; temps used by the spawning routines
SpawnedEntityRow: .res 1
SpawnedEntityCol: .res 1
SpawnAttemptsCounter: .res 1
AccumulatedAggression: .res 1
AccumulatedTrickiness: .res 1
AccumulatedLootReward: .res 1
AccumulatedTankiness: .res 1
AccumulatedPopulation: .res 1

; spawning range for the generic spawn pool, generally used
; to set a sliding difficulty per zone
SpawnPoolMin: .res 1
SpawnPoolMax: .res 1

; difficulty caps to control generation
AggressionMax: .res 1
TrickinessMax: .res 1
LootRewardMax: .res 1
TankinessMax: .res 1
PopulationLimit: .res 1

    .segment "DATA_3"

spawn_pool_data:
    .include "leveldata/spawns.asm"
    .include "leveldata/spawn_lists.asm"
    .include "leveldata/spawn_pools.asm"

    .segment "CODE_4"

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

; For rapidly computing the tile row
row_number_to_tile_index_lut:
        .repeat ::BATTLEFIELD_HEIGHT, i
        .byte (::BATTLEFIELD_WIDTH * i)
        .endrepeat

.proc pick_safe_coordinate
        jsr next_room_rand
        and #%00011111
        tax
        lda random_row_table, x
        sta SpawnedEntityRow
        jsr next_room_rand
        and #%00011111
        tax
        lda random_col_table, x
        sta SpawnedEntityCol
        ldx SpawnedEntityRow
        lda row_number_to_tile_index_lut, x
        clc
        adc SpawnedEntityCol
        sta SpawnedEntityIndex
done:
        rts
.endproc

.proc single_disco_tile
        ldx SpawnedEntityIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        beq is_valid_space
        ; no good; this is not a floor tile. We cannot spawn anything here,
        ; try again
        lda #$FF
        rts
is_valid_space:
        lda #0
        rts
.endproc

.proc cross_of_disco_tiles
        ; our location
        ldx SpawnedEntityIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        jne invalid_space
        ; the row above us
        lda SpawnedEntityIndex
        sec
        sbc #(BATTLEFIELD_WIDTH+0)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the row below us
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH+0)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the spaces to either side
        lda SpawnedEntityIndex
        clc
        adc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        sec
        sbc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
valid_space:
        lda #0
        rts
invalid_space:
        lda #$FF
        rts
.endproc

.proc ring_of_disco_tiles
        ; our location
        ldx SpawnedEntityIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        jne invalid_space
        ; the row above us
        lda SpawnedEntityIndex
        sec
        sbc #(BATTLEFIELD_WIDTH+1)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        jne invalid_space
        lda SpawnedEntityIndex
        sec
        sbc #(BATTLEFIELD_WIDTH+0)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        sec
        sbc #(BATTLEFIELD_WIDTH-1)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the row below us
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH-1)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH+0)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH+1)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the spaces to either side
        lda SpawnedEntityIndex
        clc
        adc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        sec
        sbc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
valid_space:
        lda #0
        rts
invalid_space:
        lda #$FF
        rts
.endproc

; mostly for intermediate slimes
.proc disco_tile_to_my_right
        ; our location
        ldx SpawnedEntityIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the space to our right
        lda SpawnedEntityIndex
        clc
        adc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
valid_space:
        lda #0
        rts
invalid_space:
        lda #$FF
        rts
.endproc

; mostly for advanced slimes
.proc disco_square_to_my_down_and_right
        ; our location
        ldx SpawnedEntityIndex
        lda battlefield, x
        and #%11111100 ; we only care about the index, not the color
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the space to our right
        lda SpawnedEntityIndex
        clc
        adc #1
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        ; the row below us
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH+0)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
        lda SpawnedEntityIndex
        clc
        adc #(BATTLEFIELD_WIDTH+1)
        tax
        lda battlefield, x
        and #%11111100
        cmp #TILE_DISCO_FLOOR
        bne invalid_space
valid_space:
        lda #0
        rts
invalid_space:
        lda #$FF
        rts
.endproc

.proc always_valid
        lda #0
        rts
.endproc

.proc __cond_trampoline
        jmp (ConditionalPtr)
.endproc

; spawns one (1) entity!
; call with EntityPtr already set up
; note: only interprets the SpawnListEntry portion, ignores all other attributes.
.proc spawn_entity
        ldy #SpawnListEntry::SpawnCheck
        lda (EntityPtr), y
        sta ConditionalPtr+0
        iny
        lda (EntityPtr), y
        sta ConditionalPtr+1

        lda #255
        sta SpawnAttemptsCounter

valid_space_loop:
        perform_zpcm_inc
        dec SpawnAttemptsCounter
        beq spawn_attempt_failed
        jsr pick_safe_coordinate
        jsr __cond_trampoline
        bne valid_space_loop

        ldx SpawnedEntityIndex
        ldy #SpawnListEntry::Behavior
        lda (EntityPtr), y
        sta battlefield, x
        ldy #SpawnListEntry::TileLow
        lda (EntityPtr), y
        sta tile_patterns, x
        ldy #SpawnListEntry::TileHighAttr
        lda (EntityPtr), y
        sta tile_attributes, x
        ldy #SpawnListEntry::Data
        lda (EntityPtr), y
        sta tile_data, x
        ldy #SpawnListEntry::Flags
        lda (EntityPtr), y
        sta tile_flags, x
done:
        rts
spawn_attempt_failed:
        ; for now, just exit
        ; TODO: call crash handler? yell? etc
        rts
.endproc

; call with CopiesToSpawn already populated
; basically just calls spawn_entity in a loop
.proc spawn_pack
PackSize := R19
pack_spawn_loop:
        jsr spawn_entity
        dec PackSize
        bne pack_spawn_loop
done:
        rts
.endproc

; Call with SpawnListPtr set to the start of the entity list. Will
; proceed to spawn every entity in the list. Clobbers EntityPtr!
.proc spawn_entity_list
ListLength := R18
PackSize := R19
        ldy #0
        lda (SpawnListPtr), y
        beq done
        sta ListLength
        inc16 SpawnListPtr

spawn_list_loop:
        ldy #0
        lda (SpawnListPtr), y
        sta EntityPtr+0
        inc16 SpawnListPtr
        lda (SpawnListPtr), y
        sta EntityPtr+1
        inc16 SpawnListPtr
        lda (SpawnListPtr), y
        sta PackSize
        inc16 SpawnListPtr
        jsr spawn_pack
        dec ListLength
        bne spawn_list_loop
        
done:
        rts
.endproc

; Call with SpawnPoolPtr already populated, and difficulty settings
; tweaked accordingly. (Right now that's just the pool range and pop limit)
.proc FAR_spawn_entities_from_pool
RngResult := R17
RngRange := R18
; used by spawn_pack
PackSize := R19
        access_data_bank #<.bank(spawn_pool_data)

        ; for now, fix these in place
        lda #3
        sta AggressionMax
        sta TrickinessMax
        sta LootRewardMax
        sta TankinessMax
        
        ; initialize counters
        lda #0
        sta AccumulatedAggression
        sta AccumulatedTankiness
        sta AccumulatedLootReward
        sta AccumulatedTrickiness
        sta AccumulatedPopulation

        ; basically, keep spawning until we hit our population cap
loop:
        lda AccumulatedPopulation
        cmp PopulationLimit
        bcc continue_spawning
        restore_previous_bank
        rts ; all done
continue_spawning:
        ; pick a random entity from the spawn pool
        ; roll twice and sum for a nice curve
        lda SpawnPoolMax
        sec
        sbc SpawnPoolMin
        sta RngRange
        in_range next_room_rand, RngRange
        sta RngResult
        in_range next_room_rand, RngRange
        clc
        adc RngResult
        clc
        adc SpawnPoolMin
        and #%11111110 ; fix to a word boundary
        tay
        lda (SpawnPoolPtr), y
        sta EntityPtr+0
        iny
        lda (SpawnPoolPtr), y
        sta EntityPtr+1

        ; check its properties to see if we are allowed to spawn it
        ; if not, try again
        ; TODO! for now, properties are unimplemented :(

        ; roll a random pack size
        ldy #SpawnPoolEntry::PackSizeMax
        lda (EntityPtr), y
        ldy #SpawnPoolEntry::PackSizeMin
        sec
        sbc (EntityPtr), y
        sta RngRange
        beq fixed_pack_size
variable_pack_size:
        in_range_smol next_room_rand, RngRange
fixed_pack_size:
        ldy #SpawnPoolEntry::PackSizeMin
        clc
        adc (EntityPtr), y
        sta PackSize
        
        ; increase the population count by the rolled pack size (it may
        ; slightly exceed the intended limit; this is fine)
        ; note: PackSize is clobbered by spawn_pack, so we need to do this first
        lda AccumulatedPopulation
        clc
        adc PackSize
        sta AccumulatedPopulation

        ; call the spawn_pack function
        jsr spawn_pack

        ; another!
        jmp loop
        ; unreachable !?
.endproc
        
; Call with SpawnSetPtr populated. Chooses ONE spawn list from the
; set, entirely at random, and spawns all the enemies in that list.
; (meant for challenge rooms and bosses, so it's really rather simple)
.proc FAR_spawn_entities_from_spawn_set
RngMask := R18
        access_data_bank #<.bank(spawn_pool_data)
        ldy #0
        lda (SpawnSetPtr), y
        sta RngMask
        jsr next_room_rand
        and RngMask
        ; A now holds one item in the list, but we need an address
        ; (2 bytes) and we need to skip past the length byte. do that
        ; here:
        asl
        ora #1
        tay
        ; set up the spawn list ptr:
        lda (SpawnSetPtr), y
        sta SpawnListPtr+0
        iny
        lda (SpawnSetPtr), y
        sta SpawnListPtr+1
        ; and spawn the list. simple!
        jsr spawn_entity_list

        restore_previous_bank
        rts
.endproc