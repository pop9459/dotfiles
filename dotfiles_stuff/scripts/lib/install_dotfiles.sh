#!/usr/bin/env bash
# Dotfiles bare repository installation module

install_dotfiles() {
    local branch="${1:-main}"
    local dotfiles_repo="https://github.com/pop9459/dotfiles.git"
    local dotfiles_dir="$HOME/.dotfiles"
    
    log_header "Installing Dotfiles"
    log_info "Branch: $branch"
    
    # Check if already installed
    if [ -d "$dotfiles_dir" ]; then
        log_warning "$dotfiles_dir already exists."
        
        # Check if it's a valid git repo
        if git --git-dir="$dotfiles_dir" --work-tree="$HOME" rev-parse --git-dir &> /dev/null; then
            log_success "Dotfiles repository already set up. Skipping."
            setup_dotfiles_alias
            return 0
        else
            log_error "$dotfiles_dir exists but is not a valid git repository."
            if ask_yes_no "Do you want to remove it and reinstall?"; then
                rm -rf "$dotfiles_dir"
            else
                log_warning "Dotfiles installation cancelled."
                return 1
            fi
        fi
    fi
    
    # Clone the bare repository
    log_info "Cloning bare repository to $dotfiles_dir..."
    if ! retry_on_failure "git clone --bare '$dotfiles_repo' '$dotfiles_dir'" "Repository clone"; then
        return 1
    fi
    
    # Define the dotfiles command for this session
    function dotfiles {
        git --git-dir="$dotfiles_dir" --work-tree="$HOME" "$@"
    }
    
    # Configure the repository
    log_info "Configuring repository..."
    dotfiles config --local status.showUntrackedFiles no
    
    # Checkout the branch
    log_info "Checking out dotfiles..."
    if ! dotfiles checkout "$branch" 2>&1 | grep -q "error: The following untracked working tree files would be overwritten"; then
        dotfiles checkout "$branch"
    else
        log_warning "Some files would be overwritten. Creating backup..."
        mkdir -p "$HOME/.dotfiles-backup"
        dotfiles checkout "$branch" 2>&1 | grep -E "^\s+" | awk '{print $1}' | xargs -I{} mv "$HOME/{}" "$HOME/.dotfiles-backup/" 2>/dev/null
        dotfiles checkout "$branch"
        log_success "Original files backed up to $HOME/.dotfiles-backup"
    fi
    
    # Setup alias
    setup_dotfiles_alias
    
    log_success "Dotfiles installation complete!"
    return 0
}

setup_dotfiles_alias() {
    log_info "Setting up dotfiles alias..."
    
    local alias_line='alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"'
    local added=false
    
    # Fish shell
    if [ -n "$FISH_VERSION" ] || command_exists fish; then
        local fish_config="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$fish_config")"
        
        if ! grep -q "alias dotfiles" "$fish_config" 2>/dev/null; then
            echo "" >> "$fish_config"
            echo "# Dotfiles management alias" >> "$fish_config"
            echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> "$fish_config"
            log_success "Added alias to $fish_config"
            added=true
        fi
    fi
    
    # Bash
    local bashrc="$HOME/.bashrc"
    if [ -f "$bashrc" ]; then
        if ! grep -q "alias dotfiles" "$bashrc" 2>/dev/null; then
            echo "" >> "$bashrc"
            echo "# Dotfiles management alias" >> "$bashrc"
            echo "$alias_line" >> "$bashrc"
            log_success "Added alias to $bashrc"
            added=true
        fi
    fi
    
    # Zsh
    local zshrc="$HOME/.zshrc"
    if [ -f "$zshrc" ]; then
        if ! grep -q "alias dotfiles" "$zshrc" 2>/dev/null; then
            echo "" >> "$zshrc"
            echo "# Dotfiles management alias" >> "$zshrc"
            echo "$alias_line" >> "$zshrc"
            log_success "Added alias to $zshrc"
            added=true
        fi
    fi
    
    if [ "$added" = false ]; then
        log_info "Dotfiles alias already configured."
    fi
}
