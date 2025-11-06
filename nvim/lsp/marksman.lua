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
}
