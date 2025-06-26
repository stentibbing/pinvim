local M = {}

M.exists = function(buffer)
	if not buffer then
		return false
	elseif not vim.api.nvim_buf_is_valid(buffer) then
		return false
	end
	return true
end

M.create = function(state)
	state.buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buffer].modifiable = false
	vim.bo[state.buffer].readonly = true
end

M.set_cur = function(buffer)
	if not M.exists(buffer) then
		return
	end
	if vim.api.nvim_buf_is_loaded(buffer) then
		vim.api.nvim_set_current_buf(buffer)
	else
		vim.api.nvim_buf_load(buffer)
	end
end

M.info = function()
	local info = {}
	info.buffer = vim.api.nvim_get_current_buf()
	info.path = vim.api.nvim_buf_get_name(info.buffer)
	info.dir = vim.fn.fnamemodify(info.path, ":p:~:h")
	info.fn = vim.fn.fnamemodify(info.path, ":t")
	info.ext = vim.fn.fnamemodify(info.path, ":e")
	return info
end

return M
