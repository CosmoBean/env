# tmux helpers

tmux() {
    if [ "$#" -eq 0 ]; then
        command tmux new-session -A -s main
    else
        command tmux "$@"
    fi
}

tls() {
    command tmux list-sessions
}

ta() {
    local session="${1:-main}"
    command tmux attach-session -t "$session"
}

tk() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: tk <session>\n' >&2
        return 1
    fi

    command tmux kill-session -t "$1"
}
