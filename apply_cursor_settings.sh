#!/bin/bash

# Script to apply Cursor settings and keybindings
# Usage: ./apply_cursor_settings.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

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
    
    python3 << EOF
import json
import sys
import os

try:
    # Load existing settings
    existing_file = '$existing'
    if existing_file and os.path.exists(existing_file):
        with open(existing_file, 'r') as f:
            existing_data = json.load(f)
    else:
        existing_data = {}
    
    # Load new settings
    new_file = '$new'
    with open(new_file, 'r') as f:
        new_data = json.load(f)
    
    # Merge: new settings override existing ones
    # For nested objects, we do a shallow merge
    merged = existing_data.copy()
    for key, value in new_data.items():
        if key in merged and isinstance(merged[key], dict) and isinstance(value, dict):
            # Merge nested dictionaries
            merged[key].update(value)
        else:
            # Overwrite with new value
            merged[key] = value
    
    # Write merged settings
    output_file = '$output'
    with open(output_file, 'w') as f:
        json.dump(merged, f, indent=4)
    
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
    
    python3 << EOF
import json
import sys
import os

try:
    # Load existing keybindings
    existing_file = '$existing'
    if existing_file and os.path.exists(existing_file):
        with open(existing_file, 'r') as f:
            content = f.read()
            # Remove comments (simple approach - remove lines starting with //)
            lines = [line for line in content.split('\n') if not line.strip().startswith('//')]
            content = '\n'.join(lines)
            existing_data = json.loads(content)
    else:
        existing_data = []
    
    # Load new keybindings
    new_file = '$new'
    with open(new_file, 'r') as f:
        content = f.read()
        # Remove comments
        lines = [line for line in content.split('\n') if not line.strip().startswith('//')]
        content = '\n'.join(lines)
        new_data = json.loads(content)
    
    # Combine arrays, avoiding duplicates based on key+command+when
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
    
    # Write merged keybindings with comment
    output_file = '$output'
    with open(output_file, 'w') as f:
        f.write("// Place your key bindings in this file to override the defaults\n")
        json.dump(merged, f, indent=4)
    
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
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
echo ""
echo -e "${YELLOW}Note: You may need to restart Cursor for all settings to take effect.${NC}"
