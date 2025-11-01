#!/usr/bin/env python3
"""
Advanced exploration of tmux control mode (-C flag)

This script demonstrates:
- Command/response protocol
- Event notifications
- Response parsing
- Error handling
"""

import subprocess
import sys
import time
import re


class TmuxControlMode:
    """Wrapper for interacting with tmux control mode"""
    
    def __init__(self):
        self.process = None
        self.events = []
        
    def start(self):
        """Start tmux in control mode"""
        self.process = subprocess.Popen(
            ['tmux', '-C'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        return self.process
    
    def send_command(self, command):
        """Send a command and return the response"""
        if not self.process:
            raise RuntimeError("Control mode not started")
        
        # Send command
        self.process.stdin.write(f"{command}\n")
        self.process.stdin.flush()
        
        # Collect response
        response_lines = []
        events = []
        
        while True:
            line = self.process.stdout.readline()
            if not line:
                break
            
            line = line.strip()
            
            # Handle events (lines starting with %)
            if line.startswith('%'):
                if line.startswith('%begin'):
                    # Start of response
                    continue
                elif line.startswith('%end'):
                    # End of response
                    break
                elif line.startswith('%error'):
                    # Error response
                    response_lines.append(f"ERROR: {line}")
                    break
                else:
                    # Event notification
                    events.append(line)
                    continue
            else:
                # Response content
                response_lines.append(line)
        
        return {
            'command': command,
            'events': events,
            'response': response_lines
        }
    
    def read_events(self, timeout=0.1):
        """Read any pending events"""
        if not self.process:
            return []
        
        events = []
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            # Check if there's data available
            import select
            if sys.platform != 'win32':
                ready, _, _ = select.select([self.process.stdout], [], [], timeout)
                if not ready:
                    break
            
            line = self.process.stdout.readline()
            if not line:
                break
            
            line = line.strip()
            if line.startswith('%'):
                events.append(line)
            else:
                # Not an event, might be part of response
                break
        
        return events
    
    def exit(self):
        """Exit control mode"""
        if self.process:
            self.process.stdin.write("exit\n")
            self.process.stdin.flush()
            time.sleep(0.1)
            self.process.stdin.close()
            self.process.wait()


def explore_advanced():
    """Advanced exploration of control mode"""
    
    print("=" * 70)
    print("Advanced tmux Control Mode Exploration")
    print("=" * 70)
    print()
    
    tmux = TmuxControlMode()
    tmux.start()
    
    print("1. Testing command responses")
    print("-" * 70)
    
    # Test various commands
    test_commands = [
        "list-sessions -F '#{session_name}: #{session_windows} windows'",
        "list-windows -F '#{window_index}: #{window_name} (#{window_panes} panes)'",
        "list-panes -F '#{pane_index}: #{pane_pid} - #{pane_current_command}'",
        "show-options -g prefix",
        "show-options -g default-shell",
    ]
    
    for cmd in test_commands:
        print(f"\nCommand: {cmd}")
        result = tmux.send_command(cmd)
        
        if result['events']:
            print(f"Events received: {len(result['events'])}")
            for event in result['events']:
                print(f"  - {event}")
        
        print("Response:")
        if result['response']:
            for line in result['response'][:10]:  # First 10 lines
                print(f"  {line}")
            if len(result['response']) > 10:
                print(f"  ... ({len(result['response']) - 10} more lines)")
        else:
            print("  (empty)")
    
    print("\n" + "=" * 70)
    print("2. Testing event notifications")
    print("-" * 70)
    
    # Create a new window and observe events
    print("\nCreating a new window...")
    result = tmux.send_command("new-window -n control_test 'echo hello'")
    
    print("Events received:")
    for event in result['events']:
        print(f"  {event}")
    
    print("\nResponse:")
    for line in result['response']:
        print(f"  {line}")
    
    # Check for any additional events
    print("\nChecking for additional events...")
    events = tmux.read_events(timeout=0.2)
    if events:
        print("Additional events:")
        for event in events:
            print(f"  {event}")
    
    print("\n" + "=" * 70)
    print("3. Exploring response format")
    print("-" * 70)
    
    # Get detailed information
    result = tmux.send_command("list-sessions -F '#{session_id}|#{session_name}|#{session_windows}|#{session_attached}'")
    
    print("Parsed session information:")
    for line in result['response']:
        if '|' in line:
            parts = line.split('|')
            print(f"  Session ID: {parts[0]}")
            print(f"    Name: {parts[1]}")
            print(f"    Windows: {parts[2]}")
            print(f"    Attached: {parts[3]}")
            print()
    
    print("=" * 70)
    print("4. Testing error handling")
    print("-" * 70)
    
    # Test invalid command
    print("\nTesting invalid command...")
    result = tmux.send_command("invalid-command-that-does-not-exist")
    
    print("Events:")
    for event in result['events']:
        print(f"  {event}")
    
    print("Response:")
    for line in result['response']:
        print(f"  {line}")
    
    print("\n" + "=" * 70)
    print("5. Control Mode Protocol Summary")
    print("-" * 70)
    print("""
Protocol Overview:
- Commands: Send as plain text lines terminated with newline
- Responses: Begin with %begin, contain data lines, end with %end
- Events: Asynchronous notifications starting with % (e.g., %window-add, %session-changed)
- Errors: Indicated with %error prefix

Event Types Observed:
- %begin: Start of command response
- %end: End of command response
- %window-add: New window created
- %session-changed: Active session changed
- %sessions-changed: Session list changed
- %error: Error occurred

Use Cases:
- Automation: Script tmux operations programmatically
- Integration: Build tools that interact with tmux
- Monitoring: Watch for tmux events and react accordingly
- Custom UIs: Build alternative interfaces to tmux
""")
    
    # Cleanup
    tmux.exit()
    
    print("\nExploration complete!")


if __name__ == '__main__':
    try:
        explore_advanced()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
