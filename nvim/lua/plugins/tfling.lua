-- File: lua/floating_term.lua

local M = {}
local Terminal = {}
Terminal.__index = Terminal
local active_instances = {}

---
-- Internal helper to calculate pixel geometry from percentages.
--
function Terminal:_calculate_win_geometry(user_opts)
  -- Default to 80% if not specified
  local width_str = user_opts.width or "80%"
  local height_str = user_opts.height or "80%"

  -- Calculate pixel values
  local width = math.floor(vim.o.columns * (tonumber((width_str:gsub("%%", ""))) / 100))
  local height = math.floor(vim.o.lines * (tonumber((height_str:gsub("%%", ""))) / 100))

  -- Ensure it's not larger than the screen
  width = math.min(width, vim.o.columns - 2)
  height = math.min(height, vim.o.lines - 2)

  -- Calculate centering
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Return the full table for nvim_open_win
  return {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded", -- <<< THIS IS THE ONLY CHANGE
  }
end

function M:new(config)
  if not config.cmd or not config.win_opts then
    vim.notify("FloatingTerm:new() requires 'cmd' and 'win_opts'", vim.log.levels.ERROR)
    return
  end

  local self = setmetatable({}, Terminal)
  self.cmd = config.cmd
  self.win_opts = config.win_opts -- This is the default percentage-based config
  self.bufnr = nil
  self.win_id = nil
  self.job_id = nil
  return self
end

function Terminal:toggle(win_opts) -- win_opts is the new percentage config
  if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
    self:hide()
  else
    self:open(win_opts) -- Pass it to open
  end
end

function Terminal:hide()
  if not (self.win_id and vim.api.nvim_win_is_valid(self.win_id)) then
    return
  end
  active_instances[self.win_id] = nil
  vim.api.nvim_win_close(self.win_id, true)
  self.win_id = nil
end

---
-- Opens the terminal window.
--
function Terminal:open(win_opts) -- win_opts is the new percentage config
  -- 1. Get the percentage config to use
  local user_opts = win_opts or self.win_opts

  -- 2. Calculate the final pixel geometry
  local final_win_opts = self:_calculate_win_geometry(user_opts)

  -- 3. If window is valid, just focus it
  if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
    vim.api.nvim_set_current_win(self.win_id)
    return
  end

  -- 4. If buffer exists, re-open the window
  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    self.win_id = vim.api.nvim_open_win(self.bufnr, true, final_win_opts) -- Use calculated opts
    active_instances[self.win_id] = self
    self:setup_win_options()
    vim.cmd("startinsert")
    return
  end

  -- 5. If new, create everything
  self.bufnr = vim.api.nvim_create_buf(true, true)
  vim.bo[self.bufnr].bufhidden = "hide"
  vim.bo[self.bufnr].filetype = "tfling"

  self.win_id = vim.api.nvim_open_win(self.bufnr, true, final_win_opts) -- Use calculated opts
  active_instances[self.win_id] = self
  self:setup_win_options()

  local on_exit = vim.schedule_wrap(function()
    if active_instances[self.win_id] then
      active_instances[self.win_id] = nil
    end
    self.bufnr = nil
    self.win_id = nil
    self.job_id = nil
  end)

  vim.api.nvim_win_call(self.win_id, function()
    self.job_id = vim.fn.termopen(self.cmd, { on_exit = on_exit })
    vim.cmd("startinsert")
  end)
end

function Terminal:setup_win_options()
  local win_id = self.win_id
  vim.wo[win_id].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  vim.wo[win_id].relativenumber = false
  vim.wo[win_id].number = false
  vim.wo[win_id].signcolumn = "no"
end

function M.hide_current()
  local current_win = vim.api.nvim_get_current_win()
  local term_instance = active_instances[current_win]
  if term_instance then
    term_instance:hide()
  end
end

local terms = {}

--- @class TFlingTerm
--- @field name string the name (needs to be unique)
--- @field cmd string the command/program to run
--- @field width string width as a percentage like "80%"
--- @field height string height as a percentage like "80%"
--- @field setup? function function to run on mount (you can setup keymaps)

--- @param opts TFlingTerm
function TFling(opts)
  if opts.setup == nil then
    opts.setup = function() end
  end

  if terms[opts.name] == nil then
    terms[opts.name] = M:new({
      cmd = opts.cmd,
      win_opts = {
        width = opts.width,
        height = opts.height,
      },
    })
  end
  terms[opts.name]:toggle()
  -- call setup function in autocommand
  local augroup_name = "tfling." .. opts.name .. ".config"
  vim.api.nvim_create_augroup(augroup_name, {
    -- reset each time we enter
    clear = true,
  })
  -- on terminal enter (the window opening)
  vim.api.nvim_create_autocmd("TermEnter", {
    group = augroup_name,
    -- only apply in the buffer created for this program
    buffer = terms[opts.name].bufnr,
    callback = function()
      Config.always()
      opts.setup()
    end,
  })
end

Config = {
  always = function() end,
}

--- @class SetupOpts
--- @field always? function callback ran in all tfling buffers
local function setup(opts)
  if opts.always ~= nil then
    Config.always = opts.always
  end
  --- nothing yet
end

return {
  term = TFling,
  setup = setup,
  hide_current = M.hide_current,
}
