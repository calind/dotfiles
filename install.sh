#!/bin/sh
set -e

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

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
