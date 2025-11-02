-- keymap to get to keymaps
local quickkeymap = function()
	vim.cmd("sp | e ~/.config/nvim/lua/user/keymaps.lua")
	vim.cmd("res 25")

	vim.keymap.set("n", "q", function()
		-- source it
		vim.cmd("update | source %")
		-- kill it
		vim.cmd("bdelete")
	end, { buffer = true, desc = "Delete current buffer" })

	-- I probably want to go to the end
	vim.cmd("norm G")
end

vim.keymap.set({ "n" }, "<leader>km", quickkeymap, { desc = "open keybindings config" })

vim.keymap.set("n", "<leader>kb", quickkeymap, { desc = "Edit keymaps" })

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
