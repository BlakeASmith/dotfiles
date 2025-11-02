# nvim lua snippet for cht.sh interaction within neovim

-- cht.sh lua --
-- assume cht.sh already installed
local popover = function (opts)
    local splitbelow = vim.o.splitbelow
    if opts.bottom ~= nil and opts.bottom == false then
        vim.o.splitbelow = false
    else
        vim.o.splitbelow = true
    end

    if opts.size == nil then
       opts.size = 20
    end

    vim.cmd("new | resize " .. opts.size .. " | term cht.sh " .. opts.query)
    -- move down a bit, usually a comment at the beginning
    vim.cmd("norm 10jzz")
    -- quit with q
    vim.keymap.set('n', 'q', '<cmd>bdelete<CR>', { buffer = true, desc = 'Delete current buffer' })

    vim.o.splitbelow = splitbelow
end

vim.api.nvim_create_user_command(
  'Cheat', -- The name of your command (case-sensitive)
  function(opts)
      popover({
          bottom = false,
          size = 20,
          query = opts.args
      })
  end,
  {
    nargs = '*',
    desc = 'use cht.sh',
  }
)

vim.keymap.set('n', '<leader>cs', ':Cheat ', {desc = "cht.sh"})
-- cht.sh lua --
