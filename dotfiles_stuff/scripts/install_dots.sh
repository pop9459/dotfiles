#!/usr/bin/env bash
# Main installation script for dotfiles and system setup
# Usage: ./install_dots.sh [branch]
#   branch: Git branch to checkout (default: main)

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/utils.sh"

# Source installation modules
source "$SCRIPT_DIR/lib/install_dotfiles.sh"
source "$SCRIPT_DIR/lib/install_paru.sh"

# Parse arguments
BRANCH="${1:-main}"

# Main installation flow
main() {
    log_header "Dotfiles System Installation"
    
    # Check prerequisites
    if ! command_exists git; then
        log_error "git is not installed. Please install git first."
        exit 1
    fi
    
    # Install dotfiles
    if ! install_dotfiles "$BRANCH"; then
        log_error "Dotfiles installation failed."
        exit 1
    fi
    
    # Install paru (AUR helper)
    if ! install_paru; then
        log_warning "Paru installation was skipped or failed."
        log_info "You can install it manually later if needed."
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
}

# Run main function
main
