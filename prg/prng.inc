;.globalzp seed
;.globalzp fixed_seed

.global initialize_prng
.global next_gameplay_rand
.global next_floor_rand
.global next_room_rand
.global next_global_rand

.global generate_run_seed_for_save ; from the global seed in the save block
.global generate_room_seed  ; from the floor seed

.globalzp floor_seed, room_seed

.global prng_table
.global prng_entity_start_index
.global advance_prng_table

; Clobbers X, Result in A
.macro prng_from_table_x
    inc prng_entity_start_index
    ldx prng_entity_start_index
    lda prng_table, x
.endmacro

; Clobbers Y, Result in A
.macro prng_from_table_y
    inc prng_entity_start_index
    ldy prng_entity_start_index
    lda prng_table, y
.endmacro

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

; similar, but clamped to 0-31 to keep the performance in check. ideal
; for rather small rolls
.macro in_range_smol_from_table_y range
.scope
    prng_from_table_y
    and #$1F
    sec
divide_loop:
    sbc range
    bcs divide_loop
    adc range
    perform_zpcm_inc
.endscope
.endmacro
