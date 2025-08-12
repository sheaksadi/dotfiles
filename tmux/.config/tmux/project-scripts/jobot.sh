#!/usr/bin/env bash
PROJECT_DIR="$1"
SESSION_NAME="$2"

# Kill the default window created by the main script

# Window 1: nvim
tmux new-window -t "$SESSION_NAME" -n "nvim" -c "$PROJECT_DIR" "nvim .; exec zsh"
# Window 2: SSH
tmux new-window -t "$SESSION_NAME" -n "ssh" "ssh deadhorse.net"

# Window 3: empty shell
tmux new-window -t "$SESSION_NAME" -n "zsh" -c "$PROJECT_DIR"

tmux kill-window -t "${SESSION_NAME}:1"

tmux select-window -t "$SESSION_NAME:nvim"
