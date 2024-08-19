fpga_ram_writes = {}

function fpga_ram_written(addr, value)
	table.insert(fpga_ram_writes, addr)
end

function fpga_ram_coordinates(addr)
    local row = (addr >> 5) % 32
    local col = (addr % 32)
	if addr >= 0x5000 and addr < 0x5400 then
		return 0 + col, 0 + row
	end
	if addr >= 0x5400 and addr < 0x5800 then
		return 32 + col, 0 + row
	end
	if addr >= 0x5800 and addr < 0x5C00 then
		return 0 + col, 32 + row
	end
	if addr >= 0x5C00 and addr < 0x6000 then
		return 32 + col, 32 + row
	end
	-- what?
	return 0, 0
end

function fpga_ram_color(addr)
	if addr >= 0x5000 and addr < 0x5800 then
		return 0x40FF4444
	end
	if addr >= 0x5800 and addr < 0x6000 then
		return 0x40FFFF44
	end
	return 0x40FFFFFF
end

function draw_fpga_ram_write(addr)
	local dx, dy = fpga_ram_coordinates(addr)
	local color = fpga_ram_color(addr)
	emu.drawRectangle( 64 + (dx*2), 32 + (dy*2), 2, 2, color, true)
end

function draw_fpga_ram_status()
	emu.drawRectangle( 63, 31, 130, 130, 0xE0FFFFFF, false)
	emu.drawRectangle( 64, 32, 64, 64, 0xC0000000, true)
	emu.drawRectangle(128, 32, 64, 64, 0xB0000000, true)
	emu.drawRectangle( 64, 96, 64, 64, 0xB0000000, true)
	emu.drawRectangle(128, 96, 64, 64, 0xC0000000, true)
	
	for _,addr in pairs(fpga_ram_writes) do
		draw_fpga_ram_write(addr)
	end
	
	fpga_ram_writes = {}
end

emu.addMemoryCallback(fpga_ram_written, emu.callbackType.write, 0x5000, 0x6000)
emu.addEventCallback(draw_fpga_ram_status, emu.eventType.nmi)