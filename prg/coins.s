    .include "coins.inc"
    .include "../build/tile_defs.inc"
    .include "zeropage.inc"


    .segment "PRGRAM"

MAX_ACTIVE_COINS = 12
coin_pos_x_pixels: .res ::MAX_ACTIVE_COINS
coin_pos_y_pixels: .res ::MAX_ACTIVE_COINS
coin_pos_x_subpixels: .res ::MAX_ACTIVE_COINS
coin_pos_y_subpixels: .res ::MAX_ACTIVE_COINS
coin_speed_x_fast: .res ::MAX_ACTIVE_COINS
coin_speed_y_fast: .res ::MAX_ACTIVE_COINS
coin_speed_x_slow: .res ::MAX_ACTIVE_COINS
coin_speed_y_slow: .res ::MAX_ACTIVE_COINS
coin_tile_id: .res ::MAX_ACTIVE_COINS
coin_value: .res ::MAX_ACTIVE_COINS

MAX_QUEUED_COINS = 32
queued_coin_id: .res ::MAX_ACTIVE_COINS

    .segment "CODE_3"



coin_height_lut:
    ;32100123
    ;21012
    ;11
    ;0
    .byte 0, 3, 5, 6, 6, 6, 5, 3 ; first bounce
    .byte 0, 2, 3, 3, 2          ; second bounce
    .byte 0, 1, 0, 0             ; final bounce and skid

FIRST_BOUNCE_DURATION = 8
SECOND_BOUNCE_DURATION = 5
THIRD_BOUNCE_DURATION = 4
TOTAL_BOUNCE_TIME = FIRST_BOUNCE_DURATION + SECOND_BOUNCE_DURATION + THIRD_BOUNCE_DURATION




.proc spawn_coin
    rts
    
.endproc