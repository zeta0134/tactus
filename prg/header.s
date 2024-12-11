        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $40               ; 64x 16KB PRG-ROM banks = 1024 KB total
        .byte $00               ; 256x 8KB CHR-ROM banks = 2048 KB total
        .byte $A2, $A8          ; Mapper 682 (Rainbow) (also iNes 2.0 specifier)
        .byte $02               ; 
        .byte $10               ; MSB of CHR-ROM (256k)
        ;.byte $B0               ; PRG-NVRAM: 128k (battery backed)
        .byte $90               ; PRG-NVRAM: 32k (battery backed)
        .byte $00               ; CHR-RAM: 32k (shift count: 9)
        .byte $00
        .byte $00
        .byte $00
        .byte $00