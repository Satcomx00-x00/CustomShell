#!/bin/bash

set -e

ZSHRC_URL="https://raw.githubusercontent.com/Satcomx00-x00/CustomShell/refs/heads/main/config/.zshrc"
ZSHRC_DEST="$HOME/.zshrc"

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

log_info "Fetching latest .zshrc from GitHub repository..."

# Check if curl is available
if ! command -v curl &> /dev/null; then
    log_error "curl is not installed. Please install curl first."
    exit 1
fi

# Create backup if existing .zshrc exists
if [[ -f "$ZSHRC_DEST" ]]; then
    backup_file="$ZSHRC_DEST.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$ZSHRC_DEST" "$backup_file"
    log_info "Backed up existing .zshrc to $backup_file"
fi

# Download new .zshrc
if curl -fsSL "$ZSHRC_URL" -o "$ZSHRC_DEST"; then
    log_success "Updated $ZSHRC_DEST with the latest .zshrc from GitHub"
else
    log_error "Failed to download .zshrc from $ZSHRC_URL"
    exit 1
fi

# Make sure the file has correct permissions
chmod 644 "$ZSHRC_DEST"

# Reload configuration in current shell if running interactively
if [[ $- == *i* ]]; then
    source "$ZSHRC_DEST"
    log_success "Reloaded .zshrc in current shell."
else
    log_info "To apply the new configuration, run: source ~/.zshrc"
    log_info "Or restart your terminal/start a new zsh session"
fi

log_success "Zsh configuration update completed!"
