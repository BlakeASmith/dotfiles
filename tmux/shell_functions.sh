#!/usr/bin/bash


### TMUX Functions ###
tn() {
    tmux new-session -A -s "$(basename $PWD)"
}

t() {
    session=$(tmux list-sessions | fzf --tmux --exit-0 --select-1 | cut -d":" -f1)
    tmux attach -t "$session"
    
}
### TMUX Functions ###
