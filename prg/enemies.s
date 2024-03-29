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
GoldToAward: .res 1
DamageSpriteCoordX: .res 2
DamageSpriteCoordY: .res 2
HealthDroughtCounter: .res 1

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

.include "enemies/common.asm"

.include "enemies/birb.asm"
.include "enemies/cardinal_chaser.asm"
.include "enemies/diagonal_chaser.asm"
.include "enemies/disco_tile.asm"
.include "enemies/exit_block.asm"
.include "enemies/mole.asm"
.include "enemies/slimes.asm"
.include "enemies/small_heart.asm"
.include "enemies/smoke_puff.asm"
.include "enemies/treasure_chest.asm"
.include "enemies/weapon_shadow.asm"

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
        .word no_behavior     ; $94 - pit center
        .word no_behavior     ; $98 - treasure chest
        .word no_behavior     ; $9C - big key
        .word no_behavior     ; $A0 - gold sack
        .word update_weapon_shadow ; $A4 - weapon shadow
        ; safety: fill out the rest of the table
        .repeat 22
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
        .word collect_small_heart ; $B0
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
