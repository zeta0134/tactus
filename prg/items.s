        .include "items.inc"

        .include "../build/tile_defs.inc"
        .include "far_call.inc"
        .include "hearts.inc"
        .include "hud.inc"
        .include "prng.inc"
        .include "procgen.inc"
        .include "player.inc"
        .include "rainbow.inc"
        .include "sound.inc"
        .include "sprites.inc"
        .include "torchlight.inc"
        .include "weapons.inc"
        .include "word_util.inc"
        .include "zeropage.inc"
        .include "zpcm.inc"

        .zeropage

; for use during general purpose routines, since I don't want to delicately
; dance around scratch byte allocation
ItemPtr: .res 2
ItemFuncPtr: .res 2

        .segment "DATA_0"

item_table:
        .word no_item
        .word dagger_lvl_1
        .word broadsword_lvl_1
        .word broadsword_lvl_2
        .word broadsword_lvl_3
        .word longsword_lvl_1
        .word longsword_lvl_2
        .word longsword_lvl_3
        .word spear_lvl_1
        .word spear_lvl_2
        .word spear_lvl_3
        .word flail_lvl_1
        .word flail_lvl_2
        .word flail_lvl_3
        .word basic_torch
        .word large_torch
        .word compass
        .word map
        .word small_fries
        .word medium_fries
        .word large_fries
        .word go_go_boots
        ; safety
        .repeat 128
        .word no_item
        .endrepeat

no_item:
        .byte SLOT_WEAPON                     ; SlotId (irrelevant)
        .byte SPRITE_TILE_MENU_CURSOR_SPIN    ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 50                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

dagger_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_DAGGER              ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_DAGGER         ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 25                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

broadsword_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_BROADSWORD          ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD     ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 75                              ; ShopCost
        .byte WEAPON_BROADSWORD               ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

broadsword_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_BROADSWORD          ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD     ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 250                             ; ShopCost
        .byte WEAPON_BROADSWORD               ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

broadsword_lvl_3:
        .byte SLOT_WEAPON                      ; SlotId
        .byte SPRITE_TILE_BROADSWORD           ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_BROADSWORD      ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                ; HudSpriteTile
        .byte 0                                ; HudSpriteAttr
        .word 1000                             ; ShopCost
        .byte WEAPON_BROADSWORD                ; WeaponShape
        .addr flat_3                           ; DamageFunc
        .addr no_effect                        ; TorchlightFunc
        .addr do_nothing                       ; UseFunc

longsword_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_LONGSWORD           ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD      ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 75                              ; ShopCost
        .byte WEAPON_LONGSWORD                ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

longsword_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_LONGSWORD           ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD      ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 250                             ; ShopCost
        .byte WEAPON_LONGSWORD                ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

longsword_lvl_3:
        .byte SLOT_WEAPON                      ; SlotId
        .byte SPRITE_TILE_LONGSWORD            ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_LONGSWORD       ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                ; HudSpriteTile
        .byte 0                                ; HudSpriteAttr
        .word 1000                             ; ShopCost
        .byte WEAPON_LONGSWORD                 ; WeaponShape
        .addr flat_3                           ; DamageFunc
        .addr no_effect                        ; TorchlightFunc
        .addr do_nothing                       ; UseFunc

spear_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_SPEAR               ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR          ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 50                              ; ShopCost
        .byte WEAPON_SPEAR                    ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

spear_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_SPEAR               ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR          ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 200                             ; ShopCost
        .byte WEAPON_SPEAR                    ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

spear_lvl_3:
        .byte SLOT_WEAPON                      ; SlotId
        .byte SPRITE_TILE_SPEAR                ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_SPEAR           ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                ; HudSpriteTile
        .byte 0                                ; HudSpriteAttr
        .word 750                              ; ShopCost
        .byte WEAPON_SPEAR                     ; WeaponShape
        .addr flat_3                           ; DamageFunc
        .addr no_effect                        ; TorchlightFunc
        .addr do_nothing                       ; UseFunc

flail_lvl_1:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_FLAIL               ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL          ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 100                             ; ShopCost
        .byte WEAPON_FLAIL                    ; WeaponShape
        .addr flat_1                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

flail_lvl_2:
        .byte SLOT_WEAPON                     ; SlotId
        .byte SPRITE_TILE_FLAIL               ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL          ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)  ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 350                             ; ShopCost
        .byte WEAPON_FLAIL                    ; WeaponShape
        .addr flat_2                          ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

flail_lvl_3:
        .byte SLOT_WEAPON                      ; SlotId
        .byte SPRITE_TILE_FLAIL                ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE                ; WorldSpriteAttr
        .byte EQUIPMENT_WEAPON_FLAIL           ; HudBgTile
        .byte (HUD_PURPLE_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                ; HudSpriteTile
        .byte 0                                ; HudSpriteAttr
        .word 1250                             ; ShopCost
        .byte WEAPON_FLAIL                     ; WeaponShape
        .addr flat_3                           ; DamageFunc
        .addr no_effect                        ; TorchlightFunc
        .addr do_nothing                       ; UseFunc

basic_torch:
        .byte SLOT_TORCH                        ; SlotId
        .byte SPRITE_TILE_BASIC_TORCH           ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                   ; WorldSpriteAttr
        .byte EQUIPMENT_BASIC_TORCH             ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 50                                ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr flat_8                            ; TorchlightFunc
        .addr do_nothing                        ; UseFunc

large_torch:
        .byte SLOT_TORCH                        ; SlotId
        .byte SPRITE_TILE_LARGE_TORCH           ; WorldSpriteTile
        .byte SPRITE_PAL_RED                    ; WorldSpriteAttr
        .byte EQUIPMENT_LARGE_TORCH             ; HudBgTile
        .byte (HUD_RED_PAL | CHR_BANK_ITEMS)    ; HudBgAttr
        .byte 0                                 ; HudSpriteTile
        .byte 0                                 ; HudSpriteAttr
        .word 150                               ; ShopCost
        .byte WEAPON_DAGGER                     ; WeaponShape (unused)
        .addr no_effect                         ; DamageFunc
        .addr flat_15                           ; TorchlightFunc
        .addr do_nothing                        ; UseFunc

compass:
        .byte SLOT_CONSUMABLE                 ; SlotId (irrelevant)
        .byte SPRITE_TILE_COMPASS             ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 75                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr reveal_special_rooms            ; UseFunc

map:
        .byte SLOT_CONSUMABLE                 ; SlotId (irrelevant)
        .byte SPRITE_TILE_MAP                 ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 150                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr reveal_all_rooms                ; UseFunc

small_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId (irrelevant)
        .byte SPRITE_TILE_SMALL_FRIES         ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 25                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_4_hp                       ; UseFunc

medium_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId (irrelevant)
        .byte SPRITE_TILE_MEDIUM_FRIES        ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 100                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_8_hp                       ; UseFunc

large_fries:
        .byte SLOT_CONSUMABLE                 ; SlotId (irrelevant)
        .byte SPRITE_TILE_LARGE_FRIES         ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 225                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_12_hp                      ; UseFunc

; Note: as an item with a custom effect, these are just special-case checked
; in the player movement code
go_go_boots:
        .byte SLOT_BOOTS                      ; SlotId (irrelevant)
        .byte SPRITE_TILE_GO_GO_BOOTS         ; WorldSpriteTile (obviously broken)
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_GO_GO_BOOTS           ; HudBgTile
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr
        .byte 0                               ; HudSpriteTile
        .byte 0                               ; HudSpriteAttr
        .word 150                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr do_nothing                      ; UseFunc

        .segment "CODE_0"

; Flat value functions. If these seem remarkably inefficient, that's because they are

.proc no_effect
        lda #0
        rts
.endproc

.proc flat_1
        lda #1
        rts
.endproc

.proc flat_2
        lda #2
        rts
.endproc

.proc flat_3
        lda #3
        rts
.endproc

.proc flat_4
        lda #4
        rts
.endproc

.proc flat_5
        lda #5
        rts
.endproc

.proc flat_6
        lda #6
        rts
.endproc

.proc flat_7
        lda #7
        rts
.endproc

.proc flat_8
        lda #8
        rts
.endproc

.proc flat_9
        lda #9
        rts
.endproc

.proc flat_10
        lda #10
        rts
.endproc

.proc flat_11
        lda #11
        rts
.endproc

.proc flat_12
        lda #12
        rts
.endproc

.proc flat_13
        lda #13
        rts
.endproc

.proc flat_14
        lda #14
        rts
.endproc

.proc flat_15
        lda #15
        rts
.endproc

.proc do_nothing
        rts
.endproc

; Reveal just "special" chambers! Meant for the compass
.proc reveal_special_rooms
        ldx #0
loop:
        perform_zpcm_inc
        ; if this room has an exit, reveal it!
        lda room_flags, x
        and #ROOM_FLAG_EXIT_STAIRS
        bne reveal_room
        ; if this room is a challenge chamber, reveal it!
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_CHALLENGE
        beq reveal_room
        ; if this room is a shop, reveal it!
        lda room_properties, x
        and #ROOM_CATEGORY_MASK
        cmp #ROOM_CATEGORY_SHOP
        beq reveal_room
        jmp done_with_this_room
reveal_room:
        lda room_flags, x
        ora #ROOM_FLAG_REVEALED
        sta room_flags, x
done_with_this_room:
        inx
        cpx #::FLOOR_SIZE
        bne loop

        lda #1
        sta HudMapDirty

        ; Play a SFX! Maybe a custom one later, but we'll use the same one for health
        ; containers just to have something
        st16 R0, sfx_heart_container
        jsr play_sfx_pulse1

        rts
.endproc

; Same deal but it's not picky; reveal the *entire* map!
.proc reveal_all_rooms
        ldx #0
loop:
        perform_zpcm_inc
        lda room_flags, x
        ora #ROOM_FLAG_REVEALED
        sta room_flags, x
done_with_this_room:
        inx
        cpx #::FLOOR_SIZE
        bne loop

        lda #1
        sta HudMapDirty

        ; Play a SFX! Maybe a custom one later, but we'll use the same one for health
        ; containers just to have something
        st16 R0, sfx_heart_container
        jsr play_sfx_pulse1

        rts
.endproc

; TODO: rewrite all of these when we completely overhaul hearts
.proc heal_4_hp
HealingAmount := R0
        lda #4
        sta HealingAmount
        far_call FAR_receive_healing

        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        rts
.endproc

.proc heal_8_hp
HealingAmount := R0
        lda #8
        sta HealingAmount
        far_call FAR_receive_healing

        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        rts
.endproc

.proc heal_12_hp
HealingAmount := R0
        lda #12
        sta HealingAmount
        far_call FAR_receive_healing

        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        rts
.endproc

.proc FAR_apply_item_world_metasprite
MetaSpriteIndex := R0
ItemIndex := R1
ItemPtr := R2
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldx MetaSpriteIndex
        ldy #ItemDef::WorldSpriteTile
        lda (ItemPtr), y
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldx MetaSpriteIndex
        ldy #ItemDef::WorldSpriteAttr
        lda (ItemPtr), y
        ora #SPRITE_ACTIVE ; TODO: if we're going to bob the item up and down, do that here
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        restore_previous_bank

        rts
.endproc

.proc FAR_apply_item_hud_metasprite
MetaSpriteIndex := R0
ItemIndex := R1
ItemPtr := R2
        access_data_bank #<.bank(item_table)

        lda ItemIndex
        asl ; index into the word table
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ldx MetaSpriteIndex
        ldy #ItemDef::HudSpriteTile
        lda (ItemPtr), y
        sta sprite_table + MetaSpriteState::TileIndex, x

        ldx MetaSpriteIndex
        ldy #ItemDef::HudSpriteAttr
        lda (ItemPtr), y
        sta sprite_table + MetaSpriteState::BehaviorFlags, x

        restore_previous_bank

        rts
.endproc

.proc __item_logic_trampoline
        jmp (ItemFuncPtr)
.endproc

; TODO: maybe rework this to accept an item ID, to make it more generic?
.proc FAR_pickup_item
NewItem := R0
OldItem := R0

ItemPtr := R16
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        lda NewItem
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        lda NewItem
        pha
        ; Play a joyous SFX
        ; TODO: should this be a different sound depending on the type of item? (yes, but how?)
        st16 R0, sfx_equip_ability_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_equip_ability_pulse2
        jsr play_sfx_pulse2
        pla
        sta NewItem

        ldy #ItemDef::SlotId
        lda (ItemPtr), y
        cmp #SLOT_CONSUMABLE
        beq pickup_consumable_item
        ; TODO: bombs are a special case
        ; (spells are not really)
pickup_equipped_item:
        ; switcheroo!
        tay
        lda player_equipment_by_index, y
        tax
        lda NewItem
        sta player_equipment_by_index, y
        stx OldItem

restore_previous_bank
        perform_zpcm_inc
        rts

pickup_consumable_item:
        ldy #ItemDef::UseFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline

        lda #0
        sta OldItem

        restore_previous_bank
        rts
.endproc

; item index in A
.proc item_damage_common
DmgTotal := R0
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::DamageFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        clc
        adc DmgTotal
        sta DmgTotal
        rts
.endproc

; Returns weapon dmg amount in A, based on the currently loaded item
; Clobbers: TODO, probably at least X,Y
.proc FAR_weapon_dmg
DmgTotal := R0
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; Loop through all 5 equipment slots and keep a running sum of their damage
        ; contributions
        lda #0
        sta DmgTotal

        lda PlayerEquipmentWeapon
        jsr item_damage_common
        perform_zpcm_inc
        lda PlayerEquipmentTorch
        jsr item_damage_common
        perform_zpcm_inc
        lda PlayerEquipmentArmor
        jsr item_damage_common
        perform_zpcm_inc
        lda PlayerEquipmentBoots
        jsr item_damage_common
        perform_zpcm_inc
        lda PlayerEquipmentAccessory
        jsr item_damage_common
        perform_zpcm_inc

        restore_previous_bank
        lda DmgTotal
        rts
.endproc

; item index in A
.proc item_torchlight_common
TorchlightTotal := R0
        asl
        tax
        lda item_table+0, x
        sta ItemPtr+0
        lda item_table+1, x
        sta ItemPtr+1
        ldy #ItemDef::TorchlightFunc
        lda (ItemPtr), y
        sta ItemFuncPtr+0
        iny
        lda (ItemPtr), y
        sta ItemFuncPtr+1
        jsr __item_logic_trampoline
        clc
        adc TorchlightTotal
        sta TorchlightTotal
        rts
.endproc

; Returns weapon dmg amount in A, based on the currently loaded item
; Clobbers: TODO, probably at least X,Y
.proc FAR_equipment_torchlight
TorchlightTotal := R0
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        ; Loop through all 5 equipment slots and keep a running sum of their 
        ; torchlight contributions
        lda #0
        sta TorchlightTotal

        lda PlayerEquipmentWeapon
        jsr item_torchlight_common
        perform_zpcm_inc
        lda PlayerEquipmentTorch
        jsr item_torchlight_common
        perform_zpcm_inc
        lda PlayerEquipmentArmor
        jsr item_torchlight_common
        perform_zpcm_inc
        lda PlayerEquipmentBoots
        jsr item_torchlight_common
        perform_zpcm_inc
        lda PlayerEquipmentAccessory
        jsr item_torchlight_common
        perform_zpcm_inc

        ; safety: make sure the torchlight is at least the guaranteed minimum
        lda TorchlightTotal
        cmp #PLAYER_BASE_TORCHLIGHT
        bcs torchlight_mininum_satisfied
        lda #PLAYER_BASE_TORCHLIGHT
        sta TorchlightTotal
torchlight_mininum_satisfied:

        ; safety: make sure we aren't *above* the maximum torchlight we can render
        lda TorchlightTotal
        cmp #MAXIMUM_TORCHLIGHT_RADIUS
        bcc torchlight_maximum_satisfied
        lda #MAXIMUM_TORCHLIGHT_RADIUS
        sta TorchlightTotal
torchlight_maximum_satisfied:

        restore_previous_bank
        perform_zpcm_inc
        lda TorchlightTotal
        rts
.endproc