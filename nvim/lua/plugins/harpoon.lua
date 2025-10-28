return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "add to harpoon" })

			vim.keymap.set("n", "<leader>he", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "open harpoon menu" })

			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "go to 1" })
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "go to 2" })
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "go to 3" })
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "go to 4" })

			-- Toggle previous & next buffers stored within Harpoon list
			vim.keymap.set("n", "<leader>hp", function()
				harpoon:list():prev()
			end, { desc = "go to previous harpoon" })
			vim.keymap.set("n", "<leader>hn", function()
				harpoon:list():next()
			end, { desc = "go to next harpoon" })
		end,
	},
}
