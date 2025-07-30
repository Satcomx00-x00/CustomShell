#!/bin/bash

export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8

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

# Detect current user reliably
detect_current_user() {
    if [[ -n "$USER" ]]; then
        CURRENT_USER="$USER"
    else
        CURRENT_USER="$(whoami)"
    fi
    log_info "Detected user: $CURRENT_USER"
}

# Install dependencies based on OS
install_dependencies() {
    log_info "Installing dependencies..."

    case $OS in
        "debian")
            if [[ $EUID -eq 0 ]]; then
                apt-get update -y
                apt-get install -y zsh git curl wget vim nano sudo tmux fzf unzip
            else
                sudo apt-get update -y
                sudo apt-get install -y zsh git curl wget vim nano sudo tmux fzf unzip
            fi
        ;;
        "redhat")
            if command -v dnf &> /dev/null; then
                if [[ $EUID -eq 0 ]]; then
                    dnf install -y zsh git curl wget vim nano sudo tmux fzf unzip
                else
                    sudo dnf install -y zsh git curl wget vim nano sudo tmux fzf unzip
                fi
            else
                if [[ $EUID -eq 0 ]]; then
                    yum install -y zsh git curl wget vim nano sudo tmux fzf unzip
                else
                    sudo yum install -y zsh git curl wget vim nano sudo tmux fzf unzip
                fi
            fi
        ;;
        "alpine")
            if [[ $EUID -eq 0 ]]; then
                apk update
                apk add --no-cache zsh git curl wget vim nano sudo shadow tmux fzf unzip
            else
                sudo apk update
                sudo apk add --no-cache zsh git curl wget vim nano sudo shadow tmux fzf unzip
            fi
        ;;
        "macos")
            if ! command -v brew &> /dev/null; then
                log_warning "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh git curl wget vim nano tmux fzf unzip
        ;;
        *)
            log_error "Unsupported OS. Please install zsh, git, curl, wget, tmux, unzip manually."
            exit 1
        ;;
    esac

    log_success "Dependencies installed successfully"
}

# Install Oh My Zsh for a specific user
install_oh_my_zsh_for_user() {
    local user_home="$1"
    local user_name="$2"
    
    log_info "Installing Oh My Zsh for user: $user_name..."
    
    if [[ -d "$user_home/.oh-my-zsh" ]]; then
        log_info "Removing existing Oh My Zsh installation for $user_name..."
        if [[ "$user_name" == "$CURRENT_USER" && $EUID -ne 0 ]]; then
            rm -rf "$user_home/.oh-my-zsh"
        elif [[ "$user_name" == "root" && $EUID -eq 0 ]]; then
            rm -rf "$user_home/.oh-my-zsh"
        else
            sudo rm -rf "$user_home/.oh-my-zsh"
        fi
    fi
    
    # Install Oh My Zsh non-interactively
    if [[ "$user_name" == "root" ]]; then
        if [[ $EUID -eq 0 ]]; then
            HOME="$user_home" RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        else
            sudo HOME="$user_home" RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        fi
    else
        sudo -u "$user_name" HOME="$user_home" RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    
    log_success "Oh My Zsh installed successfully for $user_name"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    install_oh_my_zsh_for_user "$HOME" "$CURRENT_USER"
}

# Install zinit for a specific user
install_zinit_for_user() {
    local user_home="$1"
    local user_name="$2"
    
    log_info "Installing zinit plugin manager for user: $user_name..."
    
    if [[ -d "$user_home/.zinit/bin" ]]; then
        # Check if it's a valid git repository
        local is_git_repo=false
        if [[ "$user_name" == "root" ]]; then
            if [[ $EUID -eq 0 ]]; then
                cd "$user_home/.zinit/bin" && git status &>/dev/null && is_git_repo=true
            else
                sudo bash -c "cd $user_home/.zinit/bin && git status" &>/dev/null && is_git_repo=true
            fi
        else
            sudo -u "$user_name" bash -c "cd $user_home/.zinit/bin && git status" &>/dev/null && is_git_repo=true
        fi
        
        if [[ "$is_git_repo" == "true" ]]; then
            log_info "zinit already installed for $user_name, updating..."
            if [[ "$user_name" == "root" ]]; then
                if [[ $EUID -eq 0 ]]; then
                    cd "$user_home/.zinit/bin" && git pull
                else
                    sudo bash -c "cd $user_home/.zinit/bin && git pull"
                fi
            else
                sudo -u "$user_name" bash -c "cd $user_home/.zinit/bin && git pull"
            fi
        else
            log_info "zinit directory exists but is not a valid git repository for $user_name, removing and reinstalling..."
            if [[ "$user_name" == "root" && $EUID -ne 0 ]]; then
                sudo rm -rf "$user_home/.zinit"
            else
                rm -rf "$user_home/.zinit"
            fi
            
            # Install fresh copy
            if [[ "$user_name" == "root" ]]; then
                if [[ $EUID -eq 0 ]]; then
                    mkdir -p "$user_home/.zinit"
                    git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
                else
                    sudo mkdir -p "$user_home/.zinit"
                    sudo git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
                fi
            else
                sudo -u "$user_name" mkdir -p "$user_home/.zinit"
                sudo -u "$user_name" git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
            fi
            log_success "zinit installed successfully for $user_name"
        fi
    else
        if [[ "$user_name" == "root" ]]; then
            if [[ $EUID -eq 0 ]]; then
                mkdir -p "$user_home/.zinit"
                git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
            else
                sudo mkdir -p "$user_home/.zinit"
                sudo git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
            fi
        else
            sudo -u "$user_name" mkdir -p "$user_home/.zinit"
            sudo -u "$user_name" git clone https://github.com/zdharma-continuum/zinit.git "$user_home/.zinit/bin"
        fi
        log_success "zinit installed successfully for $user_name"
    fi
}

# --- Ensure clean folder structure ---
setup_folder_structure() {
    mkdir -p "$(dirname "$0")/../config"
    mkdir -p "$(dirname "$0")/../scripts"
    
    # Move config files if not already in config/
    for f in .zshrc .p10k.zsh .tmux.conf; do
        if [[ -f "$(dirname "$0")/../$f" ]]; then
            mv "$(dirname "$0")/../$f" "$(dirname "$0")/../config/$f"
        fi
    done
    
    # Move scripts if not already in scripts/
    for f in install.sh uninstall.sh update-p10k.sh; do
        if [[ -f "$(dirname "$0")/../$f" && "$(basename "$0")" != "$f" ]]; then
            mv "$(dirname "$0")/../$f" "$(dirname "$0")/../scripts/$f"
        fi
    done
}

# Setup configuration for a specific user
setup_config_for_user() {
    local user_home="$1"
    local user_name="$2"
    local config_file="$3"
    local config_name="$4"
    
    log_info "Setting up $config_name configuration for user: $user_name..."
    local src="$(realpath "$(dirname "$0")/../config/$config_file")"
    
    if [[ -f "$src" ]]; then
        if [[ "$user_name" == "root" && $EUID -ne 0 ]]; then
            sudo cp "$src" "$user_home/$config_file"
            sudo chown "$user_name":"$user_name" "$user_home/$config_file" 2>/dev/null || true
            sudo chmod 644 "$user_home/$config_file" 2>/dev/null || true
        else
            cp "$src" "$user_home/$config_file"
            chown "$user_name":"$user_name" "$user_home/$config_file" 2>/dev/null || true
            chmod 644 "$user_home/$config_file" 2>/dev/null || true
        fi
        log_success "Custom $config_name configuration applied for $user_name"
    else
        log_warning "Custom $config_file not found at $src, skipping $config_name setup for $user_name"
    fi
}

# Setup .zshrc configuration
setup_zshrc() {
    # Setup for current user
    setup_config_for_user "$HOME" "$CURRENT_USER" ".zshrc" ".zshrc"
}

# Install Powerlevel10k config
setup_p10k_config() {
    # Setup for current user
    setup_config_for_user "$HOME" "$CURRENT_USER" ".p10k.zsh" "Powerlevel10k"
}

# Setup tmux for a specific user
setup_tmux_for_user() {
    local user_home="$1"
    local user_name="$2"

    log_info "Setting up Tmux configuration for user: $user_name..."
    local src="$(realpath "$(dirname "$0")/../config/.tmux.conf")"

    if [[ -f "$src" ]]; then
        cp "$src" "$user_home/.tmux.conf"
        chown "$user_name":"$user_name" "$user_home/.tmux.conf" 2>/dev/null || true
        log_success "Custom .tmux.conf configuration applied for $user_name"
    else
        log_warning "Custom .tmux.conf not found at $src, skipping tmux configuration for $user_name"
    fi
    # No plugin manager or plugin install here; zinit will handle plugins
}

# Install tmux configuration and plugins
install_tmux() {
    setup_tmux_for_user "$HOME" "$CURRENT_USER"
}

# Change default shell to zsh
change_shell() {
    log_info "Changing default shell to zsh for $CURRENT_USER..."

    local zsh_path=$(which zsh)

    # Add zsh to valid shells if not present
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding zsh to /etc/shells..."
        if [[ $EUID -eq 0 ]]; then
            echo "$zsh_path" >> /etc/shells
        else
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
    fi

    # Change shell for current user
    if [[ "$SHELL" != "$zsh_path" ]]; then
        if command -v chsh &> /dev/null; then
            chsh -s "$zsh_path"
            log_success "Default shell changed to zsh for $CURRENT_USER"
        else
            log_warning "chsh not available. Please manually change shell to: $zsh_path"
        fi
    else
        log_info "Zsh is already the default shell for $CURRENT_USER"
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

# Install Nerd Font for a specific user
install_nerdfont_for_user() {
    local user_home="$1"
    local user_name="$2"
    
    log_info "Installing FiraCode Nerd Font for user: $user_name..."
    local font_dir="$user_home/.local/share/fonts"
    
    if [[ "$user_name" == "root" ]]; then
        if [[ $EUID -eq 0 ]]; then
            mkdir -p "$font_dir"
        else
            sudo mkdir -p "$font_dir"
        fi
    else
        sudo -u "$user_name" mkdir -p "$font_dir"
    fi
    
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
    local tmp_zip="/tmp/FiraCodeNerdFont_${user_name}.zip"
    
    curl -fLo "$tmp_zip" --create-dirs "$font_url"
    unzip -o "$tmp_zip" -d "$font_dir"
    rm -f "$tmp_zip"
    
    if [[ "$user_name" == "root" && $EUID -ne 0 ]]; then
        sudo chown -R "$user_name":"$user_name" "$font_dir" 2>/dev/null || true
    else
        chown -R "$user_name":"$user_name" "$font_dir" 2>/dev/null || true
    fi
    
    if command -v fc-cache &> /dev/null; then
        if [[ "$user_name" == "root" ]]; then
            if [[ $EUID -eq 0 ]]; then
                fc-cache -fv "$font_dir"
            else
                sudo fc-cache -fv "$font_dir"
            fi
        else
            sudo -u "$user_name" fc-cache -fv "$font_dir"
        fi
    fi
    
    log_success "FiraCode Nerd Font installed for $user_name"
}

# Install Nerd Font for Alacritty
install_nerdfont() {
    # Install for current user
    install_nerdfont_for_user "$HOME" "$CURRENT_USER"
    
    log_success "FiraCode Nerd Font installed. Set it in your Alacritty config."
}

# Main installation function
main() {
    log_info "Starting Zsh installation..."
    
    detect_current_user

    setup_folder_structure
    detect_os
    install_dependencies
    install_oh_my_zsh_for_user "$HOME" "$CURRENT_USER"
    install_zinit_for_user "$HOME" "$CURRENT_USER"
    setup_p10k_config
    setup_zshrc
    install_tmux
    change_shell
    install_additional_tools
    install_nerdfont

    log_success "Zsh installation completed successfully!"
    log_info "Please restart your terminal or run 'exec zsh' to start using zsh"
    log_info "Run 'p10k configure' to configure Powerlevel10k theme"
    log_info "Run 'tmux' to start tmux with the enhanced configuration"
    log_info "Use 'prefix + I' (Ctrl-a + I) to install tmux plugins"
}

# Run installation
main "$@"

exec zsh