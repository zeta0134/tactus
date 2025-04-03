        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_mushroom
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active
        ldx CurrentTile

        ; Determine how many beats we should remain idle, based on type
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq earth
        cmp #PAL_ICE
        beq ice
        cmp #PAL_AIR
        beq air
fire:
        lda #(MUSHROOM_FIRE_BEATS-1)
        sta IdleDelay
        jmp done_picking_idle_duration
earth:
        lda #(MUSHROOM_EARTH_BEATS-1)
        sta IdleDelay
        jmp done_picking_idle_duration
ice:
        lda #(MUSHROOM_ICE_BEATS-1)
        sta IdleDelay
        jmp done_picking_idle_duration
air:
        lda #(MUSHROOM_AIR_BEATS-1)
        sta IdleDelay
done_picking_idle_duration:

        lda tile_data, x
        cmp IdleDelay
        beq perform_attack

        inc tile_data, x
        lda tile_data, x
        cmp IdleDelay
        beq perform_anticipation
continue_idling:
        draw_at_x_keeppal TILE_MUSHROOM, BG_TILE_MUSHROOM_IDLE
        rts

perform_anticipation:
        draw_at_x_keeppal TILE_MUSHROOM, BG_TILE_MUSHROOM_ANTICIPATE
        rts

perform_attack:
        draw_at_x_keeppal TILE_MUSHROOM, BG_TILE_MUSHROOM_ATTACK
        lda #0
        sta tile_data, x

        ; all mushrooms will spawn spores in cardinal directions, so do that first
        ; note: mushrooms are immobile and cannot spawn on a map border, so there is
        ; no need to perform bounds checks on these calculations
        lda #DUST_DIRECTION_N
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #BATTLEFIELD_WIDTH
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        dec SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_S
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #BATTLEFIELD_WIDTH
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        inc SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_W
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #1
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_E
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #1
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        ; everything except the basic variety also spawns diagonals, so check for that here
        ldx CurrentTile
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_FIRE
        beq skip_spawning_diagonal_spores

        lda #DUST_DIRECTION_NW
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #(BATTLEFIELD_WIDTH+1)
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        dec SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_NE
        sta SmokePuffDirection
        lda CurrentTile
        sec
        sbc #(BATTLEFIELD_WIDTH-1)
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        dec SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_SW
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #(BATTLEFIELD_WIDTH-1)
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        inc SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

        lda #DUST_DIRECTION_SE
        sta SmokePuffDirection
        lda CurrentTile
        clc
        adc #(BATTLEFIELD_WIDTH+1)
        sta SmokePuffTile
        lda CurrentRow
        sta SmokePuffRow
        inc SmokePuffRow
        near_call ENEMY_UPDATE_spawn_spore_tile

skip_spawning_diagonal_spores:
        rts
.endproc

.proc ENEMY_UPDATE_spawn_spore_tile
        ; First off, is this even a valid location for a spore to spawn? Basically
        ; this follows the same rules as any other enemy movement, but also allows
        ; overwriting nearby spore tiles
        ldx SmokePuffTile
        lda battlefield, x
        ; floors are unconditionally okay
        cmp #TILE_DISCO_FLOOR
        beq proceed_to_spawn
check_smoke_puffs:
        ; puffs of smoke are only okay if they moved *last* frame
        ; (this resolves some weirdness with tile update order)
        cmp #TILE_SMOKE_PUFF
        bne check_one_beat_hazards
        lda tile_flags, x
        bpl proceed_to_spawn
        jmp valid_destination_failure
check_one_beat_hazards:
        ; same deal with hazard tiles (which would be turning into floor when they update)
        cmp #TILE_ONE_BEAT_HAZARD
        bne valid_destination_failure
        lda tile_flags, x
        bpl proceed_to_spawn
        jmp valid_destination_failure
valid_destination_failure:
        rts
proceed_to_spawn:
        near_call ENEMY_UPDATE_draw_spore_here
        rts        
.endproc

        .segment "ENEMY_ATTACK"
.proc ENEMY_ATTACK_direct_attack_mushroom
AttackSquare := R3
EnemyHealth := R11
        ldx AttackSquare
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq earth_hp
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_AIR
        beq air_hp
fire_hp:
        set_loot_table MUSHROOM_FIRE_LOOT
        lda #MUSHROOM_FIRE_HP
        sta EnemyHealth
        jmp done
earth_hp:
        set_loot_table MUSHROOM_EARTH_LOOT
        lda #MUSHROOM_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table MUSHROOM_ICE_LOOT
        lda #MUSHROOM_ICE_HP
        sta EnemyHealth
        jmp done
air_hp:
        set_loot_table MUSHROOM_AIR_LOOT
        lda #MUSHROOM_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        ; did we die? if so, cleanup the result of our attack
        ldx AttackSquare
        lda battlefield, x
        cmp #TILE_MUSHROOM
        beq not_dead
        jsr ENEMY_ATTACK_cleanup_own_spores
not_dead:
        rts
.endproc

; If we attack a mushroom on the same beat that it would have released
; spores, we "cancel" that attack, like with other enemies. Unfortunately
; those spores are already drawn in place, so we need to check for them
; here and remove the tiles, otherwise the player can take damage.
spore_offsets:
        .byte <(-BATTLEFIELD_WIDTH - 1)
        .byte <(-BATTLEFIELD_WIDTH + 0)
        .byte <(-BATTLEFIELD_WIDTH + 1)
        .byte <(                 0 - 1)
        .byte <(                 0 + 1)
        .byte <( BATTLEFIELD_WIDTH - 1)
        .byte <( BATTLEFIELD_WIDTH + 0)
        .byte <( BATTLEFIELD_WIDTH + 1)

.proc ENEMY_ATTACK_cleanup_own_spores
TargetIndex := R0
ConsiderationIndex := R10
AttackSquare := R3
        perform_zpcm_inc
        lda #0
        sta ConsiderationIndex
loop:
        perform_zpcm_inc
        clc
        lda AttackSquare
        ldy ConsiderationIndex
        adc spore_offsets, y
        sta DiscoTile
        tax
        ; is this a spore tile? don't erase just anything
        lda battlefield, x
        cmp #TILE_ONE_BEAT_HAZARD
        bne not_a_spore
        lda tile_index_to_row_lut, x
        sta DiscoRow
        far_call ENEMY_UPDATE_draw_disco_tile_here
        lda DiscoTile
        sta TargetIndex
        jsr draw_active_tile
not_a_spore:
        inc ConsiderationIndex
        lda ConsiderationIndex
        cmp #8
        bne loop
        perform_zpcm_inc
        rts
.endproc

        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_one_beat_hazard
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved

        ; it's been one beat! stop being a one beat hazard, thx.
        ldx CurrentTile
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_EARTH
        near_call ENEMY_UPDATE_draw_disco_tile
        rts
.endproc

        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_hazard_damages_player
DamageAmount := R0
        ; hazards to 2 dmg to the player (for now)
        lda #MUSHROOM_SPORE_DMG
        sta DamageAmount
        far_call FAR_damage_player
        
        ; YOU WERE HERE
        ; TODO: have the spore work out the direction to damage the player, so the
        ; knockback goes away from the mushroom. (Read the tile we chose; there's
        ; a whole equivalence class due to the disco floor thing, and I'm too tired
        ; to think it out right now.)

        ; hazards don't disappear when they "collide." They
        ; will clean themselves up automatically, usually
        ; on the next beat

        rts
.endproc

        .segment "ENEMY_UPDATE"

spores_lut:
spores_n:
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_N, OFFSET_PLAIN
spores_ne:
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_NE, OFFSET_PLAIN
spores_e:
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_E, OFFSET_PLAIN
spores_se:
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_SE, OFFSET_PLAIN
spores_s:
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_S, OFFSET_PLAIN
spores_sw:
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_SW, OFFSET_PLAIN
spores_w:
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_W, OFFSET_PLAIN
spores_nw:
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_SOLID_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_SOLID_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_PLAIN
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_OUTLINE_GROWING
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_OUTLINE_STATIC
        directional_tile_offset "SPORE_TILES", OFFSET_NW, OFFSET_PLAIN

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
; note: uses smokepuff input variables, since it is almost the same logic
.proc ENEMY_UPDATE_draw_spore_here
TargetFuncPtr := R0
        perform_zpcm_inc
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldx current_save + SaveFile::OptionDiscoFloor
        lda disco_behavior_lut_low, x
        sta TargetFuncPtr+0
        lda disco_behavior_lut_high, x
        sta TargetFuncPtr+1
        jsr _disco_trampoline

        ora SmokePuffDirection
        asl ; expand from byte to word alignment
        tay
        ldx SmokePuffTile
        lda #TILE_ONE_BEAT_HAZARD
        sta battlefield, x
        lda spores_lut+0, y
        sta tile_patterns, x
        lda spores_lut+1, y
        sta tile_attributes, x

        ; set our "already processed" flag, since we don't want our "one beat hazard" logic to
        ; erase this tile's properties before the next beat
        ; (note: dashes don't need to do this because they replace the enemy's old tile, but spores
        ; do because they are drawn around the enemy)
        lda tile_flags, x
        ora #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; And done!
        perform_zpcm_inc
        rts
.endproc

        .segment "ENEMY_BOMB_SPELL"

mushroom_spell_lut:
        .word ENEMY_BOMB_SPELL_mushroom_elemental_attack ; SPELL_FIRE
        .word ENEMY_BOMB_SPELL_mushroom_elemental_attack ; SPELL_AIR
        .word ENEMY_BOMB_SPELL_mushroom_elemental_attack ; SPELL_ICE
        .word ENEMY_BOMB_SPELL_mushroom_elemental_attack ; SPELL_EARTH
        .word FIXED_no_behavior                ; SPELL_BOMB
        .word FIXED_no_behavior                ; SPELL_LIFE

.proc ENEMY_BOMB_SPELL_mushroom_spell_dispatch
DispatchPtr := R0
;Length := R13
CurrentRow := R14
CurrentTile := R15
        lda current_save + SaveFile::PlayerEquipmentSpell
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
        lda mushroom_spell_lut+0, x
        sta DispatchPtr+0
        lda mushroom_spell_lut+1, x
        sta DispatchPtr+1
        jmp (DispatchPtr)
        ; does not return
.endproc

.proc ENEMY_BOMB_SPELL_mushroom_elemental_attack
EnemyHealth := R12

CurrentRow := R14
CurrentTile := R15
        ldx CurrentTile
        lda tile_attributes, x
        and #PAL_MASK
        cmp #PAL_EARTH
        beq earth_hp
        cmp #PAL_ICE
        beq ice_hp
        cmp #PAL_AIR
        beq air_hp
fire_hp:
        set_loot_table MUSHROOM_FIRE_LOOT
        lda #MUSHROOM_FIRE_HP
        sta EnemyHealth
        jmp done
earth_hp:
        set_loot_table MUSHROOM_EARTH_LOOT
        lda #MUSHROOM_EARTH_HP
        sta EnemyHealth
        jmp done
ice_hp:
        set_loot_table MUSHROOM_ICE_LOOT
        lda #MUSHROOM_ICE_HP
        sta EnemyHealth
        jmp done
air_hp:
        set_loot_table MUSHROOM_AIR_LOOT
        lda #MUSHROOM_AIR_HP
        sta EnemyHealth
done:
        near_call ENEMY_BOMB_SPELL_regular_enemy_elemental_spell_common
        rts
.endproc
