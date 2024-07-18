.global FAR_init_player
.global FAR_draw_player
.global FAR_determine_player_intent
.global FAR_update_player
.global FAR_damage_player
.global FAR_player_resolve_collision

.global row_number_to_tile_index_lut

.global PlayerRow
.global PlayerCol
.global PlayerMaxHealth
.global PlayerHealth
.globalzp PlayerWeapon
.global PlayerWeaponDmg
.globalzp PlayerWeaponPtr
.global PlayerRoomIndex
.global PlayerKeys
.global PlayerGold
.global PlayerSpriteIndex
.global PlayerZone
.global PlayerFloor
.global PlayerNextDirection
.global PlayerTorchlightRadius

.global PlayerCurrentX
.global PlayerCurrentY

.global EnemyDiedThisFrame
.global PlayerCombo
.global PlayerChain

MAX_HEARTS = 5
MAX_GOLD = 999