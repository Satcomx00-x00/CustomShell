# --- Path and Environment ---

export PATH="/usr/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export BROWSER="firefox"
export NODE_OPTIONS="--max-old-space-size=16384 --max-semi-space-size=64 --optimize-for-size=false"


# --- Key Bindings ---
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- History ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY HIST_VERIFY 

# --- Zsh Options ---
setopt AUTO_CD AUTO_LIST AUTO_MENU AUTO_PARAM_SLASH EXTENDED_GLOB
setopt MENU_COMPLETE HASH_LIST_ALL COMPLETE_IN_WORD NO_BEEP

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _complete _match _approximate _prefix _suffix
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' 

# --- Utility Functions ---

# Set alias if command exists
set_alias_if_exists() {
    local cmd="$1"
    shift
    if command -v "$cmd" &> /dev/null; then
        alias "$@"
    fi
}

# Set multiple aliases for a tool if command exists
set_tool_aliases() {
    local tool="$1"
    local package="$2"
    shift 2
    if command -v "$tool" &> /dev/null; then
        for alias_def in "$@"; do
            alias "$alias_def"
        done
    fi
}

# --- Alias Setup Functions ---

# Python aliases
python_aliases() {
    alias py3='python3'
    alias pipi='pip install'
    alias pipu='pip uninstall'
    alias pipir='pip install -r requirements.txt'
    alias py='python'
    alias pipi3='pip3 install'
    alias pipu3='pip3 uninstall'
    alias pipir3='pip3 install -r requirements.txt'
}

# Tmux aliases
tmux_aliases() {
    set_tool_aliases tmux tmux \
        tmux='tmux -2' \
        tma='tmux attach -t 2>/dev/null || echo "No session found. Use tms <name> to create one."' \
        tms='tmux new-session -s' \
        tmk='tmux kill-session -t' \
        ts='[[ -n "$TMUX" ]] && unset TMUX; tmux new-session -s' \
        tl='tmux list-sessions 2>/dev/null || echo "No tmux sessions running."' \
        tat='tmux attach 2>/dev/null || tmux new-session -s main' \
        tk='tmux kill-server' \
        tx='tmux-start'
}

# Docker aliases
docker_aliases() {
    set_tool_aliases docker docker \
        dk='docker' \
        dkc='docker-compose' \
        dki='docker images' \
        dkr='docker run' \
        dkl='docker logs' \
        dkp='docker ps' \
        dke='docker exec -it' \
        dkb='docker build'
}

# Git aliases
git_aliases() {
    set_tool_aliases git git \
        gs='git status' \
        ga='git add' \
        gc='git commit -m' \
        gp='git push' \
        gl='git log --oneline --graph --decorate --all' \
        gpl='git pull' \
        gco='git checkout' \
        gcm='git checkout master' \
        gcb='git checkout -b' \
        gup='git pull --rebase' \
        gcl='git clone' \
        gpf='git push --force-with-lease' \
        gbr='git branch' \
        gbrd='git branch -d' \
        gbrm='git branch -m' \
        gpr='git pull --rebase'
}

# Directory navigation aliases
navigation_aliases() {
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
}

# System aliases
system_aliases() {
    alias h='history'
    alias j='jobs -l'
    alias df='df -h'
    alias du='du -h'
    alias free='free -h'
    alias ps='ps aux'
    alias top='htop'
    alias mount='mount | column -t'
    alias ping='ping -c 5'
    alias wget='wget -c'
}

# Utility aliases
utility_aliases() {
    alias cleanfd='find . -type d -empty -delete'
    alias reload='exec $SHELL -l'
    alias update-zshrc='bash $HOME/.update-zshrc.sh'
}

# Enhanced tools aliases
enhanced_tools_aliases() {
    # Enhanced listing aliases
    if command -v exa &> /dev/null; then
        alias ls='exa --color=auto'
        alias ll='exa -alF --color=auto'
        alias la='exa -a --color=auto'
        alias l='exa -CF'
        alias lt='exa --tree --color=auto'
    else
        alias ll='ls -alF'
        alias la='ls -A'
        alias l='ls -CF'
    fi

    # Better cat if bat is available
    set_alias_if_exists bat cat='bat'
}

# --- Setup Aliases ---
python_aliases
tmux_aliases
docker_aliases
git_aliases
navigation_aliases
system_aliases
utility_aliases
enhanced_tools_aliases

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Smart tmux session management
tmux-smart() {
    if tmux list-sessions &>/dev/null; then
        echo -e "\e[36mExisting tmux sessions:\e[0m"
        tmux list-sessions
        echo
        read -p "Attach to session (or press Enter for new): " session
        if [[ -n "$session" ]]; then
            tmux attach -t "$session" 2>/dev/null || echo -e "\e[31mSession '$session' not found.\e[0m"
        else
            tmux new-session
        fi
    else
        echo -e "\e[33mNo existing sessions. Creating new session...\e[0m"
        tmux new-session
    fi
}

# Smart tmux starter function
tmux-start() {
    if [[ -n "$TMUX" ]]; then
        echo -e "\e[33mAlready inside tmux session.\e[0m"
        return 1
    fi
    
    if tmux has-session -t main 2>/dev/null; then
        echo -e "\e[36mAttaching to existing 'main' session...\e[0m"
        tmux attach -t main
    else
        echo -e "\e[36mCreating new 'main' session...\e[0m"
        tmux new-session -s main
    fi
}

extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar e "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# --- Environment Variables ---
# Set default editor
export EDITOR="nano"
export VISUAL="nano"


# Development environment setup
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/bin"

# Node.js version manager (nvm)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# Python virtual environment
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
[[ -f "/usr/local/bin/virtualenvwrapper.sh" ]] && source "/usr/local/bin/virtualenvwrapper.sh"

# --- Plugin Configs ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_USE_ASYNC=1
FAST_HIGHLIGHT_MAXLENGTH=300

# --- Welcome Message ---
# echo -e "\e[35mWelcome to your purple Zsh terminal!\e[0m"

banner() {
    # Get system information
    local hostname
    hostname=$(hostname 2>/dev/null || echo "Unknown")
    local username
    username=$(whoami 2>/dev/null || echo "Unknown")
    local uptime
    uptime=$(uptime 2>/dev/null | sed 's/.*up \([^,]*\).*/\1/' | xargs 2>/dev/null || echo "Unknown")
    local kernel
    kernel=$(uname -r 2>/dev/null || echo "Unknown")
    local os
    os=$(uname -s 2>/dev/null || echo "Unknown")
    
    # Get IP addresses
    local local_ip
    local_ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' 2>/dev/null || echo "No connection")
    local public_ip
    public_ip=$(curl -s --max-time 3 ipinfo.io/ip 2>/dev/null || echo "Unknown")
    
    # Get memory info
    local mem_info="N/A"
    if [[ "$os" == "Linux" ]]; then
        if command -v free &> /dev/null; then
            local mem_total
            mem_total=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' 2>/dev/null || echo "N/A")
            local mem_used
            mem_used=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3}' 2>/dev/null || echo "N/A")
            mem_info="$mem_used / $mem_total"
        fi
    elif [[ "$os" == "Darwin" ]]; then
        local mem_total
        mem_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)"GB"}' 2>/dev/null || echo "N/A")
        mem_info="Total: $mem_total"
    fi
    
    # Get load average
    local load_avg="N/A"
    if command -v uptime &> /dev/null; then
        load_avg=$(uptime 2>/dev/null | grep -oP 'load average: \K.*' 2>/dev/null || echo "N/A")
    fi
    
    # Get current time
    local current_time
    current_time=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "Unknown")
    local timezone
    timezone=$(date '+%Z' 2>/dev/null || echo "Unknown")
    
    # Get shell info
    local shell_version
    shell_version=$(zsh --version 2>/dev/null | cut -d' ' -f2 2>/dev/null || echo "Unknown")
    
    # Get terminal size
    local term_size="${COLUMNS:-Unknown}x${LINES:-Unknown}"
    
    # Print the banner
    echo -e "\e[35m╔════════════════════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[35m║\e[0m                          \e[1;35m🚀 Custom Zsh Shell\e[0m                             \e[35m║\e[0m"
    echo -e "\e[35m╠════════════════════════════════════════════════════════════════════════════╣\e[0m"
    
    # Dynamic information
    printf "  \e[36m👤 User:\e[0m %-18s \e[36m🖥️  Host:\e[0m %s\n" "$username" "$hostname"
    printf "  \e[36m🌐 Local IP:\e[0m %-14s \e[36m🌍 Public IP:\e[0m %s\n" "$local_ip" "$public_ip"
    printf "  \e[36m⏰ Time:\e[0m %-19s \e[36m🌎 Zone:\e[0m %s\n" "$current_time" "$timezone"
    printf "  \e[36m⏱️  Uptime:\e[0m %-16s \e[36m🧠 Memory:\e[0m %s\n" "$uptime" "$mem_info"
    printf "  \e[36m📊 Load:\e[0m %-18s \e[36m🖥️  Terminal:\e[0m %s\n" "$load_avg" "$term_size"
    printf "  \e[36m🐧 Kernel:\e[0m %-15s \e[36m🐚 Zsh:\e[0m %s\n" "$kernel" "$shell_version"
    
    echo -e "\e[35m╠════════════════════════════════════════════════════════════════════════════╣\e[0m"
    echo -e "\e[35m║\e[0m                    \e[33m💡 Type 'help' for available commands\e[0m                    \e[35m║\0m"
    echo -e "\e[35m╚════════════════════════════════════════════════════════════════════════════╝\e[0m"
    echo
}

# --- Help Command ---
help-zsh() {
    echo "Available commands and aliases:"
    echo "  - reload: Reload the shell"
    echo "  - update-zshrc: Update the .zshrc file"
    echo "  - mkcd <dir>: Create directory and cd into it"
    echo "  - tmux-smart: Interactive tmux session manager"
    echo "  - tmux-start: Smart tmux starter"
    echo "  - extract <file>: Extract archives"
    echo "  - banner: Display system information banner"
    echo "See the .zshrc file for more aliases and functions."
}

alias help='help-zsh'

banner