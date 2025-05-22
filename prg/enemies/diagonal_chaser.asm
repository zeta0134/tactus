; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE0"

.proc _setup_diagonal_targets_common
CurrentRow := R14
CurrentTile := R15
        ; setup the properties for all 4 directions, should they be chosen

        ; North-West
        lda CurrentTile
        sec
        sbc #(::BATTLEFIELD_WIDTH+1)
        sta candidate_tiles+0
        ; North-East
        clc
        adc #2
        sta candidate_tiles+1
        ; South-West
        clc
        adc #((::BATTLEFIELD_WIDTH * 2) - 2)
        sta candidate_tiles+2
        ; South-East
        clc
        adc #2
        sta candidate_tiles+3

        lda CurrentRow
        sec
        sbc #1
        sta candidate_rows+0 ; North-West
        sta candidate_rows+1 ; North-East
        clc
        adc #2
        sta candidate_rows+2 ; South-West
        sta candidate_rows+3 ; South-East

        lda #DUST_DIRECTION_SE
        sta candidate_directions+0 ; North-West
        lda #DUST_DIRECTION_SW
        sta candidate_directions+1 ; North-East
        lda #DUST_DIRECTION_NE
        sta candidate_directions+2 ; South-West
        lda #DUST_DIRECTION_NW
        sta candidate_directions+3 ; South-East
        rts
.endproc

; Result in R0, Returns $FF on failure
; TODO: other than the subroutine at the top, this is identical to cardinal. combine
; to save space?
.proc ENEMY_UPDATE_pick_random_diagonal
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_diagonal_targets_common

        prng_from_table_y
        sta candidate_weights+0
        prng_from_table_y
        sta candidate_weights+1
        prng_from_table_y
        sta candidate_weights+2
        prng_from_table_y
        sta candidate_weights+3

        ; actually pick the direction
        lda #4
        sta NumCandidates
        near_call ENEMY_UPDATE_choose_destination
        rts
.endproc

; Result in R0, Returns $FF on failure
; TODO: other than the subroutine at the top, this is identical to cardinal. combine
; to save space?
.proc ENEMY_UPDATE_target_player_diagonal
TargetTile := R0
TargetRow := R1
PlayerDistance := R2
RandomScratch0 := R3
RandomScratch1 := R4

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_diagonal_targets_common

        ; For the weights, work out the distance to the player for each potential
        ; target tile. We'll try to prefer the shortest distance to close
        ; the gap

        .repeat 4, i
        prng_from_table_y
        and #%11 ; the lower 2 bits will be randomly inverted to help with tiebreaking
        sta PlayerDistance
        ldy candidate_tiles+i
        lda (PlayerDistanceLut), y
        eor PlayerDistance
        sta candidate_weights+i
        .endrepeat

        ; actually pick the direction
        lda #4
        sta NumCandidates
        near_call ENEMY_UPDATE_choose_destination
        rts
.endproc

; Spiders store their beat counter in tile_data, and damage in the low 7 bits of tile_flags
.proc ENEMY_UPDATE_update_spider_base
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; Determine how many beats we should remain idle, based on difficulty
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq earth
        cmp #PAL_AIR
        beq air
        cmp #PAL_FIRE
        beq fire
ice:
        lda #SPIDER_ICE_IDLE_DELAY
        sta IdleDelay
        jmp done
air:
        lda #SPIDER_AIR_IDLE_DELAY
        sta IdleDelay
        jmp done
earth:
        lda #SPIDER_EARTH_IDLE_DELAY
        sta IdleDelay
        jmp done
fire:
        lda #SPIDER_FIRE_IDLE_DELAY
        sta IdleDelay
done:

        inc tile_data, x
        lda tile_data, x
        cmp IdleDelay ; TODO: pick a threshold based on spider difficulty
        bcc no_change
        ; switch to our anticipation pose
        draw_at_x_keeppal TILE_SPIDER_ANTICIPATE, BG_TILE_SPIDER_ANTICIPATE

no_change:
        rts
.endproc

; This really needs to be... just... ENTIRELY redone. Most notably, spiders
; are REAL bad about getting stuck in a corner with a 25% chance to escape. They
; do a bit better when tracking the player, but still make stupid decisions. We
; want them to try to always move if they're not completely blocked, and we want
; the whole "randomly pick a direction" logic to be much less stupid.
.proc ENEMY_UPDATE_update_spider_anticipate
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldy CurrentTile
        lda (PlayerDistanceLut), y
track_player:
        ; First the row
        ; If we're outside the tracking radius, choose it randomly
        ; (here, A already has the distance from before)
        cmp #SPIDER_TARGET_RADIUS
        bcs randomly_choose_direction
        ; Otherwise target the player
        near_call ENEMY_UPDATE_target_player_diagonal
        jmp location_chosen
randomly_choose_direction:
        near_call ENEMY_UPDATE_pick_random_diagonal
location_chosen:
        lda ValidDestination
        cmp #$FF
        bne proceed_with_jump
jump_failed:
        lda SemisafeDestination
        cmp #$FF
        bne make_target_dangerous
        jmp return_to_idle_without_moving
make_target_dangerous:
        ; write our own position into the target tile, as this will help
        ; the damage sprite to spawn in the right location if the player
        ; takes the hit
        ldx SemisafeDestination
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
        draw_at_x_keeppal TILE_SPIDER, BG_TILE_SPIDER
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        rts

proceed_with_jump:
        ldx CurrentTile
        ldy ValidDestination
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_SPIDER, BG_TILE_SPIDER

        ; Fix our counter at the destination tile so we start fresh
        lda #0
        sta tile_data, y

        ; Write our new position to the data byte for the puff of smoke
        lda ValidDestination
        sta tile_data, x

        ; Move our data flags to the destination, and flag ourselves as having just moved
        lda #FLAG_MOVED_THIS_FRAME
        ora tile_flags, x
        sta tile_flags, y
        ; Finally clear the data flags for the puff of smoke, just to keep things tidy
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
.proc ENEMY_ATTACK_direct_attack_spider
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_FIRE
        beq fire_hp
        cmp #PAL_AIR
        beq air_hp
earth_hp:
        set_loot_table SPIDER_EARTH_LOOT
        lda #SPIDER_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table SPIDER_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table SPIDER_FIRE_LOOT
        lda #SPIDER_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table SPIDER_AIR_LOOT
        lda #SPIDER_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_spider
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_FIRE
        beq fire_hp
        cmp #PAL_AIR
        beq air_hp
earth_hp:
        set_loot_table SPIDER_EARTH_LOOT
        lda #SPIDER_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table SPIDER_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table SPIDER_FIRE_LOOT
        lda #SPIDER_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table SPIDER_AIR_LOOT
        lda #SPIDER_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_indirect_attack_with_hp
        rts
.endproc

        .segment "ENEMY_BOMB_SPELL"

spider_spell_lut:
        .word ENEMY_BOMB_SPELL_spider_elemental_attack ; SPELL_FIRE
        .word ENEMY_BOMB_SPELL_spider_elemental_attack ; SPELL_AIR
        .word ENEMY_BOMB_SPELL_spider_elemental_attack ; SPELL_ICE
        .word ENEMY_BOMB_SPELL_spider_elemental_attack ; SPELL_EARTH
        .word FIXED_no_behavior                ; SPELL_BOMB
        .word FIXED_no_behavior                ; SPELL_LIFE

.proc ENEMY_BOMB_SPELL_spider_spell_dispatch
DispatchPtr := R0
;Length := R13
CurrentRow := R14
CurrentTile := R15
        lda CurrentlyActiveSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        ; Safety: don't call a spell effect that doesn't exist
        ; (This shouldn't happen, but crashing is no fun)
        cmp #LAST_SPELL_IN_ITEM_LIST
        bcc safe_to_dispatch
        rts
safe_to_dispatch:
        asl
        tax
        lda spider_spell_lut+0, x
        sta DispatchPtr+0
        lda spider_spell_lut+1, x
        sta DispatchPtr+1
        jmp (DispatchPtr)
        ; does not return
.endproc

.proc ENEMY_BOMB_SPELL_spider_elemental_attack
EnemyHealth := R12

CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_FIRE
        beq fire_hp
        cmp #PAL_AIR
        beq air_hp
earth_hp:
        set_loot_table SPIDER_EARTH_LOOT
        lda #SPIDER_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table SPIDER_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table SPIDER_FIRE_LOOT
        lda #SPIDER_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table SPIDER_AIR_LOOT
        lda #SPIDER_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_BOMB_SPELL_regular_enemy_elemental_spell_common
        rts
.endproc
