local Ui = require("pin.ui")
local Buffer = require("pin.buffer")
local Pin = require("pin.pin")

local M = {}

M.state = {
	buffer = nil,
	window = nil,
	config = {
		relative = "editor",
		border = "rounded",
		title = " Pin ",
		style = "minimal",
		title_pos = "center",
	},
	pins = {},
}

-- TODO: user passed config
M.setup = function()
	Buffer.create(M.state)

	vim.api.nvim_create_user_command("Pin", function(opts)
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
			Pin.add(M.state, buf_info)
			return
		elseif args[1] == "select" then
			local buffer = Pin.get_buffer(M.state, tonumber(args[2]) + 1)

			print("buffer: " .. vim.inspect(buffer))

			if buffer then
				vim.cmd("Pin close")
				Buffer.set_cur(buffer)
				return
			end

			local path = Pin.get_path(M.state, tonumber(args[2]))

			if path then
				vim.cmd("Pin close")
				vim.cmd("edit " .. path)
				return
			end
		end
	end, { nargs = "*" })

	vim.keymap.set("n", "<C-e>", function()
		vim.cmd("Pin toggle")
	end, { remap = true })

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("Pin close")
	end, { buffer = M.state.buffer, remap = false })

	vim.keymap.set("n", "<C-a>", function()
		vim.cmd("Pin add")
	end, {})

	vim.keymap.set("n", "<CR>", function()
		vim.cmd("Pin select " .. vim.api.nvim_win_get_cursor(M.state.window)[1] - 1)
	end, { buffer = M.state.buffer, remap = false })
end

M.setup()

return M
