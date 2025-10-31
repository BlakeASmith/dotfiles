return {
	{
		"awslabs/amazonq.nvim",
		opts = {
			ssoStartUrl = "https://view.awsapps.com/start",
		},
		config = function()
			vim.keymap.set("n", "<leader>aq", ":AmazonQ<CR>", { desc = "Open Amazon Q chat" })
			vim.keymap.set("v", "<leader>ar", ":AmazonQ refactor<CR>", { desc = "Refactor selection" })
			vim.keymap.set("n", "<leader>af", ":.AmazonQ fix<CR>", { desc = "Fix current line" })
			vim.keymap.set("n", "<leader>ao", ":%AmazonQ optimize<CR>", { desc = "Optimize entire file" })
			vim.keymap.set("n", "<leader>ae", ":AmazonQ explain<CR>", { desc = "Explain current file" })
		end,
	},
}
