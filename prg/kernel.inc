.globalzp GameMode
.globalzp FadeToGameMode
.global CurrentBeatCounter
.global DisplayedRowCounter
.global AccumulatedGameBeats

.global PlayfieldBgHighBank
.global PlayfieldObjHighBank
.global HudBgHighBank
.global HudObjHighBank

; subroutines
.global FAR_kernel_game_loop

; kernel states
.global init_engine
.global room_init
.global advance_to_next_floor
.global fade_to_game_mode
.global game_prep
.global title_prep
.global options_prep
.global game_end_screen_prep

.globalzp PpuScrollX
.globalzp PpuScrollY
.globalzp PpuScrollNametable

.globalzp ScreenShakeDepth
.globalzp ScreenShakeSpeed
.globalzp ScreenShakeDecayCounter