#!/usr/bin/env bash
# Uninstall script for dotfiles repository
# This removes the bare git repository and dotfiles alias
# Does NOT uninstall system packages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Dotfiles Uninstallation ===${NC}"
echo ""
echo "This script will:"
echo "  - Remove the ~/.dotfiles bare repository"
echo "  - Remove dotfiles alias from shell configs"
echo "  - NOT remove any tracked dotfiles from your home directory"
echo "  - NOT uninstall any system packages"
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove the bare repository
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}Removing $DOTFILES_DIR...${NC}"
    rm -rf "$DOTFILES_DIR"
    echo -e "${GREEN}✓ Repository removed${NC}"
else
    echo -e "${YELLOW}Repository not found at $DOTFILES_DIR${NC}"
fi

# Remove alias from fish config
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONFIG" ]; then
    if grep -q "alias dotfiles" "$FISH_CONFIG" 2>/dev/null; then
        echo -e "${GREEN}Removing dotfiles alias from $FISH_CONFIG...${NC}"
        sed -i '/# Dotfiles management alias/d' "$FISH_CONFIG"
        sed -i '/alias dotfiles/d' "$FISH_CONFIG"
        echo -e "${GREEN}✓ Removed from fish config${NC}"
    fi
fi

# Remove alias from bashrc
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if grep -q "alias dotfiles" "$BASHRC" 2>/dev/null; then
        echo -e "${GREEN}Removing dotfiles alias from $BASHRC...${NC}"
        sed -i '/# Dotfiles management alias/d' "$BASHRC"
        sed -i '/alias dotfiles/d' "$BASHRC"
        echo -e "${GREEN}✓ Removed from bashrc${NC}"
    fi
fi

# Remove alias from zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q "alias dotfiles" "$ZSHRC" 2>/dev/null; then
        echo -e "${GREEN}Removing dotfiles alias from $ZSHRC...${NC}"
        sed -i '/# Dotfiles management alias/d' "$ZSHRC"
        sed -i '/alias dotfiles/d' "$ZSHRC"
        echo -e "${GREEN}✓ Removed from zshrc${NC}"
    fi
fi

# Check for backup directory
BACKUP_DIR="$HOME/.dotfiles-backup"
if [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo -e "${YELLOW}Found backup directory: $BACKUP_DIR${NC}"
    echo "This contains original files that were backed up during installation."
    read -p "Do you want to remove it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BACKUP_DIR"
        echo -e "${GREEN}✓ Backup directory removed${NC}"
    else
        echo "Backup directory kept."
    fi
fi

echo ""
echo -e "${GREEN}=== Uninstallation Complete ===${NC}"
echo ""
echo "Notes:"
echo "  - Your dotfiles (configs) are still in your home directory"
echo "  - Installed packages remain on the system"
echo "  - You may need to restart your shell for alias removal to take effect"
echo ""
echo "To reinstall, run the install script again:"
echo "  curl -s https://raw.githubusercontent.com/pop9459/dotfiles/from_scratch/dotfiles_stuff/scripts/install_dots.sh | bash -s from_scratch"
