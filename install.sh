#!/bin/bash

# CustomShell Dependency Installer
# This script installs optional dependencies for the custom Zsh configuration

set -e  # Exit on any error

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

# Detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Install package using detected package manager
install_package() {
    local package="$1"
    local pm
    pm=$(detect_package_manager)

    log_info "Installing $package using $pm..."

    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        yum)
            sudo yum install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        *)
            log_error "Unsupported package manager. Please install $package manually."
            return 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        log_success "$package installed successfully"
    else
        log_error "Failed to install $package"
        return 1
    fi
}

# Check if package is installed
is_installed() {
    command -v "$1" &> /dev/null
}

# Main installation function
install_dependencies() {
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" == "unknown" ]]; then
        log_error "No supported package manager found. Please install dependencies manually."
        exit 1
    fi

    log_info "Detected package manager: $pm"
    log_info "Starting dependency installation..."

    # List of packages to install
    local packages=(
        "eza:eza"          # Modern ls replacement
        "bat:bat"          # Modern cat replacement
        "tmux:tmux"        # Terminal multiplexer
        "docker:docker"    # Container runtime
        "git:git"          # Version control (usually pre-installed)
        "htop:htop"        # Process viewer
        "python3:python3"  # Python interpreter
        "pip3:python3-pip" # Python package manager
    )

    local installed_count=0
    local total_count=${#packages[@]}

    for package_info in "${packages[@]}"; do
        IFS=':' read -r command_name package_name <<< "$package_info"

        if is_installed "$command_name"; then
            log_info "$command_name is already installed"
            ((installed_count++))
        else
            if install_package "$package_name"; then
                ((installed_count++))
            fi
        fi
    done

    log_success "Installation complete: $installed_count/$total_count packages ready"

    # Post-installation notes
    echo
    log_info "Post-installation notes:"
    echo "  - For Docker: You may need to add your user to the docker group:"
    echo "    sudo usermod -aG docker \$USER"
    echo "    Then log out and back in for the changes to take effect."
    echo "  - For tmux: The configuration includes smart session management."
    echo "  - For eza/bat: Enhanced file listing and viewing commands."
    echo
    log_success "CustomShell dependencies installation finished!"
}

# Run the installation
install_dependencies