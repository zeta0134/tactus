.global FAR_init_torchlight
.global FAR_update_torchlight
.global FAR_draw_torchlight
.global FAR_darken_entire_inactive_torchlight
.global FAR_lighten_entire_inactive_torchlight

.global FAR_reset_torchlight_raster_slide_updater
.global FAR_update_torchlight_over_raster_slide_updater
.global FAR_catchup_and_finalize_torchlight_raster_slide

.global current_torchlight_radius
.global target_torchlight_radius
.global SuppressTorchlight

; this is also the "fully bright" size. we don't have anymore
; lookup tables for a larger radius.
MAXIMUM_TORCHLIGHT_RADIUS = 31