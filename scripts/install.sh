#!/bin/bash

# Zsh Installation Script - Multi-OS Support
# Supports: Ubuntu/Debian, CentOS/RHEL/Fedora, Alpine, macOS, and Docker containers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/alpine-release ]]; then
        OS="alpine"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
    elif [[ -f /etc/redhat-release ]] || [[ -f /etc/centos-release ]] || [[ -f /etc/fedora-release ]]; then
        OS="redhat"
    else
        OS="unknown"
    fi
    log_info "Detected OS: $OS"
}

# Install dependencies based on OS
install_dependencies() {
    log_info "Installing dependencies..."
    
    case $OS in
        "debian")
            apt-get update -y
            apt-get install -y zsh git curl wget vim nano sudo tmux
            ;;
        "redhat")
            if command -v dnf &> /dev/null; then
                dnf install -y zsh git curl wget vim nano sudo tmux
            else
                yum install -y zsh git curl wget vim nano sudo tmux
            fi
            ;;
        "alpine")
            apk update
            apk add --no-cache zsh git curl wget vim nano sudo shadow tmux
            ;;
        "macos")
            if ! command -v brew &> /dev/null; then
                log_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh git curl wget vim nano tmux
            ;;
        *)
            log_error "Unsupported OS. Please install zsh, git, curl, wget, tmux manually."
            exit 1
            ;;
    esac
    
    log_success "Dependencies installed successfully"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh already exists. Backing up..."
        mv "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Install Oh My Zsh non-interactively
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    log_success "Oh My Zsh installed successfully"
}

# Install Zsh plugins
install_plugins() {
    log_info "Installing Zsh plugins..."
    
    local custom_dir="$HOME/.oh-my-zsh/custom"
    
    # Essential plugins (removed zsh-autocomplete due to input duplication issues)
    local plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions" 
        "zsh-users/zsh-history-substring-search"
        "zdharma-continuum/fast-syntax-highlighting"
        "zsh-users/zsh-completions"
    )
    
    # Function to clone or update a plugin
    clone_plugin() {
        local plugin="$1"
        local plugin_name=$(basename "$plugin")
        local plugin_dir="$custom_dir/plugins/$plugin_name"
        
        if [[ -d "$plugin_dir" ]]; then
            log_warning "Plugin $plugin_name already exists. Updating..."
            cd "$plugin_dir" && git pull
        else
            log_info "Installing plugin: $plugin_name"
            git clone --depth 1 "https://github.com/$plugin.git" "$plugin_dir"
        fi
    }
    
    # Clone plugins in parallel
    local pids=()
    for plugin in "${plugins[@]}"; do
        clone_plugin "$plugin" &
        pids+=($!)
    done
    
    # Install Powerlevel10k theme in parallel
    {
        local p10k_dir="$custom_dir/themes/powerlevel10k"
        if [[ -d "$p10k_dir" ]]; then
            log_warning "Powerlevel10k already exists. Updating..."
            cd "$p10k_dir" && git pull
        else
            log_info "Installing Powerlevel10k theme..."
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        fi
    } &
    pids+=($!)
    
    # Wait for all background processes to complete
    log_info "Waiting for all repositories to finish cloning..."
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    log_success "All plugins installed successfully"
}

# Install Powerlevel10k config
setup_p10k_config() {
    log_info "Setting up Powerlevel10k configuration..."
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Existing .p10k.zsh backed up"
    fi
    if [[ -f "$(dirname "$0")/.p10k.zsh" ]]; then
        cp "$(dirname "$0")/.p10k.zsh" "$HOME/.p10k.zsh"
        log_success "Custom .p10k.zsh configuration applied"
    else
        log_warning "Custom .p10k.zsh not found, skipping Powerlevel10k config"
    fi
}

# Setup .zshrc configuration
setup_zshrc() {
    log_info "Setting up .zshrc configuration..."
    
    # Backup existing .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy our custom .zshrc
    if [[ -f "$(dirname "$0")/.zshrc" ]]; then
        cp "$(dirname "$0")/.zshrc" "$HOME/.zshrc"
        log_success "Custom .zshrc configuration applied"
    else
        log_warning "Custom .zshrc not found, using default Oh My Zsh configuration"
    fi
}

# Install tmux configuration and plugins
install_tmux() {
    log_info "Setting up Tmux configuration..."
    
    # Backup existing tmux config
    if [[ -f "$HOME/.tmux.conf" ]]; then
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Existing .tmux.conf backed up"
    fi
    
    # Copy our custom tmux config
    if [[ -f "$(dirname "$0")/.tmux.conf" ]]; then
        cp "$(dirname "$0")/.tmux.conf" "$HOME/.tmux.conf"
        log_success "Custom .tmux.conf configuration applied"
    else
        log_warning "Custom .tmux.conf not found, skipping tmux configuration"
        return
    fi
    
    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing Tmux Plugin Manager (TPM)..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "TPM installed successfully"
    else
        log_info "TPM already installed, updating..."
        cd "$HOME/.tmux/plugins/tpm" && git pull
    fi
    
    # Install tmux plugins
    log_info "Installing tmux plugins..."
    if command -v tmux &> /dev/null; then
        # Start tmux server in detached mode and install plugins
        tmux new-session -d -s plugin_install 2>/dev/null || true
        tmux send-keys -t plugin_install 'source ~/.tmux.conf' Enter 2>/dev/null || true
        tmux send-keys -t plugin_install '~/.tmux/plugins/tpm/bin/install_plugins' Enter 2>/dev/null || true
        sleep 3
        tmux kill-session -t plugin_install 2>/dev/null || true
        log_success "Tmux plugins installed"
    else
        log_warning "Tmux not available, plugins will be installed on first tmux startup"
    fi
}

# Change default shell to zsh
change_shell() {
    log_info "Changing default shell to zsh..."
    
    local zsh_path=$(which zsh)
    
    # Add zsh to valid shells if not present
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    
    # Change shell for current user
    if [[ "$SHELL" != "$zsh_path" ]]; then
        if command -v chsh &> /dev/null; then
            chsh -s "$zsh_path"
            log_success "Default shell changed to zsh"
        else
            log_warning "chsh not available. Please manually change shell to: $zsh_path"
        fi
    else
        log_info "Zsh is already the default shell"
    fi
}

# Install additional tools
install_additional_tools() {
    log_info "Installing additional development tools..."
    
    # Install exa (better ls)
    case $OS in
        "debian")
            apt-get install -y exa 2>/dev/null || {
                log_warning "exa not available in repositories, skipping..."
            }
            ;;
        "redhat")
            if command -v dnf &> /dev/null; then
                dnf install -y exa 2>/dev/null || {
                    log_warning "exa not available in repositories, skipping..."
                }
            fi
            ;;
        "macos")
            brew install exa 2>/dev/null || {
                log_warning "Failed to install exa, skipping..."
            }
            ;;
    esac
    
    # Install bat (better cat)
    case $OS in
        "debian")
            apt-get install -y bat 2>/dev/null || {
                log_warning "bat not available in repositories, skipping..."
            }
            ;;
        "redhat")
            if command -v dnf &> /dev/null; then
                dnf install -y bat 2>/dev/null || {
                    log_warning "bat not available in repositories, skipping..."
                }
            fi
            ;;
        "macos")
            brew install bat 2>/dev/null || {
                log_warning "Failed to install bat, skipping..."
            }
            ;;
    esac
}

# Main installation function
main() {
    log_info "Starting Zsh installation..."
    
    detect_os
    install_dependencies
    install_oh_my_zsh
    install_plugins
    setup_p10k_config
    setup_zshrc
    install_tmux
    change_shell
    install_additional_tools
    
    log_success "Zsh installation completed successfully!"
    log_info "Please restart your terminal or run 'exec zsh' to start using zsh"
    log_info "Run 'p10k configure' to configure Powerlevel10k theme"
    log_info "Run 'tmux' to start tmux with the enhanced configuration"
    log_info "Use 'prefix + I' (Ctrl-a + I) to install tmux plugins"
}

# Run installation
main "$@"
# If running in a Docker container, exec zsh to start the shell
exec zsh