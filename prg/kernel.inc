.globalzp GameMode
.globalzp FadeToGameMode
.global CurrentBeatCounter
.global DisplayedRowCounter
.global AccumulatedGameBeats
.global RoomTransitionType

.global PlayfieldBgHighBank
.global PlayfieldObjHighBank
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
ROOM_TRANSITION_NONE        = 0
; a quick, eased camera slide between adjacent rooms
ROOM_TRANSITION_SLIDE_RIGHT = 1
ROOM_TRANSITION_SLIDE_LEFT  = 2
ROOM_TRANSITION_SLIDE_UP    = 3
ROOM_TRANSITION_SLIDE_DOWN  = 4
; TODO: more!

SPRITE_BANK_PLAYER  = PlayfieldObjBanks+0
SPRITE_BANK_WEAPON  = PlayfieldObjBanks+1
SPRITE_BANK_COMBO   = PlayfieldObjBanks+2
SPRITE_BANK_CHAIN   = PlayfieldObjBanks+3
SPRITE_BANK_ITEM0   = PlayfieldObjBanks+4
SPRITE_BANK_ITEM1   = PlayfieldObjBanks+5
SPRITE_BANK_ITEM2   = PlayfieldObjBanks+6
SPRITE_BANK_ITEM3   = PlayfieldObjBanks+7
SPRITE_BANK_STATIC0 = PlayfieldObjBanks+8
SPRITE_BANK_STATIC1 = PlayfieldObjBanks+9
SPRITE_BANK_STATIC2 = PlayfieldObjBanks+10
SPRITE_BANK_STATIC3 = PlayfieldObjBanks+11
SPRITE_BANK_STATIC4 = PlayfieldObjBanks+12
SPRITE_BANK_STATIC5 = PlayfieldObjBanks+13
SPRITE_BANK_STATIC6 = PlayfieldObjBanks+14
SPRITE_BANK_STATIC7 = PlayfieldObjBanks+15

SPRITE_BANK_BANNER_UPPER = HudObjBanks+0
SPRITE_BANK_BANNER_LOWER = HudObjBanks+1
SPRITE_BANK_HUD_STATIC0  = HudObjBanks+2
SPRITE_BANK_HUD_STATIC1  = HudObjBanks+3
SPRITE_BANK_HUD_STATIC2  = HudObjBanks+4
SPRITE_BANK_HUD_STATIC3  = HudObjBanks+5
SPRITE_BANK_HUD_STATIC4  = HudObjBanks+6
SPRITE_BANK_HUD_STATIC5  = HudObjBanks+7

SPRITE_OFFSET_PLAYER  = $00
SPRITE_OFFSET_WEAPON  = $20
SPRITE_OFFSET_COMBO   = $40
SPRITE_OFFSET_CHAIN   = $60
SPRITE_OFFSET_ITEM0   = $80
SPRITE_OFFSET_ITEM1   = $A0
SPRITE_OFFSET_ITEM2   = $C0
SPRITE_OFFSET_ITEM3   = $E0
SPRITE_OFFSET_STATIC0 = $01
SPRITE_OFFSET_STATIC1 = $21
SPRITE_OFFSET_STATIC2 = $41
SPRITE_OFFSET_STATIC3 = $61
SPRITE_OFFSET_STATIC4 = $81
SPRITE_OFFSET_STATIC5 = $A1
SPRITE_OFFSET_STATIC6 = $C1
SPRITE_OFFSET_STATIC7 = $E1

SPRITE_OFFSET_BANNER_UPPER = $00
SPRITE_OFFSET_BANNER_LOWER = $20
SPRITE_OFFSET_HUD_STATIC0  = $40
SPRITE_OFFSET_HUD_STATIC1  = $60
SPRITE_OFFSET_HUD_STATIC2  = $80
SPRITE_OFFSET_HUD_STATIC3  = $A0
SPRITE_OFFSET_HUD_STATIC4  = $C0
SPRITE_OFFSET_HUD_STATIC5  = $E0

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