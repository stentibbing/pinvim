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

return M
