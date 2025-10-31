return {
	{
		"awslabs/amazonq.nvim",
		opts = {
			ssoStartUrl = "https://view.awsapps.com/start",
		},
		config = function()
			-- Active keybindings
			vim.keymap.set("n", "<leader>qc", ":AmazonQ<CR>", { desc = "Open Amazon Q chat" })
			vim.keymap.set("v", "<leader>qr", ":AmazonQ refactor<CR>", { desc = "Refactor selection" })
			vim.keymap.set("n", "<leader>qf", ":.AmazonQ fix<CR>", { desc = "Fix current line" })
			vim.keymap.set("n", "<leader>qo", ":%AmazonQ optimize<CR>", { desc = "Optimize entire file" })
			vim.keymap.set("n", "<leader>qe", ":AmazonQ explain<CR>", { desc = "Explain current file" })

			-- Example keybindings for all AmazonQ commands (commented out - uncomment and customize as needed)
			-- Chat window commands
			-- vim.keymap.set("n", "<leader>qc", ":AmazonQ<CR>", { desc = "Open/focus Amazon Q chat window" })
			-- vim.keymap.set("n", "<leader>qt", ":AmazonQ toggle<CR>", { desc = "Toggle Amazon Q chat window" })
			-- vim.keymap.set("n", "<leader>qx", ":AmazonQ clear<CR>", { desc = "Clear Amazon Q chat session" })
			-- vim.keymap.set("n", "<leader>qh", ":AmazonQ help<CR>", { desc = "Show Amazon Q help" })

			-- Authentication commands
			-- vim.keymap.set("n", "<leader>ql", ":AmazonQ login<CR>", { desc = "Login to Amazon Q (SSO)" })
			-- vim.keymap.set("n", "<leader>qL", ":AmazonQ logout<CR>", { desc = "Logout from Amazon Q" })

			-- Range-based commands (visual selection or ranges)
			-- vim.keymap.set("v", "<leader>qr", ":AmazonQ refactor<CR>", { desc = "Refactor selection" })
			-- vim.keymap.set("n", "<leader>qr", ":'<,'>AmazonQ refactor<CR>", { desc = "Refactor last selection" })
			-- vim.keymap.set("n", "<leader>qr", ":%AmazonQ refactor<CR>", { desc = "Refactor entire file" })

			-- vim.keymap.set("v", "<leader>qf", ":AmazonQ fix<CR>", { desc = "Fix selection" })
			-- vim.keymap.set("n", "<leader>qf", ":.AmazonQ fix<CR>", { desc = "Fix current line" })
			-- vim.keymap.set("n", "<leader>qf", ":%AmazonQ fix<CR>", { desc = "Fix entire file" })

			-- vim.keymap.set("v", "<leader>qo", ":AmazonQ optimize<CR>", { desc = "Optimize selection" })
			-- vim.keymap.set("n", "<leader>qo", ":%AmazonQ optimize<CR>", { desc = "Optimize entire file" })

			-- vim.keymap.set("v", "<leader>qe", ":AmazonQ explain<CR>", { desc = "Explain selection" })
			-- vim.keymap.set("n", "<leader>qe", ":AmazonQ explain<CR>", { desc = "Explain current file" })
			-- vim.keymap.set("n", "<leader>qe", ":%AmazonQ explain<CR>", { desc = "Explain entire file" })

			-- Append text to prompt without sending (visual selection)
			-- vim.keymap.set("v", "<leader>qa", ":AmazonQ<CR>", { desc = "Append selection to Amazon Q prompt" })
			-- vim.keymap.set("n", "<leader>qa", ":%AmazonQ<CR>", { desc = "Append entire file to Amazon Q prompt" })
			-- vim.keymap.set("n", "<leader>qa", ":0AmazonQ<CR>", { desc = "Focus chat window without updating context" })

			-- Note: Built-in mapping 'zq' is already available in visual and normal mode
			-- It appends selected text to chat context (equivalent to selecting text and running :AmazonQ)
		end,
	},
}
