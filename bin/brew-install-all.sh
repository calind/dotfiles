#!/bin/bash
set -e
set -o pipefail
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

set -x
brew install vim
brew install coreutils
brew install bash
brew install bash-completion
brew install git
brew install hub
brew install envchain
brew install htop
brew install tree
brew install kubernetes-cli
brew install kubernetes-helm

brew install goenv
brew install pyenv
brew install nvm

brew tap homebrew/cask-versions

brew cask install iterm2
brew cask install firefox-beta
brew cask install docker-edge
brew cask install slack
brew cask install front
brew cask install gpg-suite
brew cask install gitter
brew cask install dnscrypt
brew cask install google-cloud-sdk
