        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "player.inc"
        .include "rainbow.inc"
        .include "saves.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage

PlayerWeaponPtr: .res 2
WeaponSquaresPtr: .res 2

.segment "RAM"

; oh, this is probably overkill. it's fine.
weapon_metasprite_ids: .res 8

; "Scratch" registers, because 16 was just not enough for some situations
EnemyDiedThisFrame: .res 1
SafetyCol: .res 1
SafetyRow: .res 1
WeaponSquaresIndex: .res 1
TilesRemaining: .res 1

; Outside code depends on these
WeaponProperties: .res 1
WeaponAttackLanded: .res 1

.segment "CODE_PLAYER_1"

weapon_class_table:
        .word dagger, dagger ; Daggers don't have charge attacks :(
        .word broadsword, broadsword_charge
        .word longsword, longsword_charge
        .word spear, spear_charge
        .word flail, flail_charge

.proc load_weapon_ptr
ItemPtr := R0
        access_data_bank #<.bank(item_table)
        lda current_save + SaveFile::PlayerEquipmentWeapon
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1
        ldy #ItemDef::WeaponShape
        lda (ItemPtr), y
        asl
        asl
        tay
        lda PlayerIsCharged
        beq load_regular_ptr
        iny
        iny
load_regular_ptr:
        lda weapon_class_table+0, y
        sta PlayerWeaponPtr+0
        lda weapon_class_table+1, y
        sta PlayerWeaponPtr+1
        restore_previous_bank
        rts
.endproc

.proc FAR_draw_weapon_effects
        jmp (WeaponDrawFunc)
.endproc

; No update! Sprites stay where they are spawned, even if the player moves later.
; Ideal for simple slashes and strikes.
.proc weapon_update_none
        rts
.endproc

; Weapon sprites should track the player! Ideal for weapons that do not cancel
; the player's movement, so the animation appears to travel appropriately
.proc weapon_update_track_player
MetaSpriteIndex := R0
EntriesRemaining := R1
CurrentEntry := R2
AnimPtr := R3
        mov16 AnimPtr, WeaponAnimPtr

        ldy #0
        lda (AnimPtr), y
        sta EntriesRemaining
        bne safe_to_continue
        ; huh? empty set? okay, do nothing
        rts 
safe_to_continue:
        inc16 AnimPtr
        lda #0
        sta CurrentEntry
loop:
        perform_zpcm_inc
        ldy CurrentEntry
        lda weapon_metasprite_ids, y
        sta MetaSpriteIndex
        ; sanity check #1: is this index valid? the sprite
        ; may have failed to spawn during init; if so, do nothing
        cmp #$FF
        beq skip_this_sprite
        ; sanity check #2: is this metasprite still active? it
        ; really "should" be, but trust nothing; if it has gone inactive,
        ; permanently mark this slot as invalid and then do nothing
        ldx MetaSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #SPRITE_ACTIVE
        bne update_this_sprite
        lda #$FF
        ldy CurrentEntry
        sta weapon_metasprite_ids, y
        jmp skip_this_sprite
update_this_sprite:
        ; using the entry in the table, compute the new sprite position
        ; based on the player's current position, and move the metasprite
        ; to that location
        ldy #WeaponAnimEntry::RelativePixelPosX
        lda (AnimPtr), y
        clc
        adc PlayerCurrentX+1
        sta sprite_table + MetaSpriteState::PositionX, x

        ldy #WeaponAnimEntry::RelativePixelPosY
        lda (AnimPtr), y
        clc
        adc PlayerCurrentY+1
        sta sprite_table + MetaSpriteState::PositionY, x
skip_this_sprite:
        add16b AnimPtr, #.sizeof(WeaponAnimEntry)
        inc CurrentEntry
        dec EntriesRemaining
        bne loop
        perform_zpcm_inc
        rts
.endproc

.proc FAR_player_swing_weapon
; R0 and R1 are reserved for the enemy behaviors to use
; Current target square to consider for attacking
AttackSquare := R3

; Most on-hit routines primarily consume this variable and little else
EffectiveAttackSquare := R10
; We don't use these, but we should know not to clobber them. The
; outer player routine is tracking the player's new destination. Called
; weapon-handling routines MAY change these, but usually do not.
TargetRow := R14
TargetCol := R15
        perform_zpcm_inc

        jsr load_weapon_ptr ; clobbers R0,R1,y

        perform_zpcm_inc

        lda #0
        sta EnemyDiedThisFrame

        lda #0
        sta PlayerCombo

        ldx PlayerRow
        lda row_number_to_tile_index_lut, x ; Row * Width
        clc
        adc PlayerCol                  ; ... + Col
        sta PlayerSquare

        ; depending on the player's directional input, we'll need to load one of
        ; the four directional pointers, so do that:

        lda PlayerNextDirection
        ora PlayerHeldDirection
        bne direction_in_range
        ; If we get here, the player released the button and we're probably in a
        ; charge state. Use the last successful attack direction as a fallback.
        lda PlayerPreviousSuccessfulAttackDirection
        bne direction_in_range
        ; If we get HERE, ... first of all, how? This is weird enough that we should
        ; crash on purpose, but... default to a north swing, just to be in range.
        lda #PLAYER_DIRECTION_NORTH
direction_in_range:
check_north:
        cmp #PLAYER_DIRECTION_NORTH
        bne check_east
        ldy #WeaponClass::NorthSquaresPtr
        jmp done_choosing_direction
check_east:
        cmp #PLAYER_DIRECTION_EAST
        bne check_south
        far_call FAR_player_face_right
        ldy #WeaponClass::EastSquaresPtr
        jmp done_choosing_direction
check_south:
        cmp #PLAYER_DIRECTION_SOUTH
        bne check_west
        ldy #WeaponClass::SouthSquaresPtr
        jmp done_choosing_direction
check_west:
        cmp #PLAYER_DIRECTION_WEST
        bne done_choosing_direction ; should never be taken
        far_call FAR_player_face_left
        ldy #WeaponClass::WestSquaresPtr

done_choosing_direction:
        perform_zpcm_inc
        lda (PlayerWeaponPtr), y
        sta WeaponSquaresPtr
        iny
        lda (PlayerWeaponPtr), y
        sta WeaponSquaresPtr+1
        ; skip ahead 4 words, minus 1 for the iny we already did, to nab
        ; the corresponding animation init routine for this direction
        .repeat 7 
        iny       
        .endrepeat
        ; preload the weapon init animation (which we may cancel later)
        lda (PlayerWeaponPtr), y
        sta WeaponDrawFunc+0
        iny
        lda (PlayerWeaponPtr), y
        sta WeaponDrawFunc+1
        
        ; Now we iterate through each of these squares, roll an attack against the square
        lda #0
        sta WeaponAttackLanded
        sta WeaponSquaresIndex
        sta WeaponSingleTargetIndex

        ldy #WeaponClass::NumSquares
        lda (PlayerWeaponPtr), y
        sta TilesRemaining
loop:
        perform_zpcm_inc
        ; Reset to the player's position
        lda PlayerSquare
        sta AttackSquare
        ; For safety, track the raw row/col as well
        lda PlayerRow
        sta SafetyRow
        lda PlayerCol
        sta SafetyCol

        ; Add the relative offset from the considered square
        ldy WeaponSquaresIndex
        lda (WeaponSquaresPtr), y ; X offset
        clc
        adc AttackSquare
        sta AttackSquare
        
        ; Also add it to our tracked SafetyCol
        lda PlayerCol
        clc
        adc (WeaponSquaresPtr), y ; X offset
        sta SafetyCol

        iny
        ; For the SafetyRow, we can do simple arithmetic here
        lda (WeaponSquaresPtr), y ; Y offset
        clc
        adc SafetyRow
        sta SafetyRow
        
        lda (WeaponSquaresPtr), y ; Y offset
        bmi negative_y
positive_y:
        tax        
        lda row_number_to_tile_index_lut, x
        clc
        adc AttackSquare
        sta AttackSquare
        jmp converge
negative_y:
        eor #$FF
        tax
        inx
        sec
        lda AttackSquare
        sbc row_number_to_tile_index_lut, x
        sta AttackSquare
converge:
        iny
        perform_zpcm_inc

        lda (WeaponSquaresPtr), y ; Behavioral Flags for this tile
        sta WeaponProperties      ; Stash these here so the enemies can see them (if applicable)
        iny
        sty WeaponSquaresIndex

        ; Safety Dance: do NOT attack tiles that are out of bounds
        lda SafetyCol
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_WIDTH
        bcs skip_out_of_bounds
        lda SafetyRow
        bmi skip_out_of_bounds
        cmp #BATTLEFIELD_HEIGHT
        bcs skip_out_of_bounds

        perform_zpcm_inc
        far_call FAR_attack_enemy_tile
skip_out_of_bounds:
        perform_zpcm_inc

check_player_movement:
        ; If this weapon square could cancel movement
        lda #WEAPON_CANCEL_MOVEMENT
        and WeaponProperties
        beq check_early_exit
        ; ... and an attack actually landed
        lda WeaponAttackLanded
        beq check_early_exit
        ; ... then block player movement
        lda #1
        sta PlayerMovementBlocked
check_early_exit:
        ; If this weapon square is single target...
        lda #WEAPON_SINGLE_TARGET
        and WeaponProperties
        beq no_early_exit
        ; ... and the attack actually landed
        lda WeaponAttackLanded
        beq no_early_exit
        ; Then we are done with the swing, and should clean up
        jmp done_with_swing
no_early_exit:
        ; Otherwise, iterate to the next weapon square and continue
        inc WeaponSingleTargetIndex
        dec TilesRemaining
        jne loop

done_with_swing:
        perform_zpcm_inc

        ; charge attacks always "land", because it looks and feels very wrong otherwise.
        ; even if they whiff, we still need to see the swing. this also means a whiffed
        ; charge attack still burns the player :D
        lda PlayerIsCharged
        bne attack_did_not_miss

        ; if an attack landed at all ...
        lda WeaponAttackLanded
        beq attack_missed
attack_did_not_miss:

        ; process burn damage, if required
        jsr process_burn_damage
        
        ; ... play a weapon slash effect
        lda EnemyDiedThisFrame
        bne skip_weapon_sfx
        queue_sfx_noise sfx_weapon_slash
skip_weapon_sfx:
        ; ... and set our sprite state to attacking
        ; TODO: if we have multiple or weapon-specific attack animations, here is where to apply them
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_ATTACK
        lda #$FF
        sta PlayerAnimationTable

done:
        ; If there is any cleanup to do, do that here. Otherwise we're finished I think?
        perform_zpcm_inc
        rts

attack_missed:
        ; Clear out our animation routine which we preloaded earlier, we want to
        ; draw nothing instead
        st16 WeaponDrawFunc, weapon_update_none
        perform_zpcm_inc
        rts
.endproc

.proc process_burn_damage
IncomingDamage := R0
        lda PlayerLingeringStatusType
        cmp #PLAYER_STATUS_BURNED
        beq processing_required
        rts
processing_required:

        ; TODO: if we're really going to do burn resistance, factor that in here.
        ; For now, burn damage deals a consistent 2 HP. Burns **can** kill the player.
        lda #2
        sta IncomingDamage
        far_call FAR_receive_damage

no_attack_this_turn:
        rts
.endproc

; Programmer notes: try to prefer clockwise update order, for consistency.
; That means single-hit weapons should prioritize the *player's* left

; Make sure WeaponAnimPtr is set before calling!
.proc weapon_init_common
MetaSpriteIndex := R0
EntriesRemaining := R1
CurrentEntry := R2
AnimPtr := R3

        mov16 AnimPtr, WeaponAnimPtr

        ldy #0
        lda (AnimPtr), y
        sta EntriesRemaining
        bne safe_to_continue
        ; huh? empty set? okay, do nothing
        rts 
safe_to_continue:
        inc16 AnimPtr
        lda #0
        sta CurrentEntry
loop:
        far_call FAR_find_unused_sprite
        ldy CurrentEntry
        lda MetaSpriteIndex
        sta weapon_metasprite_ids, y
        cmp #$FF
        beq sprite_failed

        ldx MetaSpriteIndex
        ldy #WeaponAnimEntry::TileId
        lda (AnimPtr), y
        clc
        adc #SPRITE_OFFSET_WEAPON
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldy #WeaponAnimEntry::BehaviorFlags
        lda (AnimPtr), y
        ora #(SPRITE_ACTIVE | SPRITE_ONE_BEAT)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        lda #0
        sta sprite_table + MetaSpriteState::LifetimeBeats, x

        ldy #WeaponAnimEntry::RelativePixelPosX
        lda (AnimPtr), y
        clc
        adc PlayerCurrentX+1
        sta sprite_table + MetaSpriteState::PositionX, x

        ldy #WeaponAnimEntry::RelativePixelPosY
        lda (AnimPtr), y
        clc
        adc PlayerCurrentY+1
        sta sprite_table + MetaSpriteState::PositionY, x

sprite_failed:
        add16b AnimPtr, #.sizeof(WeaponAnimEntry)
        inc CurrentEntry
        dec EntriesRemaining
        bne loop

        rts
.endproc

; Daggers are simple weapons: they hit one tile in the direction
; the player is facing, and stop the player on hit:
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

; (Daggers are also single target, but the flag here would be redundant, as their
; patterns only consider a single square.)

dagger:
        .byte $01 ; Length
        ; behavior tables
        .word dagger_north, dagger_east, dagger_south, dagger_west
        ; animation routines
        .word dagger_init_north, dagger_init_east, dagger_init_south, dagger_init_west

dagger_north:
        ;         X,  Y, Behavior
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT)

dagger_east:
        ;         X,  Y, Behavior
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT)

dagger_south:
        ;         X,  Y, Behavior
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT)

dagger_west:
        ;         X,  Y, Behavior
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT)

dagger_north_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes  -8, -16, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_1, (SPRITE_PAL_YELLOW)
        .lobytes   8, -16, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_2, (SPRITE_PAL_YELLOW)

dagger_east_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes  16,  -8, SPRITE_WEAPON_DAGGER_DAGGER_EAST_1, (SPRITE_PAL_YELLOW)
        .lobytes  16,   8, SPRITE_WEAPON_DAGGER_DAGGER_EAST_2, (SPRITE_PAL_YELLOW)

dagger_south_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes  -8,  16, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes   8,  16, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

dagger_west_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes -16,  -8, SPRITE_WEAPON_DAGGER_DAGGER_EAST_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes -16,   8, SPRITE_WEAPON_DAGGER_DAGGER_EAST_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

; Daggers have no special behavior; each directional strike sets up a common anim table
.proc dagger_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_1
        st16 WeaponAnimPtr, dagger_north_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc dagger_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_DAGGER_DAGGER_EAST_1
        st16 WeaponAnimPtr, dagger_east_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc dagger_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_DAGGER_DAGGER_NORTH_1
        st16 WeaponAnimPtr, dagger_south_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc dagger_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_DAGGER_DAGGER_EAST_1
        st16 WeaponAnimPtr, dagger_west_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; Broadswords hit a wide field of 3 tiles in front of the player. Great
; for crowd control, but poor for escaping, as they are likely to cancel
; movement at inopportune times:
; [ ][ ][ ][ ][ ][ ]
; [ ][*][ ][ ][ ][ ]
; [P][*][ ][ ][ ][ ]
; [ ][*][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

broadsword:
        .byte $03 ; Length
        ; behavior tables
        .word broadsword_north, broadsword_east, broadsword_south, broadsword_west
        ; animation routines
        .word broadsword_init_north, broadsword_init_east, broadsword_init_south, broadsword_init_west

broadsword_north:
        ;         X,  Y, Behavior
        .lobytes -1, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -1, (WEAPON_CANCEL_MOVEMENT)

broadsword_east:
        ;         X,  Y, Behavior
        .lobytes  1, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  1, (WEAPON_CANCEL_MOVEMENT)

broadsword_south:
        ;         X,  Y, Behavior
        .lobytes  1,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  1, (WEAPON_CANCEL_MOVEMENT)

broadsword_west:
        ;         X,  Y, Behavior
        .lobytes -1,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1, -1, (WEAPON_CANCEL_MOVEMENT)

broadsword_north_clockwise_anim:
        .byte 3  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes -16, -16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_1, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_2, (SPRITE_PAL_YELLOW)
        .lobytes  16, -16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_3, (SPRITE_PAL_YELLOW)

broadsword_east_clockwise_anim:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  16, -16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_1, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_2, (SPRITE_PAL_YELLOW)
        .lobytes  16,  16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_3, (SPRITE_PAL_YELLOW)

broadsword_south_clockwise_anim:
        .byte 3  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes -16,  16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_3, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes   0,  16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes  16,  16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

broadsword_west_clockwise_anim:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -16, -16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_3, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes -16,   0, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes -16,  16, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)


; When charged up, Broadswords strike all 8 tiles around the player, in
; a big fancy circle. Extremely classic and straightforward, this move is
; present in all sorts of action games.
; [ ][ ][ ][ ][ ][ ]
; [*][*][*][ ][ ][ ]
; [*][P][*][ ][ ][ ]
; [*][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

broadsword_charge:
        .byte $08 ; Length
        ; charge behavior tables
        .word broadsword_charge_common, broadsword_charge_common, broadsword_charge_common, broadsword_charge_common
        ; charge animation routines
        .word broadsword_charge_init, broadsword_charge_init, broadsword_charge_init, broadsword_charge_init

; in terms of behavior, broadsword "charge" mechanics are identical in all four directions. We strike
; all 8 tiles around the player
broadsword_charge_common:
        ;         X,  Y, Behavior
        .lobytes -1, -1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  1, -1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes -1,  1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  1,  1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)

; As this is non-directional, we'll just use the same variant for all directions to save space.
; (also this is placeholder)
broadsword_charge_anim:
        .byte 8  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)

; Broadswords have no special behavior; each directional strike sets up a common anim table
.proc broadsword_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_1
        st16 WeaponAnimPtr, broadsword_north_clockwise_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc broadsword_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_1
        st16 WeaponAnimPtr, broadsword_east_clockwise_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc broadsword_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_BROADSWORD_BROADSWORD_NORTH_1
        st16 WeaponAnimPtr, broadsword_south_clockwise_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc broadsword_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_BROADSWORD_BROADSWORD_EAST_1
        st16 WeaponAnimPtr, broadsword_west_clockwise_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; Since the broadsword charge animation is symmetric, all four directions share the same
; setup code and animation table
.proc broadsword_charge_init
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, broadsword_charge_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; Longswords are like daggers that hit an extra square in front of the player
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

longsword:
        .byte $02 ; Length
        ; behavior tables
        .word longsword_north, longsword_east, longsword_south, longsword_west
        ; animation routines
        .word longsword_init_north, longsword_init_east, longsword_init_south, longsword_init_west

longsword_north:
        ;         X,  Y, Behavior
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT)

longsword_east:
        ;         X,  Y, Behavior
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT)

longsword_south:
        ;         X,  Y, Behavior
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT)

longsword_west:
        ;         X,  Y, Behavior
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT)

longsword_north_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0, -32, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_1, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_2, (SPRITE_PAL_YELLOW)

longsword_east_anim:
        .byte 2  ; length
                 ; X,   Y,                                   TileId, Sprite Behavior
        .lobytes  32,   0, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_1, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_2, (SPRITE_PAL_YELLOW)

longsword_south_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0,  32, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes   0,  16, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

longsword_west_anim:
        .byte 2  ; length
                 ; X,   Y,                                   TileId, Sprite Behavior
        .lobytes -32,   0, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes -16,   0, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

; Longswords have no special behavior; each directional strike sets up a common anim table
.proc longsword_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_1
        st16 WeaponAnimPtr, longsword_north_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_1
        st16 WeaponAnimPtr, longsword_east_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_LONGSWORD_LONGSWORD_NORTH_1
        st16 WeaponAnimPtr, longsword_south_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_LONGSWORD_LONGSWORD_EAST_1
        st16 WeaponAnimPtr, longsword_west_anim
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; Charged Longswords hit a 2x3 area in front of the player:
; [ ][ ][ ][ ][ ][ ]
; [ ][*][*][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

longsword_charge:
        .byte $06 ; Length
        ; behavior tables
        .word longsword_charge_north, longsword_charge_east, longsword_charge_south, longsword_charge_west
        ; animation routines
        .word longsword_charge_init_north, longsword_charge_init_east, longsword_charge_init_south, longsword_charge_init_west

longsword_charge_north:
        ;         X,  Y, Behavior
        .lobytes -1, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -1, (WEAPON_CANCEL_MOVEMENT)

longsword_charge_east:
        ;         X,  Y, Behavior
        .lobytes  2, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  1, (WEAPON_CANCEL_MOVEMENT)

longsword_charge_south:
        ;         X,  Y, Behavior
        .lobytes  1,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  1, (WEAPON_CANCEL_MOVEMENT)

longsword_charge_west:
        ;         X,  Y, Behavior
        .lobytes -2,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1, -1, (WEAPON_CANCEL_MOVEMENT)

longsword_charge_anim_north:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)

longsword_charge_anim_east:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

longsword_charge_anim_south:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

longsword_charge_anim_west:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

.proc longsword_charge_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, longsword_charge_anim_north
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_charge_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, longsword_charge_anim_east
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_charge_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, longsword_charge_anim_south
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc longsword_charge_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, longsword_charge_anim_west
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; Spears are almost identical to longswords, except they can only target one enemy
; at a time, prioritizing the enemy closest to the player
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

; Note: on their own, spears aren't unique enough from longswords to necessarily be
; worth including. Ideally they would confer some other benefit, like being able
; to use a shield or something?

spear:
        .byte $02 ; Length
        ; behavior tables
        .word spear_north, spear_east, spear_south, spear_west
        ; animation routines
        .word spear_init_north, spear_init_east, spear_init_south, spear_init_west

spear_north:
        ;         X,  Y, Behavior
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_east:
        ;         X,  Y, Behavior
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_south:
        ;         X,  Y, Behavior
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_west:
        ;         X,  Y, Behavior
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_north_distant_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0, -32, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_2, (SPRITE_PAL_YELLOW)

spear_north_near_anim:
        .byte 1  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0, -16, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1, (SPRITE_PAL_YELLOW)

spear_east_distant_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes  32,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_2, (SPRITE_PAL_YELLOW)

spear_east_near_anim:
        .byte 1  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes  16,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1, (SPRITE_PAL_YELLOW)

spear_south_distant_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0,  32, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes   0,  16, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

spear_south_near_anim:
        .byte 1  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes   0,  16, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

spear_west_distant_anim:
        .byte 2  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes -32,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)
        .lobytes -16,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_2, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

spear_west_near_anim:
        .byte 1  ; length
                 ; X,   Y,                         TileId, Sprite Behavior
        .lobytes -16,   0, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1, (SPRITE_PAL_YELLOW | SPRITE_VERT_FLIP | SPRITE_HORIZ_FLIP)

; Spears select from one of two animation tables, depending on whether the near
; or far target was struck
.proc spear_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1
        st16 WeaponDrawFunc, weapon_update_none
        lda WeaponSingleTargetIndex
        beq near
distant:
        st16 WeaponAnimPtr, spear_north_distant_anim
        jmp weapon_init_common
near:
        st16 WeaponAnimPtr, spear_north_near_anim
        jmp weapon_init_common
.endproc

.proc spear_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1
        st16 WeaponDrawFunc, weapon_update_none
        lda WeaponSingleTargetIndex
        beq near
distant:
        st16 WeaponAnimPtr, spear_east_distant_anim
        jmp weapon_init_common
near:
        st16 WeaponAnimPtr, spear_east_near_anim
        jmp weapon_init_common
.endproc

.proc spear_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPEAR_SPEAR_NORTH_1
        st16 WeaponDrawFunc, weapon_update_none
        lda WeaponSingleTargetIndex
        beq near
distant:
        st16 WeaponAnimPtr, spear_south_distant_anim
        jmp weapon_init_common
near:
        st16 WeaponAnimPtr, spear_south_near_anim
        jmp weapon_init_common
.endproc

.proc spear_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPEAR_SPEAR_EAST_1
        st16 WeaponDrawFunc, weapon_update_none
        lda WeaponSingleTargetIndex
        beq near
distant:
        st16 WeaponAnimPtr, spear_west_distant_anim
        jmp weapon_init_common
near:
        st16 WeaponAnimPtr, spear_west_near_anim
        jmp weapon_init_common
.endproc

; Charged Spears hit a 3x1 area in front of the player, and they smack it hard
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][*][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

spear_charge:
        .byte $03 ; Length
        ; behavior tables
        .word spear_charge_north, spear_charge_east, spear_charge_south, spear_charge_west
        ; animation routines
        .word spear_charge_init_north, spear_charge_init_east, spear_charge_init_south, spear_charge_init_west

spear_charge_north:
        ;         X,  Y, Behavior
        .lobytes  0, -3, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0, -1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)

spear_charge_east:
        ;         X,  Y, Behavior
        .lobytes  3,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)

spear_charge_south:
        ;         X,  Y, Behavior
        .lobytes  0,  3, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes  0,  1, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)

spear_charge_west:
        ;         X,  Y, Behavior
        .lobytes -3,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)
        .lobytes -1,  0, (WEAPON_CANCEL_MOVEMENT | WEAPON_STRONG_HIT)

spear_charge_anim_north:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes   0, -48, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)

spear_charge_anim_east:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  48,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

spear_charge_anim_south:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes   0,  48, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)

spear_charge_anim_west:
        .byte 3  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -48,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

.proc spear_charge_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, spear_charge_anim_north
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc spear_charge_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, spear_charge_anim_east
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc spear_charge_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, spear_charge_anim_south
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc spear_charge_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, spear_charge_anim_west
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc


; Flails have the widest attack pattern, hit a single enemy, and mostly
; do not block movement for the player:
; [ ][1#][ ][ ][ ][ ]
; [ ][3#][ ][ ][ ][ ]
; [P][5*][ ][ ][ ][ ]
; [ ][4#][ ][ ][ ][ ]
; [ ][2#][ ][ ][ ][ ]
; (number = priority, # = player movement allowed, * = player movement blocked)

; Due to permitting player movement, flails encourage keeping distance from enemies
; and attempting to attack them with lateral movement. One can safely attack a single
; enemy directly in front, but if there is an enemy to the side it will take the hit,
; allowing the player to "bonk" into the enemy ahead and take damage. This makes close
; range combat with a flail especially risky.

flail:
        .byte $05 ; Length
        ; behavior tables
        .word flail_north, flail_east, flail_south, flail_west
        ; animation routines
        .word flail_init_north, flail_init_east, flail_init_south, flail_init_west

flail_north:
        ;         X,  Y, Behavior
        .lobytes -2, -1, (WEAPON_SINGLE_TARGET)
        .lobytes  2, -1, (WEAPON_SINGLE_TARGET)
        .lobytes -1, -1, (WEAPON_SINGLE_TARGET)
        .lobytes  1, -1, (WEAPON_SINGLE_TARGET)
        .lobytes  0, -1, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_east:
        ;         X,  Y, Behavior
        .lobytes  1, -2, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  2, (WEAPON_SINGLE_TARGET)
        .lobytes  1, -1, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  1, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  0, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_south:
        ;         X,  Y, Behavior
        .lobytes  2,  1, (WEAPON_SINGLE_TARGET)
        .lobytes -2,  1, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  1, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  1, (WEAPON_SINGLE_TARGET)
        .lobytes  0,  1, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  2, (WEAPON_SINGLE_TARGET)
        .lobytes -1, -2, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  1, (WEAPON_SINGLE_TARGET)
        .lobytes -1, -1, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  0, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

; === NORTH ===
flail_anim_north_long_cw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16, -32, SPRITE_WEAPON_FLAIL_NORTH_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes   0, -32, SPRITE_WEAPON_FLAIL_NORTH_HEAD_CW,  (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_FLAIL_NORTH_CHAIN_CW, (SPRITE_PAL_YELLOW)

flail_anim_north_long_ccw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16, -32, SPRITE_WEAPON_FLAIL_NORTH_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes   0, -32, SPRITE_WEAPON_FLAIL_NORTH_HEAD_CCW,  (SPRITE_PAL_YELLOW)
        .lobytes   0, -16, SPRITE_WEAPON_FLAIL_NORTH_CHAIN_CCW, (SPRITE_PAL_YELLOW)

flail_anim_north_short_cw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16, -16, SPRITE_WEAPON_FLAIL_NORTH_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes   0, -16, SPRITE_WEAPON_FLAIL_NORTH_HEAD_CW,  (SPRITE_PAL_YELLOW)

flail_anim_north_short_ccw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16, -16, SPRITE_WEAPON_FLAIL_NORTH_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes   0, -16, SPRITE_WEAPON_FLAIL_NORTH_HEAD_CCW,  (SPRITE_PAL_YELLOW)        

flail_anim_north_bash:
        .byte 1  ; length
                 ; X,   Y,                               TileId,     Sprite Behavior
        .lobytes   0, -16, SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN,  (SPRITE_PAL_YELLOW) 

; === EAST ===
flail_anim_east_long_cw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  32, -16, SPRITE_WEAPON_FLAIL_EAST_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes  32,   0, SPRITE_WEAPON_FLAIL_EAST_HEAD_CW,  (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_FLAIL_EAST_CHAIN_CW, (SPRITE_PAL_YELLOW)

flail_anim_east_long_ccw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  32,  16, SPRITE_WEAPON_FLAIL_EAST_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes  32,   0, SPRITE_WEAPON_FLAIL_EAST_HEAD_CCW,  (SPRITE_PAL_YELLOW)
        .lobytes  16,   0, SPRITE_WEAPON_FLAIL_EAST_CHAIN_CCW, (SPRITE_PAL_YELLOW)

flail_anim_east_short_cw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16, -16, SPRITE_WEAPON_FLAIL_EAST_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes  16,   0, SPRITE_WEAPON_FLAIL_EAST_HEAD_CW,  (SPRITE_PAL_YELLOW)

flail_anim_east_short_ccw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16,  16, SPRITE_WEAPON_FLAIL_EAST_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes  16,   0, SPRITE_WEAPON_FLAIL_EAST_HEAD_CCW,  (SPRITE_PAL_YELLOW)

flail_anim_east_bash:
        .byte 1  ; length
                 ; X,   Y,                               TileId,     Sprite Behavior
        .lobytes  16,   0, SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN,  (SPRITE_PAL_YELLOW) 

; === SOUTH ===
flail_anim_south_long_cw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16,  32, SPRITE_WEAPON_FLAIL_SOUTH_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes   0,  32, SPRITE_WEAPON_FLAIL_SOUTH_HEAD_CW,  (SPRITE_PAL_YELLOW)
        .lobytes   0,  16, SPRITE_WEAPON_FLAIL_SOUTH_CHAIN_CW, (SPRITE_PAL_YELLOW)

flail_anim_south_long_ccw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16,  32, SPRITE_WEAPON_FLAIL_SOUTH_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes   0,  32, SPRITE_WEAPON_FLAIL_SOUTH_HEAD_CCW,  (SPRITE_PAL_YELLOW)
        .lobytes   0,  16, SPRITE_WEAPON_FLAIL_SOUTH_CHAIN_CCW, (SPRITE_PAL_YELLOW)

flail_anim_south_short_cw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes  16,  16, SPRITE_WEAPON_FLAIL_SOUTH_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes   0,  16, SPRITE_WEAPON_FLAIL_SOUTH_HEAD_CW,  (SPRITE_PAL_YELLOW)        

flail_anim_south_short_ccw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16,  16, SPRITE_WEAPON_FLAIL_SOUTH_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes   0,  16, SPRITE_WEAPON_FLAIL_SOUTH_HEAD_CCW,  (SPRITE_PAL_YELLOW)

flail_anim_south_bash:
        .byte 1  ; length
                 ; X,   Y,                               TileId,     Sprite Behavior
        .lobytes   0,  16, SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN,  (SPRITE_PAL_YELLOW) 

; === WEST ===
flail_anim_west_long_cw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -32,  16, SPRITE_WEAPON_FLAIL_WEST_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes -32,   0, SPRITE_WEAPON_FLAIL_WEST_HEAD_CW,  (SPRITE_PAL_YELLOW)
        .lobytes -16,   0, SPRITE_WEAPON_FLAIL_WEST_CHAIN_CW, (SPRITE_PAL_YELLOW)

flail_anim_west_long_ccw:
        .byte 3  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -32, -16, SPRITE_WEAPON_FLAIL_WEST_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes -32,   0, SPRITE_WEAPON_FLAIL_WEST_HEAD_CCW,  (SPRITE_PAL_YELLOW)
        .lobytes -16,   0, SPRITE_WEAPON_FLAIL_WEST_CHAIN_CCW, (SPRITE_PAL_YELLOW)

flail_anim_west_short_cw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16,  16, SPRITE_WEAPON_FLAIL_WEST_TRAIL_CW, (SPRITE_PAL_YELLOW)         
        .lobytes -16,   0, SPRITE_WEAPON_FLAIL_WEST_HEAD_CW,  (SPRITE_PAL_YELLOW)

flail_anim_west_short_ccw:
        .byte 2  ; length
                 ; X,   Y,                             TileId,     Sprite Behavior
        .lobytes -16, -16, SPRITE_WEAPON_FLAIL_WEST_TRAIL_CCW, (SPRITE_PAL_YELLOW)         
        .lobytes -16,   0, SPRITE_WEAPON_FLAIL_WEST_HEAD_CCW,  (SPRITE_PAL_YELLOW)

flail_anim_west_bash:
        .byte 1  ; length
                 ; X,   Y,                               TileId,     Sprite Behavior
        .lobytes -16,   0, SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN,  (SPRITE_PAL_YELLOW) 

; Flails are the most complex by far, choosing from one of 5 animation tables
; depending on which tile was struck.

north_anim_lut:
        .word flail_anim_west_long_cw
        .byte >SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN, 0
        .word flail_anim_east_long_ccw
        .byte >SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN, 0
        .word flail_anim_west_short_cw
        .byte >SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN, 0
        .word flail_anim_east_short_ccw
        .byte >SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN, 0
        .word flail_anim_north_bash
        .byte >SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN, 0

east_anim_lut:
        .word flail_anim_north_long_cw
        .byte >SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN, 0
        .word flail_anim_south_long_ccw
        .byte >SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN, 0
        .word flail_anim_north_short_cw
        .byte >SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN, 0
        .word flail_anim_south_short_ccw
        .byte >SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN, 0
        .word flail_anim_east_bash
        .byte >SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN, 0

south_anim_lut:
        .word flail_anim_east_long_cw
        .byte >SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN, 0
        .word flail_anim_west_long_ccw
        .byte >SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN, 0
        .word flail_anim_east_short_cw
        .byte >SPRITE_WEAPON_FLAIL_EAST_HEAD_PLAIN, 0
        .word flail_anim_west_short_ccw
        .byte >SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN, 0
        .word flail_anim_south_bash
        .byte >SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN, 0

west_anim_lut:
        .word flail_anim_south_long_cw
        .byte >SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN, 0
        .word flail_anim_north_long_ccw
        .byte >SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN, 0
        .word flail_anim_south_short_cw
        .byte >SPRITE_WEAPON_FLAIL_SOUTH_HEAD_PLAIN, 0
        .word flail_anim_north_short_ccw
        .byte >SPRITE_WEAPON_FLAIL_NORTH_HEAD_PLAIN, 0
        .word flail_anim_west_bash
        .byte >SPRITE_WEAPON_FLAIL_WEST_HEAD_PLAIN, 0


.proc flail_init_north
SpriteBank := R0
        st16 WeaponDrawFunc, weapon_update_track_player
        lda WeaponSingleTargetIndex
        asl
        asl
        tax
        lda north_anim_lut+0, x
        sta WeaponAnimPtr+0
        lda north_anim_lut+1, x
        sta WeaponAnimPtr+1
        lda north_anim_lut+2, x
        sta SPRITE_BANK_WEAPON
        jmp weapon_init_common
.endproc

.proc flail_init_east
        st16 WeaponDrawFunc, weapon_update_track_player
        lda WeaponSingleTargetIndex
        asl
        asl
        tax
        lda east_anim_lut+0, x
        sta WeaponAnimPtr+0
        lda east_anim_lut+1, x
        sta WeaponAnimPtr+1
        lda east_anim_lut+2, x
        sta SPRITE_BANK_WEAPON
        jmp weapon_init_common
.endproc

.proc flail_init_south
        st16 WeaponDrawFunc, weapon_update_track_player
        lda WeaponSingleTargetIndex
        asl
        asl
        tax
        lda south_anim_lut+0, x
        sta WeaponAnimPtr+0
        lda south_anim_lut+1, x
        sta WeaponAnimPtr+1
        lda south_anim_lut+2, x
        sta SPRITE_BANK_WEAPON
        jmp weapon_init_common
.endproc

.proc flail_init_west
        st16 WeaponDrawFunc, weapon_update_track_player
        lda WeaponSingleTargetIndex
        asl
        asl
        tax
        lda west_anim_lut+0, x
        sta WeaponAnimPtr+0
        lda west_anim_lut+1, x
        sta WeaponAnimPtr+1
        lda west_anim_lut+2, x
        sta SPRITE_BANK_WEAPON
        jmp weapon_init_common
.endproc

; Charged Flails hit two separate 3x1 areas to the sides of the player:
; [*][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][P][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [*][*][*][ ][ ][ ]

flail_charge:
        .byte $06 ; Length
        ; behavior tables
        .word flail_charge_north, flail_charge_east, flail_charge_south, flail_charge_west
        ; animation routines
        .word flail_charge_init_north, flail_charge_init_east, flail_charge_init_south, flail_charge_init_west

flail_charge_north:
        ;         X,  Y, Behavior
        .lobytes -2,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  1, (WEAPON_CANCEL_MOVEMENT)

flail_charge_east:
        ;         X,  Y, Behavior
        .lobytes -1, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  2, (WEAPON_CANCEL_MOVEMENT)

flail_charge_south:
        ;         X,  Y, Behavior
        .lobytes  2, -1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  1, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  0, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2, -1, (WEAPON_CANCEL_MOVEMENT)

flail_charge_west:
        ;         X,  Y, Behavior
        .lobytes  1,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -2, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -2, (WEAPON_CANCEL_MOVEMENT)

flail_charge_anim_north:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)

flail_charge_anim_east:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes -16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

flail_charge_anim_south:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32,  16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32,   0, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -32, -16, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

flail_charge_anim_west:
        .byte 6  ; length
                 ; X,   Y,                        TileId, Sprite Behavior
        .lobytes  16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16,  32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes -16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes   0, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW)
        .lobytes  16, -32, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER, (SPRITE_PAL_YELLOW) 

.proc flail_charge_init_north
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, flail_charge_anim_north
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc flail_charge_init_east
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, flail_charge_anim_east
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc flail_charge_init_south
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, flail_charge_anim_south
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

.proc flail_charge_init_west
        set_sprite_bank SPRITE_BANK_WEAPON, SPRITE_WEAPON_SPELLCASTING_PLACEHOLDER
        st16 WeaponAnimPtr, flail_charge_anim_west
        st16 WeaponDrawFunc, weapon_update_none
        jmp weapon_init_common
.endproc

; indexed by aaabbb, composed of crystal indices, where 0 is "no crystal"
weapon_dmg_offset_lut:
        .byte 0  ; none     + none
        .byte 10 ; earth    + none
        .byte 20 ; ice      + none
        .byte 30 ; air      + none
        .byte 40 ; fire     + none
        .byte 0  ; oob      + none (nonsense)
        .byte 0  ; oob      + none (nonsense)
        .byte 0  ; oob      + none (nonsense)
        
        .byte 0   ; none     + earth (nonsense)
        .byte 50  ; earth    + earth
        .byte 100 ; ice      + earth
        .byte 90  ; air      + earth
        .byte 110 ; fire     + earth
        .byte 0   ; oob      + earth (nonsense)
        .byte 0   ; oob      + earth (nonsense)
        .byte 0   ; oob      + earth (nonsense)

        .byte 0   ; none     + ice (nonsense)
        .byte 100 ; earth    + ice
        .byte 60  ; ice      + ice
        .byte 120 ; air      + ice
        .byte 90  ; fire     + ice
        .byte 0   ; oob      + ice (nonsense)
        .byte 0   ; oob      + ice (nonsense)
        .byte 0   ; oob      + ice (nonsense)

        .byte 0   ; none     + air (nonsense)
        .byte 90  ; earth    + air
        .byte 120 ; ice      + air
        .byte 70  ; air      + air
        .byte 130 ; fire     + air
        .byte 0   ; oob      + air (nonsense)
        .byte 0   ; oob      + air (nonsense)
        .byte 0   ; oob      + air (nonsense)

        .byte 0   ; none     + fire (nonsense)
        .byte 110 ; earth    + fire
        .byte 90  ; ice      + fire
        .byte 130 ; air      + fire
        .byte 80  ; fire     + fire
        .byte 0   ; oob      + fire (nonsense)
        .byte 0   ; oob      + fire (nonsense)
        .byte 0   ; oob      + fire (nonsense)

weapon_dmg_table:
        ; ===== Base / Non-upgraded =====
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     1,   1,   1,    1 ; regular hit
        .byte             2,     2,   2,   2,    2 ; strong hit ; shouldn't generally be used?
        ; ===== Single Upgrade (second slot empty) =====
        ; EARTH
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     1,   1,   2,    1 ; regular hit
        .byte             2,     1,   2,   3,    2 ; strong hit
        ; ICE
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     1,   1,   1,    2 ; regular hit
        .byte             2,     2,   1,   2,    3 ; strong hit
        ; AIR
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     2,   1,   1,    1 ; regular hit
        .byte             2,     3,   2,   1,    2 ; strong hit
        ; FIRE
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     1,   2,   1,    1 ; regular hit
        .byte             2,     2,   3,   2,    1 ; strong hit
        ; ===== Two Matched Crystals - Strong Affinity =====
        ; EARTH+EARTH
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     1,   2,   4,    2 ; regular hit
        .byte             3,     2,   3,   4,    3 ; strong hit
        ; ICE+ICE
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     2,   1,   2,    4 ; regular hit
        .byte             3,     3,   2,   3,    4 ; strong hit
        ; AIR+AIR
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     4,   2,   1,    2 ; regular hit
        .byte             3,     4,   3,   2,    3 ; strong hit
        ; FIRE+FIRE
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     2,   4,   2,    1 ; regular hit
        .byte             3,     3,   4,   3,    2 ; strong hit
        ; ===== Two Opposed Crystals - Neutral Affinity =====
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     2,   2,   2,    2 ; regular hit
        .byte             3,     3,   3,   3,    3 ; strong hit

        ; EARTH+ICE
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     2,   3,   2,    3 ; regular hit
        .byte             3,     2,   4,   2,    4 ; strong hit
        ; EARTH+FIRE
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     2,   3,   3,    2 ; regular hit
        .byte             3,     2,   4,   4,    2 ; strong hit
        ; ICE+AIR
        ;     non-elemental, earth, ice, air, fire
        .byte             2,     3,   2,   2,    3 ; regular hit
        .byte             3,     4,   2,   2,    4 ; strong hit
        ; AIR+FIRE
        ;     non-elemental, earth, ice, air, fire
        .byte             1,     3,   3,   2,    2 ; regular hit
        .byte             1,     4,   4,   2,    2 ; strong hit

; This function works out the weak/strong dmg amounts based on the current
; slotted upgrade crystals, and caches those for quick access by enemy
; damage routines. Call this any time the current crystals change for any reason.
.proc FAR_calculate_weapon_damage
AffinityIndex := R20
        lda #0
        sta AffinityIndex

        lda current_save + SaveFile::PlayerWeaponUpgradeSlot1
        cmp #ITEM_NONE
        beq no_first_slot
        sec
        sbc #ITEM_UPGRADE_EARTH - 1
        and #%111 ; safety
        sta AffinityIndex
no_first_slot:

        lda current_save + SaveFile::PlayerWeaponUpgradeSlot2
        cmp #ITEM_NONE
        beq no_second_slot
        sec
        sbc #ITEM_UPGRADE_EARTH - 1
        and #%111 ; safety
        .repeat 3
        asl
        .endrepeat
        ora AffinityIndex
        sta AffinityIndex
no_second_slot:

        ; Now copy and cache, etc. Straightforward from here
        ldx AffinityIndex
        lda weapon_dmg_offset_lut, x
        tax
        
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_WEAK + WEAPON_AFFINITY_OFFSET_NONE, x
        sta PlayerWeaponDmgWeak + WEAPON_AFFINITY_OFFSET_NONE
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_WEAK + WEAPON_AFFINITY_OFFSET_EARTH, x
        sta PlayerWeaponDmgWeak + WEAPON_AFFINITY_OFFSET_EARTH
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_WEAK + WEAPON_AFFINITY_OFFSET_ICE, x
        sta PlayerWeaponDmgWeak + WEAPON_AFFINITY_OFFSET_ICE
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_WEAK + WEAPON_AFFINITY_OFFSET_AIR, x
        sta PlayerWeaponDmgWeak + WEAPON_AFFINITY_OFFSET_AIR
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_WEAK + WEAPON_AFFINITY_OFFSET_FIRE, x
        sta PlayerWeaponDmgWeak + WEAPON_AFFINITY_OFFSET_FIRE

        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_STRONG + WEAPON_AFFINITY_OFFSET_NONE, x
        sta PlayerWeaponDmgStrong + WEAPON_AFFINITY_OFFSET_NONE
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_STRONG + WEAPON_AFFINITY_OFFSET_EARTH, x
        sta PlayerWeaponDmgStrong + WEAPON_AFFINITY_OFFSET_EARTH
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_STRONG + WEAPON_AFFINITY_OFFSET_ICE, x
        sta PlayerWeaponDmgStrong + WEAPON_AFFINITY_OFFSET_ICE
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_STRONG + WEAPON_AFFINITY_OFFSET_AIR, x
        sta PlayerWeaponDmgStrong + WEAPON_AFFINITY_OFFSET_AIR
        lda weapon_dmg_table + WEAPON_STRENGTH_OFFSET_STRONG + WEAPON_AFFINITY_OFFSET_FIRE, x
        sta PlayerWeaponDmgStrong + WEAPON_AFFINITY_OFFSET_FIRE

        ; et voila!
        rts
.endproc