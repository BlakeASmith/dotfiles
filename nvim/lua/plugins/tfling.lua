-- File: lua/floating_term.lua

local M = {}
local Terminal = {}
Terminal.__index = Terminal
local active_instances = {}

local function get_selected_text()
  -- Check if we're currently in visual mode using nvim_get_mode()
  local mode_info = vim.api.nvim_get_mode()
  local current_mode = mode_info.mode

  -- Check if we're in any visual mode (v, V, or Ctrl+V)
  if not string.match(current_mode, "^[vV]") and current_mode ~= "\22" then
    -- Not in visual mode, do NOT capture anything
    return nil
  end

  -- We ARE in visual mode, so force normal mode and capture
  vim.cmd("normal! \27") -- Send Escape to exit visual mode

  -- Now get the selection markers (they should be current)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- If markers are invalid, return nil
  if start_pos[2] <= 0 or end_pos[2] <= 0 then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  if #lines == 0 then
    return nil
  end

  -- Extract the selection based on positions
  local result = {}
  for i, line in ipairs(lines) do
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    if i == 1 and i == #lines then
      -- Single line selection
      table.insert(result, string.sub(line, start_col, end_col))
    elseif i == 1 then
      -- First line of multi-line selection
      table.insert(result, string.sub(line, start_col))
    elseif i == #lines then
      -- Last line of multi-line selection
      table.insert(result, string.sub(line, 1, end_col))
    else
      -- Middle lines
      table.insert(result, line)
    end
  end

  return table.concat(result, "\n")
end

---
-- Internal helper to parse window configuration.
--
function Terminal:_parse_win_config(opts)
  -- Handle backward compatibility
  if opts.win then
    return opts.win
  else
    -- Legacy mode: treat as floating window with center position
    return {
      type = "floating",
      position = "center",
      width = opts.width or "80%",
      height = opts.height or "80%",
      margin = "2%",
    }
  end
end

---
-- Internal helper to calculate pixel geometry for floating windows.
--
function Terminal:_calculate_floating_geometry(win_config)
  local width_str = win_config.width or "80%"
  local height_str = win_config.height or "80%"
  local margin_str = win_config.margin or "2%"
  local position = win_config.position or "center"

  -- Calculate pixel values
  local width = math.floor(vim.o.columns * (tonumber((width_str:gsub("%%", ""))) / 100))
  local height = math.floor(vim.o.lines * (tonumber((height_str:gsub("%%", ""))) / 100))
  local margin = math.floor(math.min(vim.o.lines, vim.o.columns) * (tonumber((margin_str:gsub("%%", ""))) / 100))

  -- Ensure it's not larger than the screen
  width = math.min(width, vim.o.columns - 2)
  height = math.min(height, vim.o.lines - 2)

  -- Calculate position based on placement
  local row, col
  if position == "center" then
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
  elseif position == "top-left" then
    row = margin
    col = margin
  elseif position == "top-center" then
    row = margin
    col = math.floor((vim.o.columns - width) / 2)
  elseif position == "top-right" then
    row = margin
    col = vim.o.columns - width - margin
  elseif position == "bottom-left" then
    row = vim.o.lines - height - margin
    col = margin
  elseif position == "bottom-center" then
    row = vim.o.lines - height - margin
    col = math.floor((vim.o.columns - width) / 2)
  elseif position == "bottom-right" then
    row = vim.o.lines - height - margin
    col = vim.o.columns - width - margin
  elseif position == "left-center" then
    row = math.floor((vim.o.lines - height) / 2)
    col = margin
  elseif position == "right-center" then
    row = math.floor((vim.o.lines - height) / 2)
    col = vim.o.columns - width - margin
  else
    -- Default to center if invalid position
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
  end

  -- Return the full table for nvim_open_win
  return {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
  }
end

function M:new(config)
  if not config.cmd then
    vim.notify("FloatingTerm:new() requires 'cmd'", vim.log.levels.ERROR)
    return
  end

  local self = setmetatable({}, Terminal)
  self.cmd = config.cmd
  self.win_opts = config.win_opts or {} -- Legacy support
  self.bufnr = nil
  self.win_id = nil
  self.job_id = nil
  return self
end

function Terminal:toggle(opts)
  if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
    if opts then
      local win_config = self:_parse_win_config(opts)
      if win_config.type == "floating" then
        local final_win_opts = self:_calculate_floating_geometry(win_config)
        vim.api.nvim_win_set_config(self.win_id, final_win_opts)
        vim.api.nvim_set_current_win(self.win_id)
      else
        -- For splits, just focus the existing window
        vim.api.nvim_set_current_win(self.win_id)
      end
    else
      self:hide()
    end
  else
    self:open(opts)
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
function Terminal:open(opts)
  -- 1. Parse window configuration
  local win_config = self:_parse_win_config(opts)

  -- 2. If window is valid, just focus it
  if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
    vim.api.nvim_set_current_win(self.win_id)
    return
  end

  -- 3. If buffer exists, create window based on type
  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    if win_config.type == "floating" then
      local final_win_opts = self:_calculate_floating_geometry(win_config)
      self.win_id = vim.api.nvim_open_win(self.bufnr, true, final_win_opts)
    else
      self:_create_split_window(win_config)
    end
    active_instances[self.win_id] = self
    self:setup_win_options()
    vim.cmd("startinsert")
    return
  end

  -- 4. If new, create everything
  self.bufnr = vim.api.nvim_create_buf(true, true)
  vim.bo[self.bufnr].bufhidden = "hide"
  vim.bo[self.bufnr].filetype = "tfling"

  if win_config.type == "floating" then
    local final_win_opts = self:_calculate_floating_geometry(win_config)
    self.win_id = vim.api.nvim_open_win(self.bufnr, true, final_win_opts)
  else
    self:_create_split_window(win_config)
  end
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

function Terminal:_create_split_window(win_config)
  local size_str = win_config.size
  local size_percent = tonumber((size_str:gsub("%%", "")))
  local actual_size

  if win_config.direction == "top" or win_config.direction == "bottom" then
    -- Horizontal split - calculate percentage of total lines
    actual_size = math.floor(vim.o.lines * (size_percent / 100))
    if win_config.direction == "top" then
      vim.cmd("topleft split")
    else
      vim.cmd("botright split")
    end
    vim.cmd("resize " .. actual_size)
  elseif win_config.direction == "left" or win_config.direction == "right" then
    -- Vertical split - calculate percentage of total columns
    actual_size = math.floor(vim.o.columns * (size_percent / 100))
    if win_config.direction == "left" then
      vim.cmd("topleft vsplit")
    else
      vim.cmd("botright vsplit")
    end
    vim.cmd("vertical resize " .. actual_size)
  end

  -- Get the current window ID after creating the split
  self.win_id = vim.api.nvim_get_current_win()

  -- Set the buffer to the terminal buffer
  vim.api.nvim_win_set_buf(self.win_id, self.bufnr)
end

function Terminal:setup_win_options()
  local win_id = self.win_id
  if self.win_config and self.win_config.type == "floating" then
    vim.wo[win_id].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  end
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

--- @class TFlingTermDetails
--- @field job_id number the job ID (channel ID for nvim_chan_send)
--- @field bufnr number the buffer number
--- @field win_id number the window ID
--- @field name string the terminal name
--- @field cmd string the command being run
--- @field send function helper function to send commands to the terminal
--- @field selected_text? string the text that was selected when triggered from visual mode

--- @class TFlingFloatingWin
--- @field type "floating"
--- @field position? "top-left" | "top-center" | "top-right" | "bottom-left" | "bottom-right" | "bottom-center" | "left-center" | "right-center" position of floating window (defaults to "center")
--- @field width? string width as a percentage like "80%" (defaults to "80%")
--- @field height? string height as a percentage like "80%" (defaults to "80%")
--- @field margin? string margin as a percentage like "2%" (defaults to "2%")

--- @class TFlingSplitWin
--- @field type "split"
--- @field direction string split direction: "top", "bottom", "left", "right"
--- @field size string size as a percentage like "30%"

--- @class TFlingTerm
--- @field name? string the name (needs to be unique, defaults to cmd)
--- @field cmd string the command/program to run
--- @field win? TFlingFloatingWin|TFlingSplitWin window configuration (defaults to floating center)
--- @field width? string width as a percentage like "80%" (deprecated, use win.width)
--- @field height? string height as a percentage like "80%" (deprecated, use win.height)
--- @field send_delay? number delay in milliseconds before sending commands (defaults to global config)
--- @field setup? fun(details: TFlingTermDetails) function to run on mount (receives TFlingTermDetails table)

--- @param opts TFlingTerm
function TFling(opts)
  if opts.setup == nil then
    opts.setup = function() end
  end

  -- Set default name to cmd if not provided
  if opts.name == nil then
    opts.name = opts.cmd
  end

  -- Capture selected text BEFORE any buffer operations
  local captured_selected_text = get_selected_text()

  if terms[opts.name] == nil then
    terms[opts.name] = M:new({
      cmd = opts.cmd,
      win_opts = {}, -- Legacy support
    })
  end
  terms[opts.name]:toggle(opts)
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
      -- Create a table with terminal details to pass to the callback
      local term_details = {
        job_id = terms[opts.name].job_id,
        bufnr = terms[opts.name].bufnr,
        win_id = terms[opts.name].win_id,
        name = opts.name,
        cmd = opts.cmd,
        selected_text = captured_selected_text, -- Use the captured text
        -- Helper function to send commands to this terminal
        send = function(command)
          local term_instance = terms[opts.name]
          if term_instance and term_instance.job_id then
            -- Use per-terminal send_delay if provided, otherwise fall back to global config
            local delay = opts.send_delay or Config.send_delay or 100
            vim.defer_fn(function()
              vim.api.nvim_chan_send(term_instance.job_id, command)
            end, delay)
          end
        end,
      }
      Config.always(term_details)
      opts.setup(term_details)
    end,
  })
end

Config = {
  always = function(term) end,
  send_delay = 100, -- Default delay in milliseconds
}

--- @class SetupOpts
--- @field always? fun(TFlingTermDetails) callback ran in all tfling buffers
--- @field send_delay? number delay in milliseconds before sending commands (default: 100)
---
local function setup(opts)
  if opts.always ~= nil then
    Config.always = opts.always
  end
  if opts.send_delay ~= nil then
    Config.send_delay = opts.send_delay
  end
end

vim.api.nvim_create_user_command("TFlingHideCurrent", M.hide_current, {})

return {
  term = TFling,
  setup = setup,
  hide_current = M.hide_current,
}
