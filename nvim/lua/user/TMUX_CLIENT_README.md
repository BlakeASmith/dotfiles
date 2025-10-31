# tmux Control Mode Client (Lua)

A minimal Lua client for tmux control mode (`-C` flag). Assumes there is only ever one pane.

## Features

- Stateless design: each command spawns its own tmux process
- Works in Neovim (uses `vim.fn.system`) or standalone Lua (uses `io.popen`)
- Parses tmux control mode protocol responses
- Handles events and errors

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

### `client:send_command(command)`
Sends a command to tmux and returns a table with:
- `response`: array of response lines
- `events`: array of event notifications

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
No-op for stateless client (no persistent connection to close).

## Implementation Details

- Uses stateless approach: each command spawns `echo 'command' | tmux -C`
- Parses `%begin`/`%end` markers to extract responses
- Collects `%`-prefixed lines as events
- Handles errors indicated by `%error` prefix

## Example

See `tmux_client_example.lua` for a complete usage example.
