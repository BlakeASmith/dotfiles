--- Example usage of tmux control mode client with terminal buffer
-- This shows how to use the minimal tmux client in Neovim with terminal buffer integration

local tmux = require("user.tmux_client")

-- Create a client instance
local client = tmux.new()

-- Attach a terminal buffer to display tmux pane output
local bufnr = client:attach_terminal_buffer()

-- Open the buffer in a vertical split
client:open_terminal_window("vertical")

-- Now commands sent to the pane will appear in the buffer
-- and outputs will be refreshed automatically

-- Send a command to the pane (will appear in buffer as "$ echo hello")
client:send_to_pane("echo 'Hello from tmux client'")

-- Send another command
vim.defer_fn(function()
    client:send_to_pane("pwd")
end, 1000)

-- The buffer will automatically refresh every 500ms (default)
-- showing the current pane output

-- You can also manually refresh
-- client:refresh_buffer()

-- Example: List sessions (this won't show in terminal buffer, it's a tmux command)
local sessions = client:list_sessions()
print("Sessions:")
for _, session in ipairs(sessions) do
    print("  - " .. session)
end

-- Close the client when done (stops the refresh timer)
-- client:close()
