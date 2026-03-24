#!/usr/bin/env bash
# Standalone font fix script
# Installs missing fonts for proper icon and symbol rendering

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities and font installer
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/install_fonts.sh"

log_header "Font Installation & Fix"

# Run font installation
if install_fonts; then
    log_success "All fonts installed successfully!"
    echo ""
    log_info "Restart your applications to see the changes:"
    log_info "  - Kitty: Close all windows and reopen"
    log_info "  - eww: killall eww && eww daemon && eww open bar"
    log_info "  - Chrome/Browser: Restart the browser"
else
    log_error "Font installation failed."
    echo ""
    log_info "Manual installation command:"
    log_info "  paru -S ttf-jetbrains-mono-nerd ttf-font-awesome"
    exit 1
fi
