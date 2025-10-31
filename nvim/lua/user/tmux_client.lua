--- Minimal tmux control mode client with persistent connection
-- Assumes there is only ever one pane
-- @module tmux_client

local M = {}
local mt = { __index = M }

-- Check if running in Neovim
local is_nvim = pcall(function() return vim.fn.has end)

--- Parse response lines
-- @param lines table Array of lines from tmux
-- @return table Response with 'response' and 'events' fields
local function parse_response(lines)
    local response_lines = {}
    local events = {}
    local in_response = false
    
    for _, line in ipairs(lines) do
        if line:match("^%%begin") then
            in_response = true
        elseif line:match("^%%end") then
            break
        elseif line:match("^%%error") then
            table.insert(response_lines, "ERROR: " .. line)
            break
        elseif line:match("^%%") then
            -- Event notification
            table.insert(events, line)
        elseif in_response then
            -- Response content
            table.insert(response_lines, line)
        end
    end
    
    return {
        response = response_lines,
        events = events
    }
end

--- Create a new tmux control mode client
-- @return tmux client instance
function M.new()
    local self = setmetatable({}, mt)
    self.job_id = nil
    self.stdout_buffer = {}
    self.pending_commands = {}
    self.response_callbacks = {}
    self.command_id = 0
    self.term_bufnr = nil
    self.refresh_timer = nil
    self.last_output = ""
    self.command_history = {}
    
    if is_nvim then
        -- Start persistent tmux -C process
        local job_id = vim.fn.jobstart({ "tmux", "-C" }, {
            stdout_buffered = false,
            on_stdout = function(_, data, _)
                self:_handle_stdout(data)
            end,
            on_stderr = function(_, data, _)
                self:_handle_stderr(data)
            end,
            on_exit = function(_, code, _)
                self:_handle_exit(code)
            end,
        })
        
        if job_id <= 0 then
            error("Failed to start tmux control mode: " .. tostring(job_id))
        end
        
        self.job_id = job_id
    else
        error("Persistent connection requires Neovim")
    end
    
    return self
end

--- Handle stdout from tmux
-- @param data table Array of lines from stdout
function M:_handle_stdout(data)
    for _, line in ipairs(data) do
        if line ~= "" then
            table.insert(self.stdout_buffer, line)
            
            -- Check if we've received a complete response (%end)
            if line:match("^%%end") then
                self:_process_response()
            end
        end
    end
end

--- Handle stderr from tmux
-- @param data table Array of lines from stderr
function M:_handle_stderr(data)
    -- Handle errors if needed
    for _, line in ipairs(data) do
        if line ~= "" then
            vim.notify("tmux stderr: " .. line, vim.log.levels.WARN)
        end
    end
end

--- Handle process exit
-- @param code number Exit code
function M:_handle_exit(code)
    self.job_id = nil
    if code ~= 0 then
        vim.notify("tmux control mode exited with code: " .. tostring(code), vim.log.levels.ERROR)
    end
end

--- Process a complete response from the buffer
function M:_process_response()
    if #self.pending_commands == 0 then
        -- Clear events that don't belong to any command
        local i = 1
        while i <= #self.stdout_buffer do
            if self.stdout_buffer[i]:match("^%%begin") then
                -- Found start of response without pending command, skip it
                while i <= #self.stdout_buffer do
                    if self.stdout_buffer[i]:match("^%%end") then
                        break
                    end
                    i = i + 1
                end
                -- Remove processed lines
                for j = i, 1, -1 do
                    if self.stdout_buffer[j]:match("^%%begin") or self.stdout_buffer[j]:match("^%%end") then
                        table.remove(self.stdout_buffer, j)
                    end
                end
                break
            end
            i = i + 1
        end
        return
    end
    
    -- Find the most recent %begin marker
    local begin_idx = nil
    for i = #self.stdout_buffer, 1, -1 do
        if self.stdout_buffer[i]:match("^%%begin") then
            begin_idx = i
            break
        end
    end
    
    if not begin_idx then
        return
    end
    
    -- Collect lines from %begin to %end
    local lines = {}
    local end_idx = nil
    for i = begin_idx, #self.stdout_buffer do
        table.insert(lines, self.stdout_buffer[i])
        if self.stdout_buffer[i]:match("^%%end") then
            end_idx = i
            break
        end
    end
    
    if not end_idx then
        return
    end
    
    -- Remove processed lines from buffer
    for i = end_idx, begin_idx, -1 do
        table.remove(self.stdout_buffer, i)
    end
    
    -- Parse and call callback
    local cmd_info = table.remove(self.pending_commands, 1)
    if cmd_info and cmd_info.callback then
        local result = parse_response(lines)
        cmd_info.callback(result)
    end
end

--- Send a command to tmux
-- @param command string The command to send
-- @param callback function Optional callback function(response)
-- @return table|nil Response if callback not provided (synchronous)
function M:send_command(command, callback)
    if not self.job_id then
        error("tmux client not connected")
    end
    
    if callback then
        -- Asynchronous with callback
        table.insert(self.pending_commands, {
            command = command,
            callback = callback
        })
        
        -- Send command
        vim.fn.chansend(self.job_id, command .. "\n")
        return nil
    else
        -- Synchronous: wait for response
        local response_received = false
        local result = nil
        
        local function sync_callback(resp)
            result = resp
            response_received = true
        end
        
        table.insert(self.pending_commands, {
            command = command,
            callback = sync_callback
        })
        
        -- Send command
        vim.fn.chansend(self.job_id, command .. "\n")
        
        -- Wait for response (with timeout)
        local timeout_ms = 5000 -- 5 seconds
        local elapsed = 0
        while not response_received do
            if elapsed >= timeout_ms then
                error("tmux command timeout: " .. command)
            end
            vim.wait(10) -- Wait 10ms
            elapsed = elapsed + 10
        end
        
        return result
    end
end

--- Get the current pane ID
-- Since we assume only one pane, this simplifies things
-- @return string|nil Pane ID
function M:get_pane_id()
    local result = self:send_command("list-panes -F '#{pane_id}'")
    if result and #result.response > 0 then
        return result.response[1]
    end
    return nil
end

--- Send a command to the pane
-- @param command string Command to execute
-- @param callback function Optional callback
-- @return table|nil Response if callback not provided
function M:send_to_pane(command, callback)
    local pane_id = self:get_pane_id()
    if not pane_id then
        error("No pane found")
    end
    
    -- Add command to history for display in terminal buffer
    if self.term_bufnr and vim.api.nvim_buf_is_valid(self.term_bufnr) then
        table.insert(self.command_history, command)
        -- Keep only last 100 commands
        if #self.command_history > 100 then
            table.remove(self.command_history, 1)
        end
        -- Trigger refresh to show the command
        self.last_output = ""
    end
    
    -- Use send-keys to send command
    local cmd = string.format("send-keys -t %s '%s' Enter", pane_id, command:gsub("'", "'\\''"))
    return self:send_command(cmd, callback)
end

--- Get pane output
-- @return string|nil Output from pane
function M:get_pane_output()
    local pane_id = self:get_pane_id()
    if not pane_id then
        return nil
    end
    
    -- Capture pane contents
    local result = self:send_command(string.format("capture-pane -t %s -p", pane_id))
    if result and #result.response > 0 then
        return table.concat(result.response, "\n")
    end
    return nil
end

--- List sessions
-- @param callback function Optional callback
-- @return table|nil List of session names if callback not provided
function M:list_sessions(callback)
    local result = self:send_command("list-sessions -F '#{session_name}'", callback)
    if result then
        return result.response
    end
    return nil
end

--- List windows
-- @param callback function Optional callback
-- @return table|nil List of window information if callback not provided
function M:list_windows(callback)
    local result = self:send_command("list-windows -F '#{window_index}: #{window_name}'", callback)
    if result then
        return result.response
    end
    return nil
end

--- Attach a Neovim terminal buffer to display tmux pane output
-- @param bufnr number|nil Buffer number (creates new if nil)
-- @param refresh_interval number Refresh interval in milliseconds (default: 500)
-- @return number Buffer number
function M:attach_terminal_buffer(bufnr, refresh_interval)
    refresh_interval = refresh_interval or 500
    
    -- Create or use existing buffer
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        self.term_bufnr = bufnr
    else
        self.term_bufnr = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(self.term_bufnr, "tmux-pane-output")
    end
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(self.term_bufnr, "filetype", "tmux-output")
    vim.api.nvim_buf_set_option(self.term_bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(self.term_bufnr, "bufhidden", "hide")
    
    -- Initial output
    self:refresh_buffer()
    
    -- Set up periodic refresh
    if self.refresh_timer then
        vim.fn.timer_stop(self.refresh_timer)
    end
    
    self.refresh_timer = vim.fn.timer_start(refresh_interval, function()
        if self.term_bufnr and vim.api.nvim_buf_is_valid(self.term_bufnr) then
            self:refresh_buffer()
        end
    end, { ["repeat"] = -1 }) -- Repeat indefinitely
    
    return self.term_bufnr
end

--- Refresh the terminal buffer with current pane output
function M:refresh_buffer()
    if not self.term_bufnr or not vim.api.nvim_buf_is_valid(self.term_bufnr) then
        return
    end
    
    local output = self:get_pane_output()
    if not output then
        return
    end
    
    -- Only update if output has changed
    if output == self.last_output then
        return
    end
    
    self.last_output = output
    
    -- Split output into lines
    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    -- Prepend command history to show commands that were sent
    local all_lines = {}
    for _, cmd in ipairs(self.command_history) do
        table.insert(all_lines, "$ " .. cmd)
    end
    -- Add separator if there are commands
    if #all_lines > 0 then
        table.insert(all_lines, "")
    end
    -- Add pane output
    for _, line in ipairs(lines) do
        table.insert(all_lines, line)
    end
    
    -- Update buffer
    vim.api.nvim_buf_set_lines(self.term_bufnr, 0, -1, false, all_lines)
    
    -- Move cursor to end
    local last_line = math.max(0, #all_lines - 1)
    vim.api.nvim_buf_set_option(self.term_bufnr, "modified", false)
end


--- Open the terminal buffer in a window
-- @param split string Split type: "vertical", "horizontal", or nil (use current window)
function M:open_terminal_window(split)
    if not self.term_bufnr or not vim.api.nvim_buf_is_valid(self.term_bufnr) then
        error("Terminal buffer not attached. Call attach_terminal_buffer() first.")
    end
    
    local cmd
    if split == "vertical" then
        cmd = "vsplit"
    elseif split == "horizontal" then
        cmd = "split"
    else
        cmd = "buffer"
    end
    
    vim.cmd(cmd .. " " .. self.term_bufnr)
end

--- Close the tmux client
function M:close()
    -- Stop refresh timer
    if self.refresh_timer then
        vim.fn.timer_stop(self.refresh_timer)
        self.refresh_timer = nil
    end
    
    -- Close tmux control mode
    if self.job_id then
        -- Send exit command
        vim.fn.chansend(self.job_id, "exit\n")
        vim.fn.jobstop(self.job_id)
        self.job_id = nil
    end
    
    -- Note: We don't delete the buffer automatically
    -- The user can close it manually if needed
end

return M
