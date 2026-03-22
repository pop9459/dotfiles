# Hyprland Modular Configuration

This directory contains the modular configuration files for Hyprland.

## File Structure

- **monitors.conf** - Monitor configuration and display settings
- **programs.conf** - Default application definitions ($terminal, $fileManager, $menu)
- **autostart.conf** - Programs to start when Hyprland launches
- **environment.conf** - Environment variables (cursor size, etc.)
- **appearance.conf** - Visual settings (gaps, borders, colors, shadows, blur)
- **animations.conf** - Animation curves and settings
- **layouts.conf** - Window layout settings (dwindle, master)
- **input.conf** - Keyboard, mouse, touchpad, and gesture settings
- **keybinds.conf** - Keyboard shortcuts and mouse bindings
- **windowrules.conf** - Window rules and workspace rules

## Current Keybinds

### Basic Controls
- `CTRL + Q` - Close active window
- `CTRL + T` - Open kitty terminal

### System (with SUPER/Windows key)
- `SUPER + M` - Exit Hyprland
- `SUPER + E` - Open file manager
- `SUPER + R` - Open application launcher
- `SUPER + V` - Toggle floating mode
- Arrow keys with SUPER - Move focus between windows
- Numbers 1-0 with SUPER - Switch workspaces
- SHIFT + Numbers with SUPER - Move window to workspace

### Multimedia Keys
- Volume up/down, mute
- Brightness up/down
- Media playback controls (requires playerctl)

## How to Edit

1. Modify any of the `.conf` files directly
2. Save the changes
3. Reload Hyprland with `hyprctl reload` or re-login to apply changes

## Backup

The original monolithic config has been backed up to:
`~/.config/hypr/hyprland.conf.bak`
