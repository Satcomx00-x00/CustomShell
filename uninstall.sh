#!/bin/bash

# Zsh Uninstallation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Confirm uninstallation
confirm_uninstall() {
    echo -e "${YELLOW}This will remove Oh My Zsh and all custom configurations.${NC}"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
}

# Remove Oh My Zsh
remove_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Removing Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        log_success "Oh My Zsh removed"
    fi
}

# Restore shell
restore_shell() {
    log_info "Restoring shell to bash..."
    if command -v chsh &> /dev/null; then
        chsh -s /bin/bash
        log_success "Shell restored to bash"
    else
        log_warning "Please manually change your shell back to bash"
    fi
}

# Restore .zshrc
restore_zshrc() {
    if [[ -f "$HOME/.zshrc" ]]; then
        log_info "Backing up current .zshrc..."
        mv "$HOME/.zshrc" "$HOME/.zshrc.removed.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Restore backup if exists
    local backup=$(ls -t "$HOME/.zshrc.backup."* 2>/dev/null | head -1)
    if [[ -n "$backup" ]]; then
        log_info "Restoring .zshrc backup..."
        cp "$backup" "$HOME/.zshrc"
        log_success ".zshrc backup restored"
    fi
}

# Main uninstall function
main() {
    log_info "Starting Zsh uninstallation..."
    
    confirm_uninstall
    remove_oh_my_zsh
    restore_zshrc
    restore_shell
    
    log_success "Zsh uninstallation completed!"
    log_info "Please restart your terminal to use bash as default shell"
}

main "$@"
