# Dotfiles

My personal dotfiles for Arch-based Linux, managed as a bare Git repository.

## 🚀 Quick Install (New Machine)

### Stable Version (main branch)

```bash
curl -s https://raw.githubusercontent.com/pop9459/dotfiles/main/dotfiles_stuff/scripts/install_dots.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/pop9459/dotfiles.git ~/dotfiles-temp
bash ~/dotfiles-temp/dotfiles_stuff/scripts/install_dots.sh
rm -rf ~/dotfiles-temp
```

### Development Version (from_scratch branch)

⚠️ **Current active development branch** - includes latest features but may be unstable.

```bash
curl -s https://raw.githubusercontent.com/pop9459/dotfiles/from_scratch/dotfiles_stuff/scripts/install_dots.sh | bash
```

Or clone and run:

```bash
git clone --branch from_scratch https://github.com/pop9459/dotfiles.git ~/dotfiles-temp
bash ~/dotfiles-temp/dotfiles_stuff/scripts/install_dots.sh
rm -rf ~/dotfiles-temp
```

### After Installation

Restart your shell or run:
```bash
source ~/.bashrc  # or ~/.config/fish/config.fish for fish shell
```

## 💻 Usage

Once installed, use the `dotfiles` command like git:

```bash
dotfiles status                    # Check status
dotfiles add .config/nvim/init.vim # Stage a file
dotfiles commit -m "Update nvim"   # Commit changes
dotfiles push                      # Push to GitHub
dotfiles pull                      # Pull latest changes
dotfiles log                       # View history
```

## Components

### Core System

- **Distro**: CachyOS
- **Kernel**: linux-cachyos
- **Package Manager**: pacman + paru (AUR)
- **Bootloader**: Limine
- **Shell**: fish


### Desktop Environment

- **WM/Compositor**: Hyprland (uwsm-managed session)
- **Display Manager**: ly
- **Status Bar**: eww-wayland
- **Launcher**: fuzzel
- **Notifications**: mako
- **Lockscreen**: hyprlock
- **Wallpaper**: hyprpaper
- **Terminal**: kitty
- **File Manager**: Nautilus (Nextcloud) + yazi (CLI)


### Wayland Essentials

- **Clipboard**: wl-clipboard
- **XDG Portal**: xdg-desktop-portal-hyprland
- **Polkit**: hyprpolkitagent
- **Multi-monitor**: kanshi
- **Screenshots**: grim + slurp


### System Services

- **Audio**: PipeWire + WirePlumber + pipewire-pulse
- **Network**: NetworkManager + nmtui
- **Bluetooth**: bluez + bluez-utils
- **Fonts**: ttf-font-awesome, noto-fonts, ttf-jetbrains-mono-nerd


### Development Tools

- **Version Control**: git + base-devel
- **Containers**: docker + docker-compose
- **Editor**: neovim + code (VSCode)
- **Browser**: zen-browser-bin
- **CLI Utils**: fzf, bat, btop, neofetch, lazydocker-bin
- **Sync**: nextcloud

***

## ⚙️ Repository

- **GitHub**: [pop9459/dotfiles](https://github.com/pop9459/dotfiles)
- **Main Branch**: `main` (stable)
- **Dev Branch**: `from_scratch` (active development)

