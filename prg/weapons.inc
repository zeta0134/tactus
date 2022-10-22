.struct WeaponClass
        TileIndex .byte
        NumSquares .byte
        NorthSquaresPtr .word
        EastSquaresPtr .word
        SouthSquaresPtr .word
        WestSquaresPtr .word
.endstruct

.struct AttackSquare
        RelativePosX .byte
        RelativePosY .byte
        BehaviorFlags .byte
.endstruct

WEAPON_SINGLE_TARGET   = %00000001
WEAPON_CANCEL_MOVEMENT = %00000010

WEAPON_CLASS_LENGTH = 5
WEAPON_DAGGER = 0
WEAPON_BROADSWORD = 1
WEAPON_LONGSWORD = 2
WEAPON_SPEAR = 3
WEAPON_FLAIL = 4
.global weapon_class_table
