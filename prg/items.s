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
        .word gold_sack
        .word heart_container
        .word temporary_heart
        .word heart_armor
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
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_COMPASS             ; WorldSpriteTile
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
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_MAP                 ; WorldSpriteTile
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
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_SMALL_FRIES         ; WorldSpriteTile
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
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_MEDIUM_FRIES        ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
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
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_LARGE_FRIES         ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape    (unused)
        .addr no_effect                       ; DamageFunc     (unused)
        .addr no_effect                       ; TorchlightFunc (unused)
        .addr heal_all_hp                     ; UseFunc

; Note: as an item with a custom effect, these are just special-case checked
; in the player movement code
go_go_boots:
        .byte SLOT_BOOTS                      ; SlotId
        .byte SPRITE_TILE_GO_GO_BOOTS         ; WorldSpriteTile
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

gold_sack:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_GOLD_SACK           ; WorldSpriteTile
        .byte SPRITE_PAL_GREY                 ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 0                               ; ShopCost (does not spawn in shops)
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_100_gold                   ; UseFunc

heart_container:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_HEART_CONTAINER     ; WorldSpriteTile
        .byte SPRITE_PAL_RED                  ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 250                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_heart_container            ; UseFunc

temporary_heart:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_HEART_CONTAINER     ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 50                              ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_temporary_heart            ; UseFunc

heart_armor:
        .byte SLOT_CONSUMABLE                 ; SlotId
        .byte SPRITE_TILE_HEART_ARMOR         ; WorldSpriteTile
        .byte SPRITE_PAL_PURPLE               ; WorldSpriteAttr
        .byte EQUIPMENT_NONE                  ; HudBgTile (unused)
        .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS) ; HudBgAttr (unused)
        .byte 0                               ; HudSpriteTile (unused)
        .byte 0                               ; HudSpriteAttr (unused)
        .word 100                             ; ShopCost
        .byte WEAPON_DAGGER                   ; WeaponShape (unused)
        .addr no_effect                       ; DamageFunc
        .addr no_effect                       ; TorchlightFunc
        .addr give_heart_armor                ; UseFunc

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

        lda #0 ; return success
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

        lda #0 ; return success
        rts
.endproc

.proc heal_4_hp
        lda #4
        jmp _heal_player_common
.endproc

.proc heal_8_hp
        lda #8
        jmp _heal_player_common
.endproc

.proc heal_12_hp
        lda #12
        jmp _heal_player_common
.endproc

.proc heal_all_hp
        lda #255 ; all of it!
        jmp _heal_player_common
.endproc

; Healing amount in A
.proc _heal_player_common
HealingAmount := R0
        ; sanity check: does the player have any health to heal?
        far_call FAR_missing_health
        bne proceed_to_heal
        ; this food item would do nothing! cancel the pickup/purchase
        lda #$FF ; return failure
        rts
proceed_to_heal:
        sta HealingAmount
        far_call FAR_receive_healing

        st16 R0, sfx_small_heart
        jsr play_sfx_triangle

        lda #0 ; return success
        rts
.endproc

.proc give_heart_container
NewHeartType := R0
HealingAmount := R0
        ; Can the player actually hold an additional heart?
        ldx #(MAX_REGULAR_HEARTS-1)
        lda heart_type, x
        cmp #HEART_TYPE_NONE      ; empty containers are fine
        beq okay_to_increase
        cmp #HEART_TYPE_TEMPORARY ; temporary containers are also fine
        beq okay_to_increase
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq okay_to_increase
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

okay_to_increase:
        ; Add one heart container to the player's maximum
        lda #HEART_TYPE_REGULAR
        sta NewHeartType
        far_call FAR_add_heart

        ; Regular heart containers start empty (otherwise it looks weird)
        ; so heal the player 4 HP to award the health it contains
        lda #4
        sta HealingAmount
        far_call FAR_receive_healing
        ; TODO: these are kinda uncommon. Maybe they should award a full heal?

        ; And we're done!
        lda #0 ; return success
        rts
.endproc

.proc give_temporary_heart
NewHeartType := R0
        ; Can the player actually hold an additional temporary heart?
        ; For this routine we intentionally restrict the player to 1
        ; full temporary heart maximum. (The underlying HP system CAN
        ; handle more than one, so this is a balance choice that we 
        ; may later revisit.)

        ; Starting from the left, examime each heart we find
        ldx #0
find_heart_loop:
        lda heart_type, x
        ; If we encounter an empty heart slot, we can spawn
        ; a temporary heart here
        cmp #HEART_TYPE_NONE
        beq okay_to_add
        ; If we encounter a temporary heart slot, we may be able
        ; to refill its health
        cmp #HEART_TYPE_TEMPORARY
        beq okay_to_heal
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq okay_to_heal
        ; Otherwise keep checking
        inx
        cpx #TOTAL_HEART_SLOTS
        bne find_heart_loop

fail_to_collect:
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

okay_to_add:
        ; Add one heart container to the player's maximum
        lda #HEART_TYPE_TEMPORARY
        sta NewHeartType
        far_call FAR_add_heart
        ; And we're done!
        lda #0 ; return success
        rts

okay_to_heal:
        ; At this stage, X is pointing at the temporary heart
        ; If the temporary heart is full, we fail!
        lda heart_hp, x
        cmp #4
        beq fail_to_collect
        ; Otherwise, top it up.
        lda #4
        sta heart_hp, x
        ; Success!
        lda #0 ; return success
        rts
.endproc

.proc give_heart_armor
        ; Starting from the left, look for the first
        ; normal/temporary heart that is unarmored
        ldx #0
find_heart_loop:
        lda heart_type, x
        cmp #HEART_TYPE_REGULAR
        beq upgrade_to_armored
        cmp #HEART_TYPE_TEMPORARY
        beq upgrade_to_temporary_armored
        ; Otherwise keep checking
        inx
        cpx #TOTAL_HEART_SLOTS
        bne find_heart_loop
fail_to_collect:
        ; Oh no! Whelp; cancel the thing then.
        lda #$FF ; return failure
        rts

upgrade_to_armored:
        lda #HEART_TYPE_REGULAR_ARMORED
        sta heart_type, x
        lda #0 ; return success
        rts

upgrade_to_temporary_armored:
        lda #HEART_TYPE_TEMPORARY_ARMORED
        sta heart_type, x
        lda #0 ; return success
        rts
.endproc

.proc give_100_gold
        add16w PlayerGold, #100
        clamp16 PlayerGold, #MAX_GOLD

        lda #0
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
InputNewItem := R0
OutputOldItem := R0
ItemPtr := R16
NewItem := R18
        perform_zpcm_inc
        access_data_bank #<.bank(item_table)

        lda InputNewItem
        sta NewItem

        lda NewItem
        asl
        tay
        lda item_table+0, y
        sta ItemPtr+0
        lda item_table+1, y
        sta ItemPtr+1

        ; Play a joyous SFX
        ; TODO: should this be a different sound depending on the type of item? (yes, but how?)
        st16 R0, sfx_equip_ability_pulse1
        jsr play_sfx_pulse1
        st16 R0, sfx_equip_ability_pulse2
        jsr play_sfx_pulse2

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
        stx OutputOldItem
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
        ; The return value in A indicates if the consumable item was consumed successfully
        beq successful_consumable_item
failed_consumable_item:
        ; Put the consumable item back in the square (the calling function can use this
        ; state as an error check)
        lda NewItem
        sta OutputOldItem
        restore_previous_bank
        rts
successful_consumable_item:
        ; Clear out the old item slot; we "consumed" the new item and left nothing behind
        lda #0
        sta OutputOldItem
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