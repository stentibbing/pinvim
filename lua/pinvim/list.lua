local Buffer = require("pinvim.buffer")

local M = {}
local clipboard = nil

M.exists = function(state, idx)
	if not state.list[idx] then
		return false
	end
	return true
end

M.exist_by_path = function(state, path)
	for i = 1, #state.list do
		if state.list[i].path == path then
			return true
		end
	end
	return false
end

M.add = function(state, buf_info)
	for i = 1, #state.list do
		if state.list[i].path == buf_info.path then
			return
		end
	end
	table.insert(state.list, buf_info)
end

M.delete = function(state, pos)
	clipboard = state.list[pos]
	table.remove(state.list, pos)
end

M.paste = function(state, idx)
	if not clipboard or M.exist_by_path(state, clipboard.path) then
		return
	end
	table.insert(state.list, idx, clipboard)
end

M.get_buffer = function(state, idx)
	if not state.list[idx] then
		return nil
	end
	return state.list[idx].buffer
end

M.get_path = function(state, idx)
	if not state.list[idx] then
		return nil
	end
	return state.list[idx].path
end

M.clear_buffer = function(state, buf)
	for i = 1, #state.list do
		if state.list[i].buffer == buf then
			state.list[i].buffer = nil
		end
	end
end

M.add_buffer = function(state, buf)
	local buffer_info = Buffer.info()
	for i = 1, #state.list do
		if state.list[i].path == buffer_info.path then
			state.list[i].buffer = buf
			return
		end
	end
end

return M
