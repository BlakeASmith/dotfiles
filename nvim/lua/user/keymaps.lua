-- keymap to get to keymaps
local quick_action = require("utils.quick-action")
local daily_note = require("user.daily-note")

local quickkeymap = quick_action.open({
	file = "~/.config/nvim/lua/user/keymaps.lua",
	height = 25,
	on_close = function()
		vim.cmd("update | source %")
	end,
	on_open = function()
		vim.cmd("norm G")
	end,
})

vim.keymap.set({ "n" }, "<leader>km", quickkeymap, { desc = "open keybindings config" })

vim.keymap.set("n", "<leader>kb", quickkeymap, { desc = "Edit keymaps" })

-- Daily note quick open
local daily_note_quick = function()
	local filepath = daily_note.get_daily_note_path()
	quick_action.open({
		file = filepath,
		height = 25,
	})()
end
vim.keymap.set("n", "<leader>nd", daily_note_quick, { desc = "Open daily note in quick window" })

-- Daily note navigation
vim.keymap.set("n", "<leader>nn", daily_note.next_daily_note, { desc = "Next daily note" })
vim.keymap.set("n", "<leader>np", daily_note.prev_daily_note, { desc = "Previous daily note" })

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

ls = require("luasnip")
-- luasnip keybindings
vim.keymap.set("i", "<C-d>", function()
	ls.expand_or_jump()
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-s>", function()
	ls.jump(-1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-f>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, { silent = true })
