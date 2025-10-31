-- Test plugin to validate VSCode plugin loading

return {
	{
		"vim-scripts/commentary.vim",
		cond = vim.g.vscode,
	},
}
