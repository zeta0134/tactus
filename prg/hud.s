        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "hud.inc"
        .include "items.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "text_util.inc"
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

WeaponDisplayCurrent: .res 1
TorchDisplayCurrent: .res 1
ArmorDisplayCurrent: .res 1
BootsDisplayCurrent: .res 1
AccessoryDisplayCurrent: .res 1
SpellDisplayCurrent: .res 1
ItemDisplayCurrent: .res 1

.segment "CODE_0"

HUD_TILE_BASE        = $52C0
HUD_NAMETABLE_OFFSET = $0400
HUD_ATTR_OFFSET      = $0800

ROW_0 = (32*0)
ROW_1 = (32*1)
ROW_2 = (32*2)
ROW_3 = (32*3)
ROW_4 = (32*4)
ROW_5 = (32*5)

chr_tile_offset MAP_BORDER_TL, 6, 7
chr_tile_offset MAP_BORDER_TM, 7, 7
chr_tile_offset MAP_BORDER_TR, 8, 7
chr_tile_offset MAP_BORDER_ML, 6, 8
chr_tile_offset MAP_BORDER_MR, 8, 8
chr_tile_offset MAP_BORDER_BL, 6, 9
chr_tile_offset MAP_BORDER_BM, 7, 9
chr_tile_offset MAP_BORDER_BR, 8, 9
chr_tile_offset COIN_ICON, 0, 7
chr_tile_offset COIN_X,    1, 7
chr_tile_offset FULL_HEART_BASE,          0, 5
chr_tile_offset FULL_HEART_BEATING,       2, 5
chr_tile_offset ARMORED_HEART_BASE,       4, 5
chr_tile_offset ARMORED_HEART_BEATING,    6, 5
chr_tile_offset ARMORED_HEART_DEPLETED,   8, 5
chr_tile_offset FRAGILE_HEART_BASE,      10, 5
chr_tile_offset FRAGILE_HEART_BEATING,   12, 5
chr_tile_offset HEART_CONTAINER_BASE,    12, 7
chr_tile_offset HEART_CONTAINER_BEATING, 14, 7
chr_tile_offset SPELL_A_DISABLED,   0, 14
chr_tile_offset SPELL_B_DISABLED,   0, 15
chr_tile_offset SPELL_A_ENABLED,    2, 14
chr_tile_offset SPELL_B_ENABLED,    2, 15
chr_tile_offset SPELL_DISABLED_BL_CORNER, 1, 14


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
        lda attr
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + row, x
.endmacro

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
        draw_tile_at_x ROW_3, #BLANK_TILE, #(HUD_RED_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #BLANK_TILE, #(HUD_RED_PAL | CHR_BANK_HUD)
        inx
        draw_tile_at_x ROW_3, #BLANK_TILE, #(HUD_RED_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #BLANK_TILE, #(HUD_RED_PAL | CHR_BANK_HUD)
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
        draw_tile_at_x ROW_3, TileId, #(HUD_RED_PAL | CHR_BANK_HUD)

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
        draw_tile_at_x ROW_4, TileId, #(HUD_RED_PAL | CHR_BANK_HUD)

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
        draw_tile_at_x ROW_3, TileId, #(HUD_RED_PAL | CHR_BANK_HUD)

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
        draw_tile_at_x ROW_4, TileId, #(HUD_RED_PAL | CHR_BANK_HUD)

        perform_zpcm_inc
        inx

        rts
.endproc

.proc draw_static_hud_elements
        perform_zpcm_inc
        ; first, draw the border around the minimap
        ldx #19
        ; left side
        draw_tile_at_x ROW_0, #MAP_BORDER_TL, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_ML, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_ML, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_ML, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_ML, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BL, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        inx
        ; center loop
loop:
        perform_zpcm_inc
        draw_tile_at_x ROW_0, #MAP_BORDER_TM, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BM, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        inx
        cpx #30
        bne loop

        perform_zpcm_inc
        ; right side
        draw_tile_at_x ROW_0, #MAP_BORDER_TR, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_MR, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_MR, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_MR, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_MR, #(HUD_BLUE_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BR, #(HUD_BLUE_PAL | CHR_BANK_HUD)

        ; coin counter, static tiles
        ldx #14
        draw_tile_at_x ROW_4, #COIN_ICON, #(HUD_YELLOW_PAL | CHR_BANK_HUD)
        ldx #15
        draw_tile_at_x ROW_4, #COIN_X, #(HUD_BLUE_PAL | CHR_BANK_HUD)

        perform_zpcm_inc

        rts
.endproc

MINIMAP_BASE = (ROW_1+22)

chr_tile_offset BOSS_ROOM, 0, 1
chr_tile_offset DOOR_ROOM, 0, 2
chr_tile_offset SHOP_ROOM, 0, 3
chr_tile_offset WARP_ROOM, 0, 4

chr_tile_offset BOSS_ROOM_CURRENT, 14, 5
chr_tile_offset DOOR_ROOM_CURRENT, 15, 5
chr_tile_offset SHOP_ROOM_CURRENT, 14, 6
chr_tile_offset WARP_ROOM_CURRENT, 15, 6

chr_tile_offset HERE_ICON_IN_THE_VOID, 0, 15
chr_tile_offset EXTERIOR_SET, 0, 13
chr_tile_offset CLEAREED_ROOM_SET, 0, 10

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
        and #%00011000 ; isolate the row, which is currently x8        
        asl ;x16
        asl ;x32
        sta DrawIndex
        lda RoomIndex
        and #%00000111 ; isolate the column
        ora DrawIndex
        sta DrawIndex

        ; Figure out what tile we should draw here
        ldx RoomIndex
        lda room_flags, x
        
        ; can we see this room at all? any room that has been either
        ; visited OR revealed should be displayed
        and #(ROOM_FLAG_VISITED | ROOM_FLAG_REVEALED)
        
        ; DEBUG: all rooms start at least 'revealed' for testing
        ;jeq room_hidden

        ; check for special room types, which right now include boss
        ; rooms and exit doors
        lda room_flags, x
        and #ROOM_FLAG_BOSS
        bne boss_room
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        bne door_room
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        beq shop_room
        jmp normal_room

boss_room:
        ; If the boss has been cleared, draw this like a normal room instead
        lda room_flags, x
        and #ROOM_FLAG_CLEARED
        bne cleared_room

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

shop_room:
        ; load the appropriate shop tile, based on whether the player is
        ; currently in this room or not
        lda PlayerRoomIndex
        cmp RoomIndex
        beq current_shop_room
regular_shop_room:
        lda #SHOP_ROOM
        sta DrawTile
        jmp draw_tile
current_shop_room:
        lda #SHOP_ROOM_CURRENT
        sta DrawTile
        jmp draw_tile

cleared_room:
        ; Start with an interior room's "revealed" tile
        lda room_floorplan, x
        and #%00001111
        ; if there are 0 exits, treat this as a "hidden" tile instead (we may be out of bounds, or otherwise
        ; in a special room that we forgot to handle)
        beq room_hidden
        sta DrawTile
        ; this is a cleared room, so use that offset and then merge with the below code
        lda DrawTile
        adc #CLEAREED_ROOM_SET
        sta DrawTile
        jmp done_with_interior_offset

normal_room:
        ; Start with an interior room's "revealed" tile
        lda room_floorplan, x
        and #%00001111
        ; if there are 0 exits, treat this as a "hidden" tile instead (we may be out of bounds, or otherwise
        ; in a special room that we forgot to handle)
        beq room_hidden
        sta DrawTile

        ; if this is an exterior room, move to that map offset (keep the exit configuration)
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_EXTERIOR
        bne done_with_interior_offset
        clc
        lda DrawTile
        adc #EXTERIOR_SET
        sta DrawTile
done_with_interior_offset:

        ; If the player hasn't visited this room, we're done
        lda room_flags, x
        and #ROOM_FLAG_VISITED
        beq draw_tile
        ; If the player HAS visited the room, start by moving to the "visited" row
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
        adc #16
        sta DrawTile

        jmp draw_tile

room_hidden:
        lda #BLANK_TILE
        sta DrawTile
        ; if the player is somehow inside an otherwise "hidden" room, pick a special tile to still
        ; show their "here" location, floating in an empty void. (we might use this behavior for
        ; warp zones, but until then, it's mostly useful for debugging out-of-bounds areas)
        lda PlayerRoomIndex
        cmp RoomIndex
        bne draw_tile
        lda #HERE_ICON_IN_THE_VOID
        sta DrawTile
        ; fall through
draw_tile:
        ldx DrawIndex
        draw_tile_at_x MINIMAP_BASE, DrawTile, #(HUD_TEXT_PAL | CHR_BANK_HUD)

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
        cmp #::FLOOR_SIZE
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
        draw_tile_at_x ROW_1, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_1, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)

        perform_zpcm_inc

        ; now proceed with the rest of the banner, which is always at a
        ; fixed "row" of 5 within the banner graphics
        lda #(5*16)
        ora BannerBase
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_2, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_2, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)

        clc
        lda DrawTile
        adc #15
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_3, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_3, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)

        perform_zpcm_inc

        clc
        lda DrawTile
        adc #15
        sta DrawTile

        ldx #20
        draw_tile_at_x ROW_4, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)
        inc DrawTile
        inx
        draw_tile_at_x ROW_4, DrawTile, #(HUD_WORLD_PAL | CHR_BANK_ZONES)

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
NumberWord := T0
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5
TenThousandsDigit := T6
        mov16 NumberWord, DisplayedGold
        near_call FAR_base_10

        lda ThousandsDigit
        beq draw_little_x
draw_thousands_digit:
        ldx #15
        draw_tile_at_x ROW_4, ThousandsDigit, #(HUD_TEXT_PAL | CHR_BANK_000_SHIFTED_NUMERALS)
        jmp converge
draw_little_x:
        ldx #15
        draw_tile_at_x ROW_4, #COIN_X, #(HUD_TEXT_PAL | CHR_BANK_HUD)
converge:
        ldx #16
        draw_tile_at_x ROW_4, HundredsDigit, #(HUD_TEXT_PAL | CHR_BANK_000_SHIFTED_NUMERALS)
        ldx #17
        draw_tile_at_x ROW_4, TensDigit, #(HUD_TEXT_PAL | CHR_BANK_000_SHIFTED_NUMERALS)
        ldx #18
        draw_tile_at_x ROW_4, OnesDigit, #(HUD_TEXT_PAL | CHR_BANK_000_SHIFTED_NUMERALS)
        rts
.endproc

.proc update_equipment
        ; TODO: if we're going to animate equipment icons, this is where we do that
        rts
.endproc

.proc draw_icon_common
ItemId := R0
TileAddr  := R2
AttributeAddr := R4
DrawTile := R6
DrawAttr := R7
ItemPtr := R8

        clc
        lda TileAddr+0
        adc #<HUD_ATTR_OFFSET
        sta AttributeAddr+0
        lda TileAddr+1
        adc #>HUD_ATTR_OFFSET
        sta AttributeAddr+1

        ; lookup the item ID to obtain its attributes
        lda ItemId
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr +1
        ldy #ItemDef::HudBgTile
        lda (ItemPtr), y
        sta DrawTile
        ldy #ItemDef::HudBgAttr
        lda (ItemPtr), y
        sta DrawAttr

        ; Perform the draw

        ldy #0

        lda DrawTile
        sta (TileAddr), y
        lda DrawAttr
        sta (AttributeAddr), y
        
        inc DrawTile
        iny

        lda DrawTile
        sta (TileAddr), y
        lda DrawAttr
        sta (AttributeAddr), y

        clc
        lda DrawTile
        adc #15
        sta DrawTile

        tya
        clc
        adc #31
        tay

        lda DrawTile
        sta (TileAddr), y
        lda DrawAttr
        sta (AttributeAddr), y

        inc DrawTile
        iny

        lda DrawTile
        sta (TileAddr), y
        lda DrawAttr
        sta (AttributeAddr), y
        
        rts
.endproc

.proc draw_equipment_icon
ItemId := R0
TileAddr  := R2
AttributeAddr := R4
DrawTile := R6
DrawAttr := R7
ItemPtr := R8
        ; The 5 standard equipment icons need no special logic
        jsr draw_icon_common
        rts
.endproc

; same interface as above, but handles the little tab tiles on the bottom left
.proc draw_tabbed_b_icon
ItemId := R0
TileAddr  := R2
AttributeAddr := R4
DrawTile := R6
DrawAttr := R7
ItemPtr := R8
        jsr draw_icon_common
        ; at this point, Y points to the bottom-right tile
        ; backpedal unconditionally here
        dey
        ; now handle the little tab
        lda ItemId
        beq no_b_item_equipped
b_item_equipped:
        ; skip past the bottom-left corner
        dey
        ; draw the little B tab, enabled
        lda #SPELL_B_ENABLED
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        rts
no_b_item_equipped:
        ; draw the tabbed bottom left corner, disabled
        lda #SPELL_DISABLED_BL_CORNER
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        ; now skip past the bottom-left corner
        dey
        ; and finally draw the B tab, disabled
        lda #SPELL_B_DISABLED
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        rts
.endproc

; same deal but for the A button
.proc draw_tabbed_a_icon
ItemId := R0
TileAddr  := R2
AttributeAddr := R4
DrawTile := R6
DrawAttr := R7
ItemPtr := R8
        jsr draw_icon_common
        ; at this point, Y points to the bottom-right tile
        ; backpedal unconditionally here
        dey
        ; now handle the little tab
        lda ItemId
        beq no_a_item_equipped
a_item_equipped:
        ; skip past the bottom-left corner
        dey
        ; draw the little B tab, enabled
        lda #SPELL_A_ENABLED
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        rts
no_a_item_equipped:
        ; draw the tabbed bottom left corner, disabled
        lda #SPELL_DISABLED_BL_CORNER
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        ; now skip past the bottom-left corner
        dey
        ; and finally draw the B tab, disabled
        lda #SPELL_A_DISABLED
        sta (TileAddr), y
        lda #(HUD_TEXT_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        rts
.endproc

.proc draw_equipment
ItemId := R0
TileAddr  := R2
        perform_zpcm_inc

        access_data_bank #<.bank(item_table)

check_weapon:
        lda PlayerEquipmentWeapon
        cmp WeaponDisplayCurrent
        beq check_torch
        sta WeaponDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 2)
        jsr draw_equipment_icon
        perform_zpcm_inc

check_torch:
        lda PlayerEquipmentTorch
        cmp TorchDisplayCurrent
        beq check_armor
        sta TorchDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 4)
        jsr draw_equipment_icon
        perform_zpcm_inc

check_armor:
        lda PlayerEquipmentArmor
        cmp ArmorDisplayCurrent
        beq check_boots
        sta ArmorDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 6)
        jsr draw_equipment_icon
        perform_zpcm_inc

check_boots:
        lda PlayerEquipmentBoots
        cmp BootsDisplayCurrent
        beq check_accessory
        sta BootsDisplayCurrent        
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 8)
        jsr draw_equipment_icon
        perform_zpcm_inc

check_accessory:
        lda PlayerEquipmentAccessory
        cmp AccessoryDisplayCurrent
        beq check_item
        sta AccessoryDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 10)
        jsr draw_equipment_icon
        perform_zpcm_inc

check_item:
        lda PlayerEquipmentBombs
        cmp ItemDisplayCurrent
        jeq check_spell
        sta ItemDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 14)
        jsr draw_tabbed_b_icon
        perform_zpcm_inc

check_spell:
        lda PlayerEquipmentSpell
        cmp SpellDisplayCurrent
        jeq done
        sta SpellDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 17)
        jsr draw_tabbed_a_icon
        perform_zpcm_inc
       
done:
        restore_previous_bank
        perform_zpcm_inc
        rts
.endproc

