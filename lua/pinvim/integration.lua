local M = {}

local integrations = {
	["fzf_lua"] = require("integration.fzf_lua"),
}

M.run = function(name, cmd, params)
	if not integrations[name] then
		print("Integration '" .. name .. "' not found")
		return
	end
	local integration = integrations[name]
	if not integration[cmd] then
		print("Command '" .. cmd .. "' not found in integration '" .. name .. "'")
		return
	end
	integration[cmd](params)
end

M.setup = function()
	for _, integration in pairs(integrations) do
		if not integration.init then
			print("Integration '" .. integration .. "' does not have an init function")
			goto continue
		end
		integration.init()
		::continue::
	end
end

return M
