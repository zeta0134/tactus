MAX_METASPRITES = 16
SHADOW_OAM = $0200
OAM_Y_POS = 0
OAM_TILE = 1
OAM_ATTRIBUTES = 2
OAM_X_POS = 3
ONE_SPRITE = 4

.struct MetaSpriteState
        PositionX .byte
        PositionY .byte
        BehaviorFlags .byte ; and also palette
        TileIndex .byte
        LifetimeBeats .byte
.endstruct

; These come first so we can use the behavior
; flags byte as the OAM attributes byte
SPRITE_VERT_FLIP   = %10000000
SPRITE_HORIZ_FLIP  = %01000000
SPRITE_BG_PRIORITY = %00100000
SPRITE_ACTIVE      = %00010000
SPRITE_RISE        = %00001000
SPRITE_ONE_BEAT    = %00000100
; the last 2 bits are the sprite palette

.global sprite_table

.global FAR_initialize_sprites
.global FAR_draw_sprites
.global FAR_age_sprites
.global FAR_find_unused_sprite
.global FAR_despawn_unimportant_sprites

SPRITES_PLAYER_IDLE = $01
SPRITES_DEATH_SKULL = $05
SPRITES_DAMAGE_PLAYER = $2D

SPRITE_PAL_0 = %00
SPRITE_PAL_1 = %01
SPRITE_PAL_2 = %10
SPRITE_PAL_3 = %11