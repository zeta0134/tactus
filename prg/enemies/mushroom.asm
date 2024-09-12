        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_mushroom
IdleDelay := R0
; these are provided for us
CurrentRow := R14
CurrentTile := R15
        inc enemies_active
        ldx CurrentTile

        ; Determine how many beats we should remain idle, based on type
        lda battlefield, x
        and #%00000011
        cmp #%00
        beq weird
        cmp #%01
        beq intermediate
        cmp #%10
        beq advanced
basic:
        lda #3
        sta IdleDelay
        jmp done_picking_idle_duration
intermediate:
        lda #3
        sta IdleDelay
        jmp done_picking_idle_duration
advanced:
        lda #2
        sta IdleDelay
        jmp done_picking_idle_duration
weird:
        lda #4
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
        draw_at_x_keeppal TILE_MUSHROOM_BASE, BG_TILE_MUSHROOM_IDLE
        rts

perform_anticipation:
        draw_at_x_keeppal TILE_MUSHROOM_BASE, BG_TILE_MUSHROOM_ANTICIPATE
        rts

perform_attack:
        draw_at_x_keeppal TILE_MUSHROOM_BASE, BG_TILE_MUSHROOM_ATTACK
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
        lda battlefield, x
        and #%00000011
        cmp #%11
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
        lda battlefield, x
        and #%00000011
        cmp #%00
        beq weird_hp
        cmp #%01
        beq intermediate_hp
        cmp #%10
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
        jmp done
weird_hp:
        set_loot_table advanced_loot_table
        lda #4
        sta EnemyHealth
done:
        near_call ENEMY_ATTACK_direct_attack_with_hp
        ; did we die? if so, cleanup the result of our attack
        ldx AttackSquare
        lda battlefield, x
        and #%11111100
        cmp #TILE_MUSHROOM_BASE
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
        lda #0
        sta ConsiderationIndex
loop:
        clc
        lda AttackSquare
        ldy ConsiderationIndex
        adc spore_offsets, y
        sta DiscoTile
        tax
        ; is this a spore tile? don't erase just anything
        lda battlefield, x
        cmp #TILE_ONE_BEAT_HAZARD ; TODO: is this check specific enough?
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
        rts
.endproc

        .segment "ENEMY_UPDATE"
.proc ENEMY_UPDATE_update_one_beat_hazard
CurrentTile := R15
        ldx CurrentTile
        bail_if_already_moved

        ; it's been one beat! stop being a one beat hazard, thx.
        ldx CurrentTile
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD
        near_call ENEMY_UPDATE_draw_disco_tile
        rts
.endproc

        .segment "ENEMY_COLLIDE"
.proc ENEMY_COLLIDE_hazard_damages_player
DamageAmount := R0
        ; hazards to 2 dmg to the player (for now)
        lda #2
        sta DamageAmount
        far_call FAR_damage_player

        ; unlike regular enemies, hazards don't disappear.

        ; TODO: if there should be a hazard-specific damage sprite / overlay thing,
        ; this is where we would spawn that

        rts
.endproc

        .segment "ENEMY_UPDATE"

spores_lut:
spores_n:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_N + OFFSET_PLAIN
spores_ne:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NE + OFFSET_PLAIN
spores_e:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_E + OFFSET_PLAIN
spores_se:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SE + OFFSET_PLAIN
spores_s:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_S + OFFSET_PLAIN
spores_sw:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_SW + OFFSET_PLAIN
spores_w:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_W + OFFSET_PLAIN
spores_nw:
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_SOLID_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_SOLID_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_PLAIN
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_OUTLINE_GROWING
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_OUTLINE_STATIC
        .word BG_TILE_SPORE_TILES_0000 + OFFSET_NW + OFFSET_PLAIN

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
; note: uses smokepuff input variables, since it is almost the same logic
.proc ENEMY_UPDATE_draw_spore_here
TargetFuncPtr := R0
        perform_zpcm_inc
        ; run the disco selection logic based on the player's preference
        ; (DiscoTile==SmokePuffTile, and DiscoRow==SmokePuffRow, so that setup is done by this point)
        ldx setting_disco_floor
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
