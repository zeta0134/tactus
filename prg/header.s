        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $04               ; 8x 16KB PRG-ROM banks = 128 KB total
        .byte $00               ; 4x 8KB CHR-ROM banks = 32 KB total
        .byte $C1, $18          ; Mapper 4 (MMC3) w/ battery-backed RAM
        .byte $00               ; 8k of PRG RAM
        .byte $00               ;
        .byte $00
        .byte $09
        .byte $00
        .byte $00
        .byte $00
        .byte $00