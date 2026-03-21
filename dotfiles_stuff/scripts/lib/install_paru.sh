#!/usr/bin/env bash
# Paru AUR helper installation module

install_paru() {
    log_header "Installing Paru (AUR Helper)"
    
    # Check if paru is already installed
    if command_exists paru; then
        local paru_version=$(paru --version | head -n1)
        log_success "Paru is already installed: $paru_version"
        return 0
    fi
    
    log_info "Paru not found. Installing..."
    
    # Check if base-devel is installed (required for building AUR packages)
    if ! is_installed base-devel; then
        log_info "Installing base-devel (required for AUR builds)..."
        if ! sudo pacman -S --needed --noconfirm base-devel; then
            log_error "Failed to install base-devel."
            if ask_yes_no "Do you want to retry?"; then
                return $(install_paru)
            else
                log_warning "Skipping paru installation. You can install it later with: cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
                return 1
            fi
        fi
        log_success "base-devel installed successfully."
    else
        log_info "base-devel is already installed."
    fi
    
    # Check if git is installed (should be, but double-check)
    if ! command_exists git; then
        log_error "git is required but not installed."
        log_info "Installing git..."
        if ! sudo pacman -S --needed --noconfirm git; then
            log_error "Failed to install git."
            return 1
        fi
    fi
    
    # Clone and build paru
    local build_dir="/tmp/paru-build-$$"
    log_info "Cloning paru from AUR to $build_dir..."
    
    if ! git clone https://aur.archlinux.org/paru.git "$build_dir"; then
        log_error "Failed to clone paru repository."
        if ask_yes_no "Do you want to retry?"; then
            rm -rf "$build_dir"
            return $(install_paru)
        else
            return 1
        fi
    fi
    
    log_info "Building and installing paru..."
    cd "$build_dir"
    
    if ! makepkg -si --noconfirm; then
        log_error "Failed to build/install paru."
        log_info "Common issues:"
        log_info "  - Missing dependencies: Install base-devel"
        log_info "  - Permission issues: Ensure you have sudo access"
        log_info "  - Network issues: Check internet connection"
        
        if ask_yes_no "Do you want to retry?"; then
            cd - > /dev/null
            rm -rf "$build_dir"
            return $(install_paru)
        else
            cd - > /dev/null
            rm -rf "$build_dir"
            log_warning "Paru installation skipped."
            return 1
        fi
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$build_dir"
    
    # Verify installation
    if command_exists paru; then
        local paru_version=$(paru --version | head -n1)
        log_success "Paru installed successfully: $paru_version"
        return 0
    else
        log_error "Paru installation completed but command not found."
        log_info "You may need to restart your shell or run: source ~/.bashrc"
        return 1
    fi
}
