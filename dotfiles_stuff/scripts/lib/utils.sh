#!/usr/bin/env bash
# Shared utility functions for dotfiles installation scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo ""
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a package is installed (pacman)
is_installed() {
    pacman -Qi "$1" &> /dev/null
}

# Ask user yes/no question (returns 0 for yes, 1 for no)
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt (Y/n) "
    else
        prompt="$prompt (y/N) "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    else
        # Use default
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
}

# Retry a command on failure
retry_on_failure() {
    local cmd="$1"
    local description="$2"
    
    while true; do
        if eval "$cmd"; then
            return 0
        else
            log_error "$description failed."
            if ask_yes_no "Do you want to retry?"; then
                continue
            else
                log_warning "Skipping $description"
                return 1
            fi
        fi
    done
}
