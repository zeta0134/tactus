    .include "battlefield.inc"
    .include "coins.inc"
    .include "../build/tile_defs.inc"
    .include "player.inc"
    .include "sprites.inc"
    .include "slowam.inc"
    .include "word_util.inc"
    .include "zeropage.inc"
    .include "zpcm.inc"


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
queued_coin_id: .res ::MAX_QUEUED_COINS
queued_coin_pos: .res ::MAX_QUEUED_COINS

coin_queue_next: .res 1
coin_queue_last: .res 1
next_active_coin: .res 1

coin_spawn_cooldown: .res 1

coin_sprite_starting_index: .res 1

        .segment "PRGFIXED_E000"

; coin type in A, position in X
; clobbers A, Y
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

COIN_PAL_WHI  = $01
COIN_PAL_RED    = $02
COIN_PAL_PPL = $03

; indexed by entries in the coin queue. IDs into this table are what
; game logic will ultimately specify when spawning coins, usually on
; enemy defeat
coin_type_tile_id_lut:
    .byte SPRITE_TILE_LOOT_01 + 0 ; 0-value diamond (should be unused)
    .byte SPRITE_TILE_LOOT_01 + 2 ; 1-coin (white)
    .byte SPRITE_TILE_LOOT_23 + 0 ; 2-gem (red)
    .byte SPRITE_TILE_LOOT_23 + 2 ; 3-gem (purple)
    .byte SPRITE_TILE_LOOT_45 + 0 ; 5-jewel (red)
    .byte SPRITE_TILE_LOOT_45 + 2 ; 5-jewel (purple)
    .byte SPRITE_TILE_LOOT_67 + 0 ; 10-pearl (white)
    .byte SPRITE_TILE_LOOT_67 + 2 ; 10-obelisk (purple)
    .byte SPRITE_TILE_LOOT_01 + 0 ; 25-diamond (white)
coin_type_attribute_lut:
    .byte COIN_PAL_WHI ; 0-value diamond (should be unused)
    .byte COIN_PAL_WHI ; 1-coin
    .byte COIN_PAL_RED ; 2-gem (red)
    .byte COIN_PAL_PPL ; 3-gem (purple)
    .byte COIN_PAL_RED ; 5-jewel (red)
    .byte COIN_PAL_PPL ; 5-jewel (purple)
    .byte COIN_PAL_WHI ; 10-pearl (white)
    .byte COIN_PAL_PPL ; 10-obelisk (purple)
    .byte COIN_PAL_WHI ; 25-diamond
coin_type_value_lut:
    .byte 0  ; 0-value diamond (should be unused)
    .byte 1  ; 1-coin
    .byte 2  ; 2-gem (red)
    .byte 3  ; 3-gem (purple)
    .byte 5  ; 5-jewel (red)
    .byte 5  ; 5-jewel (purple)
    .byte 10 ; 10-pearl (white)
    .byte 10 ; 10-obelisk (purple)
    .byte 25 ; 25-diamond

coin_height_lut:
    ;32100123
    ;21012
    ;11
    ;0

    .byte 0, 3, 2, 1, 0, 0, $FF, $FE, $FD
    .byte 2, 1, 0, $FF, $FE
    .byte 1, $FF, 0, 0

    ;.byte 0, 3, 5, 6, 6, 6, 5, 3 ; first bounce
    ;.byte 0, 2, 3, 3, 2          ; second bounce
    ;.byte 0, 1, 0, 0             ; final bounce and skid

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
TOTAL_BOUNCE_TIME = FIRST_BOUNCE_DURATION + SECOND_BOUNCE_DURATION
SETTLE_DURATION = 20
VACUUM_DURATION = 8

COIN_STATE_INACTIVE = 0
COIN_STATE_FAST_BOUNCE = 2
COIN_STATE_SLOW_BOUNCE = 4
COIN_STATE_SETTLE = 6
COIN_STATE_VACUUM = 8

; Call this once when initializing the game as a whole. Do not call
; between rooms or zones, the coins will maintain their own state.
.proc FAR_init_coins
    perform_zpcm_inc
    lda #0
    sta coin_queue_next
    sta coin_queue_last
    sta next_active_coin
    sta coin_sprite_starting_index
    sta coin_spawn_cooldown

    lda #COIN_STATE_INACTIVE
    ldx #0
loop:
    perform_zpcm_inc
    sta coin_state, x
    inx
    cpx #::MAX_ACTIVE_COINS
    bne loop

    perform_zpcm_inc
    rts
.endproc

.proc FAR_update_coins
CoinStatePtr := R0
CoinIndex := R15
    ; try to spawn a new coin every frame
    jsr spawn_one_new_coin
    ; draw all active coins
    jsr draw_coins

    lda #0
    sta CoinIndex
loop:
    perform_zpcm_inc
    ldx CoinIndex
    lda coin_state, x
    beq coin_inactive
    tay
    lda coin_state_table+0, y
    sta CoinStatePtr+0
    lda coin_state_table+1, y
    sta CoinStatePtr+1
    jsr coin_state_trampoline
coin_inactive:
    inc CoinIndex
    lda CoinIndex
    cmp #MAX_ACTIVE_COINS
    bne loop

    perform_zpcm_inc
    rts  
.endproc

coin_state_table:
    .word coin_state_inactive
    .word coin_state_fast_bounce
    .word coin_state_slow_bounce
    .word coin_state_settle
    .word coin_state_collect

.proc coin_state_trampoline
CoinStatePtr := R0
    jmp (CoinStatePtr)
    ; wheeeeeee
.endproc

; if there is a waiting coin in the queue, attempts to spawn it
; in. fails if either the queue is empty or the active coin list is full
.proc spawn_one_new_coin
    perform_zpcm_inc
    lda coin_spawn_cooldown
    beq check_for_spawn
    dec coin_spawn_cooldown
    rts
check_for_spawn:
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
    perform_zpcm_inc
    ; common initialization for all coins
    lda #COIN_STATE_FAST_BOUNCE ; init
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
    perform_zpcm_inc
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
    perform_zpcm_inc

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
    perform_zpcm_inc
    
    ; advance!
    inc next_active_coin
    lda next_active_coin
    cmp #MAX_ACTIVE_COINS
    bcc done_advancing_active_coins
    lda #0
    sta next_active_coin
done_advancing_active_coins:

    inc coin_queue_next
    lda coin_queue_next
    and #$1F
    sta coin_queue_next

    lda #2
    sta coin_spawn_cooldown

    ; ... and we're done?
    perform_zpcm_inc
    rts
.endproc

SHUFFLE_NEXT_SPRITE = 5
SHUFFLE_NEXT_FRAME = 7
FIRST_COIN_SPRITE = 32

.proc draw_coins
CoinIndex := R0
SpriteIndex := R1
SpritePtr := R2
    lda #0
    sta CoinIndex
    lda coin_sprite_starting_index
    sta SpriteIndex

loop:
    perform_zpcm_inc
    ldx CoinIndex
    lda coin_state, x
    beq coin_inactive

    lda SpriteIndex
    clc
    adc #FIRST_COIN_SPRITE
    tay
    lda sprite_ptr_lut_low, y
    sta SpritePtr+0
    lda sprite_ptr_lut_high, y
    sta SpritePtr+1

    lda coin_pos_x_pixels, x
    ldy #SelfModifiedSprite::PosX
    sta (SpritePtr), y
    lda coin_pos_y_pixels, x
    ldy #SelfModifiedSprite::PosY
    sta (SpritePtr), y
    lda coin_tile_id, x
    ldy #SelfModifiedSprite::TileId
    sta (SpritePtr), y
    lda coin_attributes, x
    ldy #SelfModifiedSprite::Attributes
    sta (SpritePtr), y

coin_inactive:
    lda SpriteIndex
    clc
    adc #SHUFFLE_NEXT_SPRITE
    cmp #MAX_ACTIVE_COINS
    bcc sprite_index_okay
    sec
    sbc #MAX_ACTIVE_COINS
sprite_index_okay:
    sta SpriteIndex
    inc CoinIndex
    lda CoinIndex
    cmp #MAX_ACTIVE_COINS
    bne loop

    ; update the sprite pointer for proper rotation
    lda coin_sprite_starting_index
    clc
    adc #SHUFFLE_NEXT_FRAME
    cmp #MAX_ACTIVE_COINS
    bcc sprite_start_okay
    sec
    sbc #MAX_ACTIVE_COINS
sprite_start_okay:
    sta coin_sprite_starting_index

    perform_zpcm_inc
    rts    
.endproc

.proc coin_state_inactive
    ; shouldn't ever be called, but we might as well populate the table for safety
    rts
.endproc

.proc coin_state_fast_bounce
CoinIndex := R15
    
    ; apply fast coin speed
    ldx CoinIndex
    lda coin_pos_x_subpixels, x
    clc
    adc coin_speed_x_fast_low, x
    sta coin_pos_x_subpixels, x
    lda coin_pos_x_pixels, x
    adc coin_speed_x_fast_high, x
    sta coin_pos_x_pixels, x

    lda coin_pos_y_subpixels, x
    clc
    adc coin_speed_y_fast_low, x
    sta coin_pos_y_subpixels, x
    lda coin_pos_y_pixels, x
    adc coin_speed_y_fast_high, x
    sta coin_pos_y_pixels, x

    ; apply coin height
    lda coin_state_duration, x
    tay
    lda coin_pos_y_pixels, x
    sec
    sbc coin_height_lut, y
    sta coin_pos_y_pixels, x

    ; increment duration
    inc coin_state_duration, x
    ; if it is time to switch to the next state, do so
    lda coin_state_duration, x
    cmp #FIRST_BOUNCE_DURATION
    bcc done
    lda #COIN_STATE_SLOW_BOUNCE
    sta coin_state, x

done:
    rts
.endproc

.proc coin_state_slow_bounce
CoinIndex := R15
    ; apply slow coin speed
    ldx CoinIndex
    lda coin_pos_x_subpixels, x
    clc
    adc coin_speed_x_slow_low, x
    sta coin_pos_x_subpixels, x
    lda coin_pos_x_pixels, x
    adc coin_speed_x_slow_high, x
    sta coin_pos_x_pixels, x

    lda coin_pos_y_subpixels, x
    clc
    adc coin_speed_y_slow_low, x
    sta coin_pos_y_subpixels, x
    lda coin_pos_y_pixels, x
    adc coin_speed_y_slow_high, x
    sta coin_pos_y_pixels, x

    ; apply coin height
    lda coin_state_duration, x
    tay
    lda coin_pos_y_pixels, x
    sec
    sbc coin_height_lut, y
    sta coin_pos_y_pixels, x

    ; increment duration
    inc coin_state_duration, x
    ; if it is time to switch to the next state, do so
    lda coin_state_duration, x
    cmp #(FIRST_BOUNCE_DURATION+SECOND_BOUNCE_DURATION)
    bcc done
    lda #COIN_STATE_SETTLE
    sta coin_state, x
    lda #0
    sta coin_state_duration, x

done:
    rts
.endproc

.proc coin_state_settle
CoinIndex := R15
    ; Just wait for a few frames on the ground

    ; increment duration
    inc coin_state_duration, x
    ; if it is time to switch to the next state, do so
    lda coin_state_duration, x
    cmp #SETTLE_DURATION
    bcc done
    lda #COIN_STATE_VACUUM
    sta coin_state, x
    lda #0
    sta coin_state_duration, x

done:
    rts
.endproc

.proc coin_state_collect
TargetPosX := R0
TargetPosY := R1

CoinIndex := R15

    ; move some... distance towards the player's... current metasprite position
    ; that's not complicated, right?
    ldy PlayerSpriteIndex
    lda sprite_table + MetaSpriteState::PositionX, y
    clc 
    adc #4
    sta TargetPosX
    lda sprite_table + MetaSpriteState::PositionY, y
    sec
    sbc #4
    sta TargetPosY

    ldx CoinIndex
    lda TargetPosX
    sec
    sbc coin_pos_x_pixels, x
    cmp #$80 ; divide by 4, preserving sign?
    ror
    cmp #$80
    ror
    clc
    adc coin_pos_x_pixels, x
    sta coin_pos_x_pixels, x

    lda TargetPosY
    sec
    sbc coin_pos_y_pixels, x
    cmp #$80
    ror
    cmp #$80
    ror
    clc
    adc coin_pos_y_pixels, x
    sta coin_pos_y_pixels, x


    ; increment duration
    inc coin_state_duration, x
    ; if it is time to switch to the next state, do so
    lda coin_state_duration, x
    cmp #VACUUM_DURATION
    bcc done

    ; collect our value into the player's purse
    add16b PlayerGold, {coin_value, x}
    clamp16 PlayerGold, #MAX_GOLD

    ; set ourselves to inactive; we're done!
    lda #COIN_STATE_INACTIVE
    sta coin_state, x

done:
    rts
.endproc