.global FAR_init_hud
.global FAR_queue_hud
.global FAR_refresh_hud

.global HudMapDirty

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

chr_tile_offset EQUIPMENT_ARMOR_1, 0, 4
chr_tile_offset EQUIPMENT_ARMOR_2, 2, 4
chr_tile_offset EQUIPMENT_ARMOR_3, 4, 4
chr_tile_offset EQUIPMENT_ARMOR_4, 6, 4

chr_tile_offset EQUIPMENT_ACCESSORY_1, 0, 6
chr_tile_offset EQUIPMENT_ACCESSORY_2, 2, 6
chr_tile_offset EQUIPMENT_ACCESSORY_3, 4, 6
chr_tile_offset EQUIPMENT_ACCESSORY_4, 6, 6

chr_tile_offset EQUIPMENT_GO_GO_BOOTS, 0, 8
chr_tile_offset EQUIPMENT_BOOTS_2, 2, 8
chr_tile_offset EQUIPMENT_BOOTS_3, 4, 8
chr_tile_offset EQUIPMENT_BOOTS_4, 6, 8

chr_tile_offset EQUIPMENT_SPELL_1, 0, 12
chr_tile_offset EQUIPMENT_SPELL_2, 2, 12
chr_tile_offset EQUIPMENT_SPELL_3, 4, 12

chr_tile_offset EQUIPMENT_ITEM_1, 4, 14
chr_tile_offset EQUIPMENT_ITEM_2, 6, 14
chr_tile_offset EQUIPMENT_ITEM_3, 8, 14

HUD_WORLD_PAL  = %00000000
HUD_TEXT_PAL   = %01000000 ; text and blue are the same, the blue palette will
HUD_BLUE_PAL   = %01000000 ; always contain white in slot 3 for simple UI elements
HUD_YELLOW_PAL = %10000000
HUD_RED_PAL    = %11000000