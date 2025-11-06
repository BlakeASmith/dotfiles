-- Quick action utility for opening files in splits with custom actions
--
-- Usage:
--   local quick_action = require("utils.quick-action")
--   vim.keymap.set("n", "<leader>km", quick_action.open({
--     file = "~/.config/nvim/lua/user/keymaps.lua",
--     height = 25,
--     close_key = "q",
--     on_close = function()
--       vim.cmd("update | source %")
--     end,
--     on_open = function()
--       vim.cmd("norm G")
--     end,
--   }), { desc = "open keybindings config" })

local M = {}

--- Creates a quick action function that opens a file in a split
--- @param opts table Configuration options
--- @param opts.file string Path to the file to open
--- @param opts.height? number Height of the split window (default: 25)
--- @param opts.close_key? string Key to close the buffer (default: "q")
--- @param opts.on_close? function|string Function or command to run on close
--- @param opts.on_open? function|string Function or command to run after opening
--- @return function Function that can be used as a keymap handler
function M.open(opts)
	local file = opts.file
	local height = opts.height or 25
	local close_key = opts.close_key or "q"
	local on_close = opts.on_close
	local on_open = opts.on_open

	return function()
		-- Open the file in a split
		vim.cmd("sp | e " .. file)
		vim.cmd("res " .. height)

		-- Set up close keymap
		vim.keymap.set("n", close_key, function()
			if on_close then
				if type(on_close) == "string" then
					vim.cmd(on_close)
				elseif type(on_close) == "function" then
					on_close()
				end
			end
			vim.cmd("bdelete")
		end, { buffer = true, desc = "Close quick action buffer" })

		-- Run on_open callback if provided
		if on_open then
			if type(on_open) == "string" then
				vim.cmd(on_open)
			elseif type(on_open) == "function" then
				on_open()
			end
		end
	end
end

return M
