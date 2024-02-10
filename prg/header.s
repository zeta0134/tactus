        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $10               ; 16x 16KB PRG-ROM banks = 256 KB total
        .byte $80               ; 0x 8KB CHR-ROM banks = 0 KB total
        .byte $A2, $A8          ; Mapper 682 (Rainbow) (also iNes 2.0 specifier)
        .byte $02               ; 
        .byte $00               ;
        .byte $70               ; PRG-NVRAM: 8k (battery backed)
        .byte $00               ; CHR-RAM: 32k (shift count: 9)
        .byte $00
        .byte $00
        .byte $00
        .byte $00