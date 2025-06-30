local Buffer = require("pinvim.buffer")
local Commands = require("pinvim.cmds")
local Keymap = require("pinvim.keymap")

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
-- run autocommand on buf exit, reasign new buffer to state once created
-- filename, dir etc. length limitations for narrow window
--

Buffer.create(state)
Commands.setup(state)
Keymap.setup(state)
