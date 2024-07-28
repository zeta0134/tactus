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
.endstruct

SLOT_WEAPON    = 0
SLOT_TORCH     = 1
SLOT_ARMOR     = 2
SLOT_BOOTS     = 3
SLOT_ACCESSORY = 4
SLOT_ITEM      = 5
SLOT_SPELL     = 6

.global item_table

ITEM_NONE          = 0
ITEM_DAGGER_L1     = 1
ITEM_BROADSWORD_L1 = 2
ITEM_BROADSWORD_L2 = 3
ITEM_BROADSWORD_L3 = 4
ITEM_LONGSWORD_L1  = 5
ITEM_LONGSWORD_L2  = 6
ITEM_LONGSWORD_L3  = 7

.global FAR_apply_item_world_metasprite
.global FAR_apply_item_hud_metasprite

.global FAR_weapon_dmg
.global FAR_reset_shop_tracker
.global FAR_roll_shop_loot
.global FAR_roll_gameplay_loot