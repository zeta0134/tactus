.proc update_mushroom
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
        lda #2
        sta IdleDelay
        jmp done_picking_idle_duration
advanced:
        lda #1
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

        ; TODO: spawn spore tiles around ourselves!


        rts
.endproc

.proc direct_attack_mushroom
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
        jsr direct_attack_with_hp
        rts
.endproc

.proc indirect_attack_mushroom
EffectiveAttackSquare := R10 
EnemyHealth := R11
        ldx EffectiveAttackSquare
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
        jsr indirect_attack_with_hp
        rts
.endproc

.proc update_one_beat_hazard
CurrentTile := R15
        ; it's been one beat! stop being a one beat hazard, thx.
        ldx CurrentTile
        draw_at_x_withpal TILE_REGULAR_FLOOR, BG_TILE_FLOOR, PAL_WORLD
        jsr draw_disco_tile
        rts
.endproc

.proc hazard_damages_player
        ; hazards do 1 damage to the player on hit
        far_call FAR_damage_player

        ; unlike regular enemies, hazards don't disappear.

        ; TODO: if there should be a hazard-specific damage sprite / overlay thing,
        ; this is where we would spawn that

        rts
.endproc

spore_plain_lut:
        .word BG_TILE_SPORES_N_PLAIN
        .word BG_TILE_SPORES_NE_PLAIN
        .word BG_TILE_SPORES_E_PLAIN
        .word BG_TILE_SPORES_SE_PLAIN
        .word BG_TILE_SPORES_S_PLAIN
        .word BG_TILE_SPORES_SW_PLAIN
        .word BG_TILE_SPORES_W_PLAIN
        .word BG_TILE_SPORES_NW_PLAIN
spore_solid_lut:
        .word BG_TILE_SPORES_N_SOLID
        .word BG_TILE_SPORES_NE_SOLID
        .word BG_TILE_SPORES_E_SOLID
        .word BG_TILE_SPORES_SE_SOLID
        .word BG_TILE_SPORES_S_SOLID
        .word BG_TILE_SPORES_SW_SOLID
        .word BG_TILE_SPORES_W_SOLID
        .word BG_TILE_SPORES_NW_SOLID
spore_outline_lut:
        .word BG_TILE_SPORES_N_OUTLINE
        .word BG_TILE_SPORES_NE_OUTLINE
        .word BG_TILE_SPORES_E_OUTLINE
        .word BG_TILE_SPORES_SE_OUTLINE
        .word BG_TILE_SPORES_S_OUTLINE
        .word BG_TILE_SPORES_SW_OUTLINE
        .word BG_TILE_SPORES_W_OUTLINE
        .word BG_TILE_SPORES_NW_OUTLINE

; Note: This is only for DRAWING the smoke puff! Any other data you need to stuff into
; this thing, do that at the call site.
; note: uses smokepuff input variables, since it is almost the same logic
.proc draw_spore_here
        ; The smoke puff needs to obey the same accesibility rules as the disco tile so
        ; that it meshes well with the underlying floor. Do all of those same checks here

        ; If the current room is cleared, we release the player from the perils of the tempo, and the
        ; floor stops dancing. (these would look very spastic if they flickered with the player's moves)
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne cleared_tile
        ; If we are in disco accessibility mode 3, treat all rooms as cleared for disco purposes,
        ; effectively suppressing the animation entirely
        lda setting_disco_floor
        cmp #DISCO_FLOOR_STATIC
        beq cleared_tile
        ; If we are in mode 2, don't draw the checkerboard pattern. Instead, treat all tiles as though
        ; they are unlit. This still allows the detail to dance with the music
        cmp #DISCO_FLOOR_NO_OUTLINE
        beq regular_tile

        ; Otherwise, we want to draw a checkerboard pattern, which alternates every time the beat advances
        ; we can do this with an XOR of these low bits: X coordinate, Y coordinate, Beat Counter
        lda SmokePuffRow
        eor SmokePuffTile
        eor CurrentBeatCounter
        and #%00000001
        bne disco_tile

        ; Here we diverge heavily; the smoke puff tiles have a completely different
        ; layout in memory. Note that smoke puffs now always use the world color, which
        ; diverges from their old behavior (they used to preserve the enemy color) since
        ; this looks weird with their disco floor variants
regular_tile:
        ; "regular" and "cleared" tiles are the same for smoke poffs
cleared_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda spore_plain_lut+0, y
        sta tile_patterns, x
        lda spore_plain_lut+1, y
        sta tile_attributes, x
        jmp converge
disco_tile:
        perform_zpcm_inc
        ; disco tiles have two accessibility modes: regular and outline, so handle that here
        lda setting_disco_floor
        cmp #DISCO_FLOOR_OUTLINE
        beq outlined_disco_tile
full_disco_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda spore_solid_lut+0, y
        sta tile_patterns, x
        lda spore_solid_lut+1, y
        sta tile_attributes, x
        jmp converge
outlined_disco_tile:
        perform_zpcm_inc
        ldx SmokePuffTile
        ldy SmokePuffDirection
        lda spore_outline_lut+0, y
        sta tile_patterns, x
        lda spore_outline_lut+1, y
        sta tile_attributes, x
        jmp converge

converge:
        ; draw_with_pal, adjusted for our temporary stash
        lda #TILE_ONE_BEAT_HAZARD
        sta battlefield, x

        ; set our "already processed" flag, since we don't want our "one beat hazard" logic to
        ; erase this tile's properties before the next beat
        ; (note: dashes don't need to do this because they replace the enemy's old tile, but spores
        ; do because they are drawn around the enemy)
        lda tile_flags, x
        ora #FLAG_MOVED_THIS_FRAME
        sta tile_flags, x

        ; And done!
        rts
.endproc