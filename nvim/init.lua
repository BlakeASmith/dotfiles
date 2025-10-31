require("config.lazy")
require("user.lspkeymap")
require("user.format")
require("user.fuzzy")
require("user.keymaps")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.cursorline = false

vim.cmd("colorscheme gruvbox")
