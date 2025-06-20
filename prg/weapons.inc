.struct WeaponClass
        NumSquares .byte
        NorthSquaresPtr .word
        EastSquaresPtr .word
        SouthSquaresPtr .word
        WestSquaresPtr .word
        NorthAnimationPtr .word
        EastAnimationPtr .word
        SouthAnimationPtr .word
        WestAnimationPtr .word
.endstruct

.struct AttackSquare
        RelativePosX .byte
        RelativePosY .byte
        FxTileId .byte
        SecondaryFxTileId .byte
        BehaviorFlags .byte
.endstruct

.struct WeaponAnimEntry
        RelativePixelPosX .byte
        RelativePixelPosY .byte
        TileId .byte
        BehaviorFlags .byte
.endstruct

WEAPON_NO_BEHAVIOR     = %00000000
WEAPON_SINGLE_TARGET   = %00000001
WEAPON_CANCEL_MOVEMENT = %00000010
WEAPON_STRONG_HIT      = %00000100

WEAPON_DAGGER = 0
WEAPON_BROADSWORD = 1
WEAPON_LONGSWORD = 2
WEAPON_SPEAR = 3
WEAPON_FLAIL = 4
WEAPON_ANCHOR = 5

.global weapon_class_table
.global weapon_update_none

.global FAR_player_swing_weapon
.global FAR_draw_weapon_effects

.global FAR_calculate_weapon_damage

.global WeaponAttackLanded
.global WeaponProperties