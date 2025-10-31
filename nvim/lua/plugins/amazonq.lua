return {
	{
		"awslabs/amazonq.nvim",
		opts = {
			ssoStartUrl = "https://view.awsapps.com/start",
		},
		config = function()
			vim.keymap.set("n", "<leader>qc", ":AmazonQ<CR>", { desc = "Open Amazon Q chat" })
			vim.keymap.set("v", "<leader>qr", ":AmazonQ refactor<CR>", { desc = "Refactor selection" })
			vim.keymap.set("n", "<leader>qf", ":.AmazonQ fix<CR>", { desc = "Fix current line" })
			vim.keymap.set("n", "<leader>qo", ":%AmazonQ optimize<CR>", { desc = "Optimize entire file" })
			vim.keymap.set("n", "<leader>qe", ":AmazonQ explain<CR>", { desc = "Explain current file" })
		end,
	},
}
