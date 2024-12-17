.global FAR_init_player
.global FAR_draw_player
.global FAR_determine_player_intent
.global FAR_update_player
.global FAR_damage_player
.global FAR_player_resolve_collision
.global FAR_correct_player_pos_during_slide
.global FAR_finalize_player_pos_after_slide
.global FAR_apply_player_palette

.global row_number_to_tile_index_lut

.global player_equipment_by_index

.global PlayerEquipmentWeapon
.global PlayerEquipmentTorch
.global PlayerEquipmentArmor
.global PlayerEquipmentBoots
.global PlayerEquipmentAccessory
.global PlayerEquipmentBombs
.global PlayerEquipmentSpell
.global PlayerBombCount

.global PlayerRow
.global PlayerCol
.global PlayerMaxHealth
.global PlayerHealth
.global PlayerRoomIndex
.global PlayerKeys
.global PlayerGold
.global PlayerSpriteIndex
.global PlayerNextDirection
.global PlayerTorchlightRadius

.global PlayerCurrentX
.global PlayerCurrentY

.global EnemyDiedThisFrame
.global PlayerCombo
.global PlayerChain

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

.globalzp WeaponAnimPtr
.global WeaponDrawFunc
.global WeaponSingleTargetIndex

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