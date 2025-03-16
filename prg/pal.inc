.global detect_system_type
.global detect_ppu_type

.global system_type
.global ppu_type

SYSTEM_TYPE_NTSC    = 0
SYSTEM_TYPE_PAL     = 1
SYSTEM_TYPE_DENDY   = 2
SYSTEM_TYPE_UNKNOWN = 3

; Composite PPUs are expected to have, among other things:
; - skipped even/odd dot during the prerender scanline
; - fully working color emphasis (bit order dependent on system type above)
; - extant $2D and $3D greyscale shades
PPU_TYPE_COMPOSITE = 0
; RGB PPUs are expected to have:
; - no skipped even/odd dot
; - cursed color emphasis (one channel set to max) in NTSC bit ordering
; - missing $2D and $3D greyscale shades
PPU_TYPE_RGB       = 1
