# tmux Control Mode Client (Lua)

A minimal Lua client for tmux control mode (`-C` flag) with persistent connection. Assumes there is only ever one pane.

## Features

- **Persistent connection**: Maintains a single tmux -C process for efficient communication
- **Synchronous and asynchronous APIs**: Block for responses or use callbacks
- **Event handling**: Processes tmux events asynchronously
- **Neovim integration**: Uses Neovim's job API for bidirectional communication

## Usage

```lua
local tmux = require("user.tmux_client")

-- Create a client
local client = tmux.new()

-- List sessions
local sessions = client:list_sessions()
for _, session in ipairs(sessions) do
    print(session)
end

-- List windows
local windows = client:list_windows()

-- Get pane ID (assumes only one pane)
local pane_id = client:get_pane_id()

-- Get pane output
local output = client:get_pane_output()

-- Send command to pane
client:send_to_pane("echo 'Hello'")

-- Send arbitrary tmux command
local result = client:send_command("show-options -g prefix")
print(result.response[1])  -- e.g., "prefix C-b"
```

## API

### `tmux.new()`
Creates a new tmux client instance.

### `client:send_command(command, callback)`
Sends a command to tmux.

**Parameters:**
- `command` (string): The tmux command to send
- `callback` (function, optional): If provided, called asynchronously with response table. If not provided, blocks and returns response.

**Returns:**
- If callback provided: `nil`
- If no callback: table with `response` (array of lines) and `events` (array of event notifications)

### `client:get_pane_id()`
Returns the pane ID (assumes only one pane exists).

### `client:send_to_pane(command)`
Sends a command to the pane (executes it in the shell).

### `client:get_pane_output()`
Returns the current pane contents as a string.

### `client:list_sessions()`
Returns an array of session names.

### `client:list_windows()`
Returns an array of window information strings.

### `client:close()`
Closes the persistent connection to tmux control mode. Sends `exit` command and stops the job.

## Implementation Details

- **Persistent connection**: Starts `tmux -C` once via `vim.fn.jobstart`
- **Bidirectional communication**: Sends commands via `chansend`, receives via `on_stdout` callback
- **Response parsing**: Handles `%begin`/`%end` markers to extract responses
- **Event handling**: Processes `%`-prefixed event notifications
- **Error handling**: Detects `%error` prefix and surfaces errors
- **Synchronization**: Uses `vim.wait()` for synchronous calls with timeout

## Asynchronous Usage

```lua
local client = tmux.new()

-- Asynchronous with callback
client:send_command("list-sessions", function(result)
    print("Sessions:")
    for _, session in ipairs(result.response) do
        print("  " .. session)
    end
end)

-- Synchronous (blocks until response)
local result = client:send_command("show-options -g prefix")
print("Prefix: " .. result.response[1])
```

## Example

See `tmux_client_example.lua` for a complete usage example.
