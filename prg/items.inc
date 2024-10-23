.struct ItemDef
    SlotId .byte
    WorldSpriteTile .byte
    WorldSpriteAttr .byte
    HudBgTile .byte
    HudBgAttr .byte
    HudSpriteTile .byte
    HudSpriteAttr .byte
    ShopCost .word
    WeaponShape .byte
    DamageFunc .addr
    TorchlightFunc .addr
    UseFunc .addr
    DmgReductionFunc .addr
.endstruct

SLOT_WEAPON     = 0
SLOT_TORCH      = 1
SLOT_ARMOR      = 2
SLOT_BOOTS      = 3
SLOT_ACCESSORY  = 4
SLOT_ITEM       = 5
SLOT_SPELL      = 6
SLOT_CONSUMABLE = 7

.global item_table

; utilities for drawing items
.global FAR_apply_item_world_metasprite
.global FAR_apply_item_hud_metasprite

; utilities for working out the (generic) effects of most items
; (some unique item effects are not covered here)
.global FAR_pickup_item
.global FAR_weapon_dmg
.global FAR_equipment_torchlight
.global FAR_dmg_reduction

; various utilities for generating loot. be mindful of the RNG seed!
.global FAR_reset_shop_tracker
.global FAR_roll_shop_loot
.global FAR_roll_gameplay_loot

