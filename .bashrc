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
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
