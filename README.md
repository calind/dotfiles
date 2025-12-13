# Installation

## Linux/macOS

```bash
curl -Lks https://raw.githubusercontent.com/calind/dotfiles/main/script/bootstrap | /bin/bash
```

## Windows (PowerShell)

1. Clone the repository:
```powershell
git clone https://github.com/calind/dotfiles.git "$HOME\dotfiles"
```

2. Create a symbolic link to the PowerShell profile:
```powershell
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$HOME\dotfiles\Microsoft.PowerShell_profile.ps1" -Force
```

# Console font

[Source Code Pro, nerd-font](https://github.com/ryanoasis/nerd-fonts/releases)
