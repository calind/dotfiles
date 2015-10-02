#!/bin/sh
#set -e

DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"
cd $DOTFILES_DIR

echo "Updating git submodules..."
git submodule update --init --recursive

echo "Configuring git"
git config --global core.excludesfile $DOTFILES_DIR/git/gitignore

echo "Compiling vimproc"
(cd $DOTFILES_DIR/vim/bundle/vimproc.vim ; make)

echo "Installing dotfiles into '$HOME'..."

ln -sf "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/bash/profile" "$HOME/.profile"
ln -sf "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"

if [ ! -e "$DOTFILES_DIR/bash/exports.local" ] ; then
    touch "$DOTFILES_DIR/bash/exports.local"
    chmod +x "$DOTFILES_DIR/bash/exports.local"
fi

local_settings="$HOME/.settings"
if [ ! -e "$local_settings" ] ; then
    touch "$local_settings"
    chmod +x "$local_settings"
fi

cat <<EOF > "$local_settings"
export DOTFILES_DIR=$DOTFILES_DIR
EOF
