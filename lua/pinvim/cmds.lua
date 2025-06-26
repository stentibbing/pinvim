local List = require("pinvim.list")

local M = {}

M.setup = function(state)
	vim.api.nvim_create_augroup("Pinvim", { clear = true })

	vim.api.nvim_create_autocmd("BufDelete", {
		group = "Pinvim",
		pattern = "*",
		callback = function(args)
			List.clear_buffer(state, args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = "Pinvim",
		pattern = "*",
		callback = function(args)
			List.add_buffer(state, args.buf)
		end,
	})
end

return M
