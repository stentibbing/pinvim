local Ui = require("pinvim.ui")
local Buffer = require("pinvim.buffer")
local List = require("pinvim.list")
local Commands = require("pinvim.cmds")

local M = {}

M.state = {
	buffer = nil,
	window = nil,
	config = {
		relative = "editor",
		border = "rounded",
		style = "minimal",
	},
	pins = {},
}

-- TODO:
-- user passed config
-- run autocommand on buf exit, reasign new buffer to state once created
M.setup = function()
	Buffer.create(M.state)
	Commands.setup(M.state)

	vim.api.nvim_create_user_command("Pinvim", function(opts)
		local args = opts.fargs
		if #args == 0 then
			Ui.toggle_window(M.state)
			return
		end
		if args[1] == "open" then
			Ui.create_window(M.state)
			return
		elseif args[1] == "close" then
			Ui.destroy_window(M.state)
			return
		elseif args[1] == "toggle" then
			Ui.toggle_window(M.state)
			return
		elseif args[1] == "add" then
			local buf_info = Buffer.info()
			if buf_info.path == "" then
				print("No file to pin")
				return
			end
			List.add(M.state, buf_info)
			return
		elseif args[1] == "select" then
			local buffer = List.get_buffer(M.state, tonumber(args[2]) + 1)

			if buffer then
				vim.cmd("Pinvim close")
				Buffer.set_cur(buffer)
				return
			end

			local path = List.get_path(M.state, tonumber(args[2]) + 1)

			if path then
				vim.cmd("Pinvim close")
				vim.cmd("edit " .. path)
				return
			end
		end
	end, { nargs = "*" })

	vim.keymap.set("n", "<C-e>", function()
		vim.cmd("Pinvim toggle")
	end, { remap = true })

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("Pin close")
	end, { buffer = M.state.buffer, remap = false })

	vim.keymap.set("n", "<C-a>", function()
		vim.cmd("Pinvim add")
	end, {})

	vim.keymap.set("n", "<CR>", function()
		vim.cmd("Pinvim select " .. vim.api.nvim_win_get_cursor(M.state.window)[1] - 1)
	end, { buffer = M.state.buffer, remap = false })
end

M.setup()

return M
