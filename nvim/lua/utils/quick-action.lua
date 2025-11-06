-- Quick action utility for opening files in splits with custom actions
--
-- Usage:
--   local quick_action = require("utils.quick-action")
--   -- Split version
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
--
--   -- Popup version
--   vim.keymap.set("n", "<leader>kp", quick_action.open_popup({
--     file = "~/.config/nvim/lua/user/keymaps.lua",
--     width = 80,
--     height = 25,
--     close_key = "q",
--     on_close = function()
--       vim.cmd("update | source %")
--     end,
--     on_open = function()
--       vim.cmd("norm G")
--     end,
--   }), { desc = "open keybindings config (popup)" })

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

--- Creates a quick action function that opens a file in a floating popup window
--- @param opts table Configuration options
--- @param opts.file string Path to the file to open
--- @param opts.width? number Width of the popup window (default: 80)
--- @param opts.height? number Height of the popup window (default: 25)
--- @param opts.close_key? string Key to close the buffer (default: "q")
--- @param opts.on_close? function|string Function or command to run on close
--- @param opts.on_open? function|string Function or command to run after opening
--- @param opts.relative? string Window relative positioning (default: "editor")
--- @param opts.row? number Row position (default: centered)
--- @param opts.col? number Column position (default: centered)
--- @return function Function that can be used as a keymap handler
function M.open_popup(opts)
	local file = opts.file
	local width = opts.width or 80
	local height = opts.height or 25
	local close_key = opts.close_key or "q"
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
		vim.keymap.set("n", close_key, function()
			if on_close then
				if type(on_close) == "string" then
					vim.cmd(on_close)
				elseif type(on_close) == "function" then
					on_close()
				end
			end
			vim.api.nvim_win_close(win, true)
		end, { buffer = buf, desc = "Close quick action popup" })

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
