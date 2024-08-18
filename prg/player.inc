.global FAR_init_player
.global FAR_draw_player
.global FAR_determine_player_intent
.global FAR_update_player
.global FAR_damage_player
.global FAR_player_resolve_collision
.global FAR_correct_player_pos_during_slide
.global FAR_finalize_player_pos_after_slide

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

MAX_HEARTS = 5
MAX_GOLD = 9999