.struct Item
    SlotId .byte
    WorldSpriteTile .byte
    WorldSpriteAttr .byte
    HudBgTile .byte
    HudBgAttr .byte
    HudSpriteTile .byte
    HudSpriteAttr .byte
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
