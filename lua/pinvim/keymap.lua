local M = {}

M.setup = function(state)
	vim.keymap.set("n", "<C-e>", function()
		vim.cmd("Pinvim toggle")
	end, { remap = true })

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("Pin close")
	end, { buffer = state.buffer, remap = false })

	vim.keymap.set("n", "<C-a>", function()
		vim.cmd("Pinvim add_buffer")
	end, {})

	vim.keymap.set("n", "<CR>", function()
		vim.cmd("Pinvim select " .. vim.api.nvim_win_get_cursor(state.window)[1] - 1)
	end, { buffer = state.buffer, remap = false })

	vim.keymap.set("n", "dd", function()
		vim.cmd("Pinvim delete " .. vim.api.nvim_win_get_cursor(state.window)[1] - 1)
	end, { buffer = state.buffer, remap = false })

	vim.keymap.set("n", "p", function()
		vim.cmd("Pinvim paste " .. vim.api.nvim_win_get_cursor(state.window)[1])
	end, { buffer = state.buffer, remap = false })

	vim.keymap.set("n", "P", function()
		vim.cmd("Pinvim paste " .. vim.api.nvim_win_get_cursor(state.window)[1] - 1)
	end, { buffer = state.buffer, remap = false })
end

return M
