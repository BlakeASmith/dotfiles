return {
	{
		"stevearc/quicker.nvim",
		ft = "qf",
		opts = {
			use_default_opts = false,
			opts = {
				buflisted = false,
				number = false,
				relativenumber = false,
				signcolumn = "yes:1",
				winfixheight = true,
				wrap = false,
			},
			edit = {
				enabled = true,
				autosave = "unmodified",
			},
			highlight = {
				treesitter = true,
				lsp = true,
				load_buffers = true,
			},
			follow = {
				enabled = true,
			},
			constrain_cursor = true,
			trim_leading_whitespace = "common",
			type_icons = {
				E = " ",
				W = " ",
				I = " ",
				N = " ",
				H = " ",
			},
			borders = {
				vert = "│",
				strong_header = "─",
				strong_cross = "┼",
				strong_end = "┤",
				soft_header = "·",
				soft_cross = "┊",
				soft_end = "┆",
			},
			max_filename_width = function()
				return math.floor(math.min(80, vim.o.columns * 0.4))
			end,
			header_length = function(_, start_col)
				return vim.o.columns - start_col - 2
			end,
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

			map("<leader>qf", function()
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
