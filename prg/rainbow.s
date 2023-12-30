.include "rainbow.inc"

.segment "PRGFIXED_C000"

.proc rainbow_init
	; for PRG, our starting bank0 initially controls 32k from $8000
	; we want it to control 16k from $8000, and we want bank1 to control
	; everything from $C000 onwards
	lda #0
	sta MAP_PRG_8_HI
	sta MAP_PRG_8_LO
	sta MAP_PRG_C_HI
	lda #1
	sta MAP_PRG_C_LO
	; now we can switch to 16k banking, and $C000 behaves like our "fixed" bank, while
	; $8000 behaves like our old swappable bank:
	lda #(PRG_RAM_MODE_0 | PRG_ROM_MODE_1)
	sta MAP_PRG_CONTROL
	; Ideally we didn't just crash [fingers crossed] and can continue with setup XD

	; for CHR we want our 32k of CHR RAM accessible (for now) in big 8k chunks:
	lda #(CHR_CHIP_RAM | CHR_MODE_0)
	sta MAP_CHR_CONTROL
	;  let's default to bank 0 just in case
	lda #0
	sta MAP_CHR_0_HI
	sta MAP_CHR_0_LO

	; for PRG RAM, just map in all 8k in one big chunk
	; this stuff is battery backed, so we'll put save files here
	lda #$80 ; select PRG RAM
	sta MAP_PRG_6_HI
	lda #0
	sta MAP_PRG_6_LO

	; for nametables, set up something resembling vertical mirroring, but using FPGA RAM as the
	; backing memory (instead of the more typical CIRAM)
	lda #(NT_FPGA_RAM | NT_NO_EXT)
	sta MAP_NT_A_CONTROL
	sta MAP_NT_B_CONTROL
	sta MAP_NT_C_CONTROL
	sta MAP_NT_D_CONTROL
	lda #0
	sta MAP_NT_A_BANK
	sta MAP_NT_C_BANK
	lda #1
	sta MAP_NT_B_BANK
	sta MAP_NT_D_BANK

	rts
.endproc