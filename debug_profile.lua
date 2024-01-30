last_cycle_count = 0
current_emphasis_bits = 0
first_beat_frame = false

profiles_this_frame = {}
frames_this_beat = {} 
frames_last_beat = {} 

color_names = {
  [0]="idle",
  [1]="(red)",
  [2]="(green)",
  [3]="(yellow)",
  [4]="(blue)",
  [5]="(magenta)",
  [6]="(cyan)",
  [7]="(dark)",
  [8]="other", -- (greyscale)
  [9]="audio", --  (grey red)
  [10]="battlefield", --  (grey green)
  [11]="(grey yellow)",
  [12]="player", --  (grey blue)
  [13]="(grey magenta)",
  [14]="sprites", --  (grey cyan)
  [15]="(grey dark)",
}

function ppumask_write(address, value)
	local new_emphasis_bits = ((value & 0xE0) >> 5) | ((value & 0x01) << 3)
	if new_emphasis_bits ~= current_emphasis_bits then
		finalize_current_profile()
		current_emphasis_bits = new_emphasis_bits
	end
end

function finalize_current_profile()
	if current_emphasis_bits == 12 then
		first_beat_frame = true
	end
	
	-- safety: if we end up with more than 16 profiles in a beat, bail
	if #profiles_this_frame > 16 then
		return
	end

	local emu_state = emu.getState() 
	local duration = emu_state["cpu.cycleCount"] - last_cycle_count
	last_cycle_count = emu_state["cpu.cycleCount"]
	table.insert(profiles_this_frame, {["color"]=current_emphasis_bits,["duration"]=duration})
end

function frame_start()
  finalize_current_profile()
  if first_beat_frame == true then
  	frames_last_beat = frames_this_beat
  	frames_this_beat = {}
  	first_beat_frame = false
  end
  table.insert(frames_this_beat, profiles_this_frame)
  profiles_this_frame = {}
  draw_profiles()
end

function crude_profile_string(frame_profiles)
	local str = ""
	for i,profile in ipairs(frame_profiles) do
		parameter_string = string.format("%s: %s ", color_names[profile["color"]], profile["duration"])
		str = str .. parameter_string
	end
	return str
end

function draw_profiles()
  emu.selectDrawSurface(emu.drawSurface.scriptHud, 2)
  
  for i = 1, 16 do
    y_offset = 10 + i * 10
    if i < #frames_this_beat then
    	parameter_string = crude_profile_string(frames_this_beat[i])
    	emu.drawString(10, y_offset, parameter_string, 0x00FFFFFF, 0x40200020)
    elseif i < #frames_last_beat then
    	parameter_string = crude_profile_string(frames_last_beat[i])
    	emu.drawString(10, y_offset, parameter_string, 0x00FFFFFF, 0x40200020)
    end
  end
end

emu.addEventCallback(frame_start, emu.eventType.nmi)
emu.addMemoryCallback(ppumask_write, emu.callbackType.write, 0x2001)