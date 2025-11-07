#!/usr/bin/env python3
"""
Practical example: Using tmux control mode to monitor sessions

This demonstrates a real-world use case: monitoring tmux sessions
and reacting to events.
"""

import subprocess
import sys
import time
import json


def monitor_sessions():
    """Monitor tmux sessions using control mode"""
    
    print("Starting tmux session monitor...")
    print("Press Ctrl+C to stop\n")
    
    process = subprocess.Popen(
        ['tmux', '-C'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )
    
    try:
        # Initial session list
        print("Current sessions:")
        process.stdin.write("list-sessions -F '#{session_name}'\n")
        process.stdin.flush()
        
        sessions = []
        while True:
            line = process.stdout.readline()
            if not line:
                break
            
            line = line.strip()
            if line.startswith('%end'):
                break
            elif line.startswith('%begin'):
                continue
            elif line.startswith('%'):
                continue
            elif line:
                sessions.append(line)
        
        for session in sessions:
            print(f"  - {session}")
        
        print("\nMonitoring for changes (create/delete sessions to see updates)...")
        print("-" * 60)
        
        # Monitor for events
        event_count = 0
        while True:
            # Check for events
            import select
            if sys.platform != 'win32':
                ready, _, _ = select.select([process.stdout], [], [], 1.0)
                if ready:
                    line = process.stdout.readline()
                    if line:
                        line = line.strip()
                        if line.startswith('%'):
                            event_count += 1
                            if 'session' in line.lower():
                                print(f"Event #{event_count}: {line}")
                                
                                # Refresh session list
                                process.stdin.write("list-sessions -F '#{session_name}'\n")
                                process.stdin.flush()
                                
                                # Read response
                                new_sessions = []
                                while True:
                                    resp_line = process.stdout.readline()
                                    if not resp_line:
                                        break
                                    resp_line = resp_line.strip()
                                    if resp_line.startswith('%end'):
                                        break
                                    elif resp_line.startswith('%begin'):
                                        continue
                                    elif resp_line.startswith('%'):
                                        continue
                                    elif resp_line:
                                        new_sessions.append(resp_line)
                                
                                print(f"  Updated sessions: {', '.join(new_sessions) if new_sessions else '(none)'}")
                                print()
            else:
                time.sleep(1)
    
    except KeyboardInterrupt:
        print("\n\nStopping monitor...")
    finally:
        process.stdin.write("exit\n")
        process.stdin.flush()
        time.sleep(0.1)
        process.stdin.close()
        process.wait()


if __name__ == '__main__':
    monitor_sessions()
