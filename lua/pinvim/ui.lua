local DevIcons = require("nvim-web-devicons")
local Buffer = require("pinvim.buffer")

local M = {}
M.ns_id = vim.api.nvim_create_namespace("pinvim")

M.update_window_params = function(state)
	state.config.width = math.floor(vim.o.columns * 0.3)
	state.config.height = math.floor(vim.o.lines * 0.3)
	state.config.col = math.floor((vim.o.columns - state.config.width) / 2)
	state.config.row = math.floor((vim.o.lines - state.config.height) / 2)
end

M.window_exists = function(window)
	if not window then
		return false
	elseif not vim.api.nvim_win_is_valid(window) then
		return false
	end
	return true
end

M.create_window = function(state)
	if M.window_exists(state.window) or not Buffer.exists(state.buffer) then
		return
	end

	M.update_window_params(state)
	M.render_buffer(state)

	state.window = vim.api.nvim_open_win(state.buffer, true, state.config)

	vim.wo[state.window].cursorline = true
end

M.update_window = function(state)
	if not M.window_exists(state.window) then
		return
	end
	M.update_window_params(state)
	M.update_buffer_lines(state)
	vim.api.nvim_win_set_config(state.window, state.config)
end

M.toggle_window = function(state)
	if M.window_exists(state.window) then
		M.destroy_window(state)
	else
		M.create_window(state)
	end
end

M.destroy_window = function(state)
	if not M.window_exists(state.window) then
		return
	end
	vim.api.nvim_win_hide(state.window)
	state.window = nil
end

M.render_buffer = function(state)
	if not Buffer.exists(state.buffer) then
		return
	end

	vim.bo[state.buffer].modifiable = true
	vim.bo[state.buffer].readonly = false

	vim.api.nvim_buf_clear_namespace(state.buffer, M.ns_id, 0, -1)

	local lines = {}
	local extmarks = {}
	local cur_buf = vim.api.nvim_get_current_buf()

	for lnr, li in ipairs(state.list) do
		local fn = li.fn
		local dir = li.dir
		local pad = 1
		local icon, icon_hl = DevIcons.get_icon(li.fn, li.ext)

		local fn_len = string.len(fn)
		local dir_len = string.len(dir)
		local max_len = state.config.width - 10
		local max_dir_len = max_len - fn_len - pad

		if fn_len >= max_len then
			fn = string.sub(fn, 0, max_len)
			fn_len = max_len
			dir = ""
			pad = 0
		elseif dir_len > max_dir_len then
			dir = "..." .. string.sub(dir, dir_len - max_dir_len + 3, dir_len)
		else
			pad = max_len - fn_len - dir_len
		end

		table.insert(extmarks, {
			{ " ", "Normal" },
			{ tostring(lnr), li.buffer == cur_buf and "Constant" or "Normal" },
			{ " ", "Normal" },
			{ icon or " ", icon_hl or "Normal" },
			{ " ", "Normal" },
			{ fn, "Normal" },
			{ " ", "Normal" },
			{ li.buffer and " " or "󰆴", li.buffer and "Normal" or "Error" },
			{ string.rep(" ", pad), "Normal" },
			{ dir, "Comment" },
			{ " ", "Normal" },
		})

		table.insert(lines, " ")
	end

	vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, lines)

	for lnr, extmark in ipairs(extmarks) do
		vim.api.nvim_buf_set_extmark(state.buffer, M.ns_id, lnr - 1, 1, {
			virt_text = extmark,
			virt_text_pos = "inline",
			hl_mode = "combine",
		})
	end

	vim.bo[state.buffer].modifiable = false
	vim.bo[state.buffer].readonly = true
end

return M
