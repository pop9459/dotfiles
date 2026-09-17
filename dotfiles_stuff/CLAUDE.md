# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

Bare-git dotfiles repo for Arch-based Linux (CachyOS), Hyprland/Wayland desktop, fish shell. Two distinct parts:

1. **This checkout** (`~/dotfiles_stuff`): install scripts, package list, font docs. Not itself a git repo.
2. **The bare dotfiles repo** at `~/.dotfiles`, working tree `~` (home directory). Tracks selected dotfiles directly in `$HOME`.

## Working with the bare dotfiles repo

No `dotfiles` shell alias in Claude Code bash sessions — use the full command:

```bash
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status
git --git-dir=$HOME/.dotfiles --work-tree=$HOME add .config/some/config.file
git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m "Description"
git --git-dir=$HOME/.dotfiles --work-tree=$HOME push origin <branch-name>
```

- Always use paths relative to `$HOME`, no `~/` prefix (`dotfiles add .config/hypr/hyprland.conf`).
- Check current branch before pushing (`... branch`) and push to it explicitly.
- Repo config sets `status.showUntrackedFiles no` — status only shows tracked files.
- `.gitignore` strategy: ignore everything (`*`), then negate (`!`) specific tracked paths.

## Install/uninstall scripts (`scripts/`)

No build, lint, or test tooling — these are bash scripts run directly.

```bash
./scripts/install_dots.sh [branch]      # full install, default branch=main, idempotent
./scripts/uninstall_dots.sh
./scripts/fix_fonts.sh                  # or install_fonts_simple.sh
```

`install_dots.sh` has a bootstrap mode: if run outside a local checkout with `lib/` (e.g. via curl pipe), it clones `~/.dotfiles` bare, checks out the branch, then re-execs itself from `~/dotfiles_stuff/scripts/install_dots.sh`.

Main flow (`main()` in `install_dots.sh`), each step logs a warning and continues on failure rather than aborting:
`install_dotfiles` → `install_paru` → `install_keyring` → `install_matugen` → `install_all_packages` (from `packages.yaml`) → `install_fonts` → `install_fish_plugins`.

Modules live in `scripts/lib/`, each sourced by `install_dots.sh`:
- `utils.sh` — shared logging (`log_info/success/warning/error/header`), `command_exists`, `is_installed` (pacman), `ask_yes_no`, retry helpers. Source this first when writing/testing a module standalone.
- `install_dotfiles.sh` — bare repo clone/checkout setup.
- `install_paru.sh`, `install_keyring.sh`, `install_matugen.sh`, `install_fish.sh`, `install_fonts.sh` — one concern each.
- `parse_packages.sh` — hand-rolled YAML parser for `packages.yaml` (no yq/python dependency). `parse_packages <file> <category> <type>` where type is `official` or `aur`; `get_categories`; `get_category_description`. Parsing is line-based and format-sensitive — keep `packages.yaml` structure (category → `description`/`official`/`aur` keys → `- pkg` list) intact when editing.
- `install_packages.sh` — drives package installation using the parser, split by official (pacman) vs AUR (paru).

**Adding a new install module**: create `scripts/lib/install_<component>.sh` following the existing pattern (idempotency check first, use `utils.sh` logging, retry on failure, clean up temp files), source it in `install_dots.sh`, and call it from `main()`.

**Adding packages**: edit `packages.yaml` under the right category (`system`, `desktop`, `wayland`, `dev-tools`, ...), under `official:` or `aur:`.

## Stack / conventions

- Compositor: Hyprland via uwsm (not standalone). Bar: eww-wayland. Terminal: kitty. Launcher: fuzzel. Notifications: mako. Lockscreen: hyprlock. Files: Nautilus (GUI) + yazi (CLI).
- Theming: matugen + catppuccin variants (mocha/macchiato/frappe/latte), switched via `theme-switch <flavor>` or `theme-switch /path/to/wallpaper.png`.
- Shell: fish, not bash/zsh, for interactive use (install scripts themselves are bash).
- Fonts: JetBrainsMono Nerd Font + Font Awesome are required for icons in kitty/eww; see `FONTS.md` for troubleshooting squares/missing-glyph symptoms. Configured in `~/.config/kitty/kitty.conf` and `~/.config/eww/eww.scss`.
