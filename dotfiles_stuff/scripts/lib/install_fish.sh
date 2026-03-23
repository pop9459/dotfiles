#!/usr/bin/env bash
# Fish shell setup module
# Installs fisher plugin manager and fzf.fish plugin

install_fish_plugins() {
    log_info "Setting up Fish shell plugins..."
    
    # Check if fish is installed
    if ! command_exists fish; then
        log_warning "Fish shell is not installed. Install it first with: sudo pacman -S fish"
        return 1
    fi
    
    # Check if fisher is already installed
    if fish -c "type -q fisher" 2>/dev/null; then
        log_success "Fisher plugin manager already installed"
    else
        log_info "Installing Fisher plugin manager..."
        if fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null; then
            log_success "Fisher installed successfully"
        else
            log_error "Failed to install Fisher"
            return 1
        fi
    fi
    
    # Check if fzf.fish plugin is already installed
    if fish -c "type -q fzf_configure_bindings" 2>/dev/null; then
        log_success "fzf.fish plugin already installed"
    else
        log_info "Installing fzf.fish plugin..."
        if fish -c "fisher install PatrickF1/fzf.fish" 2>/dev/null; then
            log_success "fzf.fish plugin installed successfully"
        else
            log_error "Failed to install fzf.fish plugin"
            log_info "You can install it manually later with: fisher install PatrickF1/fzf.fish"
            return 1
        fi
    fi
    
    log_success "Fish shell plugins setup complete"
    return 0
}
