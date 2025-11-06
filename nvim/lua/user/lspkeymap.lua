--- Settings applying to all LSPs
---
vim.lsp.enable("basedpyright")
vim.lsp.enable("lua-ls")
vim.lsp.enable("jdtls")
vim.lsp.enable("marksman")
vim.lsp.enable("typescript-language-server")

-- Some default mappings, but listing here so I remember
-- ]d next diagnostic
-- [d prev diagnostic
-- ]D last diagnostic
-- C-w d show floating
vim.keymap.set({ "n" }, "<leader>de", "<cmd>lua vim.diagnostic.enable()<cr>", { desc = "enable diagnostics" })
vim.keymap.set({ "n" }, "<leader>dd", "<cmd>lua vim.diagnostic.enable(false)<cr>", { desc = "disable diagnostics" })
vim.keymap.set({ "n" }, "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "open diagnostic in float" })

-- Jump to diagnostic AND show the floating window
local next_diagnostic = function()
	vim.diagnostic.jump({ count = 1 })
	-- Use a small delay to ensure the jump completes before opening float
	vim.defer_fn(function()
		vim.diagnostic.open_float()
	end, 10)
end

local prev_diagnostic = function()
	vim.diagnostic.jump({ count = -1 })
	-- Use a small delay to ensure the jump completes before opening float
	vim.defer_fn(function()
		vim.diagnostic.open_float()
	end, 10)
end

vim.keymap.set({ "n" }, "<leader>dn", next_diagnostic, { desc = "Toggle diagnostic virtual_lines" })
vim.keymap.set({ "n" }, "<leader>dp", prev_diagnostic, { desc = "Toggle diagnostic virtual_lines" })

--- Toggle on and off virtual lines
local toggle_virtual_lines = function()
	local new_config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_config })
end

vim.keymap.set({ "n" }, "<leader>dl", toggle_virtual_lines, { desc = "Toggle diagnostic virtual_lines" })

-- LSP keymaps
function on_attach(client, bufnr)
	-- Mappings
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
	vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
	vim.keymap.set(
		"n",
		"gi",
		vim.lsp.buf.implementation,
		vim.tbl_extend("force", opts, { desc = "Go to implementation" })
	)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
	vim.keymap.set(
		"n",
		"<leader>wa",
		vim.lsp.buf.add_workspace_folder,
		vim.tbl_extend("force", opts, { desc = "Add workspace folder" })
	)
	vim.keymap.set(
		"n",
		"<leader>wr",
		vim.lsp.buf.remove_workspace_folder,
		vim.tbl_extend("force", opts, { desc = "Remove workspace folder" })
	)
	vim.keymap.set("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
	vim.keymap.set(
		"n",
		"<leader>D",
		vim.lsp.buf.type_definition,
		vim.tbl_extend("force", opts, { desc = "Go to type definition" })
	)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
	vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
	vim.keymap.set("n", "<leader>cf", function()
		vim.lsp.buf.format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
end

-- Set up LSP keymaps for all LSP clients
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = on_attach,
})

-- Diagnostics config
vim.diagnostic.config({
	signs = false,
	virtual_lines = {
		source = "if_many",
		spacing = 2,
		-- severity = vim.diagnostic.severity.HINT,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
})
