return {
	-- In your lazy.nvim plugin list:
	{
		"nvim-java/nvim-java",
		dependencies = {
			"nvim-java/lua-async-await",
			"nvim-java/nvim-java-core",
			"nvim-java/nvim-java-test",
			"nvim-java/nvim-java-test",
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
		},
		config = function()
			-- Configure Java with proper DAP setup
			require("java").setup({
				-- Ensure DAP is properly configured
				dap = {
					hotcodereplace = "auto",
					enabled = true,
				},
			})
		end,
	},
}
