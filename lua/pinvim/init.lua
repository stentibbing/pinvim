local Buffer = require("pinvim.buffer")
local Commands = require("pinvim.cmds")
local Keymap = require("pinvim.keymap")
local Integration = require("pinvim.integration")

local state = {
	buffer = nil,
	window = nil,
	config = {
		relative = "editor",
		border = "rounded",
		style = "minimal",
	},
	list = {},
}

-- TODO:
-- user passed config
-- run autocommand on buf delete, reasign new buffer to state once created
-- adding buffer to the app should check everything not on the list but on the autocommand
-- filename, dir etc. length limitations for narrow window
-- jump to prev and next file
-- save state to file per dir

Buffer.create(state)
Commands.setup(state)
Keymap.setup(state)
Integration.setup()
