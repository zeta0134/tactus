; ░▒▓███████▓▒░░▒▓█▓▒░       ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓███████▓▒░  
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓███████▓▒░░▒▓█▓▒░      ░▒▓████████▓▒░░▒▓██████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░  
; ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ 
; ░▒▓█▓▒░      ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ 

PLAYER_NORMAL_HEART_TYPE     = HEART_TYPE_REGULAR
PLAYER_NORMAL_HEART_COUNT    = 3
PLAYER_NORMAL_STARTING_GOLD  = 0
PLAYER_NORMAL_WEAPON         = ITEM_DAGGER_L1
PLAYER_NORMAL_LIGHT          = ITEM_NONE
PLAYER_NORMAL_ARMOR          = ITEM_NONE
PLAYER_NORMAL_BOOTS          = ITEM_NONE
PLAYER_NORMAL_ACCESSORY      = ITEM_NONE
PLAYER_NORMAL_BOMBS          = ITEM_NONE
PLAYER_NORMAL_SPELL          = ITEM_NONE

PLAYER_GODMODE_HEART_TYPE    = HEART_TYPE_REGULAR_ARMORED
PLAYER_GODMODE_HEART_COUNT   = 5
PLAYER_GODMODE_STARTING_GOLD = 500
PLAYER_GODMODE_WEAPON        = ITEM_SPEAR_L3
PLAYER_GODMODE_LIGHT         = ITEM_LARGE_TORCH
PLAYER_GODMODE_ARMOR         = ITEM_SHIELD
PLAYER_GODMODE_BOOTS         = ITEM_NONE
PLAYER_GODMODE_ACCESSORY     = ITEM_CHAIN_LINK
PLAYER_GODMODE_BOMBS         = ITEM_NONE
PLAYER_GODMODE_SPELL         = ITEM_NONE

PLAYER_GLASSMODE_HEART_TYPE  = HEART_TYPE_GLASS
PLAYER_GLASSMODE_HEART_COUNT = 5

; torchlight provided by the player alone, so they aren't
; completely blind if they haven't found a light emitting
; item in the early game
PLAYER_BASE_TORCHLIGHT = 5


; ░▒▓████████▓▒░▒▓███████▓▒░░▒▓████████▓▒░▒▓██████████████▓▒░░▒▓█▓▒░▒▓████████▓▒░░▒▓███████▓▒░ 
; ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░        
; ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░        
; ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓██████▓▒░  ░▒▓██████▓▒░  
; ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░ 
; ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░ 
; ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓████████▓▒░▒▓███████▓▒░  

; (general note: "radius" here means manhattan distance)

; used by basic player collision routines, represents
; basically a "weak" attack. 4 HP == 1 Heart
DEFAULT_DMG       = 4

BIRB_BASIC_HP          = 1
BIRB_BASIC_LOOT        = basic_loot_table

BIRB_INTERMEDIATE_HP   = 2
BIRB_INTERMEDIATE_LOOT = intermediate_loot_table

BIRB_ADVANCED_HP       = 4
BIRB_ADVANCED_LOOT     = advanced_loot_table


; Below this distance, spiders will prefer to move directly towards the player
SPIDER_TARGET_RADIUS = 16

SPIDER_BASIC_HP                = 2
SPIDER_BASIC_IDLE_DELAY        = 3
SPIDER_BASIC_LOOT              = basic_loot_table

SPIDER_INTERMEDIATE_HP         = 4
SPIDER_INTERMEDIATE_IDLE_DELAY = 2
SPIDER_INTERMEDIATE_LOOT       = intermediate_loot_table

SPIDER_ADVANCED_HP             = 6
SPIDER_ADVANCED_IDLE_DELAY     = 1
SPIDER_ADVANCED_LOOT           = advanced_loot_table

; Below this distance, zombies will prefer to move directly towards the player
ZOMBIE_TARGET_RADIUS           = 16

ZOMBIE_BASIC_HP                = 2
ZOMBIE_BASIC_IDLE_DELAY        = 3
ZOMBIE_BASIC_LOOT              = basic_loot_table

ZOMBIE_INTERMEDIATE_HP         = 4
ZOMBIE_INTERMEDIATE_IDLE_DELAY = 2
ZOMBIE_INTERMEDIATE_LOOT       = intermediate_loot_table

ZOMBIE_ADVANCED_HP             = 6
ZOMBIE_ADVANCED_IDLE_DELAY     = 1
ZOMBIE_ADVANCED_LOOT           = advanced_loot_table

; Below this distance, moles will not rise out of the ground
; (intentionally very small, mostly to prevent the player from being able to
; stand on a mole hole *while* a mole is rising, which would deal way too much
; damage AND look weird)
MOLE_SUPPRESSION_RADIUS    = 2

MOLE_BASIC_POPUP_DELAY     = 2
MOLE_BASIC_VANISH_DELAY    = 2
MOLE_BASIC_HP              = 2

MOLE_ADVANCED_POPUP_DELAY  = 0
MOLE_ADVANCED_VANISH_DELAY = 1
MOLE_ADVANCED_HP           = 6

MOLE_WRENCH_DMG = 4

; Note: these attack on cardinals
MUSHROOM_BASIC_BEATS        = 4
MUSHROOM_BASIC_HP           = 2
MUSHROOM_BASIC_LOOT         = basic_loot_table

; Note: these attack in all 8 directions
MUSHROOM_INTERMEDIATE_BEATS = 3
MUSHROOM_INTERMEDIATE_HP    = 4
MUSHROOM_INTERMEDIATE_LOOT  = intermediate_loot_table

MUSHROOM_ADVANCED_BEATS     = 2
MUSHROOM_ADVANCED_HP        = 6
MUSHROOM_ADVANCED_LOOT      = advanced_loot_table

MUSHROOM_WEIRD_BEATS        = 5
MUSHROOM_WEIRD_HP           = 4
MUSHROOM_WEIRD_LOOT         = advanced_loot_table

MUSHROOM_SPORE_DMG          = 4

; All slime types are defeated in one hit
; and share a loot table.
SLIME_LOOT_TABLE = tiny_loot_table

; ░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░▒▓██████████████▓▒░ ░▒▓███████▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  

