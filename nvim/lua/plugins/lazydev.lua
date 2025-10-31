return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- Load plugin library when require statements are found
				-- You can add specific plugin paths here if needed
				-- Example: "lazy.nvim" or { path = "lazy.nvim", words = { "LazyVim" } }
			},
			-- Integrations are enabled by default:
			-- integrations = {
			--   lspconfig = true,  -- Fixes lspconfig's workspace management for LuaLS
			--   cmp = true,        -- Adds cmp source for completion
			--   coq = false,       -- Coq integration (disabled by default)
			-- },
		},
	},
}
