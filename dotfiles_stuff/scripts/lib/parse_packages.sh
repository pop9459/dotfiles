#!/usr/bin/env bash
# YAML parser for packages.yaml
# Simple bash-based parser for our specific YAML structure

# Parse packages from YAML file by category and type (official/aur)
# Usage: parse_packages <yaml_file> <category> <type>
# Example: parse_packages packages.yaml desktop official
parse_packages() {
    local yaml_file="$1"
    local category="$2"
    local type="$3"  # 'official' or 'aur'
    
    if [ ! -f "$yaml_file" ]; then
        log_error "Package file not found: $yaml_file"
        return 1
    fi
    
    # Extract packages for the given category and type
    # This is a simple parser that works with our specific YAML structure
    local in_category=false
    local in_type=false
    local packages=()
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # Check if we're entering the target category
        if [[ "$line" == "$category:" ]]; then
            in_category=true
            in_type=false
            continue
        fi
        
        # Check if we're leaving the current category (new top-level key)
        if [[ "$line" =~ ^[a-z-]+: ]] && [[ "$line" != "description:"* ]] && [[ "$line" != "official:"* ]] && [[ "$line" != "aur:"* ]]; then
            if [ "$in_category" = true ]; then
                break
            fi
        fi
        
        # Check if we're in the right type section
        if [ "$in_category" = true ]; then
            if [[ "$line" == "$type:" ]]; then
                in_type=true
                continue
            elif [[ "$line" == "official:" ]] || [[ "$line" == "aur:" ]]; then
                in_type=false
                continue
            fi
        fi
        
        # Extract package names (lines starting with -)
        if [ "$in_category" = true ] && [ "$in_type" = true ]; then
            if [[ "$line" =~ ^-[[:space:]]+(.*) ]]; then
                # Extract package name (remove comments)
                local pkg="${BASH_REMATCH[1]}"
                pkg=$(echo "$pkg" | sed 's/#.*//' | sed 's/[[:space:]]*$//')
                [ -n "$pkg" ] && packages+=("$pkg")
            fi
        fi
    done < "$yaml_file"
    
    # Output packages (one per line)
    for pkg in "${packages[@]}"; do
        echo "$pkg"
    done
}

# Get all categories from YAML file
get_categories() {
    local yaml_file="$1"
    
    if [ ! -f "$yaml_file" ]; then
        log_error "Package file not found: $yaml_file"
        return 1
    fi
    
    # Extract top-level keys (categories)
    grep -E "^[a-z-]+:" "$yaml_file" | grep -v "description:" | grep -v "official:" | grep -v "aur:" | sed 's/://'
}

# Get description for a category
get_category_description() {
    local yaml_file="$1"
    local category="$2"
    
    if [ ! -f "$yaml_file" ]; then
        return 1
    fi
    
    # Extract description line for the category
    awk -v cat="$category:" '
        $0 ~ cat {found=1; next}
        found && /description:/ {
            sub(/.*description:[[:space:]]*"/, "")
            sub(/".*/, "")
            print
            exit
        }
        found && /^[a-z-]+:/ {exit}
    ' "$yaml_file"
}
