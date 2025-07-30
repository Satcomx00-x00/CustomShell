#!/bin/bash

# Zsh Uninstallation Script - Clean removal of custom zsh setup

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create timestamped backup
create_backup() {
    local file="$1"
    local backup_suffix="${2:-removed}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [[ -f "$file" ]]; then
        local backup_file="${file}.${backup_suffix}.${timestamp}"
        mv "$file" "$backup_file"
        log_info "Backed up $file to $backup_file"
        return 0
    fi
    return 1
}

# Remove files matching pattern
remove_backup_files() {
    local pattern="$1"
    local description="$2"
    
    local count=0
    for backup in $pattern; do
        if [[ -e "$backup" ]]; then
            rm -f "$backup"
            ((count++))
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        log_info "Removed $count $description backup files"
    fi
}

# Confirm uninstallation
confirm_uninstall() {
    echo
    log_warning "This will remove:"
    echo "  • zinit plugin manager"
    echo "  • Powerlevel10k configuration"
    echo "  • Custom .zshrc configuration"
    echo "  • tmux configuration and plugins"
    echo "  • Additional development tools (exa, bat)"
    echo "  • Custom shell settings"
    echo
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
}

# Remove Powerlevel10k config
remove_p10k_config() {
    log_info "Removing Powerlevel10k configuration..."
    
    local count=0
    for p10k_file in "$HOME"/.p10k*; do
        if [[ -f "$p10k_file" ]]; then
            rm -f "$p10k_file"
            ((count++))
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        log_success "Removed $count Powerlevel10k config files"
    else
        log_warning "No Powerlevel10k config files found"
    fi
}

# Remove zinit plugin manager
remove_zinit() {
    log_info "Removing zinit plugin manager and related files..."
    
    local count=0
    
    # Remove zinit directories
    for zinit_dir in "$HOME"/.zinit*; do
        if [[ -d "$zinit_dir" ]]; then
            rm -rf "$zinit_dir"
            ((count++))
            log_info "Removed directory: $(basename "$zinit_dir")"
        fi
    done
    
    # Remove zinit files
    for zinit_file in "$HOME"/.zinit*; do
        if [[ -f "$zinit_file" ]]; then
            rm -f "$zinit_file"
            ((count++))
            log_info "Removed file: $(basename "$zinit_file")"
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        log_success "Removed $count zinit items"
    else
        log_warning "No zinit files or directories found"
    fi
}

# Restore .zshrc
restore_zshrc() {
    log_info "Managing .zshrc configuration..."
    
    # Remove current .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        rm -f "$HOME/.zshrc"
        log_success ".zshrc removed"
    fi
    
    # Remove all .zshrc backups
    remove_backup_files "$HOME/.zshrc.backup.*" ".zshrc"
    remove_backup_files "$HOME/.zshrc.removed.*" ".zshrc removed"
}

# Remove tmux configuration
remove_tmux_config() {
    log_info "Removing tmux configuration..."
    
    # Remove tmux config
    if [[ -f "$HOME/.tmux.conf" ]]; then
        rm -f "$HOME/.tmux.conf"
        log_success ".tmux.conf removed"
    fi
    
    # Remove all tmux backups
    remove_backup_files "$HOME/.tmux.conf.backup.*" ".tmux.conf"
    remove_backup_files "$HOME/.tmux.conf.removed.*" ".tmux.conf removed"
    
    # Remove TPM and plugins
    if [[ -d "$HOME/.tmux" ]]; then
        rm -rf "$HOME/.tmux"
        log_success "Tmux plugins removed"
    fi
    
    # Remove tmux logs
    local log_count=$(ls "$HOME"/tmux-*.log 2>/dev/null | wc -l)
    if [[ $log_count -gt 0 ]]; then
        rm -f "$HOME"/tmux-*.log
        log_info "Removed $log_count tmux log files"
    fi
}

# Remove additional tools
remove_additional_tools() {
    log_info "Removing additional development tools..."
    
    local tools_removed=false
    
    if command -v apt-get &> /dev/null; then
        if dpkg -l | grep -q -E "^ii.*\b(exa|bat)\b"; then
            sudo apt-get remove -y exa bat 2>/dev/null && tools_removed=true
        fi
    elif command -v dnf &> /dev/null; then
        if rpm -qa | grep -q -E "(exa|bat)"; then
            sudo dnf remove -y exa bat 2>/dev/null && tools_removed=true
        fi
    elif command -v brew &> /dev/null; then
        if brew list | grep -q -E "(exa|bat)"; then
            brew uninstall --ignore-dependencies exa bat 2>/dev/null && tools_removed=true
        fi
    elif command -v apk &> /dev/null; then
        if apk info -e exa bat &>/dev/null; then
            sudo apk del exa bat 2>/dev/null && tools_removed=true
        fi
    fi
    
    if [[ "$tools_removed" == "true" ]]; then
        log_success "Additional tools removed"
    else
        log_info "No additional tools found to remove"
    fi
}

# Restore shell
restore_shell() {
    log_info "Restoring default shell..."
    
    local current_shell=$(getent passwd "$USER" | cut -d: -f7)
    
    if [[ "$current_shell" == *"zsh"* ]]; then
        if command -v chsh &> /dev/null; then
            if chsh -s /bin/bash; then
                log_success "Default shell restored to bash"
            else
                log_error "Failed to change shell. Please run: chsh -s /bin/bash"
            fi
        else
            log_warning "chsh command not available"
            log_info "Please manually change your shell: chsh -s /bin/bash"
        fi
    else
        log_info "Shell is already set to: $current_shell"
    fi
}

# Display post-uninstall information
show_post_uninstall_info() {
    echo
    log_success "Zsh uninstallation completed successfully!"
    echo
    log_info "What was removed:"
    echo "  ✓ zinit plugin manager"
    echo "  ✓ Powerlevel10k configuration"
    echo "  ✓ Custom .zshrc and .tmux.conf (including all backups)"
    echo "  ✓ tmux plugins and logs"
    echo "  ✓ Additional development tools"
    echo
    log_info "Next steps:"
    echo "  • Restart your terminal to use the default shell"
    echo "  • All configuration files and backups have been removed"
    echo "  • You may need to recreate your shell configuration manually"
    echo
}

# Main uninstall function
main() {
    log_info "Starting Zsh environment uninstallation..."
    
    confirm_uninstall
    
    # Execute removal steps
    remove_zinit
    remove_p10k_config
    restore_zshrc
    remove_tmux_config
    remove_additional_tools
    restore_shell
    
    show_post_uninstall_info
}

# Error handling
trap 'log_error "Uninstallation failed at line $LINENO"' ERR

# Run main function
main "$@"
