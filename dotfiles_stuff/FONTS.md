# Font Configuration & Troubleshooting

## Required Fonts

This dotfiles configuration requires the following fonts:

### Primary Font
- **ttf-jetbrains-mono-nerd**: JetBrainsMono with Nerd Font icons
  - Used by: Kitty terminal, eww status bar
  - Provides: Programming ligatures + icon glyphs

### Icon Fonts  
- **ttf-font-awesome**: Font Awesome icons
  - Used by: Various UI elements
  - Provides: Additional icon set

### System Fonts (usually pre-installed)
- **noto-fonts**: Standard sans-serif font
- **noto-fonts-cjk**: Chinese/Japanese/Korean support
- **noto-fonts-emoji**: Emoji rendering

## Symptoms of Missing Fonts

If you see **squares (□)** or **question marks (�)** instead of icons/symbols, fonts are missing or not properly configured.

## Quick Fix

Run the font installation script:

```bash
cd ~/dotfiles_stuff/scripts
./fix_fonts.sh
```

## Manual Installation

If the script fails, install manually:

```bash
paru -S ttf-jetbrains-mono-nerd ttf-font-awesome
fc-cache -fv
```

## Font Configuration Locations

- **Kitty**: `~/.config/kitty/kitty.conf`
  ```conf
  font_family JetBrainsMono Nerd Font
  ```

- **eww**: `~/.config/eww/eww.scss`
  ```scss
  font-family: "JetBrainsMono Nerd Font", monospace;
  ```

- **GTK**: `~/.config/gtk-3.0/settings.ini`
  ```ini
  gtk-font-name=Noto Sans, 10
  ```

## Verifying Installation

Check if fonts are installed:

```bash
fc-list | grep -i "JetBrainsMono Nerd Font"
fc-list | grep -i "Font Awesome"
```

If you see output, the fonts are installed.

## Applying Changes

After installing fonts:

1. **Rebuild font cache**: `fc-cache -fv`
2. **Restart applications**:
   - Kitty: Close and reopen all windows
   - eww: `killall eww && eww daemon && eww open bar`
   - Browsers: Restart completely
3. **Reboot** (if symbols still don't appear)

## Alternative Fonts

If you prefer different fonts, edit:
- `~/.config/kitty/kitty.conf` → Change `font_family`
- `~/.config/eww/eww.scss` → Change `font-family`

Available Nerd Fonts on the system:
```bash
fc-list : family | grep -i "nerd"
```

## Troubleshooting

### Fonts installed but symbols still show as squares

1. Clear font cache: `fc-cache -fv`
2. Check if font is recognized: `fc-match "JetBrainsMono Nerd Font"`
3. Restart your session (log out/log in)

### Wrong font rendering in terminal

Kitty may not refresh font settings. Force reload:
```bash
killall kitty  # Close all instances
kitty &        # Start fresh
```

### Icons missing in status bar (eww)

eww requires full restart:
```bash
killall eww
eww daemon
eww open bar
```

## Integration with Installation Script

The main installation script (`install_dots.sh`) now includes font installation automatically. Fonts are installed after packages but before Fish plugins.

To skip font installation during setup:
```bash
# Comment out the font installation call in install_dots.sh
# Or install manually later with ./fix_fonts.sh
```
