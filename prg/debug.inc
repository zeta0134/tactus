DEBUG_MODE = 0
DEBUG_TIME_WASTE = 0
DEBUG_DISABLE_MUSIC = 0
DEBUG_TEST_FLOOR = 0
DEBUG_GOD_MODE = 0

DEBUG_SEED = 42

.macro debug_color flags
        .if ::DEBUG_MODE
        lda #(BG_ON | OBJ_ON | BG_CLIP | OBJ_CLIP | flags)
        sta PPUMASK
        .endif
.endmacro

