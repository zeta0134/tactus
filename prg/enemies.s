        .setcpu "6502"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "kernel.inc"
        .include "player.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.zeropage
DestPtr: .res 2

.segment "RAM"

.segment "PRGFIXED_C000"

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

static_behaviors:
        .word update_smoke_puff      ; $00 - smoke puff
        .word update_slime           ; $04 - slime (idle pose)
        .repeat 30
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
        .word direct_attack_puff
        .word direct_attack_slime
        .repeat 30
        .word no_behavior
        .endrepeat
        ; safety: fill out the rest of the table
        .repeat 32
        .word no_behavior
        .endrepeat

indirect_attack_behaviors:
        .word no_behavior ; smoke puff can't attack itself
        .word indirect_attack_slime
        .repeat 30
        .word no_behavior
        .endrepeat
        ; safety: fill out the rest of the table
        .repeat 32
        .word no_behavior
        .endrepeat

bonk_behaviors:
        .word no_behavior ; standing in a smoke puff is fine
        .word basic_enemy_attacks_player
        .repeat 30
        .word no_behavior
        .endrepeat
        .word no_behavior ; $80 - plain floor
        .word no_behavior ; $84 - disco floor
        .word solid_tile_forbids_movement     ; $88 - wall top
        .word solid_tile_forbids_movement     ; $8C - wall face
        .word solid_tile_forbids_movement     ; $90 - pit edge
        ; safety: fill out the rest of the table
        .repeat 27
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
        sta inactive_attribute_queue, x
        rts
.endproc

.proc queue_row_x
        lda #1
        sta inactive_tile_queue, x
        txa
        lsr
        tax
        sta inactive_attribute_queue, x
        rts
.endproc

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
        sta active_attribute_queue, x
        rts
.endproc

.proc spawn_death_sprite_here
MetaSpriteIndex := R0
EffectiveAttackSquare := R10
        jsr find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed

        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_RISE | SPRITE_PAL_1)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x

        ldy EffectiveAttackSquare
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
.proc update_static_enemy_row
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

.proc clear_active_move_flags
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

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================

.proc attack_enemy_tile
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

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================

.proc player_collides_with_tile
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