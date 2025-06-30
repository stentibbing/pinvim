local Ui = require("pinvim.ui")
local Buffer = require("pinvim.buffer")
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

	vim.api.nvim_create_user_command("Pinvim", function(opts)
		local args = opts.fargs
		-- Open / close the pinvim window
		if #args == 0 then
			Ui.toggle_window(state)
			return
		end
		-- Open the pinvim window
		if args[1] == "open" then
			Ui.create_window(state)
			return
		-- Close the pinvim window
		elseif args[1] == "close" then
			Ui.destroy_window(state)
			return
		-- Open / close the pinvim window
		elseif args[1] == "toggle" then
			Ui.toggle_window(state)
			return
		-- Add new buffer to the list
		elseif args[1] == "add" then
			local buf_info = Buffer.info()
			if buf_info.path == "" then
				print("No file to pin")
				return
			end
			List.add(state, buf_info)
			return
		-- Select the buffer at the cursor position
		elseif args[1] == "select" then
			local buffer = List.get_buffer(state, tonumber(args[2]) + 1)
			if buffer then
				vim.cmd("Pinvim close")
				Buffer.set_cur(buffer)
				return
			end
			local path = List.get_path(state, tonumber(args[2]) + 1)
			if path then
				vim.cmd("Pinvim close")
				vim.cmd("edit " .. path)
				return
			end
		-- Delete the buffer at the given index
		elseif args[1] == "delete" then
			local index = tonumber(args[2]) + 1
			if not index or index < 1 or index > #state.list then
				print("Invalid index for delete")
				return
			end
			List.delete(state, index)
			Ui.render_buffer(state)
			return
		-- Paste at the position of cursor
		elseif args[1] == "paste" then
			local index = tonumber(args[2]) + 1
			print("index", index)
			if not index or index < 1 or index > #state.list + 1 then
				print("Invalid index for paste")
				return
			end
			List.paste(state, index)
			Ui.render_buffer(state)
			return
		end
	end, { nargs = "*" })
end

return M
