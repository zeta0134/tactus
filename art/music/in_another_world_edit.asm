; Dn-FamiTracker exported music data: in_another_world_edit.dnm
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $00

ft_inst_1:
	.byte 0
	.byte $01
	.word ft_seq_2a03_0

ft_inst_2:
	.byte 0
	.byte $13
	.word ft_seq_2a03_5
	.word ft_seq_2a03_1
	.word ft_seq_2a03_4

ft_inst_3:
	.byte 0
	.byte $13
	.word ft_seq_2a03_5
	.word ft_seq_2a03_6
	.word ft_seq_2a03_4

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_10
	.word ft_seq_2a03_11

ft_inst_5:
	.byte 9
	.byte $01
	.word ft_seq_n163_0
	.byte $10
	.byte $00
	.word ft_waves_5

ft_inst_6:
	.byte 4
	.byte $0F
	.word ft_seq_vrc6_10
	.word ft_seq_vrc6_11
	.word ft_seq_vrc6_2
	.word ft_seq_vrc6_3

ft_inst_7:
	.byte 0
	.byte $00

ft_inst_8:
	.byte 0
	.byte $00

; Sequences
ft_seq_2a03_0:
	.byte $0A, $FF, $01, $00, $0F, $0B, $09, $08, $06, $05, $03, $02, $01, $00
ft_seq_2a03_1:
	.byte $03, $02, $00, $01, $04, $00, $00
ft_seq_2a03_4:
	.byte $03, $FF, $00, $00, $01, $01, $00
ft_seq_2a03_5:
	.byte $10, $FF, $00, $00, $0F, $0F, $0A, $07, $06, $06, $05, $04, $03, $03, $03, $02, $02, $01, $01, $00
ft_seq_2a03_6:
	.byte $04, $03, $00, $01, $04, $08, $06, $07
ft_seq_2a03_10:
	.byte $07, $FF, $00, $00, $0A, $06, $05, $03, $02, $01, $00
ft_seq_2a03_11:
	.byte $02, $01, $00, $01, $0C, $0D
ft_seq_vrc6_2:
	.byte $01, $00, $00, $00, $03
ft_seq_vrc6_3:
	.byte $01, $00, $00, $00, $1A
ft_seq_vrc6_10:
	.byte $0A, $FF, $01, $00, $0F, $0B, $09, $08, $06, $05, $03, $02, $01, $00
ft_seq_vrc6_11:
	.byte $01, $00, $00, $01, $00
ft_seq_n163_0:
	.byte $0A, $FF, $01, $00, $0F, $0C, $0A, $08, $07, $05, $04, $02, $01, $00

; N163 waves
ft_waves_5:
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01

; DPCM instrument list (pitch, sample index)
ft_sample_list:
	.byte 15, 0, 0
	.byte 15, 0, 3
	.byte 192, 255, 6
	.byte 193, 255, 9
	.byte 194, 255, 9
	.byte 195, 255, 9
	.byte 196, 255, 9
	.byte 196, 255, 6
	.byte 197, 255, 9
	.byte 197, 255, 6
	.byte 199, 255, 9
	.byte 200, 255, 9
	.byte 201, 255, 9
	.byte 192, 255, 12
	.byte 0, 255, 12

; DPCM samples list (location, size, bank)
ft_samples:
	.byte <((ft_sample_0 - $C000) >> 6), 23, <.bank(ft_sample_0)
	.byte <((ft_sample_1 - $C000) >> 6), 49, <.bank(ft_sample_1)
	.byte <((ft_sample_2 - $C000) >> 6), 70, <.bank(ft_sample_2)
	.byte <((ft_sample_3 - $C000) >> 6), 91, <.bank(ft_sample_3)
	.byte <((ft_sample_4 - $C000) >> 6), 0, <.bank(ft_sample_4)

; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)
	.byte $04, $04, $02, $02, $00, $01
	.byte $04, $00, $07

; Song pointer list
ft_song_list:
	.word ft_song_0
	.word ft_song_1
	.word ft_song_2

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 100	; frame count
	.byte 32	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 1	; groove position
	.byte 0	; initial bank

ft_song_1:
	.word ft_s1_frames
	.byte 100	; frame count
	.byte 32	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 1	; groove position
	.byte 0	; initial bank

ft_song_2:
	.word ft_s2_frames
	.byte 100	; frame count
	.byte 32	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
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
	.word ft_s0f11
	.word ft_s0f12
	.word ft_s0f13
	.word ft_s0f14
	.word ft_s0f15
	.word ft_s0f16
	.word ft_s0f17
	.word ft_s0f18
	.word ft_s0f19
	.word ft_s0f20
	.word ft_s0f21
	.word ft_s0f22
	.word ft_s0f23
	.word ft_s0f24
	.word ft_s0f25
	.word ft_s0f26
	.word ft_s0f27
	.word ft_s0f28
	.word ft_s0f29
	.word ft_s0f30
	.word ft_s0f31
	.word ft_s0f32
	.word ft_s0f33
	.word ft_s0f34
	.word ft_s0f35
	.word ft_s0f36
	.word ft_s0f37
	.word ft_s0f38
	.word ft_s0f39
	.word ft_s0f40
	.word ft_s0f41
	.word ft_s0f42
	.word ft_s0f43
	.word ft_s0f44
	.word ft_s0f45
	.word ft_s0f46
	.word ft_s0f47
	.word ft_s0f48
	.word ft_s0f49
	.word ft_s0f50
	.word ft_s0f51
	.word ft_s0f52
	.word ft_s0f53
	.word ft_s0f54
	.word ft_s0f55
	.word ft_s0f56
	.word ft_s0f57
	.word ft_s0f58
	.word ft_s0f59
	.word ft_s0f60
	.word ft_s0f61
	.word ft_s0f62
	.word ft_s0f63
	.word ft_s0f64
	.word ft_s0f65
	.word ft_s0f66
	.word ft_s0f67
	.word ft_s0f68
	.word ft_s0f69
	.word ft_s0f70
	.word ft_s0f71
	.word ft_s0f72
	.word ft_s0f73
	.word ft_s0f74
	.word ft_s0f75
	.word ft_s0f76
	.word ft_s0f77
	.word ft_s0f78
	.word ft_s0f79
	.word ft_s0f80
	.word ft_s0f81
	.word ft_s0f82
	.word ft_s0f83
	.word ft_s0f84
	.word ft_s0f85
	.word ft_s0f86
	.word ft_s0f87
	.word ft_s0f88
	.word ft_s0f89
	.word ft_s0f90
	.word ft_s0f91
	.word ft_s0f92
	.word ft_s0f93
	.word ft_s0f94
	.word ft_s0f95
	.word ft_s0f96
	.word ft_s0f97
	.word ft_s0f98
	.word ft_s0f99
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c5, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
ft_s0f1:
	.word ft_s0p0c4, ft_s0p1c1, ft_s0p0c4, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f2:
	.word ft_s0p0c4, ft_s0p1c1, ft_s0p0c4, ft_s0p2c3, ft_s0p1c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f3:
	.word ft_s0p0c4, ft_s0p1c1, ft_s0p0c4, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f4:
	.word ft_s0p0c0, ft_s0p4c1, ft_s0p0c2, ft_s0p0c3, ft_s0p4c5, ft_s0p0c0, ft_s0p0c0, ft_s0p0c4
ft_s0f5:
	.word ft_s0p0c4, ft_s0p4c1, ft_s0p0c4, ft_s0p1c3, ft_s0p5c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f6:
	.word ft_s0p0c4, ft_s0p4c1, ft_s0p0c4, ft_s0p2c3, ft_s0p5c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f7:
	.word ft_s0p0c4, ft_s0p4c1, ft_s0p0c4, ft_s0p1c3, ft_s0p5c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f8:
	.word ft_s0p4c0, ft_s0p0c1, ft_s0p4c2, ft_s0p0c3, ft_s0p8c5, ft_s0p0c0, ft_s0p4c7, ft_s0p0c4
ft_s0f9:
	.word ft_s0p5c0, ft_s0p1c1, ft_s0p5c2, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4, ft_s0p5c7, ft_s0p0c4
ft_s0f10:
	.word ft_s0p6c0, ft_s0p1c1, ft_s0p6c2, ft_s0p2c3, ft_s0p1c5, ft_s0p0c4, ft_s0p4c7, ft_s0p0c4
ft_s0f11:
	.word ft_s0p5c0, ft_s0p1c1, ft_s0p5c2, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4, ft_s0p5c7, ft_s0p0c4
ft_s0f12:
	.word ft_s0p8c0, ft_s0p4c1, ft_s0p8c2, ft_s0p0c3, ft_s0p4c5, ft_s0p0c0, ft_s0p8c7, ft_s0p0c4
ft_s0f13:
	.word ft_s0p9c0, ft_s0p4c1, ft_s0p9c2, ft_s0p1c3, ft_s0p5c5, ft_s0p0c4, ft_s0p9c7, ft_s0p0c4
ft_s0f14:
	.word ft_s0p10c0, ft_s0p4c1, ft_s0p10c2, ft_s0p2c3, ft_s0p5c5, ft_s0p0c4, ft_s0p8c7, ft_s0p0c4
ft_s0f15:
	.word ft_s0p11c0, ft_s0p4c1, ft_s0p11c2, ft_s0p39c3, ft_s0p5c5, ft_s0p0c4, ft_s0p11c7, ft_s0p51c4
ft_s0f16:
	.word ft_s0p48c0, ft_s0p0c1, ft_s0p4c2, ft_s0p52c3, ft_s0p8c5, ft_s0p8c6, ft_s0p12c7, ft_s0p4c4
ft_s0f17:
	.word ft_s0p5c7, ft_s0p1c1, ft_s0p5c2, ft_s0p53c3, ft_s0p1c5, ft_s0p9c6, ft_s0p5c7, ft_s0p5c4
ft_s0f18:
	.word ft_s0p14c7, ft_s0p1c1, ft_s0p6c2, ft_s0p54c3, ft_s0p1c5, ft_s0p10c6, ft_s0p14c7, ft_s0p6c4
ft_s0f19:
	.word ft_s0p5c7, ft_s0p1c1, ft_s0p5c2, ft_s0p55c3, ft_s0p1c5, ft_s0p9c6, ft_s0p5c7, ft_s0p7c4
ft_s0f20:
	.word ft_s0p52c0, ft_s0p4c1, ft_s0p8c2, ft_s0p52c3, ft_s0p4c5, ft_s0p12c6, ft_s0p16c7, ft_s0p4c4
ft_s0f21:
	.word ft_s0p9c7, ft_s0p4c1, ft_s0p9c2, ft_s0p53c3, ft_s0p5c5, ft_s0p13c6, ft_s0p9c7, ft_s0p5c4
ft_s0f22:
	.word ft_s0p16c7, ft_s0p4c1, ft_s0p10c2, ft_s0p54c3, ft_s0p5c5, ft_s0p14c6, ft_s0p16c7, ft_s0p6c4
ft_s0f23:
	.word ft_s0p11c7, ft_s0p4c1, ft_s0p11c2, ft_s0p55c3, ft_s0p5c5, ft_s0p15c6, ft_s0p11c7, ft_s0p7c4
ft_s0f24:
	.word ft_s0p48c0, ft_s0p12c1, ft_s0p12c2, ft_s0p4c3, ft_s0p12c5, ft_s0p8c6, ft_s0p12c7, ft_s0p4c4
ft_s0f25:
	.word ft_s0p5c7, ft_s0p13c1, ft_s0p13c2, ft_s0p5c3, ft_s0p13c5, ft_s0p9c6, ft_s0p5c7, ft_s0p5c4
ft_s0f26:
	.word ft_s0p14c7, ft_s0p13c1, ft_s0p14c2, ft_s0p6c3, ft_s0p13c5, ft_s0p10c6, ft_s0p14c7, ft_s0p6c4
ft_s0f27:
	.word ft_s0p5c7, ft_s0p13c1, ft_s0p13c2, ft_s0p7c3, ft_s0p13c5, ft_s0p9c6, ft_s0p5c7, ft_s0p7c4
ft_s0f28:
	.word ft_s0p52c0, ft_s0p16c1, ft_s0p16c2, ft_s0p4c3, ft_s0p16c5, ft_s0p12c6, ft_s0p16c7, ft_s0p4c4
ft_s0f29:
	.word ft_s0p9c7, ft_s0p16c1, ft_s0p17c2, ft_s0p5c3, ft_s0p17c5, ft_s0p13c6, ft_s0p9c7, ft_s0p5c4
ft_s0f30:
	.word ft_s0p16c7, ft_s0p16c1, ft_s0p16c2, ft_s0p6c3, ft_s0p17c5, ft_s0p14c6, ft_s0p16c7, ft_s0p6c4
ft_s0f31:
	.word ft_s0p11c7, ft_s0p16c1, ft_s0p17c2, ft_s0p7c3, ft_s0p17c5, ft_s0p15c6, ft_s0p11c7, ft_s0p7c4
ft_s0f32:
	.word ft_s0p48c0, ft_s0p12c1, ft_s0p12c2, ft_s0p4c3, ft_s0p20c5, ft_s0p8c6, ft_s0p12c7, ft_s0p4c4
ft_s0f33:
	.word ft_s0p5c7, ft_s0p13c1, ft_s0p13c2, ft_s0p5c3, ft_s0p13c5, ft_s0p9c6, ft_s0p5c7, ft_s0p5c4
ft_s0f34:
	.word ft_s0p14c7, ft_s0p13c1, ft_s0p14c2, ft_s0p6c3, ft_s0p13c5, ft_s0p10c6, ft_s0p14c7, ft_s0p6c4
ft_s0f35:
	.word ft_s0p5c7, ft_s0p13c1, ft_s0p13c2, ft_s0p7c3, ft_s0p13c5, ft_s0p9c6, ft_s0p5c7, ft_s0p7c4
ft_s0f36:
	.word ft_s0p52c0, ft_s0p16c1, ft_s0p16c2, ft_s0p4c3, ft_s0p16c5, ft_s0p12c6, ft_s0p16c7, ft_s0p4c4
ft_s0f37:
	.word ft_s0p9c7, ft_s0p16c1, ft_s0p17c2, ft_s0p5c3, ft_s0p17c5, ft_s0p13c6, ft_s0p9c7, ft_s0p5c4
ft_s0f38:
	.word ft_s0p16c7, ft_s0p16c1, ft_s0p16c2, ft_s0p6c3, ft_s0p17c5, ft_s0p14c6, ft_s0p16c7, ft_s0p6c4
ft_s0f39:
	.word ft_s0p11c7, ft_s0p16c1, ft_s0p17c2, ft_s0p7c3, ft_s0p17c5, ft_s0p15c6, ft_s0p11c7, ft_s0p7c4
ft_s0f40:
	.word ft_s0p0c0, ft_s0p12c1, ft_s0p0c2, ft_s0p8c3, ft_s0p20c5, ft_s0p16c6, ft_s0p20c7, ft_s0p8c4
ft_s0f41:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p9c3, ft_s0p13c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f42:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p10c3, ft_s0p13c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f43:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p11c3, ft_s0p13c5, ft_s0p0c4, ft_s0p0c4, ft_s0p11c4
ft_s0f44:
	.word ft_s0p0c0, ft_s0p24c1, ft_s0p0c2, ft_s0p12c3, ft_s0p24c5, ft_s0p0c0, ft_s0p24c7, ft_s0p8c4
ft_s0f45:
	.word ft_s0p0c4, ft_s0p25c1, ft_s0p0c4, ft_s0p13c3, ft_s0p25c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f46:
	.word ft_s0p0c4, ft_s0p25c5, ft_s0p0c4, ft_s0p14c3, ft_s0p24c1, ft_s0p0c4, ft_s0p0c4, ft_s0p14c4
ft_s0f47:
	.word ft_s0p12c0, ft_s0p20c1, ft_s0p36c2, ft_s0p16c3, ft_s0p28c5, ft_s0p0c0, ft_s0p28c7, ft_s0p8c4
ft_s0f48:
	.word ft_s0p0c4, ft_s0p21c1, ft_s0p0c4, ft_s0p17c3, ft_s0p22c1, ft_s0p0c4, ft_s0p29c7, ft_s0p0c4
ft_s0f49:
	.word ft_s0p0c4, ft_s0p22c1, ft_s0p0c4, ft_s0p18c3, ft_s0p30c5, ft_s0p0c4, ft_s0p30c7, ft_s0p14c4
ft_s0f50:
	.word ft_s0p16c0, ft_s0p24c1, ft_s0p40c2, ft_s0p56c3, ft_s0p24c5, ft_s0p0c0, ft_s0p40c7, ft_s0p8c4
ft_s0f51:
	.word ft_s0p0c4, ft_s0p25c1, ft_s0p0c4, ft_s0p17c3, ft_s0p25c5, ft_s0p0c4, ft_s0p37c7, ft_s0p0c4
ft_s0f52:
	.word ft_s0p18c0, ft_s0p25c5, ft_s0p0c4, ft_s0p58c3, ft_s0p24c1, ft_s0p0c4, ft_s0p36c7, ft_s0p42c4
ft_s0f53:
	.word ft_s0p48c0, ft_s0p28c1, ft_s0p20c2, ft_s0p20c3, ft_s0p32c5, ft_s0p8c6, ft_s0p32c7, ft_s0p16c4
ft_s0f54:
	.word ft_s0p5c7, ft_s0p29c1, ft_s0p21c2, ft_s0p21c3, ft_s0p30c1, ft_s0p9c6, ft_s0p29c7, ft_s0p17c4
ft_s0f55:
	.word ft_s0p58c0, ft_s0p30c1, ft_s0p22c2, ft_s0p22c3, ft_s0p34c5, ft_s0p22c6, ft_s0p34c7, ft_s0p18c4
ft_s0f56:
	.word ft_s0p52c0, ft_s0p32c1, ft_s0p24c2, ft_s0p20c3, ft_s0p36c5, ft_s0p24c6, ft_s0p36c7, ft_s0p16c4
ft_s0f57:
	.word ft_s0p9c7, ft_s0p33c1, ft_s0p25c2, ft_s0p21c3, ft_s0p34c1, ft_s0p25c6, ft_s0p37c7, ft_s0p17c4
ft_s0f58:
	.word ft_s0p62c0, ft_s0p34c1, ft_s0p26c2, ft_s0p26c3, ft_s0p32c1, ft_s0p26c6, ft_s0p38c7, ft_s0p22c4
ft_s0f59:
	.word ft_s0p64c0, ft_s0p28c1, ft_s0p20c2, ft_s0p20c3, ft_s0p40c5, ft_s0p8c6, ft_s0p32c7, ft_s0p16c4
ft_s0f60:
	.word ft_s0p65c0, ft_s0p29c1, ft_s0p21c2, ft_s0p21c3, ft_s0p30c1, ft_s0p9c6, ft_s0p29c7, ft_s0p17c4
ft_s0f61:
	.word ft_s0p66c0, ft_s0p30c1, ft_s0p22c2, ft_s0p22c3, ft_s0p34c5, ft_s0p22c6, ft_s0p34c7, ft_s0p18c4
ft_s0f62:
	.word ft_s0p68c0, ft_s0p32c1, ft_s0p24c2, ft_s0p20c3, ft_s0p36c5, ft_s0p24c6, ft_s0p36c7, ft_s0p16c4
ft_s0f63:
	.word ft_s0p69c0, ft_s0p33c1, ft_s0p25c2, ft_s0p21c3, ft_s0p34c1, ft_s0p25c6, ft_s0p37c7, ft_s0p17c4
ft_s0f64:
	.word ft_s0p70c0, ft_s0p34c1, ft_s0p26c2, ft_s0p26c3, ft_s0p32c1, ft_s0p26c6, ft_s0p38c7, ft_s0p22c4
ft_s0f65:
	.word ft_s0p48c0, ft_s0p36c1, ft_s0p28c2, ft_s0p44c3, ft_s0p44c5, ft_s0p8c6, ft_s0p32c7, ft_s0p16c4
ft_s0f66:
	.word ft_s0p5c7, ft_s0p21c1, ft_s0p29c2, ft_s0p45c3, ft_s0p22c1, ft_s0p9c6, ft_s0p29c7, ft_s0p17c4
ft_s0f67:
	.word ft_s0p58c0, ft_s0p22c1, ft_s0p30c2, ft_s0p46c3, ft_s0p30c5, ft_s0p22c6, ft_s0p34c7, ft_s0p18c4
ft_s0f68:
	.word ft_s0p52c0, ft_s0p24c1, ft_s0p32c2, ft_s0p44c3, ft_s0p24c5, ft_s0p24c6, ft_s0p36c7, ft_s0p16c4
ft_s0f69:
	.word ft_s0p9c7, ft_s0p25c1, ft_s0p33c2, ft_s0p45c3, ft_s0p25c5, ft_s0p25c6, ft_s0p37c7, ft_s0p17c4
ft_s0f70:
	.word ft_s0p62c0, ft_s0p25c5, ft_s0p34c2, ft_s0p50c3, ft_s0p24c1, ft_s0p26c6, ft_s0p38c7, ft_s0p22c4
ft_s0f71:
	.word ft_s0p48c0, ft_s0p36c1, ft_s0p28c2, ft_s0p44c3, ft_s0p28c5, ft_s0p8c6, ft_s0p32c7, ft_s0p16c4
ft_s0f72:
	.word ft_s0p5c7, ft_s0p21c1, ft_s0p29c2, ft_s0p45c3, ft_s0p22c1, ft_s0p9c6, ft_s0p29c7, ft_s0p17c4
ft_s0f73:
	.word ft_s0p58c0, ft_s0p22c1, ft_s0p30c2, ft_s0p46c3, ft_s0p30c5, ft_s0p22c6, ft_s0p34c7, ft_s0p18c4
ft_s0f74:
	.word ft_s0p52c0, ft_s0p24c1, ft_s0p32c2, ft_s0p44c3, ft_s0p24c5, ft_s0p24c6, ft_s0p36c7, ft_s0p16c4
ft_s0f75:
	.word ft_s0p9c7, ft_s0p25c1, ft_s0p33c2, ft_s0p45c3, ft_s0p25c5, ft_s0p25c6, ft_s0p37c7, ft_s0p17c4
ft_s0f76:
	.word ft_s0p62c0, ft_s0p25c5, ft_s0p34c2, ft_s0p50c3, ft_s0p24c1, ft_s0p26c6, ft_s0p38c7, ft_s0p22c4
ft_s0f77:
	.word ft_s0p0c0, ft_s0p36c1, ft_s0p0c2, ft_s0p28c3, ft_s0p28c5, ft_s0p16c6, ft_s0p20c7, ft_s0p8c4
ft_s0f78:
	.word ft_s0p0c4, ft_s0p21c1, ft_s0p0c4, ft_s0p29c3, ft_s0p22c1, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f79:
	.word ft_s0p0c4, ft_s0p22c1, ft_s0p0c4, ft_s0p30c3, ft_s0p30c5, ft_s0p0c4, ft_s0p0c4, ft_s0p14c4
ft_s0f80:
	.word ft_s0p0c0, ft_s0p16c1, ft_s0p0c2, ft_s0p32c3, ft_s0p16c5, ft_s0p0c0, ft_s0p48c7, ft_s0p8c4
ft_s0f81:
	.word ft_s0p0c4, ft_s0p16c1, ft_s0p0c4, ft_s0p33c3, ft_s0p17c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f82:
	.word ft_s0p0c4, ft_s0p16c1, ft_s0p0c4, ft_s0p34c3, ft_s0p17c5, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f83:
	.word ft_s0p0c4, ft_s0p16c1, ft_s0p0c4, ft_s0p35c3, ft_s0p17c5, ft_s0p0c4, ft_s0p0c4, ft_s0p11c4
ft_s0f84:
	.word ft_s0p20c0, ft_s0p12c1, ft_s0p36c2, ft_s0p36c3, ft_s0p20c5, ft_s0p0c0, ft_s0p4c7, ft_s0p8c4
ft_s0f85:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p1c3, ft_s0p13c5, ft_s0p0c4, ft_s0p5c7, ft_s0p0c4
ft_s0f86:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p38c3, ft_s0p13c5, ft_s0p0c4, ft_s0p4c7, ft_s0p0c4
ft_s0f87:
	.word ft_s0p0c4, ft_s0p13c1, ft_s0p0c4, ft_s0p39c3, ft_s0p13c5, ft_s0p0c4, ft_s0p5c7, ft_s0p11c4
ft_s0f88:
	.word ft_s0p24c0, ft_s0p16c1, ft_s0p40c2, ft_s0p40c3, ft_s0p16c5, ft_s0p0c0, ft_s0p8c7, ft_s0p8c4
ft_s0f89:
	.word ft_s0p0c4, ft_s0p16c1, ft_s0p0c4, ft_s0p1c3, ft_s0p17c5, ft_s0p0c4, ft_s0p9c7, ft_s0p0c4
ft_s0f90:
	.word ft_s0p0c4, ft_s0p16c1, ft_s0p0c4, ft_s0p38c3, ft_s0p17c5, ft_s0p0c4, ft_s0p8c7, ft_s0p0c4
ft_s0f91:
	.word ft_s0p18c0, ft_s0p16c1, ft_s0p0c4, ft_s0p39c3, ft_s0p17c5, ft_s0p0c4, ft_s0p11c7, ft_s0p27c4
ft_s0f92:
	.word ft_s0p48c0, ft_s0p0c1, ft_s0p4c2, ft_s0p52c3, ft_s0p48c5, ft_s0p8c6, ft_s0p12c7, ft_s0p4c4
ft_s0f93:
	.word ft_s0p5c7, ft_s0p1c1, ft_s0p5c2, ft_s0p53c3, ft_s0p1c5, ft_s0p9c6, ft_s0p5c7, ft_s0p5c4
ft_s0f94:
	.word ft_s0p14c7, ft_s0p1c1, ft_s0p6c2, ft_s0p54c3, ft_s0p1c5, ft_s0p10c6, ft_s0p14c7, ft_s0p6c4
ft_s0f95:
	.word ft_s0p5c7, ft_s0p1c1, ft_s0p5c2, ft_s0p55c3, ft_s0p1c5, ft_s0p9c6, ft_s0p5c7, ft_s0p7c4
ft_s0f96:
	.word ft_s0p52c0, ft_s0p4c1, ft_s0p8c2, ft_s0p52c3, ft_s0p4c5, ft_s0p12c6, ft_s0p16c7, ft_s0p28c4
ft_s0f97:
	.word ft_s0p9c7, ft_s0p4c1, ft_s0p9c2, ft_s0p53c3, ft_s0p5c5, ft_s0p13c6, ft_s0p9c7, ft_s0p29c4
ft_s0f98:
	.word ft_s0p16c7, ft_s0p4c1, ft_s0p10c2, ft_s0p54c3, ft_s0p5c5, ft_s0p14c6, ft_s0p16c7, ft_s0p30c4
ft_s0f99:
	.word ft_s0p11c7, ft_s0p4c1, ft_s0p11c2, ft_s0p55c3, ft_s0p5c5, ft_s0p15c6, ft_s0p11c7, ft_s0p31c4
; Bank 0
ft_s0p0c0:
	.byte $7F, $1F

; Bank 0
ft_s0p0c1:
	.byte $E1, $93, $02, $8F, $11, $F8, $27, $01, $2A, $02, $33, $02, $3A, $01, $3D, $02, $3F, $02, $27, $01
	.byte $2A, $02, $33, $02, $3A, $01, $3D, $02, $3F, $02

; Bank 0
ft_s0p0c2:
	.byte $8F, $00, $7F, $1F

; Bank 0
ft_s0p0c3:
	.byte $82, $07, $E4, $A0, $01, $85, $96, $FF, $11, $85, $96, $11, $85, $96, $11, $83, $85, $96, $11, $07

; Bank 0
ft_s0p0c4:
	.byte $00, $1F

; Bank 0
ft_s0p0c5:
	.byte $93, $07, $91, $7F, $F4, $7F, $00, $8F, $11, $00, $03, $E1, $27, $02, $2A, $01, $33, $02, $3A, $02
	.byte $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s0p1c1:
	.byte $E1, $27, $01, $2A, $02, $33, $02, $3A, $01, $3D, $02, $3F, $02, $27, $01, $2A, $02, $33, $02, $3A
	.byte $01, $3D, $02, $3F, $02

; Bank 0
ft_s0p1c3:
	.byte $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $04, $11, $02

; Bank 0
ft_s0p1c5:
	.byte $E1, $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02, $3D, $01, $3F, $02, $27, $02, $2A
	.byte $01, $33, $02, $3A, $02

; Bank 0
ft_s0p2c3:
	.byte $82, $07, $E4, $85, $96, $15, $85, $96, $11, $85, $96, $11, $83, $85, $96, $11, $07

; Bank 0
ft_s0p4c0:
	.byte $91, $7F, $00, $01, $7F, $02, $E0, $8F, $00, $93, $02, $F2, $3D, $00, $3F, $06, $8F, $28, $00, $07
	.byte $8F, $00, $39, $04, $3A, $05

; Bank 0
ft_s0p4c1:
	.byte $E1, $2F, $01, $33, $02, $3A, $02, $3B, $01, $3A, $02, $36, $02, $2F, $01, $33, $02, $3A, $02, $3B
	.byte $01, $3A, $02, $36, $02

; Bank 0
ft_s0p4c2:
	.byte $E0, $8F, $00, $49, $00, $4B, $06, $8F, $28, $00, $07, $8F, $00, $45, $04, $46, $04, $4E, $05

; Bank 0
ft_s0p4c3:
	.byte $E2, $85, $96, $FF, $11, $04, $E4, $11, $02, $85, $96, $11, $04, $11, $02, $E3, $85, $96, $11, $04
	.byte $E4, $11, $02, $85, $96, $11, $04, $11, $02

; Bank 0
ft_s0p4c4:
	.byte $01, $01, $7F, $0D, $02, $01, $7F, $0D

; Bank 0
ft_s0p4c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $3D, $01, $3F, $02, $2F, $02, $33, $01, $3A, $02, $3B, $02, $3A, $01
	.byte $36, $02, $2F, $02, $33, $01, $3A, $02, $3B, $02

; Bank 0
ft_s0p4c7:
	.byte $E1, $FF, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p5c0:
	.byte $E0, $42, $04, $3F, $07, $8F, $28, $00, $07, $8F, $00, $39, $04, $3A, $05

; Bank 0
ft_s0p5c2:
	.byte $E0, $4B, $07, $8F, $28, $00, $07, $8F, $00, $45, $04, $46, $07, $7F, $02

; Bank 0
ft_s0p5c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $04, $11, $02, $E3, $85, $96, $11, $01, $E4
	.byte $11, $02, $11, $02, $85, $96, $11, $04, $E3, $11, $02

; Bank 0
ft_s0p5c4:
	.byte $01, $01, $7F, $0D, $02, $01, $7F, $0A, $02, $02

; Bank 0
ft_s0p5c5:
	.byte $E1, $3A, $01, $36, $02, $2F, $02, $33, $01, $3A, $02, $3B, $02, $3A, $01, $36, $02, $2F, $02, $33
	.byte $01, $3A, $02, $3B, $02

; Bank 0
ft_s0p5c7:
	.byte $E1, $16, $07, $14, $04, $7E, $02, $12, $04, $7E, $02, $11, $04, $7E, $02

; Bank 0
ft_s0p6c0:
	.byte $00, $01, $7F, $07, $E0, $3D, $00, $3F, $01, $8F, $28, $00, $07, $8F, $00, $39, $04, $3A, $05

; Bank 0
ft_s0p6c2:
	.byte $00, $04, $E0, $49, $00, $4B, $01, $8F, $28, $00, $07, $8F, $00, $45, $04, $46, $04, $4E, $05

; Bank 0
ft_s0p6c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $04, $11, $02, $E3, $85, $96, $11, $04, $E4
	.byte $11, $02, $85, $96, $11, $04, $E2, $11, $02

; Bank 0
ft_s0p6c4:
	.byte $01, $01, $7F, $0D, $02, $01, $7F, $0A, $01, $02

; Bank 0
ft_s0p7c3:
	.byte $E2, $85, $96, $11, $01, $E4, $11, $02, $11, $02, $85, $96, $11, $04, $11, $02, $E3, $85, $96, $11
	.byte $01, $E4, $11, $02, $11, $02, $E3, $85, $96, $11, $04, $11, $02

; Bank 0
ft_s0p7c4:
	.byte $01, $01, $7F, $0D, $02, $01, $7F, $05, $02, $01, $7F, $02, $02, $02

; Bank 0
ft_s0p8c0:
	.byte $00, $01, $7F, $02, $E0, $3A, $00, $3B, $06, $8F, $28, $00, $07, $8F, $00, $3D, $04, $3B, $05

; Bank 0
ft_s0p8c2:
	.byte $E0, $46, $00, $47, $06, $8F, $28, $00, $07, $8F, $00, $49, $04, $47, $04, $49, $05

; Bank 0
ft_s0p8c3:
	.byte $E2, $A0, $01, $85, $96, $FF, $11, $07, $E4, $85, $96, $FE, $11, $01, $F0, $11, $05, $85, $96, $FE
	.byte $11, $04, $F1, $11, $02, $85, $96, $FD, $11, $07

; Bank 0
ft_s0p8c4:
	.byte $01, $01, $7F, $1D

; Bank 0
ft_s0p8c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $3A, $01, $36, $02, $27, $02, $2A, $01, $33, $02, $3A, $02, $3D, $01
	.byte $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s0p8c6:
	.byte $E1, $93, $07, $FF, $03, $04, $7E, $02, $03, $04, $7E, $02, $06, $07, $08, $07

; Bank 0
ft_s0p8c7:
	.byte $E1, $FF, $0B, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $16, $07

; Bank 0
ft_s0p9c0:
	.byte $E0, $3D, $04, $3F, $07, $8F, $28, $00, $07, $8F, $00, $3D, $04, $3B, $05

; Bank 0
ft_s0p9c2:
	.byte $E0, $4B, $07, $8F, $28, $00, $07, $8F, $00, $49, $04, $47, $07, $7F, $02

; Bank 0
ft_s0p9c3:
	.byte $E4, $85, $96, $FD, $11, $04, $F2, $11, $02, $85, $96, $FD, $11, $01, $F2, $11, $05, $85, $96, $FC
	.byte $11, $04, $F3, $11, $02, $85, $96, $FB, $11, $04, $FB, $11, $02

; Bank 0
ft_s0p9c6:
	.byte $E1, $0A, $07, $08, $04, $7E, $02, $06, $04, $7E, $02, $05, $04, $7E, $02

; Bank 0
ft_s0p9c7:
	.byte $E1, $17, $07, $16, $04, $7E, $02, $12, $04, $7E, $02, $0F, $04, $7E, $02

; Bank 0
ft_s0p10c0:
	.byte $00, $01, $7F, $02, $E0, $41, $00, $42, $06, $8F, $28, $00, $07, $8F, $00, $44, $04, $42, $05

; Bank 0
ft_s0p10c2:
	.byte $E0, $4D, $00, $4E, $06, $8F, $28, $00, $07, $8F, $00, $50, $04, $4E, $04, $55, $05

; Bank 0
ft_s0p10c3:
	.byte $E4, $85, $96, $FB, $11, $07, $85, $96, $FB, $11, $01, $F4, $11, $05, $85, $96, $FA, $11, $01, $F5
	.byte $11, $02, $F5, $11, $02, $85, $96, $FA, $11, $07

; Bank 0
ft_s0p10c6:
	.byte $E1, $03, $04, $7E, $02, $03, $04, $7E, $02, $06, $07, $08, $07

; Bank 0
ft_s0p11c0:
	.byte $E0, $49, $04, $46, $07, $8F, $28, $00, $07, $8F, $00, $44, $04, $42, $05

; Bank 0
ft_s0p11c2:
	.byte $E0, $52, $07, $8F, $28, $00, $07, $8F, $00, $50, $04, $4E, $07, $7F, $02

; Bank 0
ft_s0p11c3:
	.byte $E4, $85, $96, $F9, $11, $07, $85, $96, $F9, $11, $01, $F6, $11, $05, $85, $96, $F8, $11, $04, $F7
	.byte $11, $02, $E3, $85, $96, $FF, $11, $01, $E4, $F7, $11, $02, $E3, $FF, $11, $02

; Bank 0
ft_s0p11c4:
	.byte $00, $17, $02, $04, $02, $02

; Bank 0
ft_s0p11c7:
	.byte $E1, $17, $07, $19, $04, $7E, $02, $1B, $04, $7E, $02, $16, $04, $7E, $02

; Bank 0
ft_s0p12c0:
	.byte $91, $7F, $00, $03, $E0, $8F, $00, $93, $02, $F2, $25, $00, $27, $06, $8F, $38, $00, $13

; Bank 0
ft_s0p12c1:
	.byte $E1, $93, $02, $F8, $1B, $01, $1E, $02, $27, $02, $2E, $01, $31, $02, $33, $02, $1B, $01, $1E, $02
	.byte $27, $02, $2E, $01, $31, $02, $33, $02

; Bank 0
ft_s0p12c2:
	.byte $8F, $38, $7F, $01, $E0, $33, $02, $7F, $02, $33, $01, $7F, $02, $33, $02, $3A, $01, $3B, $02, $3A
	.byte $02, $36, $01, $33, $05

; Bank 0
ft_s0p12c3:
	.byte $E2, $A0, $07, $85, $96, $FF, $11, $05, $E4, $F7, $11, $01, $85, $96, $F8, $11, $03, $F7, $11, $03
	.byte $85, $96, $F9, $11, $01, $F6, $11, $05, $85, $96, $F9, $11, $03, $FA, $11, $01, $FA, $11, $01

; Bank 0
ft_s0p12c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $3A, $01, $36, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02, $31, $01
	.byte $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02

; Bank 0
ft_s0p12c6:
	.byte $E6, $93, $07, $FF, $0B, $04, $7E, $02, $E1, $03, $04, $7E, $02, $06, $07, $0A, $07

; Bank 0
ft_s0p12c7:
	.byte $E1, $F6, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p13c1:
	.byte $E1, $1B, $01, $1E, $02, $27, $02, $2E, $01, $31, $02, $33, $02, $1B, $01, $1E, $02, $27, $02, $2E
	.byte $01, $31, $02, $33, $02

; Bank 0
ft_s0p13c2:
	.byte $7F, $01, $E0, $33, $02, $7F, $02, $33, $01, $7F, $02, $33, $02, $3D, $01, $3E, $02, $42, $02, $3D
	.byte $01, $3F, $05

; Bank 0
ft_s0p13c3:
	.byte $E4, $85, $96, $FA, $11, $03, $F5, $11, $03, $85, $96, $FB, $11, $01, $F4, $11, $03, $F4, $11, $01
	.byte $85, $96, $FB, $11, $05, $F3, $11, $01, $85, $96, $FC, $11, $03, $FC, $11, $01, $FC, $11, $01

; Bank 0
ft_s0p13c5:
	.byte $E1, $31, $01, $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02, $31, $01, $33, $02, $1B, $02, $1E
	.byte $01, $27, $02, $2E, $02

; Bank 0
ft_s0p13c6:
	.byte $E1, $0B, $07, $0A, $04, $7E, $02, $06, $04, $7E, $02, $03, $04, $7E, $02

; Bank 0
ft_s0p14c2:
	.byte $7F, $01, $E0, $33, $02, $7F, $02, $33, $01, $7F, $02, $33, $02, $3A, $01, $3B, $02, $3A, $02, $36
	.byte $01, $33, $05

; Bank 0
ft_s0p14c3:
	.byte $E4, $85, $96, $FC, $11, $01, $F2, $11, $01, $11, $03, $85, $96, $FD, $11, $05, $F1, $11, $01, $85
	.byte $96, $FD, $11, $03, $F1, $11, $03, $E2, $85, $96, $FF, $11, $03, $E3, $FF, $11, $01, $FF, $11, $01

; Bank 0
ft_s0p14c4:
	.byte $00, $17, $01, $01, $7F, $01, $02, $01, $02, $00, $87, $01, $00, $00

; Bank 0
ft_s0p14c6:
	.byte $E6, $0B, $04, $7E, $02, $E1, $03, $04, $7E, $02, $06, $07, $0A, $07

; Bank 0
ft_s0p14c7:
	.byte $E1, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p15c6:
	.byte $E1, $0B, $07, $0D, $04, $7E, $02, $0F, $04, $7E, $02, $0A, $04, $7E, $02

; Bank 0
ft_s0p16c0:
	.byte $91, $7F, $00, $03, $E0, $8F, $00, $F2, $22, $00, $23, $06, $8F, $38, $00, $13

; Bank 0
ft_s0p16c1:
	.byte $E1, $23, $01, $27, $02, $2E, $02, $2F, $01, $2E, $02, $2A, $02, $23, $01, $27, $02, $2E, $02, $2F
	.byte $01, $2E, $02, $2A, $02

; Bank 0
ft_s0p16c2:
	.byte $7F, $01, $E0, $2F, $02, $7F, $02, $2F, $01, $7F, $02, $2F, $02, $35, $01, $36, $02, $35, $02, $33
	.byte $01, $2F, $05

; Bank 0
ft_s0p16c3:
	.byte $E2, $84, $04, $85, $96, $11, $07, $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $03
	.byte $11, $01, $11, $01

; Bank 0
ft_s0p16c4:
	.byte $01, $01, $7F, $05, $02, $01, $7F, $05, $01, $01, $7F, $05, $02, $01, $7F, $03, $02, $01

; Bank 0
ft_s0p16c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $31, $01, $33, $02, $23, $02, $27, $01, $2E, $02, $2F, $02, $2E, $01
	.byte $2A, $02, $23, $02, $27, $01, $2E, $02, $2F, $02

; Bank 0
ft_s0p16c6:
	.byte $E5, $F8, $03, $04, $7E, $1A

; Bank 0
ft_s0p16c7:
	.byte $E1, $0B, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $16, $07

; Bank 0
ft_s0p17c2:
	.byte $7F, $01, $E0, $2F, $02, $7F, $02, $2F, $01, $7F, $02, $2F, $02, $3A, $01, $3B, $02, $3A, $02, $3B
	.byte $01, $3A, $05

; Bank 0
ft_s0p17c3:
	.byte $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $03, $11, $01, $11
	.byte $01

; Bank 0
ft_s0p17c4:
	.byte $01, $01, $7F, $05, $02, $01, $7F, $05, $01, $01, $7F, $05, $02, $01, $7F, $05

; Bank 0
ft_s0p17c5:
	.byte $E1, $2E, $01, $2A, $02, $23, $02, $27, $01, $2E, $02, $2F, $02, $2E, $01, $2A, $02, $23, $02, $27
	.byte $01, $2E, $02, $2F, $02

; Bank 0
ft_s0p18c0:
	.byte $00, $1E, $8F, $00, $00, $00

; Bank 0
ft_s0p18c3:
	.byte $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $07, $E2, $85, $96, $11, $03, $E3, $11
	.byte $01, $11, $01

; Bank 0
ft_s0p18c4:
	.byte $01, $01, $7F, $05, $02, $01, $7F, $05, $01, $01, $7F, $05, $02, $01, $7F, $01, $02, $01, $02, $00
	.byte $87, $01, $00, $00

; Bank 0
ft_s0p20c0:
	.byte $91, $7F, $00, $04, $E0, $8F, $00, $93, $02, $F2, $25, $00, $27, $06, $8F, $38, $00, $12

; Bank 0
ft_s0p20c1:
	.byte $82, $01, $E1, $93, $02, $F8, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E
	.byte $27, $83, $2E, $01

; Bank 0
ft_s0p20c2:
	.byte $E0, $8F, $00, $49, $00, $4B, $02, $8F, $28, $00, $07, $8F, $00, $45, $07, $46, $03, $8F, $28, $00
	.byte $03, $8F, $00, $4E, $03

; Bank 0
ft_s0p20c3:
	.byte $82, $03, $E2, $85, $96, $11, $E4, $11, $E3, $85, $96, $11, $E4, $11, $E2, $85, $96, $11, $E4, $11
	.byte $E3, $85, $96, $11, $83, $E4, $11, $01, $E3, $11, $01

; Bank 0
ft_s0p20c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $2E, $01, $2A, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02, $31, $01
	.byte $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02

; Bank 0
ft_s0p20c7:
	.byte $E5, $FF, $0F, $04, $7E, $1A

; Bank 0
ft_s0p21c1:
	.byte $82, $01, $E1, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $83, $1E
	.byte $01

; Bank 0
ft_s0p21c2:
	.byte $E0, $4B, $03, $8F, $28, $00, $07, $8F, $00, $45, $07, $46, $03, $8F, $28, $00, $03, $7F, $03

; Bank 0
ft_s0p21c3:
	.byte $82, $03, $E2, $85, $96, $11, $E4, $11, $E3, $85, $96, $11, $E4, $11, $E2, $85, $96, $11, $E4, $11
	.byte $E3, $85, $96, $11, $83, $E4, $11, $03

; Bank 0
ft_s0p22c1:
	.byte $82, $01, $E1, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $83, $33
	.byte $01

; Bank 0
ft_s0p22c2:
	.byte $00, $03, $E0, $8F, $00, $49, $00, $4B, $02, $8F, $28, $00, $03, $8F, $00, $45, $07, $46, $03, $8F
	.byte $28, $00, $03, $8F, $00, $4E, $03

; Bank 0
ft_s0p22c3:
	.byte $82, $03, $E2, $85, $96, $11, $E4, $11, $E3, $85, $96, $11, $E4, $11, $E2, $85, $96, $11, $E4, $11
	.byte $E3, $85, $96, $11, $83, $11, $01, $11, $01

; Bank 0
ft_s0p22c4:
	.byte $01, $01, $7F, $05, $02, $01, $7F, $05, $01, $01, $7F, $05, $02, $01, $02, $01, $02, $01, $02, $00
	.byte $87, $01, $00, $00

; Bank 0
ft_s0p22c6:
	.byte $E1, $0F, $04, $7E, $02, $09, $04, $7E, $02, $0A, $07, $12, $07

; Bank 0
ft_s0p24c0:
	.byte $91, $7F, $00, $04, $E0, $8F, $00, $F2, $22, $00, $23, $06, $8F, $38, $00, $12

; Bank 0
ft_s0p24c1:
	.byte $82, $01, $E1, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $83, $2F
	.byte $01

; Bank 0
ft_s0p24c2:
	.byte $E0, $46, $00, $47, $02, $8F, $28, $00, $07, $8F, $00, $49, $07, $47, $03, $8F, $28, $00, $03, $8F
	.byte $00, $49, $03

; Bank 0
ft_s0p24c5:
	.byte $82, $01, $E1, $31, $33, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $83, $27
	.byte $01

; Bank 0
ft_s0p24c6:
	.byte $E6, $FF, $0B, $04, $7E, $02, $E5, $03, $04, $7E, $02, $06, $07, $0A, $07

; Bank 0
ft_s0p24c7:
	.byte $E5, $FF, $0B, $03, $7E, $1B

; Bank 0
ft_s0p25c1:
	.byte $82, $01, $E1, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $83, $27
	.byte $01

; Bank 0
ft_s0p25c2:
	.byte $E0, $4B, $03, $8F, $28, $00, $07, $8F, $00, $49, $07, $47, $03, $8F, $28, $00, $03, $7F, $03

; Bank 0
ft_s0p25c5:
	.byte $82, $01, $E1, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $83, $2A
	.byte $01

; Bank 0
ft_s0p25c6:
	.byte $E5, $0B, $07, $0A, $04, $7E, $02, $06, $04, $7E, $02, $03, $04, $7E, $02

; Bank 0
ft_s0p26c2:
	.byte $E0, $8F, $00, $4D, $00, $4E, $02, $8F, $28, $00, $07, $82, $03, $8F, $00, $50, $4E, $55, $52, $83
	.byte $8F, $28, $00, $03

; Bank 0
ft_s0p26c3:
	.byte $82, $03, $E2, $85, $96, $11, $E4, $11, $E3, $85, $96, $11, $E4, $11, $E2, $85, $96, $11, $E4, $11
	.byte $82, $01, $E3, $85, $96, $11, $11, $11, $83, $11, $01

; Bank 0
ft_s0p26c6:
	.byte $E6, $0B, $04, $7E, $02, $E5, $0B, $04, $7E, $02, $0A, $07, $0E, $07

; Bank 0
ft_s0p27c4:
	.byte $00, $17, $02, $02, $7F, $01, $02, $02

; Bank 0
ft_s0p28c1:
	.byte $82, $01, $E1, $93, $02, $F8, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A, $3D, $3F, $27, $2A
	.byte $33, $83, $3A, $01

; Bank 0
ft_s0p28c2:
	.byte $82, $01, $8F, $38, $7F, $E0, $33, $7F, $33, $7F, $33, $7F, $33, $3A, $3B, $3A, $36, $83, $33, $03
	.byte $7F, $01, $33, $01

; Bank 0
ft_s0p28c3:
	.byte $E2, $A0, $07, $85, $96, $FF, $11, $05, $E4, $F0, $11, $01, $85, $96, $FE, $11, $03, $F1, $11, $03
	.byte $85, $96, $FD, $11, $01, $F1, $11, $05, $85, $96, $FD, $11, $03, $FC, $11, $01, $FC, $11, $01

; Bank 0
ft_s0p28c4:
	.byte $01, $01, $7F, $0D, $02, $02, $7F, $0C

; Bank 0
ft_s0p28c5:
	.byte $82, $01, $E1, $93, $07, $91, $7F, $F4, $2E, $2A, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E
	.byte $31, $33, $1B, $83, $1E, $01

; Bank 0
ft_s0p28c7:
	.byte $E5, $FF, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p29c1:
	.byte $82, $01, $E1, $3D, $3F, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A, $3D, $3F, $27, $83, $2A
	.byte $01

; Bank 0
ft_s0p29c2:
	.byte $82, $01, $7F, $E0, $33, $7F, $33, $7F, $33, $7F, $33, $3D, $3E, $42, $3D, $83, $3F, $03, $7F, $01
	.byte $3F, $01

; Bank 0
ft_s0p29c3:
	.byte $E4, $85, $96, $FC, $11, $03, $F3, $11, $03, $85, $96, $FC, $11, $01, $F3, $11, $03, $F3, $11, $01
	.byte $85, $96, $FB, $11, $05, $F4, $11, $01, $85, $96, $FA, $11, $03, $FA, $11, $01, $FA, $11, $01

; Bank 0
ft_s0p29c4:
	.byte $01, $01, $7F, $0D, $02, $02, $7F, $09, $02, $02

; Bank 0
ft_s0p29c7:
	.byte $E5, $16, $07, $14, $04, $7E, $02, $12, $04, $7E, $02, $11, $04, $7E, $02

; Bank 0
ft_s0p30c1:
	.byte $82, $01, $E1, $33, $3A, $3D, $3F, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A, $3D, $83, $3F
	.byte $01

; Bank 0
ft_s0p30c2:
	.byte $82, $01, $7F, $E0, $33, $7F, $33, $7F, $33, $7F, $33, $3A, $3B, $3A, $36, $83, $33, $03, $7F, $01
	.byte $33, $01

; Bank 0
ft_s0p30c3:
	.byte $E4, $85, $96, $F9, $11, $01, $F5, $11, $05, $85, $96, $F9, $11, $05, $F6, $11, $01, $85, $96, $F9
	.byte $11, $03, $F6, $11, $03, $82, $01, $E2, $85, $96, $FF, $11, $E4, $F7, $11, $E3, $FF, $11, $83, $FF
	.byte $11, $01

; Bank 0
ft_s0p30c4:
	.byte $01, $01, $7F, $0D, $02, $02, $7F, $09, $01, $01, $7F, $00

; Bank 0
ft_s0p30c5:
	.byte $82, $01, $E1, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $83, $2E
	.byte $01

; Bank 0
ft_s0p30c7:
	.byte $E5, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p31c4:
	.byte $01, $01, $7F, $0D, $02, $02, $7F, $04, $02, $02, $7F, $01, $02, $01, $86, $11, $00, $00

; Bank 0
ft_s0p32c1:
	.byte $82, $01, $E1, $2F, $33, $3A, $3B, $3A, $36, $2F, $33, $3A, $3B, $3A, $36, $2F, $33, $3A, $83, $3B
	.byte $01

; Bank 0
ft_s0p32c2:
	.byte $82, $01, $8F, $38, $7F, $E0, $2F, $7F, $2F, $7F, $2F, $7F, $2F, $35, $36, $35, $33, $83, $2F, $03
	.byte $7F, $01, $2F, $01

; Bank 0
ft_s0p32c3:
	.byte $E2, $A0, $01, $85, $96, $FF, $11, $07, $E4, $85, $96, $F8, $11, $01, $F7, $11, $05, $85, $96, $F8
	.byte $11, $04, $F6, $11, $02, $85, $96, $F9, $11, $07

; Bank 0
ft_s0p32c5:
	.byte $82, $01, $E1, $93, $07, $91, $7F, $F4, $2E, $2A, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A
	.byte $3D, $3F, $27, $83, $2A, $01

; Bank 0
ft_s0p32c7:
	.byte $E5, $F6, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p33c1:
	.byte $82, $01, $E1, $3A, $36, $2F, $33, $3A, $3B, $3A, $36, $2F, $33, $3A, $3B, $3A, $36, $2F, $83, $33
	.byte $01

; Bank 0
ft_s0p33c2:
	.byte $82, $01, $7F, $E0, $2F, $7F, $2F, $7F, $2F, $7F, $2F, $3A, $3B, $3A, $3B, $83, $3A, $03, $7F, $01
	.byte $3A, $01

; Bank 0
ft_s0p33c3:
	.byte $E4, $85, $96, $F9, $11, $04, $F6, $11, $02, $85, $96, $FA, $11, $01, $F5, $11, $05, $85, $96, $FA
	.byte $11, $04, $F4, $11, $02, $85, $96, $FB, $11, $04, $FB, $11, $02

; Bank 0
ft_s0p34c1:
	.byte $82, $01, $E1, $3A, $3B, $3A, $36, $2F, $33, $3A, $3B, $3A, $36, $2F, $33, $3A, $3B, $3A, $83, $36
	.byte $01

; Bank 0
ft_s0p34c2:
	.byte $82, $01, $7F, $E0, $2F, $7F, $2F, $7F, $2F, $7F, $2F, $35, $36, $35, $33, $83, $2F, $03, $7F, $01
	.byte $2F, $01

; Bank 0
ft_s0p34c3:
	.byte $E4, $85, $96, $FB, $11, $07, $85, $96, $FB, $11, $01, $F3, $11, $05, $85, $96, $FC, $11, $01, $F2
	.byte $11, $02, $F2, $11, $02, $85, $96, $FC, $11, $07

; Bank 0
ft_s0p34c5:
	.byte $82, $01, $E1, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $83, $3A
	.byte $01

; Bank 0
ft_s0p34c7:
	.byte $E5, $1B, $04, $7E, $02, $15, $04, $7E, $02, $16, $07, $1E, $07

; Bank 0
ft_s0p35c3:
	.byte $E4, $85, $96, $FD, $11, $07, $85, $96, $FD, $11, $01, $F1, $11, $05, $85, $96, $FE, $11, $04, $F0
	.byte $11, $02, $E3, $85, $96, $FF, $11, $04, $FF, $11, $02

; Bank 0
ft_s0p36c1:
	.byte $82, $01, $E1, $F8, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $83
	.byte $2E, $01

; Bank 0
ft_s0p36c2:
	.byte $E0, $8F, $00, $31, $00, $33, $06, $8F, $38, $00, $17

; Bank 0
ft_s0p36c3:
	.byte $82, $07, $E2, $85, $96, $FF, $11, $E4, $85, $96, $11, $85, $96, $11, $83, $85, $96, $11, $07

; Bank 0
ft_s0p36c5:
	.byte $82, $01, $E1, $3D, $3F, $2F, $33, $3A, $3B, $3A, $36, $2F, $33, $3A, $3B, $3A, $36, $2F, $83, $33
	.byte $01

; Bank 0
ft_s0p36c7:
	.byte $E5, $0B, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $16, $07

; Bank 0
ft_s0p37c7:
	.byte $E5, $17, $07, $16, $04, $7E, $02, $12, $04, $7E, $02, $0F, $04, $7E, $02

; Bank 0
ft_s0p38c3:
	.byte $82, $07, $E4, $85, $96, $11, $85, $96, $11, $85, $96, $11, $83, $85, $96, $11, $07

; Bank 0
ft_s0p38c7:
	.byte $E5, $0B, $04, $7E, $02, $17, $04, $7E, $02, $16, $07, $1A, $07

; Bank 0
ft_s0p39c3:
	.byte $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $07, $E3, $85, $96, $11, $04, $11, $02

; Bank 0
ft_s0p40c2:
	.byte $E0, $8F, $00, $2E, $00, $2F, $06, $8F, $38, $00, $17

; Bank 0
ft_s0p40c3:
	.byte $82, $07, $E2, $85, $96, $11, $E4, $85, $96, $11, $85, $96, $11, $83, $85, $96, $11, $07

; Bank 0
ft_s0p40c5:
	.byte $82, $01, $E1, $93, $07, $91, $7F, $F4, $3A, $36, $27, $2A, $33, $3A, $3D, $3F, $27, $2A, $33, $3A
	.byte $3D, $3F, $27, $83, $2A, $01

; Bank 0
ft_s0p40c7:
	.byte $E5, $FF, $0B, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $16, $07

; Bank 0
ft_s0p42c4:
	.byte $00, $17, $02, $01, $02, $01, $02, $01, $02, $00, $87, $01, $00, $00

; Bank 0
ft_s0p44c3:
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $11, $01
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $E3, $11
	.byte $01

; Bank 0
ft_s0p44c5:
	.byte $82, $01, $E1, $93, $07, $91, $7F, $F4, $3A, $36, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E
	.byte $31, $33, $1B, $83, $1E, $01

; Bank 0
ft_s0p45c3:
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $11, $01
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $11, $01

; Bank 0
ft_s0p46c3:
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $11, $01
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $11, $01, $11, $01

; Bank 0
ft_s0p48c0:
	.byte $E1, $93, $00, $91, $78, $F4, $0F, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $14, $07

; Bank 0
ft_s0p48c5:
	.byte $E1, $93, $07, $91, $7F, $F4, $2E, $01, $2A, $02, $27, $02, $2A, $01, $33, $02, $3A, $02, $3D, $01
	.byte $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s0p48c7:
	.byte $E5, $FF, $0B, $04, $7E, $1A

; Bank 0
ft_s0p50c3:
	.byte $E2, $85, $96, $11, $03, $E4, $11, $01, $11, $01, $E3, $85, $96, $11, $03, $E4, $11, $01, $11, $01
	.byte $E2, $85, $96, $11, $03, $82, $01, $E4, $11, $11, $E3, $85, $96, $11, $11, $11, $83, $11, $01

; Bank 0
ft_s0p51c4:
	.byte $00, $17, $02, $01, $7F, $02, $02, $02

; Bank 0
ft_s0p52c0:
	.byte $E1, $93, $00, $91, $78, $F4, $0B, $04, $7E, $02, $0F, $04, $7E, $02, $12, $07, $16, $07

; Bank 0
ft_s0p52c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $11, $02, $E3, $85, $96, $11
	.byte $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $11, $02

; Bank 0
ft_s0p53c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $11, $02, $E3, $85, $96, $11
	.byte $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $E3, $11, $02

; Bank 0
ft_s0p54c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $11, $02, $E3, $85, $96, $11
	.byte $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $E2, $11, $02

; Bank 0
ft_s0p55c3:
	.byte $E2, $85, $96, $11, $04, $E4, $11, $02, $85, $96, $11, $01, $11, $02, $11, $02, $E3, $85, $96, $11
	.byte $04, $E4, $11, $02, $E3, $85, $96, $11, $01, $E4, $11, $02, $E3, $11, $02

; Bank 0
ft_s0p56c3:
	.byte $E2, $84, $04, $85, $96, $FF, $11, $07, $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11
	.byte $03, $11, $01, $11, $01

; Bank 0
ft_s0p58c0:
	.byte $E1, $1B, $04, $7E, $02, $15, $04, $7E, $02, $16, $07, $1E, $07

; Bank 0
ft_s0p58c3:
	.byte $E4, $85, $96, $11, $07, $85, $96, $11, $07, $85, $96, $11, $07, $82, $01, $E3, $85, $96, $11, $11
	.byte $11, $83, $11, $01

; Bank 0
ft_s0p62c0:
	.byte $E1, $0B, $04, $7E, $02, $17, $04, $7E, $02, $16, $07, $1A, $07

; Bank 0
ft_s0p64c0:
	.byte $E1, $93, $02, $91, $81, $F6, $38, $00, $3A, $0A, $35, $07, $36, $07, $3E, $03

; Bank 0
ft_s0p65c0:
	.byte $E1, $3A, $0B, $35, $07, $36, $07, $93, $00, $91, $78, $F4, $11, $00, $7E, $02

; Bank 0
ft_s0p66c0:
	.byte $E1, $1B, $03, $93, $02, $91, $81, $F6, $38, $00, $3A, $06, $35, $07, $36, $07, $3E, $03

; Bank 0
ft_s0p68c0:
	.byte $E1, $31, $00, $33, $0A, $35, $07, $33, $07, $35, $03

; Bank 0
ft_s0p69c0:
	.byte $E1, $36, $0B, $35, $07, $33, $07, $93, $00, $91, $78, $F4, $0F, $00, $7E, $02

; Bank 0
ft_s0p70c0:
	.byte $E0, $93, $02, $91, $81, $F6, $35, $00, $36, $0A, $38, $03, $36, $03, $3D, $03, $3A, $07

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
	.word ft_s1f19
	.word ft_s1f20
	.word ft_s1f21
	.word ft_s1f22
	.word ft_s1f23
	.word ft_s1f24
	.word ft_s1f25
	.word ft_s1f26
	.word ft_s1f27
	.word ft_s1f28
	.word ft_s1f29
	.word ft_s1f30
	.word ft_s1f31
	.word ft_s1f32
	.word ft_s1f33
	.word ft_s1f34
	.word ft_s1f35
	.word ft_s1f36
	.word ft_s1f37
	.word ft_s1f38
	.word ft_s1f39
	.word ft_s1f40
	.word ft_s1f41
	.word ft_s1f42
	.word ft_s1f43
	.word ft_s1f44
	.word ft_s1f45
	.word ft_s1f46
	.word ft_s1f47
	.word ft_s1f48
	.word ft_s1f49
	.word ft_s1f50
	.word ft_s1f51
	.word ft_s1f52
	.word ft_s1f53
	.word ft_s1f54
	.word ft_s1f55
	.word ft_s1f56
	.word ft_s1f57
	.word ft_s1f58
	.word ft_s1f59
	.word ft_s1f60
	.word ft_s1f61
	.word ft_s1f62
	.word ft_s1f63
	.word ft_s1f64
	.word ft_s1f65
	.word ft_s1f66
	.word ft_s1f67
	.word ft_s1f68
	.word ft_s1f69
	.word ft_s1f70
	.word ft_s1f71
	.word ft_s1f72
	.word ft_s1f73
	.word ft_s1f74
	.word ft_s1f75
	.word ft_s1f76
	.word ft_s1f77
	.word ft_s1f78
	.word ft_s1f79
	.word ft_s1f80
	.word ft_s1f81
	.word ft_s1f82
	.word ft_s1f83
	.word ft_s1f84
	.word ft_s1f85
	.word ft_s1f86
	.word ft_s1f87
	.word ft_s1f88
	.word ft_s1f89
	.word ft_s1f90
	.word ft_s1f91
	.word ft_s1f92
	.word ft_s1f93
	.word ft_s1f94
	.word ft_s1f95
	.word ft_s1f96
	.word ft_s1f97
	.word ft_s1f98
	.word ft_s1f99
ft_s1f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f2:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f3:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f4:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f5:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f6:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f7:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f8:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f9:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f10:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f11:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f12:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f13:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f14:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f15:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f16:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f17:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f18:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f19:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f20:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f21:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f22:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f23:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f24:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f25:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f26:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f27:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f28:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f29:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f30:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f31:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f32:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f33:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f34:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f35:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f36:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f37:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f38:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f39:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f40:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f41:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f42:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f43:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f44:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f45:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f46:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f47:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f48:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f49:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f50:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f51:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f52:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f53:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f54:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f55:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f56:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f57:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f58:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f59:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f60:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f61:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f62:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f63:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f64:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f65:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f66:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f67:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f68:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f69:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f70:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f71:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f72:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f73:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f74:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f75:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f76:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f77:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f78:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f79:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f80:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f81:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f82:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f83:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f84:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f85:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f86:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f87:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f88:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f89:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f90:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f91:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f92:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f93:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f94:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f95:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f96:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f97:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f98:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
ft_s1f99:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s1p2c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0
; Bank 0
ft_s1p0c3:
	.byte $82, $07, $A0, $01, $85, $96, $7F, $85, $96, $00, $85, $96, $00, $83, $85, $96, $00, $07

; Bank 0
ft_s1p1c3:
	.byte $82, $07, $A0, $07, $85, $96, $7F, $85, $96, $00, $85, $96, $00, $83, $85, $96, $00, $07

; Bank 0
ft_s1p2c3:
	.byte $A0, $01, $85, $96, $7F, $07, $85, $96, $00, $07, $85, $96, $00, $07, $85, $96, $00, $06, $86, $11
	.byte $00, $00

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
	.word ft_s2f19
	.word ft_s2f20
	.word ft_s2f21
	.word ft_s2f22
	.word ft_s2f23
	.word ft_s2f24
	.word ft_s2f25
	.word ft_s2f26
	.word ft_s2f27
	.word ft_s2f28
	.word ft_s2f29
	.word ft_s2f30
	.word ft_s2f31
	.word ft_s2f32
	.word ft_s2f33
	.word ft_s2f34
	.word ft_s2f35
	.word ft_s2f36
	.word ft_s2f37
	.word ft_s2f38
	.word ft_s2f39
	.word ft_s2f40
	.word ft_s2f41
	.word ft_s2f42
	.word ft_s2f43
	.word ft_s2f44
	.word ft_s2f45
	.word ft_s2f46
	.word ft_s2f47
	.word ft_s2f48
	.word ft_s2f49
	.word ft_s2f50
	.word ft_s2f51
	.word ft_s2f52
	.word ft_s2f53
	.word ft_s2f54
	.word ft_s2f55
	.word ft_s2f56
	.word ft_s2f57
	.word ft_s2f58
	.word ft_s2f59
	.word ft_s2f60
	.word ft_s2f61
	.word ft_s2f62
	.word ft_s2f63
	.word ft_s2f64
	.word ft_s2f65
	.word ft_s2f66
	.word ft_s2f67
	.word ft_s2f68
	.word ft_s2f69
	.word ft_s2f70
	.word ft_s2f71
	.word ft_s2f72
	.word ft_s2f73
	.word ft_s2f74
	.word ft_s2f75
	.word ft_s2f76
	.word ft_s2f77
	.word ft_s2f78
	.word ft_s2f79
	.word ft_s2f80
	.word ft_s2f81
	.word ft_s2f82
	.word ft_s2f83
	.word ft_s2f84
	.word ft_s2f85
	.word ft_s2f86
	.word ft_s2f87
	.word ft_s2f88
	.word ft_s2f89
	.word ft_s2f90
	.word ft_s2f91
	.word ft_s2f92
	.word ft_s2f93
	.word ft_s2f94
	.word ft_s2f95
	.word ft_s2f96
	.word ft_s2f97
	.word ft_s2f98
	.word ft_s2f99
ft_s2f0:
	.word ft_s2p0c0, ft_s2p0c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f1:
	.word ft_s2p1c0, ft_s2p0c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f2:
	.word ft_s2p1c0, ft_s2p0c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f3:
	.word ft_s2p1c0, ft_s2p0c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f4:
	.word ft_s2p2c0, ft_s2p1c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f5:
	.word ft_s2p3c0, ft_s2p1c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f6:
	.word ft_s2p3c0, ft_s2p1c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f7:
	.word ft_s2p3c0, ft_s2p1c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f8:
	.word ft_s2p4c0, ft_s2p0c1, ft_s2p1c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f9:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p2c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f10:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p1c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f11:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p2c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f12:
	.word ft_s2p2c0, ft_s2p1c1, ft_s2p3c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f13:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p4c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f14:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p3c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f15:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p5c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f16:
	.word ft_s2p4c0, ft_s2p0c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f17:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f18:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f19:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f20:
	.word ft_s2p2c0, ft_s2p1c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f21:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p9c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f22:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f23:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p10c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p10c4
ft_s2f24:
	.word ft_s2p5c0, ft_s2p2c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f25:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f26:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f27:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f28:
	.word ft_s2p7c0, ft_s2p3c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f29:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p9c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f30:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f31:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p10c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p10c4
ft_s2f32:
	.word ft_s2p9c0, ft_s2p2c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f33:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f34:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f35:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f36:
	.word ft_s2p7c0, ft_s2p3c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f37:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p9c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f38:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f39:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p10c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p10c4
ft_s2f40:
	.word ft_s2p9c0, ft_s2p2c1, ft_s2p11c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p11c4
ft_s2f41:
	.word ft_s2p6c0, ft_s2p2c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f42:
	.word ft_s2p6c0, ft_s2p2c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f43:
	.word ft_s2p6c0, ft_s2p2c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f44:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p12c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f45:
	.word ft_s2p11c0, ft_s2p5c1, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f46:
	.word ft_s2p12c0, ft_s2p6c1, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f47:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p1c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f48:
	.word ft_s2p14c0, ft_s2p8c1, ft_s2p2c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f49:
	.word ft_s2p15c0, ft_s2p9c1, ft_s2p1c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f50:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p3c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f51:
	.word ft_s2p11c0, ft_s2p5c1, ft_s2p4c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f52:
	.word ft_s2p12c0, ft_s2p6c1, ft_s2p3c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f53:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p6c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f54:
	.word ft_s2p14c0, ft_s2p8c1, ft_s2p7c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f55:
	.word ft_s2p15c0, ft_s2p9c1, ft_s2p21c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p21c4
ft_s2f56:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p8c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f57:
	.word ft_s2p11c0, ft_s2p5c1, ft_s2p9c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f58:
	.word ft_s2p12c0, ft_s2p6c1, ft_s2p24c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p24c4
ft_s2f59:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p6c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f60:
	.word ft_s2p14c0, ft_s2p8c1, ft_s2p7c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f61:
	.word ft_s2p15c0, ft_s2p9c1, ft_s2p21c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p21c4
ft_s2f62:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p8c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f63:
	.word ft_s2p11c0, ft_s2p5c1, ft_s2p9c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f64:
	.word ft_s2p12c0, ft_s2p6c1, ft_s2p24c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p24c4
ft_s2f65:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p6c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f66:
	.word ft_s2p14c0, ft_s2p8c1, ft_s2p7c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f67:
	.word ft_s2p15c0, ft_s2p9c1, ft_s2p21c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p21c4
ft_s2f68:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p8c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f69:
	.word ft_s2p11c0, ft_s2p5c1, ft_s2p9c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f70:
	.word ft_s2p12c0, ft_s2p6c1, ft_s2p24c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p24c4
ft_s2f71:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p6c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f72:
	.word ft_s2p14c0, ft_s2p8c1, ft_s2p7c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f73:
	.word ft_s2p15c0, ft_s2p9c1, ft_s2p21c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p21c4
ft_s2f74:
	.word ft_s2p10c0, ft_s2p4c1, ft_s2p8c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f75:
	.word ft_s2p11c0, ft_s2p5c1, ft_s2p9c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f76:
	.word ft_s2p12c0, ft_s2p6c1, ft_s2p24c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p24c4
ft_s2f77:
	.word ft_s2p13c0, ft_s2p7c1, ft_s2p25c2, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p11c4
ft_s2f78:
	.word ft_s2p14c0, ft_s2p8c1, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f79:
	.word ft_s2p15c0, ft_s2p9c1, ft_s0p0c0, ft_s1p1c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f80:
	.word ft_s2p7c0, ft_s2p3c1, ft_s2p26c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f81:
	.word ft_s2p8c0, ft_s2p3c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f82:
	.word ft_s2p8c0, ft_s2p3c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f83:
	.word ft_s2p8c0, ft_s2p3c1, ft_s0p0c0, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f84:
	.word ft_s2p9c0, ft_s2p2c1, ft_s2p1c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f85:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p2c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f86:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p1c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f87:
	.word ft_s2p6c0, ft_s2p2c1, ft_s2p2c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f88:
	.word ft_s2p7c0, ft_s2p3c1, ft_s2p3c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f89:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p4c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f90:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p3c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f91:
	.word ft_s2p8c0, ft_s2p3c1, ft_s2p5c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p0c4
ft_s2f92:
	.word ft_s2p16c0, ft_s2p0c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f93:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f94:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p6c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p6c4
ft_s2f95:
	.word ft_s2p1c0, ft_s2p0c1, ft_s2p7c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p7c4
ft_s2f96:
	.word ft_s2p2c0, ft_s2p1c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f97:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p9c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p9c4
ft_s2f98:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p8c2, ft_s1p0c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p8c4
ft_s2f99:
	.word ft_s2p3c0, ft_s2p1c1, ft_s2p10c2, ft_s1p2c3, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s2p10c4
; Bank 0
ft_s2p0c0:
	.byte $93, $02, $91, $7F, $F1, $7F, $00, $8F, $11, $00, $03, $E1, $27, $02, $2A, $01, $33, $02, $3A, $02
	.byte $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s2p0c1:
	.byte $E1, $93, $02, $8F, $11, $F4, $27, $01, $2A, $02, $33, $02, $3A, $01, $3D, $02, $3F, $02, $27, $01
	.byte $2A, $02, $33, $02, $3A, $01, $3D, $02, $3F, $02

; Bank 0
ft_s2p0c4:
	.byte $0F, $1F

; Bank 0
ft_s2p1c0:
	.byte $E1, $93, $02, $91, $7F, $F1, $3D, $00, $8F, $11, $00, $00, $3F, $02, $27, $02, $2A, $01, $33, $02
	.byte $3A, $02, $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s2p1c1:
	.byte $E1, $93, $02, $8F, $11, $F4, $2F, $01, $33, $02, $3A, $02, $3B, $01, $3A, $02, $36, $02, $2F, $01
	.byte $33, $02, $3A, $02, $3B, $01, $3A, $02, $36, $02

; Bank 0
ft_s2p1c2:
	.byte $E1, $1B, $04, $7F, $02, $1B, $04, $7F, $02, $1E, $07, $20, $07

; Bank 0
ft_s2p2c0:
	.byte $E1, $93, $02, $91, $7F, $F1, $3D, $00, $8F, $11, $00, $00, $3F, $02, $2F, $02, $33, $01, $3A, $02
	.byte $3B, $02, $3A, $01, $36, $02, $2F, $02, $33, $01, $3A, $02, $3B, $02

; Bank 0
ft_s2p2c1:
	.byte $E1, $93, $02, $8F, $11, $F4, $1B, $01, $1E, $02, $27, $02, $2E, $01, $31, $02, $33, $02, $1B, $01
	.byte $1E, $02, $27, $02, $2E, $01, $31, $02, $33, $02

; Bank 0
ft_s2p2c2:
	.byte $E1, $22, $07, $20, $04, $7F, $02, $1E, $04, $7F, $02, $1D, $04, $7F, $02

; Bank 0
ft_s2p3c0:
	.byte $E1, $93, $02, $91, $7F, $F1, $3A, $00, $8F, $11, $00, $00, $36, $02, $2F, $02, $33, $01, $3A, $02
	.byte $3B, $02, $3A, $01, $36, $02, $2F, $02, $33, $01, $3A, $02, $3B, $02

; Bank 0
ft_s2p3c1:
	.byte $E1, $93, $02, $8F, $11, $F4, $23, $01, $27, $02, $2E, $02, $2F, $01, $2E, $02, $2A, $02, $23, $01
	.byte $27, $02, $2E, $02, $2F, $01, $2E, $02, $2A, $02

; Bank 0
ft_s2p3c2:
	.byte $E1, $17, $04, $7F, $02, $1B, $04, $7F, $02, $1E, $07, $22, $07

; Bank 0
ft_s2p4c0:
	.byte $E1, $93, $02, $91, $7F, $F1, $3A, $00, $8F, $11, $00, $00, $36, $02, $27, $02, $2A, $01, $33, $02
	.byte $3A, $02, $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s2p4c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A
	.byte $23, $27, $2E, $83, $2F, $01

; Bank 0
ft_s2p4c2:
	.byte $E1, $23, $07, $22, $04, $7F, $02, $1E, $04, $7F, $02, $1B, $04, $7F, $02

; Bank 0
ft_s2p5c0:
	.byte $E1, $93, $02, $91, $7F, $3A, $00, $8F, $11, $00, $00, $36, $02, $1B, $02, $1E, $01, $27, $02, $2E
	.byte $02, $31, $01, $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02

; Bank 0
ft_s2p5c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F
	.byte $2E, $2A, $23, $83, $27, $01

; Bank 0
ft_s2p5c2:
	.byte $E1, $23, $07, $25, $04, $7F, $02, $27, $04, $7F, $02, $22, $04, $7F, $02

; Bank 0
ft_s2p6c0:
	.byte $E1, $93, $02, $91, $7F, $31, $00, $8F, $11, $00, $00, $33, $02, $1B, $02, $1E, $01, $27, $02, $2E
	.byte $02, $31, $01, $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02

; Bank 0
ft_s2p6c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $2E, $2F, $2E, $2A, $23, $27, $2E, $2F, $2E, $2A, $23, $27
	.byte $2E, $2F, $2E, $83, $2A, $01

; Bank 0
ft_s2p6c2:
	.byte $E1, $0F, $04, $7F, $02, $0F, $04, $7F, $02, $12, $07, $14, $07

; Bank 0
ft_s2p6c4:
	.byte $04, $04, $0E, $02, $04, $04, $0E, $02, $06, $07, $07, $07

; Bank 0
ft_s2p7c0:
	.byte $E1, $93, $02, $91, $7F, $31, $00, $8F, $11, $00, $00, $33, $02, $23, $02, $27, $01, $2E, $02, $2F
	.byte $02, $2E, $01, $2A, $02, $23, $02, $27, $01, $2E, $02, $2F, $02

; Bank 0
ft_s2p7c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33
	.byte $1B, $1E, $27, $83, $2E, $01

; Bank 0
ft_s2p7c2:
	.byte $E1, $16, $07, $14, $04, $7F, $02, $12, $04, $7F, $02, $11, $04, $7F, $02

; Bank 0
ft_s2p7c4:
	.byte $09, $07, $07, $04, $0E, $02, $06, $04, $0E, $02, $05, $04, $0E, $02

; Bank 0
ft_s2p8c0:
	.byte $E1, $93, $02, $91, $7F, $2E, $00, $8F, $11, $00, $00, $2A, $02, $23, $02, $27, $01, $2E, $02, $2F
	.byte $02, $2E, $01, $2A, $02, $23, $02, $27, $01, $2E, $02, $2F, $02

; Bank 0
ft_s2p8c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E, $27, $2E
	.byte $31, $33, $1B, $83, $1E, $01

; Bank 0
ft_s2p8c2:
	.byte $E1, $0B, $04, $7F, $02, $0F, $04, $7F, $02, $12, $07, $16, $07

; Bank 0
ft_s2p8c4:
	.byte $0A, $04, $0E, $02, $04, $04, $0E, $02, $06, $07, $09, $07

; Bank 0
ft_s2p9c0:
	.byte $E1, $93, $02, $91, $7F, $2E, $00, $8F, $11, $00, $00, $2A, $02, $1B, $02, $1E, $01, $27, $02, $2E
	.byte $02, $31, $01, $33, $02, $1B, $02, $1E, $01, $27, $02, $2E, $02

; Bank 0
ft_s2p9c1:
	.byte $82, $01, $E1, $93, $02, $8F, $11, $F4, $27, $2E, $31, $33, $1B, $1E, $27, $2E, $31, $33, $1B, $1E
	.byte $27, $2E, $31, $83, $33, $01

; Bank 0
ft_s2p9c2:
	.byte $E1, $17, $07, $16, $04, $7F, $02, $12, $04, $7F, $02, $0F, $04, $7F, $02

; Bank 0
ft_s2p9c4:
	.byte $0A, $07, $09, $04, $0E, $02, $06, $04, $0E, $02, $04, $04, $0E, $02

; Bank 0
ft_s2p10c0:
	.byte $E1, $93, $02, $91, $7F, $31, $00, $8F, $11, $00, $00, $82, $01, $33, $23, $27, $2E, $2F, $2E, $2A
	.byte $23, $27, $2E, $2F, $2E, $2A, $23, $83, $27, $01

; Bank 0
ft_s2p10c2:
	.byte $E1, $17, $07, $19, $04, $7F, $02, $1B, $04, $7F, $02, $16, $04, $7F, $02

; Bank 0
ft_s2p10c4:
	.byte $0A, $07, $0B, $04, $0E, $02, $0C, $04, $0E, $02, $09, $04, $0E, $02

; Bank 0
ft_s2p11c0:
	.byte $E1, $93, $02, $91, $7F, $2E, $00, $8F, $11, $00, $00, $82, $01, $2F, $2E, $2A, $23, $27, $2E, $2F
	.byte $2E, $2A, $23, $27, $2E, $2F, $2E, $83, $2A, $01

; Bank 0
ft_s2p11c2:
	.byte $E5, $0F, $04, $7F, $1A

; Bank 0
ft_s2p11c4:
	.byte $04, $04, $0E, $1A

; Bank 0
ft_s2p12c0:
	.byte $E1, $93, $02, $91, $7F, $23, $00, $8F, $11, $00, $00, $82, $01, $27, $2E, $2F, $2E, $2A, $23, $27
	.byte $2E, $2F, $2E, $2A, $23, $27, $2E, $83, $2F, $01

; Bank 0
ft_s2p12c2:
	.byte $E1, $17, $03, $7F, $1B

; Bank 0
ft_s2p13c0:
	.byte $E1, $93, $02, $91, $7F, $2E, $00, $8F, $11, $00, $00, $82, $01, $2A, $1B, $1E, $27, $2E, $31, $33
	.byte $1B, $1E, $27, $2E, $31, $33, $1B, $83, $1E, $01

; Bank 0
ft_s2p14c0:
	.byte $E1, $93, $02, $91, $7F, $27, $00, $8F, $11, $00, $00, $82, $01, $2E, $31, $33, $1B, $1E, $27, $2E
	.byte $31, $33, $1B, $1E, $27, $2E, $31, $83, $33, $01

; Bank 0
ft_s2p15c0:
	.byte $E1, $93, $02, $91, $7F, $1B, $00, $8F, $11, $00, $00, $82, $01, $1E, $27, $2E, $31, $33, $1B, $1E
	.byte $27, $2E, $31, $33, $1B, $1E, $27, $83, $2E, $01

; Bank 0
ft_s2p16c0:
	.byte $E1, $93, $02, $91, $7F, $2E, $00, $8F, $11, $00, $00, $2A, $02, $27, $02, $2A, $01, $33, $02, $3A
	.byte $02, $3D, $01, $3F, $02, $27, $02, $2A, $01, $33, $02, $3A, $02

; Bank 0
ft_s2p21c2:
	.byte $E1, $1B, $04, $7F, $02, $15, $04, $7F, $02, $16, $07, $1E, $07

; Bank 0
ft_s2p21c4:
	.byte $0C, $04, $0E, $02, $08, $04, $0E, $02, $09, $07, $0D, $07

; Bank 0
ft_s2p24c2:
	.byte $E1, $0B, $04, $7F, $02, $17, $04, $7F, $02, $16, $07, $1A, $07

; Bank 0
ft_s2p24c4:
	.byte $0A, $04, $0E, $02, $0A, $04, $0E, $02, $09, $07, $03, $07

; Bank 0
ft_s2p25c2:
	.byte $E1, $0F, $04, $7F, $1A

; Bank 0
ft_s2p26c2:
	.byte $E1, $17, $04, $7F, $1A


; DPCM samples (located at DPCM segment)

	.segment "DPCM_0"
	.align 64
ft_sample_0: ; bd01
	.byte $15, $F0, $7F, $F9, $FF, $FF, $FF, $FF, $83, $FB, $05, $02, $08, $04, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $F0, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $E0, $FD, $F7, $EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	.byte $04, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FB, $BF, $EF, $F7, $FD, $F7
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $23, $00, $04, $82, $10, $A2, $10, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $C0, $FD, $F7, $7B, $EF, $DE, $ED, $B6, $DD, $FB, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $40, $00, $41, $10, $21, $45, $22, $89, $24, $92
	.byte $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FE, $7D, $DF, $BD, $BB, $5D
	.byte $DB, $B6, $6D, $5B, $DB, $B6, $DB, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F
	.byte $20, $00, $41, $08, $11, $49, $92, $24, $49, $4A, $4A, $4A, $4A, $92, $24, $04, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $7C, $FF, $7D, $DF, $BB, $BB, $6D, $ED, $D6, $B6, $B6, $D6
	.byte $5A, $AD, $D5, $6A, $AD, $B5, $B6, $DD, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $01, $01, $08, $84, $10, $51, $44, $92, $24, $29, $A9, $94, $4A, $A5, $52, $A9, $54, $52, $12
	.byte $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $D0, $FF, $FE, $DE, $77, $77, $B7
	.byte $75, $5B, $DB, $DA, $5A, $AB, $B5, $6A, $D5, $AA, $6A, $55, $D5, $AA, $5A, $B5, $DA, $F6, $FE, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $01, $81, $20, $08, $11, $11, $25, $49
	.byte $92, $A4, $94, $54, $4A, $A5, $52, $A5, $4A, $55, $2A, $95, $52, $22, $08, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $55

	.align 64

ft_sample_1: ; sd08
	.byte $61, $37, $83, $27, $0C, $72, $FE, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF
	.byte $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F
	.byte $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $FC, $F7, $F7, $FD, $7F, $E7, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $EE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $1F, $0C, $00, $02, $40
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $C1, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7B, $83, $20, $0C
	.byte $64, $84, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C8, $B7, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $39, $06, $20, $20, $00, $E0, $C0, $00, $00, $00, $00, $00, $00, $00, $91, $FF, $77, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $76, $00, $00, $00, $00, $00, $00, $00, $00, $10, $FB, $FB, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $CF, $0C, $02, $00, $00, $00, $20, $02, $C7, $00, $22, $30, $C3, $3B, $73, $FF, $FB
	.byte $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $8F, $99, $01, $00, $00, $00, $00, $00, $00, $00, $E0, $3C
	.byte $FF, $FF, $FF, $FF, $FF, $7F, $7F, $7F, $61, $00, $00, $00, $00, $C0, $00, $18, $81, $CC, $71, $0E
	.byte $FA, $F7, $FE, $F5, $7F, $FF, $C7, $CE, $98, $CB, $C7, $EC, $21, $03, $04, $00, $08, $00, $00, $10
	.byte $83, $E2, $F2, $FD, $FF, $FF, $FF, $FF, $DF, $FD, $39, $4F, $00, $04, $00, $00, $00, $18, $C0, $88
	.byte $E1, $17, $3E, $FF, $31, $7F, $9F, $9F, $FF, $B9, $E3, $07, $20, $36, $60, $CE, $19, $06, $88, $99
	.byte $61, $00, $00, $B3, $31, $E6, $1B, $FF, $FC, $BF, $FF, $BF, $FF, $41, $8E, $0F, $00, $03, $01, $C0
	.byte $40, $40, $61, $F0, $F8, $38, $CF, $3F, $77, $CE, $1F, $9B, $FF, $F0, $2C, $19, $86, $E1, $18, $84
	.byte $1F, $C6, $30, $1C, $83, $40, $72, $7C, $32, $F8, $D3, $F9, $F9, $8F, $D7, $3F, $F7, $87, $4C, $38
	.byte $08, $03, $44, $86, $98, $84, $64, $C4, $19, $67, $7E, $FC, $E3, $CF, $7F, $E6, $E0, $3E, $33, $03
	.byte $61, $88, $33, $93, $78, $CE, $11, $33, $90, $E6, $18, $CE, $70, $3C, $CE, $F9, $FC, $9E, $67, $7F
	.byte $C6, $A8, $03, $B8, $C0, $C8, $C0, $8C, $98, $1C, $1C, $1E, $B0, $73, $E6, $7F, $EA, $C3, $3B, $3E
	.byte $3E, $33, $83, $23, $30, $1C, $18, $3B, $7E, $C0, $CE, $C3, $70, $C6, $8C, $17, $1E, $F6, $83, $A7
	.byte $13, $C7, $E7, $1D, $99, $5F, $78, $18, $16, $30, $37, $60, $DC, $80, $31, $23, $8E, $33, $76, $33
	.byte $FE, $FE, $9C, $47, $38, $73, $66, $0E, $83, $13, $0F, $18, $9B, $B1, $33, $5C, $07, $8E, $F8, $C4
	.byte $2C, $F7, $98, $E5, $8D, $0D, $3D, $39, $66, $EC, $C1, $89, $4F, $22, $CE, $8C, $71, $92, $C9, $0C
	.byte $AE, $8E, $F3, $B4, $71, $CF, $39, $C3, $8D, $91, $89, $1D, $12, $37, $1C, $26, $59, $D9, $63, $86
	.byte $D9, $C1, $F1, $DC, $38, $AB, $79, $1C, $67, $8E, $19, $63, $1A, $2B, $6E, $B1, $19, $9C, $71, $14
	.byte $67, $1C, $4E, $0E, $CD, $59, $26, $EF, $EC, $F8, $1C, $87, $31, $CD, $8C, $B8, $A1, $A6, $B2, $4C
	.byte $66, $CC, $8C, $E3, $71, $8C, $15, $37, $3C, $67, $1E, $E3, $52, $CE, $4C, $69, $CC, $2C, $AD, $AA
	.byte $AC, $AA, $A2, $52, $4D, $39, $C6, $38, $95, $33, $AB, $B9, $AA, $D6, $39, $E3, $34, $8E, $42, $95
	.byte $99, $AA, $2A, $8B, $99, $AA, $A9, $1C, $AB, $6A, $36, $CD, $B4, $5A, $55, $35, $33, $55, $95, $AA
	.byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $54, $55, $95, $66, $69, $55, $55, $B3, $AA, $5A, $B3, $9C
	.byte $AA, $AA, $54, $A6, $AA, $AA, $A2, $2A, $55, $55, $A5, $AA, $AA, $55, $55, $AD, $AA, $AA, $5A, $55
	.byte $55, $55, $95, $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $52, $55, $55, $B3, $A2, $AA
	.byte $AA, $AA, $AA, $A5, $55, $55, $55, $A9, $AA, $AA, $AA, $AA, $AA, $AA, $54, $55, $55, $55, $55, $B5
	.byte $AA, $AA, $55, $55, $55, $55, $AA, $AA, $AA, $AA, $A2, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
	.byte $AA, $AA, $AA, $AA, $55

	.align 64

ft_sample_2: ; puretri-low-loud-Cs4
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00
	.byte $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $80
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00
	.byte $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $E0
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00
	.byte $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F8
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00
	.byte $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $FC
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00
	.byte $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $07, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00
	.byte $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $C0, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $03, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00
	.byte $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $E0, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00
	.byte $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $3F, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00
	.byte $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $1F, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00
	.byte $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $80, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $07, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00
	.byte $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $01, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00
	.byte $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $7F
	.byte $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00
	.byte $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $3F
	.byte $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00
	.byte $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F
	.byte $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00
	.byte $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03
	.byte $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00
	.byte $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01
	.byte $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
	.byte $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00
	.byte $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00
	.byte $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00
	.byte $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00
	.byte $00

	.align 64

ft_sample_3: ; puretri-low-loud-C4
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F
	.byte $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00
	.byte $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $FC
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00
	.byte $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00
	.byte $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00
	.byte $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $07, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00
	.byte $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $0F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00
	.byte $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00
	.byte $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F
	.byte $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00
	.byte $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $F8
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00
	.byte $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00
	.byte $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00
	.byte $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
	.byte $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00
	.byte $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00
	.byte $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $1F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00
	.byte $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00
	.byte $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F
	.byte $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00
	.byte $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F8
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	.byte $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00
	.byte $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00
	.byte $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00
	.byte $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00
	.byte $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $7F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $3F, $00, $00, $00, $00, $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00
	.byte $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00
	.byte $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F
	.byte $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00
	.byte $00, $00, $00, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $F0
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $07, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01
	.byte $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00
	.byte $00, $00, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $FF, $0F, $00, $00, $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00
	.byte $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00
	.byte $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $80, $FF, $FF
	.byte $FF, $FF, $FF, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $C0, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $FF, $1F, $00, $00, $00, $00, $00, $00, $00, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $00, $00
	.byte $00, $00, $00, $00, $00, $F8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $03, $00, $00, $00, $00, $00, $00
	.byte $00, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $01, $00, $00, $00, $00, $00, $00, $00

	.align 64

ft_sample_4: ; 00.dmc
	.byte $00

	.align 64

