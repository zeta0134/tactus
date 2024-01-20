.import __ZPCM_ADDRESS__

.macro perform_zpcm_inc
	inc __ZPCM_ADDRESS__
	;inc $7FFF
.endmacro