# Custom Starship Zsh Shell Container
# Based on Debian latest with Starship prompt, oh-my-zsh, and useful plugins
# Uses Dracula theme for Starship

FROM debian:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    zsh \
    build-essential \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user
RUN useradd -m -s /bin/zsh developer && \
    echo 'developer:password' | chpasswd && \
    usermod -aG sudo developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the user
USER developer
WORKDIR /home/developer

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes --verbose

# Add Starship to PATH
ENV PATH="/home/developer/.cargo/bin:$PATH"

# Install oh-my-zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# Install Zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# Create Starship config directory
RUN mkdir -p ~/.config/starship

# Create Starship config with Dracula theme
RUN cat > ~/.config/starship/starship.toml << 'EOF'
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
RUN cat > ~/.zshrc << 'EOF'
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

# Enable vi mode (optional)
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

# Set the default shell to Zsh
RUN sudo chsh -s /bin/zsh developer

# Expose port if needed (optional)
# EXPOSE 8080

# Default command
CMD ["zsh"]