; TODO: This is GOING AWAY / BEING REDONE, etc.

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_attack_treasure_chest
MetaSpriteIndex := R0
WeaponClassTemp := R1
TargetIndex := R0
TileId := R1
AttackSquare := R3
AttackLanded := R7
WeaponPtr := R11 
        ; Register the attack as a hit
        lda #1
        sta AttackLanded

        ; if this is a boss room, we need to always spawn the key!
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        beq spawn_treasure
        near_call ENEMY_ATTACK_spawn_big_key
        rts
spawn_treasure:
        perform_zpcm_inc
        ; determine which weapon category to spawn
        jsr next_gameplay_rand
        and #%00000001
        bne spawn_item
spawn_nav:
        near_call ENEMY_ATTACK_spawn_nav_item
        rts
spawn_item:
        near_call ENEMY_ATTACK_spawn_item
        rts
.endproc

.proc ENEMY_ATTACK_spawn_big_key
TargetIndex := R0
TileId := R1
AttackSquare := R3
        ; Super easy: replace the chest with a big key tile
        ldx AttackSquare
        stx TargetIndex
        draw_at_x_withpal TILE_BIG_KEY, BG_TILE_BIG_KEY, PAL_BLUE

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        rts
.endproc

.proc ENEMY_ATTACK_spawn_item
; for draw_active_tile
TargetIndex := R0

TileId := R1
AttackSquare := R3 ; do not clobber! (don't clobber R2 or R4-R15 either!)

; for rolling treasure loot
LootTablePtr := R16
ItemId := R18

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_WORLD

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        ; Now roll for the loot this item shadow will contain. This is a gameplay
        ; roll, so use that RNG and the appropriate table

        ; the real loot table
        st16 LootTablePtr, common_chest_treasure_table
        far_call FAR_roll_gameplay_loot
        ; zeta needs to obtain a specific item for testing
        ;lda #ITEM_ALOHA_TSHIRT_1
        ;sta ItemId


        ; Sanity check: is the player currently carrying equipment matching this loot?
        ; If so, revert to a gold sack instead
        lda ItemId
        cmp PlayerEquipmentWeapon
        beq reject_item
        cmp PlayerEquipmentTorch
        beq reject_item
        cmp PlayerEquipmentArmor
        beq reject_item
        cmp PlayerEquipmentBoots
        beq reject_item
        cmp PlayerEquipmentAccessory
        beq reject_item
        cmp PlayerEquipmentSpell
        beq reject_item
accept_item:
        ldx AttackSquare
        lda ItemId
        sta tile_data, x
        rts
reject_item:
        ldx AttackSquare
        lda #ITEM_GOLD_SACK
        sta tile_data, x
        rts
.endproc

.proc ENEMY_ATTACK_spawn_nav_item
; for draw_active_tile
TargetIndex := R0
TileId := R1
AttackSquare := R3 ; do not clobber! (don't clobber R2 or R4-R15 either!)

        ; depending on the player's nav index, we spawn nav helpers in a fixed order
        lda PlayerNavState
        beq spawn_compass
        cmp #1
        beq spawn_map
        ; the player has mapped this area; revert to generating a regular item instead
        near_call ENEMY_ATTACK_spawn_item
        rts
spawn_compass:
        inc PlayerNavState
        ldx AttackSquare
        lda #ITEM_COMPASS
        sta tile_data, x
        jmp converge
spawn_map:
        inc PlayerNavState
        ldx AttackSquare
        lda #ITEM_MAP
        sta tile_data, x
converge:

        ; Mostly easy: replace the chest with an item shadow
        ldx AttackSquare
        stx TargetIndex        
        draw_at_x_withpal TILE_ITEM_SHADOW, BG_TILE_WEAPON_SHADOW, PAL_WORLD

        lda #0
        sta tile_flags, x
        jsr draw_active_tile

        rts
.endproc

; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"

; TODO: rework this into an item? (what color will it be?)
; Alternate: rework it *properly* into an entity that follows the player
; (and can be stolen!)
.proc ENEMY_COLLIDE_collect_key
TargetIndex := R0
TileId := R1
TargetSquare := R13
        lda #1 ; there is only one key per dungeon floor
        sta PlayerKeys

        ; TODO: a nice SFX
        st16 R0, sfx_key_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_key_pulse2
        jsr play_sfx_pulse2

        ; Now, draw a basic floor tile here, which will be underneath the player
        ldx TargetSquare
        stx TargetIndex
        draw_at_x_withpal TILE_DISCO_FLOOR, BG_TILE_FLOOR, PAL_WORLD

        lda #0
        sta tile_data, x
        sta tile_flags, x

        jsr draw_active_tile

        ; This is the big key! Now that we have it, reveal the location of the exit
        ; stairs (this stops the player from needing to do a brute-force search)
        ldx #0
find_exit_loop:
        perform_zpcm_inc
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        beq next_room
        lda room_flags, x
        ora #ROOM_FLAG_REVEALED
        sta room_flags, x
next_room:
        inx
        cpx #::FLOOR_SIZE
        bne find_exit_loop

        lda #1
        sta HudMapDirty

        rts
.endproc
