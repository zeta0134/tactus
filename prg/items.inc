.struct ItemDef
    SlotId .byte
    WorldSpriteTile .word
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
    ApplyPassivesFunc .addr
    IsValidLootFunc .addr
    IsConsideredHelpfulFunc .addr
    DescriptionStringPtr .addr
    DescriptionStringBank .byte
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
.global FAR_display_item_description
.global FAR_init_item_bank_allocations ; call this between rooms
.global FAR_allocate_item_bank         ; call this when allocating metasprites for items 
.global FAR_free_item_bank             ; call this when freeing those metasprites (index in R1)

; utilities for working out the (generic) effects of most items
; (some unique item effects are not covered here)
.global FAR_pickup_item
.global FAR_weapon_dmg
.global FAR_equipment_torchlight
.global FAR_dmg_reduction
.global FAR_compute_player_passives

; various utilities for generating loot. be mindful of the RNG seed!
.global FAR_reset_shop_tracker
.global FAR_roll_shop_loot
.global FAR_roll_gameplay_loot

.global FAR_give_temporary_heart
.global FAR_proc_items_on_enemy_slain
.global FAR_init_room_item_state
.global FAR_item_is_considered_valid_loot
.global FAR_item_is_considered_helpful_loot
.global FAR_init_zone_item_state
