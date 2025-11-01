local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local nvim_paths = vim.fn.glob("~/.config/nvim/**/*")
local dotfiles_paths = vim.fn.glob("~/dotfiles/**/*")
local config_paths = vim.split(nvim_paths .. "\n" .. dotfiles_paths, "\n")

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
