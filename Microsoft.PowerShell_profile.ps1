# PowerShell Profile

# Configure PSReadLine for syntax highlighting
# Only highlight variables and parameters in green
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -Colors @{
        Variable = 'Green'   # Green for variables ($var)
        Parameter = 'Green'  # Green for parameters (-param)
    }
}

# Color mapping from .dircolors ANSI codes to PowerShell colors
$script:DirColors = @{
    # Directories (36 = cyan)
    'DIR' = 'Cyan'
    # Symbolic links (35 = magenta)
    'LINK' = 'Magenta'
    # Executables (01;31 = bright red)
    'EXEC' = 'Red'
    # Source/editable text (32 = green)
    'TEXT' = 'Green'
    # Multimedia (33 = yellow)
    'MEDIA' = 'Yellow'
    # Documents (31 = red)
    'DOC' = 'Red'
    # Archives (1;35 = bright magenta)
    'ARCHIVE' = 'Magenta'
    # Normal files (00 = default)
    'NORMAL' = 'White'
}

# Extension to category mapping based on .dircolors
$script:ExtensionColors = @{
    # Text/Source files (green)
    '.txt' = 'TEXT'; '.org' = 'TEXT'; '.md' = 'TEXT'; '.mkd' = 'TEXT'
    '.h' = 'TEXT'; '.c' = 'TEXT'; '.cc' = 'TEXT'; '.cpp' = 'TEXT'; '.cxx' = 'TEXT'
    '.objc' = 'TEXT'; '.sh' = 'TEXT'; '.csh' = 'TEXT'; '.zsh' = 'TEXT'; '.el' = 'TEXT'
    '.vim' = 'TEXT'; '.java' = 'TEXT'; '.pl' = 'TEXT'; '.pm' = 'TEXT'; '.py' = 'TEXT'
    '.rb' = 'TEXT'; '.hs' = 'TEXT'; '.php' = 'TEXT'; '.htm' = 'TEXT'; '.html' = 'TEXT'
    '.shtml' = 'TEXT'; '.erb' = 'TEXT'; '.haml' = 'TEXT'; '.xml' = 'TEXT'; '.rdf' = 'TEXT'
    '.css' = 'TEXT'; '.sass' = 'TEXT'; '.scss' = 'TEXT'; '.less' = 'TEXT'; '.js' = 'TEXT'
    '.coffee' = 'TEXT'; '.man' = 'TEXT'; '.0' = 'TEXT'; '.1' = 'TEXT'; '.2' = 'TEXT'
    '.3' = 'TEXT'; '.4' = 'TEXT'; '.5' = 'TEXT'; '.6' = 'TEXT'; '.7' = 'TEXT'
    '.8' = 'TEXT'; '.9' = 'TEXT'; '.l' = 'TEXT'; '.n' = 'TEXT'; '.p' = 'TEXT'
    '.pod' = 'TEXT'; '.tex' = 'TEXT'
    
    # Multimedia files (yellow)
    '.bmp' = 'MEDIA'; '.cgm' = 'MEDIA'; '.dl' = 'MEDIA'; '.dvi' = 'MEDIA'; '.emf' = 'MEDIA'
    '.eps' = 'MEDIA'; '.gif' = 'MEDIA'; '.jpeg' = 'MEDIA'; '.jpg' = 'MEDIA'
    '.mng' = 'MEDIA'; '.pbm' = 'MEDIA'; '.pcx' = 'MEDIA'; '.pdf' = 'MEDIA'; '.pgm' = 'MEDIA'
    '.png' = 'MEDIA'; '.ppm' = 'MEDIA'; '.pps' = 'MEDIA'; '.ppsx' = 'MEDIA'; '.ps' = 'MEDIA'
    '.svg' = 'MEDIA'; '.svgz' = 'MEDIA'; '.tga' = 'MEDIA'; '.tif' = 'MEDIA'; '.tiff' = 'MEDIA'
    '.xbm' = 'MEDIA'; '.xcf' = 'MEDIA'; '.xpm' = 'MEDIA'; '.xwd' = 'MEDIA'; '.yuv' = 'MEDIA'
    '.aac' = 'MEDIA'; '.au' = 'MEDIA'; '.flac' = 'MEDIA'; '.mid' = 'MEDIA'; '.midi' = 'MEDIA'
    '.mka' = 'MEDIA'; '.mp3' = 'MEDIA'; '.mpa' = 'MEDIA'; '.mpeg' = 'MEDIA'; '.mpg' = 'MEDIA'
    '.ogg' = 'MEDIA'; '.ra' = 'MEDIA'; '.wav' = 'MEDIA'
    '.anx' = 'MEDIA'; '.asf' = 'MEDIA'; '.avi' = 'MEDIA'; '.axv' = 'MEDIA'; '.flc' = 'MEDIA'
    '.fli' = 'MEDIA'; '.flv' = 'MEDIA'; '.gl' = 'MEDIA'; '.m2v' = 'MEDIA'; '.m4v' = 'MEDIA'
    '.mkv' = 'MEDIA'; '.mov' = 'MEDIA'; '.mp4' = 'MEDIA'; '.mp4v' = 'MEDIA'; '.nuv' = 'MEDIA'
    '.ogm' = 'MEDIA'; '.ogv' = 'MEDIA'; '.ogx' = 'MEDIA'; '.qt' = 'MEDIA'; '.rm' = 'MEDIA'
    '.rmvb' = 'MEDIA'; '.swf' = 'MEDIA'; '.vob' = 'MEDIA'; '.wmv' = 'MEDIA'
    
    # Document files (red)
    '.doc' = 'DOC'; '.docx' = 'DOC'; '.rtf' = 'DOC'; '.dot' = 'DOC'; '.dotx' = 'DOC'
    '.xls' = 'DOC'; '.xlsx' = 'DOC'; '.ppt' = 'DOC'; '.pptx' = 'DOC'; '.fla' = 'DOC'; '.psd' = 'DOC'
    
    # Archives (bright magenta)
    '.7z' = 'ARCHIVE'; '.apk' = 'ARCHIVE'; '.arj' = 'ARCHIVE'; '.bin' = 'ARCHIVE'; '.bz' = 'ARCHIVE'
    '.bz2' = 'ARCHIVE'; '.cab' = 'ARCHIVE'; '.deb' = 'ARCHIVE'; '.dmg' = 'ARCHIVE'; '.gem' = 'ARCHIVE'
    '.gz' = 'ARCHIVE'; '.iso' = 'ARCHIVE'; '.jar' = 'ARCHIVE'; '.msi' = 'ARCHIVE'; '.rar' = 'ARCHIVE'
    '.rpm' = 'ARCHIVE'; '.tar' = 'ARCHIVE'; '.tbz' = 'ARCHIVE'; '.tbz2' = 'ARCHIVE'; '.tgz' = 'ARCHIVE'
    '.tx' = 'ARCHIVE'; '.war' = 'ARCHIVE'; '.xpi' = 'ARCHIVE'; '.xz' = 'ARCHIVE'; '.z' = 'ARCHIVE'
    '.zip' = 'ARCHIVE'
    
    # Executables (bright red)
    '.cmd' = 'EXEC'; '.exe' = 'EXEC'; '.com' = 'EXEC'; '.bat' = 'EXEC'; '.reg' = 'EXEC'; '.app' = 'EXEC'
}

# Custom dir function with colors
# Remove the built-in alias so our function takes precedence
if (Test-Path alias:dir) {
    Remove-Item alias:dir -Force
}
if (Test-Path alias:ls) {
    Remove-Item alias:ls -Force
}

function dir {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Path
    )
    
    # Call Get-ChildItem with provided arguments
    $items = if ($Path) {
        Get-ChildItem $Path
    } else {
        Get-ChildItem
    }
    
    foreach ($item in $items) {
        $color = 'White'
        
        if ($item.PSIsContainer) {
            # Directory
            $color = $script:DirColors['DIR']
        }
        elseif ($item.LinkType) {
            # Symbolic link
            $color = $script:DirColors['LINK']
        }
        elseif ($item.Extension) {
            # Check extension mapping
            $ext = $item.Extension.ToLower()
            if ($script:ExtensionColors.ContainsKey($ext)) {
                $category = $script:ExtensionColors[$ext]
                $color = $script:DirColors[$category]
            }
        }
        
        # Check if file is executable (has execute permission on Unix or is .exe/.cmd/.bat on Windows)
        if (-not $item.PSIsContainer) {
            $isExecutable = $false
            # Check if we're on Windows
            $isWindowsOS = $PSVersionTable.PSVersion.Major -lt 6 -or 
                           ([System.Environment]::OSVersion.Platform -eq 'Win32NT')
            
            if ($isWindowsOS) {
                $isExecutable = $item.Extension -match '\.(exe|cmd|bat|com|reg|app)$'
            } else {
                # On Unix-like systems, check execute permission
                try {
                    $isExecutable = (($item.UnixMode -band 0x49) -ne 0)  # Check if any execute bit is set
                } catch {
                    $isExecutable = $false
                }
            }
            
            if ($isExecutable) {
                $color = $script:DirColors['EXEC']
            }
        }
        
        Write-Host $item.Name -ForegroundColor $color
    }
}

# Alias ls to dir for consistency
Set-Alias -Name ls -Value dir -Force

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
