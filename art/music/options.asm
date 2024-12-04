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
	.word ft_inst_8
	.word ft_inst_9
	.word ft_inst_10
	.word ft_inst_11

; Instruments
ft_inst_0:
	.byte 0
	.byte $01
	.word ft_seq_2a03_0

ft_inst_1:
	.byte 0
	.byte $01
	.word ft_seq_2a03_5

ft_inst_2:
	.byte 0
	.byte $00

ft_inst_3:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_5

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_50
	.word ft_seq_2a03_41

ft_inst_5:
	.byte 0
	.byte $11
	.word ft_seq_2a03_10
	.word ft_seq_2a03_4

ft_inst_6:
	.byte 0
	.byte $13
	.word ft_seq_2a03_65
	.word ft_seq_2a03_56
	.word ft_seq_2a03_29

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_70
	.word ft_seq_2a03_61
	.word ft_seq_2a03_34

ft_inst_8:
	.byte 0
	.byte $07
	.word ft_seq_2a03_90
	.word ft_seq_2a03_71
	.word ft_seq_2a03_2

ft_inst_9:
	.byte 0
	.byte $03
	.word ft_seq_2a03_95
	.word ft_seq_2a03_76

ft_inst_10:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_5
	.word ft_seq_vrc6_4

ft_inst_11:
	.byte 0
	.byte $13
	.word ft_seq_2a03_125
	.word ft_seq_2a03_46
	.word ft_seq_2a03_24

; Sequences
ft_seq_2a03_0:
	.byte $19, $FF, $00, $00, $0F, $0E, $0B, $09, $08, $07, $07, $06, $05, $05, $04, $04, $03, $03, $02, $02
	.byte $02, $01, $01, $01, $01, $00, $00, $00, $00
ft_seq_2a03_2:
	.byte $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_5:
	.byte $38, $FF, $00, $00, $02, $02, $02, $03, $03, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03
	.byte $03, $03, $03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	.byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $00
ft_seq_2a03_10:
	.byte $01, $FF, $00, $00, $0F
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
	.word ft_song_1
	.word ft_song_2

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 11	; frame count
	.byte 64	; pattern length
	.byte 0	; speed
	.byte 120	; tempo
	.byte 1	; groove position
	.byte 0	; initial bank

ft_song_1:
	.word ft_s1_frames
	.byte 1	; frame count
	.byte 64	; pattern length
	.byte 6	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank

ft_song_2:
	.word ft_s2_frames
	.byte 11	; frame count
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
	.word ft_s0f2
	.word ft_s0f3
	.word ft_s0f4
	.word ft_s0f5
	.word ft_s0f6
	.word ft_s0f7
	.word ft_s0f8
	.word ft_s0f9
	.word ft_s0f10
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p2c2, ft_s0p2c3, ft_s0p0c0, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p1c2, ft_s0p1c3, ft_s0p0c0, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f2:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p0c2, ft_s0p0c3, ft_s0p1c5, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f3:
	.word ft_s0p2c0, ft_s0p2c1, ft_s0p1c2, ft_s0p1c3, ft_s0p2c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f4:
	.word ft_s0p1c0, ft_s0p3c1, ft_s0p0c2, ft_s0p0c3, ft_s0p7c5, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f5:
	.word ft_s0p2c0, ft_s0p4c1, ft_s0p1c2, ft_s0p1c3, ft_s0p6c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f6:
	.word ft_s0p3c0, ft_s0p3c1, ft_s0p0c2, ft_s0p0c3, ft_s0p3c5, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f7:
	.word ft_s0p4c0, ft_s0p8c1, ft_s0p1c2, ft_s0p1c3, ft_s0p4c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f8:
	.word ft_s0p5c0, ft_s0p5c1, ft_s0p0c2, ft_s0p0c3, ft_s0p5c5, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
ft_s0f9:
	.word ft_s0p4c0, ft_s0p6c1, ft_s0p1c2, ft_s0p1c3, ft_s0p4c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f10:
	.word ft_s0p6c0, ft_s0p7c1, ft_s0p0c2, ft_s0p0c3, ft_s0p8c5, ft_s0p0c6, ft_s0p0c7, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c2:
	.byte $E8, $0D, $07, $E9, $0D, $0B, $E8, $0D, $03, $E9, $0D, $07, $E8, $0D, $07, $E9, $0D, $09, $0D, $01
	.byte $E8, $0D, $03, $E9, $0D, $05, $0D, $01

; Bank 0
ft_s0p0c3:
	.byte $E4, $F7, $11, $01, $E6, $F5, $11, $01, $E7, $F7, $11, $03, $82, $01, $EB, $FB, $11, $E6, $F1, $11
	.byte $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E7, $F7, $11, $03, $EB, $FB, $11, $03, $82, $01, $E6
	.byte $F6, $11, $F4, $11, $E4, $F7, $11, $E6, $F5, $11, $83, $E7, $F7, $11, $03, $82, $01, $EB, $FB, $11
	.byte $E6, $F1, $11, $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E7, $F7, $11, $03, $EB, $FB, $11, $03
	.byte $E6, $F4, $11, $01, $EB, $F9, $11, $01

; Bank 0
ft_s0p0c6:
	.byte $EA, $91, $88, $FB, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F, $03, $0A, $00, $7F, $00
	.byte $0F, $02, $7F, $00, $82, $01, $10, $7F, $11, $7F, $83, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A
	.byte $01, $7F, $03, $16, $00, $7F, $00, $82, $01, $0A, $7F, $0F, $7F, $11, $83, $7F, $01

; Bank 0
ft_s0p0c7:
	.byte $E3, $FB, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F, $03, $0A, $00, $7F, $00, $0F, $02
	.byte $7F, $00, $82, $01, $10, $7F, $11, $7F, $83, $0A, $03, $7F, $01, $0A, $01, $7F, $03, $0A, $01, $7F
	.byte $03, $16, $00, $7F, $00, $82, $01, $0A, $7F, $0F, $7F, $11, $83, $7F, $01

; Bank 0
ft_s0p1c0:
	.byte $E0, $93, $01, $92, $FF, $19, $05, $FF, $16, $0D, $1B, $07, $1D, $03, $19, $05, $16, $0D, $1B, $05
	.byte $1D, $01, $16, $03

; Bank 0
ft_s0p1c1:
	.byte $91, $82, $00, $03, $E0, $93, $01, $F8, $19, $05, $16, $0D, $1B, $07, $1D, $03, $19, $05, $16, $0D
	.byte $1B, $05, $1D, $01

; Bank 0
ft_s0p1c2:
	.byte $E8, $0D, $07, $E9, $0D, $0B, $E8, $0D, $03, $E9, $0D, $07, $E8, $0D, $07, $E9, $0D, $05, $E8, $0D
	.byte $03, $E9, $0D, $01, $E8, $0D, $03, $E9, $0D, $07

; Bank 0
ft_s0p1c3:
	.byte $E4, $F7, $11, $01, $E6, $F5, $11, $01, $E7, $F7, $11, $03, $82, $01, $EB, $FB, $11, $E6, $F1, $11
	.byte $F6, $11, $F4, $11, $F6, $11, $F6, $11, $83, $E7, $F7, $11, $03, $EB, $FB, $11, $03, $82, $01, $E6
	.byte $F6, $11, $F4, $11, $E4, $F7, $11, $E6, $F5, $11, $83, $E7, $F7, $11, $03, $82, $01, $EB, $FB, $11
	.byte $E6, $F1, $11, $F6, $11, $E4, $F7, $11, $E6, $F6, $11, $EB, $F9, $11, $E6, $F6, $11, $F4, $11, $EB
	.byte $FB, $11, $E6, $F5, $11, $83, $E7, $F7, $11, $03

; Bank 0
ft_s0p1c5:
	.byte $91, $84, $00, $07, $E0, $93, $07, $F4, $19, $05, $16, $0D, $1B, $07, $1D, $03, $19, $05, $16, $0D
	.byte $1B, $03

; Bank 0
ft_s0p1c6:
	.byte $EA, $05, $03, $7F, $01, $05, $01, $7F, $03, $05, $01, $7F, $03, $05, $00, $7F, $00, $09, $02, $7F
	.byte $00, $82, $01, $0A, $7F, $0B, $7F, $0C, $05, $7F, $83, $05, $03, $7F, $01, $05, $01, $7F, $03, $82
	.byte $01, $05, $11, $7F, $05, $7F, $09, $83, $7F, $01

; Bank 0
ft_s0p1c7:
	.byte $E3, $05, $03, $7F, $01, $05, $01, $7F, $03, $05, $01, $7F, $03, $05, $00, $7F, $00, $09, $02, $7F
	.byte $00, $82, $01, $0A, $7F, $0B, $7F, $0C, $05, $7F, $83, $05, $03, $7F, $01, $05, $01, $7F, $03, $82
	.byte $01, $05, $11, $7F, $05, $7F, $09, $83, $7F, $01

; Bank 0
ft_s0p2c0:
	.byte $E0, $93, $01, $92, $FF, $18, $05, $15, $0D, $1B, $07, $1D, $03, $18, $05, $11, $0D, $1D, $05, $1D
	.byte $01, $11, $03

; Bank 0
ft_s0p2c1:
	.byte $91, $82, $00, $03, $E0, $93, $01, $F8, $18, $05, $15, $0D, $1B, $07, $1D, $03, $18, $05, $11, $0D
	.byte $1D, $05, $1D, $01

; Bank 0
ft_s0p2c2:
	.byte $E8, $0D, $07, $E9, $0D, $0B, $E8, $0D, $03, $E9, $0D, $07, $E8, $0D, $07, $E9, $0D, $09, $0D, $01
	.byte $E8, $0D, $03, $E9, $0D, $07

; Bank 0
ft_s0p2c3:
	.byte $E4, $F7, $11, $07, $EB, $FB, $11, $0B, $E4, $F7, $11, $03, $EB, $FB, $11, $07, $E4, $F7, $11, $07
	.byte $EB, $FB, $11, $09, $FB, $11, $01, $E4, $F7, $11, $03, $EB, $FB, $11, $03, $E6, $F7, $11, $00, $94
	.byte $01, $F4, $11, $00, $94, $02, $E7, $F6, $11, $01

; Bank 0
ft_s0p2c5:
	.byte $00, $07, $E0, $93, $07, $F4, $18, $05, $15, $0D, $1B, $07, $1D, $03, $18, $05, $11, $11

; Bank 0
ft_s0p3c0:
	.byte $E0, $93, $01, $92, $FF, $19, $03, $93, $03, $F8, $19, $01, $FF, $16, $03, $F8, $16, $09, $82, $03
	.byte $FF, $1B, $F8, $1B, $FF, $1D, $FF, $19, $83, $F8, $19, $01, $FF, $16, $03, $F8, $16, $09, $FF, $1B
	.byte $03, $82, $01, $F8, $1B, $FF, $1D, $FF, $16, $83, $F8, $1D, $01

; Bank 0
ft_s0p3c1:
	.byte $E1, $8A, $93, $02, $8F, $06, $FF, $33, $00, $8D, $06, $35, $01, $8F, $16, $00, $00, $8F, $26, $00
	.byte $00, $8F, $36, $00, $00, $8F, $06, $31, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8F, $46, $00, $05, $8F, $26, $00, $00, $8F, $16, $00, $00, $8F, $06, $36, $03, $8F, $06, $35
	.byte $03, $8F, $06, $33, $03, $8F, $06, $35, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8F, $06, $31, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00, $00, $8F, $46, $00
	.byte $07, $8F, $06, $36, $03, $8F, $06, $35, $03, $8F, $06, $31, $03

; Bank 0
ft_s0p3c5:
	.byte $82, $00, $E0, $93, $01, $FA, $31, $F4, $30, $F9, $29, $F4, $31, $F9, $2E, $F4, $29, $93, $02, $FA
	.byte $35, $F4, $2E, $F9, $2E, $F4, $35, $F9, $31, $F4, $2E, $93, $03, $FA, $36, $F4, $31, $F9, $2E, $F4
	.byte $36, $F9, $31, $F4, $2E, $93, $02, $FA, $35, $F4, $31, $F9, $2A, $F4, $35, $F9, $2E, $F4, $2A, $93
	.byte $01, $FA, $31, $F4, $2E, $F9, $25, $F4, $31, $F9, $29, $F4, $25, $F9, $2E, $F4, $29, $93, $01, $FA
	.byte $31, $F4, $2E, $F9, $29, $F4, $31, $F9, $2E, $F4, $29, $93, $02, $FA, $35, $F4, $2E, $F9, $2E, $F4
	.byte $35, $F9, $31, $F4, $2E, $93, $03, $FA, $36, $F4, $31, $F9, $2E, $F4, $36, $F9, $31, $F4, $2E, $93
	.byte $02, $FA, $35, $F4, $31, $F9, $2A, $F4, $35, $F9, $2E, $F4, $2A, $93, $01, $FA, $31, $F4, $2E, $F9
	.byte $25, $F4, $31, $F9, $29, $F4, $25, $F9, $2E, $83, $F4, $29, $00

; Bank 0
ft_s0p4c0:
	.byte $E0, $93, $01, $92, $FF, $18, $03, $F8, $18, $01, $FF, $15, $03, $F8, $15, $09, $82, $03, $FF, $1B
	.byte $F8, $1B, $FF, $1D, $FF, $18, $83, $F8, $18, $01, $FF, $11, $03, $F8, $11, $09, $FF, $1D, $03, $82
	.byte $01, $F8, $1D, $FF, $1D, $FF, $11, $83, $F8, $1D, $01

; Bank 0
ft_s0p4c1:
	.byte $E1, $8A, $93, $02, $8F, $06, $FF, $33, $00, $8D, $06, $00, $01, $8F, $16, $00, $00, $8F, $26, $00
	.byte $00, $8F, $36, $00, $00, $8F, $00, $30, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8F, $36, $00, $05, $8F, $26, $00, $00, $8F, $16, $00, $00, $8F, $06, $36, $03, $8F, $06, $35
	.byte $03, $8F, $06, $31, $03, $8F, $06, $33, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8D, $0C, $8F, $06, $2D, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00, $00, $8F
	.byte $46, $00, $07, $8F, $06, $36, $03, $8F, $06, $35, $03, $8F, $06, $33, $02, $8A, $00, $00

; Bank 0
ft_s0p4c5:
	.byte $82, $00, $E0, $93, $01, $FA, $2D, $F4, $2E, $F9, $29, $F4, $2D, $F9, $2D, $F4, $29, $93, $02, $FA
	.byte $35, $F4, $2D, $F9, $2D, $F4, $35, $F9, $30, $F4, $2D, $93, $03, $FA, $36, $F4, $30, $F9, $2D, $F4
	.byte $36, $F9, $30, $F4, $2D, $93, $02, $FA, $35, $F4, $30, $F9, $2D, $F4, $35, $F9, $30, $F4, $2D, $93
	.byte $01, $FA, $33, $F4, $30, $F9, $29, $F4, $33, $F9, $2D, $F4, $29, $FA, $31, $F4, $2D, $93, $01, $FA
	.byte $30, $F4, $31, $F9, $29, $F4, $30, $F9, $2D, $F4, $29, $93, $02, $FA, $36, $F4, $2D, $F9, $2D, $F4
	.byte $36, $F9, $30, $F4, $2D, $93, $03, $FA, $35, $F4, $30, $F9, $2D, $F4, $35, $F9, $30, $F4, $2D, $93
	.byte $02, $FA, $33, $F4, $30, $F9, $2D, $F4, $33, $F9, $30, $F4, $2D, $93, $01, $FA, $31, $F4, $30, $F9
	.byte $29, $F4, $31, $FA, $30, $F4, $29, $F9, $29, $83, $F4, $30, $00

; Bank 0
ft_s0p5c0:
	.byte $E0, $93, $01, $92, $FF, $19, $03, $93, $03, $F8, $19, $01, $FF, $16, $03, $F8, $16, $05, $93, $01
	.byte $F3, $29, $01, $F4, $2A, $01, $82, $03, $FF, $1B, $F8, $1B, $FF, $1D, $FF, $19, $83, $F8, $19, $01
	.byte $FF, $16, $03, $F8, $16, $09, $FF, $1B, $03, $82, $01, $F8, $1B, $FF, $1D, $FF, $16, $83, $F8, $1D
	.byte $01

; Bank 0
ft_s0p5c1:
	.byte $E1, $8A, $8F, $06, $FF, $2D, $00, $8D, $06, $00, $01, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F
	.byte $36, $00, $00, $8F, $00, $2E, $01, $82, $00, $8A, $00, $8F, $16, $00, $8F, $26, $00, $8F, $36, $00
	.byte $83, $8F, $36, $00, $07, $82, $01, $E0, $93, $01, $8F, $00, $F5, $29, $F6, $2A, $F7, $29, $F6, $2A
	.byte $F5, $29, $F4, $2A, $83, $F6, $29, $03, $F2, $29, $0B, $82, $01, $F3, $29, $F4, $2A, $F5, $29, $F6
	.byte $2A, $F7, $29, $F6, $2A, $F5, $29, $83, $F4, $2A, $01

; Bank 0
ft_s0p5c5:
	.byte $82, $00, $E0, $93, $01, $FA, $2E, $F4, $30, $F9, $29, $F4, $2E, $F9, $2E, $F4, $29, $93, $02, $FA
	.byte $35, $F4, $2E, $F9, $2E, $F4, $35, $F9, $31, $F4, $2E, $93, $03, $FA, $36, $F4, $31, $F9, $2E, $F4
	.byte $36, $F9, $31, $F4, $2E, $93, $02, $FA, $35, $F4, $31, $F9, $2A, $F4, $35, $F9, $2E, $F4, $2A, $93
	.byte $01, $FA, $31, $F4, $2E, $F9, $25, $F4, $31, $F9, $29, $F4, $25, $F9, $2E, $F4, $29, $93, $01, $FA
	.byte $31, $F4, $2E, $F9, $29, $F4, $31, $F9, $2E, $F4, $29, $93, $02, $FA, $35, $F4, $2E, $F9, $2E, $F4
	.byte $35, $F9, $31, $F4, $2E, $93, $03, $FA, $36, $F4, $31, $F9, $2E, $F4, $36, $F9, $31, $F4, $2E, $93
	.byte $02, $FA, $35, $F4, $31, $F9, $2A, $F4, $35, $F9, $2E, $F4, $2A, $93, $01, $FA, $31, $F4, $2E, $F9
	.byte $25, $F4, $31, $F9, $29, $F4, $25, $F9, $2E, $83, $F4, $29, $00

; Bank 0
ft_s0p6c0:
	.byte $E0, $93, $01, $92, $FF, $16, $03, $F8, $16, $01, $FF, $16, $03, $F8, $16, $35

; Bank 0
ft_s0p6c1:
	.byte $E0, $F6, $27, $03, $F4, $27, $0B, $82, $01, $F3, $27, $F4, $29, $F5, $27, $F6, $29, $F7, $27, $F6
	.byte $29, $F5, $27, $F4, $29, $83, $F6, $21, $03, $F4, $21, $0B, $82, $01, $F3, $29, $F4, $2A, $F5, $29
	.byte $F6, $2A, $F7, $29, $F6, $2A, $F5, $29, $83, $F4, $2A, $01

; Bank 0
ft_s0p6c5:
	.byte $00, $03, $E0, $93, $03, $F8, $18, $05, $15, $0D, $1B, $07, $1D, $03, $18, $05, $11, $0F, $82, $00
	.byte $93, $01, $F7, $29, $7F, $F8, $2D, $F2, $29, $F9, $30, $83, $F3, $2D, $00

; Bank 0
ft_s0p7c1:
	.byte $E0, $F6, $29, $03, $F4, $29, $3B

; Bank 0
ft_s0p7c5:
	.byte $91, $82, $00, $03, $E0, $93, $03, $F8, $19, $05, $16, $0D, $1B, $07, $1D, $03, $19, $05, $16, $0D
	.byte $1B, $05, $1D, $01

; Bank 0
ft_s0p8c1:
	.byte $E1, $8A, $93, $02, $8F, $06, $FF, $33, $00, $8D, $06, $00, $01, $8F, $16, $00, $00, $8F, $26, $00
	.byte $00, $8F, $36, $00, $00, $8F, $00, $30, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8F, $36, $00, $05, $8F, $26, $00, $00, $8F, $16, $00, $00, $8F, $06, $36, $03, $8F, $06, $35
	.byte $03, $8F, $06, $31, $03, $8F, $06, $33, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00
	.byte $00, $8D, $0C, $8F, $06, $2D, $02, $8F, $16, $00, $00, $8F, $26, $00, $00, $8F, $36, $00, $00, $8F
	.byte $46, $00, $07, $8F, $06, $36, $03, $8F, $06, $35, $03, $8F, $06, $2D, $02, $8A, $00, $00

; Bank 0
ft_s0p8c5:
	.byte $E0, $F8, $2E, $00, $F4, $35, $00, $7F, $00, $F4, $2E, $3B, $86, $02, $00, $00

; Bank 0
ft_s1_frames:
	.word ft_s1f0
ft_s1f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
; Bank 0
ft_s2_frames:
	.word ft_s2f0
	.word ft_s2f1
	.word ft_s2f2
	.word ft_s2f3
	.word ft_s2f4
	.word ft_s2f5
	.word ft_s2f6
	.word ft_s2f7
	.word ft_s2f8
	.word ft_s2f9
	.word ft_s2f10
ft_s2f0:
	.word ft_s2p0c0, ft_s2p0c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f1:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p1c2, ft_s0p0c0, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f2:
	.word ft_s2p0c0, ft_s2p1c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f3:
	.word ft_s2p1c0, ft_s2p2c1, ft_s2p1c2, ft_s0p0c0, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f4:
	.word ft_s2p0c0, ft_s2p1c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f5:
	.word ft_s2p1c0, ft_s2p2c1, ft_s2p1c2, ft_s0p0c0, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f6:
	.word ft_s2p0c0, ft_s2p1c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f7:
	.word ft_s2p1c0, ft_s2p2c1, ft_s2p1c2, ft_s0p0c0, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f8:
	.word ft_s2p0c0, ft_s2p1c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f9:
	.word ft_s2p1c0, ft_s2p2c1, ft_s2p1c2, ft_s0p0c0, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
ft_s2f10:
	.word ft_s2p0c0, ft_s2p3c1, ft_s2p0c2, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s2p0c1, ft_s0p0c0
; Bank 0
ft_s2p0c0:
	.byte $E5, $91, $88, $F4, $16, $03, $7F, $01, $16, $01, $7F, $03, $16, $01, $7F, $03, $16, $00, $7F, $00
	.byte $1B, $02, $7F, $00, $82, $01, $1C, $7F, $1D, $7F, $83, $16, $03, $7F, $01, $16, $01, $7F, $03, $16
	.byte $01, $7F, $03, $22, $00, $7F, $00, $82, $01, $16, $7F, $1B, $7F, $1D, $83, $7F, $01

; Bank 0
ft_s2p0c1:
	.byte $7F, $3F

; Bank 0
ft_s2p0c2:
	.byte $E2, $22, $03, $7F, $01, $22, $01, $7F, $03, $22, $01, $7F, $03, $22, $00, $7F, $00, $27, $02, $7F
	.byte $00, $82, $01, $28, $7F, $29, $7F, $83, $22, $03, $7F, $01, $22, $01, $7F, $03, $22, $01, $7F, $03
	.byte $2E, $00, $7F, $00, $82, $01, $22, $7F, $27, $7F, $29, $83, $7F, $01

; Bank 0
ft_s2p1c0:
	.byte $E5, $91, $88, $F4, $11, $03, $7F, $01, $11, $01, $7F, $03, $11, $01, $7F, $03, $11, $00, $7F, $00
	.byte $15, $02, $7F, $00, $82, $01, $16, $7F, $17, $7F, $18, $11, $7F, $83, $11, $03, $7F, $01, $11, $01
	.byte $7F, $03, $82, $01, $11, $1D, $7F, $11, $7F, $15, $83, $7F, $01

; Bank 0
ft_s2p1c1:
	.byte $E0, $93, $02, $8A, $8F, $00, $FB, $19, $03, $F6, $19, $01, $FB, $16, $03, $F6, $16, $09, $82, $03
	.byte $FB, $1B, $F6, $1B, $FB, $1D, $FB, $19, $83, $F6, $19, $01, $FB, $16, $03, $F6, $16, $09, $FB, $1B
	.byte $03, $82, $01, $F6, $1B, $FB, $1D, $F6, $16, $83, $F6, $1D, $01

; Bank 0
ft_s2p1c2:
	.byte $E2, $1D, $03, $7F, $01, $1D, $01, $7F, $03, $1D, $01, $7F, $03, $1D, $00, $7F, $00, $21, $02, $7F
	.byte $00, $82, $01, $22, $7F, $23, $7F, $24, $1D, $7F, $83, $1D, $03, $7F, $01, $1D, $01, $7F, $03, $82
	.byte $01, $1D, $29, $7F, $1D, $7F, $21, $83, $7F, $01

; Bank 0
ft_s2p2c1:
	.byte $E0, $93, $02, $8A, $8F, $00, $FB, $18, $03, $F6, $18, $01, $FB, $15, $03, $F6, $15, $09, $82, $03
	.byte $FB, $1B, $F6, $1B, $FB, $1D, $FB, $18, $83, $F6, $18, $01, $FB, $11, $03, $F6, $11, $09, $FB, $1D
	.byte $03, $82, $01, $F6, $1D, $FB, $1D, $FB, $11, $83, $F6, $1D, $01

; Bank 0
ft_s2p3c1:
	.byte $E0, $93, $02, $8A, $8F, $00, $FB, $16, $03, $F4, $16, $01, $FB, $16, $03, $F4, $16, $34, $86, $02
	.byte $00, $00


; DPCM samples (located at DPCM segment)
