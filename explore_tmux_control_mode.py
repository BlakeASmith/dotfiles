#!/usr/bin/env python3
"""
Explore tmux control mode (-C flag)

Control mode allows programs to send commands to tmux and receive responses
in a structured format. Commands are sent as lines terminated with newline,
and responses follow a specific format.
"""

import subprocess
import sys
import time
import json


def explore_control_mode():
    """Explore tmux control mode protocol"""
    
    print("=" * 60)
    print("Exploring tmux Control Mode (-C)")
    print("=" * 60)
    print()
    
    # Start tmux in control mode
    # The -C flag enables control mode
    # Commands are sent via stdin, responses via stdout
    print("Starting tmux in control mode...")
    process = subprocess.Popen(
        ['tmux', '-C'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )
    
    print("Testing basic commands...")
    print("-" * 60)
    
    # Commands to test
    commands = [
        ('list-sessions', 'List all sessions'),
        ('list-windows', 'List all windows'),
        ('list-panes', 'List all panes'),
        ('show-options -g', 'Show global options'),
        ('show-environment', 'Show environment variables'),
    ]
    
    results = {}
    
    for cmd, description in commands:
        print(f"\nCommand: {cmd}")
        print(f"Description: {description}")
        print("Sending command...")
        
        # Send command (must end with newline)
        process.stdin.write(f"{cmd}\n")
        process.stdin.flush()
        
        # Read response
        # Responses start with %begin, contain data, and end with %end
        response_lines = []
        in_response = False
        
        for _ in range(100):  # Limit iterations
            line = process.stdout.readline()
            if not line:
                break
            
            line = line.strip()
            response_lines.append(line)
            
            if line.startswith('%begin'):
                in_response = True
            elif line.startswith('%end'):
                break
            elif line.startswith('%error'):
                print(f"Error response: {line}")
                break
        
        results[cmd] = {
            'description': description,
            'response': '\n'.join(response_lines)
        }
        
        print("Response:")
        print('\n'.join(response_lines[:20]))  # Show first 20 lines
        if len(response_lines) > 20:
            print(f"... ({len(response_lines) - 20} more lines)")
    
    # Test sending a command to create a new window
    print("\n" + "=" * 60)
    print("Testing command execution: new-window")
    print("=" * 60)
    
    process.stdin.write("new-window -n test_window\n")
    process.stdin.flush()
    
    # Read response
    response = []
    for _ in range(10):
        line = process.stdout.readline()
        if not line:
            break
        line = line.strip()
        response.append(line)
        if line.startswith('%end'):
            break
    
    print("Response:")
    print('\n'.join(response))
    
    # Test listing windows again to see the new window
    print("\n" + "=" * 60)
    print("Listing windows again to verify new window")
    print("=" * 60)
    
    process.stdin.write("list-windows\n")
    process.stdin.flush()
    
    response = []
    for _ in range(20):
        line = process.stdout.readline()
        if not line:
            break
        line = line.strip()
        response.append(line)
        if line.startswith('%end'):
            break
    
    print("Response:")
    print('\n'.join(response))
    
    # Exit control mode
    print("\n" + "=" * 60)
    print("Exiting control mode")
    print("=" * 60)
    
    process.stdin.write("exit\n")
    process.stdin.flush()
    
    # Wait a bit for cleanup
    time.sleep(0.1)
    
    # Close
    process.stdin.close()
    process.wait()
    
    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    print("\nControl mode protocol:")
    print("- Commands are sent as lines terminated with newline")
    print("- Responses start with %begin")
    print("- Responses end with %end")
    print("- Errors are indicated with %error")
    print("- Multiple commands can be sent sequentially")
    print("- The protocol allows for programmatic control of tmux")
    
    return results


if __name__ == '__main__':
    try:
        results = explore_control_mode()
        print("\nExploration complete!")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
