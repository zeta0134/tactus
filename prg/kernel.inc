.globalzp GameMode
.globalzp FadeToGameMode
.global CurrentBeatCounter
.global DisplayedRowCounter
.global AccumulatedGameBeats
.global RoomTransitionType

.global PlayfieldBgHighBank
.global PlayerObjHighBank
.global PlayfieldBgObjHighBank
.global HudBgHighBank
.global HudObjHighBank

.global PlayfieldObjBanks
.global HudObjBanks

; subroutines
.global FAR_kernel_game_loop

; kernel states
.global init_engine
.global room_transition
.global room_init
.global advance_to_next_floor

; is our initial split in CHR 0M or CHR 1M?
.global fade_to_game_mode_from_gameplay ; 1M
.global fade_to_game_mode_from_ui       ; 0M

.global game_prep
.global title_prep
.global options_prep
.global file_select_prep
.global game_end_screen_prep
.global name_entry_prep
.global file_details_prep
.global draw_battlefield_A
.global draw_battlefield_B
.global draw_battlefield_C

; The default AI update routine
.global update_enemies_1
; The player may switch to this to process spellcasting logic
.global update_spells_1

.globalzp ScreenShakeX
.globalzp ScreenShakeY
.globalzp PpuScrollNametable

.globalzp ScreenShakeDepth
.globalzp ScreenShakeSpeed
.globalzp ScreenShakeDecayCounter

; current default: no transition, instantly pop into the new room
ROOM_TRANSITION_NONE          = 0
; a quick, eased camera slide between adjacent rooms
ROOM_TRANSITION_SLIDE_RIGHT   = 1
ROOM_TRANSITION_SLIDE_LEFT    = 2
ROOM_TRANSITION_SLIDE_UP      = 3
ROOM_TRANSITION_SLIDE_DOWN    = 4
ROOM_TRANSITION_WARP_ENTRANCE = 5
ROOM_TRANSITION_WARP_EJECT    = 6
; TODO: more!

SPRITE_BANK_PLAYER    = PlayfieldObjBanks+0
SPRITE_BANK_WEAPON    = PlayfieldObjBanks+1
SPRITE_BANK_COMBO     = PlayfieldObjBanks+2
SPRITE_BANK_CHAIN     = PlayfieldObjBanks+3
SPRITE_BANK_ITEM_00   = PlayfieldObjBanks+4
SPRITE_BANK_ITEM_01   = PlayfieldObjBanks+5
SPRITE_BANK_ITEM_02   = PlayfieldObjBanks+6
SPRITE_BANK_ITEM_03   = PlayfieldObjBanks+7
SPRITE_BANK_STATIC_00 = PlayfieldObjBanks+8
SPRITE_BANK_STATIC_01 = PlayfieldObjBanks+9
SPRITE_BANK_STATIC_02 = PlayfieldObjBanks+10
SPRITE_BANK_STATIC_03 = PlayfieldObjBanks+11
SPRITE_BANK_STATIC_04 = PlayfieldObjBanks+12
SPRITE_BANK_STATIC_05 = PlayfieldObjBanks+13
SPRITE_BANK_STATIC_06 = PlayfieldObjBanks+14
SPRITE_BANK_STATIC_07 = PlayfieldObjBanks+15

SPRITE_BANK_HUD_STATIC_00  = HudObjBanks+0
SPRITE_BANK_HUD_STATIC_01  = HudObjBanks+1
SPRITE_BANK_HUD_STATIC_02  = HudObjBanks+2
SPRITE_BANK_HUD_STATIC_03  = HudObjBanks+3
SPRITE_BANK_HUD_STATIC_04  = HudObjBanks+4
SPRITE_BANK_HUD_STATIC_05  = HudObjBanks+5
SPRITE_BANK_BANNER_UPPER   = HudObjBanks+6
SPRITE_BANK_BANNER_LOWER   = HudObjBanks+7

SPRITE_OFFSET_PLAYER    = $00
SPRITE_OFFSET_WEAPON    = $20
SPRITE_OFFSET_COMBO     = $40
SPRITE_OFFSET_CHAIN     = $60
SPRITE_OFFSET_ITEM_00   = $80
SPRITE_OFFSET_ITEM_01   = $A0
SPRITE_OFFSET_ITEM_02   = $C0
SPRITE_OFFSET_ITEM_03   = $E0
SPRITE_OFFSET_STATIC_00 = $01
SPRITE_OFFSET_STATIC_01 = $21
SPRITE_OFFSET_STATIC_02 = $41
SPRITE_OFFSET_STATIC_03 = $61
SPRITE_OFFSET_STATIC_04 = $81
SPRITE_OFFSET_STATIC_05 = $A1
SPRITE_OFFSET_STATIC_06 = $C1
SPRITE_OFFSET_STATIC_07 = $E1

SPRITE_OFFSET_HUD_STATIC_00  = $00
SPRITE_OFFSET_HUD_STATIC_01  = $20
SPRITE_OFFSET_HUD_STATIC_02  = $40
SPRITE_OFFSET_HUD_STATIC_03  = $60
SPRITE_OFFSET_HUD_STATIC_04  = $80
SPRITE_OFFSET_HUD_STATIC_05  = $A0
SPRITE_OFFSET_BANNER_UPPER   = $C0
SPRITE_OFFSET_BANNER_LOWER   = $E0

SPRITE_BANK_UI_00 = PlayfieldObjBanks+0
SPRITE_BANK_UI_01 = PlayfieldObjBanks+1
SPRITE_BANK_UI_02 = PlayfieldObjBanks+2
SPRITE_BANK_UI_03 = PlayfieldObjBanks+3
SPRITE_BANK_UI_04 = PlayfieldObjBanks+4
SPRITE_BANK_UI_05 = PlayfieldObjBanks+5
SPRITE_BANK_UI_06 = PlayfieldObjBanks+6
SPRITE_BANK_UI_07 = PlayfieldObjBanks+7

SPRITE_BANK_UI_HUD_00 = HudObjBanks+0
SPRITE_BANK_UI_HUD_01 = HudObjBanks+1
SPRITE_BANK_UI_HUD_02 = HudObjBanks+2
SPRITE_BANK_UI_HUD_03 = HudObjBanks+3
SPRITE_BANK_UI_HUD_04 = HudObjBanks+4
SPRITE_BANK_UI_HUD_05 = HudObjBanks+5
SPRITE_BANK_UI_HUD_06 = HudObjBanks+6
SPRITE_BANK_UI_HUD_07 = HudObjBanks+7

SPRITE_OFFSET_UI_00  = $00
SPRITE_OFFSET_UI_01  = $20
SPRITE_OFFSET_UI_02  = $40
SPRITE_OFFSET_UI_03  = $60
SPRITE_OFFSET_UI_04  = $80
SPRITE_OFFSET_UI_05  = $A0
SPRITE_OFFSET_UI_06  = $C0
SPRITE_OFFSET_UI_07  = $E0

.macro set_sprite_bank bank_number, tile_id
    lda #>tile_id
    sta bank_number
.endmacro

.macro set_player_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_PLAYER)
    sta sprite_table + MetaSpriteState::TileIndex, x
    set_sprite_bank SPRITE_BANK_PLAYER, tile_id
.endmacro

.macro set_player_sprite_y tile_id
    lda #<(tile_id + SPRITE_OFFSET_PLAYER)
    sta sprite_table + MetaSpriteState::TileIndex, y
    set_sprite_bank SPRITE_BANK_PLAYER, tile_id
.endmacro

.macro set_static_00_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_00)
    sta sprite_table + MetaSpriteState::TileIndex, x    
.endmacro

.macro set_static_01_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_01)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_02_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_02)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_02_sprite_y tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_02)
    sta sprite_table + MetaSpriteState::TileIndex, y
.endmacro

.macro set_static_03_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_03)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_04_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_04)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_05_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_05)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_06_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_06)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_static_07_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_STATIC_07)
    sta sprite_table + MetaSpriteState::TileIndex, x
.endmacro

.macro set_ui_00_sprite_x tile_id
    lda #<(tile_id + SPRITE_OFFSET_UI_00)
    sta sprite_table + MetaSpriteState::TileIndex, x    
.endmacro