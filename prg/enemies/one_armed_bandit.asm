; Internal data storage for this enemy type, spread across data and flags
; x0000ss0 e0rrhhhh
; - hhhh - accumulated hit points (damage, 0=healthy)
; - rr   - current reel position
; - e    - most recent movement was east
; - ss   - current state

; TODO: this file has a lot of tedious copy/paste, and ROM space is kindof
; at a premium for enemy logic. Consider subroutines!

ONE_ARMED_BANDIT_FLAGS_STATE     = %00001110
ONE_ARMED_BANDIT_DATA_MOVED_EAST = %10000000
ONE_ARMED_BANDIT_DATA_REEL_POS   = %00110000
ONE_ARMED_BANDIT_DATA_HP         = %00001111

ONE_ARMED_BANDIT_STATE_IDLE        = %0000 ; normal state: reel spins every beat
ONE_ARMED_BANDIT_STATE_ANTICIPATE  = %0010 ; state just before an attack
ONE_ARMED_BANDIT_STATE_ATTACK      = %0100 ; state just after an attack (looks like idle)
ONE_ARMED_BANDIT_STATE_FROZEN      = %0110 ; after being hit once, we freeze on the current reel
ONE_ARMED_BANDIT_STATE_LOOT_COINS  = %1000 ; already dead, to defer loot generation and die properly
ONE_ARMED_BANDIT_STATE_LOOT_GEMS   = %1010 ; 
ONE_ARMED_BANDIT_STATE_LOOT_DUMMY1 = %1100 ; placeholder, shouldn't be used
ONE_ARMED_BANDIT_STATE_LOOT_DUMMY2 = %1110 ; ditto

REEL_POS_SEVEN  = %00000000
REEL_POS_CHERRY = %00010000
REEL_POS_GEM    = %00100000
REEL_POS_MAGIC  = %00110000

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

.macro oab_compute_coordination_index_y
        lda tile_attributes, x ; . pp......
        rol                    ; p p.......
        rol                    ; p .......p
        rol                    ; . ......pp
        and #%00000011         ; . 000000pp
        tay
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
        .addr ENEMY_UPDATE_update_one_armed_bandit_terminal_award_coins
        .addr ENEMY_UPDATE_update_one_armed_bandit_terminal_award_diamonds
        .addr ENEMY_UPDATE_update_one_armed_bandit_terminal_award_coins ; shouldn't be used?
        .addr ENEMY_UPDATE_update_one_armed_bandit_terminal_award_coins ; ditto?

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
        ; Increase the count of active bandits
        oab_compute_coordination_index_y
        lda RoomStateBanditsActiveCurrent, y
        clc
        adc #1
        sta RoomStateBanditsActiveCurrent, y
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

        ; Increase the count of active bandits
        oab_compute_coordination_index_y
        lda RoomStateBanditsActiveCurrent, y
        clc
        adc #1
        sta RoomStateBanditsActiveCurrent, y

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
        ; Increase the count of active bandits
        oab_compute_coordination_index_y
        lda RoomStateBanditsActiveCurrent, y
        clc
        adc #1
        sta RoomStateBanditsActiveCurrent, y
        ; For the idle state that's it!
        rts
.endproc

spellcast_item_id_by_coordination_index_lut:
        .byte ITEM_SPELL_EARTH
        .byte ITEM_SPELL_ICE
        .byte ITEM_SPELL_AIR
        .byte ITEM_SPELL_FIRE

.proc ENEMY_UPDATE_update_one_armed_bandit_frozen
; for draw_active_tile
TargetIndex := R0

ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        ; Increase the count of frozen bandits
        oab_compute_coordination_index_y
        lda RoomStateBanditsFrozenCurrent, y
        clc
        adc #1
        sta RoomStateBanditsFrozenCurrent, y

        ; Using the previous frame's state...
        ; If there are any active bandits remaining, do nothing
        lda RoomStateBanditsActivePrevious, y
        beq become_defeated
        rts

become_defeated:
        ; Firstly, figure out what we should spawn. Cherries are a special case:
        ; if WE are currently a cherry, we'll always roll a healing item
check_healing_item:
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        cmp #REEL_POS_CHERRY
        jeq reward_healing_item

        ; Everything else requires a group match. For now, just check for 3+ of the target
        ; AND zero of anything else
check_big_treasure:
        ; must have 3 or more of...
        lda RoomStateBanditReelCountSeven, y
        cmp #3
        bcc no_big_treasure
        ; ... and none of:
        lda RoomStateBanditReelCountCherry, y
        bne no_big_treasure
        lda RoomStateBanditReelCountGem, y
        bne no_big_treasure
        lda RoomStateBanditReelCountMagic, y
        bne no_big_treasure
        jmp reward_big_treasure
no_big_treasure:

check_small_treasure:
        ; must have 3 or more of...
        lda RoomStateBanditReelCountGem, y
        cmp #3
        bcc no_small_treasure
        ; ... and none of:
        lda RoomStateBanditReelCountCherry, y
        bne no_small_treasure
        lda RoomStateBanditReelCountSeven, y
        bne no_small_treasure
        lda RoomStateBanditReelCountMagic, y
        bne no_small_treasure
        jmp reward_small_treasure
no_small_treasure:

check_magic_spell:
        ; must have 3 or more of...
        lda RoomStateBanditReelCountMagic, y
        cmp #3
        bcc no_magic_spell
        ; ... and none of:
        lda RoomStateBanditReelCountCherry, y
        bne no_magic_spell
        lda RoomStateBanditReelCountSeven, y
        bne no_magic_spell
        lda RoomStateBanditReelCountGem, y
        bne no_magic_spell
        jmp reward_magic_spell
no_magic_spell:
        ; This is a "loot" reward, so set us into the appropriate state for that
        ldx CurrentTile
        oab_set_state #ONE_ARMED_BANDIT_STATE_LOOT_COINS
        ; Draw an earth-tinged "explode" tile in our current location, this will
        ; appear underneath the death sprite
        lda #<BG_TILE_EXPLOSION
        sta tile_patterns, x
        lda #>BG_TILE_EXPLOSION
        ora #PAL_EARTH
        sta tile_attributes, x
        jmp shared_juice_and_cleanup

reward_small_treasure:
        ; This is a "loot" reward, so set us into the appropriate state for that
        ldx CurrentTile
        oab_set_state #ONE_ARMED_BANDIT_STATE_LOOT_GEMS
        ; Draw an earth-tinged "explode" tile in our current location, this will
        ; appear underneath the death sprite
        lda #<BG_TILE_EXPLOSION
        sta tile_patterns, x
        lda #>BG_TILE_EXPLOSION
        ora #PAL_EARTH
        sta tile_attributes, x
        ; Since we're rewarding the player, play a chime
        queue_sfx_pulse1 sfx_puzzle_success_pulse
        queue_sfx_triangle sfx_puzzle_success_tri
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase
        jmp shared_juice_and_cleanup
reward_big_treasure:
        ; "Big" treasure is one gold sack, as an item. This means we need to replace ourselves with an
        ; item shadow, sorta like a chest
        ldx CurrentTile        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH
        lda #0
        sta tile_flags, x
        lda #ITEM_GOLD_SACK
        sta tile_data, x
        ; Since we're rewarding the player, play a chime
        queue_sfx_pulse1 sfx_puzzle_success_pulse
        queue_sfx_triangle sfx_puzzle_success_tri
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase
        jmp shared_juice_and_cleanup        
reward_healing_item:
        ; "Healing" items are just food. For now, spawn a buffet of medium fries
        ; TODO: later we should roll from a zone-appropriate loot table?
        ldx CurrentTile
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_EARTH
        lda #0
        sta tile_flags, x
        lda #ITEM_SMALL_FRIES
        sta tile_data, x
        ; Since we're rewarding the player, play a chime
        queue_sfx_pulse1 sfx_puzzle_success_pulse
        queue_sfx_triangle sfx_puzzle_success_tri
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase
        jmp shared_juice_and_cleanup
reward_magic_spell:
        ; Magic spells basically queue up the appropriate spell effect, just like if the player
        ; had cast that spell. There is one spell effect for each color, so work that out
        ; At this point Y still contains our coordination index, so this is straightforward
        lda spellcast_item_id_by_coordination_index_lut, y
        sta CurrentlyActiveSpell
        lda #1
        sta MonsterRequestsSpellCast
        ; Play the spellcasting SFX, just like if the player was holding up a scroll
        queue_sfx_pulse1_with_priority sfx_cast_pulse, #10
        ; Cleanup our own tile
        ldx CurrentTile
        stx DiscoTile
        lda CurrentRow
        sta DiscoRow
        near_call ENEMY_UPDATE_draw_disco_tile_here
        lda CurrentTile
        far_call FAR_queue_late_cycle_phase
        ; And perform the remainder of shared cleanup, minus defeat SFX (since we want the spell SFX to play instead)
        jmp cleanup_without_sfx

shared_juice_and_cleanup:
        ; Play an appropriately crunchy death sound
        defer_sfx_pulse1 sfx_defeat_enemy_pulse
        defer_sfx_noise sfx_defeat_enemy_noise
cleanup_without_sfx:
        ; Spawn a death sprite here (the whole group at once-ish)
        ; For sprite-logic reasons this is actually delayed until the following beat, just like we'd expect
        far_call ENEMY_BOMB_SPELL_spawn_death_sprite_here
        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        rts
.endproc

.proc ENEMY_UPDATE_update_one_armed_bandit_terminal_award_coins
; for draw_active_tile
TargetIndex := R0

ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ; This is the state a failed match ends up in, so it should use the 3-coin loot table
        set_loot_table three_coins_loot_table
        roll_base_loot_at CurrentTile

        ; now turn ourselves into a regular disco tile, and that should be it
        ldx CurrentTile
        stx DiscoTile
        lda CurrentRow
        sta DiscoRow
        near_call ENEMY_UPDATE_draw_disco_tile_here

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

        rts
.endproc

.proc ENEMY_UPDATE_update_one_armed_bandit_terminal_award_diamonds
; for draw_active_tile
TargetIndex := R0

ScratchByte := R0
CurrentRow := R14
CurrentTile := R15
        ; This is a successful "gems" match, so reward "gems" (2 diamonds)
        set_loot_table two_diamonds_loot_table
        roll_base_loot_at CurrentTile

        ; now turn ourselves into a regular disco tile, and that should be it
        ldx CurrentTile
        stx DiscoTile
        lda CurrentRow
        sta DiscoRow
        near_call ENEMY_UPDATE_draw_disco_tile_here

        ; because we updated ourselves this frame, but we are no longer, decrement ourselves again
        dec enemies_active

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
        jcs die_now
        ; otherwise, write the health back
        sta ScratchHp
        lda tile_data, x
        and #($FF - ONE_ARMED_BANDIT_DATA_HP)
        ora ScratchHp
        sta tile_data, x

        ; If we are not currently in the frozen state, we're ABOUT to be, so
        ; increment the count of our reel type for detecting loot
        lda tile_flags, x
        and #ONE_ARMED_BANDIT_FLAGS_STATE
        cmp #ONE_ARMED_BANDIT_STATE_FROZEN
        beq done_incrementing_reel_counts
        oab_compute_coordination_index_y
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        cmp #REEL_POS_CHERRY
        beq increment_cherry_count
        cmp #REEL_POS_GEM
        beq increment_gem_count
        cmp #REEL_POS_MAGIC
        beq increment_magic_count
increment_seven_count:
        lda RoomStateBanditReelCountSeven, y
        clc
        adc #1
        sta RoomStateBanditReelCountSeven, y
        jmp done_incrementing_reel_counts
increment_cherry_count:
        lda RoomStateBanditReelCountCherry, y
        clc
        adc #1
        sta RoomStateBanditReelCountCherry, y
        jmp done_incrementing_reel_counts
increment_gem_count:
        lda RoomStateBanditReelCountGem, y
        clc
        adc #1
        sta RoomStateBanditReelCountGem, y
        jmp done_incrementing_reel_counts
increment_magic_count:
        lda RoomStateBanditReelCountMagic, y
        clc
        adc #1
        sta RoomStateBanditReelCountMagic, y
        jmp done_incrementing_reel_counts
done_incrementing_reel_counts:

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
        ; Firstly, DECREASE the number of active frozen bandits on this frame; this
        ; affects loot generation for the remaining bandits on the next frame, if any
        oab_compute_coordination_index_y
        lda RoomStateBanditsFrozenCurrent, y
        sec
        sbc #1
        sta RoomStateBanditsFrozenCurrent, y

        ; Similarly, decrease the frozen count of our current reel, as we are leaving this mortal coil
        ; and are no longer feeling generous towards the player
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        cmp #REEL_POS_CHERRY
        beq decrement_cherry_count
        cmp #REEL_POS_GEM
        beq decrement_gem_count
        cmp #REEL_POS_MAGIC
        beq decrement_magic_count
decrement_seven_count:
        lda RoomStateBanditReelCountSeven, y
        sec
        sbc #1
        sta RoomStateBanditReelCountSeven, y
        jmp done_decrementing_reel_counts
decrement_cherry_count:
        lda RoomStateBanditReelCountCherry, y
        sec
        sbc #1
        sta RoomStateBanditReelCountCherry, y
        jmp done_decrementing_reel_counts
decrement_gem_count:
        lda RoomStateBanditReelCountGem, y
        sec
        sbc #1
        sta RoomStateBanditReelCountGem, y
        jmp done_decrementing_reel_counts
decrement_magic_count:
        lda RoomStateBanditReelCountMagic, y
        sec
        sbc #1
        sta RoomStateBanditReelCountMagic, y
        jmp done_decrementing_reel_counts
done_decrementing_reel_counts:

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
TargetSquare := R13
        ; If we are currently frozen, we are entirely nonthreatening! (Especially if we *just* became frozen
        ; in response to the player's attack!)
        ldx TargetSquare
        lda tile_flags, x
        and #ONE_ARMED_BANDIT_FLAGS_STATE
        cmp #ONE_ARMED_BANDIT_STATE_FROZEN
        beq deal_no_damage

        ; If we recently moved to the east, we are also nonthreatening
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_MOVED_EAST
        bne deal_no_damage

        ; TODO: handle the player bumping into us from the west?

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
        ldx EffectiveAttackSquare
        ; If we are currently frozen...
        lda tile_flags, x
        and #ONE_ARMED_BANDIT_FLAGS_STATE
        cmp #ONE_ARMED_BANDIT_STATE_FROZEN
        bne done_fixing_frozen_counter
        ; ... then DECREASE the number of active frozen bandits on this frame;
        oab_compute_coordination_index_y
        lda RoomStateBanditsFrozenCurrent, y
        sec
        sbc #1
        sta RoomStateBanditsFrozenCurrent, y
        ; ... and DECREASE the count for this reel type
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        cmp #REEL_POS_CHERRY
        beq decrement_cherry_count
        cmp #REEL_POS_GEM
        beq decrement_gem_count
        cmp #REEL_POS_MAGIC
        beq decrement_magic_count
decrement_seven_count:
        lda RoomStateBanditReelCountSeven, y
        sec
        sbc #1
        sta RoomStateBanditReelCountSeven, y
        jmp done_decrementing_reel_counts
decrement_cherry_count:
        lda RoomStateBanditReelCountCherry, y
        sec
        sbc #1
        sta RoomStateBanditReelCountCherry, y
        jmp done_decrementing_reel_counts
decrement_gem_count:
        lda RoomStateBanditReelCountGem, y
        sec
        sbc #1
        sta RoomStateBanditReelCountGem, y
        jmp done_decrementing_reel_counts
decrement_magic_count:
        lda RoomStateBanditReelCountMagic, y
        sec
        sbc #1
        sta RoomStateBanditReelCountMagic, y
        jmp done_decrementing_reel_counts
done_decrementing_reel_counts:
done_fixing_frozen_counter:

        ; Copy in the attack square, so we can use shared logic to process the effect
        lda AttackSquare
        sta EffectiveAttackSquare
        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_one_armed_bandit_indirect_explode
AttackSquare := R3
EffectiveAttackSquare := R10
        ldx EffectiveAttackSquare
        ; If we are currently frozen...
        lda tile_flags, x
        and #ONE_ARMED_BANDIT_FLAGS_STATE
        cmp #ONE_ARMED_BANDIT_STATE_FROZEN
        bne done_fixing_frozen_counter
        ; ... then DECREASE the number of active frozen bandits on this frame;
        oab_compute_coordination_index_y
        lda RoomStateBanditsFrozenCurrent, y
        sec
        sbc #1
        sta RoomStateBanditsFrozenCurrent, y
        ; ... and DECREASE the count for this reel type
        lda tile_data, x
        and #ONE_ARMED_BANDIT_DATA_REEL_POS
        cmp #REEL_POS_CHERRY
        beq decrement_cherry_count
        cmp #REEL_POS_GEM
        beq decrement_gem_count
        cmp #REEL_POS_MAGIC
        beq decrement_magic_count
decrement_seven_count:
        lda RoomStateBanditReelCountSeven, y
        sec
        sbc #1
        sta RoomStateBanditReelCountSeven, y
        jmp done_decrementing_reel_counts
decrement_cherry_count:
        lda RoomStateBanditReelCountCherry, y
        sec
        sbc #1
        sta RoomStateBanditReelCountCherry, y
        jmp done_decrementing_reel_counts
decrement_gem_count:
        lda RoomStateBanditReelCountGem, y
        sec
        sbc #1
        sta RoomStateBanditReelCountGem, y
        jmp done_decrementing_reel_counts
decrement_magic_count:
        lda RoomStateBanditReelCountMagic, y
        sec
        sbc #1
        sta RoomStateBanditReelCountMagic, y
        jmp done_decrementing_reel_counts
done_decrementing_reel_counts:
done_fixing_frozen_counter:

        near_call ENEMY_BOMB_SPELL_explode_common
        rts
.endproc

.proc ENEMY_BOMB_SPELL_one_armed_bandit_spell_dispatch
        ; TODO: change our color **and** advance/redraw our reel symbol
        rts
.endproc