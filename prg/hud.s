        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"
HudState: .res 2

HeartDisplayTarget: .res 6
HeartDisplayCurrent: .res 6

HudMapDirty: .res 1
CurrentMapIndex: .res 1

ZoneTarget: .res 1
ZoneCurrent: .res 1
FloorTarget: .res 1
FloorCurrent: .res 1

DisplayedGold: .res 2
GoldSfxCooldown: .res 1

WeaponDisplayTarget: .res 1
WeaponDisplayCurrent: .res 1
TorchDisplayTarget: .res 1
TorchDisplayCurrent: .res 1
ArmorDisplayTarget: .res 1
ArmorDisplayCurrent: .res 1
AccessoryDisplayTarget: .res 1
AccessoryDisplayCurrent: .res 1
BootsDisplayTarget: .res 1
BootsDisplayCurrent: .res 1
SpellDisplayTarget: .res 1
SpellDisplayCurrent: .res 1
ItemDisplayTarget: .res 1
ItemDisplayCurrent: .res 1

.segment "CODE_0"

HUD_TILE_BASE        = $5300
HUD_NAMETABLE_OFFSET = $0400
HUD_ATTR_OFFSET      = $0800

ROW_0 = (32*0)
ROW_1 = (32*1)
ROW_2 = (32*2)
ROW_3 = (32*3)
ROW_4 = (32*4)
ROW_5 = (32*5)

.macro tile_offset ident, tile_x, tile_y
ident = ((tile_y * 16) + tile_x)
.endmacro

tile_offset BLANK_TILE, 0, 0

tile_offset MAP_BORDER_TL, 6,  8
tile_offset MAP_BORDER_TM, 7,  8
tile_offset MAP_BORDER_TR, 8,  8
tile_offset MAP_BORDER_ML, 6,  9
tile_offset MAP_BORDER_MR, 8,  9
tile_offset MAP_BORDER_BL, 6, 10
tile_offset MAP_BORDER_BM, 7, 10
tile_offset MAP_BORDER_BR, 8, 10

tile_offset COIN_ICON, 0, 7
tile_offset COIN_X,    1, 7

tile_offset FULL_HEART_BASE,          0, 5
tile_offset FULL_HEART_BEATING,       2, 5
tile_offset ARMORED_HEART_BASE,       4, 5
tile_offset ARMORED_HEART_BEATING,    6, 5
tile_offset ARMORED_HEART_DEPLETED,   8, 5
tile_offset FRAGILE_HEART_BASE,      10, 5
tile_offset FRAGILE_HEART_BEATING,   12, 5
tile_offset HEART_CONTAINER_BASE,    12, 7
tile_offset HEART_CONTAINER_BEATING, 14, 7

tile_offset SPELL_A_DISABLED,   0, 14
tile_offset SPELL_B_DISABLED,   0, 15
tile_offset SPELL_A_ENABLED,    2, 14
tile_offset SPELL_B_ENABLED,    2, 15

tile_offset SPELL_DISABLED_BL_CORNER, 1, 14

tile_offset EQUIPMENT_NONE,    0, 0
tile_offset EQUIPMENT_TORCH_1, 2, 0
tile_offset EQUIPMENT_TORCH_2, 4, 0
tile_offset EQUIPMENT_TORCH_3, 6, 0

tile_offset EQUIPMENT_WEAPON_DAGGER,     0, 2
tile_offset EQUIPMENT_WEAPON_BROADSWORD, 2, 2
tile_offset EQUIPMENT_WEAPON_LONGSWORD,  4, 2
tile_offset EQUIPMENT_WEAPON_SPEAR,      6, 2
tile_offset EQUIPMENT_WEAPON_FLAIL,      8, 2

tile_offset EQUIPMENT_ARMOR_1, 0, 4
tile_offset EQUIPMENT_ARMOR_2, 2, 4
tile_offset EQUIPMENT_ARMOR_3, 4, 4
tile_offset EQUIPMENT_ARMOR_4, 6, 4

tile_offset EQUIPMENT_ACCESSORY_1, 0, 6
tile_offset EQUIPMENT_ACCESSORY_2, 2, 6
tile_offset EQUIPMENT_ACCESSORY_3, 4, 6
tile_offset EQUIPMENT_ACCESSORY_4, 6, 6

tile_offset EQUIPMENT_BOOTS_1, 0, 8
tile_offset EQUIPMENT_BOOTS_2, 2, 8
tile_offset EQUIPMENT_BOOTS_3, 4, 8
tile_offset EQUIPMENT_BOOTS_4, 6, 8

tile_offset EQUIPMENT_SPELL_1, 0, 12
tile_offset EQUIPMENT_SPELL_2, 2, 12
tile_offset EQUIPMENT_SPELL_3, 4, 12

tile_offset EQUIPMENT_ITEM_1, 4, 14
tile_offset EQUIPMENT_ITEM_2, 6, 14
tile_offset EQUIPMENT_ITEM_3, 8, 14

; the only one of the above that's implemented at the moment is weapon, so
; deal with that here

weapon_tile_table:
        .byte EQUIPMENT_NONE
        .byte EQUIPMENT_WEAPON_DAGGER
        .byte EQUIPMENT_WEAPON_BROADSWORD
        .byte EQUIPMENT_WEAPON_LONGSWORD
        .byte EQUIPMENT_WEAPON_SPEAR
        .byte EQUIPMENT_WEAPON_FLAIL

torch_tile_table:
        .byte EQUIPMENT_NONE
        .byte EQUIPMENT_TORCH_1
        .byte EQUIPMENT_TORCH_2
        .byte EQUIPMENT_TORCH_3

armor_tile_table:
        .byte EQUIPMENT_NONE
        .byte EQUIPMENT_ARMOR_1
        .byte EQUIPMENT_ARMOR_2
        .byte EQUIPMENT_ARMOR_3
        .byte EQUIPMENT_ARMOR_4

accessory_tile_table:
        .byte EQUIPMENT_NONE
        .byte EQUIPMENT_ACCESSORY_1
        .byte EQUIPMENT_ACCESSORY_2
        .byte EQUIPMENT_ACCESSORY_3
        .byte EQUIPMENT_ACCESSORY_4

boots_tile_table:
        .byte EQUIPMENT_NONE
        .byte EQUIPMENT_BOOTS_1
        .byte EQUIPMENT_BOOTS_2
        .byte EQUIPMENT_BOOTS_3
        .byte EQUIPMENT_BOOTS_4

spell_tile_table:
        .byte EQUIPMENT_NONE    ; note: needs a special case to deal with the BL corner
        .byte EQUIPMENT_SPELL_1
        .byte EQUIPMENT_SPELL_2
        .byte EQUIPMENT_SPELL_3

item_tile_table:
        .byte EQUIPMENT_NONE    ; note: needs a special case to deal with the BL corner
        .byte EQUIPMENT_ITEM_1
        .byte EQUIPMENT_ITEM_2
        .byte EQUIPMENT_ITEM_3

TILE_COL_OFFSET = 1
TILE_ROW_OFFSET = 16

.macro draw_tile_at_x row, tile_id, attr
        lda tile_id
        sta HUD_TILE_BASE + row, x
        sta HUD_TILE_BASE + row + HUD_NAMETABLE_OFFSET, x
        lda attr
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + row, x
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + row + HUD_NAMETABLE_OFFSET, x
.endmacro

WORLD_PAL  = %00000000
TEXT_PAL   = %01000000 ; text and blue are the same, the blue palette will
BLUE_PAL   = %01000000 ; always contain white in slot 3 for simple UI elements
YELLOW_PAL = %10000000
RED_PAL    = %11000000

weapon_palette_table:
        .byte %00, %01, %10, %11

; Called once when entering the main gameplay mode. Called
; again each time this mode is entered from another mode.
; Let's assume it may be called multiple times in a given
; play session.
.proc FAR_init_hud
        st16 HudState, hud_state_init
        rts
.endproc

; Called just after the player has finished their update, on
; the first frame of a given beat. Use this to update any state
; related to the player's most recent activities
.proc FAR_refresh_hud
        jsr update_zone_state
        jsr update_equipment
        rts
.endproc

; Called once on every frame. Mostly use this to draw the HUD and
; operate its per-frame timings for animations.
.proc FAR_queue_hud
        jmp (HudState)
.endproc

; States!

.proc hud_state_init
        lda #1
        sta HudMapDirty
        lda #0
        sta CurrentMapIndex
        lda #$FF
        sta ZoneCurrent
        sta FloorCurrent
        sta WeaponDisplayCurrent
        sta TorchDisplayCurrent
        sta ArmorDisplayCurrent
        sta AccessoryDisplayCurrent
        sta BootsDisplayCurrent
        sta SpellDisplayCurrent
        sta ItemDisplayCurrent

        jsr draw_static_hud_elements
        mov16 DisplayedGold, PlayerGold
        jsr draw_coin_counter
        st16 HudState, hud_state_update
        rts
.endproc

.proc hud_state_update
        jsr update_heart_state
        jsr draw_hearts
        jsr draw_map_tiles
        jsr draw_current_zone
        jsr draw_equipment
        jsr update_coin_counter
        rts
.endproc

; Update functions!

; the top 5 bits are the type of heart this is,
; and the lower 2 bits describe a "fullness" in quarter-hearts
HEART_STATE_NONE    = $00
HEART_STATE_REGULAR = $10
; bit 2 is used for beat tracking, to have the hearts pulse along
; with the rhythm
HEART_STATE_BEATING = $08

.proc update_heart_state
CurrentBeat := R0
TargetHealth := R1
        ; if the player has more than 4 hearts, use an 8-beat pattern
        lda PlayerMaxHealth
        cmp #17
        bcs use_8_beats
use_4_beats:
        lda currently_playing_row
        and #%00011000
        jmp done_picking_beat_length
use_8_beats:
        lda currently_playing_row
        and #%00111000
done_picking_beat_length:
        .repeat 3
        lsr
        .endrepeat
        sta CurrentBeat

        ; TODO: player health needs to be pretty much completely rethought.
        ; This gets the old half-heart system working, but we want to transition
        ; to quarter-heart display later, and eventually treat each heart container
        ; as its own bespoke entity.

        ldx #0 ; heart container
loop:
        lda PlayerMaxHealth
        lsr
        lsr
        sta TargetHealth
        cpx TargetHealth
        bcs empty_heart

        ; for now, treat player health as half-hearts
        ; if health is >= than the current slot number, then
        ; fill all quarter-hearts
        lda PlayerHealth
        lsr
        lsr
        sta TargetHealth
        cpx TargetHealth
        bcc full_quarter_hearts
        beq variable_quarter_hearts
empty_quarter_hearts:
        lda #(%00000000 | HEART_STATE_REGULAR)
        jmp apply_beat_counter
full_quarter_hearts:
        lda #(%00000100 | HEART_STATE_REGULAR)
        jmp apply_beat_counter
variable_quarter_hearts:
        ; mask the player's health and display that number
        ; of quarter-hearts here
        lda PlayerHealth
        and #%00000011
        ora #HEART_STATE_REGULAR
        jmp apply_beat_counter
apply_beat_counter:
        ; if we are on the curernt beat, this will be a beating heart
        cpx CurrentBeat
        bne converge
        ora #HEART_STATE_BEATING
        jmp converge
empty_heart:
        lda #HEART_STATE_NONE
converge:
        sta HeartDisplayTarget, x
        inx
        cpx #6
        bne loop
        rts
.endproc

; Drawing functions!

.proc draw_hearts
        ldx #2 ; current heart offset in the HUD row
        ldy #0 ; current heart index in the current/target state lists
loop:
        perform_zpcm_inc
        lda HeartDisplayTarget, y
        cmp HeartDisplayCurrent, y
        beq skip_heart
        ; we're about to draw this heart, so update the target state
        sta HeartDisplayCurrent, y
        ; now perform the draw; first, branch based on the heart type
        and #%11110000
        cmp #HEART_STATE_NONE
        beq empty_heart
        cmp #HEART_STATE_REGULAR
        beq regular_heart
        ; if we got here, something went wrong! draw nothing
        inx
        inx
        jmp done_with_this_heart
empty_heart:
        jsr draw_empty_heart
        jmp done_with_this_heart
regular_heart:
        jsr draw_regular_heart
        jmp done_with_this_heart
skip_heart:
        inx
        inx
done_with_this_heart:
        iny
        cpy #6
        bne loop
        rts
.endproc

; note: all heart drawing functions expect Y to contain
; the heart index, and X to contain the current tile column for drawing.
; upon completion, Y is left alone, and X is incremented twice
.proc draw_empty_heart
        perform_zpcm_inc
        draw_tile_at_x ROW_3, #BLANK_TILE, #(RED_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #BLANK_TILE, #(RED_PAL | CHR_BANK_HUD)
        inx
        draw_tile_at_x ROW_3, #BLANK_TILE, #(RED_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #BLANK_TILE, #(RED_PAL | CHR_BANK_HUD)
        inx
        rts
.endproc

.proc draw_regular_heart
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
        perform_zpcm_inc
        ; is this a beating heart?
        lda HeartDisplayTarget, y
        and #%00001000
        beq inert_heart
beating_heart:
        lda #FULL_HEART_BEATING
        sta HeartFullBase
        lda #HEART_CONTAINER_BEATING
        sta HeartEmptyBase
        jmp done_with_beating_checks
inert_heart:
        lda #FULL_HEART_BASE
        sta HeartFullBase
        lda #HEART_CONTAINER_BASE
        sta HeartEmptyBase
done_with_beating_checks:

        perform_zpcm_inc

top_left:
        lda HeartDisplayTarget, y
        and #%00000111 ; is the top-left quarter empty?
        cmp #1
        bcc top_left_empty
top_left_full:
        lda HeartFullBase
        jmp draw_top_left
top_left_empty:
        lda HeartEmptyBase
draw_top_left:
        sta TileId
        draw_tile_at_x ROW_3, TileId, #(RED_PAL | CHR_BANK_HUD)

        perform_zpcm_inc

bottom_left:
        lda HeartDisplayTarget, y
        and #%00000111 ; is the top-left quarter empty?
        cmp #2
        bcc bottom_left_empty
bottom_left_full:
        lda HeartFullBase
        jmp draw_bottom_left
bottom_left_empty:
        lda HeartEmptyBase
draw_bottom_left:
        clc
        adc #TILE_ROW_OFFSET
        sta TileId
        draw_tile_at_x ROW_4, TileId, #(RED_PAL | CHR_BANK_HUD)

        perform_zpcm_inc
        inx

top_right:
        lda HeartDisplayTarget, y
        and #%00000111 ; is the top-left quarter empty?
        cmp #4
        bcc top_right_empty
top_right_full:
        lda HeartFullBase
        jmp draw_top_right
top_right_empty:
        lda HeartEmptyBase
draw_top_right:
        clc
        adc #TILE_COL_OFFSET
        sta TileId
        draw_tile_at_x ROW_3, TileId, #(RED_PAL | CHR_BANK_HUD)

        perform_zpcm_inc

bottom_right:
        lda HeartDisplayTarget, y
        and #%00000111 ; is the top-left quarter empty?
        cmp #3
        bcc bottom_right_empty
bottom_right_full:
        lda HeartFullBase
        jmp draw_bottom_right
bottom_right_empty:
        lda HeartEmptyBase
draw_bottom_right:
        clc
        adc #TILE_COL_OFFSET + TILE_ROW_OFFSET
        sta TileId
        draw_tile_at_x ROW_4, TileId, #(RED_PAL | CHR_BANK_HUD)

        perform_zpcm_inc
        inx

        rts
.endproc

.proc draw_static_hud_elements
        perform_zpcm_inc
        ; first, draw the border around the minimap
        ldx #19
        ; left side
        draw_tile_at_x ROW_0, #MAP_BORDER_TL, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_ML, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_ML, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_ML, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_ML, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BL, #(BLUE_PAL | CHR_BANK_HUD)
        inx
        ; center loop
loop:
        perform_zpcm_inc
        draw_tile_at_x ROW_0, #MAP_BORDER_TM, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BM, #(BLUE_PAL | CHR_BANK_HUD)
        inx
        cpx #30
        bne loop

        perform_zpcm_inc
        ; right side
        draw_tile_at_x ROW_0, #MAP_BORDER_TR, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_MR, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_MR, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_MR, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_MR, #(BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BR, #(BLUE_PAL | CHR_BANK_HUD)

        ; coin counter, static tiles
        ldx #14
        draw_tile_at_x ROW_4, #COIN_ICON, #(YELLOW_PAL | CHR_BANK_HUD)
        ldx #15
        draw_tile_at_x ROW_4, #COIN_X, #(BLUE_PAL | CHR_BANK_HUD)

        perform_zpcm_inc

        rts
.endproc

MINIMAP_BASE = (ROW_1+24)

tile_offset BOSS_ROOM, 0, 1
tile_offset DOOR_ROOM, 0, 2
tile_offset SHOP_ROOM, 0, 3
tile_offset WARP_ROOM, 0, 4

tile_offset BOSS_ROOM_CURRENT, 14, 5
tile_offset DOOR_ROOM_CURRENT, 15, 5
tile_offset SHOP_ROOM_CURRENT, 14, 6
tile_offset WARP_ROOM_CURRENT, 15, 6

.proc draw_minimap_tile
RoomIndex := R0
DrawIndex := R1
DrawTile := R2
NametableAddr := R12
AttributeAddr := R14
        ; compute the destination tile based on the room index
        ; TODO: adjust this for 8x4 mode when we implement that, currently
        ; it's tuned for 4x4
        lda RoomIndex
        and #%00001100 ; isolate the row, which is currently x4
        asl ; x8
        asl ;x16
        asl ;x32
        sta DrawIndex
        lda RoomIndex
        and #%00000011 ; isolate the column
        ora DrawIndex
        sta DrawIndex

        ; Figure out what tile we should draw here
        ldx RoomIndex
        lda room_flags, x
        
        ; can we see this room at all? any room that has been either
        ; visited OR revealed should be displayed
        and #(ROOM_FLAG_VISITED | ROOM_FLAG_REVEALED)
        beq room_hidden
        ; DEBUG: all rooms start at least 'revealed' for testing

        ; check for special room types, which right now include boss
        ; rooms and exit doors
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_room
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        bne door_room
        jmp normal_room

boss_room:
        ; If the boss has been cleared, draw this like a normal room instead
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne normal_room

        ; load the appropriate boss tile, based on whether the player is
        ; currently in this room or not
        lda PlayerRoomIndex
        cmp RoomIndex
        beq current_boss_room
regular_boss_room:
        lda #BOSS_ROOM
        sta DrawTile
        jmp draw_tile
current_boss_room:
        lda #BOSS_ROOM_CURRENT
        sta DrawTile
        jmp draw_tile

door_room:
        ; load the appropriate door tile, based on whether the player is
        ; currently in this room or not
        lda PlayerRoomIndex
        cmp RoomIndex
        beq current_door_room
regular_door_room:
        lda #DOOR_ROOM
        sta DrawTile
        jmp draw_tile
current_door_room:
        lda #DOOR_ROOM_CURRENT
        sta DrawTile
        jmp draw_tile

normal_room:
        ; Start with the room's "revealed" tile
        lda room_properties, x
        and #%00001111
        sta DrawTile
        ; If the player hasn't visited this room, we're done
        lda room_flags, x
        and #ROOM_FLAG_VISITED
        beq draw_tile
        ; If the player HAS visited the room, start by moving to the "visited" row
        lda DrawTile
        clc
        adc #16
        sta DrawTile
        ; if this is a "lit" room, add another 16 to move to that row
        ; (DEBUG: all rooms are lit for now)
        lda DrawTile
        clc
        adc #16
        sta DrawTile
        ; finally, if this is our current room, then we need to jump to the "flashing cursor" tile
        lda PlayerRoomIndex
        cmp RoomIndex
        bne draw_tile
        lda DrawTile
        clc
        adc #32
        sta DrawTile

        jmp draw_tile

room_hidden:
        lda #BLANK_TILE
        sta DrawTile
        ; fall through
draw_tile:
        ldx DrawIndex
        draw_tile_at_x MINIMAP_BASE, DrawTile, #(TEXT_PAL | CHR_BANK_HUD)

        rts
.endproc

.proc draw_map_tiles
RoomIndex := R0
        ; sanity check: is the map in need of drawing?
        ; if the index is 0 AND the map is not currently dirty...
        lda CurrentMapIndex
        bne proceed_to_draw ; we've already started a draw, see it through
        lda HudMapDirty
        bne begin_to_draw
        ; ... then continue waiting
        rts
begin_to_draw:
        ; clear the dirty flag, as we just consumed it
        lda #0
        sta HudMapDirty
proceed_to_draw:
        ; TODO: this does one tile per update, which is a bit slow. we could probably
        ; call this in a loop, tuned for performance
        sta RoomIndex
        jsr draw_minimap_tile
        inc CurrentMapIndex
        lda CurrentMapIndex
        cmp #16
        bne done
        lda #0
        sta CurrentMapIndex
done:
        rts
.endproc

.proc update_zone_state
        ; TODO: rethink zones entirely, update this logic (maybe consume player zone directly)
        lda PlayerZone
        sec
        sbc #1
        sta ZoneTarget
        lda PlayerFloor
        sec
        sbc #1
        sta FloorTarget
        rts
.endproc

.proc draw_current_zone
BannerBase := R0
DrawTile := R1
        lda ZoneTarget
        cmp ZoneCurrent
        bne proceed_to_draw
        lda FloorTarget
        cmp FloorCurrent
        bne proceed_to_draw
        rts
proceed_to_draw:
        perform_zpcm_inc
        lda ZoneTarget
        sta ZoneCurrent
        lda FloorTarget
        sta FloorCurrent

        ; The banner base is determined by the current zone index
        lda ZoneCurrent
        asl
        sta BannerBase

        ; first draw the top banner. the row is determined by the
        ; current floor index, from 0-4:
        lda FloorCurrent
        .repeat 4
        asl
        .endrepeat
        ora BannerBase
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_1, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_1, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)

        perform_zpcm_inc

        ; now proceed with the rest of the banner, which is always at a
        ; fixed "row" of 5 within the banner graphics
        lda #(5*16)
        ora BannerBase
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_2, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_2, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)

        clc
        lda DrawTile
        adc #15
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_3, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_3, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)

        perform_zpcm_inc

        clc
        lda DrawTile
        adc #15
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_4, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_4, DrawTile, #(WORLD_PAL | CHR_BANK_ZONES)

        ; and that should be it!
        perform_zpcm_inc

        rts
.endproc

; Reacts to the game state to perform a slow, rolling update of the
; coin counter when the player picks up gold, or loses it (via the
; yet-unimplemented shop mechanic)
.proc update_coin_counter
NumberWord := R0
OnesDigit := R2
TensDigit := R3
HundredsDigit := R4
ThousandsDigit := R5
TenThousandsDigit := R6
        ; always perform the visual update, so we increase/decrease the counter
        ; at 1 gold / frame
        cmp16 PlayerGold, DisplayedGold
        beq done
        bcc decrease_needed
increase_needed:
        inc16 DisplayedGold
        jmp converge
decrease_needed:
        dec16 DisplayedGold
        jmp converge
converge:
        jsr draw_coin_counter 

        ; only play the cash SFX if we haven't started it within some number of frames, just
        ; to make sure it isn't trampling all over itself
        lda GoldSfxCooldown
        beq play_coin_sfx
        dec GoldSfxCooldown
        rts
        
play_coin_sfx:
        st16 R0, sfx_cash_flow
        jsr play_sfx_pulse1

        lda #3
        sta GoldSfxCooldown
        rts
done:
        ; be sure to reset the cooldown, so that the next time our gold changes, the SFX starts
        ; playing right away
        lda #0
        sta GoldSfxCooldown
        rts
.endproc

; Draws the coin counter immediately. Make sure DisplayedGold is set first!
.proc draw_coin_counter
NumberWord := R0
OnesDigit := R2
TensDigit := R3
HundredsDigit := R4
ThousandsDigit := R5
TenThousandsDigit := R6
        mov16 NumberWord, DisplayedGold
        jsr base_10
        ldx #16
        draw_tile_at_x ROW_4, HundredsDigit, #(TEXT_PAL | CHR_BANK_OLD_CHRRAM)
        ldx #17
        draw_tile_at_x ROW_4, TensDigit, #(TEXT_PAL | CHR_BANK_OLD_CHRRAM)
        ldx #18
        draw_tile_at_x ROW_4, OnesDigit, #(TEXT_PAL | CHR_BANK_OLD_CHRRAM)
        rts
.endproc

; given a 16bit number, computes the individual digit tiles (in base 10)
; does not actually draw the number, meant to be consumed by other routines
; that perform this task
.proc base_10
NumberWord := R0
OnesDigit := R2
TensDigit := R3
HundredsDigit := R4
ThousandsDigit := R5
TenThousandsDigit := R6
        perform_zpcm_inc

        lda #NUMBERS_BASE
        sta TenThousandsDigit
ten_thousands_loop:
        cmp16 NumberWord, #10000
        bcc compute_thousands
        inc TenThousandsDigit
        sub16w NumberWord, 10000
        jmp ten_thousands_loop

compute_thousands:
        lda #NUMBERS_BASE
        sta ThousandsDigit
thousands_loop:
        cmp16 NumberWord, #1000
        bcc compute_hundreds
        inc ThousandsDigit
        sub16w NumberWord, 1000
        jmp thousands_loop

compute_hundreds:
        lda #NUMBERS_BASE
        sta HundredsDigit
hundreds_loop:
        cmp16 NumberWord, #100
        bcc compute_tens
        inc HundredsDigit
        sub16w NumberWord, 100
        jmp hundreds_loop

compute_tens:
        lda #NUMBERS_BASE
        sta TensDigit
tens_loop:
        cmp16 NumberWord, #10
        bcc compute_ones
        inc TensDigit
        sub16w NumberWord, 10
        jmp tens_loop

compute_ones:
        ; at this stage, NumberWord's lowest byte is already
        ; between 0 and 9, so just use it directly
        lda NumberWord+0
        clc
        adc #NUMBERS_BASE
        sta OnesDigit

        rts
.endproc

.proc update_equipment
        lda PlayerWeapon
        clc
        adc #1
        sta WeaponDisplayTarget

        ; hardcode a torch for now
        lda #1
        sta TorchDisplayTarget

        ; nothing else exists, so zero it out
        lda #0
        sta ArmorDisplayTarget
        sta BootsDisplayTarget
        sta AccessoryDisplayTarget
        sta SpellDisplayTarget
        sta ItemDisplayTarget

        rts
.endproc

.proc draw_equipment
DrawTile := R0
        perform_zpcm_inc

check_weapon:
        lda WeaponDisplayTarget
        cmp WeaponDisplayCurrent
        beq check_torch
        sta WeaponDisplayCurrent

        ldx WeaponDisplayCurrent
        lda weapon_tile_table, x
        sta DrawTile
        ldx #2
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #3
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        clc
        lda DrawTile
        adc #15
        sta DrawTile
        ldx #2
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #3
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_torch:
        lda TorchDisplayTarget
        cmp TorchDisplayCurrent
        beq check_armor
        sta TorchDisplayCurrent

        ldx TorchDisplayCurrent
        lda torch_tile_table, x
        sta DrawTile
        ldx #4
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #5
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        clc
        lda DrawTile
        adc #15
        sta DrawTile
        ldx #4
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #5
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_armor:
        lda ArmorDisplayTarget
        cmp ArmorDisplayCurrent
        beq check_boots
        sta ArmorDisplayCurrent

        ldx ArmorDisplayCurrent
        lda armor_tile_table, x
        sta DrawTile
        ldx #6
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #7
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        clc
        lda DrawTile
        adc #15
        sta DrawTile
        ldx #6
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #7
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_boots:
        lda BootsDisplayTarget
        cmp BootsDisplayCurrent
        beq check_accessory
        sta BootsDisplayCurrent

        ldx BootsDisplayCurrent
        lda boots_tile_table, x
        sta DrawTile
        ldx #8
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #9
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        clc
        lda DrawTile
        adc #15
        sta DrawTile
        ldx #8
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #9
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_accessory:
        lda AccessoryDisplayTarget
        cmp AccessoryDisplayCurrent
        beq check_item
        sta AccessoryDisplayCurrent

        ldx AccessoryDisplayCurrent
        lda accessory_tile_table, x
        sta DrawTile
        ldx #10
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #11
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        clc
        lda DrawTile
        adc #15
        sta DrawTile
        ldx #10
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #11
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_item:
        lda ItemDisplayTarget
        cmp ItemDisplayCurrent
        jeq check_spell
        sta ItemDisplayCurrent

        ; here we need to handle the little tab as a special case
        ldx ItemDisplayCurrent
        cpx #0
        bne item_equipped
no_item_equipped:
        ldx #13
        draw_tile_at_x ROW_2, #SPELL_B_DISABLED, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx #14
        draw_tile_at_x ROW_2, #SPELL_DISABLED_BL_CORNER, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx ItemDisplayCurrent
        lda item_tile_table, x
        clc
        adc #16
        sta DrawTile
        jmp draw_untabbed_item_tiles
item_equipped:
        ldx #13
        draw_tile_at_x ROW_2, #SPELL_B_ENABLED, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx ItemDisplayCurrent
        lda item_tile_table, x
        clc
        adc #16
        sta DrawTile
        ldx #14
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
draw_untabbed_item_tiles:
        inc DrawTile
        ldx #15
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        sec
        lda DrawTile
        sbc #17
        sta DrawTile
        ldx #14
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #15
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

check_spell:
        lda SpellDisplayTarget
        cmp SpellDisplayCurrent
        jeq done
        sta SpellDisplayCurrent

        ; here we need to handle the little tab as a special case
        ldx SpellDisplayCurrent
        cpx #0
        bne spell_equipped
no_spell_equipped:
        ldx #16
        draw_tile_at_x ROW_2, #SPELL_A_DISABLED, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx #17
        draw_tile_at_x ROW_2, #SPELL_DISABLED_BL_CORNER, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx SpellDisplayCurrent
        lda spell_tile_table, x
        clc
        adc #16
        sta DrawTile
        jmp draw_untabbed_spell_tiles
spell_equipped:
        ldx #16
        draw_tile_at_x ROW_2, #SPELL_A_ENABLED, #(TEXT_PAL | CHR_BANK_ITEMS)
        ldx SpellDisplayCurrent
        lda spell_tile_table, x
        clc
        adc #16
        sta DrawTile
        ldx #17
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
draw_untabbed_spell_tiles:
        inc DrawTile
        ldx #18
        draw_tile_at_x ROW_2, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        sec
        lda DrawTile
        sbc #17
        sta DrawTile
        ldx #17
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        inc DrawTile
        ldx #18
        draw_tile_at_x ROW_1, DrawTile, #(TEXT_PAL | CHR_BANK_ITEMS)
        perform_zpcm_inc

done:
        perform_zpcm_inc
        rts
.endproc


; OLD CODE BELOW!!


; This is here mostly because it relies on the string drawing functions
nametable_5000_string: .asciiz "NAMETABLE AT $5000         "
nametable_5400_string: .asciiz "NAMETABLE AT $5400         "

nametable_2000_string: .asciiz " - $2000"
nametable_2400_string: .asciiz " - $2400"

.proc FAR_debug_nametable_header
StringPtr := R0
NametableAddr := R12
AttributeAddr := R14
        st16 NametableAddr, $5020
        st16 AttributeAddr, $5820
        st16 StringPtr, nametable_5000_string
        ldy #0
        jsr draw_string

        st16 NametableAddr, $5420
        st16 AttributeAddr, $5C20
        st16 StringPtr, nametable_5400_string
        ldy #0
        jsr draw_string

        ; note: rendering is disabled, so we're allowed to do this here
        st16 NametableAddr, $2032
        st16 StringPtr, nametable_2000_string
        ldy #0
        jsr draw_string_ppudata

        st16 NametableAddr, $2432
        st16 StringPtr, nametable_2400_string
        ldy #0
        jsr draw_string_ppudata

        rts
.endproc

; remarkably slow and inefficient; it's fine, it's a debug function
.proc draw_string_ppudata
StringPtr := R0
NametableAddr := R12
loop:
        perform_zpcm_inc
        set_ppuaddr NametableAddr
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        sta PPUDATA
        inc16 StringPtr
        inc16 NametableAddr
        jmp loop
end_of_string:
        rts
.endproc

.proc draw_padding
PaddingAmount := R0

NametableAddr := R12
AttributeAddr := R14

        lda PaddingAmount
        beq skip
loop:
        perform_zpcm_inc
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny
        dec PaddingAmount
        bne loop
skip:
        rts
.endproc

.proc draw_string
StringPtr := R0
VramIndex := R2

NametableAddr := R12
AttributeAddr := R14

        sty VramIndex ; preserve
loop:
        perform_zpcm_inc
        ldy #0
        lda (StringPtr), y
        beq end_of_string
        ldy VramIndex
        sta (NametableAddr), y
        lda #(TEXT_PAL | CHR_BANK_OLD_CHRRAM)
        sta (AttributeAddr), y
        inc VramIndex
        inc16 StringPtr
        jmp loop
end_of_string:
        ldy VramIndex
        rts
.endproc

.proc draw_single_digit
Digit := R0

NametableAddr := R12
AttributeAddr := R14
        lda #NUMBERS_BASE
        clc
        adc Digit
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny
        rts
.endproc

.proc draw_16bit_number
NumberWord := R0
CurrentDigit := R2
LeadingCounter := R3

NametableAddr := R12
AttributeAddr := R14

        perform_zpcm_inc
        lda #0
        sta CurrentDigit
        sta LeadingCounter
tens_of_thousands_loop:
        cmp16 NumberWord, #10000
        bcc display_tens_of_thousands
        inc CurrentDigit
        sub16w NumberWord, 10000
        jmp tens_of_thousands_loop
display_tens_of_thousands:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_ten_thousands
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_ten_thousands
blank_ten_thousands:
        lda #BLANK_TILE
draw_ten_thousands:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
thousands_loop:
        cmp16 NumberWord, #1000
        bcc display_thousands
        inc CurrentDigit
        sub16w NumberWord, 1000
        jmp thousands_loop
display_thousands:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_thousands
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_thousands
blank_thousands:
        lda #BLANK_TILE
draw_thousands:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
hundreds_loop:
        cmp16 NumberWord, #100
        bcc display_hundreds
        inc CurrentDigit
        sub16w NumberWord, 100
        jmp hundreds_loop
display_hundreds:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_hundreds
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_hundreds
blank_hundreds:
        lda #BLANK_TILE
draw_hundreds:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
tens_loop:
        cmp16 NumberWord, #10
        bcc display_tens
        inc CurrentDigit
        sub16w NumberWord, 10
        jmp tens_loop
display_tens:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_tens
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_tens
blank_tens:
        lda #BLANK_TILE
draw_tens:
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        lda #0
        sta CurrentDigit
ones_loop:
        cmp16 NumberWord, #1
        bcc display_ones
        inc CurrentDigit
        sub16w NumberWord, 1
        jmp ones_loop
display_ones:
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        sta (NametableAddr), y
        lda #TEXT_PAL
        sta (AttributeAddr), y
        iny

        perform_zpcm_inc

        rts
.endproc