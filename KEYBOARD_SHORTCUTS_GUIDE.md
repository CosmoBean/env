# Keyboard Shortcuts Guide - Neovim + Cursor

**Leader Key:** `<Space>` (press Space first, then the next key)

---

## 📁 File Navigation

### Opening Files & Explorer

| Shortcut | Action | Description |
|----------|--------|-------------|
| `<Space>e` | Toggle Sidebar | Open/close the file explorer sidebar |
| `<Space>f` | Quick Open | Fuzzy finder to quickly open any file |
| `Ctrl+p` | Previous Editor | Switch to the previous open file (in normal mode) |
| `Ctrl+n` | Next Editor | Switch to the next open file (in normal mode) |

### File Explorer (when sidebar is open)
- Use arrow keys or `hjkl` to navigate
- `Enter` to open a file
- `Ctrl+g l` to focus back to the editor

---

## 🎯 Basic Movement (Normal Mode)

### Character & Line Movement

| Key | Action |
|-----|--------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |

**Pro tip:** You can use numbers with these:
- `5j` = move down 5 lines
- `10k` = move up 10 lines
- `3l` = move right 3 characters

### Word Movement

| Key | Action |
|-----|--------|
| `w` | Move forward to start of next word |
| `b` | Move backward to start of previous word |
| `e` | Move forward to end of word |
| `W` | Move forward to start of next WORD (ignores punctuation) |
| `B` | Move backward to start of previous WORD |

### Line Movement

| Key | Action |
|-----|--------|
| `0` | Move to beginning of line |
| `^` | Move to first non-blank character of line |
| `$` | Move to end of line |
| `gg` | Move to top of file |
| `G` | Move to bottom of file |
| `{line}G` | Move to specific line (e.g., `50G` goes to line 50) |

### Screen Movement

| Key | Action |
|-----|--------|
| `Ctrl+d` | Scroll down half a page |
| `Ctrl+u` | Scroll up half a page |
| `Ctrl+f` | Scroll down one full page |
| `Ctrl+b` | Scroll up one full page |
| `zz` | Center cursor on screen |
| `zt` | Move cursor line to top of screen |
| `zb` | Move cursor line to bottom of screen |

---

## 🪟 Pane/Window Navigation

### Switching Between Panes

| Shortcut | Action |
|----------|--------|
| `Ctrl+h` | Focus left pane |
| `Ctrl+j` | Focus bottom pane |
| `Ctrl+k` | Focus top pane |
| `Ctrl+l` | Focus right pane |

**Note:** These work when you have multiple editor panes open (split view).

---

## 🖥️ Terminal Navigation

### Terminal Access

| Shortcut | Action | Context |
|----------|--------|---------|
| `<Space>r` | Focus Terminal | From editor |
| `Ctrl+g j` | Focus Terminal | From editor |
| `Ctrl+g k` | Focus Terminal | From editor |
| `Ctrl+g h` | Focus Explorer | From terminal |
| `Ctrl+g l` | Focus Editor | From explorer |

### Terminal Resizing

| Shortcut | Action |
|----------|--------|
| `Ctrl+g Shift+j` | Resize terminal pane down |
| `Ctrl+g Shift+k` | Resize terminal pane up |

---

## ✏️ Editing

### Modes

| Key | Mode | Description |
|-----|------|-------------|
| `i` | Insert | Enter insert mode at cursor |
| `a` | Append | Enter insert mode after cursor |
| `I` | Insert at line start | Enter insert mode at beginning of line |
| `A` | Append at line end | Enter insert mode at end of line |
| `o` | New line below | Insert new line below and enter insert mode |
| `O` | New line above | Insert new line above and enter insert mode |
| `v` | Visual | Select characters |
| `V` | Visual Line | Select entire lines |
| `Esc` | Normal | Exit insert/visual mode |

### Deletion

| Key | Action |
|-----|--------|
| `x` | Delete character under cursor |
| `X` | Delete character before cursor |
| `dw` | Delete word |
| `dd` | Delete entire line |
| `{n}dd` | Delete n lines (e.g., `3dd` deletes 3 lines) |
| `D` | Delete from cursor to end of line |
| `<Space>d` | Delete to void register (doesn't copy) |

### Copy & Paste

| Shortcut | Action | Description |
|----------|--------|-------------|
| `y` | Yank (copy) | Copy selection in visual mode |
| `yy` | Yank line | Copy entire line |
| `Y` | Yank to end | Copy from cursor to end of line |
| `<Space>y` | Yank to clipboard | Copy to system clipboard |
| `p` | Paste | Paste after cursor |
| `P` | Paste before | Paste before cursor |
| `<Space>P` | Paste from clipboard | Paste from system clipboard |

### Undo/Redo

| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |

---

## 🔍 Search & Replace

### Search

| Key | Action |
|-----|--------|
| `/` | Search forward | Type pattern, press Enter |
| `?` | Search backward | Type pattern, press Enter |
| `n` | Next match | After searching |
| `N` | Previous match | After searching |
| `*` | Search word under cursor forward |
| `#` | Search word under cursor backward |
| `Esc Esc` | Clear search highlights |

### Replace

| Command | Action |
|---------|--------|
| `:s/old/new` | Replace first occurrence on current line |
| `:s/old/new/g` | Replace all occurrences on current line |
| `:%s/old/new/g` | Replace all occurrences in file |

---

## 📝 Visual Mode

### Entering Visual Mode

| Key | Action |
|-----|--------|
| `v` | Character selection |
| `V` | Line selection |
| `Ctrl+v` | Block selection |

### Visual Mode Operations

| Key | Action |
|-----|--------|
| `J` | Move selected block down |
| `K` | Move selected block up |
| `<` | Indent left |
| `>` | Indent right |
| `d` | Delete selection |
| `y` | Copy selection |
| `<Space>p` | Delete and paste (maintains register) |

---

## 💬 Comments

| Shortcut | Action |
|----------|--------|
| `<Space>c` | Comment/Uncomment line |

---

## 🎨 Other Useful Commands

| Command | Action |
|---------|--------|
| `:w` | Save file |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `:TT` | Open terminal in new tab |

---

## 🚀 Quick Reference Cheat Sheet

### Most Used Commands

```
File Navigation:
  <Space>e  - Toggle file explorer
  <Space>f  - Quick open file
  Ctrl+p/n  - Previous/Next file

Movement:
  hjkl      - Left/Down/Up/Right
  w/b       - Next/Previous word
  gg/G      - Top/Bottom of file
  Ctrl+d/u  - Half page down/up

Editing:
  i         - Insert mode
  dd        - Delete line
  yy        - Copy line
  p         - Paste
  u         - Undo

Panes:
  Ctrl+hjkl - Navigate panes

Terminal:
  <Space>r  - Focus terminal
  Ctrl+g hjkl - Navigate between editor/terminal/explorer
```

---

## 💡 Tips for Learning

1. **Start with basics**: Master `hjkl` movement first
2. **Use numbers**: Combine with numbers (`5j`, `10dd`) for efficiency
3. **Stay in Normal mode**: Most commands work in normal mode (press `Esc` to get there)
4. **Practice daily**: Try to use shortcuts instead of mouse/arrow keys
5. **Leader key**: Remember `<Space>` is your leader - press it first for custom commands

---

## 🎯 Practice Exercises

1. **Open a file**: `<Space>f`, type filename, Enter
2. **Navigate**: Use `hjkl` to move around
3. **Jump to line 50**: Type `50G`
4. **Delete 3 lines**: `3dd`
5. **Copy a line**: `yy`, then paste with `p`
6. **Search for a word**: `/word`, then `n` to find next
7. **Open explorer**: `<Space>e`
8. **Switch files**: `Ctrl+p` or `Ctrl+n`
9. **Focus terminal**: `<Space>r`
10. **Comment a line**: `<Space>c`

---

**Remember:** The leader key is `<Space>`, so for commands like `<Space>e`, press Space first, then `e`!
