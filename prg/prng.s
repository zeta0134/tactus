        .setcpu "6502"
        .include "prng.inc"
        .include "player.inc"
        .include "levels.inc"
        .include "zpcm.inc"
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

.zeropage
seed: .res 2 ; seed can be 2-4 bytes
fixed_seed: .res 2

        .segment "PRGFIXED_E000"

; overlapped version, computes all 8 iterations in an overlapping fashion
; 69 cycles
; 35 bytes

next_rand:
	lda seed+1
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0 ; recombine with original low byte
	sta seed+1
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
	sta seed+0
	asl
	eor seed+0
	asl
	eor seed+0
	asl
	asl
	asl
	eor seed+0
	sta seed+0
	perform_zpcm_inc
	rts

next_fixed_rand:
	lda fixed_seed+1
	tay ; store copy of high byte
	; compute fixed_seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta fixed_seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor fixed_seed+1
	lsr
	eor fixed_seed+1
	eor fixed_seed+0 ; recombine with original low byte
	sta fixed_seed+1
	; compute fixed_seed+0 ($39 = %111001)
	tya ; original high byte
	sta fixed_seed+0
	asl
	eor fixed_seed+0
	asl
	eor fixed_seed+0
	asl
	asl
	asl
	eor fixed_seed+0
	sta fixed_seed+0
	perform_zpcm_inc
	rts

.proc set_fixed_room_seed
	perform_zpcm_inc
        lda global_rng_seed
        sta fixed_seed
        ldx PlayerRoomIndex
        lda room_seeds, x
        sta fixed_seed+1
        ; I've noticed that the first number pulled can be a *mite* predictable, so to
        ; resolve this run the routine twice before returning
        jsr next_fixed_rand
        jsr next_fixed_rand
        rts
.endproc