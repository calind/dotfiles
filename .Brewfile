brew "coreutils"
brew "gnu-sed"
brew "gnu-tar"
brew "gzip"

brew "envchain"
brew "git"
brew "neovim"
brew "tree-sitter-cli"
brew "zsh"
brew "zsh-completions"

brew "composer"
brew "go@1.26"
brew "node@24" # latest LTS
brew "php@8.3" # latests supported WordPress version
brew "python@3.12"
brew "uv"

brew "bat"
brew "curl"
brew "fzf"
brew "htop"
brew "jq"
brew "ripgrep"
brew "sops"
brew "age"
brew "tree"
brew "wget"
brew "yq"
brew "watch"
brew "mtr"
brew "gron"
brew "awk"

brew "gh"

brew "helm"
brew "kube-ps1"
brew "kubectl"
brew "kubectx"
brew "kustomize"
brew "docker-completion"

brew "dockutil" if OS.mac?
cask "ghostty"

local_brewfile = File.expand_path("~/.Brewfile.local")
eval(File.read(local_brewfile), binding, local_brewfile) if File.exist?(local_brewfile)
