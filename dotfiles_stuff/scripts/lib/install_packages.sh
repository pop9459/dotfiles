#!/usr/bin/env bash
# Package installation module using paru

# Check if a single package is installed
is_package_installed() {
    local package="$1"
    pacman -Qi "$package" &> /dev/null
}

# Install packages from a list
# Usage: install_package_list <category_name> <package_list> [is_aur]
install_package_list() {
    local category_name="$1"
    local -n packages=$2  # nameref to array
    local is_aur="${3:-false}"
    
    local type_label="official"
    [ "$is_aur" = "true" ] && type_label="AUR"
    
    log_info "Checking $category_name packages ($type_label)..."
    
    local to_install=()
    local already_installed=()
    
    # Check which packages need installation
    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            already_installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done
    
    # Report already installed
    if [ ${#already_installed[@]} -gt 0 ]; then
        log_info "Already installed (${#already_installed[@]}): ${already_installed[*]}"
    fi
    
    # Install missing packages
    if [ ${#to_install[@]} -gt 0 ]; then
        log_info "Installing (${#to_install[@]}): ${to_install[*]}"
        
        if paru -S --needed --noconfirm "${to_install[@]}"; then
            log_success "Successfully installed ${#to_install[@]} package(s)"
            return 0
        else
            log_error "Failed to install some packages: ${to_install[*]}"
            return 1
        fi
    else
        log_info "All packages already installed."
        return 0
    fi
}

# Install all packages from a category
install_category() {
    local yaml_file="$1"
    local category="$2"
    
    log_header "Installing: $category"
    
    # Get category description
    local description=$(get_category_description "$yaml_file" "$category")
    [ -n "$description" ] && log_info "$description"
    
    local success=true
    
    # Install official packages
    local official_pkgs=()
    while IFS= read -r pkg; do
        official_pkgs+=("$pkg")
    done < <(parse_packages "$yaml_file" "$category" "official")
    
    if [ ${#official_pkgs[@]} -gt 0 ]; then
        if ! install_package_list "$category" official_pkgs false; then
            success=false
        fi
    fi
    
    # Install AUR packages
    local aur_pkgs=()
    while IFS= read -r pkg; do
        aur_pkgs+=("$pkg")
    done < <(parse_packages "$yaml_file" "$category" "aur")
    
    if [ ${#aur_pkgs[@]} -gt 0 ]; then
        if ! install_package_list "$category" aur_pkgs true; then
            success=false
        fi
    fi
    
    if [ "$success" = true ]; then
        log_success "$category installation complete!"
        return 0
    else
        log_warning "$category installation completed with some failures."
        return 1
    fi
}

# Install all packages from YAML file
install_all_packages() {
    local yaml_file="$1"
    
    log_header "Package Installation"
    
    # Check if paru is available
    if ! command_exists paru; then
        log_error "paru is not installed. Cannot install packages."
        return 1
    fi
    
    local categories=()
    while IFS= read -r cat; do
        categories+=("$cat")
    done < <(get_categories "$yaml_file")
    
    if [ ${#categories[@]} -eq 0 ]; then
        log_warning "No package categories found in $yaml_file"
        return 0
    fi
    
    log_info "Found ${#categories[@]} package categories: ${categories[*]}"
    
    local failed_categories=()
    
    # Install each category
    for category in "${categories[@]}"; do
        if ! install_category "$yaml_file" "$category"; then
            failed_categories+=("$category")
        fi
        echo ""  # Spacing between categories
    done
    
    # Final report
    if [ ${#failed_categories[@]} -eq 0 ]; then
        log_success "All package categories installed successfully!"
        return 0
    else
        log_warning "Some categories had failures: ${failed_categories[*]}"
        log_info "You can retry failed packages manually with: paru -S <package-name>"
        return 1
    fi
}
