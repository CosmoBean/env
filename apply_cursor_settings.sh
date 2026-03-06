#!/usr/bin/env bash

# Script to apply Cursor settings and keybindings
# Usage: ./apply_cursor_settings.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

get_cursor_user_dir() {
    case "$1" in
        linux)
            printf '%s\n' "$HOME/.config/Cursor/User"
            ;;
        macos)
            printf '%s\n' "$HOME/Library/Application Support/Cursor/User"
            ;;
        *)
            return 1
            ;;
    esac
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_NAME="$(detect_os)"
CURSOR_USER_DIR="${CURSOR_USER_DIR:-$(get_cursor_user_dir "$OS_NAME")}"

# Source files
SETTINGS_SRC="$SCRIPT_DIR/vscode_settings.json"
KEYBINDINGS_SRC="$SCRIPT_DIR/vscode_keybindings.json"

# Target files
SETTINGS_TARGET="$CURSOR_USER_DIR/settings.json"
KEYBINDINGS_TARGET="$CURSOR_USER_DIR/keybindings.json"

echo -e "${GREEN}Applying Cursor settings...${NC}"

# Check if source files exist
if [ ! -f "$SETTINGS_SRC" ]; then
    echo -e "${RED}Error: $SETTINGS_SRC not found!${NC}"
    exit 1
fi

if [ ! -f "$KEYBINDINGS_SRC" ]; then
    echo -e "${RED}Error: $KEYBINDINGS_SRC not found!${NC}"
    exit 1
fi

# Create Cursor User directory if it doesn't exist
mkdir -p "$CURSOR_USER_DIR"
echo -e "${GREEN}✓ Cursor User directory ready${NC}"

# Backup existing files if they exist
BACKUP_DIR="$CURSOR_USER_DIR/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -f "$SETTINGS_TARGET" ]; then
    cp "$SETTINGS_TARGET" "$BACKUP_DIR/settings.json.$TIMESTAMP.bak"
    echo -e "${YELLOW}✓ Backed up existing settings.json${NC}"
fi

if [ -f "$KEYBINDINGS_TARGET" ]; then
    cp "$KEYBINDINGS_TARGET" "$BACKUP_DIR/keybindings.json.$TIMESTAMP.bak"
    echo -e "${YELLOW}✓ Backed up existing keybindings.json${NC}"
fi

# Function to merge JSON settings
merge_settings() {
    local existing="$1"
    local new="$2"
    local output="$3"
    
    python3 - "$existing" "$new" "$output" <<'EOF'
import json
import re
import sys
from pathlib import Path

def strip_jsonc(text):
    result = []
    in_string = False
    escaped = False
    i = 0

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if in_string:
            result.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            result.append(ch)
            i += 1
            continue

        if ch == "/" and nxt == "/":
            while i < len(text) and text[i] != "\n":
                i += 1
            continue

        if ch == "/" and nxt == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue

        result.append(ch)
        i += 1

    return re.sub(r",(\s*[}\]])", r"\1", "".join(result))

def load_jsonc(path, default):
    file_path = Path(path)
    if not file_path.exists():
        return default

    raw = file_path.read_text(encoding="utf-8")
    if not raw.strip():
        return default

    cleaned = strip_jsonc(raw)
    if not cleaned.strip():
        return default

    return json.loads(cleaned)

try:
    existing_file, new_file, output_file = sys.argv[1:4]
    existing_data = load_jsonc(existing_file, {})
    new_data = load_jsonc(new_file, {})

    merged = existing_data.copy()
    for key, value in new_data.items():
        if key in merged and isinstance(merged[key], dict) and isinstance(value, dict):
            merged[key].update(value)
        else:
            merged[key] = value

    Path(output_file).write_text(json.dumps(merged, indent=4) + "\n", encoding="utf-8")
    print("Settings merged successfully")
except Exception as e:
    print(f"Error merging settings: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

# Function to merge keybindings (append arrays)
merge_keybindings() {
    local existing="$1"
    local new="$2"
    local output="$3"
    
    python3 - "$existing" "$new" "$output" <<'EOF'
import json
import re
import sys
from pathlib import Path

def strip_jsonc(text):
    result = []
    in_string = False
    escaped = False
    i = 0

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if in_string:
            result.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            result.append(ch)
            i += 1
            continue

        if ch == "/" and nxt == "/":
            while i < len(text) and text[i] != "\n":
                i += 1
            continue

        if ch == "/" and nxt == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue

        result.append(ch)
        i += 1

    return re.sub(r",(\s*[}\]])", r"\1", "".join(result))

def load_jsonc(path, default):
    file_path = Path(path)
    if not file_path.exists():
        return default

    raw = file_path.read_text(encoding="utf-8")
    if not raw.strip():
        return default

    cleaned = strip_jsonc(raw)
    if not cleaned.strip():
        return default

    return json.loads(cleaned)

try:
    existing_file, new_file, output_file = sys.argv[1:4]
    existing_data = load_jsonc(existing_file, [])
    new_data = load_jsonc(new_file, [])

    existing_keys = set()
    for item in existing_data:
        key_str = f"{item.get('key', '')}:{item.get('command', '')}:{item.get('when', '')}"
        existing_keys.add(key_str)

    merged = existing_data.copy()
    for item in new_data:
        key_str = f"{item.get('key', '')}:{item.get('command', '')}:{item.get('when', '')}"
        if key_str not in existing_keys:
            merged.append(item)
            existing_keys.add(key_str)

    output = "// Place your key bindings in this file to override the defaults\n"
    output += json.dumps(merged, indent=4) + "\n"
    Path(output_file).write_text(output, encoding="utf-8")
    print("Keybindings merged successfully")
except Exception as e:
    print(f"Error merging keybindings: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Warning: python3 not found. Will overwrite existing files.${NC}"
    echo -e "${YELLOW}Install Python 3 for merge functionality.${NC}"
    
    # Simple copy (overwrite)
    cp "$SETTINGS_SRC" "$SETTINGS_TARGET"
    cp "$KEYBINDINGS_SRC" "$KEYBINDINGS_TARGET"
    echo -e "${GREEN}✓ Settings and keybindings copied (overwritten)${NC}"
else
    # Merge settings
    echo -e "${GREEN}Merging settings...${NC}"
    if merge_settings "$SETTINGS_TARGET" "$SETTINGS_SRC" "$SETTINGS_TARGET"; then
        echo -e "${GREEN}✓ Settings merged successfully${NC}"
    else
        echo -e "${RED}Error merging settings${NC}"
        exit 1
    fi
    
    # Merge keybindings
    echo -e "${GREEN}Merging keybindings...${NC}"
    if merge_keybindings "$KEYBINDINGS_TARGET" "$KEYBINDINGS_SRC" "$KEYBINDINGS_TARGET"; then
        echo -e "${GREEN}✓ Keybindings merged successfully${NC}"
    else
        echo -e "${RED}Error merging keybindings${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Settings applied successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Files updated:"
echo "  - $SETTINGS_TARGET"
echo "  - $KEYBINDINGS_TARGET"
echo ""
if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
echo ""
echo -e "${YELLOW}Note: You may need to restart Cursor for all settings to take effect.${NC}"
