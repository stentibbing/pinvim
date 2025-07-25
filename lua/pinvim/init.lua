-- TODO:
-- user passed config
-- run autocommand on buf delete, reasign new buffer to state once created
-- adding buffer to the app should check everything not on the list but on the autocommand
-- filename, dir etc. length limitations for narrow window
-- jump to prev and next file
-- save state to file per dir

local List = require("pinvim.list")
local UI = require("pinvim.ui")

-- local Commands = require("pinvim.cmds")
-- local Keymap = require("pinvim.keymap")
-- local Integration = require("pinvim.integration")

---@class Pinvim
---@field ui UI
---@field list List
local Pinvim = {}

Pinvim.__index = Pinvim

function Pinvim:setup()
	print(vim.inspect(self))

	vim.api.nvim_create_augroup("Pinvim", { clear = true })

	vim.api.nvim_create_autocmd("BufDelete", {
		group = "Pinvim",
		pattern = "*",
		callback = function(args)
			self.list:remove_buffer(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = "Pinvim",
		pattern = "*",
		callback = function(args)
			-- self.list:add_buffer(args.buf, vim.api.nvim_buf_get_name(args.buf))
		end,
	})

	vim.api.nvim_create_user_command("Pinvim", function(opts)
		local cmd = nil
		local args = {}

		for i = 1, #opts.fargs do
			if i == 1 then
				cmd = opts.fargs[i]
			elseif i > 1 then
				table.insert(args, opts.fargs[i])
			end
		end

		if not cmd or cmd == "toggle" then
			if self.ui:window_exists() then
				self.ui:hide_window()
			else
				self.ui:render_window(self.list.items)
			end
			return
		end

		-- Open the pinvim window
		if cmd == "open" then
			self.ui:render_window(self.list.items)
			return
		end

		-- Close the pinvim window
		if cmd == "close" then
			self.ui:hide_window()
			return
		end

		-- Add new buffer to the list
		if cmd == "add_item" then
			List.add(args[1])
			return
		end

		-- Select the buffer rt the cursor position
		if cmd == "select_item" then
			if self.ui:window_exists() then
				self.ui:hide_window()
			end
			self.list:select_item(tonumber(args[1]) + 1)
		end

		-- Delete the buffer at the given index
		if cmd == "remove_item" then
			self.list:remove_item(tonumber(args[1]) + 1)
			self.ui:update_buffer(self.list.items)
			return
		end

		-- Paste at the position of cursor
		if cmd == "paste" then
			local index = tonumber(args[1]) + 1
			self.list:paste_item(index)
			self.ui:update_buffer(self.list.items)
			return
		end

		-- Run integration commands
		if cmd == "integration" then
			local name = args[1]
			local sub_cmd = args[2]
			local params = args[3]
			if not name then
				print("Invalid integration name")
				return
			end
			if not sub_cmd then
				print("Invalid integration command")
				return
			end
			Integration.run(name, sub_cmd, params)
			return
		end
	end, { nargs = "*" })
end

function Pinvim:new()
	local pinvim = setmetatable({
		ui = UI:new(nil),
		list = List:new(),
	}, self)
	return pinvim
end

local pinvim = Pinvim:new()
pinvim:setup()
