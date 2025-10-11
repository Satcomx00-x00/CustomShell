#!/bin/bash

# Custom Starship Zsh Shell Installer
# This script installs Zsh with Starship prompt, oh-my-zsh, and useful plugins
# Uses Dracula theme for Starship

set -e

# Default settings
INSTALL_PLUGINS=true
INSTALL_KUBE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-plugins)
            INSTALL_PLUGINS=false
            shift
            ;;
        --kube)
            INSTALL_KUBE=true
            shift
            ;;
        --help|-h)
            echo "Custom Starship Zsh Shell Installer"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-plugins    Skip installation of Zsh plugins"
            echo "  --kube         Install Kubernetes tools (kubectl, talosctl)"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              Install everything (default)"
            echo "  $0 --no-plugins Install without Zsh plugins"
            echo "  $0 --kube       Install with Kubernetes tools"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

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

# Check if sudo is needed
get_sudo() {
    if [[ $EUID -eq 0 ]]; then
        echo ""
    else
        echo "sudo"
    fi
}

# Install kubectl
install_kubectl() {
    log_info "Installing kubectl..."

    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        log_warning "kubectl already installed. Skipping."
        return
    fi

    # Download and install kubectl
    local kubectl_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    local arch=$(uname -m)
    case $arch in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac

    log_info "Downloading kubectl ${kubectl_version} for ${arch}..."
    curl -LO "https://dl.k8s.io/release/${kubectl_version}/bin/linux/${arch}/kubectl"

    # Make executable and move to bin directory
    chmod +x kubectl
    $(get_sudo) mv kubectl "$INSTALL_PREFIX/bin/kubectl"

    log_success "kubectl installed successfully"
}

# Install talosctl
install_talosctl() {
    log_info "Installing talosctl..."

    # Check if talosctl is already installed
    if command -v talosctl &> /dev/null; then
        log_warning "talosctl already installed. Skipping."
        return
    fi

    # Get latest release
    local latest_release=$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    local arch=$(uname -m)
    case $arch in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac

    log_info "Downloading talosctl ${latest_release} for linux-${arch}..."
    curl -LO "https://github.com/siderolabs/talos/releases/download/${latest_release}/talosctl-linux-${arch}"

    # Make executable and move to bin directory
    chmod +x "talosctl-linux-${arch}"
    $(get_sudo) mv "talosctl-linux-${arch}" "$INSTALL_PREFIX/bin/talosctl"

    log_success "talosctl installed successfully"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This installer is designed for Linux systems only."
    exit 1
fi

# Check if running as root (for system-wide installation)
if [[ $EUID -eq 0 ]]; then
    log_warning "Running as root. Installing system-wide."
    INSTALL_PREFIX="/usr/local"
else
    log_info "Running as user. Installing locally."
    INSTALL_PREFIX="$HOME/.local"
fi

# Starship config is always user-specific
INSTALL_CONFIG_DIR="$HOME/.config"

# Install system dependencies
log_info "Installing system dependencies..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/install_packages.sh"

# Install Starship
log_info "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$INSTALL_PREFIX/bin" --verbose

# Add Starship to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
    export PATH="$INSTALL_PREFIX/bin:$PATH"
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$HOME/.zshrc"
fi

# Install Kubernetes tools if requested
if [[ "$INSTALL_KUBE" == "true" ]]; then
    install_kubectl
    install_talosctl
fi

# Install oh-my-zsh
log_info "Installing oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    log_warning "oh-my-zsh already installed. Skipping."
fi

# Install Zsh plugins
if [[ "$INSTALL_PLUGINS" == "true" ]]; then
    log_info "Installing Zsh plugins..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        log_warning "zsh-autosuggestions already installed. Skipping."
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        log_warning "zsh-syntax-highlighting already installed. Skipping."
    fi

    # zsh-completions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    else
        log_warning "zsh-completions already installed. Skipping."
    fi
else
    log_info "Skipping Zsh plugins installation (--no-plugins specified)"
fi

# Create .zshrc
log_info "Creating .zshrc configuration..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CONFIG_DIR="$SCRIPT_DIR/../config"

# Copy Starship config with Dracula theme
log_info "Configuring Starship with Dracula theme..."
cp "$PROJECT_CONFIG_DIR/starship.toml" "$INSTALL_CONFIG_DIR/starship.toml"

if [[ "$INSTALL_PLUGINS" == "true" ]]; then
    # With plugins
    cp "$PROJECT_CONFIG_DIR/.zshrc" "$HOME/.zshrc"
else
    # Without plugins
    cp "$PROJECT_CONFIG_DIR/.zshrc.minimal" "$HOME/.zshrc"
fi

# Set Zsh as default shell
log_info "Setting Zsh as default shell..."
if [[ $EUID -eq 0 ]]; then
    # System-wide - running as root
    if ! grep -q "/bin/zsh" /etc/shells; then
        echo "/bin/zsh" >> /etc/shells
    fi
else
    # User-specific - may need sudo for chsh on some systems
    local sudo_cmd=$(get_sudo)
    if command -v chsh &> /dev/null; then
        $sudo_cmd chsh -s $(which zsh)
    else
        log_warning "chsh not available. Please manually set Zsh as your default shell."
    fi
fi

log_success "Installation completed successfully!"
log_info "Please restart your terminal or run 'exec zsh' to start using the new shell."
log_info "Starship configuration is located at: $INSTALL_CONFIG_DIR/starship.toml"
log_info "Zsh configuration is located at: $HOME/.zshrc"
log_info "Tip: You can customize Starship config/cache locations with STARSHIP_CONFIG and STARSHIP_CACHE variables"