local Buffer = require("pinvim.buffer")

local M = {}
local clipboard = nil

M.add = function(state, buf_info)
	for i = 1, #state.pins do
		if state.pins[i].path == buf_info.path then
			return
		end
	end
	table.insert(state.pins, buf_info)
end

M.remove = function(state, pos)
	clipboard = state.pins[pos]
	table.remove(state.pins, pos)
end

M.paste = function(state, idx)
	if not clipboard then
		return
	end
	table.insert(state.pins, idx, clipboard)
end

M.exists = function(state, idx)
	if not state.pins[idx] then
		return false
	end
	return true
end

M.get_buffer = function(state, idx)
	if not state.pins[idx] then
		return nil
	end
	return state.pins[idx].buffer
end

M.get_path = function(state, idx)
	if not state.pins[idx] then
		return nil
	end
	return state.pins[idx].path
end

M.clear_buffer = function(state, buf)
	for i = 1, #state.pins do
		if state.pins[i].buffer == buf then
			state.pins[i].buffer = nil
		end
	end
end

M.add_buffer = function(state, buf)
	local buffer_info = Buffer.info()
	for i = 1, #state.pins do
		if state.pins[i].path == buffer_info.path then
			state.pins[i].buffer = buf
			return
		end
	end
end

return M
