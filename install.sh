#!/bin/bash

# CustomShell Installation Script
# This script installs the CustomShell Zsh configuration with Oh My Zsh, Powerlevel10k theme, and plugins

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Satcomx00-x00/CustomShell.git"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
BACKUP_DIR="$HOME/.zsh_backup_$(date +%Y%m%d_%H%M%S)"

# Parse command line arguments
DEPS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--deps-only)
            DEPS_ONLY=true
            shift
            ;;
        -h|--help)
            echo "CustomShell Installation Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --deps-only    Install only dependencies (zsh, git, curl)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Without any options, performs full installation."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

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
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup existing configuration
backup_existing_config() {
    log_info "Checking for existing Zsh configuration..."

    if [[ -f "$HOME/.zshrc" ]]; then
        log_warning "Found existing .zshrc file. Creating backup..."
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.backup"
        log_success "Backup created at $BACKUP_DIR/.zshrc.backup"
    fi

    if [[ -f "$HOME/.p10k.zsh" ]]; then
        log_warning "Found existing .p10k.zsh file. Creating backup..."
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh.backup"
        log_success "Backup created at $BACKUP_DIR/.p10k.zsh.backup"
    fi

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Found existing Oh My Zsh installation. Creating backup..."
        mkdir -p "$BACKUP_DIR"
        mv "$HOME/.oh-my-zsh" "$BACKUP_DIR/.oh-my-zsh.backup"
        log_success "Backup created at $BACKUP_DIR/.oh-my-zsh.backup"
    fi
}

# Install prerequisites
install_prerequisites() {
    log_header "Installing Prerequisites"

    # Check for required commands
    local missing_deps=()

    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if ! command_exists git; then
        missing_deps+=("git")
    fi

    if ! command_exists zsh; then
        missing_deps+=("zsh")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_info "Installing missing dependencies: ${missing_deps[*]}"

        # Detect package manager
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y "${missing_deps[@]}"
        elif command_exists yum; then
            sudo yum install -y "${missing_deps[@]}"
        elif command_exists dnf; then
            sudo dnf install -y "${missing_deps[@]}"
        elif command_exists pacman; then
            sudo pacman -Syu --noconfirm "${missing_deps[@]}"
        elif command_exists brew; then
            brew install "${missing_deps[@]}"
        else
            log_error "Could not detect package manager. Please install manually: ${missing_deps[*]}"
            exit 1
        fi
    fi

    log_success "Prerequisites installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_header "Installing Oh My Zsh"

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh already installed. Skipping..."
        return
    fi

    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    log_success "Oh My Zsh installed"
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    log_header "Installing Powerlevel10k Theme"

    local theme_dir="$ZSH_CUSTOM/themes/powerlevel10k"

    if [[ -d "$theme_dir" ]]; then
        log_warning "Powerlevel10k already installed. Skipping..."
        return
    fi

    log_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"

    log_success "Powerlevel10k theme installed"
}

# Install plugins
install_plugins() {
    log_header "Installing Zsh Plugins"

    local plugins_dir="$ZSH_CUSTOM/plugins"

    # Essential plugins that need separate installation
    local essential_plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "fast-syntax-highlighting"
        "zsh-completions"
        "fzf-tab"
    )

    # Install essential plugins
    for plugin in "${essential_plugins[@]}"; do
        local plugin_dir="$plugins_dir/$plugin"

        if [[ -d "$plugin_dir" ]]; then
            log_info "Plugin $plugin already installed. Skipping..."
            continue
        fi

        log_info "Installing essential plugin: $plugin"

        case "$plugin" in
            "zsh-autosuggestions")
                git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
                ;;
            "zsh-syntax-highlighting")
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir"
                ;;
            "fast-syntax-highlighting")
                git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$plugin_dir"
                ;;
            "zsh-completions")
                git clone https://github.com/zsh-users/zsh-completions "$plugin_dir"
                ;;
            "fzf-tab")
                git clone https://github.com/Aloxaf/fzf-tab "$plugin_dir"
                ;;
        esac
    done

    log_success "Essential plugins installation completed"
}

# Install additional tools
install_additional_tools() {
    log_header "Installing Additional Tools"

    # Install eza (modern ls replacement)
    if ! command_exists eza; then
        log_info "Installing eza..."
        if command_exists apt-get; then
            sudo apt-get install -y eza
        elif command_exists brew; then
            brew install eza
        else
            log_warning "Could not install eza. Please install manually."
        fi
    fi

    # Install bat (modern cat replacement)
    if ! command_exists bat; then
        log_info "Installing bat..."
        if command_exists apt-get; then
            sudo apt-get install -y bat
        elif command_exists brew; then
            brew install bat
        else
            log_warning "Could not install bat. Please install manually."
        fi
    fi

    log_success "Additional tools installation completed"
}

# Copy configuration files
copy_config_files() {
    log_header "Copying Configuration Files"

    # Copy .zshrc
    if [[ -f ".oh-my-zsh/.zshrc" ]]; then
        log_info "Copying .zshrc..."
        cp ".oh-my-zsh/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc copied"
    else
        log_error ".zshrc not found in repository"
        exit 1
    fi

    # Copy .p10k.zsh
    if [[ -f ".p10k.zsh" ]]; then
        log_info "Copying .p10k.zsh..."
        cp ".p10k.zsh" "$HOME/.p10k.zsh"
        log_success ".p10k.zsh copied"
    else
        log_error ".p10k.zsh not found in repository"
        exit 1
    fi
}

# Set Zsh as default shell
set_default_shell() {
    log_header "Setting Zsh as Default Shell"

    local current_shell
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        log_info "Zsh is already the default shell"
        return
    fi

    log_info "Changing default shell to Zsh..."
    if command_exists chsh; then
        sudo chsh -s "$(which zsh)" "$USER"
        log_success "Default shell changed to Zsh. Please log out and back in for changes to take effect."
    else
        log_warning "Could not change default shell automatically. Please run: chsh -s $(which zsh)"
    fi
}

# Main installation function
main() {
    if [[ "$DEPS_ONLY" == true ]]; then
        log_header "CustomShell Dependencies Installation"

        echo -e "${CYAN}This script will install only the dependencies required for CustomShell."
        echo -e "This includes zsh, git, and curl."
        echo -e ""
        echo -e "What will be installed:"
        echo -e "  • Zsh shell"
        echo -e "  • Git"
        echo -e "  • Curl"
        echo -e ""
        echo -e "Existing configurations will be backed up.${NC}"
        echo ""

        read -p "Continue with dependencies installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled."
            exit 0
        fi

        # Run only dependency installation steps
        backup_existing_config
        install_prerequisites

        log_header "Dependencies Installation Complete!"

        echo -e "${GREEN}Dependencies have been successfully installed!${NC}"
        echo ""
        echo -e "${CYAN}You can now run the full installation or set up CustomShell manually.${NC}"
        echo ""
        echo -e "${YELLOW}If you encounter any issues, check the backups in: $BACKUP_DIR${NC}"
        return
    fi

    log_header "CustomShell Installation"

    echo -e "${CYAN}This script will install CustomShell - a comprehensive Zsh configuration"
    echo -e "with Oh My Zsh, Powerlevel10k theme, and many useful plugins."
    echo -e ""
    echo -e "What will be installed:"
    echo -e "  • Zsh shell"
    echo -e "  • Oh My Zsh framework"
    echo -e "  • Powerlevel10k theme"
    echo -e "  • Essential Zsh plugins"
    echo -e "  • Custom configuration files"
    echo -e "  • Additional tools (eza, bat)"
    echo -e ""
    echo -e "Existing configurations will be backed up.${NC}"
    echo ""

    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi

    # Run installation steps
    backup_existing_config
    install_prerequisites
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    install_additional_tools
    copy_config_files
    set_default_shell

    log_header "Installation Complete!"

    echo -e "${GREEN}CustomShell has been successfully installed!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Log out and back in, or run: exec zsh"
    echo "2. Run 'p10k configure' to customize the Powerlevel10k prompt"
    echo "3. Enjoy your new shell!"
    echo ""
    echo -e "${YELLOW}If you encounter any issues, check the backups in: $BACKUP_DIR${NC}"
}

# Run main function
main "$@"