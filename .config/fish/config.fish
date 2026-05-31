# Fish greeting
set -g fish_greeting # Add custom text here if wanted

# Dotfiles management alias
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Configure fzf.fish keybindings - use Alt+C for directory navigation
# fzf_configure_bindings --directory=\ec

# Customize fzf fd options to include .config directory specifically
set -gx fzf_fd_opts --hidden --exclude .git --exclude .cache --exclude .local --exclude .mozilla --exclude .npm --exclude .cargo --exclude .dotfiles-backup

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


function fish_prompt
    set -l host (prompt_hostname)
    set -l cwd (pwd)
    if test -n "$HOME"
        if test "$cwd" = "$HOME"; or string match -q "$HOME/*" -- $cwd
            set cwd (string replace -r "^$HOME" "~" -- $cwd)
        end
    end
    set -l git_indicator ""
    set -l c_blue 89b4fa
    set -l c_mauve cba6f7
    set -l c_green a6e3a1
    set -l c_peach fab387
    set -l c_overlay 7f849c

    if command -sq git; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l git_branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
        if test -z "$git_branch"
            set git_branch (command git rev-parse --short HEAD 2>/dev/null)
        end
        if test -n "$git_branch"
            set git_indicator " (git:$git_branch)"
        end
    end

    set_color $c_overlay
    echo -n "┌["

    set_color $c_blue
    echo -n $USER"@"$host

    set_color $c_overlay
    echo -n "] "

    set_color $c_mauve
    echo -n "("$cwd")"

    if test -n "$git_indicator"
        set_color $c_green
        echo -n $git_indicator
    end

    set_color normal
    echo

    set_color $c_overlay
    echo -n "└["

    set_color $c_peach
    echo -n '$'

    set_color $c_overlay
    echo -n "] "

    set_color normal
end


# Created by `pipx` on 2026-05-28 08:40:48
set PATH $PATH /home/pop/.local/bin
