# Copilot Instructions for Dotfiles Repository

## Repository Overview

This is a **bare Git repository** for managing dotfiles across Arch-based Linux systems (specifically CachyOS). Unlike a typical Git repo, dotfiles are tracked directly in the user's home directory (`~`) using a bare repository stored at `~/.dotfiles`.

## Key Architecture Concepts

### Bare Repository Structure

- The actual Git repository lives at `~/.dotfiles` (bare repository)
- The working tree is the entire home directory (`~`)
- Users interact via the `dotfiles` command, which is an alias for: `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`
- Files are tracked selectively (not the entire home directory)

### Installation Flow

1. `install_dots.sh` script (modular architecture):
   - Sources utility functions from `lib/utils.sh`
   - Calls `lib/install_dotfiles.sh` to set up bare repository
   - Calls `lib/install_paru.sh` to install AUR helper
2. Sets up the `dotfiles` command alias in shell RC files
3. Checks out dotfiles to the home directory
4. Configures the repo to not show untracked files (`git config --local status.showUntrackedFiles no`)
5. **Script is idempotent** - safe to run multiple times, will skip already-installed components

### Installation Script Structure

The installation scripts follow a modular architecture:

```
scripts/
├── install_dots.sh          # Main orchestrator
└── lib/
    ├── utils.sh             # Shared utilities (logging, checks, retry logic)
    ├── install_dotfiles.sh  # Bare repository setup
    └── install_paru.sh      # Paru AUR helper installation
```

**Key Features:**
- **Idempotent**: Checks if components are already installed before acting
- **Error Handling**: Retry prompts on failures with helpful recovery tips
- **Modular**: Easy to add new installation modules
- **Logging**: Color-coded output (INFO, SUCCESS, WARNING, ERROR)

## Important Conventions

### File Paths

- **Always use absolute paths from `~`** when referencing dotfiles (e.g., `.config/nvim/init.vim`, `.bashrc`)
- Don't include `~/` prefix when adding files: `dotfiles add .config/hypr/hyprland.conf` (not `~/`)
- The repository root conceptually IS the home directory

### Gitignore Strategy

- Since the work tree is `~`, the `.gitignore` should be **very permissive**
- By default, ignore everything except explicitly tracked dotfiles
- Pattern: Start with `*` to ignore all, then negate (`!`) specific files/directories to track

### System-Specific Files

This dotfiles setup is tailored for:
- **CachyOS** (Arch-based) with `pacman` + `paru` (AUR)
- **Hyprland** (Wayland compositor) with uwsm session management
- **fish** shell (not bash/zsh)
- Modern Wayland tooling (no X11 dependencies)

## Shell Commands

### For Users (with alias set up)

```bash
# Check status of tracked dotfiles
dotfiles status

# Add a new dotfile
dotfiles add .config/some/config.file

# Commit changes
dotfiles commit -m "Description"

# Push to remote
dotfiles push

# Pull updates
dotfiles pull
```

### For Copilot Sessions (use full command)

Since shell aliases may not be available in Copilot's bash sessions, use the full git command:

```bash
# Define as variable for cleaner commands (optional)
DOTFILES="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Or use directly:
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status
git --git-dir=$HOME/.dotfiles --work-tree=$HOME add .config/some/config.file
git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m "Description"
git --git-dir=$HOME/.dotfiles --work-tree=$HOME push
git --git-dir=$HOME/.dotfiles --work-tree=$HOME push origin <branch-name>
```

**Important**: When pushing, check the current branch with `git --git-dir=$HOME/.dotfiles --work-tree=$HOME branch` and push to the correct branch explicitly if needed.

## Stack Components

### Desktop Environment
- **Compositor**: Hyprland (managed by uwsm, not standalone)
- **Bar**: eww-wayland
- **Terminal**: kitty
- **Launcher**: fuzzel
- **Notifications**: mako
- **Lockscreen**: hyprlock
- **File Manager**: Nautilus (GUI) + yazi (CLI)

### Development Tools
- neovim (primary editor)
- VSCode
- Docker + Docker Compose
- Git + base-devel

## When Adding New Dotfiles

1. Ensure the file is in the home directory or a subdirectory
2. Add using: `dotfiles add <relative-path-from-home>`
3. Update README.md if adding a new tool/component category
4. Keep the bare repository setup in mind - avoid tracking large binaries or secrets

## When Adding New Installation Modules

To add a new installation component (e.g., install_hyprland.sh):

1. Create `scripts/lib/install_<component>.sh`
2. Follow the module pattern:
   - Check if already installed (idempotency)
   - Use utility functions from `utils.sh` (log_info, log_success, command_exists)
   - Implement retry logic for failures with `retry_on_failure` or custom prompts
   - Clean up temporary files/directories
3. Source the module in `install_dots.sh`
4. Add installation call in the main() function
5. Test idempotency (run script multiple times)
