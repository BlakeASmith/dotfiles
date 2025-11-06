-- Daily Note Command
-- Creates a user command :Today that opens or creates a daily note file
-- File path: ~/vault/daily/YYYY-MM-DD.md (configurable)

local function today_note()
	-- Configuration: Set your vault directory here
	local vault_dir = vim.fn.expand("~/vault")
	local daily_dir = vim.fn.expand(vault_dir .. "/daily")

	-- Create daily directory if it doesn't exist
	if vim.fn.isdirectory(daily_dir) == 0 then
		vim.fn.mkdir(daily_dir, "p")
	end

	-- Get current date in YYYY-MM-DD format
	local date = os.date("%Y-%m-%d")
	local filename = date .. ".md"
	local filepath = daily_dir .. "/" .. filename

	-- Open or create the file
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Create the user command
vim.api.nvim_create_user_command("Today", today_note, {
	desc = "Open or create today's daily note file",
})
