local builtin = require("telescope.builtin")

-- File operations
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Telescope git files" })
vim.keymap.set("n", "<leader>fr", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })

-- Git operations
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Telescope git commits" })
vim.keymap.set("n", "<leader>gC", builtin.git_bcommits, { desc = "Telescope git buffer commits" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Telescope git branches" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Telescope git status" })
vim.keymap.set("n", "<leader>gS", builtin.git_stash, { desc = "Telescope git stash" })

-- Help and documentation
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fm", builtin.man_pages, { desc = "Telescope man pages" })
vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "Telescope colorscheme" })

-- History and commands
vim.keymap.set("n", "<leader>fH", builtin.command_history, { desc = "Telescope command history" })
vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Telescope quickfix list" })
vim.keymap.set("n", "<leader>fQ", builtin.quickfixhistory, { desc = "Telescope quickfix history" })
vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "Telescope jumplist" })

-- Lists and locations
vim.keymap.set("n", "<leader>fl", builtin.loclist, { desc = "Telescope location list" })
vim.keymap.set("n", "<leader>fR", builtin.registers, { desc = "Telescope registers" })
vim.keymap.set("n", "<leader>fA", builtin.autocommands, { desc = "Telescope autocommands" })
vim.keymap.set("n", "<leader>fK", builtin.keymaps, { desc = "Telescope keymaps" })

-- Vim options and settings
vim.keymap.set("n", "<leader>fo", builtin.vim_options, { desc = "Telescope vim options" })
vim.keymap.set("n", "<leader>ft", builtin.filetypes, { desc = "Telescope filetypes" })
vim.keymap.set("n", "<leader>fL", builtin.highlights, { desc = "Telescope highlights" })

-- Buffer operations
vim.keymap.set("n", "<leader>fB", builtin.current_buffer_fuzzy_find, { desc = "Telescope current buffer fuzzy find" })
vim.keymap.set("n", "<leader>fT", builtin.current_buffer_tags, { desc = "Telescope current buffer tags" })

-- Utility
vim.keymap.set("n", "<leader>fs", builtin.spell_suggest, { desc = "Telescope spell suggest" })
vim.keymap.set("n", "<leader>f<space>", builtin.resume, { desc = "Telescope resume" })
vim.keymap.set("n", "<leader>fp", builtin.pickers, { desc = "Telescope pickers" })
