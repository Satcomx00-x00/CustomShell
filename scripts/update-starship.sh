#!/bin/bash

# Update Starship Configuration Script
# This script updates the Starship configuration without reinstalling everything

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
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            BACKUP=false
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            echo "Update Starship Configuration Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-backup    Don't backup current starship.toml"
            echo "  --force        Force update even if starship.toml doesn't exist"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                     Update starship config (default)"
            echo "  $0 --no-backup        Update without backup"
            echo "  $0 --force            Force update"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get script and config directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CONFIG_DIR="$SCRIPT_DIR/../config"

# Starship config is always user-specific (same logic as install.sh)
INSTALL_CONFIG_DIR="$HOME/.config"

# Check if project starship config exists
if [[ ! -f "$PROJECT_CONFIG_DIR/starship.toml" ]]; then
    log_error "Project starship.toml not found: $PROJECT_CONFIG_DIR/starship.toml"
    log_error "Please run this script from the CustomShell directory"
    exit 1
fi

# Check if starship config directory exists
STARSHIP_CONFIG_FILE="$INSTALL_CONFIG_DIR/starship.toml"

if [[ ! -d "$INSTALL_CONFIG_DIR" ]]; then
    if [[ "$FORCE" == "true" ]]; then
        log_warning "Config directory not found. Creating: $INSTALL_CONFIG_DIR"
        mkdir -p "$INSTALL_CONFIG_DIR"
    else
        log_error "Config directory not found: $INSTALL_CONFIG_DIR"
        log_error "Starship may not be installed. Use --force to create the directory."
        exit 1
    fi
fi

# Backup current starship config if it exists
if [[ -f "$STARSHIP_CONFIG_FILE" && "$BACKUP" == "true" ]]; then
    BACKUP_FILE="$STARSHIP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up current starship.toml to: $BACKUP_FILE"
    cp "$STARSHIP_CONFIG_FILE" "$BACKUP_FILE"
fi

# Update starship config
log_info "Updating starship.toml configuration..."
cp "$PROJECT_CONFIG_DIR/starship.toml" "$STARSHIP_CONFIG_FILE"

log_success "Starship configuration updated successfully!"
log_info "Starship configuration is located at: $STARSHIP_CONFIG_FILE"

if [[ "$BACKUP" == "true" && -f "$BACKUP_FILE" ]]; then
    log_info "Backup saved to: $BACKUP_FILE"
fi

log_info "Restart your terminal or run 'exec zsh' to apply the new Starship configuration."