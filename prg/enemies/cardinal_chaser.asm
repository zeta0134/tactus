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
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_cardinal_targets_common

        ; setup completely random weights for the directions,
        ; so we pick a given valid tile completely arbitrarily
        ; (the 2 upper bits are sufficient for a larger/smaller
        ; check, the lower 6 bits can be ignored. don't waste cycles
        ; zeroing them out)
        prng_from_table_y
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

; these are provided for us
CurrentRow := R14
CurrentTile := R15
        jsr _setup_cardinal_targets_common

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
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_AIR
        beq air
        cmp #PAL_FIRE
        beq fire
        cmp #PAL_ICE
        beq ice
earth:
        lda #ZOMBIE_EARTH_IDLE_DELAY
        sta IdleDelay
        jmp done
fire:
        lda #ZOMBIE_FIRE_IDLE_DELAY
        sta IdleDelay
        jmp done
air:
        lda #ZOMBIE_AIR_IDLE_DELAY
        sta IdleDelay
        jmp done
ice:
        lda #ZOMBIE_ICE_IDLE_DELAY
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
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldy CurrentTile
        lda (PlayerDistanceLut), y
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
        draw_at_x_keeppal TILE_ZOMBIE, BG_TILE_ZOMBIE_IDLE
        ; Zero out our delay counter, so we start fresh
        lda #0
        sta tile_data, x

        rts

proceed_with_jump:        
        ldx CurrentTile
        ldy ValidDestination
        ; Draw ourselves at the target (keep our color palette)
        draw_at_y_with_pal_x TILE_ZOMBIE, BG_TILE_ZOMBIE_IDLE
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
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_FIRE
        beq fire_hp
        cmp #PAL_AIR
        beq air_hp
earth_hp:
        set_loot_table ZOMBIE_EARTH_LOOT
        lda #ZOMBIE_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table ZOMBIE_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table ZOMBIE_FIRE_LOOT
        lda #ZOMBIE_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table ZOMBIE_AIR_LOOT
        lda #ZOMBIE_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_zombie
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
        set_loot_table ZOMBIE_EARTH_LOOT
        lda #ZOMBIE_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table ZOMBIE_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table ZOMBIE_FIRE_LOOT
        lda #ZOMBIE_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table ZOMBIE_AIR_LOOT
        lda #ZOMBIE_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_indirect_attack_with_hp
        rts
.endproc

        .segment "ENEMY_BOMB_SPELL"

zombie_spell_lut:
        .word ENEMY_BOMB_SPELL_zombie_elemental_attack ; SPELL_FIRE
        .word ENEMY_BOMB_SPELL_zombie_elemental_attack ; SPELL_AIR
        .word ENEMY_BOMB_SPELL_zombie_elemental_attack ; SPELL_ICE
        .word ENEMY_BOMB_SPELL_zombie_elemental_attack ; SPELL_EARTH
        .word FIXED_no_behavior                ; SPELL_BOMB
        .word FIXED_no_behavior                ; SPELL_LIFE

.proc ENEMY_BOMB_SPELL_zombie_spell_dispatch
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
        lda zombie_spell_lut+0, x
        sta DispatchPtr+0
        lda zombie_spell_lut+1, x
        sta DispatchPtr+1
        jmp (DispatchPtr)
        ; does not return
.endproc

.proc ENEMY_BOMB_SPELL_zombie_elemental_attack
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
        set_loot_table ZOMBIE_EARTH_LOOT
        lda #ZOMBIE_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table ZOMBIE_ICE_LOOT
        lda #SPIDER_ICE_HP
        sta EnemyHealth
        jmp done
fire_hp:
        set_loot_table ZOMBIE_FIRE_LOOT
        lda #ZOMBIE_FIRE_HP
        sta EnemyHealth        
        jmp done
air_hp:
        set_loot_table ZOMBIE_AIR_LOOT
        lda #ZOMBIE_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_BOMB_SPELL_regular_enemy_elemental_spell_common
        rts
.endproc
