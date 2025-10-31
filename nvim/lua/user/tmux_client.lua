--- Minimal tmux control mode client
-- Assumes there is only ever one pane
-- Uses stateless approach: each command spawns its own tmux process
-- @module tmux_client

local M = {}
local mt = { __index = M }

-- Check if running in Neovim
local is_nvim = pcall(function() return vim.fn.has end)

--- Parse response from tmux output
-- @param output string Raw output from tmux
-- @return table Response with 'response' and 'events' fields
local function parse_response(output)
    local response_lines = {}
    local events = {}
    local in_response = false
    
    for line in output:gmatch("[^\r\n]+") do
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
    return self
end

--- Send a command to tmux
-- @param command string The command to send
-- @return table Response with 'response' and 'events' fields
function M:send_command(command)
    local cmd
    local output
    
    if is_nvim then
        -- Neovim: use vim.fn.system
        cmd = string.format("echo '%s' | tmux -C", command:gsub("'", "'\\''"))
        output = vim.fn.system(cmd)
    else
        -- Pure Lua: use io.popen
        cmd = string.format("echo '%s' | tmux -C", command:gsub("'", "'\\''"))
        local handle = io.popen(cmd, "r")
        if not handle then
            error("Failed to execute tmux command")
        end
        output = handle:read("*a")
        handle:close()
    end
    
    return parse_response(output)
end

--- Get the current pane ID
-- Since we assume only one pane, this simplifies things
-- @return string|nil Pane ID
function M:get_pane_id()
    local result = self:send_command("list-panes -F '#{pane_id}'")
    if #result.response > 0 then
        return result.response[1]
    end
    return nil
end

--- Send a command to the pane
-- @param command string Command to execute
-- @return table Response
function M:send_to_pane(command)
    local pane_id = self:get_pane_id()
    if not pane_id then
        error("No pane found")
    end
    
    -- Use send-keys to send command
    return self:send_command(string.format("send-keys -t %s '%s' Enter", pane_id, command:gsub("'", "'\\''")))
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
    if #result.response > 0 then
        return table.concat(result.response, "\n")
    end
    return nil
end

--- List sessions
-- @return table List of session names
function M:list_sessions()
    local result = self:send_command("list-sessions -F '#{session_name}'")
    return result.response
end

--- List windows
-- @return table List of window information
function M:list_windows()
    local result = self:send_command("list-windows -F '#{window_index}: #{window_name}'")
    return result.response
end

--- Close the tmux client (no-op for stateless client)
function M:close()
    -- No persistent connection to close
end

return M
