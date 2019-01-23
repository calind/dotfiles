#!/bin/bash

function config {
   /usr/bin/git --git-dir="$HOME/.dotfiles.git/" --work-tree="$HOME" "$@"
}

git clone --bare git@github.com:calind/dotfiles.git "$HOME/.dotfiles.git" || exit 1

if [ ! -d "$HOME/.config-backup" ] ; then
    mkdir -p "$HOME/.config-backup"
fi

if config checkout 2> /dev/null ; then
    echo "Checked out config."
else
    echo "Backing up pre-existing dot files."
    for path in $(config checkout 2>&1 | egrep '^\s+' | awk '{print $1}') ; do
        echo "Backing up $path"
        if [ ! -d "$(dirname "$HOME/.config-backup/$path")" ] ; then
            mkdir -p "$(dirname "$HOME/.config-backup/$path")"
        fi
        mv "$path" "$HOME/.config-backup/$path"
   done
fi

config checkout ; config submodule update --init --recursive
