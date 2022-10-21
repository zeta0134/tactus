; Credit to blargg for the idea and original implementation, and to PinoBatch
; for helping me to understand the technique in greater detail, and the brilliant
; suggestion to restrict the rate selections to make this play nice with OAM DMA

.export zetasaw_irq, irq_active, irq_enabled, manual_nmi_needed, manual_oam_needed
.import manual_nmi_handler

.segment BHOP_ZP_SEGMENT

table_entry: .res 1
table_pos: .res 1
saw_volume: .res 1

zetasaw_ptr: .res 2
zetasaw_pos: .res 1
zetasaw_volume: .res 1
zetasaw_count: .res 1

irq_enabled: .res 1
irq_active: .res 1
manual_nmi_needed: .res 1
manual_oam_needed: .res 1

.segment BHOP_PLAYER_SEGMENT

zetasaw_irq: ; (7)
      dec irq_active ; (5) signal to NMI that the IRQ routine is in progress
      pha ; (3) save A and Y
      tya ; (2)
      pha ; (3)
      ; decrement the RLE counter
      dec zetasaw_count ; (5)
      ; if this is still positive, simply continue playing the last sample
      bne restart_dmc ; (2) (3t)
      ; otherwise it's time to load the next entry
      ldy zetasaw_pos ; (3)
      lda (zetasaw_ptr), y ; (5)
      bne load_entry ; (2) (3t)
      ; if the count is zero, it's time to reset the sequence. First write the volume
      ; to the PCM level
      lda zetasaw_volume ; (3)
      sta $4011 ; (4)
      ; then reset the postion counter to the beginning
      ldy #0 ; (2)
      lda (zetasaw_ptr), y ; (5)
load_entry:
      sta zetasaw_count ; (3)
      iny ; (2)
      lda (zetasaw_ptr), y ; (5)
      ora #$80 ; (2) set the interrupt flag
      sta $4010 ; (4) set the period + interrupt for this sample
      iny ; (2)
      sty zetasaw_pos ; (3)
restart_dmc:
      lda #$1F ; (2)
      sta $4015 ; (4)
      ; Now for housekeeping.
      ; At this point it is safe for NMI interrupt the IRQ routine
      inc irq_active
      ; If we need to perform a manual NMI, do that now
      bit manual_nmi_needed
      bpl no_nmi_needed
      inc manual_nmi_needed
      jsr manual_nmi_handler ; this should preserve all registers, including X
no_nmi_needed:
      ; Similarly, if NMI asked us to perform OAM DMA, do that here
      bit manual_oam_needed
      bpl no_oam_needed
      lda #$00
      sta $2003 ; OAM ADDR
      lda #$02
      sta $4014 ; OAM DMA
      inc manual_oam_needed
no_oam_needed:
      pla ; (4) restore A and Y
      tay ; (2)
      pla ; (4)
      rti
       ; next period entry

.include "bhop/zetasaw_table.asm"

; TODO: perhaps be less stupid about this

.import all_00_byte
.import all_ff_byte