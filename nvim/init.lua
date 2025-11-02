require("config.lazy")
require("user.keymaps")

if vim.g.vscode then
	-- VSCode NVIM Extension: https://marketplace.cursorapi.com/items/?itemName=asvetliakov.vscode-neovim
	-- Install in VSCode and point it to your Neovim installation

	require("user.vscode-settings")
	return
end

-- Ordinary Neovim - full config
require("user.lspkeymap")
require("user.format")
require("user.fuzzy")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.cursorline = false

vim.cmd("colorscheme gruvbox")

local register_keybind = function(opts)
	vim.keymap.set("v", "<leader>" .. "y" .. opts.key, '"' .. opts.register .. "y")
	vim.keymap.set("v", "<leader>" .. "y" .. opts.key, '"' .. opts.register .. "y")
	vim.keymap.set("n", "<leader>" .. "p" .. opts.key, '"' .. opts.register .. "p")
end

register_keybind({ key = "1", register = "5" })
register_keybind({ key = "2", register = "6" })
register_keybind({ key = "3", register = "7" })
register_keybind({ key = "4", register = "8" })
-- VSCode NVIM Extension: https://marketplace.cursorapi.com/items/?itemName=asvetliakov.vscode-neovim
-- Install in VSCode and point it to your Neovim installation

vim.opt.splitbelow = true
vim.opt.splitright = true
