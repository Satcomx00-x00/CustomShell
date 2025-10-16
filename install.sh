#!/bin/bash

# CustomShell Dependency Installer
# This script installs optional dependencies for the custom Zsh configuration

# set -e  # Exit on any error - commented out to allow graceful handling of failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}🗿

log_success() {[ERROR] - (starship::config): Unable to parse the config file: TOML parse error at line 1, column 2                                                                                                                                                                                                                        
  |
1 | k# Starship Configuration File
  |  ^
expected `.`, `=`

[ERROR] - (starship::config): Unable to parse the config file: TOML parse error at line 1, column 2
  |
1 | k# Starship Configuration File
  |  ^
expected `.`, `=`
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

# Check if we have sudo access
check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        # Already root
        return 0
    elif command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
        # Have sudo and it's configured
        return 0
    else
        return 1
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
            if ! check_sudo; then
                log_error "sudo access required for apt. Please run with sudo or as root."
                return 1
            fi
            sudo apt update
            if sudo apt install -y "$package" 2>/dev/null; then
                log_success "$package installed successfully"
                return 0
            else
                log_warning "$package not found in apt repositories, skipping..."
                return 1
            fi
            ;;
        brew)
            if brew install "$package" 2>/dev/null; then
                log_success "$package installed successfully"
                return 0
            else
                log_warning "$package not found in brew, skipping..."
                return 1
            fi
            ;;
        yum)
            if ! check_sudo; then
                log_error "sudo access required for yum. Please run with sudo or as root."
                return 1
            fi
            if sudo yum install -y "$package" 2>/dev/null; then
                log_success "$package installed successfully"
                return 0
            else
                log_warning "$package not found in yum repositories, skipping..."
                return 1
            fi
            ;;
        dnf)
            if ! check_sudo; then
                log_error "sudo access required for dnf. Please run with sudo or as root."
                return 1
            fi
            if sudo dnf install -y "$package" 2>/dev/null; then
                log_success "$package installed successfully"
                return 0
            else
                log_warning "$package not found in dnf repositories, skipping..."
                return 1
            fi
            ;;
        pacman)
            if ! check_sudo; then
                log_error "sudo access required for pacman. Please run with sudo or as root."
                return 1
            fi
            if sudo pacman -S --noconfirm "$package" 2>/dev/null; then
                log_success "$package installed successfully"
                return 0
            else
                log_warning "$package not found in pacman repositories, skipping..."
                return 1
            fi
            ;;
        *)
            log_error "Unsupported package manager. Please install $package manually."
            return 1
            ;;
    esac
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

    # Essential packages for zsh starship shell
    local essential_packages=(
        "zsh:zsh"         # Zsh shell
        "curl:curl"       # For downloading oh-my-zsh and starship
        "wget:wget"       # Alternative downloader
        "git:git"         # Required for oh-my-zsh
    )

    # Optional packages for enhanced functionality
    local optional_packages=(
        "eza:eza"          # Modern ls replacement
        "bat:bat"          # Modern cat replacement
        "tmux:tmux"        # Terminal multiplexer
        "docker:docker"    # Container runtime
        "htop:htop"        # Process viewer
        "python3:python3"  # Python interpreter
        "pip3:python3-pip" # Python package manager
    )

    local installed_count=0
    local total_count=$(( ${#essential_packages[@]} + ${#optional_packages[@]} ))

    log_info "Installing essential packages..."
    for package_info in "${essential_packages[@]}"; do
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

    log_info "Installing optional packages..."
    for package_info in "${optional_packages[@]}"; do
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

    # Install oh-my-zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing oh-my-zsh..."
        if command -v curl &> /dev/null; then
            if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null; then
                log_success "oh-my-zsh installed"
            else
                log_error "Failed to install oh-my-zsh"
                exit 1
            fi
        elif command -v wget &> /dev/null; then
            if sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null; then
                log_success "oh-my-zsh installed"
            else
                log_error "Failed to install oh-my-zsh"
                exit 1
            fi
        else
            log_error "Neither curl nor wget available for oh-my-zsh installation"
            exit 1
        fi
    else
        log_info "oh-my-zsh is already installed"
    fi

    # Install starship if not present
    if ! command -v starship &> /dev/null; then
        log_info "Installing starship..."
        if command -v curl &> /dev/null; then
            if curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null; then
                log_success "starship installed"
            else
                log_error "Failed to install starship"
                exit 1
            fi
        elif command -v wget &> /dev/null; then
            if wget -O- https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null; then
                log_success "starship installed"
            else
                log_error "Failed to install starship"
                exit 1
            fi
        else
            log_error "Neither curl nor wget available for starship installation"
            exit 1
        fi
    else
        log_info "starship is already installed"
    fi

    # Copy configuration files
    log_info "Setting up configuration files..."

    # Backup existing .zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing .zshrc"
    fi

    # Copy the custom .zshrc
    if cp ".oh-my-zsh/.zshrc" "$HOME/.zshrc"; then
        log_success "Custom .zshrc installed"
    else
        log_error "Failed to copy .zshrc"
        exit 1
    fi

    # Copy starship config
    log_info "Installing starship configuration..."
    mkdir -p "$HOME/.config"
    if [[ -f ".config//starship.toml" ]]; then
        if cp ".config//starship.toml" "$HOME/.config/starship.toml"; then
            log_success "Starship configuration (starship.toml) installed"
        else
            log_warning "Failed to copy starship.toml (continuing anyway)"
        fi
    else
        log_warning "starship.toml not found in repository (continuing anyway)"
    fi

    log_success "Installation complete: $installed_count/$total_count packages ready"

    # Post-installation notes
    echo
    log_info "Post-installation notes:"
    echo "  - Zsh and Starship are now installed and configured"
    echo "  - To use zsh as your default shell, run: chsh -s $(which zsh)"
    echo "  - Your old .zshrc has been backed up"
    echo "  - For Docker: You may need to add your user to the docker group:"
    echo "    sudo usermod -aG docker \$USER"
    echo "    Then log out and back in for the changes to take effect."
    echo "  - For tmux: The configuration includes smart session management."
    echo "  - For eza/bat: Enhanced file listing and viewing commands."
    echo "  - For starship: Consider installing a Nerd Font for better icon support:"
    echo "    https://www.nerdfonts.com/"
    echo
    log_success "CustomShell setup finished! Run 'zsh' to start your new shell."
}

# Run the installation
install_dependencies