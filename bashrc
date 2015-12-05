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


if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f "$(which brew)" ] && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        . "$(brew --prefix)/etc/bash_completion"
fi

# run scripts from dotfiles/commonrc.d
if [ -d $HOME/.dotfiles/commonrc.d ] ; then
    for part in $HOME/.dotfiles/commonrc.d/* ; do
        if [ -x "$part" ] ; then
            source $part
        fi
    done
fi

# run scripts from dotfiles/bashrc.d
if [ -d $HOME/.dotfiles/bashrc.d ] ; then
    for part in $HOME/.dotfiles/bashrc.d/* ; do
        if [ -x "$part" ] ; then
            source $part
        fi
    done
fi
