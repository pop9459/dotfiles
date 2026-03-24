#!/usr/bin/env bash
# One-line font installation for when sudo is available
# This script runs non-interactively if sudo credentials are cached

echo "=== Installing Missing Fonts ==="
echo ""
echo "This will install:"
echo "  - ttf-jetbrains-mono-nerd (JetBrainsMono with icon glyphs)"
echo "  - ttf-font-awesome (Icon font)"
echo ""

# Install fonts
if paru -S --needed ttf-jetbrains-mono-nerd ttf-font-awesome; then
    echo ""
    echo "✓ Fonts installed successfully!"
    
    # Rebuild font cache
    echo ""
    echo "Rebuilding font cache..."
    fc-cache -fv > /dev/null 2>&1
    echo "✓ Font cache rebuilt"
    
    echo ""
    echo "=== NEXT STEPS ==="
    echo ""
    echo "Restart your applications to see the changes:"
    echo "  1. Kitty terminal: Close all windows and reopen"
    echo "  2. eww status bar: killall eww && eww daemon && eww open bar"
    echo "  3. Browsers: Restart completely"
    echo ""
    echo "If symbols still appear as squares, try logging out and back in."
else
    echo ""
    echo "✗ Font installation failed or was cancelled"
    echo ""
    echo "You can try again later with:"
    echo "  cd ~/dotfiles_stuff/scripts && ./install_fonts_simple.sh"
    exit 1
fi
