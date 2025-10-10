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

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'

# Python aliases
alias py='python3'
alias pip='python3 -m pip'
alias venv='python3 -m venv'
alias act='source venv/bin/activate'
alias deact='deactivate'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlf='docker logs -f'

# Kubernetes aliases
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'
alias kc='kubectl config'
alias kcu='kubectl config use-context'
alias kcg='kubectl config get-contexts'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'

# Helm aliases
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade'
alias hun='helm uninstall'
alias hl='helm list'
alias hs='helm status'
alias hr='helm repo'
alias hra='helm repo add'
alias hru='helm repo update'

# Go aliases
alias gr='go run'
alias gb='go build'
alias gt='go test'
alias gm='go mod'
alias gmt='go mod tidy'
alias gmi='go mod init'

# Rust aliases
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cc='cargo check'
alias cn='cargo new'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'

# Bun aliases
alias b='bun'
alias br='bun run'
alias bd='bun dev'
alias bb='bun build'
alias bt='bun test'
alias ba='bun add'
alias brr='bun remove'

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

# Python virtual environment helpers
function pyenv() {
    if [ -z "$1" ]; then
        echo "Usage: pyenv <env_name>"
        return 1
    fi
    python3 -m venv "$1"
    source "$1/bin/activate"
    echo "Virtual environment '$1' created and activated"
}

function pyact() {
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        echo "Activated virtual environment"
    elif [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        echo "Activated virtual environment (.venv)"
    else
        echo "No virtual environment found in venv/ or .venv/"
        return 1
    fi
}

# Docker helpers
function dshell() {
    if [ -z "$1" ]; then
        echo "Usage: dshell <container_name_or_id>"
        return 1
    fi
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

function dclean() {
    echo "Removing stopped containers..."
    docker container prune -f
    echo "Removing unused images..."
    docker image prune -f
    echo "Removing unused volumes..."
    docker volume prune -f
    echo "Removing unused networks..."
    docker network prune -f
}

# Kubernetes helpers
function kctx() {
    if [ -z "$1" ]; then
        kubectl config get-contexts
    else
        kubectl config use-context "$1"
    fi
}

function kns() {
    if [ -z "$1" ]; then
        kubectl get namespaces
    else
        kubectl config set-context --current --namespace="$1"
    fi
}

function klogs() {
    if [ -z "$1" ]; then
        echo "Usage: klogs <pod_name> [container_name]"
        return 1
    fi
    if [ -n "$2" ]; then
        kubectl logs -f "$1" -c "$2"
    else
        kubectl logs -f "$1"
    fi
}

# Git helpers
function gacp() {
    if [ -z "$1" ]; then
        echo "Usage: gacp <commit_message>"
        return 1
    fi
    git add .
    git commit -m "$1"
    git push
}

function gbranch() {
    if [ -z "$1" ]; then
        echo "Usage: gbranch <branch_name>"
        return 1
    fi
    git checkout -b "$1"
}

# Development helpers
function serve() {
    if [ -z "$1" ]; then
        port=8000
    else
        port="$1"
    fi
    python3 -m http.server "$port"
}

# Load additional configurations if they exist
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi