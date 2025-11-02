-- keymap to get to keymaps
vim.keymap.set({ "n" }, "<leader>km", function()
	vim.cmd("sp | e ~/.config/nvim/lua/user/keymaps.lua")
	vim.cmd("res 30")
	-- source it
	vim.cmd("source %")
	-- kill it
	vim.keymap.set("n", "q", "<cmd>bdelete<CR>", { buffer = true, desc = "Delete current buffer" })
end, { desc = "open keybindings config" })

-- general re-binds
vim.keymap.set({ "n", "v" }, ";", ":", { desc = "classic" })

-- General navigation and visual mode keymaps
-- Scroll with cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll upwards" })

-- Search navigation with cursor centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Indent while remaining in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Center after go to definitio
vim.keymap.set("n", "gd", "gdzz")
-- Center while moving by paragraph
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "{", "{zz")

-- Oil.nvim keymaps
vim.keymap.set("n", "<leader>oi", ":Oil<CR>", { desc = "Oil!" })

-- Map <leader>ls to list document symbols
vim.keymap.set("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "List Document Symbols" })
-- Or, if you prefer Telescope's UI (recommended):
vim.keymap.set("n", "<leader>fS", ":Telescope lsp_document_symbols<CR>", { desc = "List Document Symbols (Telescope)" })
