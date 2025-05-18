; BG_TILE_TEPELORT_AFTERIMAGE_FILLED = $28a8
; BG_TILE_TEPELORT_AFTERIMAGE_OUTLINE = $28ac
; BG_TILE_TEPELORT_AFTERIMAGE_PLAIN = $28b0

; BG_TILE_CULTIST_FEET_GLOWING = $2018
; BG_TILE_CULTIST_HANDS_ON_GROUND = $201c
; BG_TILE_CULTIST_HANDS_RAISED = $2020
; BG_TILE_CULTIST_IDLE = $2024
; BG_TILE_CULTIST_KNOCKED_BACK = $2028

; BG_TILE_WARNING_FILLED = $28c4
; BG_TILE_WARNING_OUTLINE = $28c8
; BG_TILE_WARNING_PLAIN = $28cc

CULTIST_FLAGS_STATE        = %00001111
CULTIST_FLAGS_HP           = %01110000

; Why store this again? because we may be HIT by a player spell, and change our color, between beats!
CULTIST_DATA_SPELL_COLOR   = %11000000
CULTIST_DATA_SPELL_PATTERN = %00111000
CULTIST_DATA_BEAT_COUNTER  = %00000111

; ============================================================================================================================
; ===                                           Enemy Update Behaviors                                                     ===
; ============================================================================================================================
        .segment "ENEMY_UPDATE"

.proc ENEMY_UPDATE_cultist
    rts
.endproc

; ============================================================================================================================
; ===                                      Player Attacks Enemy Behaviors                                                  ===
; ============================================================================================================================
        .segment "ENEMY_ATTACK"

.proc ENEMY_ATTACK_direct_attack_cultist
    rts
.endproc

.proc ENEMY_ATTACK_indirect_attack_cultist
    rts
.endproc


; ============================================================================================================================
; ===                                Enemy Attacks Player / Collision Behaviors                                            ===
; ============================================================================================================================
        .segment "ENEMY_COLLIDE"

.proc ENEMY_COLLIDE_cultist_attacks_player
    rts
.endproc

; ============================================================================================================================
; ===                                    Explosion Attacks Enemy Behaviors                                                 ===
; ============================================================================================================================
        .segment "ENEMY_BOMB_SPELL"

.proc ENEMY_BOMB_SPELL_cultist_direct_explode
    rts
.endproc

.proc ENEMY_BOMB_SPELL_cultist_indirect_explode
    rts
.endproc

.proc ENEMY_BOMB_SPELL_cultist_spell_dispatch
    rts
.endproc

; ============================================================================================================================
; ===                                             Suspend Behaviors                                                        ===
; ============================================================================================================================
        .segment "ENEMY_UTIL"
.proc ENEMY_UTIL_cultist_suspend_logic
    rts
.endproc





















