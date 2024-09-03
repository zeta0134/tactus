; ============================================================================================================================
; ===                                           Utility Functions                                                          ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

.proc _setup_cardinal_targets_common
CurrentRow := R14
CurrentTile := R15
        ; setup the properties for all 4 directions, should they be chosen
        ; North
        lda CurrentTile
        sec
        sbc #::BATTLEFIELD_WIDTH
        sta candidate_tiles+0
        ; South
        clc
        adc #(::BATTLEFIELD_WIDTH * 2)
        sta candidate_tiles+1
        ; East
        sec
        sbc #(::BATTLEFIELD_WIDTH - 1)
        sta candidate_tiles+2
        ; West
        sec
        sbc #2
        sta candidate_tiles+3

        lda CurrentRow
        sta candidate_rows+2 ; East
        sta candidate_rows+3 ; West
        clc
        adc #1
        sta candidate_rows+1 ; South
        sec
        sbc #2
        sta candidate_rows+0 ; North

        lda #DUST_DIRECTION_S
        sta candidate_directions+0 ; North
        lda #DUST_DIRECTION_N
        sta candidate_directions+1 ; South
        lda #DUST_DIRECTION_W
        sta candidate_directions+2 ; East
        lda #DUST_DIRECTION_E
        sta candidate_directions+3 ; West
        rts
.endproc

; Result in R0, Returns $FF on failure
.proc ENEMY_UPDATE_pick_random_cardinal
ChosenDestination := R0
NumCandidates := R1
; Clobbered: R2-R3

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_cardinal_targets_common

        ; setup completely random weights for the directions,
        ; so we pick a given valid tile completely arbitrarily
        ; (the 2 upper bits are sufficient for a larger/smaller
        ; check, the lower 6 bits can be ignored. don't waste cycles
        ; zeroing them out)
        jsr next_gameplay_rand
        lsr
        ror candidate_weights+0
        lsr
        ror candidate_weights+0
        lsr
        ror candidate_weights+1
        lsr
        ror candidate_weights+1
        lsr
        ror candidate_weights+2
        lsr
        ror candidate_weights+2
        lsr
        ror candidate_weights+3
        lsr
        ror candidate_weights+3

        ; actually pick the direction
        lda #4
        sta NumCandidates
        near_call ENEMY_UPDATE_choose_destination
        rts
.endproc

; Result in R0, Returns $FF on failure
.proc ENEMY_UPDATE_target_player_cardinal
TargetTile := R0
TargetRow := R1
PlayerDistance := R2
RandomScratch0 := R3
RandomScratch1 := R4

NumCandidates := R1

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_cardinal_targets_common

        ; We'll use some random bytes to unbias the target directions
        jsr next_gameplay_rand
        sta RandomScratch0
        jsr next_gameplay_rand
        sta RandomScratch1

        ; For the weights, work out the manhattan distance for each potential
        ; target tile. We'll try to prefer the shortest distance to close
        ; the gap

        .repeat 4, i
        lda candidate_tiles+i
        sta TargetTile
        lda candidate_rows+i
        sta TargetRow
        near_call ENEMY_UPDATE_target_manhattan_distance_to_player
        lda PlayerDistance
         ; PlayerDistance = (PlayerDistance * 8) + 0-7
        rol RandomScratch0
        rol
        rol RandomScratch0
        rol
        rol RandomScratch1
        rol
        sta candidate_weights+i
        .endrepeat

        ; actually pick the direction
        lda #4
        sta NumCandidates
        near_call ENEMY_UPDATE_choose_destination
        rts
.endproc

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

.proc ENEMY_UPDATE_update_zombie_base
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; Determine how many beats we should remain idle, based on difficulty
        lda battlefield, x
        and #%00000011
        cmp #%10
        beq intermediate
        cmp #%11
        beq advanced
basic:
        lda #3
        sta IdleDelay
        jmp done
intermediate:
        lda #2
        sta IdleDelay
        jmp done
advanced:
        lda #1
        sta IdleDelay
done:
        perform_zpcm_inc

        inc tile_data, x
        lda tile_data, x
        cmp IdleDelay ; TODO: pick a threshold based on zombie difficulty
        bcc no_change
        ; switch to our anticipation pose
        draw_at_x_keeppal TILE_ZOMBIE_ANTICIPATE, BG_TILE_ZOMBIE_ANTICIPATE

no_change:
        perform_zpcm_inc
        rts
.endproc

.proc ENEMY_UPDATE_update_zombie_anticipate
DestinationTile := R0

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        near_call ENEMY_UPDATE_player_manhattan_distance
track_player:        
        ; If we're outside the tracking radius, choose our next position randomly
        ; (here, A already has the distance from before)
        cmp #ZOMBIE_TARGET_RADIUS
        bcs randomly_choose_direction
        ; Otherwise target the player
        near_call ENEMY_UPDATE_target_player_cardinal
        jmp location_chosen
randomly_choose_direction:
        near_call ENEMY_UPDATE_pick_random_cardinal
location_chosen:
        lda DestinationTile
        cmp #$FF
        bne proceed_with_jump
jump_failed:
        ; TODO: unbreak this! ALL enemies will need this functionality,
        ; so build it into the candidate logic.

        ;if_semisafe_destination make_target_dangerous
        jmp return_to_idle_without_moving

make_target_dangerous:
        ; write our own position into the target tile, as this will help
        ; the damage sprite to spawn in the right location if the player
        ; takes the hit
        ldx DestinationTile
        lda CurrentTile
        sta tile_data, x
        ; additionally, for update order reasons, mark the target as "already moved",
        ; this prevents it from clearing our damage state before the next beat
        lda tile_flags, x
        ora #%10000000
        sta tile_flags, x
        ;jmp return_to_idle_without_moving ; (fall through)
return_to_idle_without_moving:
        ; Turn ourselves back into an idle pose
        ldx CurrentTile
        draw_at_x_keeppal TILE_ZOMBIE_BASE, BG_TILE_ZOMBIE_IDLE
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        rts

proceed_with_jump:        
        ldx CurrentTile
        ldy DestinationTile
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_ZOMBIE_BASE, BG_TILE_ZOMBIE_IDLE
        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda DestinationTile
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; And finally clear the data flags for the puff of smoke, just to keep things tidy
        lda #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; Finally, draw the puff of smoke at our current location
        ; (this clobbers X and Y, so we prefer to do it last)
        lda CurrentTile
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_draw_smoke_puff

        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_zombie
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
        set_loot_table basic_loot_table
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #6
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_zombie
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
        set_loot_table basic_loot_table
        lda #2
        sta EnemyHealth
        jmp done
intermediate_hp:
        set_loot_table intermediate_loot_table
        lda #4
        sta EnemyHealth
        jmp done
advanced_hp:
        set_loot_table advanced_loot_table
        lda #6
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_indirect_attack_with_hp
        rts
.endproc
