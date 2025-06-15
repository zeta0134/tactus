.global FAR_init_hud
.global FAR_queue_hud
.global FAR_refresh_hud

.global HudMapDirty

.global WeaponDisplayCurrent
.global TorchDisplayCurrent
.global ArmorDisplayCurrent
.global BootsDisplayCurrent
.global AccessoryDisplayCurrent
.global SpellDisplayCurrent
.global ItemDisplayCurrent
.global ItemCountCurrent

.macro chr_tile_offset ident, tile_x, tile_y
ident = ((tile_y * 16) + tile_x)
.endmacro

chr_tile_offset BLANK_TILE, 0, 0

chr_tile_offset EQUIPMENT_NONE,    0, 0
chr_tile_offset EQUIPMENT_BASIC_TORCH, 2, 0
chr_tile_offset EQUIPMENT_LARGE_TORCH, 4, 0
chr_tile_offset EQUIPMENT_TORCH_3, 6, 0

chr_tile_offset EQUIPMENT_WEAPON_DAGGER,     0, 2
chr_tile_offset EQUIPMENT_WEAPON_BROADSWORD, 2, 2
chr_tile_offset EQUIPMENT_WEAPON_LONGSWORD,  4, 2
chr_tile_offset EQUIPMENT_WEAPON_SPEAR,      6, 2
chr_tile_offset EQUIPMENT_WEAPON_FLAIL,      8, 2

chr_tile_offset EQUIPMENT_ARMOR_SHIELD,        0, 4
chr_tile_offset EQUIPMENT_ARMOR_TSHIRT_TEXT,   2, 4
chr_tile_offset EQUIPMENT_ARMOR_TSHIRT_FLORAL, 4, 4
chr_tile_offset EQUIPMENT_ARMOR_TSHIRT_SKULL,  6, 4

chr_tile_offset EQUIPMENT_ACCESSORY_CHAIN_LINK, 0, 6
chr_tile_offset EQUIPMENT_OBSIDIAN_RING,        2, 6
chr_tile_offset EQUIPMENT_RUBY_NECKLACE,        4, 6
chr_tile_offset EQUIPMENT_TOPAZ_EARRINGS,       6, 6
chr_tile_offset EQUIPMENT_SAPPHIRE_BRACELET,    8, 6

chr_tile_offset EQUIPMENT_GO_GO_BOOTS,     0, 8
chr_tile_offset EQUIPMENT_NINJA_FOOTWRAPS, 2, 8
chr_tile_offset EQUIPMENT_BOOTS_3,         4, 8
chr_tile_offset EQUIPMENT_BOOTS_4,         6, 8

chr_tile_offset EQUIPMENT_NINJA_FOOTWRAPS_RECHARGE_BASE,  0, 10

chr_tile_offset EQUIPMENT_SPELL_FIRE,         0, 12
chr_tile_offset EQUIPMENT_SPELL_AIR,          2, 12
chr_tile_offset EQUIPMENT_SPELL_ICE,          4, 12
chr_tile_offset EQUIPMENT_SPELL_EARTH,        6, 12
chr_tile_offset EQUIPMENT_SPELL_BOMB_FIESTA,  8, 12
chr_tile_offset EQUIPMENT_SPELL_LIFE,        10, 12

chr_tile_offset EQUIPMENT_BOMB_STANDARD, 4, 14
chr_tile_offset EQUIPMENT_ITEM_2, 6, 14
chr_tile_offset EQUIPMENT_ITEM_3, 8, 14
