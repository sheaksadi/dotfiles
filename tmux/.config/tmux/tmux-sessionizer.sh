#!/usr/bin/env bash
# Define the base directory as a variable
USER_WIN_DIR="/mnt/c/Users/sheaksadi"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/project-scripts"

run_project_script() {
    local selected_dir="$1"
    local session_name="$2"
    echo "$selected_dir"
    local matching_script="$SCRIPT_DIR/${session_name}.sh"

    if [[ -f "$matching_script" ]]; then # Check if the script file exists. [1, 2, 3]
        chmod +x "$matching_script"
        "$matching_script" "$selected_dir" "$session_name"
    fi
}

folders=(
    "$HOME/js-projects"
    "$HOME/projects"
    "$HOME"
    "$HOME/rust-projects"
    "$USER_WIN_DIR/WebstormProjects" # Now uses the variable
    "$USER_WIN_DIR/rust-projects"    # Now uses the variable
    "$USER_WIN_DIR/js-projects"    # Now uses the variable
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
    tmux new-session -ds "$selected_name" -c "$selected"

    run_project_script "$selected" "$selected_name"

    tmux attach -t "$selected_name"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
    run_project_script "$selected" "$selected_name"

fi

if [[ -z "$TMUX" ]]; then
    tmux attach -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
