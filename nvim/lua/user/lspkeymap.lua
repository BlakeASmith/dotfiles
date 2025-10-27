--- Settings applying to all LSPs
---
vim.lsp.enable("basedpyright")
vim.lsp.enable("lua-ls")

-- Some default mappings, but listing here so I remember
-- ]d next diagnostic
-- [d prev diagnostic
-- ]D last diagnostic
-- C-w d show floating
vim.keymap.set({"n"}, "<leader>de", "<cmd>lua vim.diagnostic.enable()<cr>", { desc = "enable diagnostics" })
vim.keymap.set({"n"}, "<leader>dd", "<cmd>lua vim.diagnostic.enable(false)<cr>", { desc = "disable diagnostics" })
vim.keymap.set({"n"}, "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "open diagnostic in float" })

-- Jump to diagnostic AND show the floating window
local next_diagnostic = function ()
	vim.diagnostic.jump({count = 1})
	-- Use a small delay to ensure the jump completes before opening float
	vim.defer_fn(function()
		vim.diagnostic.open_float()
	end, 10)
end

local prev_diagnostic = function ()
	vim.diagnostic.jump({count = -1})
	-- Use a small delay to ensure the jump completes before opening float
	vim.defer_fn(function()
		vim.diagnostic.open_float()
	end, 10)
end

vim.keymap.set({'n'}, '<leader>dn', next_diagnostic, { desc = 'Toggle diagnostic virtual_lines' })
vim.keymap.set({'n'}, '<leader>dp', prev_diagnostic, { desc = 'Toggle diagnostic virtual_lines' })

--- Toggle on and off virtual lines
local toggle_virtual_lines = function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end

vim.keymap.set({'n'}, '<leader>dl', toggle_virtual_lines, { desc = 'Toggle diagnostic virtual_lines' })


-- Diagnostics config
vim.diagnostic.config({
	signs = false,
	virtual_lines =  {
          source = 'if_many',
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
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = vim.diagnostic.severity.ERROR },

})
