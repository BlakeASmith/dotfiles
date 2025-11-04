return {
	{
		"christoomey/vim-tmux-navigator",
		config = function()
			-- vim-tmux-navigator uses default keybindings:
			-- <C-h> - navigate left
			-- <C-j> - navigate down
			-- <C-k> - navigate up
			-- <C-l> - navigate right
			-- These work seamlessly between vim splits and tmux panes
		end,
	},
}
