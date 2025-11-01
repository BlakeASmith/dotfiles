local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local themes = require("telescope.themes")

local config_paths = vim.split(vim.fn.glob("~/.config/nvim/**/*"), "\n")

local config_picker = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "edit nvim config",
			finder = finders.new_table({
				results = config_paths,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.file_previewer(opts),
		})
		:find()
end

vim.keymap.set("n", "<leader>fn", function()
	config_picker()
end)
