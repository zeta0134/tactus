        .macpack longbranch

        .include "../build/tile_defs.inc"

        .include "battlefield.inc"
        .include "charmap.inc"
        .include "far_call.inc"
        .include "chr.inc"
        .include "hud.inc"
        .include "levels.inc"
        .include "nes.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "sprites.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

.segment "RAM"

HudTopmostRowDirty: .res 1
HudTopRowDirty: .res 1
HudMiddleRowDirty: .res 1
HudBottomRowDirty: .res 1
HudGoldDisplay: .res 5
HudWeaponSpriteIndex: .res 1

.segment "CODE_0"

HUD_TOPMOST_ROW_LEFT = $5302
HUD_UPPER_ROW_LEFT   = $5342
HUD_MIDDLE_ROW_LEFT  = $5362
HUD_LOWER_ROW_LEFT   = $5322

HUD_TOPMOST_ROW_RIGHT = $5702
HUD_UPPER_ROW_RIGHT   = $5742
HUD_MIDDLE_ROW_RIGHT  = $5762
HUD_LOWER_ROW_RIGHT   = $5722

HUD_ATTR_OFFSET = $0800

HEART_FULL_TILE     = 204
HEART_HALF_TILE     = 200
HEART_EMPTY_TILE    = 196
BLANK_TILE          = 250
MAP_ICON_UNEXPLORED = 192
MAP_ICON_SPECIAL    = 193
MAP_ICON_EXPLORED   = 194
MAP_ICON_CURRENT    = 195

WORLD_PAL  = %00000000 | CHR_BANK_OLD_CHRRAM
TEXT_PAL   = %01000000 | CHR_BANK_OLD_CHRRAM ; text and blue are the same, the blue palette will
BLUE_PAL   = %01000000 | CHR_BANK_OLD_CHRRAM ; always contain white in slot 3 for simple UI elements
YELLOW_PAL = %10000000 | CHR_BANK_OLD_CHRRAM
RED_PAL    = %11000000 | CHR_BANK_OLD_CHRRAM

weapon_palette_table:
        .byte %00, %01, %10, %11

.proc FAR_init_hud
MetaSpriteIndex := R0
        lda #0
        sta HudGoldDisplay+0
        sta HudGoldDisplay+1
        sta HudGoldDisplay+2
        sta HudGoldDisplay+3
        sta HudGoldDisplay+4

        ; spawn in the weapon sprite
        near_call FAR_find_unused_sprite
        ldx MetaSpriteIndex
        cpx #$FF
        beq sprite_failed
        stx HudWeaponSpriteIndex
        lda #$FF ; irrelevant
        sta sprite_table + MetaSpriteState::LifetimeBeats, x
        lda #184
        sta sprite_table + MetaSpriteState::PositionX, x
        lda #208
        sta sprite_table + MetaSpriteState::PositionY, x
        lda #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x
        jsr update_weapon_sprite
sprite_failed:
        ; uhh...

        rts
.endproc

; This is here mostly because it relies on the string drawing functions
nametable_2000_string: .asciiz "NAMETABLE AT $2000"
nametable_2400_string: .asciiz "NAMETABLE AT $2400"

.proc FAR_debug_nametable_header
StringPtr := R0
NametableAddr := R12
AttributeAddr := R14
        st16 NametableAddr, $5020
        st16 AttributeAddr, $5820
        st16 StringPtr, nametable_2000_string
        ldy #0
        jsr draw_string

        st16 NametableAddr, $5420
        st16 AttributeAddr, $5C20
        st16 StringPtr, nametable_2400_string
        ldy #0
        jsr draw_string

        rts
.endproc

.proc FAR_refresh_hud
        lda #%00000011
        sta HudTopmostRowDirty
        sta HudTopRowDirty
        sta HudMiddleRowDirty
        sta HudBottomRowDirty
        jsr update_weapon_sprite
        rts
.endproc

.proc update_weapon_sprite
        ldy #WeaponClass::TileIndex
        lda (PlayerWeaponPtr), y
        ldx HudWeaponSpriteIndex
        sta sprite_table + MetaSpriteState::TileIndex, x
        ldy PlayerWeaponDmg
        lda weapon_palette_table, y
        ora #(SPRITE_ACTIVE)
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        rts
.endproc

.proc FAR_queue_hud
NametableAddr := R12
AttributeAddr := R14
        lda HudTopmostRowDirty
        and #%00000001
        beq skip_topmost_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_topmost_row_left
        
        st16 NametableAddr, (HUD_TOPMOST_ROW_LEFT)
        st16 AttributeAddr, (HUD_TOPMOST_ROW_LEFT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_topmost_row
        lda HudTopmostRowDirty
        and #%11111110
        sta HudTopmostRowDirty
skip_topmost_row_left:
        lda HudTopRowDirty
        and #%00000001
        beq skip_top_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_top_row_left
        
        st16 NametableAddr, (HUD_UPPER_ROW_LEFT)
        st16 AttributeAddr, (HUD_UPPER_ROW_LEFT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_top_row
        lda HudTopRowDirty
        and #%11111110
        sta HudTopRowDirty
skip_top_row_left:
        lda HudMiddleRowDirty
        and #%00000001
        beq skip_middle_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_middle_row_left
        
        st16 NametableAddr, (HUD_MIDDLE_ROW_LEFT)
        st16 AttributeAddr, (HUD_MIDDLE_ROW_LEFT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_middle_row
        lda HudMiddleRowDirty
        and #%11111110
        sta HudMiddleRowDirty
skip_middle_row_left:
        lda HudBottomRowDirty
        and #%00000001
        beq skip_bottom_row_left
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_bottom_row_left
        
        st16 NametableAddr, (HUD_LOWER_ROW_LEFT)
        st16 AttributeAddr, (HUD_LOWER_ROW_LEFT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_bottom_row
        lda HudBottomRowDirty
        and #%11111110
        sta HudBottomRowDirty
skip_bottom_row_left:
        lda HudTopmostRowDirty
        and #%00000010
        beq skip_topmost_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_topmost_row_right
        
        st16 NametableAddr, (HUD_TOPMOST_ROW_RIGHT)
        st16 AttributeAddr, (HUD_TOPMOST_ROW_RIGHT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_topmost_row
        lda HudTopmostRowDirty
        and #%11111101
        sta HudTopmostRowDirty
skip_topmost_row_right:
        lda HudTopRowDirty
        and #%00000010
        beq skip_top_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_top_row_right
        
        st16 NametableAddr, (HUD_UPPER_ROW_RIGHT)
        st16 AttributeAddr, (HUD_UPPER_ROW_RIGHT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_top_row
        lda HudTopRowDirty
        and #%11111101
        sta HudTopRowDirty
skip_top_row_right:
        lda HudMiddleRowDirty
        and #%00000010
        beq skip_middle_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_middle_row_right
        
        st16 NametableAddr, (HUD_MIDDLE_ROW_RIGHT)
        st16 AttributeAddr, (HUD_MIDDLE_ROW_RIGHT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_middle_row
        lda HudMiddleRowDirty
        and #%11111101
        sta HudMiddleRowDirty
skip_middle_row_right:
        lda HudBottomRowDirty
        and #%00000010
        beq skip_bottom_row_right
        lda queued_bytes_counter
        cmp #(MAXIMUM_QUEUE_SIZE - 28)
        bcs skip_bottom_row_right
        
        st16 NametableAddr, (HUD_LOWER_ROW_RIGHT)
        st16 AttributeAddr, (HUD_LOWER_ROW_RIGHT | HUD_ATTR_OFFSET)
        ldy #0

        near_call FAR_queue_hud_bottom_row
        lda HudBottomRowDirty
        and #%11111101
        sta HudBottomRowDirty
skip_bottom_row_right:
        
        rts
.endproc

; Note: Expects Y to be loaded with the tile index
.proc FAR_queue_hud_top_row
PaddingAmount := R0
CurrentHeart := R0
RoomIndex := R0
FullHeartThreshold := R1
HalfHeartThreshold := R2

NametableAddr := R12
AttributeAddr := R14

        perform_zpcm_inc
        ; up to 10 hearts
        lda #0
        sta CurrentHeart
        lda #2
        sta FullHeartThreshold
        lda #1
        sta HalfHeartThreshold
loop:
        perform_zpcm_inc
        lda PlayerHealth
        cmp FullHeartThreshold
        bcc check_half_heart
        lda #(HEART_FULL_TILE+0)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_FULL_TILE+2)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
check_half_heart:
        cmp HalfHeartThreshold
        bcc check_heart_container
        lda #(HEART_HALF_TILE+0)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_HALF_TILE+2)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
check_heart_container:
        lda PlayerMaxHealth
        cmp HalfHeartThreshold
        bcc draw_nothing
        lda #(HEART_EMPTY_TILE+0)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_EMPTY_TILE+2)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
draw_nothing:
        ; draw two blank tiles; the upper attribute
        ; byte doesn't matter much here, but we draw it anyway
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
converge:
        inc FullHeartThreshold
        inc FullHeartThreshold
        inc HalfHeartThreshold
        inc HalfHeartThreshold
        inc CurrentHeart
        lda CurrentHeart
        cmp #MAX_HEARTS
        bne loop

        perform_zpcm_inc

        ; For now, just pad out the remainder
        lda #10
        sta PaddingAmount
        jsr draw_padding

        perform_zpcm_inc

        ; At the end, draw the second set of four tiles of the minimap
        lda #8
        sta RoomIndex
        jsr draw_map_tiles

        ; TODO: gold counter (6 more tiles)

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter

        perform_zpcm_inc

        rts
.endproc

; Note: Expects Y to be loaded with the tile index
.proc FAR_queue_hud_middle_row
PaddingAmount := R0
CurrentHeart := R0
RoomIndex := R0
FullHeartThreshold := R1
HalfHeartThreshold := R2
NumberWord := R0
StringPtr := R0

NametableAddr := R12
AttributeAddr := R14
        ; up to 10 hearts
        lda #0
        sta CurrentHeart
        lda #2
        sta FullHeartThreshold
        lda #1
        sta HalfHeartThreshold
        
loop:
        perform_zpcm_inc
        lda PlayerHealth
        cmp FullHeartThreshold
        bcc check_half_heart
        lda #(HEART_FULL_TILE+1)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_FULL_TILE+3)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
check_half_heart:
        cmp HalfHeartThreshold
        bcc check_heart_container
        lda #(HEART_HALF_TILE+1)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_HALF_TILE+3)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
check_heart_container:
        lda PlayerMaxHealth
        cmp HalfHeartThreshold
        bcc draw_nothing
        lda #(HEART_EMPTY_TILE+1)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #(HEART_EMPTY_TILE+3)
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
draw_nothing:
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
        lda #BLANK_TILE
        sta (NametableAddr), y
        lda #RED_PAL
        sta (AttributeAddr), y
        iny
converge:        
        inc FullHeartThreshold
        inc FullHeartThreshold
        inc HalfHeartThreshold
        inc HalfHeartThreshold
        inc CurrentHeart
        lda CurrentHeart
        cmp #MAX_HEARTS
        bne loop

        perform_zpcm_inc

        ; Draw the player's gold counter
        st16 StringPtr, money_text
        jsr draw_string
        mov16 NumberWord, PlayerGold
        jsr draw_16bit_number

        perform_zpcm_inc

        ; For now, just pad out the remainder
        lda #3
        sta PaddingAmount
        jsr draw_padding

        perform_zpcm_inc

        ; At the end, draw the second set of four tiles of the minimap
        lda #12
        sta RoomIndex
        jsr draw_map_tiles

        ; TODO: gold counter (6 more tiles)

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter

        perform_zpcm_inc

        rts
.endproc

zone_text: .asciiz "ZONE "
hyphen_text: .asciiz "-"
weapon_level_text: .asciiz "L"
key_text: .asciiz "k"
money_text: .asciiz " $"

weapon_name_table:
        .word dagger_text
        .word broadsword_text
        .word longsword_text
        .word spear_text
        .word flail_text

dagger_text:     .asciiz "-DAGGER"     ; 6
broadsword_text: .asciiz "-BROADSWORD" ; 10
longsword_text:  .asciiz "-LONGSWORD"  ; 9
spear_text:      .asciiz "-SPEAR"      ; 5
flail_text:      .asciiz "-FLAIL"      ; 5

weapon_padding_table:
        .byte 4, 0, 1, 5, 5

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
        lda #TEXT_PAL
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

.proc FAR_queue_hud_bottom_row
; One scratch byte, many functions
; (okay stringptr uses two bytes)
PaddingAmount := R0
StringPtr := R0
Digit := R0
RoomIndex := R0

NametableAddr := R12
AttributeAddr := R14

        perform_zpcm_inc

        ; 0123456789012345678901234567
        ; ZONE W-L  L-N WWWWWWWWWW
        ; Zone area, indicating our overall game state
        st16 StringPtr, zone_text
        jsr draw_string
        lda PlayerZone ; TODO: use the actual world number
        sta Digit
        jsr draw_single_digit
        st16 StringPtr, hyphen_text
        jsr draw_string
        lda PlayerFloor ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit
        ; If the player has a key, draw the key icon
        lda PlayerKeys
        beq no_key
has_key:
        st16 StringPtr, key_text
        jsr draw_string
        jmp done_with_keys
no_key:
        lda #1
        sta PaddingAmount
        jsr draw_padding
done_with_keys:
        perform_zpcm_inc

        ; Fixed padding between zone end and weapon area begin
        lda #1
        sta PaddingAmount
        jsr draw_padding
        ; Variable padding depending on player equipped weapon
        ldx PlayerWeapon
        lda weapon_padding_table, x
        sta PaddingAmount
        jsr draw_padding
        perform_zpcm_inc
        ; Weapon level
        st16 StringPtr, weapon_level_text
        jsr draw_string
        lda PlayerWeaponDmg ; TODO: use the actual level number
        sta Digit
        jsr draw_single_digit
        perform_zpcm_inc
        ; Finally the weapon name
        lda PlayerWeapon
        asl
        tax
        lda weapon_name_table, x
        sta StringPtr
        lda weapon_name_table+1, x
        sta StringPtr+1
        jsr draw_string
        perform_zpcm_inc
        ; One space between the weapon name and the minimap
        lda #1
        sta PaddingAmount
        jsr draw_padding
        perform_zpcm_inc
        ; At the end, draw the second set of four tiles of the minimap
        lda #4
        sta RoomIndex
        jsr draw_map_tiles

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter

        perform_zpcm_inc

        rts
.endproc

.proc FAR_queue_hud_topmost_row
PaddingAmount := R0
RoomIndex := R0

; not used, but included here for consistency
NametableAddr := R12
AttributeAddr := R14

        perform_zpcm_inc
        ; This row is mostly padding
        lda #24
        sta PaddingAmount
        jsr draw_padding
        perform_zpcm_inc
        ; At the end, draw the first four tiles of the minimap
        lda #0
        sta RoomIndex
        jsr draw_map_tiles

        perform_zpcm_inc

        lda queued_bytes_counter
        clc
        adc #28
        sta queued_bytes_counter

        perform_zpcm_inc

        rts
.endproc

; Note: called by the bigger row specific functions
; Put the starting index in R0, and leave Y pointing
; the vram index
.proc draw_map_tiles
RoomIndex := R0
Counter := R1

NametableAddr := R12
AttributeAddr := R14

        lda #4
        sta Counter
loop:
        ldx RoomIndex
        lda room_flags, x
        and #(ROOM_FLAG_VISITED)
        bne visited
unvisited:
        lda #MAP_ICON_UNEXPLORED
        sta (NametableAddr), y
        lda #YELLOW_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
visited:
        cpx PlayerRoomIndex
        beq current_room
        lda room_flags, x
        and #(ROOM_FLAG_EXIT_STAIRS)
        bne special_room
standard_room:
        lda #MAP_ICON_EXPLORED
        sta (NametableAddr), y
        lda #YELLOW_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
special_room:
        lda #MAP_ICON_SPECIAL
        sta (NametableAddr), y
        lda #YELLOW_PAL
        sta (AttributeAddr), y
        iny
        jmp converge
current_room:
        lda #MAP_ICON_CURRENT
        sta (NametableAddr), y
        lda #YELLOW_PAL
        sta (AttributeAddr), y
        iny
converge:
        inc RoomIndex
        dec Counter
        bne loop
        rts
.endproc

.macro sub16w addr, value
        sec
        lda addr
        sbc #<value
        sta addr
        lda addr+1
        sbc #>value
        sta addr+1
.endmacro

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