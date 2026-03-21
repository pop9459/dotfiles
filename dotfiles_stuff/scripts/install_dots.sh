#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Dotfiles Installation ===${NC}"

# Configuration
DOTFILES_REPO="https://github.com/pop9459/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BRANCH="main"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed. Please install git first.${NC}"
    exit 1
fi

# Check if .dotfiles already exists
if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}Warning: $DOTFILES_DIR already exists.${NC}"
    read -p "Do you want to remove it and reinstall? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$DOTFILES_DIR"
    else
        echo "Installation cancelled."
        exit 1
    fi
fi

# Clone the bare repository
echo -e "${GREEN}Cloning bare repository to $DOTFILES_DIR...${NC}"
git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

# Define the dotfiles command for this session
function dotfiles {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# Configure the repository
echo -e "${GREEN}Configuring repository...${NC}"
dotfiles config --local status.showUntrackedFiles no

# Checkout the branch
echo -e "${GREEN}Checking out dotfiles...${NC}"
if ! dotfiles checkout "$BRANCH" 2>&1 | grep -q "error: The following untracked working tree files would be overwritten"; then
    dotfiles checkout "$BRANCH"
else
    echo -e "${YELLOW}Warning: Some files would be overwritten. Creating backup...${NC}"
    mkdir -p "$HOME/.dotfiles-backup"
    dotfiles checkout "$BRANCH" 2>&1 | grep -E "^\s+" | awk '{print $1}' | xargs -I{} mv "$HOME/{}" "$HOME/.dotfiles-backup/"
    dotfiles checkout "$BRANCH"
    echo -e "${GREEN}Original files backed up to $HOME/.dotfiles-backup${NC}"
fi

# Setup alias in appropriate shell config
echo -e "${GREEN}Setting up dotfiles alias...${NC}"

ALIAS_LINE='alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"'

# Detect shell and add alias
if [ -n "$FISH_VERSION" ] || command -v fish &> /dev/null; then
    # Fish shell
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    
    if ! grep -q "alias dotfiles" "$FISH_CONFIG" 2>/dev/null; then
        echo "" >> "$FISH_CONFIG"
        echo "# Dotfiles management alias" >> "$FISH_CONFIG"
        echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> "$FISH_CONFIG"
        echo -e "${GREEN}Added alias to $FISH_CONFIG${NC}"
    fi
fi

# Also add to bashrc for compatibility
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if ! grep -q "alias dotfiles" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# Dotfiles management alias" >> "$BASHRC"
        echo "$ALIAS_LINE" >> "$BASHRC"
        echo -e "${GREEN}Added alias to $BASHRC${NC}"
    fi
fi

# Also add to zshrc if it exists
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -q "alias dotfiles" "$ZSHRC" 2>/dev/null; then
        echo "" >> "$ZSHRC"
        echo "# Dotfiles management alias" >> "$ZSHRC"
        echo "$ALIAS_LINE" >> "$ZSHRC"
        echo -e "${GREEN}Added alias to $ZSHRC${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "To start using the dotfiles command, either:"
echo "  1. Restart your shell"
echo "  2. Or run: source ~/.bashrc (or ~/.config/fish/config.fish for fish)"
echo ""
echo "Then you can use: dotfiles status, dotfiles add, dotfiles commit, etc."
