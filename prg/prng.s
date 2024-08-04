        .setcpu "6502"
        .include "prng.inc"
        .include "player.inc"
        .include "zpcm.inc"

	.zeropage
gameplay_seed: .res 2 ; seed can be 2-4 bytes

run_seed: .res 4
floor_seed: .res 4
room_seed: .res 4

	.segment "RAM"

; For preserving this to display at various points. Once the run gets going,
; the real run seed is of course advanced repeatedly. For debugging purposes,
; it can be handy to know this seed to reproduce glitch setups.
initial_run_seed: .res 4

        .segment "PRGFIXED_E000"

; this just performs some quick sanity checks at game start
; call this at startup, and again each time the run seed or gameplay
; seed are modified (by, say, loading them from the save file)
.proc initialize_prng
	lda run_seed+0
	ora run_seed+1
	ora run_seed+2
	ora run_seed+3
	bne run_seed_valid
	lda #$FF
	sta run_seed+0
run_seed_valid:
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

.proc next_run_rand
	; rotate the middle bytes left
	ldy run_seed+2 ; will move to run_seed+3 at the end
	lda run_seed+1
	sta run_seed+2
	; compute run_seed+1 ($C5>>1 = %1100010)
	lda run_seed+3 ; original high byte
	lsr
	sta run_seed+1 ; reverse: 100011
	lsr
	lsr
	lsr
	lsr
	eor run_seed+1
	lsr
	eor run_seed+1
	eor run_seed+0 ; combine with original low byte
	sta run_seed+1
	; compute run_seed+0 ($C5 = %11000101)
	lda run_seed+3 ; original high byte
	asl
	eor run_seed+3
	asl
	asl
	asl
	asl
	eor run_seed+3
	asl
	asl
	eor run_seed+3
	sty run_seed+3 ; finish rotating byte 2 into 3
	sta run_seed+0
	perform_zpcm_inc
	rts
.endproc

.proc generate_floor_seed
	jsr next_run_rand
	sta floor_seed+0
	jsr next_run_rand
	sta floor_seed+1
	jsr next_run_rand
	sta floor_seed+2
	jsr next_run_rand
	; ensure seed is not 0, which will lock up the LFSR
	ora #$80
	sta floor_seed+3
	rts
.endproc

.proc next_floor_rand
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