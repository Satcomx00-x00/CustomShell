#!/bin/bash

# Update Zsh Configuration Script
# This script updates the Zsh configuration without reinstalling everything

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
BACKUP=true
RELOAD=true
MINIMAL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            BACKUP=false
            shift
            ;;
        --no-reload)
            RELOAD=false
            shift
            ;;
        --minimal)
            MINIMAL=true
            shift
            ;;
        --help|-h)
            echo "Update Zsh Configuration Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-backup    Don't backup current .zshrc"
            echo "  --no-reload    Don't reload Zsh after update"
            echo "  --minimal      Use minimal configuration (no plugins)"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    Update with full config (default)"
            echo "  $0 --minimal         Update with minimal config"
            echo "  $0 --no-backup       Update without backup"
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
    log_error "This script is designed for Linux systems only."
    exit 1
fi

# Get script and config directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Check if config directory exists
if [[ ! -d "$CONFIG_DIR" ]]; then
    log_error "Config directory not found: $CONFIG_DIR"
    log_error "Please run this script from the CustomShell directory"
    exit 1
fi

# Backup current .zshrc if it exists
if [[ -f "$HOME/.zshrc" && "$BACKUP" == "true" ]]; then
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up current .zshrc to: $BACKUP_FILE"
    cp "$HOME/.zshrc" "$BACKUP_FILE"
fi

# Update .zshrc
log_info "Updating .zshrc configuration..."
if [[ "$MINIMAL" == "true" ]]; then
    if [[ -f "$CONFIG_DIR/.zshrc.minimal" ]]; then
        cp "$CONFIG_DIR/.zshrc.minimal" "$HOME/.zshrc"
        log_success "Updated to minimal configuration"
    else
        log_error "Minimal configuration file not found: $CONFIG_DIR/.zshrc.minimal"
        exit 1
    fi
else
    if [[ -f "$CONFIG_DIR/.zshrc" ]]; then
        cp "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"
        log_success "Updated to full configuration"
    else
        log_error "Full configuration file not found: $CONFIG_DIR/.zshrc"
        exit 1
    fi
fi

# Reload Zsh if requested
if [[ "$RELOAD" == "true" ]]; then
    log_info "Reloading Zsh configuration..."
    if [[ -n "$ZSH_VERSION" ]]; then
        # We're in Zsh, source the new config
        source "$HOME/.zshrc"
        log_success "Zsh configuration reloaded"
    else
        log_warning "Not running in Zsh. Please run 'exec zsh' or restart your terminal to apply changes"
    fi
fi

log_success "Zsh configuration update completed!"
if [[ "$BACKUP" == "true" && -f "$BACKUP_FILE" ]]; then
    log_info "Backup saved to: $BACKUP_FILE"
fi