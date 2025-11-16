return {
	{
		"stevearc/quicker.nvim",
		ft = "qf",
		opts = {
			keys = {
				{
					">",
					function()
						require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
					end,
					desc = "Expand quickfix context",
				},
				{
					"<",
					function()
						require("quicker").collapse()
					end,
					desc = "Collapse quickfix context",
				},
			},
		},
		config = function(_, opts)
			local quicker = require("quicker")
			quicker.setup(opts)

			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { desc = desc })
			end

			map("<leader>qq", function()
				quicker.toggle()
			end, "Toggle quickfix")

			map("<leader>ql", function()
				quicker.toggle({ loclist = true })
			end, "Toggle location list")

			map("<leader>qe", function()
				quicker.expand({ before = 2, after = 2, add_to_existing = true })
			end, "Expand quickfix context")

			map("<leader>qc", function()
				quicker.collapse()
			end, "Collapse quickfix context")
		end,
	},
}
