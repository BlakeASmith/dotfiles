#!/bin/bash
# Script to handle tmux default behavior based on session count
# If 0 or 1 session: create/attach to 'home' session
# If 2+ sessions: show choose-tree

session_count=$(tmux list-sessions 2>/dev/null | wc -l)

if [ "$session_count" -le 1 ]; then
    tmux new-session -A -s home
else
    tmux choose-tree
fi
