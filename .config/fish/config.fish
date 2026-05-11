# Fish greeting
set -g fish_greeting # Add custom text here if wanted

# Dotfiles management alias
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Configure fzf.fish keybindings - use Alt+C for directory navigation
# fzf_configure_bindings --directory=\ec

# Customize fzf fd options to include .config directory specifically
set -gx fzf_fd_opts --hidden --exclude .git --exclude .cache --exclude .local --exclude .mozilla --exclude .npm --exclude .cargo

function yz
    # Create temp file for yazi to write cwd into
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")

    # Run yazi and tell it where to write the cwd
    command yazi $argv --cwd-file="$tmp"

    # Read the directory from the temp file
    if test -s "$tmp"
        set -l cwd (cat -- "$tmp")

        # If it’s valid and different, cd into it
        if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
            builtin cd -- "$cwd"
            commandline -f repaint   # refresh prompt
        end
    end

    # Clean up
    rm -f -- "$tmp"
end
