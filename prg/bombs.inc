MAX_ACTIVE_BOMBS = 6

BOMB_FLAG_ACTIVE = %10000000

.struct BombState
    Flags .byte
    State .byte
    FuseDuration .byte ; in whole beats
    FrameCounter .byte ; in non-lag hardware frames
    PartyCounter .byte ; in non-lag hardware frames
    MetaspriteIndex .byte
    CurrentRow .byte ; in tiles, mostly used for game logic
    CurrentCol .byte
    TargetPosX .word ; in pixels, where we want to be after lerping
    TargetPosY .word
    CurrentPosX .word ; in pixels, where we currently are during lerping
    CurrentPosY .word
.endstruct

.global FAR_init_bomb_state ; call during room init
.global FAR_try_hoist_bomb
.global FAR_throw_held_bomb
.global FAR_tick_bomb_fuses
.global FAR_update_active_bombs
.global FAR_spawn_party_bomb
