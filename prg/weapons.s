        .setcpu "6502"

        .include "../build/tile_defs.inc"

        .include "weapons.inc"

.segment "CODE_4"

; TODO: move this to a data bank?
weapon_class_table:
        .word dagger
        .word broadsword
        .word longsword
        .word spear
        .word flail

NONE := $FD
FX_HZ := <SPRITE_TILE_HORIZONTAL_SLASH
FX_VT := <SPRITE_TILE_VERTICAL_SLASH
SFX_HZ := <SPRITE_TILE_HORIZONTAL_SLASH_SFX
SFX_VT := <SPRITE_TILE_VERTICAL_SLASH_SFX

; Programmer notes: try to prefer clockwise update order, for consistency.
; That means single-hit weapons should prioritize the *player's* left

; No update! Sprites stay where they are spawned, even if the player moves later.
; Ideal for simple slashes and strikes.
.proc weapon_update_none
        rts
.endproc

; Weapon sprites should track the player! Ideal for weapons that do not cancel
; the player's movement, so the animation appears to travel appropriately
.proc weapon_update_track_player
        ; TODO
        rts
.endproc

.proc weapon_init_common
        ; TODO
        rts
.endproc

; Daggers are simple weapons: they hit one tile in the direction
; the player is facing, and stop the player on hit:
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

; (Daggers are also single target, but the flag here would be redundant, as their
; patterns only consider a single square.)

dagger:
        ;       Tile, Length
        .byte   <SPRITE_TILE_DAGGER, $01
        ; behavior tables
        .word dagger_north, dagger_east, dagger_south, dagger_west
        ; animation routines
        .word dagger_init_north, dagger_init_east, dagger_init_south, dagger_init_west

dagger_north:
        ;         X,  Y, TileId,        Behavior
        .lobytes  0, -1, SPRITE_WEAPON_DAGGER_DAGGER_NORTH, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1,  0, SPRITE_WEAPON_DAGGER_DAGGER_EAST, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_south:
        ;         X,  Y, TileId, Behavior
        .lobytes  0,  1, SPRITE_WEAPON_DAGGER_DAGGER_SOUTH, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  0, SPRITE_WEAPON_DAGGER_DAGGER_WEST, NONE, (WEAPON_CANCEL_MOVEMENT)


; Daggers have no special behavior; each directional strike sets up a common anim table
.proc dagger_init_north
        ; TODO
        rts
.endproc

.proc dagger_init_east
        ; TODO
        rts
.endproc

.proc dagger_init_south
        ; TODO
        rts
.endproc

.proc dagger_init_west
        ; TODO
        rts
.endproc

; Broadswords hit a wide field of 3 tiles in front of the player. Great
; for crowd control, but poor for escaping, as they are likely to cancel
; movement at inopportune times:
; [ ][ ][ ][ ][ ][ ]
; [ ][*][ ][ ][ ][ ]
; [P][*][ ][ ][ ][ ]
; [ ][*][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

broadsword:
        ;       Tile, Length
        .byte   <SPRITE_TILE_BROADSWORD, $03
        ; behavior tables
        .word broadsword_north, broadsword_east, broadsword_south, broadsword_west
        ; animation routines
        .word broadsword_init_north, broadsword_init_east, broadsword_init_south, broadsword_init_west

broadsword_north:
        ;         X,  Y, TileId, Behavior
        .lobytes -1, -1, SPRITE_TILE_BROADSWORD_NORTH_1, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -1, SPRITE_TILE_BROADSWORD_NORTH_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1, -1, SPRITE_TILE_BROADSWORD_NORTH_3, NONE, (WEAPON_CANCEL_MOVEMENT)

broadsword_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1, -1, SPRITE_TILE_BROADSWORD_EAST_1, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  0, SPRITE_TILE_BROADSWORD_EAST_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  1,  1, SPRITE_TILE_BROADSWORD_EAST_3, NONE, (WEAPON_CANCEL_MOVEMENT)

broadsword_south:
        ;         X,  Y, TileId, Behavior
        .lobytes  1,  1, SPRITE_TILE_BROADSWORD_SOUTH_1, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  1, SPRITE_TILE_BROADSWORD_SOUTH_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  1, SPRITE_TILE_BROADSWORD_SOUTH_3, NONE, (WEAPON_CANCEL_MOVEMENT)

broadsword_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  1, SPRITE_TILE_BROADSWORD_WEST_1, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1,  0, SPRITE_TILE_BROADSWORD_WEST_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -1, -1, SPRITE_TILE_BROADSWORD_WEST_3, NONE, (WEAPON_CANCEL_MOVEMENT)

; Broadswords have no special behavior; each directional strike sets up a common anim table
.proc broadsword_init_north
        ; TODO
        rts
.endproc

.proc broadsword_init_east
        ; TODO
        rts
.endproc

.proc broadsword_init_south
        ; TODO
        rts
.endproc

.proc broadsword_init_west
        ; TODO
        rts
.endproc

; Longswords are like daggers that hit an extra square in front of the player
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

longsword:
        ;       Tile, Length
        .byte   <SPRITE_TILE_LONGSWORD, $02
        ; behavior tables
        .word longsword_north, longsword_east, longsword_south, longsword_west
        ; animation routines
        .word longsword_init_north, longsword_init_east, longsword_init_south, longsword_init_west

longsword_north:
        ;         X,  Y, TileId, Behavior
        .lobytes  0, -1, SPRITE_TILE_LONGSWORD_NORTH_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0, -2, SPRITE_TILE_LONGSWORD_NORTH_1, NONE, (WEAPON_CANCEL_MOVEMENT)

longsword_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1,  0, SPRITE_TILE_LONGSWORD_EAST_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  2,  0, SPRITE_TILE_LONGSWORD_EAST_1, NONE, (WEAPON_CANCEL_MOVEMENT)

longsword_south:
        ;         X,  Y, TileId, Behavior
        .lobytes  0,  1, SPRITE_TILE_LONGSWORD_SOUTH_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes  0,  2, SPRITE_TILE_LONGSWORD_SOUTH_1, NONE, (WEAPON_CANCEL_MOVEMENT)

longsword_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  0, SPRITE_TILE_LONGSWORD_WEST_2, NONE, (WEAPON_CANCEL_MOVEMENT)
        .lobytes -2,  0, SPRITE_TILE_LONGSWORD_WEST_1, NONE, (WEAPON_CANCEL_MOVEMENT)

; Longswords have no special behavior; each directional strike sets up a common anim table
.proc longsword_init_north
        ; TODO
        rts
.endproc

.proc longsword_init_east
        ; TODO
        rts
.endproc

.proc longsword_init_south
        ; TODO
        rts
.endproc

.proc longsword_init_west
        ; TODO
        rts
.endproc

; Spears are almost identical to longswords, except they can only target one enemy
; at a time, prioritizing the enemy closest to the player
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

; Note: on their own, spears aren't unique enough from longswords to necessarily be
; worth including. Ideally they would confer some other benefit, like being able
; to use a shield or something?

spear:
        ;       Tile, Length
        .byte   <SPRITE_TILE_SPEAR, $02
        ; behavior tables
        .word spear_north, spear_east, spear_south, spear_west
        ; animation routines
        .word spear_init_north, spear_init_east, spear_init_south, spear_init_west

spear_north:
        ;         X,  Y, TileId, Behavior
        .lobytes  0, -1, SPRITE_TILE_SPEAR_NORTH_1, SPRITE_TILE_SPEAR_NORTH_2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  0, -2, SPRITE_TILE_SPEAR_NORTH_1, NONE, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1,  0, SPRITE_TILE_SPEAR_EAST_1, SPRITE_TILE_SPEAR_EAST_2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  2,  0, SPRITE_TILE_SPEAR_EAST_1, NONE, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_south:
        ;         X,  Y, TileId, Behavior
        .lobytes  0,  1, SPRITE_TILE_SPEAR_SOUTH_1, SPRITE_TILE_SPEAR_SOUTH_2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes  0,  2, SPRITE_TILE_SPEAR_SOUTH_1, NONE, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

spear_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  0, SPRITE_TILE_SPEAR_WEST_1, SPRITE_TILE_SPEAR_WEST_2, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)
        .lobytes -2,  0, SPRITE_TILE_SPEAR_WEST_1, NONE, (WEAPON_CANCEL_MOVEMENT | WEAPON_SINGLE_TARGET)

; Spears select from one of two animation tables, depending on whether the near
; or far target was struck
.proc spear_init_north
        ; TODO
        rts
.endproc

.proc spear_init_east
        ; TODO
        rts
.endproc

.proc spear_init_south
        ; TODO
        rts
.endproc

.proc spear_init_west
        ; TODO
        rts
.endproc

; Flails have the widest attack pattern, hit a single enemy, and mostly
; do not block movement for the player:
; [ ][1#][ ][ ][ ][ ]
; [ ][3#][ ][ ][ ][ ]
; [P][5*][ ][ ][ ][ ]
; [ ][4#][ ][ ][ ][ ]
; [ ][2#][ ][ ][ ][ ]
; (number = priority, # = player movement allowed, * = player movement blocked)

; Due to permitting player movement, flails encourage keeping distance from enemies
; and attempting to attack them with lateral movement. One can safely attack a single
; enemy directly in front, but if there is an enemy to the side it will take the hit,
; allowing the player to "bonk" into the enemy ahead and take damage. This makes close
; range combat with a flail especially risky.

flail:
        ;       Tile, Length
        .byte   <SPRITE_TILE_FLAIL, $05
        ; behavior tables
        .word flail_north, flail_east, flail_south, flail_west
        ; animation routines
        .word flail_init_north, flail_init_east, flail_init_south, flail_init_west

flail_north:
        ;         X,  Y, TileId, Behavior
        .lobytes -2, -1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  2, -1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes -1, -1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  1, -1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  0, -1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1, -2, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  2, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes  1, -1, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  1, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  0, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_south:
        ;         X,  Y, TileId, Behavior
        .lobytes -2,  1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  2,  1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  1,  1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET)
        .lobytes  0,  1, SPRITE_TILE_FLAIL_HEAD, SFX_HZ, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

flail_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1, -2, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  2, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes -1, -1, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  1, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET)
        .lobytes -1,  0, SPRITE_TILE_FLAIL_HEAD, SFX_VT, (WEAPON_SINGLE_TARGET | WEAPON_CANCEL_MOVEMENT)

; Flails are the most complex by far, choosing from one of 5 animation tables
; depending on which tile was struck.
.proc flail_init_north
        ; TODO
        rts
.endproc

.proc flail_init_east
        ; TODO
        rts
.endproc

.proc flail_init_south
        ; TODO
        rts
.endproc

.proc flail_init_west
        ; TODO
        rts
.endproc