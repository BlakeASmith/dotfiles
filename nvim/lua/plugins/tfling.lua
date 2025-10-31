return {
	{
		-- "BlakeASmith/tfling.nvim",
		dir = "~/w/tfling.nvim",
		config = function()
			local tfling = require("tfling")

			tfling.setup({
				always = function()
					-- double esc to hide the window
					vim.keymap.set({ "t", "n", "v" }, "<Esc><Esc>", function()
						tfling.hide_current()
					end, { buffer = true })
					-- if already in normal mode, one esc to hide
					vim.keymap.set({ "n" }, "<Esc>", function()
						tfling.hide_current()
					end, { buffer = true })
					-- single esc to get to normal mode
					-- may not work with programs which require esc input
					vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-n>", { buffer = true })

					vim.keymap.set({ "n", "t" }, "<C-f>", function()
						vim.cmd(":TFlingResizeCurrent width=80% height=80%")
					end, { buffer = true })
				end,
			})

			vim.keymap.set({ "n", "v" }, "<leader>ai", function()
				tfling.term({
					cmd = "cursor-agent",
					-- abduco = true,
					tmux = true,
					send_delay = 700,
					setup = function(term)
						local selected = term.selected_text
						if selected ~= nil then
							term.send(selected)
						end
					end,
				})
			end)

			vim.keymap.set({ "n", "v" }, "<leader>af", function()
				tfling.term({
					name = "cursor-agent-top",
					cmd = "cursor-agent",
					-- tmux = true,
					abduco = true,
					send_delay = 700,
					win = {
						type = "floating",
						height = "80%",
						width = "30%",
						position = "right-center",
						margin = "10%",
					},
					setup = function(term)
						local selected = term.selected_text
						if selected ~= nil then
							term.send(selected)
						end
					end,
				})
			end)

			vim.keymap.set({ "n", "v" }, "<leader>lg", function()
				tfling.term({
					name = "LazyGit",
					cmd = "lazygit",
					-- tmux = true,
					abduco = true,
					win = {
						type = "floating",
						height = "100%",
						width = "100%",
						position = "center",
					},
					setup = function(term) end,
				})
			end)

			vim.keymap.set({ "n", "v" }, "<leader>at", function()
				tfling.term({
					name = "shell",
					cmd = "zsh",
					tmux = true,
					send_delay = 1000,
					win = {
						type = "floating",
						height = "40%",
						width = "50%",
						position = "top-right",
						margin = "5%",
					},
					setup = function(term)
						local selected = term.selected_text
						if selected ~= nil then
							term.send(selected)
						end

						vim.keymap.set({ "t", "n" }, "<C-c><C-c>", "<C-d>", { buffer = true })
					end,
				})
			end)

			vim.keymap.set({ "n", "v" }, "<leader>ar", function()
				tfling.term({
					name = "ranger",
					cmd = "ranger",
					tmux = true,
					send_delay = 1000,
					win = {
						type = "floating",
						height = "70%",
						width = "50%",
						position = "top-right",
						margin = "10%",
					},
					setup = function(term)
						vim.keymap.set({ "t", "n" }, "<C-c><C-c>", "<C-d>", { buffer = true })
					end,
				})
			end)
			-- To fix weird UI rendering, set the theme in opencode to "system" (/themes)
			vim.keymap.set({ "n", "v" }, "<leader>oc", function()
				tfling.term({
					cmd = "opencode",
					send_delay = 700,
					tmux = true,
					win = {
						type = "split",
						direction = "right",
						size = "30%",
					},
					setup = function(term)
						local selected = term.selected_text
						if selected ~= nil then
							term.send(selected)
						end

						vim.keymap.set({ "n", "v" }, "<leader>ap", function()
							term.win.resize({ width = "+10%" })
						end)
					end,
				})
			end)
		end,
	},
}
