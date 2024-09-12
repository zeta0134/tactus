; Dn-FamiTracker exported music data: click_track.dnm
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

; Instruments
ft_inst_0:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_0

ft_inst_1:
	.byte 0
	.byte $01
	.word ft_seq_2a03_0

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

; Sequences
ft_seq_2a03_0:
	.byte $10, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_34:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_56:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0E
ft_seq_2a03_61:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0C
ft_seq_2a03_65:
	.byte $0A, $FF, $00, $00, $0D, $0A, $07, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_70:
	.byte $15, $FF, $00, $00, $0A, $0A, $0A, $0A, $09, $08, $07, $06, $05, $05, $05, $05, $04, $04, $04, $03
	.byte $03, $02, $02, $01, $00
ft_seq_vrc6_0:
	.byte $18, $FF, $0E, $00, $0F, $0F, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $03
	.byte $03, $02, $02, $02, $01, $01, $01, $00

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
	.byte 1	; frame count
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c0, ft_s0p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c1:
	.byte $82, $07, $E1, $9B, $02, $93, $02, $85, $78, $49, $9B, $02, $85, $78, $3D, $9B, $02, $85, $78, $3D
	.byte $9B, $02, $85, $78, $3D, $E0, $9B, $02, $93, $02, $85, $78, $44, $E1, $9B, $02, $85, $78, $3D, $9B
	.byte $02, $85, $78, $3D, $83, $9B, $02, $85, $78, $3D, $07

; Bank 0
ft_s0p0c3:
	.byte $E3, $F7, $15, $03, $E2, $F5, $15, $01, $F3, $15, $01, $E3, $F5, $15, $03, $E2, $F5, $15, $01, $F3
	.byte $15, $01, $E3, $F5, $15, $03, $E2, $F5, $15, $01, $F3, $15, $01, $E3, $F5, $15, $03, $E2, $F5, $15
	.byte $01, $F3, $15, $01, $E3, $F7, $15, $03, $E2, $F5, $15, $01, $F3, $15, $01, $E3, $F5, $15, $03, $E2
	.byte $F5, $15, $01, $F3, $15, $01, $E3, $F5, $15, $03, $E2, $F5, $15, $01, $F3, $15, $01, $E3, $F5, $15
	.byte $03, $E2, $F5, $15, $01, $F3, $15, $01


; DPCM samples (located at DPCM segment)
