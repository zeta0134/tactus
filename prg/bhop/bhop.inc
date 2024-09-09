; These functions will be made available to your programs.
; All other symbols reside in the BHOP scope and, by default,
; will not pollute the global namespace.

.import bhop_init, bhop_play
.import bhop_set_module_bank, bhop_set_module_addr
.import bhop_mute_channel, bhop_unmute_channel, blarggsaw_irq, zetasaw_irq

; game specific variables
.importzp current_music_variant, target_music_variant, tempo_adjustment
.import global_attenuation ; UNIMPLEMENTED!

;.import row_counter
.import currently_playing_row, currently_playing_frame