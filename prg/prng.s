        .setcpu "6502"
        .include "saves.inc"
        .include "prng.inc"
        .include "player.inc"
        .include "zpcm.inc"

	.zeropage
; Fast LQ seed for realtime decision making
gameplay_seed: .res 2 ; seed can be 2-4 bytes

; Slower HQ seeds for level generation
floor_seed: .res 4
room_seed: .res 4

	.segment "RNGRAM"
; Cached LQ source, for very quick decision making in otherwise
; expensive routines. Mostly used for pathfinding to keep costs down.
prng_table: .res 256

	.segment "PRGRAM"
prng_generation_index: .res 1
prng_entity_start_index: .res 1

        .segment "PRGFIXED_E000"

; Quick implementation notes for future zeta:
; GameSeed is stored in the save block and shared between all files, just so it
; persists. This is our "boot time entropy" which is basically clocked continuously
; as long as the battery doesn't run dry. We should try to clock this on UI screens
; when we otherwise have nothing to do.

; RunSeed is stored with the currently loaded file, and usually generated from the
; GameSeed, though it may be fixed in place by a player-facing feature. This is set
; at the start of a run and remains the same throughout that run. We used this to
; initialize all level generation tasks.

; floor_seed is generated based on the RunSeed, and clocked some initial number of
; times based on the level's sequence index, which gives each floor its own unique
; starting point in the LFSR sequence. The hope is that this is sufficient to keep
; generation feeling fresh without being a tremendous performance burden.

; room_seed is generated based on the floor_seed after the floor layout is finalized.
; In effect, all 24 rooms will have a known starting seed, but may clock their personal
; seed a variable number of times based on generation choices, like shop items or
; structures that need to re-roll. This ensures that deterministic rooms stay deterministic,
; even if a few rooms need to fudge their generation in response to what the player is
; carrying or some other condition.

; this just performs some quick sanity checks at game start
; call this at startup, and again each time the run seed or gameplay
; seed are modified (by, say, loading them from the save file)
.proc initialize_prng
	lda current_save + SaveFile::RunSeed + 0
	ora current_save + SaveFile::RunSeed + 1
	ora current_save + SaveFile::RunSeed + 2
	ora current_save + SaveFile::RunSeed + 3
	bne run_seed_valid
	lda #$FF
	sta current_save + SaveFile::RunSeed + 0
run_seed_valid:
	
	lda current_block + SaveBlock::GameSeed + 0
	ora current_block + SaveBlock::GameSeed + 1
	ora current_block + SaveBlock::GameSeed + 2
	ora current_block + SaveBlock::GameSeed + 3
	bne game_seed_valid
	lda #$FF
	sta current_block + SaveBlock::GameSeed + 0
game_seed_valid:

	lda #$FF
	sta gameplay_seed+0
	rts
.endproc

;
; 6502 LFSR PRNG - 16-bit
; Brad Smith, 2019
; http://rainwarrior.ca
;

; A 16-bit Galois LFSR

; Possible feedback values that generate a full 65535 step sequence:
; $2D = %00101101
; $39 = %00111001
; $3F = %00111111
; $53 = %01010011
; $BD = %10111101
; $D7 = %11010111

; $39 is chosen for its compact bit pattern

; overlapped 16bit version, computes all 8 iterations in an overlapping fashion
; 69 cycles
; 35 bytes

.proc next_gameplay_rand
	lda gameplay_seed+1
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta gameplay_seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor gameplay_seed+1
	lsr
	eor gameplay_seed+1
	eor gameplay_seed+0 ; recombine with original low byte
	sta gameplay_seed+1
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
	sta gameplay_seed+0
	asl
	eor gameplay_seed+0
	asl
	eor gameplay_seed+0
	asl
	asl
	asl
	eor gameplay_seed+0
	sta gameplay_seed+0
	perform_zpcm_inc
	rts
.endproc

;
; 6502 LFSR PRNG - 32-bit
; Brad Smith, 2019
; http://rainwarrior.ca
;

; A 32-bit Galois LFSR

; Possible feedback values that generate a full 4294967295 step sequence:
; $AF = %10101111
; $C5 = %11000101
; $F5 = %11110101

; $C5 is chosen

; Very HQ RNG source stored in the loaded save block. Mostly used to generate
; the run seed from game to game. Clock this continuously so it is difficult
; to predict. Note that this sorta makes the nonce redundant...
.proc next_global_rand
	perform_zpcm_inc
	; rotate the middle bytes left
	ldy current_block + SaveBlock::GameSeed+2 ; will move to current_block + SaveBlock::GameSeed+3 at the end
	lda current_block + SaveBlock::GameSeed+1
	sta current_block + SaveBlock::GameSeed+2
	; compute current_block + SaveBlock::GameSeed+1 ($C5>>1 = %1100010)
	lda current_block + SaveBlock::GameSeed+3 ; original high byte
	lsr
	sta current_block + SaveBlock::GameSeed+1 ; reverse: 100011
	lsr
	lsr
	lsr
	lsr
	eor current_block + SaveBlock::GameSeed+1
	lsr
	eor current_block + SaveBlock::GameSeed+1
	eor current_block + SaveBlock::GameSeed+0 ; combine with original low byte
	sta current_block + SaveBlock::GameSeed+1
	; compute current_block + SaveBlock::GameSeed+0 ($C5 = %11000101)
	lda current_block + SaveBlock::GameSeed+3 ; original high byte
	asl
	eor current_block + SaveBlock::GameSeed+3
	asl
	asl
	asl
	asl
	eor current_block + SaveBlock::GameSeed+3
	asl
	asl
	eor current_block + SaveBlock::GameSeed+3
	sty current_block + SaveBlock::GameSeed+3 ; finish rotating byte 2 into 3
	sta current_block + SaveBlock::GameSeed+0
	perform_zpcm_inc
	rts
.endproc

.proc generate_run_seed_for_save
	jsr next_global_rand
	sta current_save + SaveFile::RunSeed + 0
	jsr next_global_rand
	sta current_save + SaveFile::RunSeed + 1
	jsr next_global_rand
	sta current_save + SaveFile::RunSeed + 2
	jsr next_global_rand
	; ensure seed is not 0, which will lock up the LFSR
	ora #$80
	sta current_save + SaveFile::RunSeed + 3
	rts
.endproc

.proc next_floor_rand
	perform_zpcm_inc
	; rotate the middle bytes left
	ldy floor_seed+2 ; will move to floor_seed+3 at the end
	lda floor_seed+1
	sta floor_seed+2
	; compute floor_seed+1 ($C5>>1 = %1100010)
	lda floor_seed+3 ; original high byte
	lsr
	sta floor_seed+1 ; reverse: 100011
	lsr
	lsr
	lsr
	lsr
	eor floor_seed+1
	lsr
	eor floor_seed+1
	eor floor_seed+0 ; combine with original low byte
	sta floor_seed+1
	; compute floor_seed+0 ($C5 = %11000101)
	lda floor_seed+3 ; original high byte
	asl
	eor floor_seed+3
	asl
	asl
	asl
	asl
	eor floor_seed+3
	asl
	asl
	eor floor_seed+3
	sty floor_seed+3 ; finish rotating byte 2 into 3
	sta floor_seed+0
	perform_zpcm_inc
	rts
.endproc

.proc generate_room_seed
	jsr next_floor_rand
	sta room_seed+0
	jsr next_floor_rand
	sta room_seed+1
	jsr next_floor_rand
	sta room_seed+2
	jsr next_floor_rand
	; ensure seed is not 0, which will lock up the LFSR
	ora #$80
	sta room_seed+3
	rts
.endproc

.proc next_room_rand
	perform_zpcm_inc
	; rotate the middle bytes left
	ldy room_seed+2 ; will move to room_seed+3 at the end
	lda room_seed+1
	sta room_seed+2
	; compute room_seed+1 ($C5>>1 = %1100010)
	lda room_seed+3 ; original high byte
	lsr
	sta room_seed+1 ; reverse: 100011
	lsr
	lsr
	lsr
	lsr
	eor room_seed+1
	lsr
	eor room_seed+1
	eor room_seed+0 ; combine with original low byte
	sta room_seed+1
	; compute room_seed+0 ($C5 = %11000101)
	lda room_seed+3 ; original high byte
	asl
	eor room_seed+3
	asl
	asl
	asl
	asl
	eor room_seed+3
	asl
	asl
	eor room_seed+3
	sty room_seed+3 ; finish rotating byte 2 into 3
	sta room_seed+0
	perform_zpcm_inc
	rts
.endproc

.proc advance_prng_table
	jsr next_gameplay_rand
	ldy prng_generation_index
	sta prng_table, y
	inc prng_generation_index
	rts
.endproc
