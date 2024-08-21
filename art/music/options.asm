; Dn-FamiTracker exported music data: options.dnm
;

; Module header
	.word ft_song_list
	.word ft_instrument_list
	.word ft_sample_list
	.word ft_samples
	.word ft_groove_list
	.byte 0 ; flags
	.word 3600 ; NTSC speed
	.word 3000 ; PAL speed

; Instrument pointer list
ft_instrument_list:
	.word ft_inst_0
	.word ft_inst_1
	.word ft_inst_2
	.word ft_inst_3
	.word ft_inst_4
	.word ft_inst_5
	.word ft_inst_6
	.word ft_inst_7

; Instruments
ft_inst_0:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_5

ft_inst_1:
	.byte 0
	.byte $03
	.word ft_seq_2a03_50
	.word ft_seq_2a03_41

ft_inst_2:
	.byte 0
	.byte $13
	.word ft_seq_2a03_65
	.word ft_seq_2a03_56
	.word ft_seq_2a03_29

ft_inst_3:
	.byte 0
	.byte $13
	.word ft_seq_2a03_70
	.word ft_seq_2a03_61
	.word ft_seq_2a03_34

ft_inst_4:
	.byte 0
	.byte $07
	.word ft_seq_2a03_90
	.word ft_seq_2a03_71
	.word ft_seq_2a03_2

ft_inst_5:
	.byte 0
	.byte $03
	.word ft_seq_2a03_95
	.word ft_seq_2a03_76

ft_inst_6:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_5
	.word ft_seq_vrc6_4

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_125
	.word ft_seq_2a03_46
	.word ft_seq_2a03_24

; Sequences
ft_seq_2a03_2:
	.byte $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_24:
	.byte $03, $FF, $00, $00, $01, $01, $00
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_34:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_41:
	.byte $0C, $FF, $00, $01, $09, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_46:
	.byte $03, $02, $00, $01, $05, $07, $0C
ft_seq_2a03_50:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_56:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0E
ft_seq_2a03_61:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0C
ft_seq_2a03_65:
	.byte $0A, $FF, $00, $00, $0D, $0A, $07, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_70:
	.byte $15, $FF, $00, $00, $0A, $0A, $0A, $0A, $09, $08, $07, $06, $05, $05, $05, $05, $04, $04, $04, $03
	.byte $03, $02, $02, $01, $00
ft_seq_2a03_71:
	.byte $06, $FF, $00, $01, $2A, $22, $1C, $17, $13, $10
ft_seq_2a03_76:
	.byte $03, $FF, $00, $01, $2E, $27, $22
ft_seq_2a03_90:
	.byte $07, $FF, $00, $00, $0F, $0F, $0F, $0F, $0F, $0F, $00
ft_seq_2a03_95:
	.byte $04, $FF, $00, $00, $0F, $0F, $0F, $00
ft_seq_2a03_125:
	.byte $0E, $FF, $00, $00, $0F, $0F, $0E, $0B, $08, $04, $01, $00, $00, $00, $00, $00, $00, $00
ft_seq_vrc6_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_vrc6_5:
	.byte $19, $FF, $0E, $00, $0F, $0F, $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0B, $0A, $0A, $02, $02
	.byte $02, $02, $02, $02, $01, $01, $01, $01, $00

; DPCM instrument list (pitch, sample index)
ft_sample_list:

; DPCM samples list (location, size, bank)
ft_samples:

; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)
	.byte $04, $03, $03, $02, $00, $01

; Song pointer list
ft_song_list:
	.word ft_song_0

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 2	; frame count
	.byte 64	; pattern length
	.byte 0	; speed
	.byte 120	; tempo
	.byte 1	; groove position
	.byte 0	; initial bank


;
; Pattern and frame data for all songs below
;

; Bank 0
ft_s0_frames:
	.word ft_s0f0
	.word ft_s0f1
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c2, ft_s0p0c3, ft_s0p0c0, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p1c2, ft_s0p1c3, ft_s0p0c0, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c2:
	.byte $E4, $0D, $07, $E5, $0D, $0B, $E4, $0D, $03, $E5, $0D, $07, $E4, $0D, $07, $E5, $0D, $0B, $E4, $0D
	.byte $03, $E5, $0D, $05, $0D, $01

; Bank 0
ft_s0p0c3:
	.byte $E1, $F7, $11, $01, $E2, $F5, $11, $01, $E3, $F7, $11, $03, $82, $01, $E7, $FB, $11, $E2, $F1, $11
	.byte $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E3, $F7, $11, $03, $E7, $FB, $11, $03, $82, $01, $E2
	.byte $F6, $11, $F4, $11, $E1, $F7, $11, $E2, $F5, $11, $83, $E3, $F7, $11, $03, $82, $01, $E7, $FB, $11
	.byte $E2, $F1, $11, $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E3, $F7, $11, $03, $E7, $FB, $11, $03
	.byte $E2, $F4, $11, $01, $E7, $F9, $11, $01

; Bank 0
ft_s0p0c6:
	.byte $E6, $91, $88, $FC, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F, $03, $0A, $00, $7F, $00
	.byte $0F, $02, $7F, $00, $82, $01, $10, $7F, $11, $7F, $83, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A
	.byte $01, $7F, $03, $16, $00, $7F, $00, $82, $01, $0A, $7F, $0F, $7F, $11, $83, $7F, $01

; Bank 0
ft_s0p0c7:
	.byte $E0, $FC, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F, $03, $0A, $00, $7F, $00, $0F, $02
	.byte $7F, $00, $82, $01, $10, $7F, $11, $7F, $83, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F
	.byte $03, $16, $00, $7F, $00, $82, $01, $0A, $7F, $0F, $7F, $11, $83, $7F, $01

; Bank 0
ft_s0p1c2:
	.byte $E4, $0D, $07, $E5, $0D, $0B, $E4, $0D, $03, $E5, $0D, $07, $E4, $0D, $07, $E5, $0D, $05, $E4, $0D
	.byte $03, $E5, $0D, $01, $E4, $0D, $03, $E5, $0D, $07

; Bank 0
ft_s0p1c3:
	.byte $E1, $F7, $11, $01, $E2, $F5, $11, $01, $E3, $F7, $11, $03, $82, $01, $E7, $FB, $11, $E2, $F1, $11
	.byte $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E3, $F7, $11, $03, $E7, $FB, $11, $03, $82, $01, $E2
	.byte $F6, $11, $F4, $11, $E1, $F7, $11, $E2, $F5, $11, $83, $E3, $F7, $11, $03, $82, $01, $E7, $FB, $11
	.byte $E2, $F1, $11, $F6, $11, $E1, $F7, $11, $E2, $F6, $11, $E7, $F9, $11, $E2, $F6, $11, $F4, $11, $E7
	.byte $FB, $11, $E2, $F5, $11, $83, $E3, $F7, $11, $03

; Bank 0
ft_s0p1c6:
	.byte $E6, $05, $03, $7F, $01, $05, $01, $7F, $03, $05, $01, $7F, $03, $05, $00, $7F, $00, $09, $02, $7F
	.byte $00, $82, $01, $0A, $7F, $0B, $7F, $0C, $05, $7F, $83, $05, $03, $7F, $01, $05, $01, $7F, $03, $82
	.byte $01, $05, $11, $7F, $05, $7F, $09, $83, $7F, $01

; Bank 0
ft_s0p1c7:
	.byte $E0, $05, $03, $7F, $01, $05, $01, $7F, $03, $05, $01, $7F, $03, $05, $00, $7F, $00, $09, $02, $7F
	.byte $00, $82, $01, $0A, $7F, $0B, $7F, $0C, $05, $7F, $83, $05, $03, $7F, $01, $05, $01, $7F, $03, $82
	.byte $01, $05, $11, $7F, $05, $7F, $09, $83, $7F, $01


; DPCM samples (located at DPCM segment)
