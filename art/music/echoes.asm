; Dn-FamiTracker exported music data: echoes.dnm
;

; Module header
	.word ft_song_list
	.word ft_instrument_list
	.word ft_sample_list
	.word ft_samples
	.word ft_groove_list
	.byte 1 ; flags
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
	.word ft_inst_12
	.word ft_inst_13
	.word ft_inst_14
	.word ft_inst_15
	.word ft_inst_16
	.word ft_inst_17
	.word ft_inst_18
	.word ft_inst_19
	.word ft_inst_20
	.word ft_inst_21
	.word ft_inst_22
	.word ft_inst_23
	.word ft_inst_24
	.word ft_inst_25
	.word ft_inst_26

; Instruments
ft_inst_0:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

ft_inst_1:
	.byte 0
	.byte $11
	.word ft_seq_2a03_5
	.word ft_seq_2a03_9

ft_inst_2:
	.byte 0
	.byte $03
	.word ft_seq_2a03_10
	.word ft_seq_2a03_1

ft_inst_3:
	.byte 0
	.byte $15
	.word ft_seq_2a03_15
	.word ft_seq_2a03_2
	.word ft_seq_2a03_14

ft_inst_4:
	.byte 0
	.byte $15
	.word ft_seq_2a03_20
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_5:
	.byte 0
	.byte $01
	.word ft_seq_2a03_25

ft_inst_6:
	.byte 0
	.byte $01
	.word ft_seq_2a03_30

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_0
	.word ft_seq_2a03_11
	.word ft_seq_2a03_24

ft_inst_8:
	.byte 0
	.byte $13
	.word ft_seq_2a03_0
	.word ft_seq_2a03_16
	.word ft_seq_2a03_24

ft_inst_9:
	.byte 0
	.byte $13
	.word ft_seq_2a03_50
	.word ft_seq_2a03_31
	.word ft_seq_2a03_34

ft_inst_10:
	.byte 0
	.byte $13
	.word ft_seq_2a03_0
	.word ft_seq_2a03_21
	.word ft_seq_2a03_24

ft_inst_11:
	.byte 0
	.byte $11
	.word ft_seq_2a03_40
	.word ft_seq_2a03_29

ft_inst_12:
	.byte 0
	.byte $03
	.word ft_seq_2a03_45
	.word ft_seq_2a03_26

ft_inst_13:
	.byte 0
	.byte $03
	.word ft_seq_2a03_10
	.word ft_seq_2a03_36

ft_inst_14:
	.byte 0
	.byte $01
	.word ft_seq_2a03_55

ft_inst_15:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_0
	.word ft_seq_vrc6_4

ft_inst_16:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_5
	.word ft_seq_vrc6_4

ft_inst_17:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_10

ft_inst_18:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_15

ft_inst_19:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_20
	.word ft_seq_vrc6_9

ft_inst_20:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_25
	.word ft_seq_vrc6_9

ft_inst_21:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_30

ft_inst_22:
	.byte 0
	.byte $01
	.word ft_seq_2a03_60

ft_inst_23:
	.byte 0
	.byte $11
	.word ft_seq_2a03_65
	.word ft_seq_2a03_39

ft_inst_24:
	.byte 0
	.byte $11
	.word ft_seq_2a03_70
	.word ft_seq_2a03_39

ft_inst_25:
	.byte 0
	.byte $01
	.word ft_seq_2a03_75

ft_inst_26:
	.byte 0
	.byte $11
	.word ft_seq_2a03_80
	.word ft_seq_2a03_44

; Sequences
ft_seq_2a03_0:
	.byte $10, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
ft_seq_2a03_1:
	.byte $04, $FF, $00, $01, $26, $1D, $18, $15
ft_seq_2a03_2:
	.byte $01, $00, $00, $00, $FB
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_5:
	.byte $0C, $FF, $00, $00, $0F, $0F, $0F, $0E, $0E, $0D, $0C, $0B, $0A, $09, $08, $07
ft_seq_2a03_7:
	.byte $14, $08, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $FF, $FF
	.byte $FF, $FF, $00, $00
ft_seq_2a03_9:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_10:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_11:
	.byte $01, $FF, $00, $01, $08
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_15:
	.byte $01, $FF, $00, $00, $08
ft_seq_2a03_16:
	.byte $01, $FF, $00, $01, $0A
ft_seq_2a03_19:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_20:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_21:
	.byte $01, $FF, $00, $01, $0B
ft_seq_2a03_24:
	.byte $02, $FF, $00, $00, $00, $01
ft_seq_2a03_25:
	.byte $23, $FF, $1A, $00, $09, $0C, $0E, $0F, $0F, $0F, $0F, $0F, $0F, $0E, $0E, $0D, $0D, $0D, $0C, $0C
	.byte $0B, $0B, $0B, $0A, $09, $09, $08, $08, $07, $07, $02, $02, $02, $02, $01, $01, $01, $01, $00
ft_seq_2a03_26:
	.byte $02, $01, $00, $02, $01, $FD
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_30:
	.byte $20, $FF, $17, $00, $0F, $0F, $0F, $0F, $0F, $0F, $0E, $0E, $0D, $0D, $0D, $0C, $0C, $0B, $0B, $0B
	.byte $0A, $09, $09, $08, $08, $07, $07, $02, $02, $02, $02, $01, $01, $01, $01, $00
ft_seq_2a03_31:
	.byte $0C, $09, $00, $00, $08, $0B, $09, $0B, $0A, $0B, $0A, $0B, $0C, $0B, $0C, $0B
ft_seq_2a03_34:
	.byte $02, $FF, $00, $00, $01, $00
ft_seq_2a03_36:
	.byte $04, $FF, $00, $01, $2B, $22, $1D, $1A
ft_seq_2a03_39:
	.byte $04, $FF, $00, $00, $02, $02, $02, $02
ft_seq_2a03_40:
	.byte $0C, $FF, $00, $00, $0F, $0E, $0A, $05, $03, $02, $02, $02, $01, $01, $01, $00
ft_seq_2a03_44:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_45:
	.byte $07, $FF, $00, $00, $0F, $0F, $0F, $0F, $00, $00, $00
ft_seq_2a03_50:
	.byte $18, $FF, $00, $00, $0D, $0C, $0B, $0B, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $03, $03, $02
	.byte $02, $02, $02, $01, $01, $01, $01, $00
ft_seq_2a03_55:
	.byte $23, $FF, $00, $00, $09, $0C, $0E, $0F, $0D, $07, $04, $01, $01, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_60:
	.byte $02, $FF, $01, $00, $0F, $00
ft_seq_2a03_65:
	.byte $07, $FF, $00, $00, $08, $06, $04, $03, $02, $00, $00
ft_seq_2a03_70:
	.byte $15, $FF, $00, $00, $04, $07, $09, $0A, $09, $08, $06, $05, $04, $04, $03, $02, $02, $01, $01, $01
	.byte $01, $01, $00, $00, $00
ft_seq_2a03_75:
	.byte $02, $FF, $00, $00, $0F, $00
ft_seq_2a03_80:
	.byte $0C, $FF, $00, $00, $0B, $0C, $0D, $0E, $0E, $0D, $0C, $0B, $0A, $09, $08, $07
ft_seq_vrc6_0:
	.byte $08, $FF, $00, $00, $0F, $0D, $07, $04, $02, $01, $00, $00
ft_seq_vrc6_4:
	.byte $0E, $00, $00, $00, $00, $01, $02, $03, $04, $05, $06, $07, $06, $05, $04, $03, $02, $01
ft_seq_vrc6_5:
	.byte $15, $FF, $00, $00, $0F, $0D, $0B, $0A, $0A, $07, $06, $05, $04, $04, $03, $02, $02, $01, $01, $01
	.byte $01, $01, $00, $00, $00
ft_seq_vrc6_9:
	.byte $0E, $00, $00, $00, $06, $07, $06, $05, $04, $03, $02, $01, $00, $01, $02, $03, $04, $05
ft_seq_vrc6_10:
	.byte $16, $FF, $0E, $00, $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0A, $09, $08, $07, $05, $03, $01
	.byte $01, $01, $01, $01, $01, $00
ft_seq_vrc6_15:
	.byte $01, $FF, $00, $00, $0F
ft_seq_vrc6_20:
	.byte $09, $FF, $00, $00, $0F, $0D, $08, $05, $02, $02, $02, $02, $01
ft_seq_vrc6_25:
	.byte $15, $FF, $00, $00, $0F, $0D, $0B, $0A, $0A, $07, $06, $05, $05, $04, $04, $03, $03, $02, $02, $02
	.byte $01, $01, $01, $01, $00
ft_seq_vrc6_30:
	.byte $23, $FF, $0E, $00, $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0A, $09, $08, $07, $07, $06, $06
	.byte $06, $06, $06, $06, $06, $06, $05, $05, $04, $03, $03, $02, $02, $02, $02, $01, $01, $01, $00

; DPCM instrument list (pitch, sample index)
ft_sample_list:

; DPCM samples list (location, size, bank)
ft_samples:

; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)

; Song pointer list
ft_song_list:
	.word ft_song_0
	.word ft_song_1
	.word ft_song_2

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 19	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank

ft_song_1:
	.word ft_s1_frames
	.byte 19	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank

ft_song_2:
	.word ft_s2_frames
	.byte 19	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
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
	.word ft_s0f4
	.word ft_s0f5
	.word ft_s0f6
	.word ft_s0f7
	.word ft_s0f8
	.word ft_s0f9
	.word ft_s0f10
	.word ft_s0f11
	.word ft_s0f12
	.word ft_s0f13
	.word ft_s0f14
	.word ft_s0f15
	.word ft_s0f16
	.word ft_s0f17
	.word ft_s0f18
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c2, ft_s0p0c3, ft_s0p0c2, ft_s0p0c2, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s0p0c2), <.bank(ft_s0p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f2:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p1c0), <.bank(ft_s0p1c1), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f3:
	.word ft_s0p2c0, ft_s0p2c1, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p2c0), <.bank(ft_s0p2c1), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f4:
	.word ft_s0p3c0, ft_s0p3c1, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p3c0), <.bank(ft_s0p3c1), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f5:
	.word ft_s0p4c0, ft_s0p4c1, ft_s0p2c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p4c0), <.bank(ft_s0p4c1), <.bank(ft_s0p2c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s0f6:
	.word ft_s0p5c0, ft_s0p5c1, ft_s0p3c2, ft_s0p2c3, ft_s0p1c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p5c0), <.bank(ft_s0p5c1), <.bank(ft_s0p3c2), <.bank(ft_s0p2c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p1c7), <.bank(ft_s0p0c4)
ft_s0f7:
	.word ft_s0p6c0, ft_s0p6c1, ft_s0p3c2, ft_s0p2c3, ft_s0p1c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p6c0), <.bank(ft_s0p6c1), <.bank(ft_s0p3c2), <.bank(ft_s0p2c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p1c7), <.bank(ft_s0p0c4)
ft_s0f8:
	.word ft_s0p7c0, ft_s0p7c1, ft_s0p4c2, ft_s0p3c3, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p7c0), <.bank(ft_s0p7c1), <.bank(ft_s0p4c2), <.bank(ft_s0p3c3), <.bank(ft_s0p2c5), <.bank(ft_s0p2c6), <.bank(ft_s0p2c7), <.bank(ft_s0p0c4)
ft_s0f9:
	.word ft_s0p8c0, ft_s0p8c1, ft_s0p4c2, ft_s0p3c3, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p8c0), <.bank(ft_s0p8c1), <.bank(ft_s0p4c2), <.bank(ft_s0p3c3), <.bank(ft_s0p2c5), <.bank(ft_s0p2c6), <.bank(ft_s0p2c7), <.bank(ft_s0p0c4)
ft_s0f10:
	.word ft_s0p9c0, ft_s0p9c1, ft_s0p3c2, ft_s0p2c3, ft_s0p3c5, ft_s0p3c6, ft_s0p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p9c0), <.bank(ft_s0p9c1), <.bank(ft_s0p3c2), <.bank(ft_s0p2c3), <.bank(ft_s0p3c5), <.bank(ft_s0p3c6), <.bank(ft_s0p1c7), <.bank(ft_s0p0c4)
ft_s0f11:
	.word ft_s0p10c0, ft_s0p10c1, ft_s0p4c2, ft_s0p3c3, ft_s0p4c5, ft_s0p4c6, ft_s0p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p10c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s0p3c3), <.bank(ft_s0p4c5), <.bank(ft_s0p4c6), <.bank(ft_s0p2c7), <.bank(ft_s0p0c4)
ft_s0f12:
	.word ft_s0p11c0, ft_s0p11c1, ft_s0p5c2, ft_s0p4c3, ft_s0p5c5, ft_s0p3c6, ft_s0p3c7, ft_s0p0c4
	.byte <.bank(ft_s0p11c0), <.bank(ft_s0p11c1), <.bank(ft_s0p5c2), <.bank(ft_s0p4c3), <.bank(ft_s0p5c5), <.bank(ft_s0p3c6), <.bank(ft_s0p3c7), <.bank(ft_s0p0c4)
ft_s0f13:
	.word ft_s0p12c0, ft_s0p12c1, ft_s0p4c2, ft_s0p5c3, ft_s0p6c5, ft_s0p6c6, ft_s0p4c7, ft_s0p0c4
	.byte <.bank(ft_s0p12c0), <.bank(ft_s0p12c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p6c5), <.bank(ft_s0p6c6), <.bank(ft_s0p4c7), <.bank(ft_s0p0c4)
ft_s0f14:
	.word ft_s0p13c0, ft_s0p9c1, ft_s0p3c2, ft_s0p2c3, ft_s0p3c5, ft_s0p7c6, ft_s0p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p13c0), <.bank(ft_s0p9c1), <.bank(ft_s0p3c2), <.bank(ft_s0p2c3), <.bank(ft_s0p3c5), <.bank(ft_s0p7c6), <.bank(ft_s0p1c7), <.bank(ft_s0p0c4)
ft_s0f15:
	.word ft_s0p14c0, ft_s0p10c1, ft_s0p4c2, ft_s0p3c3, ft_s0p4c5, ft_s0p8c6, ft_s0p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p14c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s0p3c3), <.bank(ft_s0p4c5), <.bank(ft_s0p8c6), <.bank(ft_s0p2c7), <.bank(ft_s0p0c4)
ft_s0f16:
	.word ft_s0p15c0, ft_s0p11c1, ft_s0p5c2, ft_s0p4c3, ft_s0p5c5, ft_s0p9c6, ft_s0p3c7, ft_s0p0c4
	.byte <.bank(ft_s0p15c0), <.bank(ft_s0p11c1), <.bank(ft_s0p5c2), <.bank(ft_s0p4c3), <.bank(ft_s0p5c5), <.bank(ft_s0p9c6), <.bank(ft_s0p3c7), <.bank(ft_s0p0c4)
ft_s0f17:
	.word ft_s0p16c0, ft_s0p16c1, ft_s0p4c2, ft_s0p5c3, ft_s0p10c5, ft_s0p10c6, ft_s0p4c7, ft_s0p0c4
	.byte <.bank(ft_s0p16c0), <.bank(ft_s0p16c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p10c5), <.bank(ft_s0p10c6), <.bank(ft_s0p4c7), <.bank(ft_s0p0c4)
ft_s0f18:
	.word ft_s0p17c0, ft_s0p17c1, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p17c0), <.bank(ft_s0p17c1), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)

; Bank 0
ft_s1_frames:
	.word ft_s1f0
	.word ft_s1f1
	.word ft_s1f2
	.word ft_s1f3
	.word ft_s1f4
	.word ft_s1f5
	.word ft_s1f6
	.word ft_s1f7
	.word ft_s1f8
	.word ft_s1f9
	.word ft_s1f10
	.word ft_s1f11
	.word ft_s1f12
	.word ft_s1f13
	.word ft_s1f14
	.word ft_s1f15
	.word ft_s1f16
	.word ft_s1f17
	.word ft_s1f18
ft_s1f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c2, ft_s1p0c3, ft_s0p0c2, ft_s0p0c2, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s0p0c2), <.bank(ft_s1p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p1c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s0p1c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f2:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p1c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p1c0), <.bank(ft_s0p1c1), <.bank(ft_s0p1c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f3:
	.word ft_s0p2c0, ft_s0p2c1, ft_s0p1c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p2c0), <.bank(ft_s0p2c1), <.bank(ft_s0p1c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f4:
	.word ft_s0p3c0, ft_s0p3c1, ft_s0p1c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p3c0), <.bank(ft_s0p3c1), <.bank(ft_s0p1c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f5:
	.word ft_s0p4c0, ft_s0p4c1, ft_s0p2c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p4c0), <.bank(ft_s0p4c1), <.bank(ft_s0p2c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)
ft_s1f6:
	.word ft_s1p5c0, ft_s0p5c1, ft_s0p3c2, ft_s1p2c3, ft_s0p1c5, ft_s0p1c6, ft_s1p1c7, ft_s0p0c4
	.byte <.bank(ft_s1p5c0), <.bank(ft_s0p5c1), <.bank(ft_s0p3c2), <.bank(ft_s1p2c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s1p1c7), <.bank(ft_s0p0c4)
ft_s1f7:
	.word ft_s1p6c0, ft_s0p6c1, ft_s0p3c2, ft_s1p2c3, ft_s0p1c5, ft_s0p1c6, ft_s1p1c7, ft_s0p0c4
	.byte <.bank(ft_s1p6c0), <.bank(ft_s0p6c1), <.bank(ft_s0p3c2), <.bank(ft_s1p2c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s1p1c7), <.bank(ft_s0p0c4)
ft_s1f8:
	.word ft_s1p7c0, ft_s0p7c1, ft_s0p4c2, ft_s1p3c3, ft_s0p2c5, ft_s0p2c6, ft_s1p2c7, ft_s0p0c4
	.byte <.bank(ft_s1p7c0), <.bank(ft_s0p7c1), <.bank(ft_s0p4c2), <.bank(ft_s1p3c3), <.bank(ft_s0p2c5), <.bank(ft_s0p2c6), <.bank(ft_s1p2c7), <.bank(ft_s0p0c4)
ft_s1f9:
	.word ft_s1p8c0, ft_s0p8c1, ft_s0p4c2, ft_s1p3c3, ft_s0p2c5, ft_s0p2c6, ft_s1p2c7, ft_s0p0c4
	.byte <.bank(ft_s1p8c0), <.bank(ft_s0p8c1), <.bank(ft_s0p4c2), <.bank(ft_s1p3c3), <.bank(ft_s0p2c5), <.bank(ft_s0p2c6), <.bank(ft_s1p2c7), <.bank(ft_s0p0c4)
ft_s1f10:
	.word ft_s1p9c0, ft_s0p9c1, ft_s0p3c2, ft_s1p2c3, ft_s1p3c5, ft_s1p3c6, ft_s1p1c7, ft_s0p0c4
	.byte <.bank(ft_s1p9c0), <.bank(ft_s0p9c1), <.bank(ft_s0p3c2), <.bank(ft_s1p2c3), <.bank(ft_s1p3c5), <.bank(ft_s1p3c6), <.bank(ft_s1p1c7), <.bank(ft_s0p0c4)
ft_s1f11:
	.word ft_s1p10c0, ft_s0p10c1, ft_s0p4c2, ft_s1p3c3, ft_s1p4c5, ft_s1p4c6, ft_s1p2c7, ft_s0p0c4
	.byte <.bank(ft_s1p10c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s1p3c3), <.bank(ft_s1p4c5), <.bank(ft_s1p4c6), <.bank(ft_s1p2c7), <.bank(ft_s0p0c4)
ft_s1f12:
	.word ft_s1p11c0, ft_s1p11c1, ft_s0p5c2, ft_s1p4c3, ft_s1p5c5, ft_s1p3c6, ft_s1p3c7, ft_s0p0c4
	.byte <.bank(ft_s1p11c0), <.bank(ft_s1p11c1), <.bank(ft_s0p5c2), <.bank(ft_s1p4c3), <.bank(ft_s1p5c5), <.bank(ft_s1p3c6), <.bank(ft_s1p3c7), <.bank(ft_s0p0c4)
ft_s1f13:
	.word ft_s1p12c0, ft_s1p12c1, ft_s0p4c2, ft_s1p5c3, ft_s1p6c5, ft_s1p6c6, ft_s1p4c7, ft_s0p0c4
	.byte <.bank(ft_s1p12c0), <.bank(ft_s1p12c1), <.bank(ft_s0p4c2), <.bank(ft_s1p5c3), <.bank(ft_s1p6c5), <.bank(ft_s1p6c6), <.bank(ft_s1p4c7), <.bank(ft_s0p0c4)
ft_s1f14:
	.word ft_s1p13c0, ft_s0p9c1, ft_s0p3c2, ft_s1p2c3, ft_s1p3c5, ft_s1p7c6, ft_s1p1c7, ft_s0p0c4
	.byte <.bank(ft_s1p13c0), <.bank(ft_s0p9c1), <.bank(ft_s0p3c2), <.bank(ft_s1p2c3), <.bank(ft_s1p3c5), <.bank(ft_s1p7c6), <.bank(ft_s1p1c7), <.bank(ft_s0p0c4)
ft_s1f15:
	.word ft_s1p14c0, ft_s0p10c1, ft_s0p4c2, ft_s1p3c3, ft_s1p4c5, ft_s1p8c6, ft_s1p2c7, ft_s0p0c4
	.byte <.bank(ft_s1p14c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s1p3c3), <.bank(ft_s1p4c5), <.bank(ft_s1p8c6), <.bank(ft_s1p2c7), <.bank(ft_s0p0c4)
ft_s1f16:
	.word ft_s1p15c0, ft_s1p11c1, ft_s0p5c2, ft_s1p4c3, ft_s1p5c5, ft_s1p9c6, ft_s1p3c7, ft_s0p0c4
	.byte <.bank(ft_s1p15c0), <.bank(ft_s1p11c1), <.bank(ft_s0p5c2), <.bank(ft_s1p4c3), <.bank(ft_s1p5c5), <.bank(ft_s1p9c6), <.bank(ft_s1p3c7), <.bank(ft_s0p0c4)
ft_s1f17:
	.word ft_s1p16c0, ft_s1p16c1, ft_s0p4c2, ft_s1p5c3, ft_s1p10c5, ft_s1p6c6, ft_s1p4c7, ft_s0p0c4
	.byte <.bank(ft_s1p16c0), <.bank(ft_s1p16c1), <.bank(ft_s0p4c2), <.bank(ft_s1p5c3), <.bank(ft_s1p10c5), <.bank(ft_s1p6c6), <.bank(ft_s1p4c7), <.bank(ft_s0p0c4)
ft_s1f18:
	.word ft_s0p17c0, ft_s0p17c1, ft_s0p1c2, ft_s1p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p0c2, ft_s0p0c4
	.byte <.bank(ft_s0p17c0), <.bank(ft_s0p17c1), <.bank(ft_s0p1c2), <.bank(ft_s1p1c3), <.bank(ft_s0p1c5), <.bank(ft_s0p1c6), <.bank(ft_s0p0c2), <.bank(ft_s0p0c4)

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
	.word ft_s2f11
	.word ft_s2f12
	.word ft_s2f13
	.word ft_s2f14
	.word ft_s2f15
	.word ft_s2f16
	.word ft_s2f17
	.word ft_s2f18
ft_s2f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p5c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p5c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f2:
	.word ft_s2p5c0, ft_s2p5c1, ft_s2p5c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s2p5c0), <.bank(ft_s2p5c1), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f3:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p5c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f4:
	.word ft_s2p6c0, ft_s2p6c1, ft_s2p5c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s2p6c0), <.bank(ft_s2p6c1), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f5:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p5c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p5c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)
ft_s2f6:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p1c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p1c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p1c7), <.bank(ft_s0p0c4)
ft_s2f7:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p1c2, ft_s2p0c3, ft_s2p1c5, ft_s2p1c6, ft_s2p1c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p1c2), <.bank(ft_s2p0c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p1c7), <.bank(ft_s0p0c4)
ft_s2f8:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p2c2, ft_s2p0c3, ft_s2p2c5, ft_s2p2c6, ft_s2p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p2c2), <.bank(ft_s2p0c3), <.bank(ft_s2p2c5), <.bank(ft_s2p2c6), <.bank(ft_s2p2c7), <.bank(ft_s0p0c4)
ft_s2f9:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p2c2, ft_s2p0c3, ft_s2p2c5, ft_s2p2c6, ft_s2p2c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p2c2), <.bank(ft_s2p0c3), <.bank(ft_s2p2c5), <.bank(ft_s2p2c6), <.bank(ft_s2p2c7), <.bank(ft_s0p0c4)
ft_s2f10:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p1c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p1c7, ft_s0p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p1c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p1c7), <.bank(ft_s0p0c4)
ft_s2f11:
	.word ft_s2p2c0, ft_s2p2c1, ft_s2p2c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p2c7, ft_s0p0c4
	.byte <.bank(ft_s2p2c0), <.bank(ft_s2p2c1), <.bank(ft_s2p2c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p2c7), <.bank(ft_s0p0c4)
ft_s2f12:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p3c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p3c7, ft_s0p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p3c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p3c7), <.bank(ft_s0p0c4)
ft_s2f13:
	.word ft_s2p4c0, ft_s2p4c1, ft_s2p4c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p4c7, ft_s0p0c4
	.byte <.bank(ft_s2p4c0), <.bank(ft_s2p4c1), <.bank(ft_s2p4c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p4c7), <.bank(ft_s0p0c4)
ft_s2f14:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p1c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p1c7, ft_s0p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p1c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p1c7), <.bank(ft_s0p0c4)
ft_s2f15:
	.word ft_s2p2c0, ft_s2p2c1, ft_s2p2c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p2c7, ft_s0p0c4
	.byte <.bank(ft_s2p2c0), <.bank(ft_s2p2c1), <.bank(ft_s2p2c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p2c7), <.bank(ft_s0p0c4)
ft_s2f16:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p3c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p3c7, ft_s0p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p3c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p3c7), <.bank(ft_s0p0c4)
ft_s2f17:
	.word ft_s2p4c0, ft_s2p4c1, ft_s2p4c2, ft_s2p0c3, ft_s0p0c2, ft_s0p0c2, ft_s2p4c7, ft_s0p0c4
	.byte <.bank(ft_s2p4c0), <.bank(ft_s2p4c1), <.bank(ft_s2p4c2), <.bank(ft_s2p0c3), <.bank(ft_s0p0c2), <.bank(ft_s0p0c2), <.bank(ft_s2p4c7), <.bank(ft_s0p0c4)
ft_s2f18:
	.word ft_s0p0c0, ft_s0p0c0, ft_s2p5c2, ft_s2p1c3, ft_s2p1c5, ft_s2p1c6, ft_s2p0c7, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c0), <.bank(ft_s2p5c2), <.bank(ft_s2p1c3), <.bank(ft_s2p1c5), <.bank(ft_s2p1c6), <.bank(ft_s2p0c7), <.bank(ft_s0p0c4)

; Bank 0
ft_s0p0c0:
	.byte $8F, $00, $7F, $3F

; Bank 0
ft_s0p0c2:
	.byte $7F, $3F

; Bank 0
ft_s0p0c3:
	.byte $82, $01, $E0, $85, $96, $F7, $16, $F1, $15, $F4, $17, $F1, $16, $F4, $1A, $F1, $17, $F7, $16, $F1
	.byte $1A, $F5, $17, $F2, $16, $F5, $1A, $F2, $17, $F3, $1B, $F2, $1A, $F8, $15, $F2, $1B, $F9, $16, $F3
	.byte $15, $F6, $17, $F3, $16, $F6, $1A, $F3, $17, $F9, $16, $F3, $1A, $F7, $17, $F4, $16, $F7, $1A, $F4
	.byte $17, $F5, $1B, $F4, $1A, $FA, $15, $83, $F4, $1B, $01

; Bank 0
ft_s0p0c4:
	.byte $00, $3F

; Bank 0
ft_s0p1c0:
	.byte $82, $03, $E1, $91, $68, $FF, $15, $F9, $15, $F4, $15, $FF, $15, $F9, $15, $F4, $15, $83, $7F, $07
	.byte $82, $03, $FF, $15, $F9, $15, $F4, $15, $FF, $15, $F9, $15, $F4, $15, $83, $7F, $07

; Bank 0
ft_s0p1c1:
	.byte $82, $03, $E1, $91, $68, $FC, $18, $F8, $18, $F4, $18, $FC, $18, $F8, $18, $F4, $18, $83, $7F, $07
	.byte $82, $03, $FC, $18, $F8, $18, $F4, $18, $FC, $18, $F8, $18, $F4, $18, $83, $7F, $07

; Bank 0
ft_s0p1c2:
	.byte $82, $07, $E2, $91, $60, $15, $15, $15, $15, $15, $15, $15, $83, $15, $07

; Bank 0
ft_s0p1c3:
	.byte $82, $01, $E7, $85, $96, $FA, $16, $E0, $F4, $15, $F7, $17, $F4, $16, $E7, $F7, $1A, $E0, $F4, $17
	.byte $FA, $16, $F4, $1A, $E7, $F7, $17, $E0, $F4, $16, $F7, $1A, $F4, $17, $E7, $F5, $1B, $E0, $F4, $1A
	.byte $FA, $15, $F4, $1B, $E7, $FA, $16, $E0, $F4, $15, $F7, $17, $F4, $16, $E7, $F7, $1A, $E0, $F4, $17
	.byte $FA, $16, $F4, $1A, $E7, $F7, $17, $E0, $F4, $16, $F7, $1A, $F4, $17, $E7, $F5, $1B, $E0, $F4, $1A
	.byte $FA, $15, $83, $F4, $1B, $01

; Bank 0
ft_s0p1c5:
	.byte $80, $24, $93, $02, $91, $60, $F4, $09, $3F

; Bank 0
ft_s0p1c6:
	.byte $80, $24, $93, $02, $91, $64, $F4, $09, $3F

; Bank 0
ft_s0p1c7:
	.byte $82, $01, $80, $22, $91, $6C, $FC, $09, $7E, $15, $9E, $03, $09, $09, $7E, $15, $7E, $09, $7E, $15
	.byte $9E, $03, $09, $09, $7E, $15, $7E, $09, $7E, $15, $9E, $03, $09, $09, $7E, $15, $7E, $09, $7E, $15
	.byte $9E, $03, $09, $09, $7E, $15, $83, $7E, $01

; Bank 0
ft_s0p2c0:
	.byte $00, $07, $82, $01, $E3, $91, $6C, $F2, $1E, $F3, $00, $F4, $00, $F5, $00, $F6, $00, $F7, $00, $F8
	.byte $00, $F9, $00, $FA, $00, $FB, $00, $FC, $00, $83, $FD, $00, $0D, $82, $03, $F7, $38, $F6, $38, $F5
	.byte $38, $F4, $38, $83, $F3, $38, $03

; Bank 0
ft_s0p2c1:
	.byte $82, $01, $E3, $91, $68, $F3, $1E, $F4, $00, $F5, $00, $F6, $00, $F7, $00, $F8, $00, $F9, $00, $FA
	.byte $00, $FB, $00, $FC, $00, $FD, $00, $83, $FE, $00, $0D, $82, $03, $FE, $38, $FC, $38, $FA, $38, $F8
	.byte $38, $F6, $38, $F4, $38, $83, $F2, $38, $03

; Bank 0
ft_s0p2c2:
	.byte $82, $07, $E2, $91, $60, $15, $15, $15, $15, $15, $15, $83, $15, $03, $82, $01, $EC, $3C, $3C, $37
	.byte $37, $30, $83, $30, $01

; Bank 0
ft_s0p2c3:
	.byte $82, $01, $E7, $85, $96, $FA, $16, $E8, $F4, $15, $EA, $F7, $17, $E0, $F4, $16, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $16, $E0, $F4, $1A, $E7, $F7, $17, $E8, $F4, $16, $EA, $F7, $1A, $E0, $F4
	.byte $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $15, $F4, $1B, $E7, $FA, $16, $E8, $F4, $15, $EA
	.byte $F7, $17, $E0, $F4, $16, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $16, $E0, $F4, $1A, $E7, $F7
	.byte $17, $E8, $F4, $16, $EA, $F7, $1A, $F4, $17, $83, $E9, $FB, $1F, $03, $EA, $FA, $15, $01, $F4, $1B
	.byte $01

; Bank 0
ft_s0p2c5:
	.byte $80, $24, $93, $02, $91, $68, $F4, $10, $3F

; Bank 0
ft_s0p2c6:
	.byte $80, $24, $93, $02, $91, $6C, $F4, $10, $3F

; Bank 0
ft_s0p2c7:
	.byte $82, $01, $80, $22, $91, $6C, $FC, $10, $7E, $1C, $9E, $03, $10, $10, $7E, $1C, $7E, $10, $7E, $1C
	.byte $9E, $03, $10, $10, $7E, $1C, $7E, $10, $7E, $1C, $9E, $03, $10, $10, $7E, $1C, $7E, $10, $7E, $1C
	.byte $9E, $03, $10, $10, $7E, $1C, $83, $7E, $01

; Bank 0
ft_s0p3c0:
	.byte $82, $03, $E1, $91, $68, $FF, $15, $F9, $15, $F4, $15, $FF, $15, $F9, $15, $F4, $15, $83, $7F, $07
	.byte $82, $03, $91, $6C, $FF, $15, $F9, $15, $F4, $15, $FF, $15, $F9, $15, $F4, $15, $83, $7F, $07

; Bank 0
ft_s0p3c1:
	.byte $82, $03, $E1, $91, $68, $FC, $1C, $F8, $1C, $F4, $1C, $FC, $1C, $F8, $1C, $F4, $1C, $83, $7F, $07
	.byte $82, $03, $FC, $15, $F8, $15, $F4, $15, $FC, $15, $F8, $15, $F4, $15, $83, $7F, $07

; Bank 0
ft_s0p3c2:
	.byte $82, $07, $E2, $91, $60, $15, $ED, $15, $E2, $15, $ED, $15, $E2, $15, $ED, $15, $E2, $15, $83, $ED
	.byte $15, $07

; Bank 0
ft_s0p3c3:
	.byte $82, $01, $E7, $85, $96, $FA, $17, $E8, $F4, $1C, $EA, $F7, $18, $E0, $F4, $17, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $17, $E0, $F4, $1A, $E7, $F7, $18, $E8, $F4, $17, $EA, $F7, $1A, $E0, $F4
	.byte $18, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $F5, $1C, $F4, $17, $E7, $FA, $17, $E8, $F4, $1C, $EA
	.byte $F7, $18, $E0, $F4, $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $17, $E0, $F4, $1A, $E7, $F7
	.byte $18, $E8, $F4, $17, $EA, $F7, $1A, $F4, $18, $83, $E9, $FB, $1F, $03, $EA, $F5, $1C, $01, $F4, $17
	.byte $01

; Bank 0
ft_s0p3c5:
	.byte $EF, $91, $7E, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F8, $28, $01, $F7, $28
	.byte $01, $80, $20, $F9, $28, $03, $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F7
	.byte $28, $01, $F6, $28, $01, $80, $20, $F8, $28, $03, $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA
	.byte $28, $03, $EF, $F8, $28, $01, $F7, $28, $01, $80, $20, $F9, $28, $03, $EF, $F9, $28, $01, $F8, $28
	.byte $01, $80, $20, $FA, $28, $03, $EF, $F7, $28, $01, $F6, $28, $01, $80, $20, $F8, $28, $03

; Bank 0
ft_s0p3c6:
	.byte $EF, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $EF, $F8, $24, $01, $F7, $24
	.byte $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $EF, $F7
	.byte $24, $01, $F6, $24, $01, $80, $20, $F8, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA
	.byte $24, $03, $EF, $F8, $24, $01, $F7, $24, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24
	.byte $01, $80, $20, $FA, $24, $03, $EF, $F7, $24, $01, $F6, $24, $01, $80, $20, $F8, $24, $03

; Bank 0
ft_s0p3c7:
	.byte $82, $01, $80, $22, $FD, $0C, $7E, $18, $9E, $03, $0C, $0C, $7E, $18, $7E, $0C, $7E, $18, $9E, $03
	.byte $0C, $0C, $7E, $18, $7E, $0C, $7E, $18, $9E, $03, $0C, $0C, $7E, $18, $7E, $0C, $7E, $18, $9E, $03
	.byte $0C, $0C, $7E, $18, $83, $7E, $01

; Bank 0
ft_s0p4c0:
	.byte $91, $7F, $00, $07, $E4, $F2, $45, $37

; Bank 0
ft_s0p4c1:
	.byte $E4, $91, $7E, $F1, $45, $0F, $F2, $00, $07, $F3, $00, $0F, $F2, $00, $07, $F1, $00, $07, $7F, $07

; Bank 0
ft_s0p4c2:
	.byte $82, $07, $E2, $91, $68, $1C, $ED, $1C, $E2, $1C, $ED, $1C, $E2, $1C, $ED, $1C, $E2, $1C, $83, $ED
	.byte $1C, $07

; Bank 0
ft_s0p4c3:
	.byte $82, $01, $E7, $85, $96, $FA, $19, $E8, $F4, $1C, $EA, $F7, $1B, $E0, $F4, $19, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $19, $E0, $F4, $1C, $E7, $F7, $1B, $E8, $F4, $19, $EA, $F7, $1C, $E0, $F4
	.byte $1B, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $1B, $F4, $16, $E7, $FA, $19, $E8, $F4, $1B, $EA
	.byte $F7, $1B, $E0, $F4, $19, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $19, $E0, $F4, $1C, $E7, $F7
	.byte $1B, $E8, $F4, $19, $EA, $F7, $1C, $F4, $1B, $83, $E9, $FB, $1F, $03, $EA, $FA, $1B, $01, $F4, $16
	.byte $01

; Bank 0
ft_s0p4c5:
	.byte $EF, $91, $7E, $F9, $26, $01, $F8, $26, $01, $80, $20, $FA, $26, $03, $EF, $F8, $26, $01, $F7, $26
	.byte $01, $80, $20, $F9, $26, $03, $EF, $F9, $26, $01, $F8, $26, $01, $80, $20, $FA, $26, $03, $EF, $F7
	.byte $26, $01, $F6, $26, $01, $80, $20, $F8, $26, $03, $EF, $F9, $26, $01, $F8, $26, $01, $80, $20, $FA
	.byte $26, $03, $EF, $F8, $26, $01, $F7, $26, $01, $80, $20, $F9, $26, $03, $EF, $F9, $26, $01, $F8, $26
	.byte $01, $80, $20, $FA, $26, $03, $EF, $F7, $26, $01, $F6, $26, $01, $80, $20, $F8, $26, $03

; Bank 0
ft_s0p4c6:
	.byte $EF, $91, $7F, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F8, $23, $01, $F7, $23
	.byte $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F7
	.byte $23, $01, $F6, $23, $01, $80, $20, $F8, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA
	.byte $23, $03, $EF, $F8, $23, $01, $F7, $23, $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23
	.byte $01, $80, $20, $FA, $23, $03, $EF, $F7, $23, $01, $F6, $23, $01, $80, $20, $F8, $23, $03

; Bank 0
ft_s0p4c7:
	.byte $82, $01, $80, $22, $08, $7E, $14, $9E, $03, $08, $08, $7E, $14, $7E, $08, $7E, $14, $9E, $03, $08
	.byte $08, $7E, $14, $7E, $10, $7E, $1C, $9E, $03, $10, $10, $7E, $1C, $7E, $0B, $7E, $17, $9E, $03, $0B
	.byte $0B, $7E, $17, $83, $7E, $01

; Bank 0
ft_s0p5c0:
	.byte $00, $03, $82, $01, $E5, $98, $22, $91, $7F, $93, $02, $F4, $32, $8D, $0F, $00, $E6, $F4, $30, $F1
	.byte $00, $F4, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $32, $03, $F4, $34, $03, $82, $01, $E6, $F4, $30
	.byte $F1, $00, $F4, $2D, $F1, $00, $F4, $28, $F1, $00, $E5, $98, $22, $F4, $32, $8D, $0F, $00, $E6, $F4
	.byte $30, $F1, $00, $F4, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $32, $03, $F4, $34, $01, $8A, $00, $01
	.byte $8F, $16, $00, $03, $8F, $26, $00, $03

; Bank 0
ft_s0p5c1:
	.byte $82, $01, $E5, $98, $22, $91, $7E, $93, $02, $FA, $32, $8D, $0F, $00, $E6, $F9, $30, $F4, $00, $F8
	.byte $2D, $F4, $00, $83, $E5, $98, $33, $FA, $32, $03, $FA, $34, $03, $82, $01, $E6, $F9, $30, $F4, $00
	.byte $F8, $2D, $F4, $00, $F7, $28, $F4, $00, $E5, $98, $22, $FA, $32, $8D, $0F, $00, $E6, $F9, $30, $F4
	.byte $00, $F8, $2D, $F4, $00, $83, $E5, $98, $33, $FA, $32, $03, $FA, $34, $01, $8A, $00, $01, $8F, $16
	.byte $00, $03, $8F, $26, $00, $03, $8F, $36, $00, $03

; Bank 0
ft_s0p5c2:
	.byte $82, $07, $E2, $91, $60, $18, $ED, $18, $E2, $18, $ED, $18, $E2, $18, $ED, $18, $E2, $18, $83, $ED
	.byte $18, $07

; Bank 0
ft_s0p5c3:
	.byte $82, $01, $E7, $85, $96, $FA, $15, $E8, $F4, $1B, $EA, $F7, $17, $E0, $F4, $15, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $15, $E0, $F4, $1A, $E7, $F7, $17, $E8, $F4, $15, $EA, $F7, $1A, $E0, $F4
	.byte $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $F5, $1C, $F4, $17, $E7, $FA, $15, $E8, $F4, $1C, $EA
	.byte $F7, $17, $E0, $F4, $15, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $15, $E0, $F4, $1A, $E7, $F7
	.byte $17, $E8, $F4, $15, $EA, $F7, $1A, $F4, $17, $83, $E9, $FB, $1F, $03, $EA, $F5, $1A, $01, $F4, $15
	.byte $01

; Bank 0
ft_s0p5c5:
	.byte $EF, $91, $7E, $F9, $29, $01, $F8, $29, $01, $80, $20, $FA, $29, $03, $EF, $F8, $29, $01, $F7, $29
	.byte $01, $80, $20, $F9, $29, $03, $EF, $F9, $29, $01, $F8, $29, $01, $80, $20, $FA, $29, $03, $EF, $F7
	.byte $29, $01, $F6, $29, $01, $80, $20, $F8, $29, $03, $EF, $F9, $29, $01, $F8, $29, $01, $80, $20, $FA
	.byte $29, $03, $EF, $F8, $29, $01, $F7, $29, $01, $80, $20, $F9, $29, $03, $EF, $F9, $29, $01, $F8, $29
	.byte $01, $80, $20, $FA, $29, $03, $EF, $F7, $29, $01, $F6, $29, $01, $80, $20, $F8, $29, $03

; Bank 0
ft_s0p6c0:
	.byte $8F, $36, $00, $03, $82, $01, $EB, $8F, $00, $91, $7F, $F1, $30, $F2, $2D, $F3, $34, $F4, $30, $F5
	.byte $39, $34, $F6, $3C, $39, $F7, $40, $39, $F7, $3C, $41, $F8, $40, $39, $F8, $34, $2F, $F7, $30, $2D
	.byte $F7, $34, $30, $F6, $39, $34, $F5, $3C, $39, $F4, $40, $F3, $39, $F2, $3C, $F1, $41, $40, $83, $39
	.byte $01

; Bank 0
ft_s0p6c1:
	.byte $82, $01, $EB, $91, $7E, $F3, $30, $F4, $2D, $8F, $00, $F5, $34, $F6, $30, $F7, $39, $34, $F8, $3C
	.byte $39, $F9, $40, $39, $F9, $3C, $41, $FA, $40, $39, $FA, $34, $2F, $F9, $30, $2D, $F9, $34, $30, $F8
	.byte $39, $34, $F7, $3C, $39, $F6, $40, $39, $F5, $3C, $41, $F4, $40, $39, $F3, $34, $83, $2F, $01

; Bank 0
ft_s0p6c5:
	.byte $EF, $91, $7E, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F8, $28, $01, $F7, $28
	.byte $01, $80, $20, $F9, $28, $03, $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F7
	.byte $28, $01, $F6, $28, $01, $80, $20, $F8, $28, $03, $EF, $F9, $26, $01, $F8, $26, $01, $80, $20, $FA
	.byte $26, $03, $EF, $F8, $26, $01, $F7, $26, $01, $80, $20, $F9, $26, $03, $EF, $F9, $26, $01, $F8, $26
	.byte $01, $80, $20, $FA, $26, $03, $EF, $F7, $26, $01, $F6, $26, $01, $80, $20, $F8, $26, $03

; Bank 0
ft_s0p6c6:
	.byte $EF, $91, $7F, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F8, $23, $01, $F7, $23
	.byte $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F7
	.byte $23, $01, $F6, $23, $01, $80, $20, $F8, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA
	.byte $23, $03, $EF, $F8, $23, $01, $F7, $23, $01, $80, $20, $F9, $23, $03, $EF, $F9, $20, $01, $F8, $20
	.byte $01, $80, $20, $FA, $20, $03, $EF, $F7, $20, $01, $F6, $20, $01, $80, $20, $F8, $20, $03

; Bank 0
ft_s0p7c0:
	.byte $00, $03, $82, $01, $E5, $98, $22, $91, $7F, $93, $02, $F4, $30, $8D, $0F, $00, $F4, $2F, $F0, $00
	.byte $F4, $2C, $F0, $00, $83, $98, $33, $F4, $31, $03, $F4, $32, $03, $82, $01, $F4, $2F, $F0, $00, $F4
	.byte $2C, $F0, $00, $F4, $28, $F0, $00, $98, $22, $F4, $30, $8D, $0F, $00, $F4, $2F, $F0, $00, $F4, $2C
	.byte $F0, $00, $83, $98, $34, $F4, $31, $03, $F4, $34, $01, $8A, $00, $01, $8F, $16, $00, $03, $8F, $26
	.byte $00, $03

; Bank 0
ft_s0p7c1:
	.byte $82, $01, $E5, $98, $22, $91, $7E, $93, $02, $FA, $30, $8D, $0F, $00, $F9, $2F, $F4, $00, $F8, $2C
	.byte $F4, $00, $83, $98, $33, $FA, $31, $03, $FA, $32, $03, $82, $01, $F9, $2F, $F4, $00, $F8, $2C, $F4
	.byte $00, $F7, $28, $F4, $00, $98, $22, $FA, $30, $8D, $0F, $00, $F9, $2F, $F4, $00, $F8, $2C, $F4, $00
	.byte $83, $98, $34, $FA, $31, $03, $FA, $34, $01, $8A, $00, $01, $8F, $16, $00, $03, $8F, $26, $00, $03
	.byte $8F, $36, $00, $03

; Bank 0
ft_s0p7c6:
	.byte $82, $01, $E5, $98, $22, $91, $7F, $93, $03, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF
	.byte $8A, $F8, $24, $F7, $24, $83, $E5, $98, $33, $93, $03, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30
	.byte $03, $82, $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03
	.byte $82, $01, $E5, $98, $22, $93, $03, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F8
	.byte $24, $F7, $24, $83, $E5, $98, $33, $93, $03, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82
	.byte $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03

; Bank 0
ft_s0p8c0:
	.byte $82, $03, $E1, $91, $68, $8F, $00, $FF, $14, $F9, $14, $F4, $14, $FF, $14, $F9, $14, $F4, $14, $83
	.byte $7F, $07, $82, $03, $91, $6C, $FF, $10, $F9, $10, $F4, $10, $FF, $10, $F9, $10, $F4, $10, $82, $01
	.byte $E5, $91, $7F, $93, $01, $F1, $2C, $EE, $F1, $2D, $F2, $2F, $83, $F3, $30, $01

; Bank 0
ft_s0p8c1:
	.byte $82, $03, $E1, $91, $68, $8F, $00, $FC, $17, $F8, $17, $F4, $17, $FC, $17, $F8, $17, $F4, $17, $83
	.byte $7F, $07, $82, $03, $FC, $10, $F8, $10, $F4, $10, $FC, $10, $F8, $10, $82, $01, $E5, $91, $7E, $93
	.byte $01, $F6, $2C, $EE, $F7, $2D, $F8, $2F, $F9, $30, $FA, $32, $83, $FB, $33, $01

; Bank 0
ft_s0p8c6:
	.byte $82, $01, $E5, $91, $7F, $93, $03, $F9, $2F, $8D, $0F, $00, $F8, $2C, $F3, $00, $EF, $8A, $F8, $23
	.byte $F7, $23, $83, $E5, $98, $33, $93, $03, $F9, $2D, $00, $8D, $0F, $00, $02, $F9, $2F, $03, $82, $01
	.byte $F8, $2C, $F3, $00, $EF, $8A, $F7, $23, $F6, $23, $83, $80, $20, $F8, $23, $03, $82, $01, $E5, $98
	.byte $22, $93, $03, $F9, $2D, $8D, $0F, $00, $F8, $2C, $F3, $00, $EF, $8A, $F8, $23, $F7, $23, $83, $E5
	.byte $98, $33, $93, $03, $F9, $2D, $00, $8D, $0F, $00, $02, $F9, $2F, $03, $F4, $32, $03, $EF, $8A, $F7
	.byte $23, $01, $F6, $23, $01, $80, $20, $F8, $23, $03

; Bank 0
ft_s0p9c0:
	.byte $82, $01, $EE, $91, $7F, $F4, $32, $F5, $33, $E5, $98, $22, $93, $01, $F4, $32, $8D, $0F, $00, $E6
	.byte $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $32, $03, $F4, $34, $03, $82, $01
	.byte $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $F1, $28, $F1, $00, $E5, $98, $22, $93, $01, $F4, $32
	.byte $8D, $0F, $00, $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $32, $03, $F4
	.byte $34, $03, $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F3, $2D, $83, $EE, $F3, $2F, $01

; Bank 0
ft_s0p9c1:
	.byte $82, $01, $E5, $98, $22, $91, $7E, $93, $01, $FA, $32, $8D, $0F, $00, $E6, $F9, $30, $F4, $00, $F8
	.byte $2D, $F4, $00, $83, $E5, $98, $33, $FA, $32, $03, $FA, $34, $03, $82, $01, $E6, $F9, $30, $F4, $00
	.byte $F8, $2D, $F4, $00, $F7, $28, $F4, $00, $E5, $98, $22, $93, $01, $FA, $32, $8D, $0F, $00, $E6, $F9
	.byte $30, $F4, $00, $F8, $2D, $F4, $00, $83, $E5, $98, $33, $FA, $32, $03, $FA, $34, $03, $82, $01, $E6
	.byte $F9, $30, $F4, $00, $E5, $8A, $F9, $2D, $EE, $F9, $2F, $FA, $30, $83, $FB, $31, $01

; Bank 0
ft_s0p9c6:
	.byte $82, $01, $E5, $8F, $00, $91, $7F, $93, $03, $F9, $30, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF
	.byte $8A, $F8, $24, $F7, $24, $83, $E5, $98, $33, $93, $03, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30
	.byte $03, $82, $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $93, $03, $F7, $24, $F6, $24, $83, $80, $20, $F8
	.byte $24, $03, $82, $01, $E5, $98, $22, $93, $03, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF
	.byte $8A, $F8, $24, $F7, $24, $83, $E5, $98, $33, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82
	.byte $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03

; Bank 0
ft_s0p10c0:
	.byte $82, $01, $EE, $91, $7F, $F4, $30, $F5, $31, $E5, $93, $01, $F4, $32, $8D, $0F, $00, $F3, $2F, $F1
	.byte $00, $F2, $2C, $F1, $00, $83, $98, $33, $F4, $31, $03, $F4, $32, $03, $82, $01, $F3, $2F, $F1, $00
	.byte $F2, $2C, $F1, $00, $F1, $28, $F1, $00, $98, $22, $93, $01, $F4, $30, $8D, $0F, $00, $F3, $2F, $F1
	.byte $00, $F2, $2C, $F1, $00, $83, $98, $33, $F4, $31, $03, $F4, $32, $03, $82, $01, $8A, $F1, $2C, $F1
	.byte $2D, $EE, $F2, $2F, $83, $F3, $30, $01

; Bank 0
ft_s0p10c1:
	.byte $82, $01, $E5, $91, $7E, $93, $01, $FA, $32, $8D, $0F, $00, $F9, $2F, $F4, $00, $F8, $2C, $F4, $00
	.byte $83, $98, $33, $FA, $31, $03, $FA, $32, $03, $82, $01, $F9, $2F, $F4, $00, $F8, $2C, $F4, $00, $F7
	.byte $28, $F4, $00, $98, $22, $93, $01, $FA, $30, $8D, $0F, $00, $F9, $2F, $F4, $00, $F8, $2C, $F4, $00
	.byte $83, $98, $33, $FA, $31, $03, $FA, $32, $03, $82, $01, $8A, $F6, $2C, $F7, $2D, $EE, $F8, $2F, $F9
	.byte $30, $FA, $32, $83, $FB, $34, $01

; Bank 0
ft_s0p10c5:
	.byte $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F8, $28, $01, $F7, $28, $01, $80
	.byte $20, $F9, $28, $03, $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F7, $28, $01
	.byte $F6, $28, $01, $80, $20, $F8, $28, $03, $82, $01, $E5, $98, $22, $93, $03, $FA, $33, $8D, $0F, $00
	.byte $F9, $34, $F6, $00, $F8, $2F, $F4, $00, $83, $98, $22, $FA, $33, $03, $8A, $FB, $34, $01, $8F, $16
	.byte $00, $03, $8F, $26, $00, $03, $8F, $36, $00, $04, $8F, $00, $00, $00

; Bank 0
ft_s0p10c6:
	.byte $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F8, $23, $01, $F7, $23, $01, $80
	.byte $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $EF, $F7, $23, $01
	.byte $F6, $23, $01, $80, $20, $F8, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03
	.byte $EF, $F8, $23, $01, $F7, $23, $01, $80, $20, $F9, $23, $03, $EF, $F9, $20, $01, $F8, $20, $01, $80
	.byte $20, $FA, $20, $03, $EF, $F7, $20, $01, $F6, $20, $01, $80, $20, $F8, $20, $03

; Bank 0
ft_s0p11c0:
	.byte $82, $01, $EE, $8F, $00, $91, $7F, $F4, $32, $F5, $34, $E5, $93, $01, $F4, $35, $8D, $0F, $00, $E6
	.byte $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $34, $03, $F4, $35, $03, $82, $01
	.byte $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $F1, $29, $F1, $00, $E5, $98, $22, $F4, $33, $8D, $0F
	.byte $00, $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $83, $E5, $98, $33, $F4, $34, $03, $F4, $35, $03
	.byte $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F1, $2D, $83, $EE, $F2, $2F, $01

; Bank 0
ft_s0p11c1:
	.byte $82, $01, $E5, $8F, $00, $91, $7E, $93, $01, $FA, $35, $8D, $0F, $00, $E6, $F9, $30, $F4, $00, $F8
	.byte $2D, $F4, $00, $83, $E5, $98, $33, $FA, $34, $03, $FA, $35, $03, $82, $01, $E6, $F9, $30, $F4, $00
	.byte $F8, $2D, $F4, $00, $F7, $29, $F4, $00, $E5, $98, $22, $FA, $33, $8D, $0F, $00, $E6, $F9, $30, $F4
	.byte $00, $F8, $2D, $F4, $00, $83, $E5, $98, $33, $FA, $34, $03, $FA, $35, $03, $82, $01, $E6, $F9, $30
	.byte $F4, $00, $E5, $8A, $F7, $2D, $EE, $F8, $2F, $F9, $30, $83, $FA, $32, $01

; Bank 0
ft_s0p12c0:
	.byte $82, $01, $EE, $91, $7F, $F3, $30, $F4, $32, $E5, $98, $22, $F4, $33, $8D, $0F, $00, $83, $F3, $34
	.byte $03, $F2, $2F, $01, $F1, $00, $01, $98, $22, $F4, $33, $03, $F3, $34, $03, $82, $01, $F2, $2F, $F1
	.byte $00, $F1, $2C, $EE, $F2, $2D, $F3, $2F, $F4, $32, $E5, $98, $22, $F4, $33, $8D, $0F, $00, $F3, $34
	.byte $F1, $00, $F2, $2F, $F1, $00, $83, $98, $22, $F4, $33, $03, $8A, $F5, $34, $01, $8F, $16, $00, $03
	.byte $8F, $26, $00, $01, $8F, $00, $F3, $2F, $01, $F3, $30, $01

; Bank 0
ft_s0p12c1:
	.byte $E5, $98, $22, $91, $7E, $FA, $33, $01, $8D, $0F, $00, $01, $F9, $34, $03, $F8, $2F, $01, $F4, $00
	.byte $01, $98, $22, $FA, $33, $03, $F9, $34, $03, $82, $01, $F8, $2F, $F4, $00, $F7, $2C, $EE, $F8, $2D
	.byte $F9, $2F, $FA, $32, $E5, $98, $22, $FA, $33, $8D, $0F, $00, $F9, $34, $F6, $00, $F8, $2F, $F4, $00
	.byte $83, $98, $22, $FA, $33, $03, $8A, $FB, $34, $01, $8F, $16, $00, $03, $82, $01, $8F, $26, $00, $8F
	.byte $00, $F9, $2F, $F9, $30, $EE, $FA, $32, $83, $FA, $33, $01

; Bank 0
ft_s0p13c0:
	.byte $EF, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $E6, $93, $01, $F3, $30, $01
	.byte $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03
	.byte $82, $01, $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $EF, $F9, $24, $F8, $24, $83, $80, $20, $FA
	.byte $24, $03, $E6, $F3, $30, $01, $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24
	.byte $01, $80, $20, $FA, $24, $03, $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F3, $2D, $83, $EE, $F3
	.byte $2F, $01

; Bank 0
ft_s0p14c0:
	.byte $EF, $91, $7E, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $E5, $F3, $2F, $01, $F1, $00
	.byte $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $82, $01
	.byte $E5, $F3, $2F, $F1, $00, $F2, $2C, $F1, $00, $EF, $F9, $23, $F8, $23, $83, $80, $20, $FA, $23, $03
	.byte $E5, $F3, $2F, $01, $F1, $00, $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80
	.byte $20, $FA, $23, $03, $82, $01, $E5, $8A, $F1, $2C, $F1, $2D, $EE, $F2, $2F, $83, $F3, $30, $01

; Bank 0
ft_s0p15c0:
	.byte $EF, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $E6, $F3, $30, $01, $F1, $00
	.byte $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $82, $01
	.byte $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $EF, $F9, $24, $F8, $24, $83, $80, $20, $FA, $24, $03
	.byte $E6, $F3, $30, $01, $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80
	.byte $20, $FA, $24, $03, $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F1, $2D, $83, $EE, $F2, $2F, $01

; Bank 0
ft_s0p16c0:
	.byte $82, $01, $EE, $91, $7F, $F3, $30, $F4, $32, $E5, $98, $22, $F4, $33, $8D, $0F, $00, $83, $F3, $34
	.byte $03, $F2, $2F, $01, $F1, $00, $01, $98, $22, $F4, $33, $03, $F3, $34, $03, $82, $01, $F2, $2F, $F1
	.byte $00, $F1, $2C, $EE, $F2, $2D, $EF, $F9, $26, $F8, $26, $83, $80, $20, $FA, $26, $03, $EF, $F8, $26
	.byte $01, $F7, $26, $01, $80, $20, $F9, $26, $03, $EF, $F9, $26, $01, $F8, $26, $01, $80, $20, $FA, $26
	.byte $03, $EF, $F7, $26, $01, $F6, $26, $01, $80, $20, $F8, $26, $03

; Bank 0
ft_s0p16c1:
	.byte $E5, $98, $22, $91, $7E, $FA, $33, $01, $8D, $0F, $00, $01, $F9, $34, $03, $F8, $2F, $01, $F4, $00
	.byte $01, $98, $22, $FA, $33, $03, $F9, $34, $03, $82, $01, $F8, $2F, $F4, $00, $F7, $2C, $EE, $F8, $2D
	.byte $F9, $2F, $FA, $32, $E5, $98, $22, $F9, $37, $8D, $0F, $00, $F8, $38, $F5, $00, $F7, $34, $F3, $00
	.byte $83, $98, $22, $F9, $37, $03, $8A, $FA, $38, $01, $8F, $16, $00, $03, $8F, $26, $00, $03, $8F, $36
	.byte $00, $05

; Bank 0
ft_s0p17c0:
	.byte $7E, $07, $8F, $00, $00, $36, $86, $02, $00, $00

; Bank 0
ft_s0p17c1:
	.byte $7E, $07, $8F, $00, $00, $37

.segment "MUSIC_7"

; Bank 0
ft_s1p0c3:
	.byte $82, $01, $E0, $85, $96, $F7, $16, $F3, $15, $F4, $17, $F3, $16, $F4, $1A, $F3, $17, $F7, $16, $F3
	.byte $1A, $F5, $17, $F4, $16, $F5, $1A, $F4, $17, $F3, $1B, $F4, $1A, $F8, $15, $F4, $1B, $F9, $16, $F5
	.byte $15, $F6, $17, $F5, $16, $F6, $1A, $F5, $17, $F9, $16, $F5, $1A, $F7, $17, $F6, $16, $F7, $1A, $F6
	.byte $17, $F5, $1B, $F6, $1A, $FA, $15, $83, $F6, $1B, $01

; Bank 0
ft_s1p1c3:
	.byte $82, $01, $E7, $85, $96, $FA, $16, $E0, $F6, $15, $F7, $17, $F6, $16, $E7, $F7, $1A, $E0, $F6, $17
	.byte $FA, $16, $F6, $1A, $E7, $F7, $17, $E0, $F6, $16, $F7, $1A, $F6, $17, $E7, $F5, $1B, $E0, $F6, $1A
	.byte $FA, $15, $F6, $1B, $E7, $FA, $16, $E0, $F6, $15, $F7, $17, $F6, $16, $E7, $F7, $1A, $E0, $F6, $17
	.byte $FA, $16, $F6, $1A, $E7, $F7, $17, $E0, $F6, $16, $F7, $1A, $F6, $17, $E7, $F5, $1B, $E0, $F6, $1A
	.byte $FA, $15, $83, $F6, $1B, $01

; Bank 0
ft_s1p1c7:
	.byte $80, $2A, $91, $6C, $FC, $09, $01, $7E, $01, $15, $01, $09, $00, $7E, $00, $82, $01, $09, $7E, $15
	.byte $7E, $09, $7E, $15, $83, $09, $00, $7E, $00, $82, $01, $09, $7E, $15, $7E, $09, $7E, $15, $83, $09
	.byte $00, $7E, $00, $82, $01, $09, $7E, $15, $7E, $09, $7E, $15, $83, $09, $00, $7E, $00, $82, $01, $09
	.byte $7E, $15, $83, $7E, $01

; Bank 0
ft_s1p2c3:
	.byte $82, $01, $E7, $85, $96, $FA, $16, $E8, $F6, $15, $EA, $F7, $17, $E0, $F6, $16, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $16, $E0, $F6, $1A, $E7, $F7, $17, $E8, $F6, $16, $EA, $F7, $1A, $E0, $F6
	.byte $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $15, $F6, $1B, $E7, $FA, $16, $E8, $F6, $15, $EA
	.byte $F7, $17, $E0, $F6, $16, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $16, $E0, $F6, $1A, $E7, $F7
	.byte $17, $E8, $F6, $16, $EA, $F7, $1A, $F6, $17, $83, $E9, $FB, $1F, $03, $EA, $FA, $15, $01, $F6, $1B
	.byte $01

; Bank 0
ft_s1p2c7:
	.byte $80, $2A, $91, $6C, $FC, $10, $01, $7E, $01, $1C, $01, $10, $00, $7E, $00, $82, $01, $10, $7E, $1C
	.byte $7E, $10, $7E, $1C, $83, $10, $00, $7E, $00, $82, $01, $10, $7E, $1C, $7E, $10, $7E, $1C, $83, $10
	.byte $00, $7E, $00, $82, $01, $10, $7E, $1C, $7E, $10, $7E, $1C, $83, $10, $00, $7E, $00, $82, $01, $10
	.byte $7E, $1C, $83, $7E, $01

; Bank 0
ft_s1p3c3:
	.byte $82, $01, $E7, $85, $96, $FA, $17, $E8, $F6, $1C, $EA, $F7, $18, $E0, $F6, $17, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $17, $E0, $F6, $1A, $E7, $F7, $18, $E8, $F6, $17, $EA, $F7, $1A, $E0, $F6
	.byte $18, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $F5, $1C, $F6, $17, $E7, $FA, $17, $E8, $F6, $1C, $EA
	.byte $F7, $18, $E0, $F6, $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $17, $E0, $F6, $1A, $E7, $F7
	.byte $18, $E8, $F6, $17, $EA, $F7, $1A, $F6, $18, $83, $E9, $FB, $1F, $03, $EA, $F5, $1C, $01, $F6, $17
	.byte $01

; Bank 0
ft_s1p3c5:
	.byte $80, $26, $91, $7E, $F9, $28, $01, $F8, $28, $01, $80, $28, $FA, $28, $03, $80, $26, $F8, $28, $01
	.byte $F7, $28, $01, $80, $28, $F9, $28, $03, $80, $26, $F9, $28, $01, $F8, $28, $01, $80, $28, $FA, $28
	.byte $03, $80, $26, $F7, $28, $01, $F6, $28, $01, $80, $28, $F8, $28, $03, $80, $26, $F9, $28, $01, $F8
	.byte $28, $01, $80, $28, $FA, $28, $03, $80, $26, $F8, $28, $01, $F7, $28, $01, $80, $28, $F9, $28, $03
	.byte $80, $26, $F9, $28, $01, $F8, $28, $01, $80, $28, $FA, $28, $03, $80, $26, $F7, $28, $01, $F6, $28
	.byte $01, $80, $28, $F8, $28, $03

; Bank 0
ft_s1p3c6:
	.byte $80, $26, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $28, $FA, $24, $03, $80, $26, $F8, $24, $01
	.byte $F7, $24, $01, $80, $28, $F9, $24, $03, $80, $26, $F9, $24, $01, $F8, $24, $01, $80, $28, $FA, $24
	.byte $03, $80, $26, $F7, $24, $01, $F6, $24, $01, $80, $28, $F8, $24, $03, $80, $26, $F9, $24, $01, $F8
	.byte $24, $01, $80, $28, $FA, $24, $03, $80, $26, $F8, $24, $01, $F7, $24, $01, $80, $28, $F9, $24, $03
	.byte $80, $26, $F9, $24, $01, $F8, $24, $01, $80, $28, $FA, $24, $03, $80, $26, $F7, $24, $01, $F6, $24
	.byte $01, $80, $28, $F8, $24, $03

; Bank 0
ft_s1p3c7:
	.byte $80, $2A, $FD, $0C, $01, $7E, $01, $18, $01, $0C, $00, $7E, $00, $82, $01, $0C, $7E, $18, $7E, $0C
	.byte $7E, $18, $83, $0C, $00, $7E, $00, $82, $01, $0C, $7E, $18, $7E, $0C, $7E, $18, $83, $0C, $00, $7E
	.byte $00, $82, $01, $0C, $7E, $18, $7E, $0C, $7E, $18, $83, $0C, $00, $7E, $00, $82, $01, $0C, $7E, $18
	.byte $83, $7E, $01

; Bank 0
ft_s1p4c3:
	.byte $82, $01, $E7, $85, $96, $FA, $19, $E8, $F6, $1C, $EA, $F7, $1B, $E0, $F6, $19, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $19, $E0, $F6, $1C, $E7, $F7, $1B, $E8, $F6, $19, $EA, $F7, $1C, $E0, $F6
	.byte $1B, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $1B, $F6, $16, $E7, $FA, $19, $E8, $F6, $1B, $EA
	.byte $F7, $1B, $E0, $F6, $19, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $19, $E0, $F6, $1C, $E7, $F7
	.byte $1B, $E8, $F6, $19, $EA, $F7, $1C, $F6, $1B, $83, $E9, $FB, $1F, $03, $EA, $FA, $1B, $01, $F6, $16
	.byte $01

; Bank 0
ft_s1p4c5:
	.byte $80, $26, $F9, $26, $01, $F8, $26, $01, $80, $28, $FA, $26, $03, $80, $26, $F8, $26, $01, $F7, $26
	.byte $01, $80, $28, $F9, $26, $03, $80, $26, $F9, $26, $01, $F8, $26, $01, $80, $28, $FA, $26, $03, $80
	.byte $26, $F7, $26, $01, $F6, $26, $01, $80, $28, $F8, $26, $03, $80, $26, $F9, $26, $01, $F8, $26, $01
	.byte $80, $28, $FA, $26, $03, $80, $26, $F8, $26, $01, $F7, $26, $01, $80, $28, $F9, $26, $03, $80, $26
	.byte $F9, $26, $01, $F8, $26, $01, $80, $28, $FA, $26, $03, $80, $26, $F7, $26, $01, $F6, $26, $01, $80
	.byte $28, $F8, $26, $03

; Bank 0
ft_s1p4c6:
	.byte $80, $26, $F9, $23, $01, $F8, $23, $01, $80, $28, $FA, $23, $03, $80, $26, $F8, $23, $01, $F7, $23
	.byte $01, $80, $28, $F9, $23, $03, $80, $26, $F9, $23, $01, $F8, $23, $01, $80, $28, $FA, $23, $03, $80
	.byte $26, $F7, $23, $01, $F6, $23, $01, $80, $28, $F8, $23, $03, $80, $26, $F9, $23, $01, $F8, $23, $01
	.byte $80, $28, $FA, $23, $03, $80, $26, $F8, $23, $01, $F7, $23, $01, $80, $28, $F9, $23, $03, $80, $26
	.byte $F9, $23, $01, $F8, $23, $01, $80, $28, $FA, $23, $03, $80, $26, $F7, $23, $01, $F6, $23, $01, $80
	.byte $28, $F8, $23, $03

; Bank 0
ft_s1p4c7:
	.byte $80, $2A, $08, $01, $7E, $01, $14, $01, $08, $00, $7E, $00, $82, $01, $08, $7E, $14, $7E, $08, $7E
	.byte $14, $83, $08, $00, $7E, $00, $82, $01, $08, $7E, $14, $7E, $10, $7E, $1C, $83, $10, $00, $7E, $00
	.byte $82, $01, $10, $7E, $1C, $7E, $0B, $7E, $17, $83, $0B, $00, $7E, $00, $82, $01, $0B, $7E, $17, $83
	.byte $7E, $01

; Bank 0
ft_s1p5c0:
	.byte $00, $03, $82, $01, $E5, $98, $22, $91, $7F, $93, $02, $F6, $32, $8D, $0F, $00, $E6, $F6, $30, $F3
	.byte $00, $F6, $2D, $F3, $00, $83, $E5, $98, $33, $F6, $32, $03, $F6, $34, $03, $82, $01, $E6, $F6, $30
	.byte $F3, $00, $F6, $2D, $F3, $00, $F6, $28, $F3, $00, $E5, $98, $22, $F6, $32, $8D, $0F, $00, $E6, $F6
	.byte $30, $F3, $00, $F6, $2D, $F3, $00, $83, $E5, $98, $33, $F6, $32, $03, $F6, $34, $01, $8A, $00, $01
	.byte $8F, $16, $00, $03, $8F, $26, $00, $03

; Bank 0
ft_s1p5c3:
	.byte $82, $01, $E7, $85, $96, $FA, $15, $E8, $F6, $1B, $EA, $F7, $17, $E0, $F6, $15, $83, $E9, $FB, $1F
	.byte $03, $82, $01, $EA, $FA, $15, $E0, $F6, $1A, $E7, $F7, $17, $E8, $F6, $15, $EA, $F7, $1A, $E0, $F6
	.byte $17, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $F5, $1C, $F6, $17, $E7, $FA, $15, $E8, $F6, $1C, $EA
	.byte $F7, $17, $E0, $F6, $15, $83, $E9, $FB, $1F, $03, $82, $01, $EA, $FA, $15, $E0, $F6, $1A, $E7, $F7
	.byte $17, $E8, $F6, $15, $EA, $F7, $1A, $F6, $17, $83, $E9, $FB, $1F, $03, $EA, $F5, $1A, $01, $F6, $15
	.byte $01

; Bank 0
ft_s1p5c5:
	.byte $80, $26, $91, $7E, $F9, $29, $01, $F8, $29, $01, $80, $28, $FA, $29, $03, $80, $26, $F8, $29, $01
	.byte $F7, $29, $01, $80, $28, $F9, $29, $03, $80, $26, $F9, $29, $01, $F8, $29, $01, $80, $28, $FA, $29
	.byte $03, $80, $26, $F7, $29, $01, $F6, $29, $01, $80, $28, $F8, $29, $03, $80, $26, $F9, $29, $01, $F8
	.byte $29, $01, $80, $28, $FA, $29, $03, $80, $26, $F8, $29, $01, $F7, $29, $01, $80, $28, $F9, $29, $03
	.byte $80, $26, $F9, $29, $01, $F8, $29, $01, $80, $28, $FA, $29, $03, $80, $26, $F7, $29, $01, $F6, $29
	.byte $01, $80, $28, $F8, $29, $03

; Bank 0
ft_s1p6c0:
	.byte $8F, $36, $91, $7F, $00, $03, $82, $01, $EB, $8F, $00, $F1, $30, $F2, $2D, $F3, $34, $F4, $30, $F5
	.byte $39, $34, $F6, $3C, $39, $F7, $40, $39, $F7, $3C, $41, $F8, $40, $39, $F8, $34, $2F, $F7, $30, $2D
	.byte $F7, $34, $30, $F6, $39, $34, $F5, $3C, $39, $F4, $40, $F3, $39, $F2, $3C, $F1, $41, $40, $83, $39
	.byte $01

; Bank 0
ft_s1p6c5:
	.byte $80, $26, $F9, $28, $01, $F8, $28, $01, $80, $28, $FA, $28, $03, $80, $26, $F8, $28, $01, $F7, $28
	.byte $01, $80, $28, $F9, $28, $03, $80, $26, $F9, $28, $01, $F8, $28, $01, $80, $28, $FA, $28, $03, $80
	.byte $26, $F7, $28, $01, $F6, $28, $01, $80, $28, $F8, $28, $03, $80, $26, $F9, $26, $01, $F8, $26, $01
	.byte $80, $28, $FA, $26, $03, $80, $26, $F8, $26, $01, $F7, $26, $01, $80, $28, $F9, $26, $03, $80, $26
	.byte $F9, $26, $01, $F8, $26, $01, $80, $28, $FA, $26, $03, $80, $26, $F7, $26, $01, $F6, $26, $01, $80
	.byte $28, $F8, $26, $03

; Bank 0
ft_s1p6c6:
	.byte $80, $26, $F9, $23, $01, $F8, $23, $01, $80, $28, $FA, $23, $03, $80, $26, $F8, $23, $01, $F7, $23
	.byte $01, $80, $28, $F9, $23, $03, $80, $26, $F9, $23, $01, $F8, $23, $01, $80, $28, $FA, $23, $03, $80
	.byte $26, $F7, $23, $01, $F6, $23, $01, $80, $28, $F8, $23, $03, $80, $26, $F9, $23, $01, $F8, $23, $01
	.byte $80, $28, $FA, $23, $03, $80, $26, $F8, $23, $01, $F7, $23, $01, $80, $28, $F9, $23, $03, $80, $26
	.byte $F9, $20, $01, $F8, $20, $01, $80, $28, $FA, $20, $03, $80, $26, $F7, $20, $01, $F6, $20, $01, $80
	.byte $28, $F8, $20, $03

; Bank 0
ft_s1p7c0:
	.byte $00, $03, $82, $01, $E5, $98, $22, $91, $7F, $93, $02, $F6, $30, $8D, $0F, $00, $F6, $2F, $F2, $00
	.byte $F6, $2C, $F2, $00, $83, $98, $33, $F6, $31, $03, $F6, $32, $03, $82, $01, $F6, $2F, $F2, $00, $F6
	.byte $2C, $F2, $00, $F6, $28, $F2, $00, $98, $22, $F6, $30, $8D, $0F, $00, $F6, $2F, $F2, $00, $F6, $2C
	.byte $F2, $00, $83, $98, $34, $F6, $31, $03, $F6, $34, $01, $8A, $00, $01, $8F, $16, $00, $03, $8F, $26
	.byte $00, $03

; Bank 0
ft_s1p7c6:
	.byte $82, $01, $E5, $98, $22, $91, $7F, $93, $06, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF
	.byte $8A, $F8, $24, $F7, $24, $83, $E5, $98, $33, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82
	.byte $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03, $82, $01
	.byte $E5, $98, $22, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F8, $24, $F7, $24, $83
	.byte $E5, $98, $33, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82, $01, $E6, $F8, $2D, $F3, $00
	.byte $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03

; Bank 0
ft_s1p8c0:
	.byte $82, $03, $E1, $91, $68, $8F, $00, $FF, $14, $F9, $14, $F4, $14, $FF, $14, $F9, $14, $F4, $14, $83
	.byte $7F, $07, $82, $03, $91, $6C, $FF, $10, $F9, $10, $F4, $10, $FF, $10, $F9, $10, $F4, $10, $82, $01
	.byte $E5, $91, $7F, $93, $02, $F1, $2C, $EE, $F1, $2D, $F2, $2F, $83, $F3, $30, $01

; Bank 0
ft_s1p8c6:
	.byte $82, $01, $E5, $91, $7F, $93, $06, $F9, $2F, $8D, $0F, $00, $F8, $2C, $F3, $00, $EF, $8A, $F8, $23
	.byte $F7, $23, $83, $E5, $98, $33, $F9, $2D, $00, $8D, $0F, $00, $02, $F9, $2F, $03, $82, $01, $F8, $2C
	.byte $F3, $00, $EF, $8A, $F7, $23, $F6, $23, $83, $80, $20, $F8, $23, $03, $82, $01, $E5, $98, $22, $F9
	.byte $2D, $8D, $0F, $00, $F8, $2C, $F3, $00, $EF, $8A, $F8, $23, $F7, $23, $83, $E5, $98, $33, $F9, $2D
	.byte $00, $8D, $0F, $00, $02, $F9, $2F, $03, $F4, $32, $03, $EF, $8A, $F7, $23, $01, $F6, $23, $01, $80
	.byte $20, $F8, $23, $03

; Bank 0
ft_s1p9c0:
	.byte $82, $01, $EE, $91, $7F, $F5, $32, $F6, $33, $E5, $98, $22, $93, $02, $F5, $32, $8D, $0F, $00, $E6
	.byte $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $83, $E5, $98, $33, $F5, $32, $03, $F5, $34, $03, $82, $01
	.byte $E6, $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $F2, $28, $F2, $00, $E5, $98, $22, $93, $02, $F5, $32
	.byte $8D, $0F, $00, $E6, $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $83, $E5, $98, $33, $F5, $32, $03, $F5
	.byte $34, $03, $82, $01, $E6, $F4, $30, $F2, $00, $E5, $8A, $F4, $2D, $83, $EE, $F4, $2F, $01

; Bank 0
ft_s1p9c6:
	.byte $82, $01, $E5, $8F, $00, $91, $7F, $93, $06, $F9, $30, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF
	.byte $8A, $F8, $24, $F7, $24, $83, $E5, $98, $33, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82
	.byte $01, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03, $82, $01
	.byte $E5, $98, $22, $F9, $2E, $8D, $0F, $00, $E6, $F8, $2D, $F3, $00, $EF, $8A, $F8, $24, $F7, $24, $83
	.byte $E5, $98, $33, $F9, $2F, $00, $8D, $0F, $00, $02, $F9, $30, $03, $82, $01, $E6, $F8, $2D, $F3, $00
	.byte $EF, $8A, $F7, $24, $F6, $24, $83, $80, $20, $F8, $24, $03

; Bank 0
ft_s1p10c0:
	.byte $82, $01, $EE, $91, $7F, $F5, $30, $F6, $31, $E5, $93, $02, $F5, $32, $8D, $0F, $00, $F4, $2F, $F2
	.byte $00, $F3, $2C, $F2, $00, $83, $98, $33, $F5, $31, $03, $F5, $32, $03, $82, $01, $F4, $2F, $F2, $00
	.byte $F3, $2C, $F2, $00, $F2, $28, $F2, $00, $98, $22, $93, $02, $F5, $30, $8D, $0F, $00, $F4, $2F, $F2
	.byte $00, $F3, $2C, $F2, $00, $83, $98, $33, $F5, $31, $03, $F5, $32, $03, $82, $01, $8A, $F2, $2C, $F2
	.byte $2D, $EE, $F3, $2F, $83, $F4, $30, $01

; Bank 0
ft_s1p10c5:
	.byte $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F8, $28, $01, $F7, $28, $01, $80
	.byte $20, $F9, $28, $03, $EF, $F9, $28, $01, $F8, $28, $01, $80, $20, $FA, $28, $03, $EF, $F7, $28, $01
	.byte $F6, $28, $01, $80, $20, $F8, $28, $03, $82, $01, $E5, $98, $22, $93, $06, $FA, $33, $8D, $0F, $00
	.byte $F9, $34, $F6, $00, $F8, $2F, $F4, $00, $83, $98, $22, $FA, $33, $03, $8A, $FB, $34, $01, $8F, $16
	.byte $00, $03, $8F, $26, $00, $03, $8F, $36, $00, $04, $8F, $00, $00, $00

; Bank 0
ft_s1p11c0:
	.byte $82, $01, $EE, $8F, $00, $91, $7F, $F5, $32, $F6, $34, $E5, $93, $02, $F5, $35, $8D, $0F, $00, $E6
	.byte $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $83, $E5, $98, $33, $F5, $34, $03, $F5, $35, $03, $82, $01
	.byte $E6, $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $F2, $29, $F2, $00, $E5, $98, $22, $93, $02, $F5, $33
	.byte $8D, $0F, $00, $E6, $F4, $30, $F2, $00, $F3, $2D, $F2, $00, $83, $E5, $98, $33, $F5, $34, $03, $F5
	.byte $35, $03, $82, $01, $E6, $F4, $30, $F2, $00, $E5, $8A, $F2, $2D, $83, $EE, $F3, $2F, $01

; Bank 0
ft_s1p11c1:
	.byte $82, $01, $E5, $8F, $00, $91, $7E, $93, $01, $FA, $35, $8D, $0F, $00, $E6, $F9, $30, $F4, $00, $F8
	.byte $2D, $F4, $00, $83, $E5, $98, $33, $FA, $34, $03, $FA, $35, $03, $82, $01, $E6, $F9, $30, $F4, $00
	.byte $F8, $2D, $F4, $00, $F7, $29, $F4, $00, $E5, $98, $22, $93, $01, $FA, $33, $8D, $0F, $00, $E6, $F9
	.byte $30, $F4, $00, $F8, $2D, $F4, $00, $83, $E5, $98, $33, $FA, $34, $03, $FA, $35, $03, $82, $01, $E6
	.byte $F9, $30, $F4, $00, $E5, $8A, $F7, $2D, $EE, $F8, $2F, $F9, $30, $83, $FA, $32, $01

; Bank 0
ft_s1p12c0:
	.byte $82, $01, $EE, $91, $7F, $F5, $30, $F6, $32, $E5, $98, $22, $93, $02, $F6, $33, $8D, $0F, $00, $83
	.byte $F5, $34, $03, $F4, $2F, $01, $F3, $00, $01, $98, $22, $F6, $33, $03, $F5, $34, $03, $82, $01, $F4
	.byte $2F, $F3, $00, $F3, $2C, $EE, $F4, $2D, $F5, $2F, $F6, $32, $E5, $98, $22, $93, $02, $F6, $33, $8D
	.byte $0F, $00, $F5, $34, $F3, $00, $F4, $2F, $F3, $00, $83, $98, $22, $F6, $33, $03, $8A, $F7, $34, $01
	.byte $8F, $16, $00, $03, $8F, $26, $00, $01, $8F, $00, $F5, $2F, $01, $F5, $30, $01

; Bank 0
ft_s1p12c1:
	.byte $E5, $98, $22, $91, $7E, $93, $01, $FA, $33, $01, $8D, $0F, $00, $01, $F9, $34, $03, $F8, $2F, $01
	.byte $F4, $00, $01, $98, $22, $FA, $33, $03, $F9, $34, $03, $82, $01, $F8, $2F, $F4, $00, $F7, $2C, $EE
	.byte $F8, $2D, $F9, $2F, $FA, $32, $E5, $98, $22, $93, $01, $FA, $33, $8D, $0F, $00, $F9, $34, $F6, $00
	.byte $F8, $2F, $F4, $00, $83, $98, $22, $FA, $33, $03, $8A, $FB, $34, $01, $8F, $16, $00, $03, $82, $01
	.byte $8F, $26, $00, $8F, $00, $F9, $2F, $F9, $30, $EE, $FA, $32, $83, $FA, $33, $01

; Bank 0
ft_s1p13c0:
	.byte $EF, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $E6, $93, $02, $F3, $30, $01
	.byte $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03
	.byte $82, $01, $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $EF, $F9, $24, $F8, $24, $83, $80, $20, $FA
	.byte $24, $03, $E6, $F3, $30, $01, $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24
	.byte $01, $80, $20, $FA, $24, $03, $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F3, $2D, $83, $EE, $F3
	.byte $2F, $01

; Bank 0
ft_s1p14c0:
	.byte $EF, $91, $7E, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03, $E5, $93, $02, $F3, $2F, $01
	.byte $F1, $00, $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23, $01, $80, $20, $FA, $23, $03
	.byte $82, $01, $E5, $F3, $2F, $F1, $00, $F2, $2C, $F1, $00, $EF, $F9, $23, $F8, $23, $83, $80, $20, $FA
	.byte $23, $03, $E5, $F3, $2F, $01, $F1, $00, $01, $80, $20, $F9, $23, $03, $EF, $F9, $23, $01, $F8, $23
	.byte $01, $80, $20, $FA, $23, $03, $82, $01, $E5, $8A, $F1, $2C, $F1, $2D, $EE, $F2, $2F, $83, $F3, $30
	.byte $01

; Bank 0
ft_s1p15c0:
	.byte $EF, $91, $7F, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03, $E6, $93, $02, $F3, $30, $01
	.byte $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24, $01, $80, $20, $FA, $24, $03
	.byte $82, $01, $E6, $F3, $30, $F1, $00, $F2, $2D, $F1, $00, $EF, $F9, $24, $F8, $24, $83, $80, $20, $FA
	.byte $24, $03, $E6, $F3, $30, $01, $F1, $00, $01, $80, $20, $F9, $24, $03, $EF, $F9, $24, $01, $F8, $24
	.byte $01, $80, $20, $FA, $24, $03, $82, $01, $E6, $F3, $30, $F1, $00, $E5, $8A, $F1, $2D, $83, $EE, $F2
	.byte $2F, $01

; Bank 0
ft_s1p16c0:
	.byte $82, $01, $EE, $91, $7F, $93, $02, $F3, $30, $F4, $32, $E5, $98, $22, $F4, $33, $8D, $0F, $00, $83
	.byte $F3, $34, $03, $F2, $2F, $01, $F1, $00, $01, $98, $22, $F4, $33, $03, $F3, $34, $03, $82, $01, $F2
	.byte $2F, $F1, $00, $F1, $2C, $EE, $F2, $2D, $EF, $F9, $26, $F8, $26, $83, $80, $20, $FA, $26, $03, $EF
	.byte $F8, $26, $01, $F7, $26, $01, $80, $20, $F9, $26, $03, $EF, $F9, $26, $01, $F8, $26, $01, $80, $20
	.byte $FA, $26, $03, $EF, $F7, $26, $01, $F6, $26, $01, $80, $20, $F8, $26, $03

; Bank 0
ft_s1p16c1:
	.byte $E5, $98, $22, $91, $7E, $93, $01, $FA, $33, $01, $8D, $0F, $00, $01, $F9, $34, $03, $F8, $2F, $01
	.byte $F4, $00, $01, $98, $22, $FA, $33, $03, $F9, $34, $03, $82, $01, $F8, $2F, $F4, $00, $F7, $2C, $EE
	.byte $F8, $2D, $F9, $2F, $FA, $32, $E5, $98, $22, $93, $01, $F9, $37, $8D, $0F, $00, $F8, $38, $F5, $00
	.byte $F7, $34, $F3, $00, $83, $98, $22, $F9, $37, $03, $8A, $FA, $38, $01, $8F, $16, $00, $03, $8F, $26
	.byte $00, $03, $8F, $36, $00, $05

; Bank 0
ft_s2p0c3:
	.byte $85, $96, $7F, $3F

; Bank 0
ft_s2p0c7:
	.byte $7E, $3F

; Bank 0
ft_s2p1c0:
	.byte $80, $2E, $91, $7E, $F7, $28, $01, $F6, $28, $01, $80, $30, $F8, $28, $03, $80, $2E, $F6, $28, $01
	.byte $F5, $28, $01, $80, $30, $F7, $28, $03, $80, $2E, $F7, $28, $01, $F6, $28, $01, $80, $30, $F8, $28
	.byte $03, $80, $2E, $F5, $28, $01, $F4, $28, $01, $80, $30, $F6, $28, $03, $80, $2E, $F7, $28, $01, $F6
	.byte $28, $01, $80, $30, $F8, $28, $03, $80, $2E, $F6, $28, $01, $F5, $28, $01, $80, $30, $F7, $28, $03
	.byte $80, $2E, $F7, $28, $01, $F6, $28, $01, $80, $30, $F8, $28, $03, $80, $2E, $F5, $28, $01, $F4, $28
	.byte $01, $80, $30, $F6, $28, $03

; Bank 0
ft_s2p1c1:
	.byte $80, $2E, $91, $7F, $F7, $24, $01, $F6, $24, $01, $80, $30, $F8, $24, $03, $80, $2E, $F6, $24, $01
	.byte $F5, $24, $01, $80, $30, $F7, $24, $03, $80, $2E, $F7, $24, $01, $F6, $24, $01, $80, $30, $F8, $24
	.byte $03, $80, $2E, $F5, $24, $01, $F4, $24, $01, $80, $30, $F6, $24, $03, $80, $2E, $F7, $24, $01, $F6
	.byte $24, $01, $80, $30, $F8, $24, $03, $80, $2E, $F6, $24, $01, $F5, $24, $01, $80, $30, $F7, $24, $03
	.byte $80, $2E, $F7, $24, $01, $F6, $24, $01, $80, $30, $F8, $24, $03, $80, $2E, $F5, $24, $01, $F4, $24
	.byte $01, $80, $30, $F6, $24, $03

; Bank 0
ft_s2p1c2:
	.byte $80, $2C, $91, $6C, $FC, $15, $01, $7E, $01, $21, $01, $15, $00, $7E, $00, $82, $01, $15, $7E, $21
	.byte $7E, $15, $7E, $21, $83, $15, $00, $7E, $00, $82, $01, $15, $7E, $21, $7E, $15, $7E, $21, $83, $15
	.byte $00, $7E, $00, $82, $01, $15, $7E, $21, $7E, $15, $7E, $21, $83, $15, $00, $7E, $00, $82, $01, $15
	.byte $7E, $21, $83, $7E, $01

; Bank 0
ft_s2p1c3:
	.byte $85, $96, $00, $3E, $86, $02, $00, $00

; Bank 0
ft_s2p1c5:
	.byte $80, $24, $93, $02, $91, $60, $F3, $09, $3F

; Bank 0
ft_s2p1c6:
	.byte $80, $24, $93, $02, $91, $64, $F3, $09, $3F

; Bank 0
ft_s2p1c7:
	.byte $82, $01, $7E, $80, $22, $91, $6C, $F4, $09, $7E, $15, $83, $09, $00, $7E, $00, $82, $01, $09, $7E
	.byte $15, $7E, $09, $7E, $15, $83, $09, $00, $7E, $00, $82, $01, $09, $7E, $15, $7E, $09, $7E, $15, $83
	.byte $09, $00, $7E, $00, $82, $01, $09, $7E, $15, $7E, $09, $7E, $15, $83, $09, $00, $7E, $00, $09, $01
	.byte $7E, $01, $15, $01

; Bank 0
ft_s2p2c0:
	.byte $80, $2E, $91, $7E, $F7, $26, $01, $F6, $26, $01, $80, $30, $F8, $26, $03, $80, $2E, $F6, $26, $01
	.byte $F5, $26, $01, $80, $30, $F7, $26, $03, $80, $2E, $F7, $26, $01, $F6, $26, $01, $80, $30, $F8, $26
	.byte $03, $80, $2E, $F5, $26, $01, $F4, $26, $01, $80, $30, $F6, $26, $03, $80, $2E, $F7, $26, $01, $F6
	.byte $26, $01, $80, $30, $F8, $26, $03, $80, $2E, $F6, $26, $01, $F5, $26, $01, $80, $30, $F7, $26, $03
	.byte $80, $2E, $F7, $26, $01, $F6, $26, $01, $80, $30, $F8, $26, $03, $80, $2E, $F5, $26, $01, $F4, $26
	.byte $01, $80, $30, $F6, $26, $03

; Bank 0
ft_s2p2c1:
	.byte $80, $2E, $91, $7F, $F7, $23, $01, $F6, $23, $01, $80, $30, $F8, $23, $03, $80, $2E, $F6, $23, $01
	.byte $F5, $23, $01, $80, $30, $F7, $23, $03, $80, $2E, $F7, $23, $01, $F6, $23, $01, $80, $30, $F8, $23
	.byte $03, $80, $2E, $F5, $23, $01, $F4, $23, $01, $80, $30, $F6, $23, $03, $80, $2E, $F7, $23, $01, $F6
	.byte $23, $01, $80, $30, $F8, $23, $03, $80, $2E, $F6, $23, $01, $F5, $23, $01, $80, $30, $F7, $23, $03
	.byte $80, $2E, $F7, $23, $01, $F6, $23, $01, $80, $30, $F8, $23, $03, $80, $2E, $F5, $23, $01, $F4, $23
	.byte $01, $80, $30, $F6, $23, $03

; Bank 0
ft_s2p2c2:
	.byte $80, $2C, $91, $78, $FC, $1C, $01, $7E, $01, $28, $01, $1C, $00, $7E, $00, $82, $01, $1C, $7E, $28
	.byte $7E, $1C, $7E, $28, $83, $1C, $00, $7E, $00, $82, $01, $1C, $7E, $28, $7E, $1C, $7E, $28, $83, $1C
	.byte $00, $7E, $00, $82, $01, $1C, $7E, $28, $7E, $1C, $7E, $28, $83, $1C, $00, $7E, $00, $82, $01, $1C
	.byte $7E, $28, $83, $7E, $01

; Bank 0
ft_s2p2c5:
	.byte $80, $24, $93, $02, $91, $68, $F3, $10, $3F

; Bank 0
ft_s2p2c6:
	.byte $80, $24, $93, $02, $91, $6C, $F3, $10, $3F

; Bank 0
ft_s2p2c7:
	.byte $82, $01, $7E, $80, $22, $91, $6C, $F4, $10, $7E, $1C, $83, $10, $00, $7E, $00, $82, $01, $10, $7E
	.byte $1C, $7E, $10, $7E, $1C, $83, $10, $00, $7E, $00, $82, $01, $10, $7E, $1C, $7E, $10, $7E, $1C, $83
	.byte $10, $00, $7E, $00, $82, $01, $10, $7E, $1C, $7E, $10, $7E, $1C, $83, $10, $00, $7E, $00, $10, $01
	.byte $7E, $01, $1C, $01

; Bank 0
ft_s2p3c2:
	.byte $80, $2C, $91, $78, $FD, $18, $01, $7E, $01, $24, $01, $18, $00, $7E, $00, $82, $01, $18, $7E, $24
	.byte $7E, $18, $7E, $24, $83, $18, $00, $7E, $00, $82, $01, $18, $7E, $24, $7E, $18, $7E, $24, $83, $18
	.byte $00, $7E, $00, $82, $01, $18, $7E, $24, $7E, $18, $7E, $24, $83, $18, $00, $7E, $00, $82, $01, $18
	.byte $7E, $24, $83, $7E, $01

; Bank 0
ft_s2p3c7:
	.byte $82, $01, $7E, $80, $22, $91, $6C, $F4, $0C, $7E, $18, $83, $0C, $00, $7E, $00, $82, $01, $0C, $7E
	.byte $18, $7E, $0C, $7E, $18, $83, $0C, $00, $7E, $00, $82, $01, $0C, $7E, $18, $7E, $0C, $7E, $18, $83
	.byte $0C, $00, $7E, $00, $82, $01, $0C, $7E, $18, $7E, $0C, $7E, $18, $83, $0C, $00, $7E, $00, $0C, $01
	.byte $7E, $01, $18, $01

; Bank 0
ft_s2p4c0:
	.byte $80, $2E, $91, $7E, $F7, $28, $01, $F6, $28, $01, $80, $30, $F8, $28, $03, $80, $2E, $F6, $28, $01
	.byte $F5, $28, $01, $80, $30, $F7, $28, $03, $80, $2E, $F7, $28, $01, $F6, $28, $01, $80, $30, $F8, $28
	.byte $03, $80, $2E, $F5, $28, $01, $F4, $28, $01, $80, $30, $F6, $28, $03, $80, $2E, $F7, $26, $01, $F6
	.byte $26, $01, $80, $30, $F8, $26, $03, $80, $2E, $F6, $26, $01, $F5, $26, $01, $80, $30, $F7, $26, $03
	.byte $80, $2E, $F7, $26, $01, $F6, $26, $01, $80, $30, $F8, $26, $03, $80, $2E, $F5, $26, $01, $F4, $26
	.byte $01, $80, $30, $F6, $26, $03

; Bank 0
ft_s2p4c1:
	.byte $80, $2E, $91, $7F, $F7, $23, $01, $F6, $23, $01, $80, $30, $F8, $23, $03, $80, $2E, $F6, $23, $01
	.byte $F5, $23, $01, $80, $30, $F7, $23, $03, $80, $2E, $F7, $23, $01, $F6, $23, $01, $80, $30, $F8, $23
	.byte $03, $80, $2E, $F5, $23, $01, $F4, $23, $01, $80, $30, $F6, $23, $03, $80, $2E, $F7, $23, $01, $F6
	.byte $23, $01, $80, $30, $F8, $23, $03, $80, $2E, $F6, $23, $01, $F5, $23, $01, $80, $30, $F7, $23, $03
	.byte $80, $2E, $F7, $20, $01, $F6, $20, $01, $80, $30, $F8, $20, $03, $80, $2E, $F5, $20, $01, $F4, $20
	.byte $01, $80, $30, $F6, $20, $03

; Bank 0
ft_s2p4c2:
	.byte $80, $2C, $91, $78, $14, $01, $7E, $01, $20, $01, $14, $00, $7E, $00, $82, $01, $14, $7E, $20, $7E
	.byte $14, $7E, $20, $83, $14, $00, $7E, $00, $82, $01, $14, $7E, $20, $7E, $91, $78, $1C, $7E, $28, $83
	.byte $1C, $00, $7E, $00, $82, $01, $1C, $7E, $28, $7E, $17, $7E, $23, $83, $17, $00, $7E, $00, $82, $01
	.byte $17, $7E, $23, $83, $7E, $01

; Bank 0
ft_s2p4c7:
	.byte $82, $01, $7E, $80, $22, $91, $6C, $F4, $08, $7E, $14, $83, $08, $00, $7E, $00, $82, $01, $08, $7E
	.byte $14, $7E, $08, $7E, $14, $83, $08, $00, $7E, $00, $82, $01, $08, $7E, $14, $7E, $10, $7E, $1C, $83
	.byte $10, $00, $7E, $00, $82, $01, $10, $7E, $1C, $7E, $0B, $7E, $17, $83, $0B, $00, $7E, $00, $0B, $01
	.byte $7E, $01, $17, $01

; Bank 0
ft_s2p5c0:
	.byte $82, $03, $80, $34, $91, $68, $FC, $15, $F6, $15, $F1, $15, $FC, $15, $F6, $15, $F1, $15, $83, $7F
	.byte $07, $82, $03, $FC, $15, $F6, $15, $F1, $15, $FC, $15, $F6, $15, $F1, $15, $83, $7F, $07

; Bank 0
ft_s2p5c1:
	.byte $82, $03, $80, $34, $91, $68, $F9, $18, $F5, $18, $F1, $18, $F9, $18, $F5, $18, $F1, $18, $83, $7F
	.byte $07, $82, $03, $F9, $18, $F5, $18, $F1, $18, $F9, $18, $F5, $18, $F1, $18, $83, $7F, $07

; Bank 0
ft_s2p5c2:
	.byte $80, $2C, $91, $70, $21, $01, $80, $32, $91, $70, $1C, $01, $80, $2C, $91, $74, $28, $00, $7F, $00
	.byte $80, $32, $91, $70, $21, $01, $82, $00, $80, $2C, $91, $7C, $34, $7F, $80, $32, $91, $74, $28, $7F
	.byte $83, $80, $2C, $91, $70, $21, $01, $82, $00, $80, $32, $91, $7C, $34, $7F, $80, $2C, $91, $74, $28
	.byte $7F, $83, $80, $32, $91, $70, $21, $01, $82, $00, $80, $2C, $91, $7C, $34, $7F, $80, $32, $91, $74
	.byte $28, $7F, $80, $2C, $91, $7E, $39, $7F, $80, $32, $91, $7C, $34, $7F, $83, $80, $2C, $91, $70, $1C
	.byte $01, $80, $32, $91, $7E, $39, $00, $7F, $00, $80, $2C, $91, $70, $21, $01, $80, $32, $91, $70, $1C
	.byte $01, $80, $2C, $91, $74, $28, $00, $7F, $00, $80, $32, $91, $70, $21, $01, $82, $00, $80, $2C, $91
	.byte $7C, $34, $7F, $80, $32, $91, $74, $28, $7F, $83, $80, $2C, $91, $70, $21, $01, $82, $00, $80, $32
	.byte $91, $7C, $34, $7F, $80, $2C, $91, $74, $28, $7F, $83, $80, $32, $91, $70, $21, $01, $82, $00, $80
	.byte $2C, $91, $7C, $34, $7F, $80, $32, $91, $74, $28, $7F, $80, $2C, $91, $7E, $39, $7F, $80, $32, $91
	.byte $7C, $34, $7F, $83, $80, $2C, $91, $70, $1C, $01, $80, $32, $91, $7E, $39, $00, $7F, $00

; Bank 0
ft_s2p6c0:
	.byte $82, $03, $80, $34, $91, $68, $FC, $15, $F6, $15, $F1, $15, $FC, $15, $F6, $15, $F1, $15, $83, $7F
	.byte $07, $82, $03, $91, $6C, $FC, $15, $F6, $15, $F1, $15, $FC, $15, $F6, $15, $F1, $15, $83, $7F, $07

; Bank 0
ft_s2p6c1:
	.byte $82, $03, $80, $34, $91, $68, $F9, $1C, $F5, $1C, $F1, $1C, $F9, $1C, $F5, $1C, $F1, $1C, $83, $7F
	.byte $07, $82, $03, $F9, $15, $F5, $15, $F1, $15, $F9, $15, $F5, $15, $F1, $15, $83, $7F, $07


; DPCM samples (located at DPCM segment)
