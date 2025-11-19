local always_hidden = {
	".git",
	".DS_Store",
}

local function is_hidden_file(name)
	if vim.startswith(name, ".") then
		return true
	end

	local extra = {
		"__pycache__",
		"node_modules",
	}

	for _, entry in ipairs(extra) do
		if entry == name then
			return true
		end
	end

	return false
end

local function is_always_hidden(name)
	for _, entry in ipairs(always_hidden) do
		if entry == name then
			return true
		end
	end
	return false
end

return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			{ "echasnovski/mini.icons", opts = {} },
		},
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			default_file_explorer = true,
			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 4000,
			lsp_file_methods = {
				enabled = true,
				timeout_ms = 1200,
				autosave_changes = "unmodified",
			},
			constrain_cursor = "editable",
			watch_for_changes = true,
			keymaps = {
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["<C-v>"] = { "actions.select", opts = { vertical = true } },
				["<C-x>"] = { "actions.select", opts = { horizontal = true } },
				["<C-t>"] = { "actions.select", opts = { tab = true } },
				["<C-p>"] = "actions.preview",
				["gp"] = { "actions.preview", desc = "Preview entry", mode = "n" },
				["[p"] = { "actions.preview_scroll_up", desc = "Scroll preview up" },
				["]p"] = { "actions.preview_scroll_down", desc = "Scroll preview down" },
				["q"] = { "actions.close", desc = "Close Oil" },
				["<C-l>"] = { "actions.refresh", desc = "Refresh listing" },
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = { "actions.open_external", desc = "Open with system handler" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
				["gy"] = { "actions.yank_entry", desc = "Copy entry path" },
				["gY"] = {
					callback = function()
						require("oil.actions").yank_entry.callback({ modify = ":~" })
					end,
					desc = "Copy path relative to home",
					mode = "n",
				},
			},
			use_default_keymaps = false,
			view_options = {
				show_hidden = true,
				is_hidden_file = function(name, bufnr)
					return is_hidden_file(name)
				end,
				is_always_hidden = function(name, bufnr)
					return is_always_hidden(name)
				end,
				natural_order = true,
				case_insensitive = true,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
				highlight_filename = function(entry, hidden, link_target, link_orphan)
					if hidden then
						return "Comment"
					end
					if entry.type == "directory" then
						return "Directory"
					end
					return nil
				end,
			},
			extra_scp_args = {},
			git = {
				add = function(_)
					return false
				end,
				mv = function(_, _)
					return false
				end,
				rm = function(_)
					return false
				end,
			},
			float = {
				padding = 3,
				max_width = 0.85,
				max_height = 0.8,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				get_win_title = function()
					return " Oil "
				end,
				preview_split = "right",
				override = function(conf)
					if conf.width then
						conf.col = math.floor((vim.o.columns - conf.width) / 2)
					end
					if conf.height then
						conf.row = math.floor((vim.o.lines - conf.height) / 2)
					end
					return conf
				end,
			},
			preview_win = {
				update_on_cursor_moved = true,
				preview_method = "scratch",
				disable_preview = function(filename)
					return vim.fn.getfsize(filename) > 1024 * 200
				end,
				win_options = {
					number = true,
					relativenumber = false,
					signcolumn = "no",
				},
			},
			confirmation = {
				max_width = { 100, 0.8 },
				min_width = { 40, 0.4 },
				max_height = { 20, 0.4 },
				min_height = { 6, 0.2 },
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
			progress = {
				max_width = { 80, 0.9 },
				min_width = { 40, 0.4 },
				max_height = { 10, 0.5 },
				min_height = { 5, 0.2 },
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},
			ssh = {
				border = "rounded",
			},
			keymaps_help = {
				border = "rounded",
			},
		},
	},
}
