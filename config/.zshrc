# --- Path and Environment ---

export PATH="/usr/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="vim"
export BROWSER="firefox"

# --- Zinit plugin manager ---
if [[ ! -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
    echo "Installing zinit plugin manager..."
    mkdir -p "$HOME/.zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
fi
source "$HOME/.zinit/bin/zinit.zsh"

# Initialize completion system BEFORE loading plugins
autoload -U compinit && compinit

# --- Plugins (managed by zinit) ---
zinit ice depth=1; zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light zsh-users/zsh-syntax-highlighting
zinit ice depth=1; zinit light zsh-users/zsh-completions
zinit ice depth=1; zinit light zsh-users/zsh-history-substring-search
zinit ice depth=1; zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit ice depth=1; zinit light Aloxaf/fzf-tab

# --- OMZ snippets/plugins via zinit ---
zinit snippet OMZP::git
zinit snippet OMZP::python
zinit snippet OMZP::tmux
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl
zinit snippet OMZP::command-not-found

# Load zinit completions (now compinit is already loaded)
zinit cdreplay -q

# --- Powerlevel10k config ---
# Ensure this is after zinit loads powerlevel10k
if [[ -f "$HOME/.p10k.zsh" ]]; then
    source "$HOME/.p10k.zsh"
else
    echo "[WARNING] $HOME/.p10k.zsh not found or not readable"
fi

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

# --- Aliases ---
# Enhanced aliases
alias ll='exa -alF'
alias la='exa -a'
alias l='exa -CF'

alias reload='exec $SHELL -l'
alias ::='sudo $(fc -ln -1)' # sexy alias, because '!!' 
alias update-zshrc='bash $HOME/.update-zshrc.sh'

# --- Python Aliases ---
alias py3='python3'
alias pipi='pip install'
alias pipu='pip uninstall'
alias pipir='pip install -r requirements.txt'

alias py='python'
alias pipi3='pip3 install'
alias pipu3='pip3 uninstall'
alias pipir3='pip3 install -r requirements.txt'

# --- Tmux Aliases ---
alias tmux='tmux -2'
alias tma='tmux attach -t 2>/dev/null || echo "No session found. Use tms <name> to create one."'
alias tms='tmux new-session -s'
alias tmk='tmux kill-session -t'
alias ts='[[ -n "$TMUX" ]] && unset TMUX; tmux new-session -s'
alias tl='tmux list-sessions 2>/dev/null || echo "No tmux sessions running."'
alias tat='tmux attach 2>/dev/null || tmux new-session -s main'
alias tk='tmux kill-server'  # Kill all tmux sessions

# Smart tmux starter - creates or attaches to default session
alias tx='tmux-start'

# --- Docker Aliases ---
alias dk='docker'
alias dkc='docker-compose'
alias dki='docker images'
alias dkr='docker run'
alias dkl='docker logs'
alias dkp='docker ps'
alias dke='docker exec -it'
alias dkb='docker build'

# --- Git Aliases ---
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gpl='git pull'
alias gco='git checkout'
alias gcm='git checkout master'
alias gcb='git checkout -b'
alias gup='git pull --rebase'
alias gcl='git clone'
alias gpf='git push --force-with-lease'
alias gbr='git branch'
alias gbrd='git branch -d'
alias gbrm='git branch -m'
alias gpr='git pull --rebase'

# --- Directory Navigation Aliases ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- System Aliases ---
alias h='history'
alias j='jobs -l'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop'

# Mounting and network aliases
alias mount='mount | column -t'
alias ping='ping -c 5'
alias wget='wget -c'


# System aliases
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









# Better tools aliases (if available)
if command -v exa &> /dev/null; then
    alias ls='exa --color=auto'
    alias ll='exa -alF --color=auto'
    alias la='exa -a --color=auto'
    alias lt='exa --tree --color=auto'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

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
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
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
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin

# Node.js version manager (if using nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Python virtual environment
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

# --- Plugin Configs ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_USE_ASYNC=1
FAST_HIGHLIGHT_MAXLENGTH=300

# --- Welcome Message ---
# echo -e "\e[35mWelcome to your purple Zsh terminal!\e[0m"

banner() {
    # Get system information
    local hostname=$(hostname)
    local username=$(whoami)
    local uptime=$(uptime 2>/dev/null | sed 's/.*up \([^,]*\).*/\1/' | xargs || echo "Unknown")
    local kernel=$(uname -r 2>/dev/null || echo "Unknown")
    local os=$(uname -s 2>/dev/null || echo "Unknown")
    
    # Get IP addresses
    local local_ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "No connection")
    local public_ip=$(curl -s --max-time 3 ipinfo.io/ip 2>/dev/null || echo "Unknown")
    
    # Get memory info
    local mem_info=""
    if [[ "$os" == "Linux" ]]; then
        if command -v free &> /dev/null; then
            local mem_total=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "N/A")
            local mem_used=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3}' || echo "N/A")
            mem_info="$mem_used / $mem_total"
        else
            mem_info="N/A"
        fi
    elif [[ "$os" == "Darwin" ]]; then
        local mem_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)"GB"}' || echo "N/A")
        mem_info="Total: $mem_total"
    else
        mem_info="N/A"
    fi
    
    # Get load average
    local load_avg=""
    if command -v uptime &> /dev/null; then
        load_avg=$(uptime 2>/dev/null | grep -oP 'load average: \K.*' || echo "N/A")
    else
        load_avg="N/A"
    fi
    
    # Get current time
    local current_time=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "Unknown")
    local timezone=$(date '+%Z' 2>/dev/null || echo "Unknown")
    
    # Get shell info
    local shell_version=$(zsh --version 2>/dev/null | cut -d' ' -f2 || echo "Unknown")
    
    # Get terminal size
    local term_size="${COLUMNS}x${LINES}"
    
    # Print the banner
    echo -e "\e[35m╔════════════════════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[35m║\e[0m                          \e[1;35m🚀 Custom Zsh Shell\e[0m                             \e[35m║\e[0m"
    echo -e "\e[35m╠════════════════════════════════════════════════════════════════════════════╣\e[0m"
    
    # Dynamic information without vertical borders
    printf "  \e[36m👤 User:\e[0m %-18s \e[36m🖥️  Host:\e[0m %s\n" "$username" "$hostname"
    printf "  \e[36m🌐 Local IP:\e[0m %-14s \e[36m🌍 Public IP:\e[0m %s\n" "$local_ip" "$public_ip"
    printf "  \e[36m⏰ Time:\e[0m %-19s \e[36m🌎 Zone:\e[0m %s\n" "$current_time" "$timezone"
    printf "  \e[36m⏱️  Uptime:\e[0m %-16s \e[36m🧠 Memory:\e[0m %s\n" "$uptime" "$mem_info"
    printf "  \e[36m📊 Load:\e[0m %-18s \e[36m🖥️  Terminal:\e[0m %s\n" "$load_avg" "$term_size"
    printf "  \e[36m🐧 Kernel:\e[0m %-15s \e[36m🐚 Zsh:\e[0m %s\n" "$kernel" "$shell_version"
    
    echo -e "\e[35m╠════════════════════════════════════════════════════════════════════════════╣\e[0m"
    echo -e "\e[35m║\e[0m                    \e[33m💡 Type 'help' for available commands\e[0m                    \e[35m║\e[0m"
    echo -e "\e[35m╚════════════════════════════════════════════════════════════════════════════╝\e[0m"
    echo
}

# --- Help Command ---
help-zsh() {
    echo -e "\e[35m╔════════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[35m║                    Custom Zsh Shell Help                       ║\e[0m"
    echo -e "\e[35m╚════════════════════════════════════════════════════════════════╝\e[0m"
    echo
    
    echo -e "\e[36m📁 Directory Navigation:\e[0m"
    echo "  ..              - Go up one directory"
    echo "  ...             - Go up two directories"
    echo "  ....            - Go up three directories"
    echo "  mkcd <dir>      - Create and change to directory"
    echo
    
    echo -e "\e[36m📝 File Operations:\e[0m"
    echo "  ls/ll/la/l      - Enhanced listing (using exa if available)"
    echo "  lt              - Tree view of directory"
    echo "  cat             - Enhanced cat (using bat if available)"
    echo "  extract <file>  - Extract various archive formats"
    echo    
    echo -e "\e[36m🔧 System Commands:\e[0m"
    echo "  reload          - Restart current shell"
    echo "  ::              - Run last command with sudo"
    echo "  h               - Show command history"
    echo "  j               - List active jobs"
    echo "  df/du/free      - Disk/memory usage (human readable)"
    echo "  ps              - Process list (aux format)"
    echo "  top             - Process monitor (htop if available)"
    echo "  mount           - Show mounted filesystems (formatted)"
    echo "  ping            - Ping with 5 packets limit"
    echo "  wget            - Continue partial downloads"
    echo    
    echo -e "\e[36m🐍 Python Development:\e[0m"
    echo "  py/py3          - Python interpreter shortcuts"
    echo "  pipi/pipi3      - pip install shortcut"
    echo "  pipu/pipu3      - pip uninstall shortcut"
    echo "  pipir/pipir3    - Install from requirements.txt"
    echo    
    echo -e "\e[36m🖥️ Tmux Session Management:\e[0m"
    echo "  tmux            - Start tmux with 256 color support"
    echo "  tx              - Smart tmux start (main session)"
    echo "  tma <session>   - Attach to tmux session (with error handling)"
    echo "  tms <session>   - Create new tmux session"
    echo "  tmk <session>   - Kill tmux session"
    echo "  tk              - Kill tmux server (all sessions)"
    echo "  ts <session>    - Force new session (unsets TMUX)"
    echo "  tl              - List all tmux sessions (safe)"
    echo "  tat             - Attach to session or create 'main'"
    echo "  tmux-smart      - Interactive session management"
    echo    
    echo -e "\e[36m🐳 Docker Management:\e[0m"
    echo "  dk              - Docker command shortcut"
    echo "  dkc             - Docker Compose shortcut"
    echo "  dki             - List docker images"
    echo "  dkr             - Run docker container"
    echo "  dkl             - Show docker logs"
    echo "  dkp             - List docker processes"
    echo "  dke             - Execute command in container"
    echo "  dkb             - Build docker image"
    echo    
    echo -e "\e[36m📊 Git Version Control:\e[0m"
    echo "  gs              - git status"
    echo "  ga              - git add"
    echo "  gc              - git commit -m"
    echo "  gp              - git push"
    echo "  gl              - git log (oneline graph)"
    echo "  gpl/gpr         - git pull (with rebase option)"
    echo "  gco             - git checkout"
    echo "  gcm             - git checkout master"
    echo "  gcb             - git checkout -b (new branch)"
    echo "  gcl             - git clone"
    echo "  gpf             - git push --force-with-lease"
    echo "  gbr/gbrd/gbrm   - git branch operations"
    echo    
    echo -e "\e[36m⚙️ Configuration Management:\e[0m"
    echo "  update-zshrc    - Update .zshrc from GitHub repository"
    echo "  p10k configure  - Configure Powerlevel10k theme"
    echo    
    echo -e "\e[36m🔧 Custom Functions:\e[0m"
    echo "  help-zsh        - Show this help message"
    echo "  extract <file>  - Extract archives (supports multiple formats)"
    echo "  mkcd <dir>      - Create directory and cd into it"
    echo    
    echo -e "\e[36m⌨️ Key Bindings:\e[0m"
    echo "  Ctrl+A          - Move to beginning of line"
    echo "  Ctrl+E          - Move to end of line"
    echo "  Up/Down Arrow   - History substring search"
    echo "  Tab             - Enhanced completion with fzf"
    echo    
    echo -e "\e[36m🎨 Theme & UI:\e[0m"
    echo "  • Purple-themed Powerlevel10k prompt"
    echo "  • Tmux with matching purple color scheme"
    echo "  • Enhanced syntax highlighting with DroidSansMono Nerd Font icons"
    echo "  • Auto-suggestions with async loading"
    echo "  • DroidSansMono Nerd Font with comprehensive icon support"
    echo    
    echo -e "\e[36m📦 Installed Plugins:\e[0m"
    echo "  • zsh-autosuggestions    - Command suggestions"
    echo "  • zsh-syntax-highlighting - Syntax coloring"
    echo "  • zsh-completions        - Additional completions"
    echo "  • fast-syntax-highlighting - Fast syntax coloring"
    echo "  • fzf-tab               - Fuzzy completion"
    echo "  • powerlevel10k         - Modern prompt theme"
    echo    
    echo -e "\e[33m💡 Tips:\e[0m"
    echo "  • Use 'Tab' for intelligent completions"
    echo "  • Type partial commands and use Up/Down arrows"
    echo "  • Run 'p10k configure' to customize your prompt"
    echo "  • Use 'update-zshrc' to get latest configuration"
    echo "  • Tmux prefix key is Ctrl+A (not Ctrl+B)"
    echo "  • Use 'tx' for quick tmux start with main session"
    echo "  • Use 'tmux-smart' for interactive session management"
    echo "  • Use 'tk' to kill all tmux sessions if stuck"
    echo "  • Set terminal font to 'DroidSansMono Nerd Font' for best experience"
    echo "  • DroidSansMono Nerd Font provides comprehensive icon and symbol support"

    echo -e "\e[32m🔗 Quick Reference:\e[0m"
    echo "  Configuration: ~/.zshrc, ~/.p10k.zsh, ~/.tmux.conf"
    echo "  Update script: ~/.update-zshrc.sh"
    echo "  History file:  ~/.zsh_history"
    echo
}

alias help='help-zsh'

banner