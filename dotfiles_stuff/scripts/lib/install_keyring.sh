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
    
    # Check if Hyprland autostart config exists
    local autostart_conf="$HOME/.config/hypr/conf/autostart.conf"
    
    if [ ! -f "$autostart_conf" ]; then
        log_warning "Hyprland autostart config not found at $autostart_conf"
        log_info "Skipping Hyprland keyring configuration"
        return 0
    fi
    
    # Add D-Bus environment update and keyring daemon restart to Hyprland autostart
    local dbus_marker="dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=GNOME"
    
    if grep -q "XDG_CURRENT_DESKTOP=GNOME" "$autostart_conf"; then
        log_info "Hyprland keyring autostart already configured"
    else
        log_info "Adding keyring detection fixes to Hyprland autostart..."
        
        # Find the line with keyring daemon or the AUTOSTART header to insert after
        if grep -q "gnome-keyring-daemon" "$autostart_conf"; then
            # Insert before existing gnome-keyring-daemon line
            sed -i "/^# GNOME keyring daemon/i\\
# D-Bus environment update for keyring detection (fixes VS Code/Copilot CLI Secret Service API)\\
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=GNOME\\
\\
" "$autostart_conf"
            
            # Add restart command after gnome-keyring-daemon line
            sed -i "/^exec-once = gnome-keyring-daemon/a\\
exec-once = systemctl --user restart gnome-keyring-daemon" "$autostart_conf"
            
            log_success "Added keyring detection fixes to Hyprland autostart"
        else
            log_warning "Could not find gnome-keyring-daemon in autostart config"
            log_info "Manual configuration may be needed"
        fi
    fi
    
    log_success "Keyring setup complete"
    log_warning "IMPORTANT: Log out and log back in for changes to take effect"
    log_info "After re-login, CLI tools like gh and copilot will use secure keyring storage"
    
    return 0
}
