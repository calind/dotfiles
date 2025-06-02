# zmodload zsh/zprof

setopt autocd
unsetopt beep

# Home, End, Delete key bindings
bindkey '\e[H'  beginning-of-line
bindkey '\e[F'  end-of-line
bindkey '\e[3~' delete-char

# Set locales
if [ ! -z "${LANG}" ]; then
    export LC_COLLATE=C
    export LC_CTYPE="${LANG}"
fi

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000

declare -A colors
colors[bg_0]="#103c48"
colors[bg_1]="#184956"
colors[bg_2]="#2d5b69"
colors[dim_0]="#72898f"
colors[fg_0]="#adbcbc"
colors[fg_1]="#cad8d9"
colors[red]="#fa5750"
colors[green]="#75b938"
colors[yellow]="#dbb32d"
colors[blue]="#4695f7"
colors[magenta]="#f275be"
colors[cyan]="#41c7b9"
colors[orange]="#ed8649"
colors[violet]="#af88eb"
colors[br_red]="#ff665c"
colors[br_green]="#84c747"
colors[br_yellow]="#ebc13d"
colors[br_blue]="#58a3ff"
colors[br_magenta]="#ff84cd"
colors[br_cyan]="#53d6c7"
colors[br_orange]="#fd9456"
colors[br_violet]="#bd96fa"
export colors

# setup Homebrew environment
if [ -z "${HOMEBREW_PREFIX}" ] && [ -x "/usr/local/bin/brew" ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -z "${HOMEBREW_PREFIX}" ] && [ -x "/opt/homebrew/bin/brew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -z "${HOMEBREW_PREFIX}" ] && [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] ; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -n "${HOMEBREW_PREFIX}" ]; then
    FPATH="${HOMEBREW_PREFIX}/share/zsh-completions:${FPATH}"
fi

# Add development tools to PATH
if [ -d "${HOMEBREW_PREFIX}/opt/node@20/bin" ] ; then
    export PATH="${HOMEBREW_PREFIX}/opt/node@20/bin:${PATH}"
fi

if [ -d "${HOMEBREW_PREFIX}/opt/python@3.12/bin" ] ; then
    export PATH="${HOMEBREW_PREFIX}/opt/python@3.12/bin:${PATH}"
fi

if [ -d "${HOMEBREW_PREFIX}/opt/go@1.23/bin" ] ; then
    export PATH="${HOMEBREW_PREFIX}/opt/go@1.23/bin:${PATH}"
fi

if [ -d "${HOMEBREW_PREFIX}/opt/php@8.1/bin" ] ; then
    export PATH="${HOMEBREW_PREFIX}/opt/php@8.1/bin:${PATH}"
fi

FPATH="${HOME}/.zfunc:${FPATH}"
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Load version control information
autoload -Uz vcs_info
autoload -U add-zsh-hook

# check for changes
zstyle ':vcs_info:*' check-for-changes true

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' unstagedstr '*'
zstyle ':vcs_info:*:*' formats ' (%b)%u%c'
zstyle ':vcs_info:*:*' actionformats ' (%b|%a)%u%c'
zstyle ':vcs_info:*:*' nvcsformats ''

### git: Show unstagedstr marker (*) if there are untracked files in repository
# Make sure you have added unstaged to your 'formats':  %u
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        hook_com[unstaged]='*'
    fi
}

if [[ -n "${HOMEBREW_PREFIX}" ]] && [[ -f "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh" ]]; then
    source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"
fi

_set_prompt() {
    vcs_info

    local venv=""

    if [[ -n "${VIRTUAL_ENV}" ]] ; then
        if [[ -n "${VIRTUAL_ENV_PROMPT}" ]] ; then
            venv="${VIRTUAL_ENV_PROMPT}"
        elif [[ "${VIRTUAL_ENV##*/}" == ".venv" ]] ; then
            venv="(${$(dirname "$VIRTUAL_ENV")##*/}) "
        else
            venv="(${VIRTUAL_ENV##*/}) "
        fi
    fi

    host_prompt=""
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        host_prompt="%K{${colors[bg_1]}}%F{${colors[dim_0]}} %n@%m %f%k "
    fi

    PS1="%F{3}λ%f ${host_prompt}${venv}%~${vcs_info_msg_0_} ❯ "
    PS2="  ❯ "
    RPROMPT=""

    if [[ "off" != "${KUBE_PS1_ENABLED}" ]]; then
        test -n "${KUBE_PS1_CONTEXT}" && RPROMPT="${KUBE_PS1_CONTEXT}"
        test -n "${KUBE_PS1_NAMESPACE}" && RPROMPT="${RPROMPT}:${KUBE_PS1_NAMESPACE}"
    fi

    test -n "${RPROMPT}" && RPROMPT="%K{${colors[bg_1]}}%F{${colors[dim_0]}} ${RPROMPT} %f%k"

}

function git() {
    if [ "${PWD}" = "${HOME}" ] || [ "${PWD}" = "${HOME}/.config" ] || [ "${PWD}" = "${HOME}/.local" ]; then
        GIT_DIR="${HOME}/.dotfiles.git" \
        GIT_WORK_TREE="${HOME}" \
            command git "$@"
    else
        command git "$@"
    fi
}

add-zsh-hook precmd _set_prompt

if [[ -n "${HOMEBREW_PREFIX}" ]] && [[ -x "${HOMEBREW_PREFIX}/bin/gls" ]]; then
    alias ls="${HOMEBREW_PREFIX}/bin/gls"
fi

DIRCOLORS=/usr/bin/dircolors
if [[ -n "${HOMEBREW_PREFIX}" ]] && [[ -x "${HOMEBREW_PREFIX}/bin/gdircolors" ]]; then
    DIRCOLORS="${HOMEBREW_PREFIX}/bin/gdircolors"
    alias dircolors="${DIRCOLORS}"
fi

if [[ -x "${DIRCOLORS}" ]]; then
    test -r "${HOME}/.dircolors" && eval "$("${DIRCOLORS}" -b "${HOME}/.dircolors")" || eval "$($DIRCOLORS -b)"

    if [[ -n "${HOMEBREW_PREFIX}" ]] && [[ -x "${HOMEBREW_PREFIX}/bin/gls" ]]; then
        alias ls="${HOMEBREW_PREFIX}/bin/gls --color=auto"
    else
        alias ls='ls --color=auto'
    fi

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [[ -d "${HOME}/.composer/vendor/bin" ]] ; then
    export PATH="${HOME}/.composer/vendor/bin:$PATH"
fi

export GOPATH="$HOME/work"
export PATH="$GOPATH/bin:$PATH"

if [[ -d "${HOME}/.local/bin" ]] ; then
    export PATH="${HOME}/.local/bin:$PATH"
fi

if [ $commands[nvim] ]; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

if [ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ] ; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
fi

if [ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc ] ; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
fi

# lazy load kubectl completion
if [ $commands[kubectl] ]; then
  kubectl() {
    unfunction "$0"
    source <(kubectl completion zsh)
    $0 "$@"
  }
fi

# lazy load azure-cli completion
if [ $commands[az] ]; then
  az() {
    unfunction "$0"
    test -f "${HOMEBREW_PREFIX}/etc/bash_completion.d/az" && source "${HOMEBREW_PREFIX}/etc/bash_completion.d/az"
    $0 "$@"
  }
fi

FZF_PREVIEW_OPTS="cat {}"
if [ $commands[rich] ]; then
    FZF_PREVIEW_OPTS="rich --force-terminal -n -y --max-width=\$FZF_PREVIEW_COLUMNS {}"
fi

FZF_DEFAULT_OPTS=$(cat <<-EOD
    --color="fg:${colors[fg_0]},bg:${colors[bg_0]},hl:${colors[cyan]}:bold"
    --color="fg+:${colors[fg_0]}:regular,bg+:${colors[bg_1]},hl+:$colors[br_cyan]:bold"
    --color="pointer:${colors[cyan]},prompt:${colors[yellow]}:bold"
    --color="info:${colors[blue]}"
    --color="query:${colors[fg_0]}:regular"
    --color="border:${colors[bg_2]}"
    --color="header:${colors[fg_1]}:bold,label:${colors[fg_1]}:bold"
    --preview-window=border-bold
    --scrollbar='▐'
    --separator='━'
    --prompt='❯ '
    --pointer='❯'
EOD
)

export FZF_DEFAULT_OPTS

export RIPGREP_CONFIG_PATH="${HOME}/.config/ripgrep/config"


__envchain_namespaces() {
    _values 'namespace' "${(uonzf)$(envchain --list)}"
}

_envchain() {
    _arguments -S -A '-*' \
        ':namespace:__envchain_namespaces' \
        ':command: _command_names -e' \
        '*::arguments:_precommand'
}

compdef _envchain envchain

# Function to find .venv directory in current or parent directories
find_venv_dir() {
    local current_dir="$PWD"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.venv" ]]; then
            echo "$current_dir/.venv"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

# Function to check if current directory is inside a virtualenv
is_inside_venv() {
    local venv_path="$1"
    local current_path="$PWD"

    # Strip '/bin/activate' if it exists in the path
    venv_base_path="${venv_path%/bin/activate}"

    # Check if current path starts with venv path
    [[ "$current_path" == "$venv_base_path"* ]]
}

# Variable to track which virtualenv we activated
typeset -g AUTO_ACTIVATED_VENV=""

# The chpwd hook function
auto_venv_handler() {
    # Find .venv directory
    local venv_path=$(find_venv_dir)

    # If we found a .venv directory
    if [[ -n "$venv_path" ]]; then
        # Only activate if there's no active virtualenv or if the active one
        # was activated by us
        if [[ -z "$VIRTUAL_ENV" ]] || [[ -n "$AUTO_ACTIVATED_VENV" ]]; then
            deactivate 2>/dev/null
            source "$venv_path/bin/activate"
            AUTO_ACTIVATED_VENV="$venv_path"
        fi
    # If we didn't find a .venv directory
    else
        # Only deactivate if:
        # 1. We were the ones who activated it AND
        # 2. We're not inside the virtualenv directory tree
        if [[ -n "$AUTO_ACTIVATED_VENV" ]] && ! is_inside_venv "$VIRTUAL_ENV"; then
            deactivate
            AUTO_ACTIVATED_VENV=""
        fi
    fi
}

# Register the hook
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_venv_handler

# Run once for the current directory when the shell starts
auto_venv_handler

export PATH="${HOME}/bin:$PATH"

source ~/.aliases

if [[ -f "${HOME}/.zshrc.local" ]] ; then
    source "${HOME}/.zshrc.local"
fi
