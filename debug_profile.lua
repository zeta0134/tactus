last_cycle_count = 0
current_emphasis_bits = 0
first_beat_frame = false
beat_frame_index = 255 -- waaaaay past the end of the paw paw patch

profiles_this_frame = {}
frames_this_beat = {} 
frames_last_beat = {} 

computed_metrics = {}

color_names = {
  [0]="idle",
  [1]="(red)",
  [2]="(green)",
  [3]="(yellow)",
  [4]="(blue)",
  [5]="(magenta)",
  [6]="(cyan)",
  [7]="(dark)",
  [8]="other",        -- (greyscale)
  [9]="audio",        --  (grey red)
  [10]="battlefield", --  (grey green)
  [11]="misc", -- (grey yellow)
  [12]="player", --  (grey blue)
  [13]="enemies", -- (grey magenta)
  [14]="sprites", --  (grey cyan)
  [15]="(grey dark)", -- (grey dark)
}

display_colors = {
  [0]=0x00101010, -- none
  [1]=0x00882020, -- red
  [2]=0x00208820, -- green
  [3]=0x00888820, -- yellow
  [4]=0x00202088, -- blue
  [5]=0x00882088, -- magenta
  [6]=0x00208888, -- cyan
  [7]=0x00404040, -- dark
  [8]=0x00C0C0C0, -- greyscale
  [9]=0x00FF4040, -- red+grey
  [10]=0x0040FF40, -- green+grey
  [11]=0x00FFFF40, -- yellow+grey
  [12]=0x004040FF, -- blue+grey
  [13]=0x00FF40FF, -- magenta+grey
  [14]=0x0040FFFF, -- cyan+grey
  [15]=0x00808080, -- dark+grey
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
	
	-- safety: if we end up with more than 32 profiles in a frame, bail
	if #profiles_this_frame > 32 then
		return
	end

	local emu_state = emu.getState() 
	local duration = emu_state["cpu.cycleCount"] - last_cycle_count
	last_cycle_count = emu_state["cpu.cycleCount"]
	table.insert(profiles_this_frame, {["color"]=current_emphasis_bits,["duration"]=duration})
end

function frame_start()
  update_input()
  finalize_current_profile()
  frame_name = identify_frame()
  if first_beat_frame == true then
  	computed_metrics = compute_metrics(frames_this_beat)
  	frames_last_beat = frames_this_beat
  	frames_this_beat = {}
  	first_beat_frame = false
  end
  table.insert(frames_this_beat, {["name"]=frame_name,["profiles"]=profiles_this_frame})
  profiles_this_frame = {}
  emu.selectDrawSurface(emu.drawSurface.scriptHud, 2)
  draw_profiles()
  draw_all_metrics()
end

function draw_profiles()
  if graph_state ~= 0 then
  	return
  end
  for i = 1, 12 do
    x_offset = 36
    y_offset = 360 + i * 9
    if i <= #frames_this_beat then
		emu.drawString(x_offset+1, y_offset+1, frames_this_beat[i]["name"], 0x00FFFFFF, 0x20200020)
		draw_timing_bar(x_offset+40, y_offset, frames_this_beat[i]["profiles"])
    elseif i <= #frames_last_beat then
    	emu.drawString(x_offset+1, y_offset+1, frames_last_beat[i]["name"], 0x00E0E0E0, 0x40201020)
		draw_timing_bar(x_offset+40, y_offset, frames_last_beat[i]["profiles"])
    end
  end
end

beat_frame_names = {
  [1]="BEAT!   ",
  [2]="WAIT 1  ",
  [3]="WAIT 2  ",
  [4]="ENEM 1  ",
  [5]="ENEM 2  ",
  [6]="ENEM 3  ",
  [7]="ENEM 4  ",
  [8]="WAIT 3  ",
  [9]="WAIT 4  ",
}

function identify_frame()
  frame_name = "IDLE      " -- sensible default
  if first_beat_frame == true then
    beat_frame_index = 1
  end
  -- we write 0 to the color emphasis state at the end of an idle frame
  if current_emphasis_bits == 0 then
    -- in this case, we have a normal frame and we should tag it AND advance
    if beat_frame_index <= #beat_frame_names then
      frame_name = beat_frame_names[beat_frame_index]
    end
    beat_frame_index = beat_frame_index + 1
  else
    -- this is a LAG frame! Identify it as such, and do NOT advance
    frame_name = "LAG!      "
  end
  return frame_name
end

function cycle_coordinate(cycle, width)
	local frame_length = 29780 -- NTSC frame length, in cycles
	local scaled_cycle = (cycle * width) / frame_length
	if scaled_cycle > width then
	  return width
	end
	return scaled_cycle
end

function draw_timing_rectangle(start_cycle, end_cycle, color, graph_width, graph_height, graph_x, graph_y)
	local startx = cycle_coordinate(start_cycle, graph_width)
	local endx = cycle_coordinate(end_cycle, graph_width)
	emu.drawRectangle(graph_x + startx, graph_y, endx - startx, graph_height, color, true)
end

function draw_timing_bar(pos_x, pos_y, frame_profiles)
	emu.drawRectangle(pos_x, pos_y, 400, 9, 0x00000000, true)
	local start_cycle = 0
	for i,profile in ipairs(frame_profiles) do
		local end_cycle = start_cycle + profile["duration"]
		local segment_color = display_colors[profile["color"]]
		draw_timing_rectangle(start_cycle, end_cycle, segment_color, 398, 7, pos_x + 1, pos_y + 1)
		start_cycle = end_cycle
	end
end

old_panel_key_state = false
old_graphs_key_state = false
metric_state = 0
graph_state = 0

function update_input()
	local panel_key_state = emu.isKeyPressed("C")
	local graphs_key_state = emu.isKeyPressed("V")
	
	if panel_key_state == true and old_panel_key_state == false then
		metric_state = (metric_state + 1) % 5	
	end
	if graphs_key_state == true and old_graphs_key_state == false then
		graph_state = (graph_state + 1) % 2	
	end
	
	old_panel_key_state = panel_key_state
	old_graphs_key_state = graphs_key_state
end

function draw_all_metrics()
    if metric_state == 1 then
		draw_metrics("segment", 10, 10, computed_metrics)
	end
	if metric_state == 2 then
		draw_metrics("frame", 10, 10, computed_metrics)
	end
	if metric_state == 3 then
		draw_metrics("beat", 10, 10, computed_metrics)
	end
	if metric_state == 4 then
		draw_metrics("segment", 10, 10, computed_metrics)
		draw_metrics("frame", 100, 10, computed_metrics)
		draw_metrics("beat", 190, 10, computed_metrics)
	end
end

function draw_metrics(metric_type, pos_x, pos_y, metrics)
	emu.drawRectangle(pos_x, pos_y, 90, 9, 0x20200020, true)
	emu.drawString(pos_x, pos_y, metric_type .. ": ", 0x00FFFFFF, 0xFF000000)
	
	-- sort the profile keys, we aren't complete heathens
	key_names = {}
    for k in pairs(metrics) do table.insert(key_names, k) end
    table.sort(key_names)
    for i, key_name in ipairs(key_names) do
    	local metric = metrics[key_name][metric_type]
    	local display_color = display_colors[metrics[key_name]["color_index"]]
    	metric_pos_y = pos_y + i*36 - 27
    	emu.drawRectangle(pos_x, metric_pos_y, 90, 36, 0x00000000, true)
    	emu.drawRectangle(pos_x, metric_pos_y, 90, 36, display_color | 0xE0000000, true)
    	key_string = string.format(" %s (%s):", key_name, metric["count"])
    	emu.drawString(pos_x, metric_pos_y, key_string, 0x00FFFFFF, 0xFF000000)
    	min_string = string.format("  Min: %s", metric["min"])
    	emu.drawString(pos_x, metric_pos_y+9, min_string, 0x00FFFFFF, 0xFF000000)
    	max_string = string.format("  Max: %s", metric["max"])
    	emu.drawString(pos_x, metric_pos_y+18, max_string, 0x00FFFFFF, 0xFF000000)
    	avg_string = string.format("  Avg: %s", metric["average"])
    	emu.drawString(pos_x, metric_pos_y+27, avg_string, 0x00FFFFFF, 0xFF000000)
    end
end

function compute_metrics(beat_frames)
	color_metrics = {}
	for color = 0,15 do
		local segment_metrics = compute_segment_metrics(beat_frames, color)
		if segment_metrics["count"] > 0 then
			-- todo: beat metrics here too
			frame_metrics = compute_frame_metrics(beat_frames, color)
			beat_metrics = compute_beat_metrics(beat_frames, color)
			color_metrics[color_names[color]] = {["color_index"]=color,["segment"]=segment_metrics,["frame"]=frame_metrics,["beat"]=beat_metrics}
		end
	end
	return color_metrics
end

function compute_segment_metrics(beat_frames, color_index)
    local segment_min = 99999
    local segment_max = 0
    local segment_total = 0
    local segment_count = 0
    local segment_average = 0
	for i,frame in ipairs(beat_frames) do
		for j,profile in ipairs(frame["profiles"]) do
		    if profile["color"] == color_index then
	    		local segment_duration = profile["duration"]
	    		if segment_duration > segment_max then
	    			segment_max = segment_duration
	    		end
	    		if segment_duration < segment_min then
	    			segment_min = segment_duration
	    		end
	    		segment_count = segment_count + 1
	    		segment_total = segment_total + segment_duration
	    	end
		end
	end
	if segment_count > 0 then
		segment_average = math.floor(segment_total / segment_count)
	end
	return {["min"]=segment_min,["max"]=segment_max,["average"]=segment_average,["count"]=segment_count}
end

function compute_frame_metrics(beat_frames, color_index)
    local frame_min = 99999
    local frame_max = 0
    local frame_total = 0
    local frame_count = 0
    local frame_average = 0
	for i,frame in ipairs(beat_frames) do
		local frame_duration = 0
		for j,profile in ipairs(frame["profiles"]) do
		    if profile["color"] == color_index then
	    		local segment_duration = profile["duration"]
	    		frame_duration = frame_duration + segment_duration
	    	end
	    end
	    -- here let's be clever, and only count frames in which this color was active
	    -- (if this total is 0, this block will not be displayed, so this shouldn't be terribly misleading)
	    if frame_duration > 0 then
	    	if frame_duration > frame_max then
		    	frame_max = frame_duration
		    end
		    if frame_duration < frame_min then
		    	frame_min = frame_duration
		    end
		    frame_count = frame_count + 1
		    frame_total = frame_total + frame_duration
	    end
	end
	if frame_count > 0 then
		frame_average = math.floor(frame_total / frame_count)
	end
	return {["min"]=frame_min,["max"]=frame_max,["average"]=frame_average,["count"]=frame_count}
end

historical_beat_metrics = {}

function compute_beat_metrics(beat_frames, color_index)
	local beat_min = 999999999
    local beat_max = 0
    local beat_total = 0
    local beat_count = 0
    local beat_average = 0

    local beat_duration = 0
	for i,frame in ipairs(beat_frames) do
		for j,profile in ipairs(frame["profiles"]) do
		    if profile["color"] == color_index then
	    		local segment_duration = profile["duration"]
	    		beat_duration = beat_duration + segment_duration
	    	end
	    end
	end
	if beat_duration > 0 then
		-- firstly, ensure this color HAS a historical record
		if historical_beat_metrics[color_index] == nil then
			historical_beat_metrics[color_index] = {}
		end
		table.insert(historical_beat_metrics[color_index], beat_duration)
		-- if that made this table larger than 16 beats, fix it
		if #historical_beat_metrics[color_index] > 16 then
			table.remove(historical_beat_metrics[color_index], 1)
		end
		-- now loop over the HISTORICAL table and compute our metrics from there
		for i, historical_beat_duration in ipairs(historical_beat_metrics[color_index]) do
		    if historical_beat_duration > beat_max then
				beat_max = historical_beat_duration
			end
			if historical_beat_duration < beat_min then
				beat_min = historical_beat_duration
			end
			beat_count = beat_count + 1
			beat_total = beat_total + historical_beat_duration
		end
	end
	if beat_count > 0 then
		beat_average = math.floor(beat_total / beat_count)
	end
	return {["min"]=beat_min,["max"]=beat_max,["average"]=beat_average,["count"]=beat_count}
end

emu.addEventCallback(frame_start, emu.eventType.nmi)
emu.addMemoryCallback(ppumask_write, emu.callbackType.write, 0x2001) -- NES mode, reads PPUMASK writes
emu.addMemoryCallback(ppumask_write, emu.callbackType.write, 0xFEED) -- MESEN mode, reads arbitrary ROM writes