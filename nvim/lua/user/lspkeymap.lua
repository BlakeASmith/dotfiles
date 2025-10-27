--- Settings applying to all LSPs
---
vim.lsp.enable("basedpyright")
vim.lsp.enable("lua-ls")

vim.keymap.set({"n"}, "<leader>de", "<cmd>lua vim.diagnostic.enable()<cr>")
vim.keymap.set({"n"}, "<leader>dd", "<cmd>lua vim.diagnostic.disable()<cr>")
