#!/bin/bash

# Custom Starship Zsh Shell Installer
# This script installs Zsh with Starship prompt, oh-my-zsh, and useful plugins
# Uses Dracula theme for Starship

set -e

# Default settings
INSTALL_PLUGINS=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-plugins)
            INSTALL_PLUGINS=false
            shift
            ;;
        --help|-h)
            echo "Custom Starship Zsh Shell Installer"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-plugins    Skip installation of Zsh plugins"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              Install everything (default)"
            echo "  $0 --no-plugins Install without Zsh plugins"
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

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This installer is designed for Linux systems only."
    exit 1
fi

# Check if running as root (for system-wide installation)
if [[ $EUID -eq 0 ]]; then
    log_warning "Running as root. Installing system-wide."
    INSTALL_PREFIX="/usr/local"
    CONFIG_DIR="/etc"
else
    log_info "Running as user. Installing locally."
    INSTALL_PREFIX="$HOME/.local"
    CONFIG_DIR="$HOME/.config"
fi

# Install system dependencies
log_info "Installing system dependencies..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/scripts/install_packages.sh"

# Install Starship
log_info "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$INSTALL_PREFIX/bin" --verbose

# Add Starship to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
    export PATH="$INSTALL_PREFIX/bin:$PATH"
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$HOME/.zshrc"
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

# Create Starship config directory
mkdir -p "$CONFIG_DIR/starship"

# Create Starship config with Dracula theme
log_info "Configuring Starship with Dracula theme..."
cat > "$CONFIG_DIR/starship/starship.toml" << 'EOF'
# Starship configuration with Dracula theme

# Dracula color palette
[palettes.dracula]
background = "#282a36"
current_line = "#44475a"
foreground = "#f8f8f2"
comment = "#6272a4"
cyan = "#8be9fd"
green = "#50fa7b"
orange = "#ffb86c"
pink = "#ff79c6"
purple = "#bd93f9"
red = "#ff5555"
yellow = "#f1fa8c"

[palette]
use = "dracula"

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](green)"

[git_branch]
symbol = "🌱 "
truncation_length = 4
truncation_symbol = ""

[git_commit]
commit_hash_length = 4
tag_symbol = "🔖 "

[git_state]
format = '[\($state( $progress_current of $progress_total)\)]($style) '
cherry_pick = "[🍒 PICKING](bold red)"

[git_status]
conflicted = "🏳"
ahead = "🏎💨"
behind = "😰"
diverged = "😵"
untracked = "🤷"
stashed = "📦"
modified = "📝"
staged = '[++\($count\)](green)'
renamed = "👅"
deleted = "🗑"

[hostname]
ssh_only = false
format = "[$hostname](bold red) "
trim_at = ".local"
disabled = false

[username]
style_user = "white bold"
style_root = "black bold"
format = "user: [$user]($style) "
disabled = false
show_always = true

[directory]
truncation_length = 10
truncation_symbol = "…/"
home_symbol = "🏠"
read_only_style = "197"
read_only = " 🔒"
format = "[$path]($style)[$read_only]($read_only_style) "

[cmd_duration]
min_time = 4_000
format = "[$duration]($style) "

[battery]
full_symbol = "🔋"
charging_symbol = "🔌"
discharging_symbol = "💀"
disabled = false

[[battery.display]]
threshold = 10
style = "bold red"

[time]
disabled = false
format = "🕙[$time]($style) "
time_format = "%T"
utc_time_offset = "local"

[package]
symbol = "📦 "
style = "208"
format = "[$symbol$version]($style) "
disabled = false

[nodejs]
symbol = "⬢ "
style = "bold green"
format = "[$symbol($version )]($style)"

[rust]
symbol = "🦀 "
style = "bold red"
format = "[$symbol($version )]($style)"

[golang]
symbol = "🐹 "
style = "bold cyan"
format = "[$symbol($version )]($style)"

[php]
symbol = "🐘 "
style = "bold magenta"
format = "[$symbol($version )]($style)"

[python]
symbol = "🐍 "
style = "bold yellow"
format = "[$symbol($version )]($style)"

[docker_context]
symbol = "🐳 "
style = "blue bold"
format = "[$symbol$context]($style) "

[kubernetes]
symbol = "☸️ "
style = "cyan bold"
format = "[$symbol$context \($namespace\)]($style) "

[terraform]
symbol = "🏗️ "
style = "bold 105"
format = "[$symbol$workspace]($style) "
EOF

# Create .zshrc
log_info "Creating .zshrc configuration..."
if [[ "$INSTALL_PLUGINS" == "true" ]]; then
    # With plugins
    cat > "$HOME/.zshrc" << 'EOF'
# Custom Zsh configuration with Starship and plugins

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to empty (using Starship)
ZSH_THEME=""

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Initialize Starship
eval "$(starship init zsh)"

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Enable vi mode
# bindkey -v

# Custom functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Load additional configurations if they exist
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
EOF
else
    # Without plugins
    cat > "$HOME/.zshrc" << 'EOF'
# Custom Zsh configuration with Starship (no plugins)

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to empty (using Starship)
ZSH_THEME=""

# Plugins (minimal - only git)
plugins=(git)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Initialize Starship
eval "$(starship init zsh)"

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Enable vi mode
# bindkey -v

# Custom functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Load additional configurations if they exist
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
EOF
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
log_info "Starship configuration is located at: $CONFIG_DIR/starship/starship.toml"
log_info "Zsh configuration is located at: $HOME/.zshrc"