# Hyprland Modular Configuration (Lua)

Since Hyprland 0.55 the config is Lua. `~/.config/hypr/hyprland.lua` loads these
modules with `require("conf.<name>")`. The `*.conf` files here are the legacy hyprlang
version and are no longer read by Hyprland.

## File Structure

- **programs.lua** - Default applications (returns a table: terminal, fileManager, menu, browser)
- **autostart.lua** - Programs started once at login (`hl.on("hyprland.start", ...)`)
- **environment.lua** - Environment variables (cursor size, GTK theme)
- **appearance.lua** - Visual settings (gaps, borders, colors, shadows, blur, misc, xwayland)
- **animations.lua** - Animation curves and settings
- **layouts.lua** - Window layout settings (dwindle, master)
- **input.lua** - Keyboard, mouse, touchpad, and gesture settings
- **keybinds.lua** - Keyboard shortcuts and mouse bindings
- **windowrules.lua** - Window rules and workspace rules

Generated, untracked files loaded optionally by `hyprland.lua`:

- `~/.config/hypr/monitors.lua` - written by nwg-displays (falls back to auto config if missing)
- `~/.config/hypr/colors.lua` - written by matugen from `~/.config/matugen/templates/colors-hyprland.lua`

## Current Keybinds (SUPER = mainMod)

- `SUPER` (tap) / `SUPER + R` - Launcher (fuzzel)
- `SUPER + T` / `E` / `B` - Terminal / file manager / browser
- `SUPER + Q` - Close window, `V` - toggle floating, `P` - pseudo, `F` - fullscreen
- `SUPER + DELETE` - Lock (hyprlock), `SUPER + N` - night light toggle
- `SUPER + CTRL + R` - Restart quickshell bar
- `SUPER + SHIFT + S` - Region screenshot to clipboard
- `SUPER + h/j/k/l` or arrows - Move focus; `+ SHIFT` move window; `+ ALT` resize
- `SUPER + CTRL + h/j/k/l/left/right` - Previous/next workspace; `+ SHIFT` takes the window along
- `SUPER + 1..0` - Switch workspace; `SUPER + SHIFT + 1..0` - move window to workspace
- `SUPER + scroll` - Next/previous workspace
- `SUPER + LMB/RMB drag` - Move/resize window
- Media, volume and brightness keys (volume/brightness show the quickshell OSD)

## How to Edit

1. Edit a `.lua` module
2. Check it: `Hyprland --verify-config` (must print `config ok`)
3. Hyprland reloads automatically on save (`hyprctl reload` to force)

Notes:
- `hyprctl dispatch` now takes Lua, e.g. `hyprctl dispatch 'hl.dsp.focus({ workspace = 2 })'`.
- Autostart only runs at login, not on reload.
