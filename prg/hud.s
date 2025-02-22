        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "_globals.inc"

        .include "bhop/bhop.inc"
        .include "battlefield.inc"
        .include "chr.inc"
        .include "debug.inc"
        .include "dialog.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "items.inc"
        .include "kernel.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "rainbow.inc"
        .include "slowam.inc"
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
ZonePtrCurrent: .res 2

DisplayedGold: .res 2
GoldSfxCooldown: .res 1

WeaponDisplayCurrent: .res 1
TorchDisplayCurrent: .res 1
ArmorDisplayCurrent: .res 1
BootsDisplayCurrent: .res 1
AccessoryDisplayCurrent: .res 1
SpellDisplayCurrent: .res 1
ItemDisplayCurrent: .res 1
ItemCountCurrent: .res 1

.segment "CODE_0"

HUD_TILE_BASE        = $52C0
HUD_ATTR_OFFSET      = $0800

ROW_0 = (32*0)
ROW_1 = (32*1)
ROW_2 = (32*2)
ROW_3 = (32*3)
ROW_4 = (32*4)
ROW_5 = (32*5)
ROW_6 = (32*6)
ROW_7 = (32*7)

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
chr_tile_offset HEART_NOTHING_BASE,      10, 7
chr_tile_offset HEART_CONTAINER_BASE,    12, 7
chr_tile_offset HEART_CONTAINER_BEATING, 14, 7
chr_tile_offset SPELL_A_DISABLED,   0, 14
chr_tile_offset SPELL_B_DISABLED,   0, 15
chr_tile_offset SPELL_A_ENABLED,    2, 14
chr_tile_offset SPELL_B_ENABLED,    2, 15
chr_tile_offset SPELL_DISABLED_BL_CORNER, 1, 14

chr_tile_offset STATIC_0,  4, 7
chr_tile_offset STATIC_1,  5, 7
chr_tile_offset STATIC_2,  4, 8
chr_tile_offset STATIC_3,  5, 8
chr_tile_offset STATIC_4,  9, 7
chr_tile_offset STATIC_5, 10, 7
chr_tile_offset STATIC_6,  9, 8
chr_tile_offset STATIC_7, 10, 8

TILE_COL_OFFSET = 1
TILE_ROW_OFFSET = 16

BOMB_COUNTER_POS_X = 115
BOMB_COUNTER_POS_Y = 194

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
        sta ZonePtrCurrent+0
        sta ZonePtrCurrent+1
        sta WeaponDisplayCurrent
        sta TorchDisplayCurrent
        sta ArmorDisplayCurrent
        sta AccessoryDisplayCurrent
        sta BootsDisplayCurrent
        sta SpellDisplayCurrent
        sta ItemDisplayCurrent
        sta ItemCountCurrent

        jsr clear_hud_canvas
        jsr draw_static_hud_elements
        mov16 DisplayedGold, PlayerGold
        jsr draw_coin_counter

        jsr init_dialog

        st16 HudState, hud_state_update
        rts
.endproc

.proc hud_state_update
        jsr update_heart_state
        perform_zpcm_inc
        jsr draw_hearts
        perform_zpcm_inc
        jsr draw_map_tiles
        perform_zpcm_inc
        jsr draw_current_zone
        perform_zpcm_inc
        jsr draw_equipment
        perform_zpcm_inc
        jsr update_coin_counter
        perform_zpcm_inc
        .if ::DEBUG_MODE
        jsr draw_run_seed
        .endif
        perform_zpcm_inc
        jsr update_dialog
        perform_zpcm_inc
        rts
.endproc

; Update functions!

; the top 4 bits are the type of heart this is,
; and the lower 3 bits describe a "fullness" in quarter-hearts
HEART_STATE_NONE              = $00
HEART_STATE_REGULAR           = $10
HEART_STATE_GLASS             = $20
HEART_STATE_REGULAR_ARMORED   = $30
HEART_STATE_TEMPORARY         = $40
HEART_STATE_TEMPORARY_ARMORED = $50

; bit 2 is used for beat tracking, to have the hearts pulse along
; with the rhythm
HEART_STATE_BEATING = $08

.proc update_heart_state
CurrentBeat := R0
TargetHealth := R1
        ; if the player has more than 4 hearts, use an 8-beat pattern
        ; TODO: this logic just breaks completely with shorter patterns :(
        lda heart_type+4
        cmp #HEART_TYPE_NONE
        bne use_8_beats
use_4_beats:
        lda currently_playing_row
        and #%00011000
        jmp done_picking_beat_length
use_8_beats:
        lda currently_playing_row
        and #%00011000
        sta CurrentBeat
        lda currently_playing_frame
        .repeat 5
        asl
        .endrepeat
        and #%00100000
        ora CurrentBeat
done_picking_beat_length:
        .repeat 3
        lsr
        .endrepeat
        sta CurrentBeat

        ; TODO: player health needs to be pretty much completely rethought.
        ; This gets the old half-heart system working, but we want to transition
        ; to quarter-heart display later, and eventually treat each heart container
        ; as its own bespoke entity.

        ; NEW HEARTNESS

        ldx #0
loop:
        perform_zpcm_inc
        ; grab the type of this particular heart
        lda heart_type, x
        ; move this into the top 4 bits, to conform with the drawing code
        asl
        asl
        asl
        asl
        sta HeartDisplayTarget, x
        ; grab its health and get that in place
        lda heart_hp, x
        ; if this heart is beating, get that flag in place
        cpx CurrentBeat
        bne done_applying_beat
        ora #HEART_STATE_BEATING
done_applying_beat:
        ora HeartDisplayTarget, x
        sta HeartDisplayTarget, x
        inx
        cpx #TOTAL_HEART_SLOTS
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
        cmp #HEART_STATE_GLASS
        beq glass_heart
        cmp #HEART_STATE_REGULAR_ARMORED
        beq regular_armored_heart
        cmp #HEART_STATE_TEMPORARY
        beq temporary_heart
        cmp #HEART_STATE_TEMPORARY_ARMORED
        beq temporary_armored_heart
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
glass_heart:
        jsr draw_glass_heart
        jmp done_with_this_heart
regular_armored_heart:
        jsr draw_regular_armored_heart
        jmp done_with_this_heart
temporary_heart:
        jsr draw_temporary_heart
        jmp done_with_this_heart
temporary_armored_heart:
        jsr draw_temporary_armored_heart
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

.proc draw_glass_heart
        perform_zpcm_inc
        ; is this a beating heart?
        lda HeartDisplayTarget, y
        and #%00001000
        beq inert_heart
beating_heart:
        draw_tile_at_x ROW_3, #FRAGILE_HEART_BEATING+0,  #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #FRAGILE_HEART_BEATING+16, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        draw_tile_at_x ROW_3, #FRAGILE_HEART_BEATING+1,  #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #FRAGILE_HEART_BEATING+17, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        rts
inert_heart:
        draw_tile_at_x ROW_3, #FRAGILE_HEART_BASE+0,  #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #FRAGILE_HEART_BASE+16, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        draw_tile_at_x ROW_3, #FRAGILE_HEART_BASE+1,  #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #FRAGILE_HEART_BASE+17, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        rts
.endproc

.proc draw_regular_heart
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
ColorAttributes := R6
        perform_zpcm_inc

        lda #(HUD_RED_PAL | CHR_BANK_HUD)
        sta ColorAttributes

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
        jmp draw_quartered_heart_common
.endproc

.proc draw_regular_armored_heart
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
ColorAttributes := R6
        perform_zpcm_inc

        lda #(HUD_RED_PAL | CHR_BANK_HUD)
        sta ColorAttributes

        ; is this a beating heart?
        lda HeartDisplayTarget, y
        and #%00001000
        beq inert_heart
beating_heart:
        lda #ARMORED_HEART_BEATING
        sta HeartFullBase
        lda #ARMORED_HEART_DEPLETED
        sta HeartEmptyBase
        jmp done_with_beating_checks
inert_heart:
        lda #ARMORED_HEART_BASE
        sta HeartFullBase
        lda #ARMORED_HEART_DEPLETED
        sta HeartEmptyBase
done_with_beating_checks:
        jmp draw_quartered_heart_common
.endproc

.proc draw_temporary_heart
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
ColorAttributes := R6
        perform_zpcm_inc

        lda #(HUD_PURPLE_PAL | CHR_BANK_HUD)
        sta ColorAttributes

        ; is this a beating heart?
        lda HeartDisplayTarget, y
        and #%00001000
        beq inert_heart
beating_heart:
        lda #FULL_HEART_BEATING
        sta HeartFullBase
        lda #HEART_NOTHING_BASE
        sta HeartEmptyBase
        jmp done_with_beating_checks
inert_heart:
        lda #FULL_HEART_BASE
        sta HeartFullBase
        lda #HEART_NOTHING_BASE
        sta HeartEmptyBase
done_with_beating_checks:
        jmp draw_quartered_heart_common
.endproc

.proc draw_temporary_armored_heart
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
ColorAttributes := R6
        perform_zpcm_inc

        lda #(HUD_PURPLE_PAL | CHR_BANK_HUD)
        sta ColorAttributes

        ; is this a beating heart?
        lda HeartDisplayTarget, y
        and #%00001000
        beq inert_heart
beating_heart:
        lda #ARMORED_HEART_BEATING
        sta HeartFullBase
        lda #ARMORED_HEART_DEPLETED
        sta HeartEmptyBase
        jmp done_with_beating_checks
inert_heart:
        lda #ARMORED_HEART_BASE
        sta HeartFullBase
        lda #ARMORED_HEART_DEPLETED
        sta HeartEmptyBase
done_with_beating_checks:
        jmp draw_quartered_heart_common
.endproc

.proc draw_quartered_heart_common
HeartFullBase := R3
HeartEmptyBase := R4
TileId := R5
ColorAttributes := R6
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
        draw_tile_at_x ROW_3, TileId, ColorAttributes

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
        draw_tile_at_x ROW_4, TileId, ColorAttributes

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
        draw_tile_at_x ROW_3, TileId, ColorAttributes

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
        draw_tile_at_x ROW_4, TileId, ColorAttributes

        perform_zpcm_inc
        inx

        rts
.endproc

.proc clear_hud_canvas
        ldy #0
loop:
        perform_zpcm_inc
        lda #BLANK_TILE
        sta HUD_TILE_BASE + ROW_0, y
        sta HUD_TILE_BASE + ROW_1, y
        sta HUD_TILE_BASE + ROW_2, y
        sta HUD_TILE_BASE + ROW_3, y
        sta HUD_TILE_BASE + ROW_4, y
        sta HUD_TILE_BASE + ROW_5, y
        sta HUD_TILE_BASE + ROW_6, y
        sta HUD_TILE_BASE + ROW_7, y
        lda #CHR_BANK_HUD
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_0, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_1, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_2, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_3, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_4, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_5, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_6, y
        sta HUD_TILE_BASE + HUD_ATTR_OFFSET + ROW_7, y
        iny
        cpy #32
        bne loop
        perform_zpcm_inc
        rts
.endproc

.proc draw_static_hud_elements
        perform_zpcm_inc
        ; first, draw the border around the minimap
        ldx #19
        ; left side
        draw_tile_at_x ROW_0, #MAP_BORDER_TL, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_ML, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_ML, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_ML, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_ML, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BL, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        ; center loop
loop:
        perform_zpcm_inc
        draw_tile_at_x ROW_0, #MAP_BORDER_TM, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BM, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        inx
        cpx #30
        bne loop

        perform_zpcm_inc
        ; right side
        draw_tile_at_x ROW_0, #MAP_BORDER_TR, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_1, #MAP_BORDER_MR, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_2, #MAP_BORDER_MR, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_3, #MAP_BORDER_MR, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_4, #MAP_BORDER_MR, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        draw_tile_at_x ROW_5, #MAP_BORDER_BR, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        ; coin counter, static tiles
        ldx #14
        draw_tile_at_x ROW_4, #COIN_ICON, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        ldx #15
        draw_tile_at_x ROW_4, #COIN_X, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        perform_zpcm_inc

        rts
.endproc

; center the 6x4 map in an 8x4 region
; (we might rearrange this later)
MINIMAP_BASE = (ROW_1+23)

chr_tile_offset BOSS_ROOM, 0, 1
chr_tile_offset DOOR_ROOM, 0, 2
chr_tile_offset SHOP_ROOM, 0, 3
chr_tile_offset WARP_ROOM, 2, 7

chr_tile_offset BOSS_ROOM_CURRENT, 14, 5
chr_tile_offset DOOR_ROOM_CURRENT, 15, 5
chr_tile_offset SHOP_ROOM_CURRENT, 14, 6
chr_tile_offset WARP_ROOM_CURRENT, 15, 6

chr_tile_offset HERE_ICON_IN_THE_VOID, 0, 15
chr_tile_offset EXTERIOR_SET, 0, 13
chr_tile_offset CLEAREED_ROOM_SET, 0, 10

room_index_to_draw_index_lut:
        .repeat ::FLOOR_HEIGHT, h
        .repeat ::FLOOR_WIDTH, w
        .byte (h*32)+w
        .endrepeat
        .endrepeat

warp_static_tiles_lut:
        .byte STATIC_0
        .byte STATIC_1
        .byte STATIC_2
        .byte STATIC_3
        .byte STATIC_4
        .byte STATIC_5
        .byte STATIC_6
        .byte STATIC_7
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE
        .byte BLANK_TILE

.proc draw_minimap_tile
RoomIndex := R0
DrawIndex := R1
DrawTile := R2
NametableAddr := R12
AttributeAddr := R14

        ldx RoomIndex
        lda room_index_to_draw_index_lut, x
        sta DrawIndex

        ; If the player is *currently* in a warp room, draw static instead of any of this fancy logic
        ldx PlayerRoomIndex
        lda room_properties, x
        and #(ROOM_PROPERTIES_WARP)
        beq draw_regular_minimap_here
draw_warp_static_here:
        prng_from_table_y
        and #$F
        tay
        lda warp_static_tiles_lut, y
        sta DrawTile
        ldx DrawIndex
        draw_tile_at_x MINIMAP_BASE, DrawTile, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        rts

draw_regular_minimap_here:
        ; Figure out what tile we should draw here
        ldx RoomIndex
        
        ; If this is a warp chamber, we should never draw it!
        lda room_properties, x
        and #(ROOM_PROPERTIES_WARP)
        jne room_hidden

        ; can we see this room at all? any room that has been either
        ; visited OR revealed should be displayed
        lda room_minimap_state, x
        and #(ROOM_MINIMAP_FLAG_VISITED | ROOM_MINIMAP_FLAG_MAPPED | ROOM_MINIMAP_FLAG_IDENTIFIED)
        
        ; DEBUG: all rooms start at least 'revealed' for testing
        jeq room_hidden

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
        clc
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
        lda room_minimap_state, x
        and #ROOM_MINIMAP_FLAG_VISITED
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

; yeah just keep going until it's all done. eat the lag, it's fine, this happens
; really infrequently!
draw_loop:
        lda CurrentMapIndex
        sta RoomIndex
        jsr draw_minimap_tile
        inc CurrentMapIndex
        lda CurrentMapIndex
        cmp #::FLOOR_SIZE
        bne draw_loop
        lda #0
        sta CurrentMapIndex
done:
        rts
.endproc

.proc draw_current_zone
NametableAddr := R0
AttributeAddr := R2
SpritePosX := R4
SpritePosY := R5
SpritePtr := R8
        lda PlayerZonePtr+0
        cmp ZonePtrCurrent+0
        bne proceed_to_draw
        lda PlayerZonePtr+1
        cmp ZonePtrCurrent+1
        bne proceed_to_draw
        rts
proceed_to_draw:
        perform_zpcm_inc
        lda PlayerZonePtr+0
        sta ZonePtrCurrent+0
        lda PlayerZonePtr+1
        sta ZonePtrCurrent+1

        ; load in the proper palette for this banner (and the rest of the hud)
        far_call FAR_load_hud_palette_for_current_zone

        ; actually draw the banner
        lda #<(HUD_TILE_BASE + ROW_1 + 20)
        sta NametableAddr+0
        lda #>(HUD_TILE_BASE + ROW_1 + 20)
        sta NametableAddr+1

        lda #<(HUD_TILE_BASE + ROW_1 + 20 + HUD_ATTR_OFFSET)
        sta AttributeAddr+0
        lda #>(HUD_TILE_BASE + ROW_1 + 20 + HUD_ATTR_OFFSET)
        sta AttributeAddr+1

        lda #(20 * 8)
        sta SpritePosX
        lda #<((HUD_TILE_BASE + ROW_1) / 32 * 8) + 10
        sta SpritePosY

        far_call FAR_draw_banner_for_current_zone

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

        perform_zpcm_inc

        ; only play the cash SFX if we haven't started it within some number of frames, just
        ; to make sure it isn't trampling all over itself
        lda GoldSfxCooldown
        beq play_coin_sfx
        dec GoldSfxCooldown
        rts
        
play_coin_sfx:
        queue_sfx_pulse1_with_lowest_priority sfx_cash_flow

        lda #3
        sta GoldSfxCooldown
        rts
done:
        ; be sure to reset the cooldown, so that the next time our gold changes, the SFX starts
        ; playing right away
        lda #0
        sta GoldSfxCooldown
        perform_zpcm_inc
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
        perform_zpcm_inc
        mov16 NumberWord, DisplayedGold
        near_call FAR_base_10

        lda ThousandsDigit
        beq draw_little_x
draw_thousands_digit:
        clc
        adc #'0'
        sta ThousandsDigit
        ldx #15
        draw_tile_at_x ROW_4, ThousandsDigit, #(HUD_TEXT_PAL | CHR_BANK_FONT_MARSHMALLOW)
        jmp converge
draw_little_x:
        ldx #15
        draw_tile_at_x ROW_4, #COIN_X, #(HUD_TEXT_PAL | CHR_BANK_HUD)
converge:
        perform_zpcm_inc
        lda HundredsDigit
        clc
        adc #'0'
        sta HundredsDigit
        ldx #16
        draw_tile_at_x ROW_4, HundredsDigit, #(HUD_TEXT_PAL | CHR_BANK_FONT_MARSHMALLOW)
        lda TensDigit
        clc
        adc #'0'
        sta TensDigit
        ldx #17
        draw_tile_at_x ROW_4, TensDigit, #(HUD_TEXT_PAL | CHR_BANK_FONT_MARSHMALLOW)
        lda OnesDigit
        clc
        adc #'0'
        sta OnesDigit
        ldx #18
        draw_tile_at_x ROW_4, OnesDigit, #(HUD_TEXT_PAL | CHR_BANK_FONT_MARSHMALLOW)
        perform_zpcm_inc
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
        perform_zpcm_inc
        jsr draw_icon_common
        perform_zpcm_inc
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
        lda #(HUD_PURPLE_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        perform_zpcm_inc
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
        perform_zpcm_inc
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
        perform_zpcm_inc
        jsr draw_icon_common
        perform_zpcm_inc
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
        lda #(HUD_YELLOW_PAL | CHR_BANK_ITEMS)
        sta (AttributeAddr), y
        perform_zpcm_inc
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
        perform_zpcm_inc
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
        beq check_item_count
        sta ItemDisplayCurrent
        sta ItemId
        st16 TileAddr, (HUD_TILE_BASE + ROW_1 + 14)
        jsr draw_tabbed_b_icon
        perform_zpcm_inc

check_item_count:
        lda PlayerBombCount
        cmp ItemCountCurrent
        beq check_spell
        sta ItemCountCurrent
        jsr draw_item_count_sprites
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

.if ::DEBUG_MODE
.proc draw_run_seed
Numeral := R0     
        perform_zpcm_inc   

        lda initial_run_seed+0
        lsr
        lsr
        lsr
        lsr
        and #$0F
        ora #$40
        sta Numeral
        ldx #2
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        lda initial_run_seed+0
        and #$0F
        ora #$40
        sta Numeral
        ldx #3
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        lda initial_run_seed+1
        lsr
        lsr
        lsr
        lsr
        and #$0F
        ora #$40
        sta Numeral
        ldx #4
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        lda initial_run_seed+1
        and #$0F
        ora #$40
        sta Numeral
        ldx #5
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        lda initial_run_seed+2
        lsr
        lsr
        lsr
        lsr
        and #$0F
        ora #$40
        sta Numeral
        ldx #6
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        lda initial_run_seed+2
        and #$0F
        ora #$40
        sta Numeral
        ldx #7
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        lda initial_run_seed+3
        lsr
        lsr
        lsr
        lsr
        and #$0F
        ora #$40
        sta Numeral
        ldx #8
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)
        lda initial_run_seed+3
        and #$0F
        ora #$40
        sta Numeral
        ldx #9
        draw_tile_at_x ROW_0, Numeral, #(HUD_TEXT_PAL | CHR_BANK_HUD)

        perform_zpcm_inc
        rts
.endproc
.endif

bomb_counter_tens_lut:
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_01 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_01 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_23 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_23 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_45 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_10S_45 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_01_COUNTER_10S_67 + 0 + SPRITE_OFFSET_HUD_STATIC_01
        .byte <SPRITE_HUD_STATIC_01_COUNTER_10S_67 + 2 + SPRITE_OFFSET_HUD_STATIC_01
        .byte <SPRITE_HUD_STATIC_01_COUNTER_10S_89 + 0 + SPRITE_OFFSET_HUD_STATIC_01
        .byte <SPRITE_HUD_STATIC_01_COUNTER_10S_89 + 2 + SPRITE_OFFSET_HUD_STATIC_01

bomb_counter_ones_lut:
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_01 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_01 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_23 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_23 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_45 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_45 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_67 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_67 + 2 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_89 + 0 + SPRITE_OFFSET_HUD_STATIC_00
        .byte <SPRITE_HUD_STATIC_00_COUNTER_01S_89 + 2 + SPRITE_OFFSET_HUD_STATIC_00

.proc draw_item_count_sprites
NumberWord := T0
OnesDigit := T2
TensDigit := T3
HundredsDigit := T4
ThousandsDigit := T5
TenThousandsDigit := T6

SpritePtr := R0

        lda PlayerBombCount
        bne draw_counter
        
clear_counter:
        perform_zpcm_inc
        ldy #BOMB_COUNT_FIRST_OAM_INDEX+0
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda #$F8
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldy #BOMB_COUNT_FIRST_OAM_INDEX+1
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda #$F8
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        rts

draw_counter:
        sta NumberWord+0
        lda #0
        sta NumberWord+1
        near_call FAR_base_10

        ; Tens Digit
        perform_zpcm_inc
        ldy #BOMB_COUNT_FIRST_OAM_INDEX+0
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda #BOMB_COUNTER_POS_X+0
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda #BOMB_COUNTER_POS_Y
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldx TensDigit
        lda bomb_counter_tens_lut, x
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        lda #SPRITE_PAL_YELLOW
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y    

        ; Ones Digit
        perform_zpcm_inc
        ldy #BOMB_COUNT_FIRST_OAM_INDEX+1
        lda sprite_ptr_lut_low, y
        sta SpritePtr+0
        lda sprite_ptr_lut_high, y
        sta SpritePtr+1
        lda #BOMB_COUNTER_POS_X+8
        ldy #SelfModifiedSprite::PosX
        sta (SpritePtr), y
        lda #BOMB_COUNTER_POS_Y
        ldy #SelfModifiedSprite::PosY
        sta (SpritePtr), y
        ldx OnesDigit
        lda bomb_counter_ones_lut, x
        ldy #SelfModifiedSprite::TileId
        sta (SpritePtr), y
        lda #SPRITE_PAL_YELLOW
        ldy #SelfModifiedSprite::Attributes
        sta (SpritePtr), y   

        rts
.endproc