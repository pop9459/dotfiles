#!/usr/bin/env bash
# Install and configure gnome-keyring for secure credential storage
# Fixes VS Code Settings Sync and Copilot CLI keyring detection on Hyprland

install_keyring() {
    log_header "Setting Up System Keyring"
    
    # Check if gnome-keyring is installed
    if ! is_installed "gnome-keyring"; then
        log_info "Installing gnome-keyring..."
        if ! sudo pacman -S --noconfirm gnome-keyring; then
            log_error "Failed to install gnome-keyring"
            return 1
        fi
    else
        log_info "gnome-keyring is already installed"
    fi
    
    # Check if libsecret is installed (needed for CLI tools to access keyring via Secret Service API)
    if ! is_installed "libsecret"; then
        log_info "Installing libsecret..."
        if ! sudo pacman -S --noconfirm libsecret; then
            log_warning "Failed to install libsecret, but continuing..."
        fi
    else
        log_info "libsecret is already installed"
    fi
    
    # Hyprland 0.55+ uses a Lua config. The keyring fix (D-Bus activation environment update)
    # ships in the tracked ~/.config/hypr/conf/autostart.lua, so only verify it here.
    # gnome-keyring-daemon itself is started and unlocked by PAM at login: do not restart it
    # from Hyprland, or the new instance comes up locked.
    local autostart_lua="$HOME/.config/hypr/conf/autostart.lua"
    
    if [ ! -f "$autostart_lua" ]; then
        log_warning "Hyprland autostart config not found at $autostart_lua"
        log_info "Skipping Hyprland keyring check"
    elif grep -q "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" "$autostart_lua"; then
        log_info "Hyprland keyring autostart already configured"
    else
        log_warning "D-Bus environment update missing from $autostart_lua"
        log_info "Add inside the hl.on(\"hyprland.start\", ...) block:"
        log_info "  hl.exec_cmd(\"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP\")"
    fi
    
    log_success "Keyring setup complete"
    log_warning "IMPORTANT: Log out and log back in for changes to take effect"
    log_info "After re-login, CLI tools like gh and copilot will use secure keyring storage"
    
    return 0
}
