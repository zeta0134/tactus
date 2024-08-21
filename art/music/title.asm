; Dn-FamiTracker exported music data: title.dnm
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $00

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
	.byte $15
	.word ft_seq_2a03_115
	.word ft_seq_2a03_12
	.word ft_seq_2a03_54

ft_inst_5:
	.byte 0
	.byte $11
	.word ft_seq_2a03_115
	.word ft_seq_2a03_64

; Sequences
ft_seq_2a03_12:
	.byte $01, $FF, $00, $00, $FF
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_34:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_41:
	.byte $0C, $FF, $00, $01, $09, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_50:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_54:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_56:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0E
ft_seq_2a03_61:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0C
ft_seq_2a03_64:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_65:
	.byte $0A, $FF, $00, $00, $0D, $0A, $07, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_70:
	.byte $15, $FF, $00, $00, $0A, $0A, $0A, $0A, $09, $08, $07, $06, $05, $05, $05, $05, $04, $04, $04, $03
	.byte $03, $02, $02, $01, $00
ft_seq_2a03_115:
	.byte $08, $FF, $00, $00, $0A, $0B, $09, $07, $05, $02, $01, $00

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
	.byte 4	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 120	; tempo
	.byte 0	; groove position
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c2, ft_s0p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p1c2, ft_s0p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
ft_s0f2:
	.word ft_s0p1c0, ft_s0p0c0, ft_s0p0c2, ft_s0p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
ft_s0f3:
	.word ft_s0p2c0, ft_s0p0c0, ft_s0p1c2, ft_s0p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c2:
	.byte $E0, $1C, $00, $7F, $06, $28, $00, $7F, $02, $1C, $00, $7F, $00, $28, $00, $7F, $2A, $17, $00, $7F
	.byte $00, $1A, $00, $7F, $02

; Bank 0
ft_s0p0c3:
	.byte $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $E2, $F6, $11, $01, $F5
	.byte $11, $01, $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $E2, $F6, $11
	.byte $01, $F5, $11, $01, $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $82
	.byte $01, $E2, $F6, $11, $F5, $11, $E1, $F9, $11, $E3, $F7, $11, $83, $E2, $F8, $11, $03, $E3, $F8, $11
	.byte $03, $E2, $F6, $11, $01, $F5, $11, $01

; Bank 0
ft_s0p0c4:
	.byte $96, $40, $00, $3F

; Bank 0
ft_s0p1c0:
	.byte $00, $03, $E4, $F6, $34, $03, $40, $01, $34, $05, $28, $03, $34, $01, $28, $0D, $1C, $03, $28, $01
	.byte $1C, $05, $10, $03, $1C, $01, $10, $09

; Bank 0
ft_s0p1c2:
	.byte $E0, $1C, $00, $7F, $02, $1C, $00, $7F, $02, $28, $00, $7F, $02, $1C, $00, $7F, $00, $28, $00, $7F
	.byte $30

; Bank 0
ft_s0p1c3:
	.byte $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $E2, $F6, $11, $01, $F5
	.byte $11, $01, $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $E2, $F6, $11
	.byte $01, $F5, $11, $01, $E1, $F9, $11, $03, $E2, $F6, $11, $01, $F5, $11, $01, $E3, $F8, $11, $03, $E2
	.byte $F6, $11, $01, $F5, $11, $01, $E1, $F9, $11, $03, $F8, $11, $03, $E3, $F8, $11, $03, $E2, $F6, $11
	.byte $01, $F5, $11, $01

; Bank 0
ft_s0p2c0:
	.byte $00, $03, $E5, $F6, $28, $03, $34, $01, $28, $19, $F7, $10, $03, $1C, $01, $10, $03, $10, $11


; DPCM samples (located at DPCM segment)
