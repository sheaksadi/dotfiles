#!/usr/bin/env bash
# Define the base directory as a variable
USER_WIN_DIR="/mnt/c/Users/sheaksadi"
# Define your folders in a list (modify as needed)
folders=(
    "$HOME/js-projects"
    "$HOME/rust-projects"
    "$USER_WIN_DIR/WebstormProjects"  # Now uses the variable
    "$USER_WIN_DIR/rust-projects"  # Now uses the variable
    # "$USER_WIN_DIR"
    # Add more paths here, e.g.:
    # "$HOME/work"
    # "$HOME/other_directories/*"
)

# If a directory is passed as an argument, use it
if [[ $# -eq 1 ]]; then
    selected="$1"
else
    # Generate the list of directories from the folders array
    dir_list=$(find "${folders[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | fzf)
    selected="$dir_list"
fi

if [[ -z "$selected" ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -z "$TMUX" ]]; then
    tmux attach -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
