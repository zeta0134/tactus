    .include "battlefield.inc"
    .include "coins.inc"
    .include "../build/tile_defs.inc"
    .include "zeropage.inc"


    .segment "PRGRAM"

MAX_ACTIVE_COINS = 12
coin_state: .res ::MAX_ACTIVE_COINS
coin_state_duration: .res ::MAX_ACTIVE_COINS
coin_pos_x_pixels: .res ::MAX_ACTIVE_COINS
coin_pos_y_pixels: .res ::MAX_ACTIVE_COINS
coin_pos_x_subpixels: .res ::MAX_ACTIVE_COINS
coin_pos_y_subpixels: .res ::MAX_ACTIVE_COINS
coin_speed_x_fast_high: .res ::MAX_ACTIVE_COINS
coin_speed_y_fast_high: .res ::MAX_ACTIVE_COINS
coin_speed_x_slow_high: .res ::MAX_ACTIVE_COINS
coin_speed_y_slow_high: .res ::MAX_ACTIVE_COINS
coin_speed_x_fast_low: .res ::MAX_ACTIVE_COINS
coin_speed_y_fast_low: .res ::MAX_ACTIVE_COINS
coin_speed_x_slow_low: .res ::MAX_ACTIVE_COINS
coin_speed_y_slow_low: .res ::MAX_ACTIVE_COINS
coin_tile_id: .res ::MAX_ACTIVE_COINS
coin_attributes: .res ::MAX_ACTIVE_COINS
coin_value: .res ::MAX_ACTIVE_COINS

MAX_QUEUED_COINS = 32
queued_coin_id: .res ::MAX_ACTIVE_COINS
queued_coin_pos: .res ::MAX_ACTIVE_COINS

coin_queue_next: .res 1
coin_queue_last: .res 1
next_active_coin: .res 1

        .segment "PRGFIXED_E000"

; coin type in A, position in X
; clobbers Y
; does not bother with sanity
.proc FIXED_spawn_coin
    ldy coin_queue_last
    ; Y now houses the position within the list
    ; literally all we do is write into the list and exit
    sta queued_coin_id, y
    txa
    sta queued_coin_pos, y
    inc coin_queue_last
    lda coin_queue_last
    and #$1F
    sta coin_queue_last
    rts
.endproc

    .segment "CODE_3"

COIN_PAL_WHITE = $01
COIN_PAL_ORANGE = $02
COIN_PAL_PURPLE = $03

; indexed by entries in the coin queue. IDs into this table are what
; game logic will ultimately specify when spawning coins, usually on
; enemy defeat
coin_type_tile_id_lut:
    .byte SPRITE_TILE_COIN_STACK_01 + 2 ; note: the left side here is a blank tile
    .byte SPRITE_TILE_COIN_STACK_23 + 0
    .byte SPRITE_TILE_COIN_STACK_23 + 2
    .byte SPRITE_TILE_COIN_SINGLE_01 + 0
    .byte SPRITE_TILE_COIN_SINGLE_01 + 2
    .byte SPRITE_TILE_COIN_SINGLE_23 + 0
    .byte SPRITE_TILE_COIN_SINGLE_23 + 2
    .byte SPRITE_TILE_COIN_NUGGETS_01 + 0
    .byte SPRITE_TILE_COIN_NUGGETS_01 + 2
    .byte SPRITE_TILE_COIN_NUGGETS_23 + 0
    .byte SPRITE_TILE_COIN_NUGGETS_23 + 2
    .byte SPRITE_TILE_COIN_GEMS_01 + 0
    .byte SPRITE_TILE_COIN_GEMS_01 + 2
    .byte SPRITE_TILE_COIN_GEMS_23 + 0
    .byte SPRITE_TILE_COIN_GEMS_23 + 2
    .byte SPRITE_TILE_COIN_GEMS_45 + 0
    .byte SPRITE_TILE_COIN_GEMS_45 + 2
    .byte SPRITE_TILE_COIN_GEMS_67 + 0
    .byte SPRITE_TILE_COIN_GEMS_67 + 2
coin_type_attribute_lut:
    .byte COIN_PAL_WHITE ; stack 1
    .byte COIN_PAL_WHITE ; stack 2
    .byte COIN_PAL_WHITE ; stack 3
    .byte COIN_PAL_WHITE ; single 0 
    .byte COIN_PAL_ORANGE ; single 1
    .byte COIN_PAL_ORANGE ; single 2
    .byte COIN_PAL_ORANGE ; single 3
    .byte COIN_PAL_ORANGE ; nugget 0
    .byte COIN_PAL_ORANGE ; nugget 1
    .byte COIN_PAL_ORANGE ; nugget 2
    .byte COIN_PAL_ORANGE ; nugget 3
    .byte COIN_PAL_PURPLE ; gems 0 (small jewel)
    .byte COIN_PAL_WHITE ; gems 1 (diamond)
    .byte COIN_PAL_PURPLE ; gems 2 (large jewel)
    .byte COIN_PAL_ORANGE ; gems 3 (square jewel)
    .byte COIN_PAL_ORANGE ; gems 4 (meowth coin)
    .byte COIN_PAL_WHITE ; gems 5 (pointed crystal)
    .byte COIN_PAL_PURPLE ; gems 6 (large crystal)
    .byte COIN_PAL_WHITE ; gems 7 (pearl)
coin_type_value_lut:
    .byte 1 ; stack 1
    .byte 2 ; stack 2
    .byte 3 ; stack 3
    .byte 1 ; single 0 
    .byte 1 ; single 1
    .byte 2 ; single 2
    .byte 2 ; single 3
    .byte 1 ; nugget 0
    .byte 2 ; nugget 1
    .byte 2 ; nugget 2
    .byte 3 ; nugget 3
    .byte 3 ; gems 0 (small jewel)
    .byte 25 ; gems 1 (diamond)
    .byte 5 ; gems 2 (large jewel)
    .byte 5 ; gems 3 (square jewel)
    .byte 5 ; gems 4 (meowth coin)
    .byte 10 ; gems 5 (pointed crystal)
    .byte 10 ; gems 6 (large crystal)
    .byte 10 ; gems 7 (pearl)

coin_height_lut:
    ;32100123
    ;21012
    ;11
    ;0
    .byte 0, 3, 5, 6, 6, 6, 5, 3 ; first bounce
    .byte 0, 2, 3, 3, 2          ; second bounce
    .byte 0, 1, 0, 0             ; final bounce and skid

coin_speed_slow_x_low_lut:
  .byte $cc, $80, $c3, $c4, $64, $ea, $b5, $4d, $11, $9f, $3d, $39, $83, $35, $5e, $62
  .byte $34, $80, $3d, $3c, $9c, $16, $4b, $b3, $ef, $61, $c3, $c7, $7d, $cb, $a2, $9e
coin_speed_slow_x_high_lut:
  .byte $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $ff, $00, $00, $ff, $00, $00
  .byte $ff, $00, $00, $ff, $00, $00, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $ff
coin_speed_slow_y_low_lut:
  .byte $11, $9f, $3d, $39, $83, $35, $5e, $62, $34, $80, $3d, $3c, $9c, $16, $4b, $b3
  .byte $ef, $61, $c3, $c7, $7d, $cb, $a2, $9e, $cc, $80, $c3, $c4, $64, $ea, $b5, $4d
coin_speed_slow_y_high_lut:
  .byte $00, $00, $ff, $00, $00, $ff, $00, $00, $ff, $00, $00, $ff, $00, $00, $ff, $00
  .byte $ff, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $ff, $00, $ff
coin_speed_fast_x_low_lut:
  .byte $98, $00, $85, $89, $c7, $d4, $6b, $99, $23, $3f, $7a, $72, $07, $69, $bd, $c5
  .byte $68, $00, $7b, $77, $39, $2c, $95, $67, $dd, $c1, $86, $8e, $f9, $97, $43, $3b
coin_speed_fast_x_high_lut:
  .byte $01, $ff, $ff, $01, $fe, $ff, $01, $fe, $00, $01, $fe, $00, $01, $fe, $00, $00
  .byte $fe, $01, $00, $fe, $01, $00, $fe, $01, $ff, $fe, $01, $ff, $fe, $01, $ff, $ff
coin_speed_fast_y_low_lut:
  .byte $23, $3f, $7a, $72, $07, $69, $bd, $c5, $68, $00, $7b, $77, $39, $2c, $95, $67
  .byte $dd, $c1, $86, $8e, $f9, $97, $43, $3b, $98, $00, $85, $89, $c7, $d4, $6b, $99
coin_speed_fast_y_high_lut:
  .byte $00, $01, $fe, $00, $01, $fe, $00, $00, $fe, $01, $00, $fe, $01, $00, $fe, $01
  .byte $ff, $fe, $01, $ff, $fe, $01, $ff, $ff, $01, $ff, $ff, $01, $fe, $ff, $01, $fe

tile_index_to_row_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte h
        .endrepeat
        .endrepeat

tile_index_to_col_lut:
        .repeat ::BATTLEFIELD_HEIGHT, h
        .repeat ::BATTLEFIELD_WIDTH, w
        .byte w
        .endrepeat
        .endrepeat

FIRST_BOUNCE_DURATION = 8
SECOND_BOUNCE_DURATION = 5
THIRD_BOUNCE_DURATION = 4
TOTAL_BOUNCE_TIME = FIRST_BOUNCE_DURATION + SECOND_BOUNCE_DURATION + THIRD_BOUNCE_DURATION

COIN_STATE_INACTIVE = 0
COIN_STATE_INIT = 1
COIN_STATE_FAST_BOUNCE = 2
COIN_STATE_SLOW_BOUNCE = 3
COIN_STATE_SETTLE = 4
COIN_STATE_VACUUM = 5
COIN_STATE_COLLECT = 6

; Call this once when initializing the game as a whole. Do not call
; between rooms or zones, the coins will maintain their own state.
.proc FAR_init_coins
    lda #0
    sta coin_queue_next
    sta coin_queue_last
    sta next_active_coin

    lda #COIN_STATE_INACTIVE
    ldx #0
loop:
    sta coin_state, x
    inx
    cpx #::MAX_ACTIVE_COINS
    bne loop

    rts
.endproc

.proc FAR_update_coins
    ; try to spawn a new coin every frame
    jsr spawn_one_new_coin
    rts  
.endproc

; if there is a waiting coin in the queue, attempts to spawn it
; in. fails if either the queue is empty or the active coin list is full
.proc spawn_one_new_coin
    lda coin_queue_next
    cmp coin_queue_last
    bne attempt_spawn
    rts ; no coins to spawn
attempt_spawn:
    ldx next_active_coin
    lda coin_state, x
    beq proceed_to_spawn
    rts ; no free slots for a coin to spawn into; we must wait until one frees up
        ; (coins live for an equal number of frames and fill these slots sequentially,
        ; so we don't need to scan the whole list, just the next item in the sequence)
proceed_to_spawn:
    ; common initialization for all coins
    lda #COIN_STATE_INIT ; init
    sta coin_state, x
    lda #0
    sta coin_state_duration, x
    sta coin_pos_x_subpixels, x
    sta coin_pos_y_subpixels, x
    ; use the queue index to initialize the direction/speed
    ldy coin_queue_next
    lda coin_speed_slow_x_low_lut, y
    sta coin_speed_x_slow_low, x
    lda coin_speed_slow_x_high_lut, y
    sta coin_speed_x_slow_high, x
    lda coin_speed_slow_y_low_lut, y
    sta coin_speed_y_slow_low, x
    lda coin_speed_slow_y_high_lut, y
    sta coin_speed_y_slow_high, x
    lda coin_speed_fast_x_low_lut, y
    sta coin_speed_x_fast_low, x
    lda coin_speed_fast_x_high_lut, y
    sta coin_speed_x_fast_high, x
    lda coin_speed_fast_y_low_lut, y
    sta coin_speed_y_fast_low, x
    lda coin_speed_fast_y_high_lut, y
    sta coin_speed_y_fast_high, x
    ; copy the value and tile ID from the coin type table
    ldy coin_queue_next
    lda queued_coin_id, y
    tay
    lda coin_type_tile_id_lut, y
    sta coin_tile_id, x
    lda coin_type_attribute_lut, y
    sta coin_attributes, x
    lda coin_type_value_lut, y
    sta coin_value, x
    ; use the coin's tile ID to determine its initial position
    ldy coin_queue_next
    lda queued_coin_pos, y
    tay
    lda tile_index_to_col_lut, y
    .repeat 4
    asl
    .endrepeat
    clc
    adc #4
    sta coin_pos_x_pixels, x

    ldy coin_queue_next
    lda queued_coin_pos, y
    tay
    lda tile_index_to_row_lut, y
    .repeat 4
    asl
    .endrepeat
    sec
    sbc #4
    sta coin_pos_y_pixels, x
    
    ; advance!
    inc next_active_coin
    inc coin_queue_next

    ; ... and we're done?
    rts
.endproc
