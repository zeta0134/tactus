MAX_REGULAR_HEARTS := 5
MAX_TEMPORARY_HEARTS := 1
TOTAL_HEART_SLOTS := 6

HEART_TYPE_NONE              = 0
HEART_TYPE_REGULAR           = 1
HEART_TYPE_GLASS             = 2
HEART_TYPE_REGULAR_ARMORED   = 3
HEART_TYPE_TEMPORARY         = 4
HEART_TYPE_TEMPORARY_ARMORED = 5

.global heart_hp
.global heart_type

; Resets all heart slots to NONE with 0 HP. Warning: the player
; will immediately be considered dead! Generally call this just
; before adding starter hearts.
.global FAR_initialize_hearts_for_game
; call this after processing all player updates, resets dmg tracking
; among other things
.global FAR_reset_hearts_for_beat
; nonzero in A indicates apparent death (HP=0, no hearts, etc)
.global FIXED_is_player_considered_dead
; new heart type in R0, clobbers R1
.global FAR_add_heart
; damage/healing amount in R0, clobbers R1-R3
.global FAR_receive_damage
.global FAR_receive_healing