-- VSCode-specific Neovim settings
-- These settings are only applied when running in VSCode

if not vim.g.vscode then
	return
end

-- Disable features that conflict with VSCode
vim.opt.number = false
vim.opt.relativenumber = false

-- Keep cursor visibility for VSCode integration
vim.o.cursorline = false
vim.o.cursorcolumn = false

-- Disable native completion (VSCode handles this)
vim.opt.completeopt = { "menuone", "noselect" }

-- Performance optimizations for VSCode
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Disable providers that aren't needed
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Key timeout for better VSCode interaction
vim.opt.ttimeoutlen = 50
