return {
	init = function()
		local fzf_lua = require("fzf-lua")

		if not fzf_lua then
			return
		end

		fzf_lua.setup({
			winopts = {
				on_create = function()
					vim.keymap.set(
						"t",
						"<C-a>",
						"<cmd>Pinvim integration fzf_lua add<CR>",
						{ nowait = true, buffer = true }
					)
				end,
			},
		})
	end,
	add = function(_)
		local fzf_lua = require("fzf-lua")

		if not fzf_lua then
			return
		end
		local selected = fzf_lua.__INFO.selected or ""
		local path = selected:match("^[^%w]*(.+)$")

		if not path or path == "" then
			print("No file selected")
			return
		end

		vim.cmd("Pinvim add_file " .. path)
	end,
}
