# Dracula Theme v1.2.5

function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(git_prompt_status)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

function get_host() {
  echo '@'$HOST
}

function git_prompt_status() {
  local INDEX STATUS
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^DD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^UD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^UA ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]* .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]* .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]* .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

PROMPT="%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)%{$fg[red]%}%(!.#.»)%{$reset_color%} "
RPROMPT="%{$fg[cyan]%}$(get_host)%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[cyan]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[red]%}⇡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[red]%}⇣%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[red]%}⇕%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}?%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}→%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[blue]%}$%{$reset_color%}"