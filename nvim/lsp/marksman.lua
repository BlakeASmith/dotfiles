---@brief
---
--- https://github.com/artempyanykh/marksman
---
--- `marksman`, a language server for Markdown files

---@type vim.lsp.Config
return {
	cmd = { "marksman", "server" },
	filetypes = { "markdown" },
	root_markers = {
		".marksman.toml",
		".git",
	},
	settings = {},
	on_attach = function(client, bufnr)
		-- Mappings specific to Markdown buffers
		local opts = { noremap = true, silent = true, buffer = bufnr }

		-- gd: Go to Definition (follows [[wikilinks]])
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition (follow wikilink)" }))

		-- gr: Go to References (finds backlinks)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references (find backlinks)" }))

		-- K: Hover (shows link info)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation (link info)" }))

		-- Standard LSP keymaps
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
		vim.keymap.set("n", "<leader>cf", function()
			vim.lsp.buf.format({ async = true })
		end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

		-- Diagnostic keymaps
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_next({ bufnr = bufnr })
		end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_prev({ bufnr = bufnr })
		end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
		vim.keymap.set("n", "<leader>df", function()
			vim.diagnostic.open_float({ bufnr = bufnr })
		end, vim.tbl_extend("force", opts, { desc = "Open diagnostic in float" }))
	end,
}
