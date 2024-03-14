local first_sample_written = false
local cycles_since_last_sample = 0

SAMPLE_STARVATION_THRESHOLD = 128

function clock_cpu()
	cycles_since_last_sample = cycles_since_last_sample + 1
	if first_sample_written == true and cycles_since_last_sample > SAMPLE_STARVATION_THRESHOLD then
		emu.log("Audio starvation! Pausing NOW!")
		emu.breakExecution()
		first_sample_written = false
	end
end

function write_sample()
	cycles_since_last_sample = 0
	first_sample_written = true
end

emu.addMemoryCallback(clock_cpu, emu.callbackType.read, 0x0000, 0xFFFF)
emu.addMemoryCallback(clock_cpu, emu.callbackType.write, 0x0000, 0xFFFF)
-- the real audio increment happens here:
emu.addMemoryCallback(write_sample, emu.callbackType.write, 0x4011, 0x4011)
-- a fake one happens over here, which we will count for starvation purposes
emu.addMemoryCallback(write_sample, emu.callbackType.write, 0xFF11, 0xFF11)

