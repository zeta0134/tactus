ROOM_FLAG_VISITED            = 0x80 --10000000 -- mostly for minimap purposes
ROOM_FLAG_TREASURE_SPAWNED   = 0x40 --01000000 -- so the player can't infinitely farm
ROOM_FLAG_EXIT_STAIRS        = 0x20 --00100000 -- shows on the minimap, also tells the game engine when to spawn these
ROOM_FLAG_BOSS               = 0x10 --00010000 -- boss rooms have their treasure forced to a key (and, y'know, also spawn tougher enemies)
ROOM_FLAG_CLEARED            = 0x08 --00001000 -- once cleared, a room will not respawn enemies when entered again
ROOM_FLAG_REVEALED           = 0x04 --00000100 -- more explicitly for minimap purposes
ROOM_FLAG_DARK               = 0x02 --00000010 -- activates torchlight radius effect. spookiness is optional

OVERLAY_BASE_X = 184
OVERLAY_BASE_Y = 194

function draw_room_status(x, y, room_flags)
	-- within an 8x8 square, draw a smaller 4x4 region with one corner
	-- lit up per feature we want to track
	if (room_flags & ROOM_FLAG_CLEARED) ~= 0 then
		emu.drawRectangle(x + 2, y + 2, 2, 4, 0x8000FF00)
	end
	if (room_flags & ROOM_FLAG_TREASURE_SPAWNED) ~= 0 then
		emu.drawRectangle(x + 4, y + 2, 2, 4, 0x80FF00FF)
	end
end

function draw_rooms()
	emu.drawRectangle(OVERLAY_BASE_X,OVERLAY_BASE_Y,6*8,4*8,0xD0FF00FF, false)
    emu.drawRectangle(OVERLAY_BASE_X,OVERLAY_BASE_Y,6*8,4*8,0xD0FFFFFF, true)
	label_table = emu.getLabelAddress("room_flags")
	room_flags_address = label_table.address
	for x = 0, 5 do
		for y = 0, 3 do
		    offset = y*6+x
			room_flags = emu.read(room_flags_address+offset, emu.memType.nesDebug)
			draw_room_status(OVERLAY_BASE_X + (x * 8), OVERLAY_BASE_Y + (y * 8), room_flags)
		end
	end
end

emu.addEventCallback(draw_rooms, emu.eventType.nmi)



