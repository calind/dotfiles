# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=50000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# setup XDG Base Directory layout
if [ -z "$HOME" ] ; then
    echo "\$HOME not set. This might cause lots of errors" >&2
else
    if [ -z "$XDG_CONFIG_HOME" ] ; then
        XDG_CONFIG_HOME="$HOME/.config"
    fi
    if [ -z "$XDG_CACHE_HOME" ] ; then
        XDG_CACHE_HOME="$HOME/.cache"
    fi
    if [ -z "$XDG_DATA_HOME" ] ; then
        XDG_DATA_HOME="$HOME/.local/share"
    fi
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Uncomment for bashrc tracing
# TRACE=1

# make gdate compatible across Linux/MacOS
if ! hash gdate > /dev/null 2>&1 ; then
    if [ "$(uname -s)" = "Darwin" ] ; then
        alias gdate=true
        if [ -n "$TRACE" ] ; then
            echo "You must install homebrewed coreutils" >&2
        fi
    else
        alias gdate=date
    fi
fi

if [ -f "/etc/bash_completion" ] && ! shopt -oq posix; then
    START=$(gdate +%s.%N)
    source "/etc/bash_completion"
    END=$(gdate +%s.%N)
    DIFF=$( echo "scale=3; (${END} - ${START})*1000/1" | bc )
    test -n "$TRACE" && echo "source /etc/bash_completion ${DIFF}"
fi

if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    START=$(gdate +%s.%N)
    export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
    source "/usr/local/etc/profile.d/bash_completion.sh"
    END=$(gdate +%s.%N)
    DIFF=$( echo "scale=3; (${END} - ${START})*1000/1" | bc )
    test -n "$TRACE" && echo "source /usr/local/etc/profile.d/bash_completion.sh ${DIFF}"
fi

# run scripts from dotfiles/bashrc.d
if [ -d "$HOME/.bashrc.d" ] ; then
    for part in $HOME/.bashrc.d/* ; do
        if [ -x "$part" ] ; then
            START=$(gdate +%s.%N)
            source "$part"
            END=$(gdate +%s.%N)
            DIFF=$( echo "scale=3; (${END} - ${START})*1000/1" | bc )
            test -n "$TRACE" && echo "source $part ${DIFF}"
        fi
    done
fi

if [ -f "$HOME/.aliases" ]; then
    START=$(gdate +%s.%N)
    source "$HOME/.aliases"
    END=$(gdate +%s.%N)
    DIFF=$( echo "scale=3; (${END} - ${START})*1000/1" | bc )
    test -n "$TRACE" && echo "source $HOME/.aliases ${DIFF}"
fi
