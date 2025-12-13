# PowerShell Profile

function Get-GitBranch {
    # Try to get git status, return empty if not in a git repository
    $status = git status --porcelain 2>$null
    if ($LASTEXITCODE -eq 0) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        
        # Check for changes (untracked or modified files)
        $hasChanges = $false
        $hasStaged = $false
        
        if ($status) {
            foreach ($line in $status) {
                # Untracked (??) or modified unstaged (.M) files
                if ($line -match '^\?\?|^.M') {
                    $hasChanges = $true
                }
                # Staged files (A, M, D, R, C in first column)
                if ($line -match '^[MADRC]') {
                    $hasStaged = $true
                }
            }
        }
        
        $statusStr = ""
        if ($hasChanges) {
            $statusStr += "*"
        }
        if ($hasStaged) {
            $statusStr += "+"
        }
        
        if ($branch) {
            return " ($branch)$statusStr"
        }
    }
    return ""
}

function prompt {
    # Get virtual environment name if active
    $venvPrompt = ""
    if ($env:VIRTUAL_ENV) {
        if ($env:VIRTUAL_ENV_PROMPT) {
            $venvPrompt = $env:VIRTUAL_ENV_PROMPT
        }
        else {
            $venvName = Split-Path -Leaf $env:VIRTUAL_ENV
            if ($venvName -eq ".venv") {
                $parentDir = Split-Path -Leaf (Split-Path -Parent $env:VIRTUAL_ENV)
                $venvPrompt = "($parentDir) "
            }
            else {
                $venvPrompt = "($venvName) "
            }
        }
    }
    
    # Get current directory (replace home path with ~)
    $currentPath = $PWD.Path.Replace($HOME, "~")
    
    # Get git branch and status
    $gitInfo = Get-GitBranch
    
    # Build prompt
    Write-Host "λ " -NoNewline -ForegroundColor Yellow
    Write-Host "$venvPrompt" -NoNewline
    Write-Host "$currentPath" -NoNewline
    Write-Host "$gitInfo" -NoNewline
    
    # Return the prompt character (❯ U+276F)
    return " ❯ "
}
