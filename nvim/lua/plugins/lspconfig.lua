return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")

			-- Helper function to load LSP configs from lsp/ directory
			local function setup_lsp(name)
				local config = require("lsp." .. name)
				if config then
					lspconfig[name].setup(config)
				end
			end

			-- Setup marksman LSP
			setup_lsp("marksman")
		end,
	},
}
