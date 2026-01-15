# tmux Control Mode Client (Lua)

A minimal Lua client for tmux control mode (`-C` flag) with persistent connection. Assumes there is only ever one pane.

## Features

- **Persistent connection**: Maintains a single tmux -C process for efficient communication
- **Synchronous and asynchronous APIs**: Block for responses or use callbacks
- **Event handling**: Processes tmux events asynchronously
- **Neovim integration**: Uses Neovim's job API for bidirectional communication

## Usage

### Basic Usage

```lua
local tmux = require("user.tmux_client")

-- Create a client
local client = tmux.new()

-- List sessions
local sessions = client:list_sessions()
for _, session in ipairs(sessions) do
    print(session)
end

-- Send command to pane
client:send_to_pane("echo 'Hello'")
```

### Terminal Buffer Integration

```lua
local tmux = require("user.tmux_client")

-- Create a client
local client = tmux.new()

-- Attach a terminal buffer to display tmux pane output
local bufnr = client:attach_terminal_buffer()

-- Open the buffer in a window (vertical split)
client:open_terminal_window("vertical")

-- Now commands sent to the pane will appear in the buffer
-- with "$ " prefix, and outputs will refresh automatically
client:send_to_pane("pwd")
client:send_to_pane("ls -la")

-- The buffer refreshes every 500ms (default) to show pane output
-- You can customize the refresh interval:
-- client:attach_terminal_buffer(nil, 1000) -- 1 second refresh

-- Manually refresh if needed
client:refresh_buffer()
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

### `client:attach_terminal_buffer(bufnr, refresh_interval)`
Attaches a Neovim buffer to display tmux pane output.

**Parameters:**
- `bufnr` (number|nil): Existing buffer number (creates new if nil)
- `refresh_interval` (number, optional): Refresh interval in milliseconds (default: 500)

**Returns:** Buffer number

**Behavior:**
- Creates a buffer that displays the current tmux pane output
- Automatically refreshes at the specified interval
- Shows commands sent via `send_to_pane()` with "$ " prefix

### `client:open_terminal_window(split)`
Opens the terminal buffer in a window.

**Parameters:**
- `split` (string|nil): "vertical", "horizontal", or nil (use current window)

### `client:refresh_buffer()`
Manually refreshes the terminal buffer with current pane output.

### `client:close()`
Closes the persistent connection to tmux control mode. Sends `exit` command, stops the job, and stops the refresh timer.

## Implementation Details

- **Persistent connection**: Starts `tmux -C` once via `vim.fn.jobstart`
- **Bidirectional communication**: Sends commands via `chansend`, receives via `on_stdout` callback
- **Response parsing**: Handles `%begin`/`%end` markers to extract responses
- **Event handling**: Processes `%`-prefixed event notifications
- **Error handling**: Detects `%error` prefix and surfaces errors
- **Synchronization**: Uses `vim.wait()` for synchronous calls with timeout
- **Terminal buffer**: Uses `capture-pane` to get pane output and displays it in a Neovim buffer
- **Auto-refresh**: Uses `vim.fn.timer_start()` to periodically update the buffer with pane output

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
