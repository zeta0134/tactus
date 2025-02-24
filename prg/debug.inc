DEBUG_MODE = 1
DEBUG_MESEN_MODE = 1
DEBUG_TIME_WASTE = 0
DEBUG_DISABLE_MUSIC = 1
DEBUG_GOD_MODE = 1

DEBUG_SPAWN_OVERRIDE = 0

DEBUG_FORCE_SEED = 1
DEBUG_SEED = $BCD855CE

; Force a single specific item to always spawn in shops, for testing
DEBUG_SHOP_OVERRIDE = 0
DEBUG_SHOP_ITEM = ITEM_SPELL_AIR

; Force the portal to generate in the spawn chamber, for easier testing
DEBUG_OVERRIDE_PORTAL_CHAMBER = 0

.macro debug_color flags
        .if ::DEBUG_MODE
                lda #(BG_ON | OBJ_ON | BG_CLIP | OBJ_CLIP | flags)
                .if ::DEBUG_MESEN_MODE
                        sta $FEED
                .else
                        sta PPUMASK
                .endif
        .endif
.endmacro

