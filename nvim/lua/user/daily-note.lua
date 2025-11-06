-- Daily Note Command
-- Creates a user command :Today that opens or creates a daily note file
-- File path: ~/vault/daily/YYYY-MM-DD.md (configurable)

local M = {}

-- Configuration: Set your vault directory here
local function get_vault_dir()
	return vim.fn.expand("~/vault")
end

local function get_daily_dir()
	local vault_dir = get_vault_dir()
	local daily_dir = vim.fn.expand(vault_dir .. "/daily")
	
	-- Create daily directory if it doesn't exist
	if vim.fn.isdirectory(daily_dir) == 0 then
		vim.fn.mkdir(daily_dir, "p")
	end
	
	return daily_dir
end

-- Get daily note file path for a specific date (YYYY-MM-DD format)
function M.get_daily_note_path_for_date(date)
	local daily_dir = get_daily_dir()
	local filename = date .. ".md"
	local filepath = daily_dir .. "/" .. filename
	return filepath
end

-- Get the daily note file path for today
function M.get_daily_note_path()
	local date = os.date("%Y-%m-%d")
	return M.get_daily_note_path_for_date(date)
end

-- Parse date from filename (e.g., "2025-01-15.md" -> "2025-01-15")
local function parse_date_from_filename(filename)
	local date_pattern = "(%d%d%d%d%-%d%d%-%d%d)"
	local date = filename:match(date_pattern)
	return date
end

-- Check if current buffer is a daily note
local function is_daily_note_buffer()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		return false
	end
	
	local daily_dir = get_daily_dir()
	local daily_dir_expanded = vim.fn.expand(daily_dir)
	local buf_dir = vim.fn.fnamemodify(bufname, ":h")
	
	-- Normalize paths - expand and resolve if possible
	daily_dir_expanded = vim.fn.fnamemodify(daily_dir_expanded, ":p")
	buf_dir = vim.fn.fnamemodify(buf_dir, ":p")
	
	-- Remove trailing slashes for comparison
	daily_dir_expanded = daily_dir_expanded:gsub("/+$", "")
	buf_dir = buf_dir:gsub("/+$", "")
	
	-- Check if buffer is in the daily directory
	if buf_dir ~= daily_dir_expanded then
		return false
	end
	
	-- Check if filename matches date pattern
	local filename = vim.fn.fnamemodify(bufname, ":t")
	local date = parse_date_from_filename(filename)
	return date ~= nil
end

-- Get date from current buffer or return today's date
local function get_current_date()
	if is_daily_note_buffer() then
		local bufname = vim.api.nvim_buf_get_name(0)
		local filename = vim.fn.fnamemodify(bufname, ":t")
		local date = parse_date_from_filename(filename)
		if date then
			return date
		end
	end
	return os.date("%Y-%m-%d")
end

-- Add days to a date string (YYYY-MM-DD format)
local function add_days(date_str, days)
	local year, month, day = date_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
	year = tonumber(year)
	month = tonumber(month)
	day = tonumber(day)
	
	-- Convert to timestamp, add days, convert back
	local timestamp = os.time({ year = year, month = month, day = day })
	timestamp = timestamp + (days * 24 * 60 * 60)
	
	local new_date = os.date("%Y-%m-%d", timestamp)
	return new_date
end

-- Navigate to next daily note
function M.next_daily_note()
	local current_date = get_current_date()
	local next_date = add_days(current_date, 1)
	local filepath = M.get_daily_note_path_for_date(next_date)
	
	-- Open or create the file
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Navigate to previous daily note
function M.prev_daily_note()
	local current_date = get_current_date()
	local prev_date = add_days(current_date, -1)
	local filepath = M.get_daily_note_path_for_date(prev_date)
	
	-- Open or create the file
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

local function today_note()
	local filepath = M.get_daily_note_path()
	-- Open or create the file
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Open daily note in quick window
function M.open_daily_note_quick()
	local quick_action = require("utils.quick-action")
	local filepath = M.get_daily_note_path()
	quick_action.open({
		file = filepath,
		height = 25,
	})()
end

-- Create user commands
vim.api.nvim_create_user_command("Today", today_note, {
	desc = "Open or create today's daily note file",
})

vim.api.nvim_create_user_command("DailyNext", M.next_daily_note, {
	desc = "Navigate to next daily note",
})

vim.api.nvim_create_user_command("DailyPrev", M.prev_daily_note, {
	desc = "Navigate to previous daily note",
})

vim.api.nvim_create_user_command("DailyQuick", M.open_daily_note_quick, {
	desc = "Open today's daily note in quick window",
})

return M
