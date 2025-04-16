        .include "../build/tile_defs.inc"        
        .include "_globals.inc"

        .include "dialog.inc"
        .include "localized_text.inc"

; The actual textual data the game will be using, translated
; into the user's selected target language. These are the string
; tables pointed to by the LOCALIZED_STR command, indexed by that
; language's ID. Comments will establish context (for future
; translation efforts) and any requirements, like maximum length,
; that must be adhered to.

; Definitions for actually writing in sitelen pona. Note that we'll almost certainly
; want some tool to automate the conversion.

_A       = $00
_AKESI   = $01
_ALA     = $02
_ALASA   = $03
_ALE     = $04
_ANPA    = $05
_ANTE    = $06
_ANU     = $07
_AWEN    = $08
_E       = $09
_EN      = $0A
_ESUN    = $0B
_IJO     = $0C
_IKE     = $0D
_ILO     = $0E
_INSA    = $0F

_JAKI    = $10
_JAN     = $11
_JELO    = $12
_JO      = $13
_KALA    = $14
_KALAMA  = $15
_KAMA    = $16
_KASI    = $17
_KEN     = $18
_KEPEKEN = $19
_KILI    = $1A
_KIWEN   = $1B
_KO      = $1C
_KON     = $1D
_KULE    = $1E
_KULUPU  = $1F

_S       = $20

_KUTE    = $21
_LA      = $22
_LAPE    = $23
_LASO    = $24
_LAWA    = $25
_LEN     = $26
_LETE    = $27
_LI      = $28
_LILI    = $29
_LINJA   = $2A
_LIPU    = $2B
_LOJE    = $2C
_LON     = $2D
_LUKA    = $2E
_LUKIN   = $2F

_LUPA  = $30
_MA    = $31
_MAMA  = $32
_MANI  = $33
_MELI  = $34
_MI    = $35
_MIJE  = $36
_MOKU  = $37
_MOLI  = $38
_MONSI = $39
_MU    = $3A
_MUN   = $3B
_MUSI  = $3C
_MUTE  = $3D
_NANPA = $3E
_NASA  = $3F

_NASIN  = $40
_NENA   = $41
_NI     = $42
_NIMI   = $43
_NOKA   = $44
_O      = $45
_OLIN   = $46
_ONA    = $47
_OPEN   = $48
_PAKALA = $49
_PALI   = $4A
_PALISA = $4B
_PAN    = $4C
_PANA   = $4D
_PI     = $4E
_PILIN  = $4F

_PIMEJA = $50
_PINI   = $51
_PIPI   = $52
_POKA   = $53
_POKI   = $54
_PONA   = $55
_PU     = $56
_SAMA   = $57
_SELI   = $58
_SELO   = $59
_SEME   = $5A
_SEWI   = $5B
_SIJELO = $5C
_SIKE   = $5D
_SIN    = $5E
_SINA   = $5F

_SINPIN  = $60
_SITELEN = $61
_SONA    = $62
_SOWELI  = $63
_SULI    = $64
_SUNO    = $65
_SUPA    = $66
_SUWI    = $67
_TAN     = $68
_TASO    = $69
_TAWA    = $6A
_TELO    = $6B
_TENPO   = $6C
_TOKI    = $6D
_TOMO    = $6E
_TU      = $6F

_UNPA           = $70
_UTA            = $71
_UTALA          = $72
_WALO           = $73
_WAN            = $74
_WASO           = $75
_WAWA           = $76
_WEKA           = $77
_WILE           = $78
_POKI_NIMI_OPEN = $79
_POKI_NIMI_PINI = $7A
_MIDDLE_DOT     = $7B
_COLON          = $7C
_QUOTE_OPEN     = $7D
_QUOTE_PINI     = $7E

; These are all extended glyphs, and must be fetched with an upper page command byte
_NAMAKO         = $80
_KIN            = $81
_OKO            = $82
_KIPISI         = $83
_LEKO           = $84
_MONSUTA        = $85
_TONSI          = $86
_JASIMA         = $87
_KIJETE         = $88
_SANTAKALU      = $89
_SOKO           = $8A
_MESO           = $8B
_EPIKU          = $8C
_KOKOSILA       = $8D
_LANPAN         = $8E
_N              = $8F

_MISIKEKE       = $90
_MAJUNA         = $91

; ########  ######## ########  ##     ##  ######   
; ##     ## ##       ##     ## ##     ## ##    ##  
; ##     ## ##       ##     ## ##     ## ##        
; ##     ## ######   ########  ##     ## ##   #### 
; ##     ## ##       ##     ## ##     ## ##    ##  
; ##     ## ##       ##     ## ##     ## ##    ##  
; ########  ######## ########   #######   ######   

; Old, testing, not needed, other cliches
;hello_world_localized:
;        .addr hello_world_english
;        .addr hello_world_toki_pona_sitelen_lasina
;        .addr hello_world_toki_pona_sitelen_pona
;hello_world_english:                  .byte D_FONT, FONT_ASCII, "Hello World!", D_RETURN
;hello_world_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "toki a, jan ale o!", D_RETURN
;hello_world_toki_pona_sitelen_pona:   .byte D_FONT, COLOR_SP_WHITE, _TOKI, _A, _S, _JAN, _ALE, _O, D_RETURN

; The actual game script
.include "../build/localization/text_strings.asm"
