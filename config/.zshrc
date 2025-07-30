# --- Path and Environment ---
export PATH="/usr/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="vim"
export BROWSER="firefox"

# --- Oh My Zsh & Theme ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# --- Plugins ---
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    history-substring-search
    fast-syntax-highlighting
    docker
    tmux
    python
    node
    rust
    kubectl
    aws
    gh
    bun
    sudo
    extract
    colored-man-pages
    command-not-found
)

source $ZSH/oh-my-zsh.sh

# --- Powerlevel10k config ---
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --- History ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY HIST_VERIFY

# --- Zsh Options ---
setopt AUTO_CD AUTO_LIST AUTO_MENU AUTO_PARAM_SLASH EXTENDED_GLOB
setopt MENU_COMPLETE HASH_LIST_ALL COMPLETE_IN_WORD NO_BEEP


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


# --- Plugin Configs ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_USE_ASYNC=1
FAST_HIGHLIGHT_MAXLENGTH=300

# --- Key Bindings ---
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- Welcome Message ---
echo -e "\e[35mWelcome to your purple Zsh terminal!\e[0m"

# --- Help Command ---
help-zsh() {
    echo "Custom Zsh Help:"
    echo "  .. / ... / mkcd <dir>   - Directory navigation"
    echo "  gs / ga / gc / gp       - Git shortcuts"
    echo "  dk / tma / tms / k      - Docker/Tmux/K8s"
    echo "  ls (exa), cat (bat)     - Enhanced tools if installed"
    echo "  Run 'p10k configure' to tweak your prompt"
}