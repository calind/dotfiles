# zmodload zsh/zprof

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
bindkey "\e[1;3D" backward-word # ⌥←
bindkey "\e[1;3C" forward-word # ⌥→

# set homebrew environment
if type brew &>/dev/null; then
    eval "$(brew shellenv)"
    FPATH="${HOMEBREW_PREFIX}/share/zsh-completions:$FPATH"
fi

# Load version control information
autoload -Uz vcs_info

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

precmd() {
    vcs_info

    PS1="%F{3}λ%f %~${vcs_info_msg_0_} ❯ "
    PS2="  ❯ "
}

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

if [[ -d "${HOME}/.rd/bin" ]]; then
    export PATH="${HOME}/.rd/bin:$PATH"
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

autoload -Uz compinit
compinit

source ~/.aliases
