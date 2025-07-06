local M = {}

M.log_to_file = function(filename, message)
	local file = io.open(filename, "a")
	if not file then
		error("Could not open log file: " .. filename)
	end
	file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message .. "\n")
	file:close()
end

return M
