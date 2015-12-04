#!/bin/sh
#set -e

declare -r DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"
declare -r LOCALRC="$HOME/.localrc"
cd $DOTFILES_DIR

read -p 'Your name [eg. Jon Doe]: ' name
read -p 'Your email [eg. jon.doe@example.com]: ' email

echo "Updating git submodules..."
git submodule update --init --recursive
if [ -d "$DOTFILES_DIR/vim/bundle/vimproc.vim" ] ; then
    (cd $DOTFILES_DIR/vim/bundle/vimproc.vim ; make)
fi

if [ ! -e "$LOCALRC" ] ; then
cat <<EOF > "$LOCALRC"
# vim: ft=sh:

export DOTFILES_DIR="$DOTFILES_DIR"
export NAME="$name"
export EMAIL="$email"

export LC_ALL=C
export LANG=en_US.UTF-8
export PATH="/usr/local/sbin:\$PATH"
EOF
fi

echo "Installing dotfiles into '$HOME'..."
set -o xtrace
git config --global include.path "$HOME/.dotfiles/gitconfig"
git config --global user.name "$name"
git config --global user.email "$email"

ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
ln -sfn "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
ln -sfn "$DOTFILES_DIR/profile" "$HOME/.profile"
ln -sfn "$DOTFILES_DIR/dircolors" "$HOME/.dircolors"
ln -sfn "$DOTFILES_DIR/aliases" "$HOME/.aliases"
ln -sfn "$DOTFILES_DIR/vim" "$HOME/.vim"
ln -sfn "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"

