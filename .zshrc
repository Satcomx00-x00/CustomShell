# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History configuration
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Enhanced plugin list
plugins=(
    git
    docker
    docker-compose
    kubectl
    terraform
    ansible
    aws
    gcloud
    helm
    node
    npm
    yarn
    python
    pip
    virtualenv
    golang
    rust
    ruby
    rails
    laravel
    symfony
    composer
    colored-man-pages
    command-not-found
    extract
    z
    sudo
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fast-syntax-highlighting
    bun
    gh
    pip
    tmux
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'
export VISUAL='vim'
export BROWSER='firefox'

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Enhanced aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git rebase'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias dk='docker'
alias dkc='docker-compose'
alias dki='docker images'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkex='docker exec -it'
alias dklogs='docker logs -f'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kex='kubectl exec -it'
alias klogs='kubectl logs -f'

# Tmux aliases
alias tm='tmux'
alias tma='tmux attach -t'
alias tms='tmux new-session -s'
alias tml='tmux list-sessions'
alias tmk='tmux kill-session -t'

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

# Zsh options
setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt EXTENDED_GLOB
setopt MENU_COMPLETE
setopt HASH_LIST_ALL
setopt COMPLETE_IN_WORD
setopt NO_BEEP

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Plugin configurations
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Fast syntax highlighting
FAST_HIGHLIGHT_MAXLENGTH=300

# Autocomplete configuration
zstyle ':autocomplete:*' min-delay 0.1
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' max-lines 10

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# (Custom Powerlevel10k config is provided. No need to run p10k configure.)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Custom welcome message
echo "🚀 Welcome to your enhanced Zsh environment!"
echo "💡 Type 'help-zsh' for custom commands and shortcuts"

# Tmux auto-start (uncomment to enable)
# if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
#     tmux attach-session -t default || tmux new-session -s default
# fi

# Help function
help-zsh() {
    echo "Custom Zsh Environment Help:"
    echo "============================="
    echo "📁 Navigation:"
    echo "  .. / ... / .... - Go up directories"
    echo "  mkcd <dir>      - Create and enter directory"
    echo ""
    echo "🔧 Git shortcuts:"
    echo "  gs / ga / gc / gp - status / add / commit / push"
    echo "  glog             - Pretty git log"
    echo ""
    echo "🐳 Docker shortcuts:"
    echo "  dk / dkc         - docker / docker-compose"
    echo "  dkps / dkpsa     - List containers"
    echo ""
    echo "☸️  Kubernetes shortcuts:"
    echo "  k / kgp / kgs    - kubectl / get pods / get services"
    echo ""
    echo "📺 Tmux shortcuts:"
    echo "  tm / tma / tms   - tmux / attach / new session"
    echo "  tml / tmk        - list sessions / kill session"
    echo "  Prefix: Ctrl-a   - Use Ctrl-a instead of Ctrl-b"
    echo ""
    echo "🎨 Enhanced tools:"
    echo "  ls (exa) / cat (bat) - Better versions if installed"
    echo ""
    echo "Run 'p10k configure' to setup your theme!"
    echo "Run 'tmux' to start your enhanced terminal multiplexer!"
}