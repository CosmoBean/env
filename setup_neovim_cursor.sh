#!/bin/bash

# Script to set up Neovim for use with Cursor/VSCode
# This script will:
# 1. Check if Neovim is installed
# 2. Install Neovim if needed (via Homebrew on macOS)
# 3. Link your Neovim config to ~/.config/nvim
# 4. Install the vscode-neovim extension in Cursor
# 5. Configure Cursor settings for Neovim

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_SRC="$SCRIPT_DIR/nvim"
NVIM_CONFIG_TARGET="$HOME/.config/nvim"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SETTINGS="$CURSOR_USER_DIR/settings.json"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Neovim + Cursor Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Check if Neovim is installed
echo -e "${GREEN}Step 1: Checking Neovim installation...${NC}"
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version | head -1)
    echo -e "${GREEN}✓ Neovim is installed: $NVIM_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Neovim is not installed${NC}"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}Installing Neovim via Homebrew...${NC}"
        
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Error: Homebrew is not installed.${NC}"
            echo -e "${YELLOW}Please install Homebrew first:${NC}"
            echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            echo ""
            echo -e "${YELLOW}Or install Neovim manually from: https://github.com/neovim/neovim/releases${NC}"
            exit 1
        fi
        
        brew install neovim
        echo -e "${GREEN}✓ Neovim installed successfully${NC}"
    else
        echo -e "${RED}Error: Neovim is not installed.${NC}"
        echo -e "${YELLOW}Please install Neovim manually:${NC}"
        echo "  - macOS: brew install neovim"
        echo "  - Linux: Check your distribution's package manager"
        echo "  - Or download from: https://github.com/neovim/neovim/releases"
        exit 1
    fi
fi

# Step 2: Set up Neovim config
echo ""
echo -e "${GREEN}Step 2: Setting up Neovim configuration...${NC}"

if [ ! -d "$NVIM_CONFIG_SRC" ]; then
    echo -e "${RED}Error: Neovim config directory not found at $NVIM_CONFIG_SRC${NC}"
    exit 1
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Backup existing config if it exists
if [ -d "$NVIM_CONFIG_TARGET" ] || [ -L "$NVIM_CONFIG_TARGET" ]; then
    BACKUP_DIR="$NVIM_CONFIG_TARGET.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}⚠ Existing Neovim config found. Backing up to: $BACKUP_DIR${NC}"
    mv "$NVIM_CONFIG_TARGET" "$BACKUP_DIR"
fi

# Create symlink to your Neovim config
echo -e "${GREEN}Creating symlink: $NVIM_CONFIG_TARGET -> $NVIM_CONFIG_SRC${NC}"
ln -sf "$NVIM_CONFIG_SRC" "$NVIM_CONFIG_TARGET"
echo -e "${GREEN}✓ Neovim config linked successfully${NC}"

# Step 3: Check/Update Cursor settings
echo ""
echo -e "${GREEN}Step 3: Configuring Cursor settings...${NC}"

# Get Neovim path
NVIM_PATH=$(which nvim)
if [ -z "$NVIM_PATH" ]; then
    echo -e "${RED}Error: Could not find Neovim path${NC}"
    exit 1
fi

# Check if settings.json exists
if [ ! -f "$CURSOR_SETTINGS" ]; then
    echo -e "${YELLOW}⚠ Cursor settings.json not found. Creating it...${NC}"
    mkdir -p "$CURSOR_USER_DIR"
    echo "{}" > "$CURSOR_SETTINGS"
fi

# Update settings.json with Neovim configuration
echo -e "${GREEN}Updating Cursor settings for Neovim...${NC}"

python3 << EOF
import json
import os

settings_file = "$CURSOR_SETTINGS"
nvim_path = "$NVIM_PATH"

# Read existing settings
with open(settings_file, 'r') as f:
    settings = json.load(f)

# Add/update Neovim settings
settings["vscode-neovim.neovimExecutablePaths.darwin"] = nvim_path
settings["vscode-neovim.neovimInitVimPaths.darwin"] = os.path.expanduser("~/.config/nvim/init.lua")

# Ensure extension affinity is set
if "extensions.experimental.affinity" not in settings:
    settings["extensions.experimental.affinity"] = {}
settings["extensions.experimental.affinity"]["asvetliakov.vscode-neovim"] = 1

# Ensure compositeKeys is set
if "vscode-neovim.compositeKeys" not in settings:
    settings["vscode-neovim.compositeKeys"] = {}

# Write back
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)

print("✓ Cursor settings updated")
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Cursor settings configured${NC}"
else
    echo -e "${RED}Error updating Cursor settings${NC}"
    exit 1
fi

# Step 4: Install extension instructions
echo ""
echo -e "${GREEN}Step 4: Install vscode-neovim extension${NC}"
echo -e "${YELLOW}You need to install the extension manually:${NC}"
echo ""
echo -e "${BLUE}Option 1: Via Cursor UI${NC}"
echo "  1. Open Cursor"
echo "  2. Press Cmd+Shift+X (or View > Extensions)"
echo "  3. Search for 'vscode-neovim'"
echo "  4. Click Install on 'asvetliakov.vscode-neovim'"
echo ""
echo -e "${BLUE}Option 2: Via Command Line${NC}"
echo "  cursor --install-extension asvetliakov.vscode-neovim"
echo ""

# Step 5: Verify setup
echo ""
echo -e "${GREEN}Step 5: Verifying setup...${NC}"

# Check Neovim config
if [ -L "$NVIM_CONFIG_TARGET" ] || [ -d "$NVIM_CONFIG_TARGET" ]; then
    echo -e "${GREEN}✓ Neovim config is set up${NC}"
else
    echo -e "${RED}✗ Neovim config not found${NC}"
fi

# Check if init.lua exists
if [ -f "$NVIM_CONFIG_TARGET/init.lua" ]; then
    echo -e "${GREEN}✓ Neovim init.lua found${NC}"
else
    echo -e "${YELLOW}⚠ Neovim init.lua not found (this might be okay if using init.vim)${NC}"
fi

# Check Cursor settings
if grep -q "vscode-neovim.neovimExecutablePaths" "$CURSOR_SETTINGS" 2>/dev/null; then
    echo -e "${GREEN}✓ Cursor settings configured for Neovim${NC}"
else
    echo -e "${YELLOW}⚠ Cursor settings might not be fully configured${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Install the vscode-neovim extension in Cursor (see instructions above)"
echo "  2. Restart Cursor completely"
echo "  3. Open a file in Cursor and try Neovim commands!"
echo ""
echo -e "${BLUE}Your Neovim config is located at:${NC}"
echo "  $NVIM_CONFIG_TARGET"
echo ""
echo -e "${BLUE}Useful Neovim keybindings in Cursor:${NC}"
echo "  - <leader>e  : Toggle sidebar (explorer)"
echo "  - <leader>f  : Quick open file"
echo "  - <leader>r  : Focus terminal"
echo "  - <leader>c  : Comment line"
echo "  - Ctrl+h/j/k/l : Navigate between panes"
echo ""
echo -e "${YELLOW}Note: Your Neovim config automatically detects when running in VSCode/Cursor${NC}"
echo -e "${YELLOW}and loads the appropriate configuration from nvconf_vscode/${NC}"
