#!/usr/bin/env bash
# Main installation script for dotfiles and system setup
# Usage: ./install_dots.sh [branch]
#   branch: Git branch to checkout (default: main)

set -e

# Parse arguments
BRANCH="${1:-main}"

# Detect if running via curl pipe (no local script directory)
if [ -z "${BASH_SOURCE[0]}" ] || [ ! -d "$(dirname "${BASH_SOURCE[0]}")/lib" ]; then
    # Running via curl pipe - need to bootstrap
    echo "=== Bootstrapping Dotfiles Installation ==="
    
    # Configuration
    DOTFILES_REPO="https://github.com/pop9459/dotfiles.git"
    DOTFILES_DIR="$HOME/.dotfiles"
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed. Please install git first."
        exit 1
    fi
    
    # Clone or update dotfiles repository
    if [ -d "$DOTFILES_DIR" ]; then
        echo "Updating existing dotfiles repository..."
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" fetch origin
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout "$BRANCH" 2>/dev/null || true
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" pull origin "$BRANCH" 2>/dev/null || true
    else
        echo "Cloning dotfiles repository..."
        git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout "$BRANCH" 2>/dev/null || {
            # Handle conflicts by backing up
            mkdir -p "$HOME/.dotfiles-backup"
            git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout "$BRANCH" 2>&1 | \
                grep -E "^\s+" | awk '{print $1}' | \
                xargs -I{} mv "$HOME/{}" "$HOME/.dotfiles-backup/" 2>/dev/null || true
            git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout "$BRANCH"
        }
    fi
    
    # Now run the full installation script from the checked-out location
    SCRIPT_PATH="$HOME/dotfiles_stuff/scripts/install_dots.sh"
    if [ -f "$SCRIPT_PATH" ]; then
        echo "Running full installation script..."
        exec bash "$SCRIPT_PATH" "$BRANCH"
    else
        echo "Error: Installation script not found at $SCRIPT_PATH"
        exit 1
    fi
fi

# If we get here, we're running from a local checkout with lib files available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/utils.sh"

# Source installation modules
source "$SCRIPT_DIR/lib/install_dotfiles.sh"
source "$SCRIPT_DIR/lib/install_paru.sh"
source "$SCRIPT_DIR/lib/install_keyring.sh"
source "$SCRIPT_DIR/lib/install_matugen.sh"
source "$SCRIPT_DIR/lib/install_fish.sh"
source "$SCRIPT_DIR/lib/parse_packages.sh"
source "$SCRIPT_DIR/lib/install_packages.sh"

# Main installation flow
main() {
    log_header "Dotfiles System Installation"
    
    # Install dotfiles (will skip if already done in bootstrap)
    if ! install_dotfiles "$BRANCH"; then
        log_error "Dotfiles installation failed."
        exit 1
    fi
    
    # Install paru (AUR helper)
    if ! install_paru; then
        log_warning "Paru installation was skipped or failed."
        log_info "You can install it manually later if needed."
    fi
    
    # Set up system keyring for secure credential storage
    if ! install_keyring; then
        log_warning "Keyring setup was skipped or failed."
        log_info "CLI tools may not be able to store credentials securely."
    fi
    
    # Install matugen theme manager and generate initial theme
    if ! install_matugen; then
        log_warning "Matugen installation was skipped or failed."
        log_info "You can install it later with: sudo pacman -S matugen"
        log_info "Then generate theme with: matugen theme catppuccin-macchiato"
    fi
    
    # Install system packages
    local packages_file="$SCRIPT_DIR/packages.yaml"
    if [ -f "$packages_file" ]; then
        if ! install_all_packages "$packages_file"; then
            log_warning "Some packages failed to install, but continuing..."
        fi
    else
        log_warning "Package list not found: $packages_file"
        log_info "Skipping package installation."
    fi
    
    # Set up Fish shell plugins (fisher + fzf.fish)
    if ! install_fish_plugins; then
        log_warning "Fish plugin installation was skipped or failed."
        log_info "You can install them manually later with fish commands."
    fi
    
    # Success message
    echo ""
    log_header "Installation Complete!"
    echo ""
    echo "To start using the dotfiles command, either:"
    echo "  1. Restart your shell"
    echo "  2. Or run: source ~/.bashrc (or ~/.config/fish/config.fish for fish)"
    echo ""
    echo "Then you can use: dotfiles status, dotfiles add, dotfiles commit, etc."
    echo ""
    log_info "Theme Management:"
    echo "  - Switch themes with: theme-switch catppuccin-mocha"
    echo "  - Available: catppuccin-mocha, catppuccin-macchiato, catppuccin-frappe, catppuccin-latte"
    echo "  - Generate from wallpaper: theme-switch /path/to/wallpaper.png"
}

# Run main function
main
