    .include "items.inc"

    .include "../build/tile_defs.inc"
    .include "hud.inc"
    .include "sprites.inc"
    .include "weapons.inc"

    .segment "DATA_7"



    .segment "CODE_0"

dagger_lvl_1:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_DAGGER ; WorldSpriteTile
    .byte SPRITE_PAL_GREY; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_DAGGER; HudBgTile
    .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_DAGGER ; WeaponShape
    .addr flat_1     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

broadsword_lvl_1:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_BROADSWORD; WorldSpriteTile
    .byte SPRITE_PAL_GREY; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_BROADSWORD ; HudBgTile
    .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_BROADSWORD ; WeaponShape
    .addr flat_1     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

broadsword_lvl_2:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_BROADSWORD; WorldSpriteTile
    .byte SPRITE_PAL_RED ; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_BROADSWORD ; HudBgTile
    .byte (HUD_RED_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_BROADSWORD ; WeaponShape
    .addr flat_2     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

broadsword_lvl_3:
    .byte SLOT_WEAPON            ; SlotId
    .byte SPRITE_TILE_BROADSWORD ; WorldSpriteTile
    .byte SPRITE_PAL_PURPLE      ; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_BROADSWORD ; HudBgTile
    .byte (HUD_WORLD_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_BROADSWORD ; WeaponShape
    .addr flat_3     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

longsword_lvl_1:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_LONGSWORD; WorldSpriteTile
    .byte SPRITE_PAL_GREY; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_LONGSWORD ; HudBgTile
    .byte (HUD_TEXT_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_LONGSWORD ; WeaponShape
    .addr flat_1     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

longsword_lvl_2:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_LONGSWORD; WorldSpriteTile
    .byte SPRITE_PAL_RED ; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_LONGSWORD ; HudBgTile
    .byte (HUD_RED_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_LONGSWORD ; WeaponShape
    .addr flat_2     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

longsword_lvl_3:
    .byte SLOT_WEAPON ; SlotId
    .byte SPRITE_TILE_LONGSWORD; WorldSpriteTile
    .byte SPRITE_PAL_PURPLE ; WorldSpriteAttr
    .byte EQUIPMENT_WEAPON_LONGSWORD ; HudBgTile
    .byte (HUD_WORLD_PAL | CHR_BANK_ITEMS); HudBgAttr
    .byte 0 ; HudSpriteTile
    .byte 0 ; HudSpriteAttr
    .byte WEAPON_LONGSWORD ; WeaponShape
    .addr flat_3     ; DamageFunc
    .addr no_effect  ; TorchlightFunc
    .addr do_nothing ; UseFunc

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

.proc flat_6
    lda #6
    rts
.endproc

.proc flat_10
    lda #10
    rts
.endproc

.proc flat_12
    lda #12
    rts
.endproc

.proc flat_14
    lda #14
    rts
.endproc

.proc do_nothing
    rts
.endproc

    .segment "PRGFIXED_E000"

.proc FIXED_weapon_dmg
    ; stub: do no harm!
    lda #0
    rts
.endproc
