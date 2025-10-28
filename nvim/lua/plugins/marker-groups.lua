return {
	{
		"jameswolensky/marker-groups.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Require
			"nvim-telescope/telescope.nvim", -- Optional: Telescope picker
			-- mini.pick is part of mini.nvim; this plugin vendors mini.nvim for tests,
			-- but you can also install mini.nvim explicitly to use mini.pick system-wide
			-- "nvim-mini/mini.nvim",
		},
		opts = {
			picker = "telescope",
			keymaps = {
				enabled = true,
				prefix = "<leader>m",
				mappings = {
					marker = {
						add = { suffix = "a", mode = { "n", "v" }, desc = "Add marker" },
						edit = { suffix = "e", desc = "Edit marker at cursor" },
						delete = { suffix = "d", desc = "Delete marker at cursor" },
						list = { suffix = "l", desc = "List markers in buffer" },
						info = { suffix = "i", desc = "Show marker at cursor" },
					},
					group = {
						create = { suffix = "gc", desc = "Create marker group" },
						select = { suffix = "gs", desc = "Select marker group" },
						list = { suffix = "gl", desc = "List marker groups" },
						rename = { suffix = "gr", desc = "Rename marker group" },
						delete = { suffix = "gd", desc = "Delete marker group" },
						info = { suffix = "gi", desc = "Show active group info" },
						from_branch = { suffix = "gb", desc = "Create group from git branch" },
					},
					view = { toggle = { suffix = "v", desc = "Toggle drawer marker viewer" } },
				},
			},
		},
	},
}
