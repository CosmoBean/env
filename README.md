# Dotfiles

Central repo for tmux, Vim, and Neovim configuration.

## Apply on Linux or macOS

Run the installer from the repo root:

```bash
./install.sh
```

Optional flags:

```bash
./install.sh --linux
./install.sh --macos
./install.sh --dry-run
```

The installer:

- backs up existing files to `~/.dotfiles-backups/<timestamp>/`
- links `tmux.conf` to `~/.tmux.conf`
- links `vimrc` to `~/.vimrc`
- links `nvim/` to `~/.config/nvim`
- links Bash dotfiles too if they are added later

## Notes

- The repo does not currently include Bash dotfiles, so Bash setup is skipped for now.
- On Linux, install `xclip` or `wl-clipboard` if you want tmux copy-mode to push to the system clipboard.
- If a tmux server is already running, the installer reloads `~/.tmux.conf` automatically.

## Cursor helpers

If you use Cursor, these helper scripts also work on Linux and macOS:

```bash
./apply_cursor_settings.sh
./setup_neovim_cursor.sh
```
