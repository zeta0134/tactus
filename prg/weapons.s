        .setcpu "6502"

        .include "../build/tile_defs.inc"

        .include "weapons.inc"

; TODO: move this to a data bank. Or maybe colocate it with the player code?
.segment "PRGFIXED_E000"

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
        .word dagger_north, dagger_east, dagger_south, dagger_west

dagger_north:
        ;         X,  Y, TileId,        Behavior
        .lobytes  0, -1, SPRITE_TILE_DAGGER_NORTH, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_east:
        ;         X,  Y, TileId, Behavior
        .lobytes  1,  0, SPRITE_TILE_DAGGER_EAST, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_south:
        ;         X,  Y, TileId, Behavior
        .lobytes  0,  1, SPRITE_TILE_DAGGER_SOUTH, NONE, (WEAPON_CANCEL_MOVEMENT)

dagger_west:
        ;         X,  Y, TileId, Behavior
        .lobytes -1,  0, SPRITE_TILE_DAGGER_WEST, NONE, (WEAPON_CANCEL_MOVEMENT)

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
        .word broadsword_north, broadsword_east, broadsword_south, broadsword_west

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


; Longswords are like daggers that hit an extra square in front of the player
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [P][*][*][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]
; [ ][ ][ ][ ][ ][ ]

longsword:
        ;       Tile, Length
        .byte   <SPRITE_TILE_LONGSWORD, $02
        .word longsword_north, longsword_east, longsword_south, longsword_west

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
        .word spear_north, spear_east, spear_south, spear_west

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
        .word flail_north, flail_east, flail_south, flail_west

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