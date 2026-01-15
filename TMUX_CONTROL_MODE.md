# tmux Control Mode Exploration

## Summary

tmux is installed (version 3.4) and control mode (`-C` flag) has been explored.

## Control Mode Overview

Control mode allows programs to communicate with tmux through a command/response protocol, enabling:
- Programmatic control of tmux sessions, windows, and panes
- Real-time event monitoring
- Automation and scripting
- Building custom tmux interfaces

## Protocol Details

### Command Format
- Commands are sent as plain text lines terminated with newline
- Example: `list-sessions\n`

### Response Format
- Responses begin with `%begin` followed by timestamp and IDs
- Response data follows as plain text lines
- Responses end with `%end` followed by timestamp and IDs
- Example:
  ```
  %begin 1761886525 269 0
  session1: 1 windows
  session2: 2 windows
  %end 1761886525 269 0
  ```

### Event Notifications
Asynchronous events are sent as lines starting with `%`:
- `%window-add @ID` - New window created
- `%session-changed $ID @ID` - Active session/window changed
- `%sessions-changed` - Session list modified
- `%session-window-changed $ID @ID` - Window changed in session
- `%unlinked-window-close @ID` - Window closed
- `%output %ID TEXT` - Output from pane

### Error Handling
- Errors are indicated with `%error` prefix
- Error details follow in the response

## Example Usage

### Basic Command Execution
```bash
echo "list-sessions" | tmux -C
```

### Python Integration
See `explore_tmux_control_mode.py` for a basic example and 
`explore_tmux_control_mode_advanced.py` for advanced usage including:
- Command sending and response parsing
- Event handling
- Error management
- Session monitoring

### Practical Application
See `tmux_monitor_example.py` for a session monitoring example that:
- Lists current sessions
- Monitors for session changes
- Updates display when events occur

## Use Cases

1. **Automation**: Script tmux operations programmatically
2. **Integration**: Build tools that interact with tmux
3. **Monitoring**: Watch for tmux events and react accordingly
4. **Custom UIs**: Build alternative interfaces to tmux
5. **Session Management**: Automated session creation/cleanup

## Files Created

- `explore_tmux_control_mode.py` - Basic exploration script
- `explore_tmux_control_mode_advanced.py` - Advanced exploration with event handling
- `tmux_monitor_example.py` - Practical monitoring example

## Next Steps

To use control mode in your own scripts:
1. Start tmux with `-C` flag: `tmux -C`
2. Send commands via stdin
3. Parse responses and events from stdout
4. Handle `%begin`/`%end` markers for responses
5. Process `%` prefixed lines as events
