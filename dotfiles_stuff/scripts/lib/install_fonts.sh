#!/usr/bin/env bash
# Font Installation Module
# Installs essential fonts for the desktop environment

install_fonts() {
    log_info "Installing fonts..."
    
    # Check if JetBrains Mono Nerd Font is already installed
    if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        log_success "JetBrainsMono Nerd Font already installed"
    else
        log_info "Installing JetBrainsMono Nerd Font..."
        if paru -S --needed --noconfirm ttf-jetbrains-mono-nerd; then
            log_success "JetBrainsMono Nerd Font installed"
        else
            log_error "Failed to install JetBrainsMono Nerd Font"
            retry_on_failure "install_jetbrains_font" "paru -S --needed ttf-jetbrains-mono-nerd"
        fi
    fi
    
    # Check if Font Awesome is already installed
    if fc-list | grep -qi "Font Awesome"; then
        log_success "Font Awesome already installed"
    else
        log_info "Installing Font Awesome..."
        if paru -S --needed --noconfirm ttf-font-awesome; then
            log_success "Font Awesome installed"
        else
            log_error "Failed to install Font Awesome"
            retry_on_failure "install_fontawesome" "paru -S --needed ttf-font-awesome"
        fi
    fi
    
    # Rebuild font cache
    log_info "Rebuilding font cache..."
    fc-cache -fv > /dev/null 2>&1
    log_success "Font cache rebuilt"
    
    log_success "Font installation complete"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts
fi
