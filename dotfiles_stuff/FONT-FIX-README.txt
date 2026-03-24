====================================================================
  FONT FIX - QUICK REFERENCE
====================================================================

PROBLEM: Square symbols (□) appear instead of icons

CAUSE: Missing JetBrainsMono Nerd Font

SOLUTION: Run this command:

    cd ~/dotfiles_stuff/scripts && ./install_fonts_simple.sh

This will:
  ✓ Install ttf-jetbrains-mono-nerd
  ✓ Install ttf-font-awesome  
  ✓ Rebuild font cache
  ✓ Show next steps

After installation, restart applications:
  • Kitty: Close and reopen
  • eww: killall eww && eww daemon && eww open bar
  • Browsers: Restart completely

====================================================================

Alternative installation methods:

  1. Full-featured installer:
     cd ~/dotfiles_stuff/scripts && ./fix_fonts.sh

  2. Manual installation:
     paru -S ttf-jetbrains-mono-nerd ttf-font-awesome
     fc-cache -fv

====================================================================

For detailed documentation, see:
  ~/dotfiles_stuff/FONTS.md

====================================================================
