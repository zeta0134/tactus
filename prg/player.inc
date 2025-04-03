.global FAR_init_player
.global FAR_init_player_inventory_new_game
.global FAR_draw_player
.global FAR_determine_player_intent
.global FAR_update_player
.global FAR_damage_player
.global FAR_player_resolve_collision
.global FAR_correct_player_pos_during_slide
.global FAR_finalize_player_pos_after_slide
.global FAR_apply_player_palette

.global row_number_to_tile_index_lut

.global PlayerRow
.global PlayerCol
.global PlayerMaxHealth
.global PlayerHealth
.global PlayerRoomIndex
.global PlayerKeys
.global PlayerSpriteIndex
.global PlayerNextDirection
.global PlayerHeldDirection
.global PlayerTorchlightRadius

.global PlayerCurrentX
.global PlayerCurrentY

.global PlayerWarpEjectCol
.global PlayerWarpEjectRow

.global EnemyDiedThisFrame
.global PlayerCombo
.global PlayerChain

.global PlayerState
.global PlayerNavState

.globalzp PlayerZonePtr
.global DestinationZonePtr

.global PlayerIntendsToWait
.global PlayerIntendsToBomb
.global PlayerIntendsToCast
.global PlayerIntendsToPause
.global PlayerIsPaused

.global PlayerPassiveDialogSquare
.global PlayerActiveDialogSquare
.global PlayerIncomingDamageDirection
.global PlayerHeldBombIndex
.global PlayerRequestsSpellBehavior

.global PlayerLingeringStatusType
.global PlayerLingeringStatusDuration

.globalzp WeaponAnimPtr
.global WeaponDrawFunc
.global WeaponSingleTargetIndex

.global SpellDefeatsEnemy
.global DeferLootProcessing

.global WarpStability
.global MusicalWarpStabilityCooldown

MAX_HEARTS = 5
MAX_GOLD = 9999

; By far the most common state, this allows the player to move,
; swing their weapon, and activate all abilities normally
PLAYER_STATE_NORMAL = 0
; We have hoisted a bomb and are currently trying to throw it.
; (most other abilities are suppressed)
PLAYER_STATE_BOMB = 1
; We are in the process of casting a spell
PLAYER_STATE_CASTING = 2
; Oops! We have definitely died, and are in the process of
; animating (hopefully with lots of dramatic juice) into our
; grave. This state will transition out of gameplay once
; entered!
PLAYER_STATE_DEAD = 3
; We are shocked! We can't take any actions until this wears off,
; and our combo/chain is forced to reset.
PLAYER_STATE_SHOCKED = 4

PLAYER_STATUS_NORMAL      = 0
PLAYER_STATUS_POISONED    = 1
PlAYER_STATUS_FROZEN      = 2
PlAYER_STATUS_SHOCKED     = 3
PLAYER_STATUS_BURNED      = 4
PlAYER_STAUTS_JUST_HEALED = 5

MAX_WARP_STABILITY = 30
BEATS_BETWEEN_NATURAL_STABILITY_DECAY = 4

.macro increase_warp_stability
.scope
    lda WarpStability
    cmp #MAX_WARP_STABILITY
    bcs done
    clc
    adc #2
    sta WarpStability
done:
.endscope
.endmacro

.macro decrease_warp_stability
.scope
    lda WarpStability
    beq done
    dec WarpStability
    beq done
    dec WarpStability
done:
.endscope
.endmacro

.macro decrease_warp_stability_each_beat
.scope
    lda MusicalWarpStabilityCooldown
    beq perform_decrease
    dec MusicalWarpStabilityCooldown
    jmp done
perform_decrease:
    lda WarpStability
    beq already_zero
    dec WarpStability
already_zero:
    lda #(BEATS_BETWEEN_NATURAL_STABILITY_DECAY-1)
    sta MusicalWarpStabilityCooldown
done:
.endscope
.endmacro