;.globalzp seed
;.globalzp fixed_seed

.global initialize_prng
.global next_gameplay_rand
.global next_run_rand
.global next_floor_rand
.global next_room_rand

.global generate_floor_seed ; from the run seed
.global generate_room_seed  ; from the floor seed

.globalzp run_seed, floor_seed, room_seed
.global initial_run_seed

; a rather inefficient but convenient macro to produce a random number
; between 0 and N-1. mostly meant for use during level generation where
; performance isn't a massive concern and we need to roll from odd-sized
; lists. avoid for gameplay, and consider avoiding in other places in 
; favor of powers-of-2 for speed reasons, but it's here if needed.
.macro in_range rand_func, range
.scope
    jsr rand_func
    sec
divide_loop:
    perform_zpcm_inc
    sbc range
    bcs divide_loop
    adc range
.endscope
.endmacro

; similar, but clamped to 0-31 to keep the performance in check. ideal
; for rather small rolls
.macro in_range_smol rand_func, range
.scope
    jsr rand_func
    and #$1F
    sec
divide_loop:
    sbc range
    bcs divide_loop
    adc range
    perform_zpcm_inc
.endscope
.endmacro
