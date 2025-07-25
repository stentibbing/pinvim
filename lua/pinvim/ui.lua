local DevIcons = require("nvim-web-devicons")

---@class UI
---@field ns_id number
---@field buffer number|nil
---@field window number|nil
---@field config table
---@field new fun(self:UI, config: table): UI
---@field window_exists fun(self:UI): boolean
---@field update_window_dimensions fun(self:UI): nil
---@field open_window fun(self:UI): nil
---@field close_window fun(self:UI): nil
---@field create_buffer fun(self:UI): nil
---@field update_buffer fun(self:UI, list: table): nil

local UI = {}

UI.__index = UI

---New UI instance
---@param config any
---@return UI
function UI:new(config)
	local ui = setmetatable({
		ns_id = vim.api.nvim_create_namespace("pinvim"),
		config = config or {
			relative = "editor",
			border = "rounded",
			style = "minimal",
		},
		buffer = nil,
		window = nil,
	}, self)
	return ui
end

---Check if the window exists
---@return boolean
function UI:window_exists()
	return self.window and vim.api.nvim_win_is_valid(self.window)
end

---Render the window with the given items
function UI:update_window_dimensions()
	self.config.width = math.floor(vim.o.columns * 0.3)
	self.config.height = math.floor(vim.o.lines * 0.3)
	self.config.col = math.floor((vim.o.columns - self.config.width) / 2)
	self.config.row = math.floor((vim.o.lines - self.config.height) / 2)

	if self:window_exists() then
		vim.api.nvim_win_set_config(self.window, self.config)
	end
end

---Open the window if it does not exist
function UI:open_window()
	if self:window_exists() then
		print("Window already exists")
		return
	end

	--- Check if the buffer exists, if not create it
	if not self.buffer or not vim.api.nvim_buf_is_valid(self.buffer) then
		self:create_buffer()
	end

	self.window = vim.api.nvim_open_win(self.buffer, true, self.config)
	vim.wo[self.window].cursorline = true
end

---Close the window if it exists
function UI:close_window()
	if not self:window_exists() then
		print("Window does not exist")
		return
	end
	vim.api.nvim_win_hide(self.window)
	self.window = nil
end

---Create a new buffer for the UI
---@return nil
function UI:create_buffer()
	if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
		print("Buffer already exists")
		return
	end

	self.buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[self.buffer].modifiable = false
	vim.bo[self.buffer].readonly = true
	vim.bo[self.buffer].filetype = "pinvim"
	vim.bo[self.buffer].bufhidden = "wipe"
	vim.bo[self.buffer].swapfile = false
	vim.bo[self.buffer].buflisted = false

	vim.api.nvim_buf_set_name(self.buffer, "Pinvim")
end

---Update the buffer with a list of items
---@param items Item[]
function UI:update_buffer(items)
	if not self.buffer or not vim.api.nvim_buf_is_valid(self.buffer) then
		print("Buffer does not exist")
		return
	end

	vim.bo[self.buffer].modifiable = true
	vim.bo[self.buffer].readonly = false

	vim.api.nvim_buf_clear_namespace(self.buffer, self.ns_id, 0, -1)

	local lines = {}
	local extmarks = {}
	local cur_buf = vim.api.nvim_get_current_buf()

	for line, item in ipairs(items) do
		local fn = vim.fn.fnamemodify(item.path, ":t")
		local dir = vim.fn.fnamemodify(item.path, ":p:h")
		local ext = vim.fn.fnamemodify(item.path, ":e")

		local pad = 1
		local icon, icon_hl = DevIcons.get_icon(fn, ext)

		local fn_len = string.len(fn)
		local dir_len = string.len(dir)
		local max_len = self.config.width - 10
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
			{ tostring(line), item.buffer == cur_buf and "Constant" or "Normal" },
			{ " ", "Normal" },
			{ icon or " ", icon_hl or "Normal" },
			{ " ", "Normal" },
			{ fn, "Normal" },
			{ " ", "Normal" },
			{ item.buffer and " " or "󰆴", item.buffer and "Normal" or "Error" },
			{ string.rep(" ", pad), "Normal" },
			{ dir, "Comment" },
			{ " ", "Normal" },
		})

		table.insert(lines, " ")
	end

	vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, lines)

	for lnr, extmark in ipairs(extmarks) do
		vim.api.nvim_buf_set_extmark(self.buffer, self.ns_id, lnr - 1, 1, {
			virt_text = extmark,
			virt_text_pos = "inline",
			hl_mode = "combine",
		})
	end

	vim.bo[self.buffer].modifiable = false
	vim.bo[self.buffer].readonly = true
end

return UI
