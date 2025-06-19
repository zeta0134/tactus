
        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "battlefield.inc"
        .include "beat_tracker.inc"
        .include "bombs.inc"
        .include "dialog.inc"
        .include "debug.inc"
        .include "dynamic_palette.inc"
        .include "enemies.inc"
        .include "far_call.inc"
        .include "hud.inc"
        .include "hearts.inc"
        .include "input.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "bhop/longbranch.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "player_distance.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "raster_table.inc"
        .include "saves.inc"
        .include "settings.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "torchlight.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.zeropage

FxTileId: .res 1
SfxTileId: .res 1

PlayerZonePtr: .res 2

WeaponAnimPtr: .res 2

.segment "RAM"

SpellDefeatsEnemy: .res 1
DeferLootProcessing: .res 1

WeaponDrawFunc: .res 2

DestinationZonePtr: .res 2

PlayerState: .res 1
PlayerBeatsInThisState: .res 1

PlayerBombCount: .res 1

PlayerSpriteIndex: .res 1
PlayerRow: .res 1
PlayerCol: .res 1

PlayerSquare: .res 1

PlayerWarpEjectCol: .res 1
PlayerWarpEjectRow: .res 1

PlayerNextDirection: .res 1
PlayerHeldDirection: .res 1

; full words, to do a smooth little lerp thing
PlayerCurrentX: .res 2
PlayerCurrentY: .res 2
PlayerTargetX: .res 2
PlayerTargetY: .res 2

PlayerJumpHeightPos: .res 1
PlayerAnimationTable: .res 1
PlayerMovementBlocked: .res 1
PlayerTorchlightRadius: .res 1

PlayerKeys: .res 1

PlayerRoomIndex: .res 1

PlayerIdleBeats: .res 1

; Score Multipliers
PlayerCombo: .res 1
PlayerChain: .res 1
PlayerChainGrace: .res 1

PlayerNavState: .res 1

PlayerPreviousSuccessfulDirection: .res 1

PlayerIntendsToPause: .res 1
PlayerIsPaused: .res 1

PlayerIntendsToWait: .res 1
PlayerIntendsToBomb: .res 1
PlayerIntendsToCast: .res 1

PlayerActiveDialogSquare: .res 1
PlayerPassiveDialogSquare: .res 1

PlayerTookDamageThisBeat: .res 1
PlayerDamageAnimCounter: .res 1
PlayerIncomingDamageDirection: .res 1

PlayerHeldBombIndex: .res 1

PlayerLingeringStatusType: .res 1
PlayerLingeringStatusDuration: .res 1 ; in beats
PlayerLingeringStatusFrame: .res 1
PlayerTappedIce: .res 1

WeaponSingleTargetIndex: .res 1

WarpStability: .res 1
MusicalWarpStabilityCooldown: .res 1

PlayerWeaponUpgradeSlot1: .res 1
PlayerWeaponUpgradeSlot2: .res 1

BackupWeaponUpgradeSlot1: .res 1
BackupWeaponUpgradeSlot2: .res 1
BackupWeaponUpgradeRoomIndex: .res 1
BackupWeaponUpgradeRow: .res 1
BackupWeaponUpgradeCol: .res 1

PlayerWeaponDmgWeak: .res 5
PlayerWeaponDmgStrong: .res 5

PlayerResistances: .res 1
PlayerProtections: .res 1
PlayerImmunities: .res 1
PlayerWeaknesses: .res 1
PlayerAbsorbtions: .res 1

PlayerIncomingDmgAmount: .res 1
PlayerIncomingDmgElement: .res 1

PlayerIncomingStatusDuration: .res 1
PlayerIncomingStatusType: .res 1

; miscellaneous bonus state for items
PlayerNinjaFootwrapsCooldown: .res 1

; some light providing items grant a persistent torchlight bonus. the details
; vary, but this byte is how they track that bonus. we reset this to 0 between
; floors as a courtesy. it is not persisted in the save file.
PlayerTorchlightBonus: .res 1

.segment "PRGFIXED_E000"

; For rapidly computing the tile row
row_number_to_tile_index_lut:
        .repeat ::BATTLEFIELD_HEIGHT, i
        .byte (::BATTLEFIELD_WIDTH * i)
        .endrepeat

.segment "CODE_PLAYER_0"

JUMP_HEIGHT_END = 11
jump_height_table:
        .byte 10, 14, 11, 7, 2, 0, 0, 0, 0, 0, 0, 0

JUMP_ANIMATION_INDEX      = 0
JUMP_ANIMATION_MILD_INDEX = 11
player_anim_tile_table:
        ; Jump Animation: Regular Strength
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_3 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_3 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_2 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_1 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        ; Jump Animation: Mild Strength
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER_JUMP + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_2 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_02_PLAYER_SQUISH_1 + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)
        .byte <(SPRITE_PLAYER_01_PLAYER + SPRITE_OFFSET_PLAYER)

player_anim_bank_table:
        ; Jump Animation: Regular Strength
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_3
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_3
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_2
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_1
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER
        ; Jump Animation: Mild Strength
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_01_PLAYER_JUMP
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_2
        .byte >SPRITE_PLAYER_02_PLAYER_SQUISH_1
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER
        .byte >SPRITE_PLAYER_01_PLAYER


damage_table_north_x:
damage_table_south_x:
damage_table_east_y:
damage_table_west_y:
        .repeat 32
        .byte 0
        .endrepeat
damage_table_west_x:
damage_table_northwest_x:
damage_table_southwest_x:
damage_table_north_y:
damage_table_northeast_y:
damage_table_northwest_y:
        .byte 4, 3, <-4, <-3, 3, 2, <-3, <-2, 2, 1, <-2, <-1, 1, 1, <-1, <-1
        .repeat 16
        .byte 0
        .endrepeat
damage_table_east_x:
damage_table_northeast_x:
damage_table_southeast_x:
damage_table_south_y:
damage_table_southeast_y:
damage_table_southwest_y:
        .byte <-4, <-3, 4, 3, <-3, <-2, 3, 2, <-2, <-1, 2, 1, <-1, <-1, 1, 1
        .repeat 16
        .byte 0
        .endrepeat

damage_table_generic_x:
        ;       N       SE    W         NE        S     NW        E     SW
        .byte   0,   0, 4, 3, <-3, <-2,   3,   2, 0, 0, <-2, <-1, 1, 1, <-1, <-1
        .repeat 16
        .byte 0
        .endrepeat
damage_table_generic_y:
        .byte <-4, <-3, 4, 3,   0,   0, <-3, <-2, 2, 1, <-2, <-2, 0, 0,   1,   1
        .repeat 16
        .byte 0
        .endrepeat

damage_offsets_by_direction_lut:
        .addr damage_table_generic_x, damage_table_generic_y
        .addr damage_table_north_x, damage_table_north_y
        .addr damage_table_east_x, damage_table_east_y
        .addr damage_table_south_x, damage_table_south_y
        .addr damage_table_west_x, damage_table_west_y
        .addr damage_table_northeast_x, damage_table_northeast_y
        .addr damage_table_southeast_x, damage_table_southeast_y
        .addr damage_table_northwest_x, damage_table_northwest_y
        .addr damage_table_southwest_x, damage_table_southwest_y

ice_pick_offsets_x:
        .byte <-2, <-2, 2, 2, <-1, <-1, 1, 1, <-0, <-0, 0, 0, <-0, <-0, 0, 0
        ; would repeat 16, just fall through to the other table
ice_pick_offsets_y:
        .repeat 32
        .byte 0
        .endrepeat

.segment "CODE_PLAYER_1"

.proc FAR_init_player
NewHeartType := R0
HealingAmount := R0
MetaSpriteIndex := R0
HeartCount := R2
        st16 WeaponDrawFunc, weapon_update_none

        ; spawn in the player sprite
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        jeq sprite_failed
        stx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #0 ; irrelevant
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #$FF ; intentionally offscreen
        sta sprite_table + MetaSpriteState::PositionY, x
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable

        ; For now, init the player to position 6, 6 (for no particular reason)
        lda #6
        sta PlayerRow
        sta PlayerCol
        far_call FAR_set_player_target_coordinates
        far_call FAR_apply_target_coordinates_immediately

        ; Initialize us to the *end* of the jump height table; this is its resting state
        lda #JUMP_HEIGHT_END
        sta PlayerJumpHeightPos

        lda #PLAYER_BASE_TORCHLIGHT
        sta PlayerTorchlightRadius

        lda #0
        sta PlayerKeys
        sta PlayerRoomIndex

        lda #0
        sta PlayerIdleBeats

        lda #0
        sta PlayerCombo
        sta PlayerChain
        sta PlayerChainGrace

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause
        sta PlayerNextDirection
        sta PlayerHeldDirection

        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter

        lda #$FF
        sta PlayerHeldBombIndex

        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState

        lda #0
        sta DeferLootProcessing
        sta SpellDefeatsEnemy

        lda #30
        sta WarpStability
        lda #0
        sta MusicalWarpStabilityCooldown

        lda #0
        sta PlayerNinjaFootwrapsCooldown

        rts

sprite_failed:
        ; what? this should never happen...
        rts
.endproc

.proc FAR_init_player_inventory_new_game
NewHeartType := R0
HealingAmount := R0
HeartCount := R2
        ; TODO: This really ought to be an in-game option. File it under
        ; assist mode or whatever.

        ; TODO: We might want a special "return to HUD" option for players
        ; that win the game? Or win a specific zone, etc. I guess we're still
        ; not really sure how weapon obelisks are going to work.
.if ::DEBUG_GOD_MODE
        ; The player should start with whatever Zeta likes        
        lda #ITEM_DAGGER_L1
        sta current_save + SaveFile::PlayerEquipmentWeapon
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentTorch
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentArmor
        lda #ITEM_NINJA_FOOTWRAPS
        sta current_save + SaveFile::PlayerEquipmentBoots
        lda #ITEM_AMULET_OF_YENDOR
        sta current_save + SaveFile::PlayerEquipmentAccessory
        lda #ITEM_BOMB_STANDARD
        sta current_save + SaveFile::PlayerEquipmentBombs
        lda #ITEM_SPELL_AIR
        sta current_save + SaveFile::PlayerEquipmentSpell

        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot1
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot2

        lda #99
        sta current_save + SaveFile::PlayerBombCount

        far_call FAR_initialize_hearts_for_game
        
        ; All the heart types, yes!
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart
        lda #HEART_TYPE_TEMPORARY
        sta NewHeartType
        far_call FAR_add_heart

        ; Heal the player to full! (regular hearts start empty)
        lda #128
        sta HealingAmount
        far_call FAR_receive_healing

        st16 current_save + SaveFile::PlayerGold, 500
.else
        ; The player should start with a standard L1-DAGGER
        lda #PLAYER_NORMAL_WEAPON
        sta current_save + SaveFile::PlayerEquipmentWeapon
        lda #PLAYER_NORMAL_LIGHT
        sta current_save + SaveFile::PlayerEquipmentTorch
        lda #PLAYER_NORMAL_ARMOR
        sta current_save + SaveFile::PlayerEquipmentArmor
        lda #PLAYER_NORMAL_BOOTS
        sta current_save + SaveFile::PlayerEquipmentBoots
        lda #PLAYER_NORMAL_ACCESSORY
        sta current_save + SaveFile::PlayerEquipmentAccessory
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentBombs
        sta current_save + SaveFile::PlayerEquipmentSpell

        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot1
        sta current_save + SaveFile::PlayerWeaponUpgradeSlot2

        ; 2 regular hearts makes the starting player *quite* squishy.
        ; that's the point!
        far_call FAR_initialize_hearts_for_game

        lda #3
        sta HeartCount

heart_loop:
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart
        dec HeartCount
        bne heart_loop

        ; Heal the player to full! (regular hearts start empty)
        lda #128
        sta HealingAmount
        far_call FAR_receive_healing

        st16 current_save + SaveFile::PlayerGold, 0

        lda #0
        sta current_save + SaveFile::PlayerBombCount
.endif

        rts
.endproc

.segment "CODE_PLAYER_0"

DAMAGE_ANIM_MAX = 30

NORMAL_PAL    = 0
DMG_LIGHT_PAL = 1
DMG_DARK_PAL  = 2

damage_flash_lut:
        ; three quick flashes
        .repeat 3
        .byte DMG_LIGHT_PAL
        .byte DMG_DARK_PAL
        .endrepeat
        ; now flash the player's normal palette with their dark palette
        ; for the remainder of this beat
        .repeat 16-3
        .byte NORMAL_PAL
        .byte DMG_DARK_PAL
        .endrepeat

; So things other than main gameplay can do this, mostly for
; the title screen and eventual save screen, etc etc
; TODO: completely rethink this in light of lingering effects and rhythm assist mode
.proc FAR_apply_player_palette
        lda PlayerTookDamageThisBeat
        beq normal_palette
        lda #1
        sta StagingObjPaletteDirty
        ldx PlayerDamageAnimCounter
        lda damage_flash_lut, x
        cmp #DMG_DARK_PAL
        beq dark_palette
        cmp #DMG_LIGHT_PAL
        beq light_palette
        ; fall through to normal pal
normal_palette:
        ; If we are in some lingering status other than invulnerability, call that status's update function instead
        lda PlayerLingeringStatusType
        beq draw_palette_normally
        cmp #PLAYER_STAUTS_INVULNERABLE
        beq draw_palette_normally
        jsr _draw_lingering_effect_palette
        rts
draw_palette_normally:
        ; If we are in rhythm assist mode, then do the flash thing
        lda current_save + SaveFile::OptionRhythmFlashPlayer
        bne apply_rhythm_assist
        lda player_palettes_phones+PLAYER_PALETTE_NORMAL
        sta PlayfieldObjPal0+0
        lda player_palettes_pajamas+PLAYER_PALETTE_NORMAL
        sta PlayfieldObjPal0+1
        lda player_palettes_pigment+PLAYER_PALETTE_NORMAL
        sta PlayfieldObjPal0+2
        rts
dark_palette:
        lda player_palettes_phones+PLAYER_PALETTE_DAMAGE_DARK
        sta PlayfieldObjPal0+0
        lda player_palettes_pajamas+PLAYER_PALETTE_DAMAGE_DARK
        sta PlayfieldObjPal0+1
        lda player_palettes_pigment+PLAYER_PALETTE_DAMAGE_DARK
        sta PlayfieldObjPal0+2
        rts
light_palette:
        lda player_palettes_phones+PLAYER_PALETTE_DAMAGE_LIGHT
        sta PlayfieldObjPal0+0
        lda player_palettes_pajamas+PLAYER_PALETTE_DAMAGE_LIGHT
        sta PlayfieldObjPal0+1
        lda player_palettes_pigment+PLAYER_PALETTE_DAMAGE_LIGHT
        sta PlayfieldObjPal0+2
        rts
apply_rhythm_assist:
        ; rhythm assist always uses the current tracked beat's animation frame, out of the
        ; 8 possible rows
        ldx TrackedMusicPos
        lda tracked_row_buffer, x
        tax
        lda player_palettes_phones+PLAYER_PALETTE_RHYTHM_ASSIST, x
        sta PlayfieldObjPal0+0
        lda player_palettes_pajamas+PLAYER_PALETTE_RHYTHM_ASSIST, x
        sta PlayfieldObjPal0+1
        lda player_palettes_pigment+PLAYER_PALETTE_RHYTHM_ASSIST, x
        sta PlayfieldObjPal0+2
        lda #1
        sta StagingObjPaletteDirty
        rts
.endproc

lingering_effect_palette_offset_lut:
        .byte PLAYER_PALETTE_RHYTHM_ASSIST ; not actually used, though... it could be?
        .byte PLAYER_PALETTE_POISONED
        .byte PLAYER_PALETTE_FROZEN
        .byte PLAYER_PALETTE_SHOCKED
        .byte PLAYER_PALETTE_BURNED
        .byte PLAYER_PALETTE_JUST_HEALED

.proc _draw_lingering_effect_palette
PaletteBase := R0
        ; If we got here, we aren't in a higher priority palette state (mostly damage), so we
        ; need to set up the lingering effect table and use that as our base. The timing
        ; will be different in normal and rhythm assist mode; all lingering effects are a little
        ; bit flashy with a long decay, and so we'll pulse them to the beat if requested. That'll
        ; offset the application of color a little bit, which we accept as a glitch.

        ; TODO: some of these states might have single-frame overrides? we still need to check for
        ; and apply those as necessary

        ldx PlayerLingeringStatusType
        cpx #PLAYER_STATUS_SHOCKED
        bne no_zap_zaps
check_for_zap_zaps:
        lda PlayerLingeringStatusFrame
        beq dark_zap
        cmp #1
        beq light_zap
        cmp #4
        beq dark_zap
        cmp #5
        beq light_zap
        jmp no_zap_zaps
dark_zap:
        lda #$00
        sta PlayfieldObjPal0+0
        sta PlayfieldObjPal0+1
        sta PlayfieldObjPal0+2
        lda #1
        sta StagingObjPaletteDirty
        rts
light_zap:
        lda #$50
        sta PlayfieldObjPal0+0
        sta PlayfieldObjPal0+1
        sta PlayfieldObjPal0+2
        lda #1
        sta StagingObjPaletteDirty
        rts
no_zap_zaps:
        lda lingering_effect_palette_offset_lut, x
        sta PaletteBase
        lda current_save + SaveFile::OptionRhythmFlashPlayer
        bne use_rhythm_assist_timing
use_standard_timing:
        ldx TrackedGameplayPos
        jmp timing_converge
use_rhythm_assist_timing:
        ldx TrackedMusicPos
timing_converge:
        lda tracked_row_buffer, x
        clc
        adc PaletteBase
        tax
        lda player_palettes_phones, x
        sta PlayfieldObjPal0+0
        lda player_palettes_pajamas, x
        sta PlayfieldObjPal0+1
        lda player_palettes_pigment, x
        sta PlayfieldObjPal0+2
        lda #1
        sta StagingObjPaletteDirty
        rts
.endproc

; Called once every frame
.proc FAR_draw_player
DamageOffsetPtrX := R0
DamageOffsetPtrY := R2

        ; Based on the player's chosen sprite index, update their base sprite colors
        near_call FAR_apply_player_palette

        ; For now, always lerp the player's current position to their target position
        jsr lerp_player_to_target_coordinates

        ; FOR NOW, just immediately draw the player based on their current position.
        ldx PlayerSpriteIndex
        lda PlayerCurrentX+1
        sta sprite_table + MetaSpriteState::PositionX, x
        lda PlayerCurrentY+1
        ; subtract the jump height (if there is one)
        ldy PlayerJumpHeightPos
        sec
        sbc jump_height_table, y
        sta sprite_table + MetaSpriteState::PositionY, x
        ; If we are currently playing a fancy animation, process that now
        lda PlayerAnimationTable
        cmp #$FF
        beq done_with_fancy_animations
        ; work out the index into the animation table; we reuse the jump height
        ; position counter here, and we'll keep those lengths in sync as we go
        clc 
        adc PlayerJumpHeightPos
        tay
        ; now use that to set the metasprite tile and player bank
        lda player_anim_tile_table, y
        sta sprite_table + MetaSpriteState::TileIndex, x
        lda player_anim_bank_table, y
        sta SPRITE_BANK_PLAYER
done_with_fancy_animations:
        ; Update the jump height position every frame
        lda PlayerJumpHeightPos
        cmp #JUMP_HEIGHT_END
        beq done_with_height
        inc PlayerJumpHeightPos
done_with_height:

        ; If we are invulnerable, and this is an odd frame, then
        ; override the height we just set and move this sprite offscreen instead
        lda PlayerLingeringStatusType
        cmp #PLAYER_STAUTS_INVULNERABLE
        bne not_invulnerable
        ; visually expire the flicker one beat early, to line up with the mechanical
        ; effect
        lda PlayerLingeringStatusDuration
        cmp #2
        bcc not_invulnerable
        ; okay, flicker only on odd frames please
        lda GameloopCounter
        and #%00000001
        beq not_invulnerable
        ldx PlayerSpriteIndex
        lda #$F8
        sta sprite_table + MetaSpriteState::PositionY, x
not_invulnerable:

        ; If we took damage this beat, apply that offset here
        lda PlayerTookDamageThisBeat
        beq done_with_damage_offset
        lda PlayerIncomingDamageDirection
        asl
        asl ; x4
        tay
        lda damage_offsets_by_direction_lut+0, y
        sta DamageOffsetPtrX+0
        lda damage_offsets_by_direction_lut+1, y
        sta DamageOffsetPtrX+1
        lda damage_offsets_by_direction_lut+2, y
        sta DamageOffsetPtrY+0
        lda damage_offsets_by_direction_lut+3, y
        sta DamageOffsetPtrY+1
        ldy PlayerDamageAnimCounter
        lda sprite_table + MetaSpriteState::PositionX, x
        clc
        adc (DamageOffsetPtrX), y
        sta sprite_table + MetaSpriteState::PositionX, x
        lda sprite_table + MetaSpriteState::PositionY, x
        clc
        adc (DamageOffsetPtrY), y
        sta sprite_table + MetaSpriteState::PositionY, x
done_with_damage_offset:
        ; If we're frozen, do the shake thing when the player inputs any direction
        lda PlayerTappedIce
        beq done_being_frozen
        ldy PlayerLingeringStatusFrame
        lda sprite_table + MetaSpriteState::PositionX, x
        clc
        adc ice_pick_offsets_x, y
        sta sprite_table + MetaSpriteState::PositionX, x
        lda sprite_table + MetaSpriteState::PositionY, x
        clc
        adc ice_pick_offsets_y, y
        sta sprite_table + MetaSpriteState::PositionY, x
done_being_frozen:

        ; Update the damage status every frame
        lda PlayerTookDamageThisBeat
        beq done_with_damage
        lda PlayerDamageAnimCounter
        cmp #DAMAGE_ANIM_MAX
        bcs done_with_damage
        inc PlayerDamageAnimCounter
done_with_damage:

        ; Update lingering status animations every frame
        lda PlayerLingeringStatusType
        beq done_with_lingering_status
        lda PlayerLingeringStatusFrame
        cmp #DAMAGE_ANIM_MAX ; sure, why not
        bcs done_with_lingering_status
        inc PlayerLingeringStatusFrame
done_with_lingering_status:

        ; Draw weapon effects every frame! Most weapons will spawn sprites only
        ; on their first frame, but some may have additional behavior
        far_call FAR_draw_weapon_effects

        perform_zpcm_inc
        rts
.endproc

player_horiz_offset_lut:
        .byte   1,   1,   2,   3,   4,   7,  10,  15,  21,  28,  37,  48,  61,  75,  92, 112
        .byte 132, 149, 163, 176, 187, 196, 203, 209, 214, 217, 220, 221, 222, 223, 223, 223
player_vert_offset_lut:
        .byte   1,   1,   1,   2,   3,   5,   7,  10,  14,  18,  24,  31,  39,  49,  60,  72
        .byte  84,  95, 105, 113, 120, 126, 130, 134, 137, 139, 141, 142, 143, 143, 143, 143

; Note: these apply directly to the sprite position, we'll call this every frame
; but only during transitions. We clean up the position properly later.
.proc correct_player_pos_during_left_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionX, y
        clc
        adc player_horiz_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionX, y
        rts
.endproc

.proc correct_player_pos_during_right_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionX, y
        sec
        sbc player_horiz_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionX, y
        rts
.endproc

.proc correct_player_pos_during_up_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionY, y
        clc
        adc player_vert_offset_lut, x
        cmp #224
        bcs player_too_high
        ; additional tomfoolery: if the player's Y position went
        ; negative, clamp it back to 0. we only care about a small range here
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
player_too_high:
        lda #0
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
.endproc

.proc correct_player_pos_during_down_slide
        ldx RasterEffectFrame
        ldy PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::PositionY, y
        sec
        sbc player_vert_offset_lut, x
        sta sprite_table + MetaSpriteState::PositionY, y
        rts
.endproc

.proc FAR_correct_player_pos_during_slide
        lda RoomTransitionType
        cmp #ROOM_TRANSITION_SLIDE_RIGHT
        beq correct_slide_right
        cmp #ROOM_TRANSITION_SLIDE_LEFT
        beq correct_slide_left
        cmp #ROOM_TRANSITION_SLIDE_DOWN
        beq correct_slide_down
        cmp #ROOM_TRANSITION_SLIDE_UP
        beq correct_slide_up
        ; What? How did we get here?
        rts
correct_slide_right:
        jsr correct_player_pos_during_right_slide
        rts
correct_slide_left:
        jsr correct_player_pos_during_left_slide
        rts
correct_slide_down:
        jsr correct_player_pos_during_down_slide
        rts
correct_slide_up:
        jsr correct_player_pos_during_up_slide
        rts
.endproc

.proc FAR_finalize_player_pos_after_slide
        near_call FAR_set_player_target_coordinates
        near_call FAR_apply_target_coordinates_immediately
        rts
.endproc

; Called once every frame, after input has been processed.
; Updates variables related to the desired direction and 
; whether a down press has occurred at all this frame

; Notable: Only one (1) button takes action on a given gameplay
; beat. There is a priority for simultaneous presses, but we should
; never leave the output of this function in a state that suggests
; multiple actions on the same beat. Absolutely not allowed, this
; constraint simplifies logic elsewhere. We can conditionally choose
; whether to recognize the button, but if we do recognize it, it cancels
; all the other possibilities when chosen.

.proc FAR_determine_player_intent
        ; The attempt to pause takes the highest priority, and if met,
        ; suppresses all other buttons
        lda #(KEY_START)
        bit ButtonsDown
        beq check_pause_state
        lda #1
        sta PlayerIntendsToPause
        lda #0
        sta PlayerNextDirection
        sta PlayerHeldDirection
        rts

        ; While actually paused, the only valid action is to attempt to unpause!
check_pause_state:
        lda PlayerIsPaused
        beq check_direction_release

        ; ... sortof. Check for a SELECT press here and, if found, advance the minimap
        ; theme. This lets the player tweak this during gameplay if they like.
        lda #KEY_SELECT
        bit ButtonsDown
        beq done_with_pause_inputs
        inc current_save + SaveFile::OptionMinimapTheme
        lda current_save + SaveFile::OptionMinimapTheme
        and #7
        sta current_save + SaveFile::OptionMinimapTheme
        lda #1
        sta HudMapDirty
        queue_sfx_pulse2 sfx_select_cursor

done_with_pause_inputs:
        rts

        ; If any button on the D-Pad is ever released, clear the hold action
        ; (other buttons do not have hold states, so we'll ignore them here)
check_direction_release:
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT)
        bit ButtonsUp
        beq check_action_buttons
        lda #0
        sta PlayerHeldDirection

check_action_buttons:
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT | KEY_SELECT | KEY_B  | KEY_A)
        bit ButtonsDown
        bne handle_button_press
        rts ; all done
handle_button_press:
        ; Only one button can take effect
        lda #0
        sta PlayerIntendsToPause

        ; If we are taking any action _other_ than SELECT, clear the held inputs.
        lda #(KEY_DOWN | KEY_UP | KEY_LEFT | KEY_RIGHT | KEY_B | KEY_A)
        bit ButtonsDown
        beq done_clearing_held_state
        lda #0
        sta PlayerHeldDirection
done_clearing_held_state:

        ; For now, the last button press we receive in a given beat
        ; will be the one that counts once we begin processing.
        ; TODO: detect if we receive an extra button press? we'd need 
        ; to detect the "all buttons released" state, cache that, and then
        ; check it when a new button down arrives. Ignoring this for now.
check_north:
        lda #KEY_UP
        bit ButtonsDown
        beq check_east
        lda #PLAYER_DIRECTION_NORTH
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_east:
        lda #KEY_RIGHT
        bit ButtonsDown
        beq check_south        
        lda #PLAYER_DIRECTION_EAST
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_south:
        lda #KEY_DOWN
        bit ButtonsDown
        beq check_west
        lda #PLAYER_DIRECTION_SOUTH
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts
check_west:
        lda #KEY_LEFT
        bit ButtonsDown
        beq check_wait ; this shouldn't be reachable
        lda #PLAYER_DIRECTION_WEST
        sta PlayerNextDirection
        lda #0
        sta PlayerIntendsToWait
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        rts   
check_wait:
        lda #KEY_SELECT
        bit ButtonsDown
        beq check_bomb ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToWait
        lda #0
        sta PlayerNextDirection
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast

        ; DEBUG: I AM INVINCIBLE!
        lda #PLAYER_STAUTS_INVULNERABLE
        sta PlayerLingeringStatusType
        lda #8
        sta PlayerLingeringStatusDuration

        rts
check_bomb:
        lda #KEY_B
        bit ButtonsDown
        beq check_spellcast ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToBomb
        lda #0
        sta PlayerIntendsToWait
        sta PlayerNextDirection
        sta PlayerIntendsToCast
        rts
check_spellcast:
        lda #KEY_A
        bit ButtonsDown
        beq no_valid_press ; this shouldn't be reachable
        lda #1
        sta PlayerIntendsToCast
        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToWait
        sta PlayerNextDirection
        rts
no_valid_press: ; not really sure how this label gets hit, but whatever
        rts
.endproc

.proc FAR_set_player_target_coordinates
        perform_zpcm_inc
        lda PlayerCol
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta PlayerTargetX + 1
        lda #0
        sta PlayerTargetX

        lda PlayerRow
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sta PlayerTargetY + 1
        lda #0
        sta PlayerTargetY
        perform_zpcm_inc
        rts
.endproc

; Useful during init, or to prevent a large travel lerp during teleports
.proc FAR_apply_target_coordinates_immediately
        ; Do not lerp. Do not collect 200 zorkmids
        lda PlayerTargetX
        sta PlayerCurrentX
        lda PlayerTargetX+1
        sta PlayerCurrentX+1
        lda PlayerTargetY
        sta PlayerCurrentY
        lda PlayerTargetY+1
        sta PlayerCurrentY+1
        rts
.endproc

; Standard, useful for moving between nearby tiles
.proc lerp_player_to_target_coordinates
CurrentPos := R0
TargetPos := R2
        perform_zpcm_inc
        lda PlayerCurrentX
        sta CurrentPos
        lda PlayerCurrentX+1
        sta CurrentPos+1
        lda PlayerTargetX
        sta TargetPos
        lda PlayerTargetX+1
        sta TargetPos+1
        jsr lerp_coordinate
        lda CurrentPos
        sta PlayerCurrentX
        lda CurrentPos+1
        sta PlayerCurrentX+1

        perform_zpcm_inc

        lda PlayerCurrentY
        sta CurrentPos
        lda PlayerCurrentY+1
        sta CurrentPos+1
        lda PlayerTargetY
        sta TargetPos
        lda PlayerTargetY+1
        sta TargetPos+1
        jsr lerp_coordinate        
        lda CurrentPos
        sta PlayerCurrentY
        lda CurrentPos+1
        sta PlayerCurrentY+1

        perform_zpcm_inc

        rts
.endproc

; lifted straight from dungeon game, with little to no modification
.proc lerp_coordinate
CurrentPos := R0
TargetPos := R2
Distance := R4
        sec
        lda TargetPos
        sbc CurrentPos
        sta Distance
        lda TargetPos+1
        sbc CurrentPos+1
        sta Distance+1
        ; for sign checks, we need a third distance byte; we'll use
        ; #0 for both incoming values
        lda #0
        sbc #0
        sta Distance+2

        ; sanity check: are we already very close to the target?
        ; If our distance byte is either $00 or $FF, then there is
        ; less than 1px remaining
        lda Distance+1
        cmp #$00
        beq arrived_at_target
        cmp #$FF
        beq arrived_at_target

        perform_zpcm_inc

        ; this is a signed comparison, and it's much easier to simply split the code here
        lda Distance+2
        bmi negative_distance

positive_distance:
        ; divide the distance by 2
.repeat 1
        lsr Distance+1
        ror Distance
.endrepeat
        jmp store_result

negative_distance:
        ; divide the distance by 2
.repeat 1
        sec
        ror Distance+1
        ror Distance
.endrepeat

store_result:
        ; apply the computed distance/4 to the current position
        clc
        lda CurrentPos
        adc Distance
        sta CurrentPos
        lda CurrentPos+1
        adc Distance+1
        sta CurrentPos+1
        ; and we're done!
        rts

arrived_at_target:
        ; go ahead and apply the target position completely, to skip the tail end of the lerp
        lda TargetPos + 1
        sta CurrentPos + 1
        lda #0
        sta CurrentPos
        rts
.endproc

.proc FAR_player_face_right
        ldx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        rts
.endproc

.proc FAR_player_face_left
        ldx PlayerSpriteIndex
        lda #(SPRITE_ACTIVE | SPRITE_HORIZ_FLIP)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        rts
.endproc

player_state_lut:
        .word player_state_normal
        .word player_state_bomb
        .word player_state_casting
        .word player_state_dead
        .word player_state_shocked
        .word player_state_frozen

; Called once at the beginning of every beat
.proc FAR_update_player
PlayerStatePtr := R0
        ; basic cleanup applied to all on-beat states
        st16 WeaponDrawFunc, weapon_update_none

        lda PlayerState
        asl
        tax
        lda player_state_lut+0, x
        sta PlayerStatePtr+0
        lda player_state_lut+1, x
        sta PlayerStatePtr+1
        perform_zpcm_inc
        jmp (PlayerStatePtr)
.endproc

; Stuff we need to clear out on every beat, no matter which state we're
; currently in
.proc player_global_reset
        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter
        sta PlayerLingeringStatusFrame
        sta PlayerTappedIce
        ; If no damage direction is set, default to a kinda random-circle-y lookin' thing.
        sta PlayerIncomingDamageDirection

        ; Every beat we'll by default be in our generic palette. We need to recover from whatever
        ; the previous beat's effect was doing, so flag that here.
        lda #1
        sta StagingObjPaletteDirty

        ; Always reset the player's palette back to 0 at the start of the beat
        ; (in case some other state changed it for an effect)
        ldx PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::BehaviorFlags, x
        and #($FF - SPRITE_PAL_MASK)
        ora #SPRITE_PAL_0
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        ; Similarly, disable the fancy animation table system; most animations don't
        ; use it, so this is a sensible default
        lda #$FF
        sta PlayerAnimationTable

        lda #0
        sta PlayerCombo


        perform_zpcm_inc
        rts
.endproc

.proc apply_player_torchlight
TorchlightTotal := R0
        ; If we are in a warp zone, we need to apply stability to torchlight instead
        ldx PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_WARP
        bne apply_stability_as_torchlight

        ; Detect equipment changes and update static player stats as necessary
        ; (this needs to happen BEFORE our exit changes, to facilitate room transition logic)
        far_call FAR_equipment_torchlight
        lda TorchlightTotal
        sta PlayerTorchlightRadius
        ; If this room is darkened, apply torchlight
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_DARK
        beq no_darkness
        lda PlayerTorchlightRadius
        sta target_torchlight_radius
no_darkness:
        rts

apply_stability_as_torchlight:
        lda WarpStability
        cmp #29
        bcc stability_in_range
        lda #29
stability_in_range:
        sta PlayerTorchlightRadius
        sta target_torchlight_radius
        rts
.endproc

player_direction_button_lut:
        .byte $00 ; unused
        .byte KEY_UP    ; PLAYER_DIRECTION_NORTH
        .byte KEY_RIGHT ; PLAYER_DIRECTION_EAST
        .byte KEY_DOWN  ; PLAYER_DIRECTION_SOUTH
        .byte KEY_LEFT  ; PLAYER_DIRECTION_WEST

.proc player_state_normal
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        jsr player_global_reset
        jsr process_lingering_effect_expiry
        jsr process_poison_tick

        ; First up, default the player's animation cel to either standing or, if it's been a really long
        ; time since we got a player input AND the room is clear, the idle pose for flavor
        ldx PlayerRoomIndex
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        beq pick_standard_pose
check_for_idle_pose:
        lda PlayerIdleBeats
        cmp #16
        bcc pick_standard_pose
        lda #16
        sta PlayerIdleBeats
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_IDLE
        lda #$FF
        sta PlayerAnimationTable
        jmp done_with_initial_pose
pick_standard_pose:
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable
done_with_initial_pose:

        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol

        inc PlayerIdleBeats

        ; If we aren't intending to move, then skip to collision processing
        lda PlayerNextDirection
        ora PlayerHeldDirection
        beq resolve_enemy_collision

        lda #0
        sta PlayerIdleBeats

perform_normal_movement:

        lda #0
        sta PlayerMovementBlocked

; TODO: Attempt an attack. If we hit something, most weapon types will skip movement
swing_weapon:
        far_call FAR_player_swing_weapon

        ; If the player's movement is still allowed, then attempt a move
        lda PlayerMovementBlocked
        bne resolve_enemy_collision

move_player:
        jsr player_move        

resolve_enemy_collision:
        near_call FAR_player_resolve_collision

        jsr handle_go_go_boots_movement

        ; If the player's position changed, have the jumping pose kick in
        ; (this overrides attacking, which feels like it should be appropriate?)
        ; TODO: if something else can move the player (pushing enemies?) we might
        ; need a custom "being pushed" animation. at the very least, the player probably
        ; shouldn't visibly jump.
        lda TargetRow
        cmp PlayerRow
        bne apply_jumping_pose
        lda TargetCol
        cmp PlayerCol
        bne apply_jumping_pose
        ; the player's previous move did not succeed, so clear that flag
        lda #0
        sta PlayerPreviousSuccessfulDirection
        jmp skip_jumping_pose
apply_jumping_pose:
        ; status checks: if we entered the shocked/frozen states, don't jump
        lda PlayerLingeringStatusType
        cmp #PLAYER_STATUS_SHOCKED
        beq skip_jumping_pose
        cmp #PLAYER_STATUS_FROZEN
        beq skip_jumping_pose
        ; okay to proceed!
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_JUMP
        ;lda #JUMP_ANIMATION_INDEX
        lda #JUMP_ANIMATION_MILD_INDEX
        sta PlayerAnimationTable
        ; The player's movement succeeded, so store that in a flag
        lda PlayerNextDirection
        ora PlayerHeldDirection
        sta PlayerPreviousSuccessfulDirection
skip_jumping_pose:

        ; Update the player's combo counter
        jsr update_chain_and_combo

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        near_call FAR_set_player_target_coordinates

        ; If the player is still holding this directional input, carry it over
        ; to the next beat as a held input
        ; (note: do this part unconditionally, as some mechanics rely on held inputs.
        ; the optional ones will be checked at each site)
        ldx PlayerNextDirection
        lda player_direction_button_lut, x
        and ButtonsThisFrame
        beq done_with_held_inputs
        lda PlayerNextDirection
        sta PlayerHeldDirection
done_with_held_inputs:
        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        jsr apply_player_torchlight

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; Detect pausing. (The boss key, the mom alert, etc.)
        jsr detect_pause_action

        ; Detect bomb hoisting (aggressive negotiations from afar)
        jsr detect_bomb_hoist

        ; Detect spell casting (its the WHEEL OF MAGIC!)
        jsr detect_spell_cast

        ; TODO: Detect other types of intent here. These aren't implemented,
        ; so just clear the intent flags for now.
        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait

        perform_zpcm_inc

        ; If necessary, cleanup dialog states through movement
        jsr cleanup_dialog_state

        ; Finally, our position is finalized, so compute the lookup table ptr for distance
        ; (this massively improves enemy AI during pathfinding)
        near_call FAR_compute_player_distance_lut_ptr

        rts
.endproc

.proc player_state_bomb
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        jsr process_lingering_effect_expiry

        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter
        ; If no damage direction is set, default to a kinda random-circle-y lookin' thing.
        sta PlayerIncomingDamageDirection

        ; Every beat we'll by default be in our generic palette. We need to recover from whatever
        ; the previous beat's effect was doing, so flag that here.
        lda #1
        sta StagingObjPaletteDirty

        ; Always try to throw the bomb. Whether this does anything depends on the
        ; bomb's internal logic; most require a directional input.
perform_bomb_throw:
        far_call FAR_throw_held_bomb

        ; Here we need to set the facing direction ourselves, as the calling code
        ; doesn't bother
        lda PlayerNextDirection
check_bomb_east:
        cmp #PLAYER_DIRECTION_EAST
        bne check_bomb_west
        near_call FAR_player_face_right
        jmp check_bomb_in_hand
check_bomb_west:
        cmp #PLAYER_DIRECTION_WEST
        bne no_bomb_facing_change
        near_call FAR_player_face_left
no_bomb_facing_change:
        jmp check_bomb_in_hand

check_bomb_in_hand:
        ; If we are no longer holding a bomb, clean up and return to normal behavior
        lda PlayerHeldBombIndex
        cmp #$FF
        beq not_holding_bomb

        ; Otherwise advance our animation state, in case bomb logic needs to use that
        inc PlayerBeatsInThisState
        ; Normally while holding a bomb we should use our held state:
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_HOLD
        lda #$FF
        sta PlayerAnimationTable
        ; If we are now holding a standard bomb and we are on beat 3, PANIC
        lda current_save + SaveFile::PlayerEquipmentBombs
        cmp #ITEM_BOMB_STANDARD
        bne done_panicking
        lda PlayerBeatsInThisState
        cmp #3
        bcc done_panicking
        ; Set the panic sprite
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_PANIC
        lda #$FF
        sta PlayerAnimationTable
done_panicking:

        jmp resolve_enemy_collision

not_holding_bomb:
        ; Where did the bomb go? Oh well, revert to normal state on the next frame
        ; (also we are probably about to take damage)
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
        ; Reset to idle, so the damage logic switches to that sprite
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable

resolve_enemy_collision:
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol
        near_call FAR_player_resolve_collision

        ; Update the player's combo counter
        jsr update_chain_and_combo

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        near_call FAR_set_player_target_coordinates

        ; If the player is still holding this directional input, carry it over
        ; to the next beat as a held input
        ; (note: do this part unconditionally, as some mechanics rely on held inputs.
        ; the optional ones will be checked at each site)
        ldx PlayerNextDirection
        lda player_direction_button_lut, x
        and ButtonsThisFrame
        beq done_with_held_inputs
        lda PlayerNextDirection
        sta PlayerHeldDirection
done_with_held_inputs:
        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        jsr apply_player_torchlight

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; (Notably: do not detect pausing or spellcasting. Holding a bomb overrides both!)

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause

        perform_zpcm_inc

        ; If necessary, cleanup dialog states through movement
        jsr cleanup_dialog_state

        ; Finally, our position is finalized, so compute the lookup table ptr for distance
        ; (this massively improves enemy AI during pathfinding)
        near_call FAR_compute_player_distance_lut_ptr
        rts
.endproc

; A stun state during which we cannot move. Lasts until the effect duration expires naturally
; or we take a hit from any other source, which also cancels the effect.
.proc player_state_shocked
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        lda #0
        sta PlayerLingeringStatusFrame
        jsr process_lingering_effect_expiry

        ; If the effect has expired, go ahead and revert us back to normal state
        lda PlayerLingeringStatusType
        bne stun_not_expired
        ; Reset to the normal state then
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
        ; Reset to our idle sprite, which may get replaced by taking damage
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable
        ; Now just BECOME the normal state, and skip all this other nonsense. This way if the player
        ; queues up an action on the frame they would recover, we honor that action.
        jmp player_state_normal
stun_not_expired:
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
        lda #$FF
        sta PlayerAnimationTable

        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter
        ; If no damage direction is set, default to a kinda random-circle-y lookin' thing.
        sta PlayerIncomingDamageDirection

        ; Every beat we'll by default be in our generic palette. We need to recover from whatever
        ; the previous beat's effect was doing, so flag that here.
        lda #1
        sta StagingObjPaletteDirty

resolve_enemy_collision:
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol
        near_call FAR_player_resolve_collision

        ; If we just took damage, then clear the stun state. (We might also be dead, we'll check for that in a minute.)
        lda PlayerTookDamageThisBeat
        beq no_damage_taken
        ; Revert us to our normal state, but don't set a sprite (the damage routine did that)
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
no_damage_taken:

        ; Update the player's combo counter
        jsr update_chain_and_combo

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        near_call FAR_set_player_target_coordinates

        ; If the player is still holding this directional input, carry it over
        ; to the next beat as a held input
        ; (note: do this part unconditionally, as some mechanics rely on held inputs.
        ; the optional ones will be checked at each site)
        ldx PlayerNextDirection
        lda player_direction_button_lut, x
        and ButtonsThisFrame
        beq done_with_held_inputs
        lda PlayerNextDirection
        sta PlayerHeldDirection
done_with_held_inputs:
        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        jsr apply_player_torchlight

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; (Notably: do not detect pausing or spellcasting. Holding a bomb overrides both!)

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause

        perform_zpcm_inc

        ; If necessary, cleanup dialog states through movement
        jsr cleanup_dialog_state

        ; Finally, our position is finalized, so compute the lookup table ptr for distance
        ; (this massively improves enemy AI during pathfinding)
        near_call FAR_compute_player_distance_lut_ptr
        rts
.endproc

; A state during which we are frozen solid! A few different conditions will cause this state
; to revert almost right away, but otherwise, we the player must "tap" the ice to decrease
; the counter. This will need juice so the player has appropriate feedback, etc.
.proc player_state_frozen
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        lda #0
        sta PlayerTappedIce
        sta PlayerLingeringStatusFrame

        ; If the player intends to move, then process the effect expiry as usual
        lda PlayerNextDirection
        ora PlayerHeldDirection
        beq no_movement_attempted
        lda #1
        sta PlayerTappedIce
        jsr process_lingering_effect_expiry
        ; TODO: if we're going to juice up the tap with player shake or SFX, do that here!
no_movement_attempted:

        ; If we're in a "hot" room, defrost ourselves instantly
        ldx PlayerRoomIndex
        lda room_palette_variant, x
        cmp #ROOM_PALETTE_FIRE
        bne no_defrosting_today
        lda #PLAYER_STATUS_NORMAL
        sta PlayerLingeringStatusType
        lda #0
        sta PlayerLingeringStatusDuration
        sta PlayerLingeringStatusFrame
        ; TODO: if we're going to juice up the defrosting action, do that here
no_defrosting_today:

        ; TODO: for game feel reasons, should we **process** the normal state here? If we don't
        ; then on the beat the player recovers, they'll still be able to take no action...
        ; get this actually happening in a combat situation, then revisit!

        ; If the effect has expired, go ahead and revert us back to normal state
        lda PlayerLingeringStatusType
        bne stun_not_expired
        ; Reset to the normal state then
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
        ; Reset to our idle sprite, which may get replaced by taking damage
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable
        ; Clear the ice tap thing, we're going to run normal player movement instead
        lda #0
        sta PlayerTappedIce
        ; Now just BECOME the normal state, and skip all this other nonsense. This way if the player
        ; queues up an action on the frame they would recover, we honor that action.
        jmp player_state_normal
stun_not_expired:
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
        lda #$FF
        sta PlayerAnimationTable

        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter
        ; If no damage direction is set, default to a kinda random-circle-y lookin' thing.
        sta PlayerIncomingDamageDirection

        ; Every beat we'll by default be in our generic palette. We need to recover from whatever
        ; the previous beat's effect was doing, so flag that here.
        lda #1
        sta StagingObjPaletteDirty

resolve_enemy_collision:
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol
        near_call FAR_player_resolve_collision

        ; If we just took damage, then clear the stun state. (We might also be dead, we'll check for that in a minute.)
        lda PlayerTookDamageThisBeat
        beq no_damage_taken
        ; Revert us to our normal state, but don't set a sprite (the damage routine did that)
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
no_damage_taken:

        ; DO NOT update the player's chain/combo counter. We are frozen! 
        ; (This unusual mechanic might be fun to exploit for puzzles.)

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        near_call FAR_set_player_target_coordinates

        ; If the player is still holding this directional input, carry it over
        ; to the next beat as a held input
        ; (note: do this part unconditionally, as some mechanics rely on held inputs.
        ; the optional ones will be checked at each site)
        ldx PlayerNextDirection
        lda player_direction_button_lut, x
        and ButtonsThisFrame
        beq done_with_held_inputs
        lda PlayerNextDirection
        sta PlayerHeldDirection
done_with_held_inputs:
        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        jsr apply_player_torchlight

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; (Notably: do not detect pausing or spellcasting. Holding a bomb overrides both!)

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause

        perform_zpcm_inc

        ; If necessary, cleanup dialog states through movement
        jsr cleanup_dialog_state

        ; Finally, our position is finalized, so compute the lookup table ptr for distance
        ; (this massively improves enemy AI during pathfinding)
        near_call FAR_compute_player_distance_lut_ptr
        rts
.endproc

spell_casting_dispatch_lut:
        .word cast_spell_fire
        .word cast_spell_air
        .word cast_spell_ice
        .word cast_spell_earth
        .word cast_spell_bomb_fiesta
        .word cast_spell_life

.proc player_state_casting
SpellCastPtr := R0
TorchlightTotal := R0

TargetRow := R14
TargetCol := R15
        jsr process_lingering_effect_expiry

        lda #0
        sta PlayerTookDamageThisBeat
        sta PlayerDamageAnimCounter
        ; If no damage direction is set, default to a kinda random-circle-y lookin' thing.
        sta PlayerIncomingDamageDirection

        ; Every beat we'll by default be in our generic palette. We need to recover from whatever
        ; the previous beat's effect was doing, so flag that here.
        lda #1
        sta StagingObjPaletteDirty

        ; There is nothing fancy to do at the end of spellcasting, just revert to the normal state
        lda #PLAYER_STATE_NORMAL
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState
        ; Set our animation frame back to idle
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER
        lda #$FF
        sta PlayerAnimationTable

resolve_enemy_collision:
        lda PlayerRow
        sta TargetRow
        lda PlayerCol
        sta TargetCol
        near_call FAR_player_resolve_collision

        ; Update the player's combo counter
        jsr update_chain_and_combo

        ; Now we may finalize the player's position and draw
        lda TargetRow
        sta PlayerRow
        lda TargetCol
        sta PlayerCol

        near_call FAR_set_player_target_coordinates

        ; If the player is still holding some directional input,
        ; even though we ignored it, carry it over anyway. (this way we don't eat that input.)
        ; (note: do this part unconditionally, as some mechanics rely on held inputs.
        ; the optional ones will be checked at each site)
        ldx PlayerNextDirection
        lda player_direction_button_lut, x
        and ButtonsThisFrame
        beq done_with_held_inputs
        lda PlayerNextDirection
        sta PlayerHeldDirection
done_with_held_inputs:
        ; Clear player intent for the next beat
        lda #0
        sta PlayerNextDirection

        jsr apply_player_torchlight

        ; Detect exits and, if necessary, transition to the next room
        jsr detect_exit

        ; Detect being dead and, if necessary, transition to the end screen
        jsr detect_critical_existence_failure

        ; (Notably: do not detect pausing or spellcasting. Holding a bomb overrides both!)

        lda #0
        sta PlayerIntendsToBomb
        sta PlayerIntendsToCast
        sta PlayerIntendsToWait
        sta PlayerIntendsToPause

        perform_zpcm_inc

        ; If necessary, cleanup dialog states through movement
        jsr cleanup_dialog_state

        ; Finally, our position is finalized, so compute the lookup table ptr for distance
        ; (this massively improves enemy AI during pathfinding)
        near_call FAR_compute_player_distance_lut_ptr

        ; We must actually cast the spell, yes yes!
        ; We do this bit last, so that any spell effects aren't clobbered by
        ; the above default-resolution behavior, etc etc.
        lda current_save + SaveFile::PlayerEquipmentSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        ; Safety: don't call a spell effect that doesn't exist
        ; (This shouldn't happen, but crashing is no fun)
        cmp #LAST_SPELL_IN_ITEM_LIST
        bcs not_safe_to_dispatch
        asl
        tax
        lda spell_casting_dispatch_lut+0, x
        sta SpellCastPtr+0
        lda spell_casting_dispatch_lut+1, x
        sta SpellCastPtr+1
        jsr _spellcasting_trampoline
not_safe_to_dispatch:

        ; If the spell effects deferred loot generation, release that here
        lda #0
        sta DeferLootProcessing

        ; If the spell effects caused an enemy to be defeated, play that SFX
        lda SpellDefeatsEnemy
        beq no_defeat_sfx

        ; Play an appropriately crunchy death sound
        queue_sfx_pulse1 sfx_defeat_enemy_pulse
        queue_sfx_noise sfx_defeat_enemy_noise

no_defeat_sfx:
        lda #0
        sta SpellDefeatsEnemy

        ; Finally, the spell is used up! Remove it from our hands
.if ::DEBUG_GOD_MODE
        ; Nope! Keep the spell so we can easily re-cast it
.else
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentSpell
.endif

        rts
.endproc

; Note: Only really stable/tested/intended for room-altering elemental
; effects. Monsters as a general rule don't cast other spells, those are
; for the player.
.proc FAR_monster_spellcasting_dispatch
SpellCastPtr := R0
        ; When a monster wishes to cast a spell, we need to have it
        ; call the same room-state-setting special effects (and other
        ; tomfoolery) that the player logic calls. Note that the player
        ; may then immediately call this again with their OWN spell, so
        ; we'll need to test that case somehow and work out the kinks.
        lda CurrentlyActiveSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        ; Safety: don't call a spell effect that doesn't exist
        ; (This shouldn't happen, but crashing is no fun)
        cmp #LAST_SPELL_IN_ITEM_LIST
        bcs not_safe_to_dispatch
        asl
        tax
        lda spell_casting_dispatch_lut+0, x
        sta SpellCastPtr+0
        lda spell_casting_dispatch_lut+1, x
        sta SpellCastPtr+1
        jsr _spellcasting_trampoline
not_safe_to_dispatch:
        rts
.endproc

.proc _spellcasting_trampoline
SpellCastPtr := R0
        jmp (SpellCastPtr)
.endproc

.proc brighten_room
        ; This is a room-effecting shenanigan! Brighten all the way and fade back down
        lda #BRIGHTNESS_FULLY_BRIGHT
        sta Brightness
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness
        lda #1
        sta StagingBgPaletteDirty
        sta StagingObjPaletteDirty
        rts
.endproc

.proc remove_elemental_raster_effects
        ldx PlayerRoomIndex
        lda room_raster_effect, x
        cmp #RASTER_EFFECT_SCORCHED
        beq proceed_to_remove
        ; TODO: other persistent elemental effect checks here
        rts
proceed_to_remove:
        lda #RASTER_EFFECT_NONE
        sta room_raster_effect, x
        rts
.endproc

.proc apply_scorched_raster_effect
        ldx PlayerRoomIndex
        lda room_raster_effect, x
        cmp #RASTER_EFFECT_NONE
        beq safe_to_apply
        rts
safe_to_apply:
        lda #RASTER_EFFECT_SCORCHED
        sta room_raster_effect, x
        rts
.endproc

.proc lighten_current_room
        ldx PlayerRoomIndex
        lda room_flags, x
        and #($FF - ROOM_FLAG_DARK)
        sta room_flags, x
        lda #30
        sta target_torchlight_radius
        rts
.endproc

.proc cast_spell_fire
        jsr brighten_room
        jsr remove_elemental_raster_effects
        jsr apply_scorched_raster_effect
        jsr lighten_current_room
        ; Apply red emphasis to this chamber (permanently)
        ldx PlayerRoomIndex
        lda #(TINT_R)
        sta room_color_emphasis, x
        far_call FAR_apply_room_global_color_emphasis
        ; Apply fancy custom "scorched" palette to the room (permanently)
        ldx PlayerRoomIndex
        lda #ROOM_PALETTE_FIRE
        sta room_palette_variant, x
        far_call FAR_load_palette_for_current_room
        queue_sfx_noise_with_priority sfx_scorch_noise, #10
        rts
.endproc

.proc cast_spell_air
        jsr brighten_room
        jsr remove_elemental_raster_effects
        jsr lighten_current_room
        ; Apply yellow emphasis to this chamber (permanently)
        ldx PlayerRoomIndex
        lda #(TINT_R | TINT_G)
        sta room_color_emphasis, x
        far_call FAR_apply_room_global_color_emphasis
        ; Apply fancy custom "shocked" palette to the room (permanently)
        ldx PlayerRoomIndex
        lda #ROOM_PALETTE_AIR
        sta room_palette_variant, x
        far_call FAR_load_palette_for_current_room
        
        queue_sfx_noise_with_priority sfx_shock_noise, #10
        queue_sfx_pulse1_with_priority sfx_shock_pulse, #10
        rts
.endproc

.proc cast_spell_ice
        jsr brighten_room
        jsr remove_elemental_raster_effects
        ; Apply blue emphasis to this chamber (permanently)
        ldx PlayerRoomIndex
        lda #(TINT_B)
        sta room_color_emphasis, x
        far_call FAR_apply_room_global_color_emphasis
        ; Apply fancy custom "frozen" palette to the room (permanently)
        ldx PlayerRoomIndex
        lda #ROOM_PALETTE_ICE
        sta room_palette_variant, x
        far_call FAR_load_palette_for_current_room
        ; TODO: fancy stuffs!
        queue_sfx_pulse1_with_priority sfx_chill_pulse1, #10
        queue_sfx_pulse2_with_priority sfx_chill_pulse2, #10
        rts
.endproc

.proc cast_spell_earth
        jsr brighten_room
        jsr remove_elemental_raster_effects
        ; Apply green emphasis to this chamber (permanently)
        ldx PlayerRoomIndex
        lda #(TINT_G)
        sta room_color_emphasis, x
        far_call FAR_apply_room_global_color_emphasis
        ; Apply fancy custom "overgrown" palette to the room (permanently)
        ldx PlayerRoomIndex
        lda #ROOM_PALETTE_EARTH
        sta room_palette_variant, x
        far_call FAR_load_palette_for_current_room
        ; TODO: fancy stuffs!
        queue_sfx_pulse1_with_priority sfx_fae_pulse1, #10
        queue_sfx_pulse2_with_priority sfx_fae_pulse2, #10
        rts
.endproc

.proc cast_spell_bomb_fiesta
bomb_fiesta_state := room_spell_data0
previous_room_effect := room_spell_data1

        ; Set the room into fiesta mode
        ldx PlayerRoomIndex
        lda room_spell_beat_logic, x
        sta previous_room_effect, x
        lda #SPELL_LOGIC_BOMB_FIESTA
        sta room_spell_beat_logic, x
        ; Initialize that beat timer to 0, so the spell starts at the beginning
        lda #0
        sta bomb_fiesta_state, x
        ; I kindof want an earthquakey warning rumble before the party starts
        queue_sfx_noise sfx_low_noise
        ; Earthquakes come with screen shake
        lda #1
        sta ScreenShakeDepth
        lda #64
        sta ScreenShakeSpeed
        sta ScreenShakeDecayCounter
        ; TODO: any other initial effects? most of the flashy stuff is part of
        ; the beat update logic, so maybe not
        rts
.endproc

.proc cast_spell_life
HealingAmount := R0
        ; TODO: not this! Let's lighten the **player** instead.
        ; jsr brighten_room
        lda #PLAYER_STAUTS_JUST_HEALED
        sta PlayerLingeringStatusType
        lda #1
        sta PlayerLingeringStatusDuration

        ; Heal ALL the health
        lda #128
        sta HealingAmount
        near_call FAR_receive_healing

        ; Max ALL the temporary hearts, if missing
        far_call FAR_give_temporary_heart

        ; TODO: any other fun effects, like maybe temporary shield / invuln, etc
        queue_sfx_pulse1 sfx_heart_container
        queue_sfx_pulse2 sfx_heart_container
        rts
.endproc

.proc player_state_dead
        ; RIP
        rts
.endproc

.proc cleanup_dialog_state
        ldx PlayerRow
        lda row_number_to_tile_index_lut, x ; Row * Width
        clc
        adc PlayerCol                  ; ... + Col
        sta PlayerSquare

        lda PlayerActiveDialogSquare
        beq done_with_active_dialog
        cmp PlayerSquare
        beq done_with_active_dialog
        lda #1
        sta DialogDismissActiveMode
        lda #0
        sta PlayerActiveDialogSquare
done_with_active_dialog:

        lda PlayerPassiveDialogSquare
        beq done_with_passive_dialog
        cmp PlayerSquare
        beq done_with_passive_dialog
        lda #1
        sta DialogDismissPassiveMode
        lda #0
        sta PlayerPassiveDialogSquare
done_with_passive_dialog:

        rts
.endproc

.proc handle_go_go_boots_movement
TargetRow := R14
TargetCol := R15
        ; ITEM: if the player has the gogo boots equipped, 
        ; AND the previous move succeeded,
        ; AND this is their second successful move,
        ; then attempt a move again!
        lda current_save + SaveFile::PlayerEquipmentBoots
        cmp #ITEM_GO_GO_BOOTS
        jne done_with_go_go_boots

        ; don't trigger if we aren't actually attempting a move. also, specifically,
        ; go go boots now trigger on HELD movements only. Ignore a fresh press!
        lda PlayerHeldDirection
        jeq done_with_go_go_boots

        ; don't trigger if we are changing directions OR if this is our
        ; first movement in this chain
        lda PlayerPreviousSuccessfulDirection
        cmp PlayerHeldDirection
        bne done_with_go_go_boots

        ; don't trigger if the previous movement failed!
        lda TargetRow
        cmp PlayerRow
        bne previous_move_succeeded
        lda TargetCol
        cmp PlayerCol
        bne previous_move_succeeded
        jmp done_with_go_go_boots
previous_move_succeeded:

        ; don't trigger if we are moving towards a map border and we have
        ; already arrived there!
        lda PlayerHeldDirection
        ldx TargetCol
        ldy TargetRow
check_north:
        cmp #PLAYER_DIRECTION_NORTH
        bne check_east
        cpy #0
        beq done_with_go_go_boots
check_east:
        cmp #PLAYER_DIRECTION_EAST
        bne check_south
        cpx #(BATTLEFIELD_WIDTH-1)
        beq done_with_go_go_boots
check_south:
        cmp #PLAYER_DIRECTION_SOUTH
        bne check_west
        cpy #(BATTLEFIELD_HEIGHT-1)
        beq done_with_go_go_boots
check_west:
        cmp #PLAYER_DIRECTION_WEST
        bne done_with_map_edge_checks
        cpx #0
        beq done_with_go_go_boots
done_with_map_edge_checks:
        ; finally, all the sanity checks having passed, do the thing
        queue_sfx_pulse1 sfx_go_go_pulse

        ; firstly, commit the previous move (it succeeded)
        lda TargetCol
        sta PlayerCol
        lda TargetRow
        sta PlayerRow

        ; the previous move actually happened, so apply the jumping pose
        ; (even if the next one fails!)
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_JUMP
        ;lda #JUMP_ANIMATION_INDEX
        lda #JUMP_ANIMATION_MILD_INDEX
        sta PlayerAnimationTable

move_player:
        jsr player_move        

resolve_enemy_collision:
        near_call FAR_player_resolve_collision

        ; Bugfix: if the player has a passive dialogue square, update it to
        ; their new location
        lda PlayerPassiveDialogSquare
        beq done_fixing_dialogue_square
        ldx TargetRow
        lda row_number_to_tile_index_lut, x ; Row * Width
        clc
        adc TargetCol                  ; ... + Col
        sta PlayerPassiveDialogSquare
done_fixing_dialogue_square:

done_with_go_go_boots:
        rts
.endproc

.proc player_move
TargetRow := R14
TargetCol := R15
; If we get here, we are attempting a movement. Whether it succeeds or not, animate the
; player jumping (possibly in place)
        lda #0
        sta PlayerJumpHeightPos

; Movement 
        lda PlayerNextDirection
        ora PlayerHeldDirection
check_north:
        cmp #PLAYER_DIRECTION_NORTH
        bne check_east
        dec TargetRow
        jmp done_choosing_target
check_east:
        cmp #PLAYER_DIRECTION_EAST
        bne check_south
        inc TargetCol
        near_call FAR_player_face_right
        jmp done_choosing_target
check_south:
        cmp #PLAYER_DIRECTION_SOUTH
        bne check_west
        inc TargetRow
        jmp done_choosing_target
check_west:
        cmp #PLAYER_DIRECTION_WEST
        bne done_choosing_target
        dec TargetCol        
        near_call FAR_player_face_left
done_choosing_target:
        ; That's it; leave it in Target Col/Row for now, as we need to let
        ; collision have a go at it, and collision needs old/new coords

        rts
.endproc

.proc update_chain_and_combo
ChainGraceThreshold := R0
        perform_zpcm_inc
        lda #1
        sta ChainGraceThreshold
        ; If the player has a chain effecting item equipped, increase their chain threshold accordingly
        lda current_save + SaveFile::PlayerEquipmentAccessory
        cmp #ITEM_CHAIN_LINK
        bne chain_threshold_finalized
        lda #2
        sta ChainGraceThreshold
chain_threshold_finalized:
        ; Based on the player's accumulated combo, manipulate their chain here
        lda PlayerCombo
        beq check_chain_over
        ; Continue the player's current chain
        inc PlayerChain
        lda #0
        sta PlayerChainGrace
        jmp cleanup
check_chain_over:
        ; If the player is below the grace threshold, continue the chain
        lda PlayerChainGrace
        cmp ChainGraceThreshold
        bcs chain_over
        ; continue the grace period
        inc PlayerChainGrace
        jmp cleanup
chain_over:
        ; Reset the chain and grace back to 0
        lda #0
        sta PlayerChain
        sta PlayerChainGrace

cleanup:
        perform_zpcm_inc
        rts
.endproc

.proc FAR_player_resolve_collision
TargetSquare := R13
; This is our target position after movement. It might be the same as our player position;
; regardless, this is where we want to go on this frame. What happens when we land?
TargetRow := R14
TargetCol := R15
        perform_zpcm_inc
        ldx TargetRow
        lda row_number_to_tile_index_lut, x ; Row * Width
        clc
        adc TargetCol                  ; ... + Col
        sta TargetSquare

        far_call FAR_player_collides_with_tile
        perform_zpcm_inc
        rts
.endproc

.proc FAR_damage_player
 ; used by heart functions
IncomingDamage := R0
HealingAmount := R0

DamageReduction := R0

        ; If the player is invulnerable, ignore all of the below and do absolutely nothing.
        lda PlayerLingeringStatusType
        cmp #PLAYER_STAUTS_INVULNERABLE
        jeq handle_being_invulnerable

        ; Handle absorbtion, immunity, weakness and resistance in that order
        lda PlayerIncomingDmgElement ; bit mask for this element (possibly 0, for non-elemental)
        bit PlayerAbsorbtions
        jne handle_absorbtion
        bit PlayerImmunities
        jne handle_immunity

        ; Special item: if the player currently has the ninja footwraps equipped AND it is charged, then
        ; proc the item and treat this like immunity.
        lda current_save + SaveFile::PlayerEquipmentBoots
        cmp #ITEM_NINJA_FOOTWRAPS
        bne not_wearing_charged_footwraps
        lda PlayerNinjaFootwrapsCooldown
        bne not_wearing_charged_footwraps
        ; proc the footwraps! we just "dodged" this hit
        lda #NINJA_FOOTWRAPS_RECHARGE_COUNT
        sta PlayerNinjaFootwrapsCooldown
        queue_sfx_pulse1 sfx_stealthy_pulse
        ; set the player to invulerable for a couple of beats, so the effect is visible
        lda #PLAYER_STAUTS_INVULNERABLE
        sta PlayerLingeringStatusType
        lda #2
        sta PlayerLingeringStatusDuration
        ; and that's all. kthx, bye!
        rts
not_wearing_charged_footwraps:

        lda PlayerIncomingDmgElement
        bit PlayerWeaknesses
        beq not_weak_to_this_type
        ; Weakness DOUBLES incoming damage
        asl PlayerIncomingDmgAmount
not_weak_to_this_type:
        bit PlayerResistances
        beq not_resistant_to_this_type
        ; Resistance HALVES incoming damage, rounding down
        lsr PlayerIncomingDmgAmount
not_resistant_to_this_type:
        ; We're done with special modifiers, so now use the remaining damage as our base and process
        ; damage reductions. The resulting damage is always capped to a minimum of 1, so the player
        ; is never fully immune to any damage source unless they have that specific property.
        lda PlayerIncomingDmgAmount
        pha
        far_call FAR_dmg_reduction
        pla
        sec
        sbc DamageReduction
        bmi cap_to_minimum
        beq cap_to_minimum
        jmp damage_amount_okay
cap_to_minimum:
        lda #1
damage_amount_okay:
        sta IncomingDamage
        near_call FAR_receive_damage
        jsr FIXED_is_player_considered_dead
        jne already_dead

        lda #1
        sta ScreenShakeDepth
        lda #16
        sta ScreenShakeSpeed
        sta ScreenShakeDecayCounter

        ; Taking damage is a *big deal*
        queue_sfx_pulse1 sfx_weak_hit_pulse
        queue_sfx_triangle sfx_weak_hit_tri
        queue_sfx_noise sfx_weak_hit_noise

        ; Taking damage resets any ongoing chain. We want to
        ; reward SKILLED play, not merely one's ability to
        ; kite a crowd of zombies and tank hits
        lda #0
        sta PlayerChain
        sta PlayerChainGrace

        ; If we're in a warp zone, it also decreases warp stability
        decrease_warp_stability

        ; yup, we got hit. X_X
        ; setup the juice portion of the animation, these flags and timers
        ; will drive a lot of that.
        lda #1
        sta PlayerTookDamageThisBeat
        lda #0
        sta PlayerDamageAnimCounter

        ; TODO: work out the *direction* from which we got hit somehow!

        ; If we are in our idle pose, switch to damage. (Let any other
        ; animation override the damage state though, as it's more important)
        ldx PlayerSpriteIndex
        lda sprite_table + MetaSpriteState::TileIndex, x
        cmp #<SPRITE_PLAYER_01_PLAYER
        beq apply_damage_animation
        cmp #<SPRITE_PLAYER_01_PLAYER_IDLE
        beq apply_damage_animation
        cmp #<SPRITE_PLAYER_02_PLAYER_STUN
        beq apply_damage_animation
        jmp action_overrides_damage_animation
apply_damage_animation:
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_HIT
        lda #$FF
        sta PlayerAnimationTable
action_overrides_damage_animation:
        rts

already_dead:
        rts

handle_absorbtion:
        ; The player should become HEALED by this amount! How fortunate for them.
        ; TODO: evaluate if this is OP, we might want absorbtion to be more like +1 flat?
        lda PlayerIncomingDmgAmount
        sta HealingAmount
        near_call FAR_receive_healing
        ; We just healed the player (in response to damage) so play a healing SFX to indicate this
        queue_sfx_triangle sfx_small_heart
        ; But do NOT replace their hazard state. Absorbtion isn't *that* powerful.
        ; Anyway, we're done!
        rts
handle_immunity:
        ; TODO: play a little "tink" SFX here?
        ; For now, do nothing!
        rts
handle_being_invulnerable:
        ; TODO: play a "whiff" sound? unclear!
        rts
.endproc

.proc FAR_apply_hazard_to_player
        ; If the player is invulnerable, ignore all of the below and do absolutely nothing.
        lda PlayerLingeringStatusType
        cmp #PLAYER_STAUTS_INVULNERABLE
        bne player_not_invulnerable
        rts
player_not_invulnerable:

        ; Get complicated based on the hazard type
        lda PlayerIncomingStatusType
        cmp #PLAYER_STATUS_POISONED
        beq try_apply_poison
        cmp #PLAYER_STATUS_FROZEN
        beq try_apply_frozen
        cmp #PLAYER_STATUS_SHOCKED
        beq try_apply_shocked
        cmp #PLAYER_STATUS_BURNED
        jeq try_apply_burn
        ; huh? invalid status, bail, yes!
        rts
try_apply_poison:
        ; Are we immune / absorbing of this type? If so, do nothing!
        lda #PLAYER_RESISTANCE_MASK_EARTH
        bit PlayerImmunities
        bne immune_to_poison
        bit PlayerAbsorbtions
        bne immune_to_poison
        bit PlayerProtections
        bne immune_to_poison
        ; If we're resistant, we should at least halve the incoming duration
        bit PlayerResistances
        beq not_resistant_to_poison
        lsr PlayerIncomingStatusDuration
not_resistant_to_poison:
        ; Alright, apply that status!
        lda #PLAYER_STATUS_POISONED
        sta PlayerLingeringStatusType
        lda PlayerIncomingStatusDuration
        sta PlayerLingeringStatusDuration
        ; And done!
immune_to_poison:
        rts

try_apply_frozen:
        ; Are we immune / absorbing of this type? If so, do nothing!
        lda #PLAYER_RESISTANCE_MASK_ICE
        bit PlayerImmunities
        bne immune_to_freeze
        bit PlayerAbsorbtions
        bne immune_to_freeze
        bit PlayerProtections
        bne immune_to_freeze
        ; If we're resistant, we should at least halve the incoming duration
        bit PlayerResistances
        beq not_resistant_to_freeze
        lsr PlayerIncomingStatusDuration
not_resistant_to_freeze:
        ; Alright, apply that status!
        lda #PLAYER_STATUS_FROZEN
        sta PlayerLingeringStatusType
        lda PlayerIncomingStatusDuration
        sta PlayerLingeringStatusDuration
        lda #PLAYER_STATE_FROZEN
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
        lda #$FF
        sta PlayerAnimationTable
        ; And done!
immune_to_freeze:
        rts

try_apply_shocked:
        ; Are we immune / absorbing of this type? If so, do nothing!
        lda #PLAYER_RESISTANCE_MASK_AIR
        bit PlayerImmunities
        bne immune_to_shock
        bit PlayerAbsorbtions
        bne immune_to_shock
        bit PlayerProtections
        bne immune_to_shock
        ; If we're resistant, we should at least halve the incoming duration
        bit PlayerResistances
        beq not_resistant_to_shock
        lsr PlayerIncomingStatusDuration
not_resistant_to_shock:
        ; Alright, apply that status!
        lda #PLAYER_STATUS_SHOCKED
        sta PlayerLingeringStatusType
        lda PlayerIncomingStatusDuration
        sta PlayerLingeringStatusDuration
        lda #PLAYER_STATE_SHOCKED
        sta PlayerState
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_STUN
        lda #$FF
        sta PlayerAnimationTable
        ; And done!
immune_to_shock:
        rts

try_apply_burn:
        ; Are we immune / absorbing of this type? If so, do nothing!
        lda #PLAYER_RESISTANCE_MASK_FIRE
        bit PlayerImmunities
        bne immune_to_burn
        bit PlayerAbsorbtions
        bne immune_to_burn
        bit PlayerProtections
        bne immune_to_burn
        ; If we're resistant, we should at least halve the incoming duration
        bit PlayerResistances
        beq not_resistant_to_burn
        lsr PlayerIncomingStatusDuration
not_resistant_to_burn:
        ; Alright, apply that status!
        lda #PLAYER_STATUS_BURNED
        sta PlayerLingeringStatusType
        lda PlayerIncomingStatusDuration
        sta PlayerLingeringStatusDuration
        ; And done!
immune_to_burn:
        rts
.endproc

exit_left_lut:
        .repeat ::FLOOR_HEIGHT, h
        .byte (FLOOR_WIDTH-1) + (h * FLOOR_WIDTH)
        .repeat ::FLOOR_WIDTH - 1, w
        .byte (w) + (h * FLOOR_WIDTH)
        .endrepeat
        .endrepeat

exit_right_lut:
        .repeat ::FLOOR_HEIGHT, h
        .repeat ::FLOOR_WIDTH - 1, w
        .byte (w+1) + (h * FLOOR_WIDTH)
        .endrepeat
        .byte (0) + (h * FLOOR_WIDTH)
        .endrepeat

exit_up_lut:
        .repeat ::FLOOR_WIDTH, w
        .byte w + ((::FLOOR_HEIGHT-1) * FLOOR_WIDTH)
        .endrepeat
        .repeat ::FLOOR_HEIGHT-1, h
        .repeat ::FLOOR_WIDTH, w
        .byte (w) + (h * FLOOR_WIDTH)
        .endrepeat
        .endrepeat

exit_down_lut:
        .repeat ::FLOOR_HEIGHT-1, h
        .repeat ::FLOOR_WIDTH, w
        .byte (w) + ((h+1) * FLOOR_WIDTH)
        .endrepeat
        .endrepeat
        .repeat ::FLOOR_WIDTH, w
        .byte w + ((0) * FLOOR_WIDTH)
        .endrepeat

; Note: checks and updates PlayerRow/PlayerCol,
; but does **not** update the target or tween positions.
; This intentionally desynchronizes the on-screen position, which
; allows the player to appear to jump to the exit tile. When the next
; room loads, we'll instantly set their new position and they'll be in
; the right spot based on the way they left the previous field.
.proc detect_exit
RoomIndexScratch := R0
        lda PlayerCol
        cmp #0
        beq exit_left
        cmp #(::BATTLEFIELD_WIDTH - 1)
        beq exit_right
        lda PlayerRow
        cmp #0
        beq exit_top
        cmp #(::BATTLEFIELD_HEIGHT - 1)
        beq exit_bottom
no_exit:
        rts
exit_left:
        ; For fun and later warping, wrap the room index around the map
        ; 
        ldx PlayerRoomIndex
        lda exit_left_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_LEFT
        sta RoomTransitionType
        lda #(::BATTLEFIELD_WIDTH - 2)
        sta PlayerCol
        jmp converge
exit_right:
        ldx PlayerRoomIndex
        lda exit_right_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_RIGHT
        sta RoomTransitionType
        lda #1
        sta PlayerCol
        jmp converge
exit_top:
        ldx PlayerRoomIndex
        lda exit_up_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_UP
        sta RoomTransitionType
        lda #(::BATTLEFIELD_HEIGHT - 2)
        sta PlayerRow
        jmp converge
exit_bottom:
        ldx PlayerRoomIndex
        lda exit_down_lut, x
        sta PlayerRoomIndex
        lda #ROOM_TRANSITION_SLIDE_DOWN
        sta RoomTransitionType
        lda #1
        sta PlayerRow
        jmp converge
converge:
        st16 GameMode, room_transition
        ; mark the room as "busy", this prevents us clearing the next room prematurely
        lda #1
        sta first_beat_after_load
        ; suppress torchlight updates over the transition (resolves minor visual jank)
        lda #1
        sta SuppressTorchlight
        ; we may not PAUSE over the exit transition. this normally shouldn't occur, but
        ; an enemy might have forced us to the screen edge or something, so be safe
        lda #0
        sta PlayerIntendsToPause
        rts
.endproc

.proc detect_critical_existence_failure
HealingAmount := R0
        ; If we are currently in a warp zone and our stability has reached 0,
        ; eject the player!
        lda PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_WARP
        beq perform_health_check
        lda WarpStability
        bne perform_health_check
        jmp eject_player_from_warp_zone

perform_health_check:
        jsr FIXED_is_player_considered_dead
        jeq existence_proven

        ; If we are currently in a warp zone, proceed to EJECT out of the warp zone, followed
        ; by a full heal. Oops! It could be worse though.
        lda PlayerRoomIndex
        lda room_properties, x
        and #ROOM_PROPERTIES_WARP
        jne eject_player_from_warp_zone
        ; Otherwise, proceed to actually die

        ; If we wanted to pause to avoid our fate, **TOO BAD.**
        ; (yes, this means an activating on-death item can eat a pause
        ; input; deal with it.)
        lda #0
        sta PlayerIntendsToPause

        ; If we are carrying the lucky penny, consume it and revive.
        lda current_save + SaveFile::PlayerEquipmentAccessory
        cmp #ITEM_LUCKY_PENNY
        bne no_lucky_penny
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentAccessory
        jmp award_extra_life
no_lucky_penny:

        ; Similarly, if we are currently carrying the amulet of yendor, and
        ; it is real, consume it and revive.
        lda current_save + SaveFile::PlayerEquipmentAccessory
        cmp #ITEM_AMULET_OF_YENDOR
        bne no_amulet
        ; Perform the realness check, using the **run seed**. To not overcomplicate
        ; this, just add all four bytes of that seed together, and use one of the
        ; final bits as the realness check
        clc
        lda #0
        adc current_save + SaveFile::RunSeed + 0
        adc current_save + SaveFile::RunSeed + 1
        adc current_save + SaveFile::RunSeed + 2
        adc current_save + SaveFile::RunSeed + 3
        and #%00000100 ; pick a bit at random. sure, this one. why not!
        beq amulet_failed
amulet_succeeded:
        lda #ITEM_NONE
        sta current_save + SaveFile::PlayerEquipmentAccessory
        jmp award_extra_life
amulet_failed:
        ; replace the item in our hotbar with the known fake, for tombstone
        ; readout purposes, as we are about to game over
        lda #ITEM_CHEAP_PLASTIC_IMITATION_OF_THE_AMULET_OF_YENDOR
        sta current_save + SaveFile::PlayerEquipmentAccessory
no_amulet:

        ; TODO: setup for a proper "dying" beat (greyscale background, player
        ; frozen in dmg state, etc)
        ; POSTPONED: fix hearts first (later: ??? what did I mean by this?)

        ; Whelp; that's the end of the line
        ; TODO: I dunno, screen shake? palette greyscale? SFX? Juice this up.
        st16 FadeToGameMode, game_end_screen_prep
        st16 GameMode, fade_to_game_mode_from_gameplay

        ; STOP the music
        lda #TRACK_SILENCE
        ldy #TRACK_VARIANT_NORMAL
        far_call FAR_play_track

        ; Oops
        queue_sfx_pulse1 sfx_death_spin_pulse
        queue_sfx_triangle sfx_death_spin_tri
existence_proven:
        rts

eject_player_from_warp_zone:
        ; No pausing to avoid ejection. Please keep all hands and arms inside the vehicle
        ; while the ride is in motion.
        lda #0
        sta PlayerIntendsToPause
        ; mark the room as "busy", this prevents us clearing the next room prematurely
        lda #1
        sta first_beat_after_load
        ; suppress torchlight updates over the transition (resolves minor visual jank)
        lda #1
        sta SuppressTorchlight

        lda WarpPortalRoomIndex
        sta PlayerRoomIndex

        lda #ROOM_TRANSITION_WARP_EJECT
        sta RoomTransitionType
        st16 GameMode, room_transition
        rts

award_extra_life:
        ; basically just like the life spell, plus quite a long period of invulnerability to give the player
        ; an extended chance to get out of danger
        jsr brighten_room
        lda #PLAYER_STAUTS_INVULNERABLE
        sta PlayerLingeringStatusType
        lda #9
        sta PlayerLingeringStatusDuration

        ; Heal ALL the health
        lda #128
        sta HealingAmount
        near_call FAR_receive_healing

        ; Max ALL the temporary hearts
        far_call FAR_give_temporary_heart

        ; TODO: any other fun effects, like maybe temporary shield / invuln, etc
        queue_sfx_pulse1 sfx_heart_container
        queue_sfx_pulse2 sfx_heart_container
        rts
.endproc

.proc detect_pause_action
        lda PlayerIntendsToPause
        bne proceed_to_pause
        lda PlayerIsPaused
        bne continue_being_paused
        rts
proceed_to_pause:
        ; Most importantly, consume the intent!
        lda #0
        sta PlayerIntendsToPause

        ; Some actions can eat a pause intent and do nothing. Attempting to pause
        ; while holding a bomb is one such case!
        lda PlayerHeldBombIndex
        cmp #$FF
        beq not_holding_a_bomb
        rts
not_holding_a_bomb:

        ; Are we pausing or unpausing?
        lda PlayerIsPaused
        beq perform_pause
perform_unpause:
        lda #0
        sta PlayerIsPaused
        lda #BRIGHTNESS_NORMAL
        sta TargetBrightness

        far_call FAR_play_music_for_current_room

        queue_sfx_pulse1 sfx_pause

        rts
perform_pause:
        lda #1
        sta PlayerIsPaused
        lda #BRIGHTNESS_MINUS_1
        sta TargetBrightness

        lda #TRACK_VARIANT_PAUSE
        far_call FAR_play_variant

        queue_sfx_pulse1 sfx_pause

        jmp continue_being_paused
        rts

continue_being_paused:
        ; Put player in the "idle" pose during a pause
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_IDLE
        lda #$FF
        sta PlayerAnimationTable

        ; Important: do NOT process any actual game logic while we are paused!
        ; Jump ahead to battlefield drawing, which will re-use the state we just computed.
        ; (why not just wait? because beat_frame_1 still switches the buffers; we need to
        ; draw or it'll flip back to the previous frame)
        st16 GameMode, draw_battlefield_A

        rts
.endproc

.proc detect_bomb_hoist
        ; We may not hoist while paused!
        lda PlayerIsPaused
        beq not_paused
        rts
not_paused:

        lda PlayerIntendsToBomb
        bne check_hands
        rts
check_hands:
        lda PlayerHeldBombIndex
        cmp #$FF
        beq proceed_to_hoist
        ; for now, if the player is holding a bomb, take no action
        ; (later we might have specific bomb types detect this and
        ; use it as a nondirectional input?)
        rts
proceed_to_hoist:
        ; TODO: if any other actions should prevent the bomb hoist action,
        ; do that here!

        ; The bomb logic handles all of the
        ; other fiddly stuff like "do we actually have bombs" and 
        ; "are we already holding something"
        far_call FAR_try_hoist_bomb
        sta PlayerHeldBombIndex
        cmp #$FF
        beq all_done

        ; The hoist succeeded! Transition the player into the bomb holding state
        lda #PLAYER_STATE_BOMB
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState

        ; Do animation things! This should later become the "lifting bomb" pose
        ; TODO: make this much fancier. For now just force us into the idle pose
        lda #0
        sta PlayerIdleBeats
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_02_PLAYER_HOIST
        lda #$FF
        sta PlayerAnimationTable
all_done:
        rts
.endproc

spell_casting_sprite_lut:
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_FIRE_CASTING + SPRITE_OFFSET_WEAPON
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_AIR_CASTING + SPRITE_OFFSET_WEAPON
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_ICE_CASTING + SPRITE_OFFSET_WEAPON
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_EARTH_CASTING + SPRITE_OFFSET_WEAPON
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_BOMB_FIESTA_CASTING + SPRITE_OFFSET_WEAPON
        .byte <SPRITE_WEAPON_SPELLCASTING_SPELL_LIFE_CASTING + SPRITE_OFFSET_WEAPON

spell_casting_bank_lut:
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_FIRE_CASTING
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_AIR_CASTING
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_ICE_CASTING
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_EARTH_CASTING
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_BOMB_FIESTA_CASTING
        .byte >SPRITE_WEAPON_SPELLCASTING_SPELL_LIFE_CASTING

.proc detect_spell_cast
MetaSpriteIndex := R0
        ; We may not cast while paused!
        lda PlayerIsPaused
        beq not_paused
        rts
not_paused:

        lda PlayerIntendsToCast
        bne check_equipped_spell
        rts
check_equipped_spell:
        lda current_save + SaveFile::PlayerEquipmentSpell
        cmp #ITEM_NONE
        bne proceed_to_cast
        rts

proceed_to_cast:
        ; Yes, spellcasting is more important than explosions, since
        ; it is a player input associated with a major state change
        queue_sfx_pulse1_with_priority sfx_cast_pulse, #10

        ; A few spells need to affect the room, so we'll signal to the kernel that this should happen
        ; on the next beat (the kernel will consume and clear this flag)
        lda current_save + SaveFile::PlayerEquipmentSpell
        cmp #ITEM_SPELL_FIRE
        beq full_room_spell
        cmp #ITEM_SPELL_AIR
        beq full_room_spell
        cmp #ITEM_SPELL_ICE
        beq full_room_spell
        cmp #ITEM_SPELL_EARTH
        beq full_room_spell
        jmp done_with_full_room_prep
full_room_spell:
        ; Full room spells can award loot; we want this to NOT be influenced by the player's
        ; ongoing chain/combo, so reset those both
        lda #0
        sta PlayerChain
        ; note: 0 has a wraparound issue due to update order
        ; 1 is the canonical "no combo" value
        lda #1          
        sta PlayerCombo
        ; Furthermore, we need to defer loot generation until after the spell visibly
        ; takes effect
        lda #1
        sta DeferLootProcessing
        ; We need to know if the spell defeats an enemy, so we can play the
        ; defeat SFX when the spell effect ends
        lda #0
        sta SpellDefeatsEnemy
        ; Finally, tell the kernel to run spell logic on the next round of updates. Here
        ; we explicitly set the spell ID for enemy logic to use (monsters also call this system
        ; in their own way)
        ; Note that at this point, if a monster HAD queued up a spell, the player's spell overwrites it.
        ; Player spells have higher priority. (This really shouldn't happen very often.)
        lda current_save + SaveFile::PlayerEquipmentSpell
        sta CurrentlyActiveSpell
        st16 GameMode, update_spells_1
done_with_full_room_prep:

        ; Move the player into the spellcasting state
        lda #PLAYER_STATE_CASTING
        sta PlayerState
        lda #0
        sta PlayerBeatsInThisState

        ; Animate them into the... hrm. Item holding pose, yes!
        ldx PlayerSpriteIndex
        set_player_sprite_x SPRITE_PLAYER_01_PLAYER_HAND_RAISED
        lda #$FF
        sta PlayerAnimationTable

        ; Spawn in a sprite at the player's current tile coordinates, with
        ; that spell item rising up into the air, just like a death sprite
        far_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        lda #(SPRITE_ACTIVE | SPRITE_ONE_BEAT | SPRITE_RISE | SPRITE_PAL_YELLOW)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        lda #$FF
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda PlayerCol
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_X
        sta sprite_table + MetaSpriteState::PositionX, x
        lda PlayerRow
        .repeat 4
        asl
        .endrepeat
        clc
        adc #BATTLEFIELD_OFFSET_Y
        sec
        sbc #12 ; start it fairly above the player
        sta sprite_table + MetaSpriteState::PositionY, x

        lda current_save + SaveFile::PlayerEquipmentSpell
        sec
        sbc #FIRST_SPELL_IN_ITEM_LIST
        tay
        lda spell_casting_sprite_lut, y
        sta sprite_table + MetaSpriteState::TileIndex, x
        ; all spellcasting sprites are currently in the same bank, so load that in
        lda spell_casting_bank_lut, y
        sta SPRITE_BANK_WEAPON

sprite_failed:
        ; For now, that is all. Spell effects will fly elsewhere, yes!
        rts
.endproc

; If the player is currently in the throes of a lingering effect, deal with its
; means of expiry. Usually this is a beat timer counting down, but in some cases
; custom logic is needed.
.proc process_lingering_effect_expiry
        lda PlayerLingeringStatusType
        bne processing_required
        rts ; bail fast if there is nothing to do
processing_required:
        ; Normal expiry
normal_expiry:
        dec PlayerLingeringStatusDuration
        lda PlayerLingeringStatusDuration
        beq cancel_effect
        bmi cancel_effect ; shouldn't ever happen, but just to be safe
        rts
cancel_effect:
        lda #PLAYER_STATUS_NORMAL
        sta PlayerLingeringStatusType
        lda #0
        sta PlayerLingeringStatusDuration
        sta PlayerLingeringStatusFrame
        rts
.endproc

.proc process_poison_tick
IncomingDamage := R0
        lda PlayerLingeringStatusType
        cmp #PLAYER_STATUS_POISONED
        beq processing_required
        rts
processing_required:
        ; Do we have more than 1 HP? If not, do nothing! (poison weakens, but
        ; in this game it does not directly kill.)
        near_call FAR_current_health
        cmp #2
        bcc skip_poison_tick

        lda #1
        sta IncomingDamage
        near_call FAR_receive_damage

skip_poison_tick:
        rts
.endproc
