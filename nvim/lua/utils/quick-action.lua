-- Quick action utility for opening files in splits with custom actions
--
-- Usage:
--   local quick_action = require("utils.quick-action")
--   -- Split version
--   vim.keymap.set("n", "<leader>km", quick_action.open({
--     file = "~/.config/nvim/lua/user/keymaps.lua",
--     height = 25,
--     on_close = function()
--       vim.cmd("update | source %")
--     end,
--     on_open = function()
--       vim.cmd("norm G")
--     end,
--   }), { desc = "open keybindings config" })
--
--   -- Popup version
--   vim.keymap.set("n", "<leader>kp", quick_action.open_popup({
--     file = "~/.config/nvim/lua/user/keymaps.lua",
--     width = 80,
--     height = 25,
--     on_close = function()
--       vim.cmd("update | source %")
--     end,
--     on_open = function()
--       vim.cmd("norm G")
--     end,
--   }), { desc = "open keybindings config (popup)" })
--
--   -- Terminal command version
--   vim.keymap.set("n", "<leader>cs", quick_action.open_term({
--     command = "cht.sh",
--     args = function() return vim.fn.input("Query: ") end,
--     height = 20,
--     on_open = function()
--       vim.cmd("norm 10jzz")
--     end,
--   }), { desc = "cht.sh" })

local M = {}

--- Creates a quick action function that opens a file in a split
--- @param opts table Configuration options
--- @param opts.file string Path to the file to open
--- @param opts.height? number Height of the split window (default: 25)
--- @param opts.on_close? function Function to run on close
--- @param opts.on_open? function Function to run after opening
--- @return function Function that can be used as a keymap handler
function M.open(opts)
	local file = opts.file
	local height = opts.height or 25
	local on_close = opts.on_close
	local on_open = opts.on_open

	return function()
		-- Open the file in a split
		vim.cmd("sp | e " .. file)
		vim.cmd("res " .. height)

		-- Set up close keymap
		vim.keymap.set("n", "q", function()
			if on_close then
				on_close()
			end
			vim.cmd("bdelete")
		end, { buffer = true, desc = "Close quick action buffer" })

		-- Run on_open callback if provided
		if on_open then
			on_open()
		end
	end
end

--- Creates a quick action function that opens a file in a floating popup window
--- @param opts table Configuration options
--- @param opts.file string Path to the file to open
--- @param opts.width? number Width of the popup window (default: 80)
--- @param opts.height? number Height of the popup window (default: 25)
--- @param opts.on_close? function Function to run on close
--- @param opts.on_open? function Function to run after opening
--- @param opts.relative? string Window relative positioning (default: "editor")
--- @param opts.row? number Row position (default: centered)
--- @param opts.col? number Column position (default: centered)
--- @return function Function that can be used as a keymap handler
function M.open_popup(opts)
	local file = opts.file
	local width = opts.width or 80
	local height = opts.height or 25
	local on_close = opts.on_close
	local on_open = opts.on_open
	local relative = opts.relative or "editor"
	local row = opts.row
	local col = opts.col

	return function()
		-- Calculate centered position if not provided
		local editor_width = vim.api.nvim_win_get_width(0)
		local editor_height = vim.api.nvim_win_get_height(0)

		if row == nil then
			row = math.floor((editor_height - height) / 2)
		end
		if col == nil then
			col = math.floor((editor_width - width) / 2)
		end

		-- Create floating window
		local win_opts = {
			relative = relative,
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
		}

		-- Create a buffer and load the file
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

		local win = vim.api.nvim_open_win(buf, true, win_opts)

		-- Load the file into the buffer
		vim.cmd("edit " .. file)

		-- Set up close keymap
		vim.keymap.set("n", "q", function()
			if on_close then
				on_close()
			end
			vim.api.nvim_win_close(win, true)
		end, { buffer = buf, desc = "Close quick action popup" })

		-- Set up double ESC to close
		vim.keymap.set("n", "<Esc><Esc>", function()
			if on_close then
				on_close()
			end
			vim.api.nvim_win_close(win, true)
		end, { buffer = buf, desc = "Close quick action popup (double ESC)" })

		-- Run on_open callback if provided
		if on_open then
			on_open()
		end
	end
end

--- Creates a quick action function that opens a terminal and runs a command
--- @param opts table Configuration options
--- @param opts.command string Command to run
--- @param opts.args? string|function Command arguments (string or function that returns string)
--- @param opts.height? number Height of the split window (default: 20)
--- @param opts.bottom? boolean Open split below (default: true)
--- @param opts.on_open? function Function to run after opening
--- @return function Function that can be used as a keymap handler
function M.open_term(opts)
	local command = opts.command
	local args = opts.args or ""
	local height = opts.height or 20
	local bottom = opts.bottom ~= false -- default to true
	local on_open = opts.on_open

	return function()
		-- Get arguments if it's a function
		local cmd_args = ""
		if type(args) == "function" then
			cmd_args = args()
		elseif type(args) == "string" then
			cmd_args = args
		end

		-- Save current splitbelow setting
		local splitbelow = vim.o.splitbelow
		vim.o.splitbelow = bottom

		-- Build the full command
		local full_command = command
		if cmd_args and cmd_args ~= "" then
			full_command = command .. " " .. cmd_args
		end

		-- Open terminal split and run command
		vim.cmd("new | resize " .. height .. " | term " .. full_command)

		-- Set up close keymap
		vim.keymap.set("n", "q", function()
			vim.cmd("bdelete")
		end, { buffer = true, desc = "Close quick action terminal" })

		-- Restore splitbelow setting
		vim.o.splitbelow = splitbelow

		-- Run on_open callback if provided
		if on_open then
			on_open()
		end
	end
end

return M
