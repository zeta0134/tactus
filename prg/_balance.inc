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

; Default-ish enemy HP health pools. I'm not sure if I'm
; really going to stick to this tiered L1-L3+Weird approach,
; but it models the current system and this makes those levers
; easier to mess around with.

; Notably: Slimes do not have HP. They always die in 1 "hit"

ONE_HIT_HP      = 1
BASIC_HP        = 1
INTERMEDIATE_HP = 2
ADVANCED_HP     = 3

; (general note: "radius" here means manhattan distance)

; used by basic player collision routines, represents
; basically a "weak" attack. 4 HP == 1 Heart
DEFAULT_DMG       = 4

BIRB_AIR_HP       = BASIC_HP
BIRB_AIR_LOOT     = basic_loot_table

; These will eventually leave flames behind them, adding some spice
BIRB_FIRE_HP        = INTERMEDIATE_HP
BIRB_FIRE_LOOT      = advanced_loot_table

BIRB_ICE_HP         = INTERMEDIATE_HP
BIRB_ICE_LOOT       = intermediate_loot_table

BIRB_EARTH_HP       = ADVANCED_HP
BIRB_EARTH_LOOT     = advanced_loot_table

; Below this distance, spiders will prefer to move directly towards the player
SPIDER_TARGET_RADIUS = $c6 ; about 16 squares

SPIDER_ICE_IDLE_DELAY      = 3
SPIDER_ICE_HP              = BASIC_HP
SPIDER_ICE_LOOT            = basic_loot_table

SPIDER_AIR_IDLE_DELAY      = 2
SPIDER_AIR_HP              = INTERMEDIATE_HP
SPIDER_AIR_LOOT            = intermediate_loot_table

SPIDER_FIRE_IDLE_DELAY     = 1
SPIDER_FIRE_HP             = ADVANCED_HP
SPIDER_FIRE_LOOT           = advanced_loot_table

SPIDER_EARTH_IDLE_DELAY    = 2
SPIDER_EARTH_HP            = ADVANCED_HP
SPIDER_EARTH_LOOT          = advanced_loot_table

; Below this distance, zombies will prefer to move directly towards the player
ZOMBIE_TARGET_RADIUS           = $c6 ; about 16 squares

ZOMBIE_EARTH_IDLE_DELAY  = 3
ZOMBIE_EARTH_HP          = BASIC_HP
ZOMBIE_EARTH_LOOT        = basic_loot_table

ZOMBIE_AIR_IDLE_DELAY    = 2
ZOMBIE_AIR_HP            = INTERMEDIATE_HP
ZOMBIE_AIR_LOOT          = intermediate_loot_table

ZOMBIE_FIRE_IDLE_DELAY   = 1
ZOMBIE_FIRE_HP           = ADVANCED_HP
ZOMBIE_FIRE_LOOT         = advanced_loot_table

; we'll eventually complicate these by having them freeze the player when attacking
ZOMBIE_ICE_IDLE_DELAY    = 2
ZOMBIE_ICE_HP            = INTERMEDIATE_HP
ZOMBIE_ICE_LOOT          = advanced_loot_table

; Below this distance, moles will not rise out of the ground
; (intentionally very small, mostly to prevent the player from being able to
; stand on a mole hole *while* a mole is rising, which would deal way too much
; damage AND look weird)
MOLE_SUPPRESSION_RADIUS    = 2

; Basic mole, throws standard wrenches
MOLE_FIRE_POPUP_DELAY     = 2
MOLE_FIRE_VANISH_DELAY    = 2
MOLE_FIRE_HP              = BASIC_HP
MOLE_FIRE_LOOT          = intermediate_loot_table

; Should throw snowballs instead of wrenches, that freeze on contact
MOLE_ICE_POPUP_DELAY  = 0
MOLE_ICE_VANISH_DELAY = 1
MOLE_ICE_HP           = ADVANCED_HP
MOLE_ICE_LOOT        = advanced_loot_table

; Rare variant. Should throw wrenches in all four directions
MOLE_EARTH_POPUP_DELAY     = 0
MOLE_EARTH_VANISH_DELAY    = 2
MOLE_EARTH_HP              = INTERMEDIATE_HP
MOLE_EARTH_LOOT             = advanced_loot_table

; Should throw electrified wrenches, tethered to the mole by lightning
MOLE_AIR_POPUP_DELAY     = 0
MOLE_AIR_VANISH_DELAY    = 2
MOLE_AIR_HP              = INTERMEDIATE_HP
MOLE_AIR_LOOT           = advanced_loot_table

MOLE_WRENCH_DMG = 4

; Note: these attack on cardinals
MUSHROOM_FIRE_BEATS    = 4
MUSHROOM_FIRE_HP       = BASIC_HP
MUSHROOM_FIRE_LOOT     = basic_loot_table

; Note: these attack in all 8 directions
MUSHROOM_ICE_BEATS     = 4
MUSHROOM_ICE_HP        = INTERMEDIATE_HP
MUSHROOM_ICE_LOOT      = intermediate_loot_table

MUSHROOM_AIR_BEATS     = 3
MUSHROOM_AIR_HP        = ADVANCED_HP
MUSHROOM_AIR_LOOT      = advanced_loot_table

MUSHROOM_EARTH_BEATS   = 5
MUSHROOM_EARTH_HP      = INTERMEDIATE_HP
MUSHROOM_EARTH_LOOT    = advanced_loot_table

MUSHROOM_SPORE_DMG     = 4

; All slime types are defeated in one hit
; and share a loot table.
SLIME_LOOT_TABLE = tiny_loot_table

; These have a shared and quite large health pool.
; Players are meant to freeze them all at once to defeat
; the group, so the real intent of high health is to
; discourage "standard" combat and invite the player to
; explore the mechanic properly.
ONE_ARMED_BANDIT_HP            = 8
ONE_ARMED_BANDIT_LOOT_TABLE    = basic_loot_table
ONE_ARMED_BANDIT_TARGET_RADIUS = $c6 ; about 16 squares

CULTIST_SHARED_HP              = ADVANCED_HP
CULTIST_SHARED_LOOT            = advanced_loot_table

; ░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░▒▓██████████████▓▒░ ░▒▓███████▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
; ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  

BOMB_STANDARD_FUSE_LENGTH = 4
BOMB_STANDARD_THROW_DISTANCE = 3

NINJA_FOOTWRAPS_RECHARGE_COUNT = 7