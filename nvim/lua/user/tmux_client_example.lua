--- Example usage of tmux control mode client
-- This shows how to use the minimal tmux client in Neovim

local tmux = require("user.tmux_client")

-- Create a client instance
local client = tmux.new()

-- List all sessions
local sessions = client:list_sessions()
print("Sessions:")
for _, session in ipairs(sessions) do
    print("  - " .. session)
end

-- List windows
local windows = client:list_windows()
print("\nWindows:")
for _, window in ipairs(windows) do
    print("  - " .. window)
end

-- Get pane ID (assumes only one pane)
local pane_id = client:get_pane_id()
print("\nPane ID: " .. (pane_id or "(none)"))

-- Get pane output
local output = client:get_pane_output()
if output then
    print("\nPane output (last 10 lines):")
    local lines = {}
    for line in output:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local start = math.max(1, #lines - 9)
    for i = start, #lines do
        print("  " .. lines[i])
    end
end

-- Send a command to the pane
-- client:send_to_pane("echo 'Hello from tmux client'")

-- Example: Get tmux prefix key
local result = client:send_command("show-options -g prefix")
print("\nTmux prefix key: " .. (result.response[1] or "(unknown)"))

-- No need to close (stateless client)
