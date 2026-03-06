#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles-backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
DRY_RUN=false
OS_OVERRIDE=""

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Usage: ./install.sh [--linux | --macos | --os <linux|macos>] [--dry-run]

Applies the repo dotfiles by backing up existing files and linking:
  tmux.conf -> ~/.tmux.conf
  vimrc     -> ~/.vimrc
  nvim/     -> ~/.config/nvim

If Bash dotfiles are added to the repo later, this script will also link the
first matching file it finds for each target:
  .bashrc / bashrc / bash/.bashrc / bash/bashrc -> ~/.bashrc
  .bash_profile / bash_profile / bash/.bash_profile / bash/bash_profile -> ~/.bash_profile
  .profile / profile / bash/.profile / bash/profile -> ~/.profile

Examples:
  ./install.sh
  ./install.sh --linux
  ./install.sh --macos
  ./install.sh --dry-run
EOF
}

log() {
    printf '%b%s%b\n' "$BLUE" "$1" "$NC"
}

success() {
    printf '%b%s%b\n' "$GREEN" "$1" "$NC"
}

warn() {
    printf '%b%s%b\n' "$YELLOW" "$1" "$NC"
}

error() {
    printf '%b%s%b\n' "$RED" "$1" "$NC" >&2
}

run() {
    if "$DRY_RUN"; then
        printf '[dry-run] %s\n' "$*"
        return 0
    fi

    "$@"
}

detect_os() {
    case "$(uname -s)" in
        Linux)
            printf 'linux\n'
            ;;
        Darwin)
            printf 'macos\n'
            ;;
        *)
            return 1
            ;;
    esac
}

backup_target() {
    local target="$1"
    local backup_path="$BACKUP_DIR/${target#"$HOME"/}"

    if [[ "$backup_path" == "$BACKUP_DIR/$target" ]]; then
        backup_path="$BACKUP_DIR/$(basename "$target")"
    fi

    if "$DRY_RUN"; then
        printf '[dry-run] mkdir -p %s\n' "$(dirname "$backup_path")"
        printf '[dry-run] mv %s %s\n' "$target" "$backup_path"
        warn "Would back up $target to $backup_path"
        return 0
    fi

    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    warn "Backed up $target to $backup_path"
}

link_item() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        warn "Skipping missing source: $source"
        return 0
    fi

    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        success "Already linked: $target -> $source"
        return 0
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        backup_target "$target"
    fi

    if "$DRY_RUN"; then
        printf '[dry-run] mkdir -p %s\n' "$(dirname "$target")"
        printf '[dry-run] ln -s %s %s\n' "$source" "$target"
        log "Would link $target -> $source"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    success "Linked $target -> $source"
}

find_repo_source() {
    local candidate
    for candidate in "$@"; do
        if [[ -e "$SCRIPT_DIR/$candidate" || -L "$SCRIPT_DIR/$candidate" ]]; then
            printf '%s\n' "$SCRIPT_DIR/$candidate"
            return 0
        fi
    done

    return 1
}

install_bash_configs() {
    local installed=false
    local source=""

    if source="$(find_repo_source ".bashrc" "bashrc" "bash/.bashrc" "bash/bashrc")"; then
        link_item "$source" "$HOME/.bashrc"
        installed=true
    fi

    if source="$(find_repo_source ".bash_profile" "bash_profile" "bash/.bash_profile" "bash/bash_profile")"; then
        link_item "$source" "$HOME/.bash_profile"
        installed=true
    fi

    if source="$(find_repo_source ".profile" "profile" "bash/.profile" "bash/profile")"; then
        link_item "$source" "$HOME/.profile"
        installed=true
    fi

    if [[ "$installed" == false ]]; then
        warn "No Bash dotfiles found in the repo. Skipping Bash install."
    fi
}

check_dependencies() {
    local os="$1"

    if ! command -v tmux >/dev/null 2>&1; then
        warn "tmux is not installed. ~/.tmux.conf will be linked, but tmux is not available yet."
    fi

    if ! command -v vim >/dev/null 2>&1; then
        warn "vim is not installed. ~/.vimrc will be linked, but Vim is not available yet."
    fi

    if ! command -v nvim >/dev/null 2>&1; then
        warn "nvim is not installed. ~/.config/nvim will be linked, but Neovim is not available yet."
    fi

    if [[ "$os" == "linux" ]] && ! command -v xclip >/dev/null 2>&1 && ! command -v wl-copy >/dev/null 2>&1; then
        warn "Neither xclip nor wl-copy is installed. tmux clipboard copy will fall back to tmux's internal buffer."
    fi
}

reload_tmux_if_running() {
    if ! command -v tmux >/dev/null 2>&1; then
        return 0
    fi

    if tmux ls >/dev/null 2>&1; then
        if "$DRY_RUN"; then
            printf '[dry-run] tmux source-file %s\n' "$HOME/.tmux.conf"
        else
            tmux source-file "$HOME/.tmux.conf"
            success "Reloaded tmux config in the running tmux server"
        fi
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --linux)
            OS_OVERRIDE="linux"
            shift
            ;;
        --macos)
            OS_OVERRIDE="macos"
            shift
            ;;
        --os)
            if [[ $# -lt 2 ]]; then
                error "--os requires a value"
                exit 1
            fi
            OS_OVERRIDE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

OS="${OS_OVERRIDE:-$(detect_os || true)}"
if [[ -z "$OS" ]]; then
    error "Unsupported operating system. Use --linux or --macos."
    exit 1
fi

if [[ "$OS" != "linux" && "$OS" != "macos" ]]; then
    error "Unsupported --os value: $OS"
    exit 1
fi

log "Applying dotfiles for $OS"

link_item "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
link_item "$SCRIPT_DIR/vimrc" "$HOME/.vimrc"
link_item "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
install_bash_configs
reload_tmux_if_running
check_dependencies "$OS"

success "Dotfiles applied successfully"
log "Backups directory: $BACKUP_DIR"
