---@class Item
---@field path string
---@field buffer number | nil

---@class List
---@field items Item[]
---@field clipboard Item | nil
---@field new fun(self: List): List
---@field select_item fun(self: List, idx: number): nil
---@field add_item fun(self: List, path: string | nil): nil
---@field remove_item fun(self: List, idx: number): nil
---@field paste_item fun(self: List, idx: number): nil
---@field add_buffer fun(self: List, buf: number, path: string): nil
---@field remove_buffer fun(self: List, buf: number): nil
---@field path_exists fun(self: List, path: string): boolean

local List = {}

List.__index = List

---New List instance
---@return List
function List:new()
	local list = setmetatable({
		items = {},
		clipboard = nil,
	}, self)
	return list
end

---Open the file at the given index in the current buffer
---@param idx number
---@return nil
function List:select_item(idx)
	if not idx or not self.items[idx] then
		print("Item does not exist at index: ", idx)
		return nil
	end

	local item = self.items[idx]

	if not item.path or not vim.fn.filereadable(item.path or "") then
		print("Item does not have a valid path: ", idx)
		return nil
	end

	if not item.buffer or not vim.api.nvim_buf_is_valid(item.buffer) then
		vim.cmd("edit " .. item.path)
		return
	end

	if vim.api.nvim_buf_is_loaded(item.buffer) then
		vim.api.nvim_set_current_buf(item.buffer)
	else
		vim.api.nvim_buf_load(item.buffer)
	end
end

---Create a list item from existing buffer
---@param path string | nil
---@return nil
function List:add_item(path)
	local buffer = nil

	if not path then
		buffer = vim.api.nvim_get_current_buf()
		path = vim.api.nvim_buf_get_name(buffer)
	end

	if type(path) ~= "string" or not vim.fn.filereadable(path) then
		print("File not readable: ", type(path))
		return nil
	end

	if self:path_exists(path) then
		print("Item already exists: ", path)
		return
	end

	table.insert(self.items, {
		path = path,
		buffer = buffer,
	})
end

---Remove an item from the list by index
---@param idx number
---@return nil
function List:remove_item(idx)
	if not self.items[idx] then
		print("Item does not exist at index: ", idx)
		return
	end
	self.clipboard = self.items[idx]
	table.remove(self.items, idx)
end

---Paste the clipboard item before a given index
---@param idx number
---@return nil
function List:paste_item(idx)
	if not self.clipboard or self:path_exists(self.clipboard.path) then
		return
	end

	if idx < 1 or idx > #self.items + 1 then
		print("Index out of bounds: ", idx)
		return
	end

	table.insert(self.items, idx, self.clipboard)
end

---Add a buffer to an item in the list
---@param buf number
---@param path string
function List:add_buffer(buf, path)
	for i = 1, #self.items do
		if self.items[i].path == path then
			self.items[i].buffer = buf
			return
		end
	end
end

---Remove the buffer from an item in the list
---@param buf number
---@return nil
function List:remove_buffer(buf)
	for i = 1, #self.items do
		if self.items[i].buffer == buf then
			self.items[i].buffer = nil
		end
	end
end

---Find an item by its path
---@param path string
---@return boolean
function List:path_exists(path)
	for _, item in ipairs(self.items) do
		if item.path == path then
			return true
		end
	end
	return false
end

return List
