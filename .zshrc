# zmodload zsh/zprof

autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Set locales on MacOS
if type defaults &>/dev/null; then
    LANG="$(defaults read -g AppleLocale)"
    export LANG="${LANG/en_RO/en_US}.UTF-8"
    export LC_COLLATE=C
    export LC_CTYPE="${LANG}"
fi

export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000
setopt autocd
unsetopt beep

bindkey '\e[H'  beginning-of-line
bindkey '\e[F'  end-of-line
bindkey '\e[3~' delete-char

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


# set homebrew environment
if [ -z "${HOMEBREW_PREFIX}" ] && [ -x "/usr/local/bin/brew" ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -z "${HOMEBREW_PREFIX}" ] && [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] ; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if type brew &>/dev/null; then
    FPATH="${HOMEBREW_PREFIX}/share/zsh-completions:$FPATH"
fi

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
        host_prompt="%K{${colors[bg_1]}}%F{${colors[dim_0]}}%n@%m%f%k "
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

export EDITOR=/usr/local/bin/nvim

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

source ~/.aliases
