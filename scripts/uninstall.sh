#!/bin/bash

# Custom Starship Zsh Shell Uninstaller
# This script removes all components installed by the installer

set -e

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

# Default settings
REMOVE_ZSH=true
REMOVE_STARSHIP=true
REMOVE_PLUGINS=true
REMOVE_CONFIGS=true
RESTORE_BACKUPS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-zsh)
            REMOVE_ZSH=false
            shift
            ;;
        --keep-starship)
            REMOVE_STARSHIP=false
            shift
            ;;
        --keep-plugins)
            REMOVE_PLUGINS=false
            shift
            ;;
        --keep-configs)
            REMOVE_CONFIGS=false
            shift
            ;;
        --restore-backups)
            RESTORE_BACKUPS=true
            shift
            ;;
        --help|-h)
            echo "Custom Starship Zsh Shell Uninstaller"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --keep-zsh         Don't remove Zsh and oh-my-zsh"
            echo "  --keep-starship    Don't remove Starship"
            echo "  --keep-plugins     Don't remove Zsh plugins"
            echo "  --keep-configs     Don't remove configuration files"
            echo "  --restore-backups  Restore original configuration backups"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           Full uninstall (default)"
            echo "  $0 --keep-zsh               Remove everything except Zsh"
            echo "  $0 --restore-backups        Restore original configs"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This uninstaller is designed for Linux systems only."
    exit 1
fi

# Determine installation type and paths
if [[ $EUID -eq 0 ]]; then
    log_warning "Running as root. Removing system-wide installation."
    INSTALL_PREFIX="/usr/local"
    ZSH_CONFIG_DIR="/root"
else
    log_info "Running as user. Removing user installation."
    INSTALL_PREFIX="$HOME/.local"
    ZSH_CONFIG_DIR="$HOME"
fi

# Starship config is always user-specific
INSTALL_CONFIG_DIR="$HOME/.config"

# Get package manager
get_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v apk &> /dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Remove packages
remove_packages() {
    local pm=$(get_package_manager)
    local packages=()

    if [[ "$pm" == "unknown" ]]; then
        log_warning "Unknown package manager. Skipping package removal."
        return
    fi

    log_info "Detected package manager: $pm"

    # Add packages to remove based on what's being uninstalled
    if [[ "$REMOVE_ZSH" == "true" ]]; then
        packages+=(zsh)
    fi

    # Note: Starship is typically installed via direct download, not package manager
    # fzf might be installed via package manager, but we'll handle it separately if needed

    if [[ ${#packages[@]} -gt 0 ]]; then
        log_info "Removing packages: ${packages[*]}"
        case $pm in
            apt)
                apt-get remove -y "${packages[@]}"
                apt-get autoremove -y
                ;;
            dnf)
                dnf remove -y "${packages[@]}"
                ;;
            yum)
                yum remove -y "${packages[@]}"
                ;;
            pacman)
                pacman -Rns --noconfirm "${packages[@]}"
                ;;
            zypper)
                zypper remove -y "${packages[@]}"
                ;;
            apk)
                apk del "${packages[@]}"
                ;;
        esac
    fi
}

# Restore backups if requested
restore_backups() {
    if [[ "$RESTORE_BACKUPS" == "true" ]]; then
        log_info "Restoring configuration backups..."

        # Restore .zshrc backup
        if [[ -f "$ZSH_CONFIG_DIR/.zshrc.backup."* ]]; then
            local latest_backup=$(ls -t "$ZSH_CONFIG_DIR/.zshrc.backup."* | head -1)
            if [[ -n "$latest_backup" ]]; then
                log_info "Restoring .zshrc from: $latest_backup"
                cp "$latest_backup" "$ZSH_CONFIG_DIR/.zshrc"
            fi
        fi

        # Restore starship.toml backup
        local starship_backup_dir="$INSTALL_CONFIG_DIR"
        if [[ -f "$starship_backup_dir/starship.toml.backup."* ]]; then
            local latest_backup=$(ls -t "$starship_backup_dir/starship.toml.backup."* | head -1)
            if [[ -n "$latest_backup" ]]; then
                log_info "Restoring starship.toml from: $latest_backup"
                cp "$latest_backup" "$starship_backup_dir/starship.toml"
            fi
        fi
    fi
}

# Remove Starship
remove_starship() {
    if [[ "$REMOVE_STARSHIP" == "true" ]]; then
        log_info "Removing Starship..."

        # Remove binary
        if [[ -f "$INSTALL_PREFIX/bin/starship" ]]; then
            rm -f "$INSTALL_PREFIX/bin/starship"
            log_info "Removed Starship binary: $INSTALL_PREFIX/bin/starship"
        fi

        # Remove from PATH in shell configs (if added by installer)
        local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
        for config_file in "${shell_configs[@]}"; do
            if [[ -f "$config_file" ]]; then
                sed -i "\|export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"|d" "$config_file" 2>/dev/null || true
                log_info "Cleaned PATH from: $config_file"
            fi
        done

        # Also clean from system-wide profile if root
        if [[ $EUID -eq 0 ]]; then
            local system_configs=("/etc/profile" "/etc/bash.bashrc")
            for config_file in "${system_configs[@]}"; do
                if [[ -f "$config_file" ]]; then
                    sed -i "\|export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"|d" "$config_file" 2>/dev/null || true
                    log_info "Cleaned PATH from: $config_file"
                fi
            done
        fi
    fi
}

# Remove Zsh plugins
remove_plugins() {
    if [[ "$REMOVE_PLUGINS" == "true" ]]; then
        log_info "Removing Zsh plugins..."

        local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

        # List of plugins to remove
        local plugins=(
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
            "$ZSH_CUSTOM/plugins/zsh-completions"
        )

        for plugin in "${plugins[@]}"; do
            if [[ -d "$plugin" ]]; then
                rm -rf "$plugin"
                log_info "Removed plugin: $plugin"
            fi
        done
    fi
}

# Remove oh-my-zsh
remove_ohmyzsh() {
    if [[ "$REMOVE_ZSH" == "true" ]]; then
        log_info "Removing oh-my-zsh..."

        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            rm -rf "$HOME/.oh-my-zsh"
            log_info "Removed oh-my-zsh directory: $HOME/.oh-my-zsh"
        fi
    fi
}

# Remove configuration files
remove_configs() {
    if [[ "$REMOVE_CONFIGS" == "true" ]]; then
        log_info "Removing configuration files..."

        # Remove starship config
        if [[ -f "$INSTALL_CONFIG_DIR/starship.toml" ]]; then
            rm -f "$INSTALL_CONFIG_DIR/starship.toml"
            log_info "Removed starship config: $INSTALL_CONFIG_DIR/starship.toml"
        fi

        # Remove .zshrc (but keep backups)
        if [[ -f "$ZSH_CONFIG_DIR/.zshrc" ]]; then
            rm -f "$ZSH_CONFIG_DIR/.zshrc"
            log_info "Removed .zshrc: $ZSH_CONFIG_DIR/.zshrc"
        fi

        # Remove backup files if not restoring
        if [[ "$RESTORE_BACKUPS" == "false" ]]; then
            log_info "Removing backup files..."
            rm -f "$ZSH_CONFIG_DIR/.zshrc.backup."*
            rm -f "$INSTALL_CONFIG_DIR/starship.toml.backup."*
        fi
    fi
}

# Reset shell to default (if Zsh was set as default)
reset_shell() {
    if [[ "$REMOVE_ZSH" == "true" ]]; then
        log_info "Checking if Zsh was set as default shell..."

        # For root, remove Zsh from /etc/shells if it was added
        if [[ $EUID -eq 0 ]]; then
            if grep -q "/bin/zsh" /etc/shells 2>/dev/null; then
                sed -i '/\/bin\/zsh/d' /etc/shells
                log_info "Removed Zsh from /etc/shells"
            fi
        fi

        # Note: We don't automatically change the default shell back
        # as that might be disruptive. User can manually change if needed.
        log_warning "If Zsh was set as your default shell, you may want to change it back manually."
        log_warning "Run: chsh -s /bin/bash (or your preferred shell)"
    fi
}

# Main uninstall function
main() {
    log_warning "Starting uninstallation of Custom Starship Zsh Shell..."
    log_warning "This will remove the following components:"
    [[ "$REMOVE_STARSHIP" == "true" ]] && echo "  - Starship prompt"
    [[ "$REMOVE_ZSH" == "true" ]] && echo "  - Zsh and oh-my-zsh"
    [[ "$REMOVE_PLUGINS" == "true" ]] && echo "  - Zsh plugins"
    [[ "$REMOVE_CONFIGS" == "true" ]] && echo "  - Configuration files"
    [[ "$RESTORE_BACKUPS" == "true" ]] && echo "  - Will restore backups"

    echo ""
    read -p "Continue with uninstallation? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi

    # Perform uninstallation in reverse order of installation
    restore_backups
    remove_configs
    remove_plugins
    remove_starship
    remove_ohmyzsh
    remove_packages
    reset_shell

    log_success "Uninstallation completed successfully!"

    if [[ "$RESTORE_BACKUPS" == "false" ]]; then
        log_info "Note: Backup files were preserved. Use --restore-backups to restore them."
    fi

    log_info "You may want to restart your terminal or run 'exec bash' to return to your previous shell."
}

# Run main function
main "$@"