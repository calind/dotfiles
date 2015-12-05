# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=10000

bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/calin/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# run scripts from dotfiles/commonrc.d
if [ -d $HOME/.dotfiles/commonrc.d ] ; then
    for part in $HOME/.dotfiles/commonrc.d/* ; do
        if [ -x "$part" ] ; then
            source $part
        fi
    done
fi

# run scripts from dotfiles/zshrc.d
if [ -d $HOME/.dotfiles/zshrc.d ] ; then
    for part in $HOME/.dotfiles/zshrc.d/* ; do
        if [ -x "$part" ] ; then
            source $part
        fi
    done
fi
