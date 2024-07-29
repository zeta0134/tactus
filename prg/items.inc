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
ITEM_SPEAR_L1      = 8
ITEM_SPEAR_L2      = 9
ITEM_SPEAR_L3      = 10
ITEM_FLAIL_L1      = 11
ITEM_FLAIL_L2      = 12
ITEM_FLAIL_L3      = 13
ITEM_BASIC_TORCH   = 14
ITEM_LARGE_TORCH   = 15

; utilities for drawing items
.global FAR_apply_item_world_metasprite
.global FAR_apply_item_hud_metasprite

; utilities for working out the (generic) effects of most items
; (some unique item effects are not covered here)
.global FAR_weapon_dmg
.global FAR_equipment_torchlight

; various utilities for generating loot. be mindful of the RNG seed!
.global FAR_reset_shop_tracker
.global FAR_roll_shop_loot
.global FAR_roll_gameplay_loot

; torchlight provided by the player alone, so they aren't
; completely blind if they haven't found a light emitting
; item in the early game
PLAYER_BASE_TORCHLIGHT = 5