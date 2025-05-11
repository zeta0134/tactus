; Internal data storage for this enemy type, spread across data and flags
; x0000ss0 e0rrhhhh
; - hhhh - accumulated hit points (damage, 0=healthy)
; - rr   - current reel position
; - e    - most recent movement was east
; - ss   - current state

ONE_ARMED_BANDIT_FLAGS_STATE     = %00000110
ONE_ARMED_BANDIT_DATA_MOVED_EAST = %10000000
ONE_ARMED_BANDIT_DATA_REEL_POS   = %00110000
ONE_ARMED_BANDIT_DATA_HP         = %00001111

ONE_ARMED_BANDIT_STATE_IDLE       = %000 ; normal state: reel spins every beat
ONE_ARMED_BANDIT_STATE_ANTICIPATE = %010 ; state just before an attack
ONE_ARMED_BANDIT_STATE_ATTACK     = %100 ; state just after an attack (looks like idle)
ONE_ARMED_BANDIT_STATE_FROZEN     = %110 ; after being hit once, we freeze on the current reel

; note: X should already contain our tile index, as the mechanism
; for loading this differs depending on which AI function is running
.macro oab_compute_reel_index scratch_byte
        lda tile_attributes, x
        and #PAL_MASK                       ; pp000000
        lsr                                 ; 0pp00000
        lsr                                 ; 00pp0000
        lsr                                 ; 000pp000
        sta scratch_byte
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS ; 00rr0000
        lsr                                 ; 000rr000
        lsr                                 ; 0000rr00
        lsr                                 ; 00000rr0
        ora scratch_byte                    ; 000pprr0
.endmacro

.macro oab_advance_reel scratch_byte
        lda tile_data, x
        clc
        adc #%00010000
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        sta scratch_byte
        lda tile_data, x
        and #($FF - ONE_ARMED_BANDIT_DATA_REEL_POS)
        ora scratch_byte
        sta tile_data, x
.endmacro

.macro oab_set_state target_state
        lda tile_flags, x
        and #($FF - ONE_ARMED_BANDIT_FLAGS_STATE)
        ora target_state
        sta tile_flags, x
.endmacro


; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

; hrm... to index into these sanely...
; ... should be 000pprr0, using the earth label as a base.
; ... yeah, we can compose that at runtime. Cool!

slot_reel_idle_earth:
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_7
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_CHERRY
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_GEM
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_LEAF
slot_reel_idle_ice:
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_7
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_CHERRY
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_GEM
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_SNOWFLAKE
slot_reel_idle_air:
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_7
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_CHERRY
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_GEM
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_LIGHTNING
slot_reel_idle_fire:
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_7
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_CHERRY
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_GEM
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_IDLE_FLAME

slot_reel_anticipate_earth:
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_7
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_CHERRY
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_GEM
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_LEAF
slot_reel_anticipate_ice:
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_7
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_CHERRY
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_GEM
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_SNOWFLAKE
slot_reel_anticipate_air:
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_7
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_CHERRY
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_GEM
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_LIGHTNING
slot_reel_anticipate_fire:
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_7
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_CHERRY
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_GEM
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_ANTICIPATE_FLAME

one_armed_bandit_update_dispatch_lut:
        .addr ENEMY_UPDATE_update_one_armed_bandit_idle
        .addr ENEMY_UPDATE_update_one_armed_bandit_anticipate
        .addr ENEMY_UPDATE_update_one_armed_bandit_attack
        .addr ENEMY_UPDATE_update_one_armed_bandit_frozen

.proc ENEMY_UPDATE_update_one_armed_bandit
DestFunc := R0

CurrentRow := R14
CurrentTile := R15
        inc enemies_active

        ldx CurrentTile
        bail_if_already_moved

        ; dispatch to our actual state handler
        ldx CurrentTile
        lda tile_flags, x
        and #ONE_ARMED_BANDIT_FLAGS_STATE
        tay
        lda one_armed_bandit_update_dispatch_lut+0, y
        sta DestFunc+0
        lda one_armed_bandit_update_dispatch_lut+1, y
        sta DestFunc+1
        jmp (DestFunc)
        ; tail call
.endproc

; Bandits have a pretty simple 3-beat pattern: IDLE, ANTICIPATE, ATTACK
; All 4 elemental varieties will share this pattern, making them sortof
; as difficult as an intermediate zombie, with some twists. But they're
; not ever especially threatening, as they take just one hit to "freeze"
; and then stop moving indefinitely.
.proc ENEMY_UPDATE_update_one_armed_bandit_idle
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        ; Always advance the current reel
        oab_advance_reel ScratchByte
        ; Always set our state to anticipate
        oab_set_state #ONE_ARMED_BANDIT_STATE_ANTICIPATE
        ; Always draw based on the reel and palette
        oab_compute_reel_index ScratchByte
        tay
        lda slot_reel_anticipate_earth+0, y
        sta tile_patterns, x
        lda slot_reel_anticipate_earth+1, y
        sta tile_attributes, x
        ; For the idle state that's it!
        rts
.endproc

.proc ENEMY_UPDATE_update_one_armed_bandit_anticipate
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ; Works basically identically to a cardinal chaser, except
        ; we need to do reel maintenance while we're at it

        ldx CurrentTile
        ; Always advance the current reel
        oab_advance_reel ScratchByte
        ; Always set our state to attack
        oab_set_state #ONE_ARMED_BANDIT_STATE_ATTACK
        ; Always draw based on the reel and palette
        oab_compute_reel_index ScratchByte
        tay
        lda slot_reel_idle_earth+0, y
        sta tile_patterns, x
        lda slot_reel_idle_earth+1, y
        sta tile_attributes, x

        ldy CurrentTile
        lda (PlayerDistanceLut), y
track_player:        
        ; If we're outside the tracking radius, choose our next position randomly
        ; (here, A already has the distance from before)
        cmp #ONE_ARMED_BANDIT_TARGET_RADIUS
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
        ; Bandits aren't dangerous when moving to the east, so check for that here
        lda CurrentTile          ; if our current location
        clc                      ; ... plus 1 (to the east)
        adc #1                   
        cmp SemisafeDestination  ; ... matches our target square, then...
        bne proceed_to_make_semisafe
        ldx CurrentTile
        lda tile_data, x
        ora #ONE_ARMED_BANDIT_DATA_MOVED_EAST
        sta tile_data, x
        jmp return_to_idle_without_moving
proceed_to_make_semisafe:
        ldx CurrentTile
        lda tile_data, x
        and #($FF - ONE_ARMED_BANDIT_DATA_MOVED_EAST)
        sta tile_data, x
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
        ; We've already done this setup (return to idle is unconditional) so just
        ; exit here. We're done!
        rts

proceed_with_jump:
        ; Bandits aren't dangerous when moving to the east, so check for that here.
        lda CurrentTile          ; if our current location
        clc                      ; ... plus 1 (to the east)
        adc #1                   
        cmp ValidDestination  ; ... matches our target square, then...
        bne mark_jump_as_dangerous
mark_jump_as_safe:
        ldx CurrentTile
        lda tile_data, x
        ora #ONE_ARMED_BANDIT_DATA_MOVED_EAST
        sta tile_data, x
        jmp done_marking_jump
mark_jump_as_dangerous:
        ldx CurrentTile
        lda tile_data, x
        and #($FF - ONE_ARMED_BANDIT_DATA_MOVED_EAST)
        sta tile_data, x
done_marking_jump:

        ldx CurrentTile
        ldy ValidDestination
        ; Draw ourselves at the target (keep our color palette)
        ; (we've already chosen the sprite from earlier code, so just
        ; copy that result on over, very simple)
        lda #TILE_ONE_ARMED_BANDIT
        sta battlefield, y
        lda tile_attributes, x
        sta tile_attributes, y
        lda tile_patterns, x
        sta tile_patterns, y
        lda tile_data, x
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

.proc ENEMY_UPDATE_update_one_armed_bandit_attack
ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        ; Always advance the current reel
        oab_advance_reel ScratchByte
        ; Always set our state to idle
        oab_set_state #ONE_ARMED_BANDIT_STATE_IDLE
        ; Always draw based on the reel and state
        oab_compute_reel_index ScratchByte
        tay
        lda slot_reel_idle_earth+0, y
        sta tile_patterns, x
        lda slot_reel_idle_earth+1, y
        sta tile_attributes, x
        ; For the idle state that's it!
        rts
.endproc

.proc ENEMY_UPDATE_update_one_armed_bandit_frozen
        ; TODO: are all of my buddies also frozen? If so, become defeated!
        ; If all of my buddies are on a matching symbol, drop that particular
        ; loot (rolling from tables as needed, etc etc), otherwise drop a large
        ; quantity of standard loot.
        rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

slot_reel_frozen_earth:
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_7
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_CHERRY
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_GEM
        .word (PAL_EARTH << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_LEAF
slot_reel_frozen_ice:
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_7
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_CHERRY
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_GEM
        .word (PAL_ICE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_SNOWFLAKE
slot_reel_frozen_air:
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_7
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_CHERRY
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_GEM
        .word (PAL_AIR << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_LIGHTNING
slot_reel_frozen_fire:
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_7
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_CHERRY
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_GEM
        .word (PAL_FIRE << 8) | BG_TILE_ONE_ARMED_BANDIT_FROZEN_FLAME

.proc ENEMY_ATTACK_direct_attack_one_armed_bandit
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
        near_call ENEMY_ATTACK_attack_one_armed_bandit_common
ignore_attack:
        rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_one_armed_bandit
        near_call ENEMY_ATTACK_attack_one_armed_bandit_common
        rts
.endproc

.proc ENEMY_ATTACK_attack_one_armed_bandit_common
; Scratch for calculations
ScratchHp := R0
ScratchReelIndex := R0

; For drawing tiles
TargetIndex := R0
TileId := R1

OriginalAttackSquare := R3

AttackLanded := R7
EffectiveAttackSquare := R10 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; Bandits always take 1 "hit" per attack, regardless of the player's
        ; equipment, elemental alignments, etc. They're "sturdy", have no
        ; weaknesses, and this isn't the intended way to defeat them.

        ldx EffectiveAttackSquare
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_HP
        clc
        adc #1
        and #ONE_ARMED_BANDIT_DATA_HP
        ; if we should die, do that
        cmp #ONE_ARMED_BANDIT_HP
        bcs die_now
        ; otherwise, write the health back
        sta ScratchHp
        lda tile_data, x
        and #($FF - ONE_ARMED_BANDIT_DATA_HP)
        ora ScratchHp
        sta tile_data, x

        ; now switch to our frozen state if we weren't there already
        lda tile_flags, x
        and #($FF - ONE_ARMED_BANDIT_FLAGS_STATE)
        ora #ONE_ARMED_BANDIT_STATE_FROZEN
        sta tile_flags, x

        ; now we need to draw ourselves as frozen on the current reel, matching
        ; our color element and all that jazz
        oab_compute_reel_index ScratchReelIndex
        tay
        lda slot_reel_frozen_earth+0, y
        sta tile_patterns, x
        lda slot_reel_frozen_earth+1, y
        sta tile_attributes, x
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile

        ; we took damage, so do that whole flashy business
        lda EffectiveAttackSquare
        jsr queue_palette_cycle

        ; And... done?
        rts

die_now:
        ; TODO: see if we can tail-call into the common shared routine here?

        ldx EffectiveAttackSquare
        stx DiscoTile
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda EffectiveAttackSquare
        sta TargetIndex
        jsr draw_active_tile

        ldx EffectiveAttackSquare
        lda #0
        sta tile_data, x
        sta tile_flags, x

        ; Juice: spawn a floaty, flashy death skull above our tile
        ; #RIP
        near_call ENEMY_ATTACK_spawn_death_sprite_here

        ; An enemy died! Increment the player's ongoing combo
        inc PlayerCombo

        ; spawn LOOT upon defeat
        set_loot_table ONE_ARMED_BANDIT_LOOT_TABLE
        roll_loot_at OriginalAttackSquare

        ; Play an appropriately crunchy death sound
        queue_sfx_pulse1 sfx_defeat_enemy_pulse
        queue_sfx_noise sfx_defeat_enemy_noise

        lda #1
        sta EnemyDiedThisFrame

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        ; Increase the player's warp stability any time they kill a common foe (via any means)
        increase_warp_stability

        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_one_armed_bandit_attacks_player
        ; TODO: fancy custom logic to ignore damage based on our last attack direction
        ; (if applicable) or the player's movement direction into us (if applicable)

        ; For now, fall through to regular damage stuff

deal_standard_4hp_damage:
        ; tail call into the damaging function
        jmp ENEMY_COLLIDE_basic_enemy_attacks_player

deal_no_damage:
        ; tail call into a non-threatening function (we still need all the other
        ; "move back to the puff tile" logic from a standard foe)
        jmp ENEMY_COLLIDE_basic_enemy_attacks_player::post_damage
.endproc

; ============================================================================================================================
; ===                                    Explosion Attacks Enemy Behaviors                                                 ===
; ============================================================================================================================
        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_one_armed_bandit_direct_explode
AttackSquare := R3
EffectiveAttackSquare := R10
        ; TODO: we are about to die to an explosion! Clean up any global state
        ; that other bandits may rely on.

        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_one_armed_bandit_indirect_explode
        ; TODO: we are about to die to an explosion! Clean up any global state
        ; that other bandits may rely on.

        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_one_armed_bandit_spell_dispatch
        ; TODO: change our color **and** redraw our reel symbol
        rts
.endproc