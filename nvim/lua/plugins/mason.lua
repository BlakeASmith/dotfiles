return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"basedpyright",
				"lua_ls",
				"jdtls",
				"gopls",
				"marksman",
				"typescript-language-server",
			},
		},
	},
}
