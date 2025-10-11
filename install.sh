#!/bin/bash

# CustomShell Online Installer
# Installs CustomShell directly from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/Satcomx00-x00/CustomShell/main/install.sh | bash

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

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "CustomShell is designed for Linux systems only."
    exit 1
fi

# Repository information
REPO_URL="https://github.com/Satcomx00-x00/CustomShell"
RAW_URL="https://raw.githubusercontent.com/Satcomx00-x00/CustomShell/main"

# Temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Starting CustomShell installation..."
log_info "Repository: $REPO_URL"

# Function to download file
download_file() {
    local url="$1"
    local dest="$2"
    log_info "Downloading: $url"
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$dest"
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Download the main install script
MAIN_INSTALL_URL="$RAW_URL/scripts/install.sh"
MAIN_INSTALL_FILE="$TEMP_DIR/install.sh"

log_info "Downloading installation scripts..."
download_file "$MAIN_INSTALL_URL" "$MAIN_INSTALL_FILE"

# Make it executable
chmod +x "$MAIN_INSTALL_FILE"

# Download the package installer
PKG_INSTALL_URL="$RAW_URL/scripts/install_packages.sh"
PKG_INSTALL_FILE="$TEMP_DIR/install_packages.sh"
download_file "$PKG_INSTALL_URL" "$PKG_INSTALL_FILE"
chmod +x "$PKG_INSTALL_FILE"

# Download configuration files
log_info "Downloading configuration files..."

# Zsh configs
download_file "$RAW_URL/config/.zshrc" "$TEMP_DIR/.zshrc"
download_file "$RAW_URL/config/.zshrc.minimal" "$TEMP_DIR/.zshrc.minimal"

# Starship config
download_file "$RAW_URL/config/starship.toml" "$TEMP_DIR/starship.toml"

# Create a temporary wrapper script that uses the downloaded files
cat > "$TEMP_DIR/run_install.sh" << 'INNER_EOF'
#!/bin/bash
# Wrapper script to run installation with downloaded files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Override the config directory to use our downloaded files
export CUSTOMSHELL_CONFIG_DIR="$SCRIPT_DIR"

# Run the main install script
"$SCRIPT_DIR/install.sh" "$@"
INNER_EOF

chmod +x "$TEMP_DIR/run_install.sh"

# Modify the main install script to use our custom config directory
sed -i 's|PROJECT_CONFIG_DIR="$SCRIPT_DIR\/..\/config"|PROJECT_CONFIG_DIR="${CUSTOMSHELL_CONFIG_DIR:-$SCRIPT_DIR\/..\/config}"|g' "$MAIN_INSTALL_FILE"

log_success "Downloaded all necessary files"
log_info "Starting installation..."

# Run the installation
cd "$TEMP_DIR"
./run_install.sh "$@"

log_success "CustomShell installation completed!"
log_info "Please restart your terminal or run 'exec zsh' to start using CustomShell."
log_info ""
log_info "Installation files were downloaded to: $TEMP_DIR"
log_info "You can safely delete this directory if everything works correctly."
