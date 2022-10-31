        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "palette.inc"
        .include "player.inc"
        .include "prng.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.zeropage
DestPtr: .res 2

.segment "RAM"

.segment "PRGFIXED_C000"

.proc draw_active_tile
TargetIndex := R0
TileId := R1
        ldx TargetIndex
        lda TileId
        sta battlefield, x
        lda tile_index_to_row_lut, x
        tax
        lda #1
        sta active_tile_queue, x
        txa
        lsr
        tax
        lda #1
        sta active_attribute_queue, x
        rts
.endproc

tile_index_to_row_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte h
        .endrepeat
        .endrepeat

tile_index_to_col_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte w
        .endrepeat
        .endrepeat

.segment "PRG0_8000"

static_behaviors:
        .word update_smoke_puff      ; $00 - smoke puff
        .word update_slime           ; $04 - slime (idle pose)
        .word update_spider_base     ; $08 - spider (idle)
        .word update_spider_anticipate ; $0C - spider (anticipate)
        .word update_zombie_base     ; $10 - spider (idle)
        .word update_zombie_anticipate ; $14 - spider (anticipate)
        .word update_birb_left       ; $18
        .word update_birb_right      ; $1C
        .word update_birb_flying_left   ; $20
        .word update_birb_flying_right  ; $24
        .word update_mole_hole          ; $28
        .word update_mole_throwing      ; $2C
        .word update_mole_idle          ; $30
        .word update_wrench_projectile  ; $34
        .repeat 18
        .word no_behavior ; unimplemented
        .endrepeat
        .word draw_disco_tile ; $80 - plain floor
        .word draw_disco_tile ; $84 - disco floor
        .word no_behavior     ; $88 - wall top
        .word no_behavior     ; $8C - wall face
        .word no_behavior     ; $90 - pit edge
        ; safety: fill out the rest of the table
        .repeat 27
        .word no_behavior
        .endrepeat

direct_attack_behaviors:
        ; enemies
        .word direct_attack_puff
        .word direct_attack_slime
        .word direct_attack_spider
        .word direct_attack_spider
        .word direct_attack_zombie
        .word direct_attack_zombie
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_birb
        .word direct_attack_mole_hole
        .word direct_attack_mole_throwing
        .word direct_attack_mole_idle
        .word no_behavior ; wrench projectile, cannot be attacked
        .repeat 18
        .word no_behavior
        .endrepeat
        ; floors, statics, and technical tiles
        .word no_behavior ; $80 - plain floor
        .word no_behavior ; $84 - disco floor
        .word no_behavior ; $88 - wall top
        .word no_behavior ; $8C - wall face
        .word no_behavior ; $90 - pit edge
        .word no_behavior ; $94 - pit center
        .word attack_treasure_chest ; $98 - treasure chest
        .word no_behavior ; $9C - big key
        .word no_behavior ; $A0 - gold sack
        .word no_behavior ; $A4 - weapon shadow
        .word attack_exit_block ; $A8 - exit block
        .word no_behavior ; $AC - exit stairs
        ; safety: fill out the rest of the table
        .repeat 23
        .word no_behavior
        .endrepeat

indirect_attack_behaviors:
        .word no_behavior ; smoke puff can't attack itself
        .word indirect_attack_slime
        .word indirect_attack_spider
        .word indirect_attack_spider
        .word indirect_attack_zombie
        .word indirect_attack_zombie
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word indirect_attack_birb
        .word no_behavior ; moles - do not move, and therefore will never be indirectly attacked
        .word no_behavior
        .word no_behavior
        .word no_behavior ; wrench projectile, cannot be attacked
        .repeat 18
        .word no_behavior
        .endrepeat
        ; safety: fill out the rest of the table
        .repeat 32
        .word no_behavior
        .endrepeat

bonk_behaviors:
        .word no_behavior ; standing in a smoke puff is fine
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word basic_enemy_attacks_player
        .word no_behavior ; mole holes, when unoccupied, do no damage
        .word basic_enemy_attacks_player ; moles when bonked, mostly with the flail, *do* do damage
        .word basic_enemy_attacks_player
        .word projectile_attacks_player ; projectiles do damage, but also need to erase themselves
        .repeat 18
        .word no_behavior
        .endrepeat
        .word no_behavior ; $80 - plain floor
        .word no_behavior ; $84 - disco floor
        .word solid_tile_forbids_movement     ; $88 - wall top
        .word solid_tile_forbids_movement     ; $8C - wall face
        .word solid_tile_forbids_movement     ; $90 - pit edge
        .word no_behavior ; $94 - pit center
        .word solid_tile_forbids_movement ; $98 - treasure chest
        .word collect_key ; $9C - big key
        .word collect_gold_sack ; $A0 - gold sack
        .word collect_weapon ; $A4 - weapon shadow
        .word solid_tile_forbids_movement ; $A8 - exit block
        .word descend_stairs ; $AC - exit stairs
        .word no_behavior ; $B0
        .word no_behavior ; $B4
        .word no_behavior ; $B8
        .word no_behavior ; $BC
        .word no_behavior ; $C0
        .word no_behavior ; $C4
        .word no_behavior ; $C8
        .word collect_heart_container ; $CC - heart container
        ; safety: fill out the rest of the table
        .repeat 12
        .word no_behavior
        .endrepeat

; input tile in A
.proc draw_tile_here
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        sta battlefield, x
        ldx CurrentRow
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        lda #1
        sta inactive_attribute_queue, x
        rts
.endproc

.proc queue_row_x
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        lda #1
        sta inactive_attribute_queue, x
        rts
.endproc

.proc spawn_death_sprite_here
MetaSpriteIndex := R0
AttackSquare := R3
EffectiveAttackSquare := R10
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_RISE | SPRITE_PAL_3)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x

        ldy AttackSquare
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta sprite_table + MetaSpriteState::PositionY, x

        lda #SPRITES_DEATH_SKULL
        sta sprite_table + MetaSpriteState::TileIndex, x

sprite_failed:
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================

.proc no_behavior
        ; does what it says on the tin
        rts
.endproc

.proc draw_disco_tile
CurrentRow := R14
CurrentTile := R15
        ; TODO: maybe if the player's combo gauge is empty, we don't do the disco thing?

        ; here we want to draw a checkerboard pattern, which alternates every time the beat advances
        ; we can do this with an XOR of these low bits: X coordinate, Y coordinate, Beat Counter
        lda CurrentRow
        eor CurrentTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile
regular_tile:
        lda #TILE_DISCO_FLOOR
        jsr draw_tile_here
        rts
disco_tile:
        lda #TILE_REGULAR_FLOOR
        jsr draw_tile_here
        rts
.endproc

.proc __trampoline
        jmp (DestPtr)
        ; tail call
.endproc

; Note: parameters are intentionally backloaded, to allow the behavior functions to use R0+
; without conflict
.proc FAR_update_static_enemy_row
Length := R13
CurrentRow := R14
StartingTile := R15
        lda #::BATTLEFIELD_WIDTH
        sta Length
loop:
        ldx StartingTile
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda static_behaviors, x
        sta DestPtr
        lda static_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline
        inc StartingTile
        dec Length
        bne loop
        rts
.endproc

.proc update_dynamic_enemy_row
        ; TODO. Will have the same interface as static, and since these run later, they can have
        ; somewhat more intelligent selection of their destination without stepping on anyone's
        ; toes
        rts
.endproc

.proc FAR_clear_active_move_flags
        ldx #0
loop:
        lda tile_flags, x
        and #%01111111
        sta tile_flags, x
        inx
        cpx #BATTLEFIELD_SIZE
        bne loop
        rts
.endproc

.macro bail_if_already_moved
        ; All entities which can move use their high data flag to indicate that they have just done so.
        ; By bailing early, we prevent entities that care about this from accidentally being ticked
        ; twice in the same frame
        ; 76543210
        ; |
        ; +--------- actively moving
        lda tile_flags, x
        bpl continue
        rts
continue:
.endmacro

.macro if_valid_destination success_label,
        ; Screen edges are never okay
        ldx TargetTile
        lda tile_index_to_row_lut, x
        cmp #0
        beq failure
        cmp #(::BATTLEFIELD_HEIGHT-1)
        beq failure
        lda tile_index_to_col_lut, x
        cmp #0
        beq failure
        cmp #(::BATTLEFIELD_WIDTH-1)
        beq failure

        ldx TargetTile
        lda battlefield, x
        ; floors are unconditionally okay
        cmp #TILE_REGULAR_FLOOR
        beq success_label
        cmp #TILE_DISCO_FLOOR
        beq success_label
        ; puffs of smoke are only okay if they moved *last* frame
        ; (this resolves some weirdness with tile update order)
        cmp #TILE_SMOKE_PUFF
        bne failure
        lda tile_flags, x
        bpl success_label
failure:
.endmacro

.proc update_slime
CurrentTile := R15
        inc enemies_active
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate
        cmp #%11
        beq advanced
        ; Basic slimes have no update behavior; they are stationary
        rts
intermediate:
        jsr update_intermediate_slime
        rts
advanced:
        jsr update_advanced_slime
        rts
.endproc

.proc update_intermediate_slime
TargetTile := R0
CurrentRow := R14
CurrentTile := R15
        ; TODO: make several slime variants, with behavior keyed by the palette color

        ; Intermediate slime: every 2 beats, move horizontally. We'll use these state
        ; bits, which normally start all zero:
        ; 76543210
        ;      |||
        ;      |++-- beat counter
        ;      +---- direction flag: 0 = jump right, 1 = jump left
        ldx CurrentTile
        bail_if_already_moved
        lda tile_data, x
        and #%00000011
        cmp #1
        beq jump
continue_waiting:
        inc tile_data, x
        rts
jump:
        ; Now, use our tile data to determine which direction to jump
        lda tile_data, x
        and #%00000100
        beq jump_right
jump_left:
        lda CurrentTile
        sta TargetTile
        dec TargetTile
        jmp converge
jump_right:
        lda CurrentTile
        sta TargetTile
        inc TargetTile
converge:
        ; Sanity check: is the target tile free?
        if_valid_destination proceed_with_jump
cancel_jump:
        ; fix our state and exit
        ldx CurrentTile
        lda tile_data, x
        and #%11111100 ; reset the beat counter for the next attempt
        eor #%00000100 ; invert the direction: if there was a wall to one side, try the other side next time
        sta tile_data, x
        rts
proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_SLIME_BASE
        sta battlefield, y

        ; Set up our attributes for the next jump
        lda tile_data, x
        and #%11111100 ; reset the beat counter for the next attempt
        eor #%00000100 ; invert the direction: if there was a wall to one side, try the other side next time        
        sta tile_data, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Finally, flag ourselves as having just moved; this signals to the player that our old
        ; position is a valid target, and it also signals to the engine that we shouldn't be ticked
        ; a second time, if our target square comes up while we're scanning
        lda #%10000000
        sta tile_flags, y

        ldx CurrentRow
        jsr queue_row_x

        rts
.endproc

.proc update_advanced_slime
TargetTile := R0
TargetRow := R1
CurrentRow := R14
CurrentTile := R15
        ; Advanced slime: every beats, move in one of the 4 cardinal directions
        ; bits, which normally start all zero:
        ; 76543210
        ;       ||
        ;       ++-- next direction
        ldx CurrentTile
        bail_if_already_moved

        lda CurrentRow
        sta TargetRow

        lda tile_data, x
        and #%00000011
        cmp #0
        beq east
        cmp #1
        beq south
        cmp #2
        beq west
north:
        lda CurrentTile
        sec
        sbc #(BATTLEFIELD_WIDTH)
        sta TargetTile
        dec TargetRow
        jmp converge
east:
        lda CurrentTile
        clc
        adc #1
        sta TargetTile
        jmp converge
south:
        lda CurrentTile
        clc
        adc #(BATTLEFIELD_WIDTH)
        sta TargetTile
        inc TargetRow
        jmp converge
west:
        lda CurrentTile
        sec
        sbc #1
        sta TargetTile
converge:
        ; Sanity check: is the target tile free?
        if_valid_destination proceed_with_jump
cancel_jump:
        ; fix our state and exit
        ldx CurrentTile
        lda tile_data, x
        ; ahead and advance to the next direction
        clc
        adc #1 
        ; but not too far
        and #%00000011
        sta tile_data, x
        rts
proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_SLIME_BASE
        sta battlefield, y

        ; Set up our attributes for the next jump
        lda tile_data, x
        ; ahead and advance to the next direction
        clc
        adc #1 
        ; but not too far
        and #%00000011
        sta tile_data, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Finally, flag ourselves as having just moved; this signals to the player that our old
        ; position is a valid target, and it also signals to the engine that we shouldn't be ticked
        ; a second time, if our target square comes up while we're scanning
        lda #%10000000
        sta tile_flags, y

        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

.proc update_smoke_puff
        ; All a smoke puff needs to do is return to normal floor after one beat
        jsr draw_disco_tile
        rts
.endproc

; Spiders store their beat counter in tile_data, and damage in the low 7 bits of tile_flags

.proc update_spider_base
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        inc tile_data, x
        lda tile_data, x
        cmp #2 ; TODO: pick a threshold based on spider difficulty
        bcc no_change
        ; switch to our anticipation pose
        lda battlefield, x
        and #%00000011
        ora #TILE_SPIDER_ANTICIPATE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

no_change:
        rts
.endproc

; Result in A, clobbers R0
.proc player_manhattan_distance
PlayerDistance := R2
CurrentRow := R14
CurrentTile := R15
        ; First the row
        lda PlayerRow
        sec
        sbc CurrentRow
        bpl add_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
add_row_distance:
        sta PlayerDistance
        ; Now the column
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bpl add_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
add_col_distance:
        clc
        adc PlayerDistance
        sta PlayerDistance
        rts
.endproc

.proc update_spider_anticipate
TargetRow := R0
TargetTile := R1
PlayerDistance := R2
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow

        jsr player_manhattan_distance
track_player:
        ; First the row
        ; If we're outside the tracking radius, choose it randomly
        ; (here, A already has the distance from before)
        cmp #SPIDER_TARGET_RADIUS
        bcs randomly_target_row
        ; Otherwise target the player on the vertical axis
        lda PlayerRow
        sec
        sbc CurrentRow
        beq randomly_target_row
        bpl move_down
move_up:
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        dec TargetRow
        jmp row_target_converge
move_down:
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        inc TargetRow
        jmp row_target_converge
randomly_target_row:
        jsr next_rand
        bmi move_up
        jmp move_down
row_target_converge:
        ; Now the column
        ; If we're outside the tracking radius, choose it randomly
        lda PlayerDistance
        cmp #SPIDER_TARGET_RADIUS
        bcs randomly_target_col
        ; Otherwise target the player on the horizontal axis
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq randomly_target_col
        bpl move_right
move_left:
        dec TargetTile
        jmp col_target_converge
move_right:
        inc TargetTile
        jmp col_target_converge
randomly_target_col:
        jsr next_rand
        bmi move_left
        jmp move_right
col_target_converge:
        
        ; Now our destination tile is in TargetTile, make sure it's valid
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_SPIDER_BASE
        sta battlefield, x
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_SPIDER_BASE
        sta battlefield, y

        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #%10000000
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #0
        sta tile_flags, x

        ; Queue up both rows
        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

; Zombies work quite similarly to spiders, except they move cardinally instead of diagonally

.proc update_zombie_base
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        inc tile_data, x
        lda tile_data, x
        cmp #2 ; TODO: pick a threshold based on zombie difficulty
        bcc no_change
        ; switch to our anticipation pose
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_ANTICIPATE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

no_change:
        rts
.endproc

; utility functions
.proc pick_random_cardinal
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        lda CurrentRow
        sta TargetRow
        lda CurrentTile
        sta TargetTile

        jsr next_rand
        and #%00000011
        beq east
        cmp #1
        beq south
        cmp #2
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
east:
        inc TargetTile
        rts
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
west:
        dec TargetTile
        rts
.endproc

.proc target_player_cardinal
TargetRow := R0
TargetTile := R1
PlayerDistanceRow := R2
PlayerDistanceCol := R3
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        lda CurrentRow
        sta TargetRow
        lda CurrentTile
        sta TargetTile

        ; Compute the absolute distance the player is away from us on both axis, independently

        ; First the row
        lda PlayerRow
        sec
        sbc CurrentRow
        bpl save_row_distance
fix_row_minus:
        eor #$FF
        clc
        adc #1
save_row_distance:
        sta PlayerDistanceRow

        ; Now the column
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bpl save_col_distance
fix_col_minus:
        eor #$FF
        clc
        adc #1
save_col_distance:
        sta PlayerDistanceCol

        ; Now, whichever of these is bigger will be our axis of travel. If they re the same size,
        ; pick randomly
        lda PlayerDistanceRow
        sec
        sbc PlayerDistanceCol
        beq choose_randomly
        bmi move_horizontally
        jmp move_vertically
choose_randomly:
        jsr next_rand
        bmi move_horizontally
        jmp move_vertically

move_horizontally:
        ; If the player is to our right...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        bmi move_left
move_right: 
        inc TargetTile
        rts
move_left:
        dec TargetTile
        rts

move_vertically:
        ; If the player is below us...
        lda PlayerRow
        sec
        sbc CurrentRow
        bmi move_up
move_down:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
move_up:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        rts
.endproc

.proc update_zombie_anticipate
TargetRow := R0
TargetTile := R1
PlayerDistance := R2
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow

        jsr player_manhattan_distance
track_player:        
        ; If we're outside the tracking radius, choose our next position randomly
        ; (here, A already has the distance from before)
        cmp #ZOMBIE_TARGET_RADIUS
        bcs randomly_choose_direction
        ; Otherwise target the player
        jsr target_player_cardinal
        jmp location_chosen
randomly_choose_direction:
        jsr pick_random_cardinal
location_chosen:
        ; Now our destination tile is in TargetTile, make sure it's valid
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_BASE
        sta battlefield, x
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:        
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_ZOMBIE_BASE
        sta battlefield, y

        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #%10000000
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #0
        sta tile_flags, x

        ; Queue up both rows
        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

.proc update_birb_left
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; If the player is *directly* in front of us, then we should charge at them
        lda PlayerRow
        cmp CurrentRow
        bne do_not_charge
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq do_not_charge ; also how did this happen
        bpl face_to_the_right
chaaaaaaaaarge:
        ; Turn ourselves into our flying state
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_LEFT_FLYING
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts
do_not_charge:
        ; If the player is to the RIGHT of us...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq all_done
        bpl face_to_the_right
        ; ... otherwise, we're done
        rts
face_to_the_right:
        ; Turn to face the player. That's cute, and certainly not creepy at all!
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_RIGHT_BASE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
all_done:
        rts
.endproc

.proc update_birb_right
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ; If the player is *directly* in front of us, then we should charge at them
        lda PlayerRow
        cmp CurrentRow
        bne do_not_charge
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq do_not_charge ; also how did this happen
        bmi face_to_the_left
chaaaaaaaaarge:
        ; Turn ourselves into our flying state
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_RIGHT_FLYING
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts
do_not_charge:
        ; If the player is to the LEFT of us...
        lda PlayerCol
        ldx CurrentTile
        sec
        sbc tile_index_to_col_lut, x
        beq all_done
        bmi face_to_the_left
        ; ... otherwise, we're done
        rts
face_to_the_left:
        ; Turn to face the player. That's cute, and certainly not creepy at all!
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_LEFT_BASE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
all_done:
        rts
.endproc

.proc update_birb_flying_right
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        lda CurrentTile
        sta TargetTile

        ; CHAAAAAAAARGE blindly forward
        inc TargetTile
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_RIGHT_BASE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_RIGHT_FLYING
        sta battlefield, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #%10000000
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #0
        sta tile_flags, x

        ; Queue up both rows
        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

.proc update_birb_flying_left
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        lda CurrentTile
        sta TargetTile

        ; CHAAAAAAAARGE blindly forward
        dec TargetTile
        if_valid_destination proceed_with_jump
jump_failed:

        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_LEFT_BASE
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And all done
        rts

proceed_with_jump:
        ldx CurrentTile
        ldy TargetTile
        ; Draw ourselves at the target (keep our color palette)
        lda battlefield, x
        and #%00000011
        ora #TILE_BIRB_LEFT_FLYING
        sta battlefield, y

        ; Now, draw a puff of smoke at our current location
        ; this should use the same palette that we use
        lda battlefield, x
        and #%00000011
        ora #TILE_SMOKE_PUFF
        sta battlefield, x
        ; Write our new position to the data byte for the puff of smoke
        lda TargetTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #%10000000
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #0
        sta tile_flags, x

        ; Queue up both rows
        ldx CurrentRow
        jsr queue_row_x
        ldx TargetRow
        jsr queue_row_x

        rts
.endproc

MOLE_NORTH = 0
MOLE_EAST = 1
MOLE_SOUTH = 2
MOLE_WEST = 3

.proc update_mole_hole
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        lda tile_data, x
        cmp #2 ; TODO: pick a threshold based on zombie difficulty
        bcc continue_waiting

        ; Okay first, we cannot rise out of the ground if the player is too close,
        ; both for engine and gameplay reasons, so compute that
        jsr player_manhattan_distance
        cmp #MOLE_SUPPRESSION_RADIUS
        bcc do_nothing

        ; Now, we only pop up if the player is in our line of sight, and we'll throw
        ; a wrench at them (evenutally) so, first, does the player's column match ours?
        lda PlayerCol
        ldx CurrentTile
        cmp tile_index_to_col_lut, x
        beq line_of_sight_vertical

        ; What about the row?
        lda PlayerRow
        cmp CurrentRow
        beq line_of_sight_horizontal

        ; Neither? Then continue waiting, we can't "see" them from here
        jmp do_nothing
line_of_sight_vertical:
        ; if the player's row is less than ours...
        lda PlayerRow
        cmp CurrentRow
        bpl south
north:
        ; ... then we will throw north
        lda #MOLE_NORTH
        sta tile_data, x
        jmp switch_to_attack_pose
south:
        ; ... otherwise, we will throw south
        lda #MOLE_SOUTH
        sta tile_data, x
        jmp switch_to_attack_pose

line_of_sight_horizontal:
        ; if the player's column is more than ours...
        lda PlayerCol
        ldx CurrentTile
        cmp tile_index_to_col_lut, x
        bmi west
east:
        ; ... then we will throw north
        lda #MOLE_EAST
        sta tile_data, x
        jmp switch_to_attack_pose
west:
        ; ... otherwise, we will throw south
        lda #MOLE_WEST
        sta tile_data, x
        jmp switch_to_attack_pose

switch_to_attack_pose:
        ; switch to our anticipation pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_THROWING
        sta battlefield, x

        ldx CurrentRow
        jsr queue_row_x

        ; And we're done, the tile_data is set up for the next frame, and we don't
        ; need to bother with the flags byte this round

        rts

continue_waiting:
        inc tile_data, x
do_nothing:
        rts
.endproc

.proc update_mole_throwing
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow
        ; Using our tile data, determine which direction we will be attempting to throw
        ldx CurrentTile
        lda tile_data, x
        cmp #MOLE_EAST
        beq east
        cmp #MOLE_SOUTH
        beq south
        cmp #MOLE_WEST
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
east:
        inc TargetTile
        jmp attempt_to_spawn_wrench
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
west:
        dec TargetTile
attempt_to_spawn_wrench:
        if_valid_destination spawn_wrench
        jmp switch_to_idle_pose
spawn_wrench:
        ldx CurrentTile
        ldy TargetTile

        ; Draw a wrench at the chosen target location, using our palette from the
        ; current location
        lda battlefield, x
        and #%00000011
        ora #TILE_WRENCH_PROJECTILE
        sta battlefield, y
        ; Write the throw direction to the data byte for the wrench, that way
        ; it keeps going in the same direction we threw it initially
        lda tile_data, x
        sta tile_data, y
        ; Set the flags on the wrench to indicate that we have just moved,
        ; this prevents us from going an extra square in the east/south directions
        lda #%10000000
        sta tile_flags, y
        
        ldx TargetRow
        jsr queue_row_x

switch_to_idle_pose:

        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_IDLE
        sta battlefield, x
        ; reset tile_data to 0, it will be our counter for idle -> hole
        lda #0
        sta tile_data, x

        ldx CurrentRow
        jsr queue_row_x

        rts
.endproc

.proc update_mole_idle
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        lda tile_data, x
        cmp #2 ; TODO: pick a threshold based on mole difficulty?
        bcc continue_waiting

        ; Switch back into our hole pose
        ldx CurrentTile
        lda battlefield, x
        and #%00000011
        ora #TILE_MOLE_HOLE_BASE
        sta battlefield, x
        ; Again reset our delay counter
        lda #0
        sta tile_data, x
        ; Because we just went intangible this frame, mark ourselves as having "just moved"
        ; This allows the player to attack us on what, to them, feels like the frame when we
        ; were still above ground.
        lda tile_flags, x
        ora #%10000000
        sta tile_flags, x
        rts

continue_waiting:
        inc tile_data, x
        rts
.endproc

.proc update_wrench_projectile
TargetRow := R0
TargetTile := R1
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved

        ; Very similar to the mole's throwing pose, we first need to work out where the wrench
        ; wants to GO from here...
        lda CurrentTile
        sta TargetTile
        lda CurrentRow
        sta TargetRow

        ; Using our tile data, determine which direction we will be attempting to move
        ldx CurrentTile
        lda tile_data, x
        cmp #MOLE_EAST
        beq east
        cmp #MOLE_SOUTH
        beq south
        cmp #MOLE_WEST
        beq west
north:
        dec TargetRow
        lda TargetTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
east:
        inc TargetTile
        jmp attempt_to_spawn_wrench
south:
        inc TargetRow
        lda TargetTile
        clc
        adc #::BATTLEFIELD_WIDTH
        sta TargetTile
        jmp attempt_to_spawn_wrench
west:
        dec TargetTile
attempt_to_spawn_wrench:
        if_valid_destination spawn_new_wrench
        jmp despawn_old_wrench
spawn_new_wrench:
        ldx CurrentTile
        ldy TargetTile

        ; Draw a wrench at the chosen target location, using our palette from the
        ; current location
        lda battlefield, x
        and #%00000011
        ora #TILE_WRENCH_PROJECTILE
        sta battlefield, y
        ; Write the throw direction to the data byte for the wrench, that way
        ; it keeps going in the same direction we threw it initially
        lda tile_data, x
        sta tile_data, y
        ; Set the new wrench as active, so it isn't ticked multiple times
        lda #%10000000
        sta tile_flags, y
        
        ldx TargetRow
        jsr queue_row_x
        
despawn_old_wrench:
        ; mark ourselves as floor; we're done
        ; (no puff stool this time, projectiles can't be attacked)
        ldx CurrentTile
        lda #TILE_REGULAR_FLOOR
        sta battlefield, x
        ; clean up the other flags for posterity
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ldx CurrentRow
        jsr queue_row_x

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc FAR_attack_enemy_tile
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9
; We don't use these, but we should know not to clobber them
TargetRow := R14
TargetCol := R15

        ldx AttackSquare
        lda battlefield, x
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        lsr
        and #%01111110
        tax
        lda direct_attack_behaviors, x
        sta DestPtr
        lda direct_attack_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc

.proc direct_attack_puff
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
PlayerSquare := R2
AttackSquare := R3
WeaponSquaresIndex := R4
WeaponSquaresPtr := R5 ; R6
AttackLanded := R7
WeaponProperties := R8
TilesRemaining := R9
; Indirect target square, so the tile we attack knows its own location
EffectiveAttackSquare := R10 

; We don't use these, but we should know not to clobber them
TargetRow := R14
TargetCol := R15
        
        ; A puff stores the tile index of the enemy that moved in its
        ; tile_data, so we'll roll an indirect attack on that square
        ldx AttackSquare
        lda tile_data, x
        sta EffectiveAttackSquare
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        ldx EffectiveAttackSquare
        lda battlefield, x
        lsr
        and #%01111110
        tax
        lda indirect_attack_behaviors, x
        sta DestPtr
        lda indirect_attack_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc

.proc direct_attack_slime
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; If we have *just moved*, then ignore this attack
        ; (A valid attack can only land at our previous destination)
        ldx AttackSquare
        lda tile_flags, x
        bmi ignore_attack
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        jsr attack_slime_common
ignore_attack:
        rts
.endproc

.proc indirect_attack_slime
        jsr attack_slime_common
        rts
.endproc

.proc attack_slime_common
; For drawing tiles
TargetIndex := R0
TileId := R1

AttackLanded := R7
EffectiveAttackSquare := R10 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; FOR NOW, slimes have 1 HP, so there is no health bar. Just delete
        ; the slime by replacing it with a floor tile

        lda EffectiveAttackSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        jsr spawn_death_sprite_here

        ; Play an appropriately crunchy death sound
        st16 R0, sfx_defeat_enemy_pulse
        jsr play_sfx_pulse2
        st16 R0, sfx_defeat_enemy_noise
        jsr play_sfx_noise

        rts
.endproc

; TODO: all of these should have variable health based on difficulty

.proc direct_attack_spider
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_spider
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
done:
        jsr indirect_attack_with_hp
        rts
.endproc

.proc direct_attack_zombie
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_zombie
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #6
        sta EnemyHealth
done:
        jsr indirect_attack_with_hp
        rts
.endproc

.proc direct_attack_birb
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #1
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #2
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #4
        sta EnemyHealth
done:
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_birb
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda battlefield, x
        and #%00000011
        cmp #%01
        beq intermediate_hp
        cmp #%11
        beq advanced_hp
basic_hp:
        lda #1
        sta EnemyHealth
        jmp done
intermediate_hp:
        lda #2
        sta EnemyHealth
        jmp done
advanced_hp:
        lda #4
        sta EnemyHealth
done:
        jsr indirect_attack_with_hp
        rts
.endproc

.proc direct_attack_with_hp
AttackSquare := R3
EffectiveAttackSquare := R10 
        ; If we have *just moved*, then ignore this attack
        ; (A valid attack can only land at our previous destination)
        ldx AttackSquare
        lda tile_flags, x
        bmi ignore_attack
        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        jsr attack_with_hp_common
ignore_attack:
        rts
.endproc

.proc indirect_attack_with_hp
        jsr attack_with_hp_common
        rts
.endproc

.proc attack_with_hp_common
; For drawing tiles
TargetIndex := R0
TileId := R1

AttackLanded := R7
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; Add the player's currently equipped damage to our flags byte
        ldx EffectiveAttackSquare
        lda PlayerWeaponDmg
        clc
        adc tile_flags, x
        sta tile_flags, x
        ; Now check: if the damage, NOT including the movement bit, is greater than our health...
        and #%01111111
        cmp EnemyHealth
        bcs die
        ; TODO: if we implement health bars, we should draw one right now
        ; TODO: should we have a "weapon hit something" SFX?
        ; otherwise we're done
        rts

die:
        ; Replace ourselves with a regular floor, and spawn the usual death juice
        lda EffectiveAttackSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        jsr spawn_death_sprite_here

        ; Play an appropriately crunchy death sound
        st16 R0, sfx_defeat_enemy_pulse
        jsr play_sfx_pulse2
        st16 R0, sfx_defeat_enemy_noise
        jsr play_sfx_noise

        rts
.endproc

.proc direct_attack_mole_idle
EnemyHealth := R11
        lda #2
        sta EnemyHealth
        jsr direct_attack_with_hp
        rts
.endproc

.proc direct_attack_mole_throwing
EnemyHealth := R11
        lda #2
        sta EnemyHealth
        jsr direct_attack_with_hp
        rts
.endproc

.proc direct_attack_mole_hole
AttackSquare := R3
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ; Mole holes are intangible except on the frame they appear, since visually the mole
        ; was above ground from the player's point of view. So, check for that here
        ldx AttackSquare
        lda tile_flags, x
        bmi allow_attack
        rts
allow_attack:
        lda #2
        sta EnemyHealth
        lda AttackSquare
        sta EffectiveAttackSquare
        jsr indirect_attack_with_hp
        rts
.endproc

; map all 5 weapons to 16 entries, for a mostly fair random type
; we'll give longswords one extra slot, as they're a fairly decent
; weapon type that many players will find success with
cheaty_weapon_lut:
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        .byte WEAPON_DAGGER
        .byte WEAPON_BROADSWORD
        .byte WEAPON_LONGSWORD
        .byte WEAPON_SPEAR
        .byte WEAPON_FLAIL
        ; bonus percent
        .byte WEAPON_LONGSWORD

weapon_damage_lut:
        .byte 1, 2, 3, 3

TREASURE_WEAPON = 0
TREASURE_HEART = 1
TREASURE_GOLD = 2

; control frequency of gold, weapon, and heart container drops
; right now it feels like we should favor weapons, as the player
; has to work pretty hard to get a chest to spawn. Hearts are useful,
; gold not so much, it feels like a nothing drop
treasure_category_table:
        .repeat 4
        .byte TREASURE_GOLD
        .endrepeat
        .repeat 10
        .byte TREASURE_WEAPON
        .endrepeat
        .repeat 2
        .byte TREASURE_HEART
        .endrepeat

.proc attack_treasure_chest
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
WeaponPtr := R12 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; load the room seed before spawning the treasure
        jsr set_fixed_room_seed

        ; if this is a boss room, we need to always spawn the key!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        beq spawn_treasure
        jsr spawn_big_key
        rts
spawn_treasure:
        ; determine which weapon category to spawn
        jsr next_fixed_rand
        and #%00001111
        tax
        lda treasure_category_table, x
check_weapon:
        cmp #TREASURE_WEAPON
        bne check_gold
        jsr spawn_weapon
        rts
check_gold:
        cmp #TREASURE_GOLD
        bne spawn_heart
        jsr spawn_gold_sack
        rts
spawn_heart:
        jsr spawn_heart_container
        rts
.endproc

.proc spawn_weapon
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
WeaponPtr := R12 
        ; First we need to roll a weapon class
        ; TODO: this should almost certainly use a FIXED seed. Without this, the player
        ; can leave and re-enter the room to try the roll again, which is scummy
        jsr next_fixed_rand
        and #%00111111 ; low 2 bits = weapon strength, middle 4 bits = weapon type from table
        sta WeaponClassTemp
        ; TODO: chests should spawn any treasure, not just a weapon. But as weapons are complicated...
        ; let's do those first.
        ; weapon strength should be clamped based on the current floor (and later, zone?)
        and #%00000011 ; isolate the damage index
        cmp PlayerFloor
        bcc zone_index_valid
        lda #0 ; force a lvl 1 weapon; this affects spawn rate of higher tier weapons on each floor
zone_index_valid:
        tax
        lda WeaponClassTemp
        and #%00111100 ; isolate weapon type
        ora weapon_damage_lut, x  ;  apply the damage bits here
        sta WeaponClassTemp

spawn_weapon:
        ; Spawn a sprite to hold the weapon
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        ; We need to despawn this later, so store the index in the data byte for this tile
        ldy AttackSquare
        txa
        sta tile_data, y
        ; This is an active sprite, it does not move
        ; and the palette we choose here will be the same as the weapon class low 2 bits
        lda WeaponClassTemp
        and #%00000011
        ora #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF ; irrelevant
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        ; the X and Y position will be based on our current location, very similar to
        ; how we spawn death sprites
        ldy AttackSquare
        lda tile_index_to_col_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x

        lda tile_index_to_row_lut, y
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta sprite_table + MetaSpriteState::PositionY, x

        ; Finally the tile ID will be based on the weapon class we rolled, so
        ; let's work that out
        lda WeaponClassTemp
        lsr
        lsr
        tax
        lda cheaty_weapon_lut, x
        ; now use the weapon type to index into the weapons table
        asl
        tax
        lda weapon_class_table, x
        sta WeaponPtr
        lda weapon_class_table+1, x
        sta WeaponPtr+1
        ldy #WeaponClass::TileIndex
        lda (WeaponPtr), y
        ldx MetaSpriteIndex
        sta sprite_table + MetaSpriteState::TileIndex, x
        ; *whew.* Okay, now we just need to preserve the WeaponClass byte as tile flags. for later use
        ; when this thing is collected by the player
        lda WeaponClassTemp
        ldx AttackSquare
        sta tile_flags, x
        ; and finally, set this tile to a weapon shadow

        lda AttackSquare
        sta TargetIndex
        lda #TILE_WEAPON_SHADOW
        sta TileId
        jsr draw_active_tile
        ; ... we're done?
        rts

sprite_failed:
        ; Since we failed to spawn the sprite, we cannot spawn a weapon! Do nothing; we will wait until the next beat and try again
        rts
.endproc

.proc spawn_heart_container
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; If the player is already at max hearts...
        lda PlayerMaxHealth
        cmp #(MAX_HEARTS * 2)
        bne okay_to_spawn
        ; ... then we must not increase their health any further.
        ; Spawn a gold sack instead
        jsr spawn_gold_sack
        rts

okay_to_spawn:
        ; Super easy: replace the chest with a heart container tile
        lda AttackSquare
        sta TargetIndex
        lda #TILE_HEART_CONTAINER
        sta TileId
        jsr draw_active_tile
        ldx AttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x
        rts
.endproc

.proc spawn_gold_sack
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; Super easy: replace the chest with a gold sack tile
        lda AttackSquare
        sta TargetIndex
        lda #TILE_GOLD_SACK
        sta TileId
        jsr draw_active_tile
        ldx AttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x
        rts
.endproc

.proc spawn_big_key
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; Super easy: replace the chest with a big key tile
        lda AttackSquare
        sta TargetIndex
        lda #TILE_BIG_KEY
        sta TileId
        jsr draw_active_tile
        ldx AttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x
        rts
.endproc

.proc attack_exit_block
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
        lda PlayerKeys
        beq no_key
        
        ; Register the attack as a hit
        ; (don't otherwise interfere with combat if the player doesn't have the key)
        lda #1
        sta AttackLanded

        ; Replace the exit block with the stairs down
        lda AttackSquare
        sta TargetIndex
        lda #TILE_EXIT_STAIRS
        sta TileId
        jsr draw_active_tile
        ldx AttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

no_key:
        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc FAR_player_collides_with_tile
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        ; the top 6 bits index into the behavior table, which is a list of **words**
        ; so we want it to end up like this: %0bbbbbb0
        ldx TargetSquare
        lda battlefield, x
        lsr
        and #%01111110
        tax
        lda bonk_behaviors, x
        sta DestPtr
        lda bonk_behaviors+1, x
        sta DestPtr+1
        jsr __trampoline

        rts
.endproc

.proc find_puff_tile
PuffSquare := R12
TargetSquare := R13
        lda #$FF        ; A value of $FF indicates search failure
        sta PuffSquare
        ldx #0
loop:
        ; is this a poof?
        lda battlefield, x
        and #%11111100
        cmp #TILE_SMOKE_PUFF
        bne not_our_puff
        ; is this OUR poof?
        lda tile_data, x
        cmp TargetSquare
        bne not_our_puff
        ; we did it!
        stx PuffSquare
        rts
not_our_puff:
        inx
        cpx #::BATTLEFIELD_SIZE
        bne loop
done:
        rts
.endproc

.proc basic_enemy_attacks_player
TargetIndex := R0
TileId := R1
PuffSquare := R12
TargetSquare := R13
        ; All basic enemies do 1 damage to the player on hit
        jsr damage_player
        ; Now the tricky part: we need to scan the map and find this enemy's poof
        ; (It might not exist if we have a bugged board, so handle that safely)
        jsr find_puff_tile
        lda PuffSquare
        cmp #$FF
        beq no_puff_found
        ; Copy ourselves over the puff tile, to cancel our own movement
        lda PuffSquare
        sta TargetIndex
        ldx TargetSquare
        lda battlefield, x
        sta TileId
        jsr draw_active_tile

        ldx TargetSquare
        ldy PuffSquare
        lda tile_data, x
        sta tile_data, y
        lda tile_flags, x
        sta tile_flags, y

        ; Now, draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; TODO: we just damaged the player. Spawn a hit sprite inbetween the enemy that dealt
        ; the damage and the player's position

        rts
no_puff_found:
        ; If we couldn't find a puff, then try to cancel the player's movement instead.
        ; This *shouldn't* happen for basic enemies, but if we can't kick the enemy back,
        ; we should try to at least separate it from the player. (If this also fails the
        ; player will soft lock and die very quickly.)
        jsr forbid_player_movement
        rts
.endproc

.proc projectile_attacks_player
TargetIndex := R0
TileId := R1
TargetSquare := R13
        ; All projectiles do 1 damage to the player on hit
        jsr damage_player

        ; Now, despawn the projectile:
        ; draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        rts
.endproc

.proc solid_tile_forbids_movement
        jsr forbid_player_movement
        rts
.endproc

.proc forbid_player_movement
TargetRow := R14
TargetCol := R15
        lda PlayerCol
        sta TargetCol
        lda PlayerRow
        sta TargetRow
        rts
.endproc

.proc collect_heart_container
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda PlayerMaxHealth
        clc
        adc #2
        sta PlayerMaxHealth
        sta PlayerHealth

        st16 R0, sfx_heal
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x



        rts
.endproc

.proc collect_key
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda #1 ; there is only one key per dungeon floor
        sta PlayerKeys

        ; TODO: a nice SFX
        st16 R0, sfx_key_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_key_pulse2
        jsr play_sfx_pulse2

        ; Now, draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        rts
.endproc

.proc collect_gold_sack
TargetIndex := R0
TileId := R1
TargetSquare := R13
        add16w PlayerGold, #100

        ; TODO: a nice SFX
        st16 R0, sfx_coin
        jsr play_sfx_pulse1

        ; Now, draw a basic floor tile here, which will be underneath the player
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        rts
.endproc



.proc collect_weapon
TargetIndex := R0
TileId := R1
TargetSquare := R13
        ; We stuffed the WeaponClassTemp variable in tile_flags, so use that to determine
        ; the weapon properties
        ldx TargetSquare
        lda tile_flags, x
        and #%00000011
        sta PlayerWeaponDmg
        lda tile_flags, x
        and #%00111100
        lsr
        lsr
        tax
        lda cheaty_weapon_lut, x
        sta PlayerWeapon
        ; we also need to update the weapon ptr here
        asl
        tax
        lda weapon_class_table, x
        sta PlayerWeaponPtr
        lda weapon_class_table+1, x
        sta PlayerWeaponPtr+1

        ; TODO: play a weapon gain SFX

        ; Despawn the weapon sprite
        ldx TargetSquare
        lda tile_data, x
        tax
        lda #0
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        ; Finally, draw a basic floor tile here
        lda TargetSquare
        sta TargetIndex
        lda #TILE_REGULAR_FLOOR
        sta TileId
        jsr draw_active_tile
        ldx TargetSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; We have *collected a treasure*! Mark this as such in the current room data
        ldx PlayerRoomIndex
        lda room_flags, x
        ora #ROOM_FLAG_TREASURE_COLLECTED
        sta room_flags, x

        ; Play a joyous SFX
        st16 R0, sfx_equip_ability_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_equip_ability_pulse2
        jsr play_sfx_pulse2

        rts
.endproc

.proc descend_stairs
        st16 FadeToGameMode, advance_to_next_floor
        st16 GameMode, fade_to_game_mode        
        
        st16 R0, sfx_teleport
        jsr play_sfx_pulse1

        rts
.endproc