# Util Functions {{{
#
# Manage $env:Path
function Set-EnvPath {
    param (
        [string]$AddPath,
        [string]$RemovePath
    )

    $regexPaths = @()
    if ($PSBoundParameters.Keys -contains 'AddPath'){
        $regexPaths += [regex]::Escape($AddPath)
    }

    if ($PSBoundParameters.Keys -contains 'RemovePath'){
        $regexPaths += [regex]::Escape($RemovePath)
    }

    $arrPath = $env:Path -split ';'
    foreach ($path in $regexPaths) {
        $arrPath = $arrPath | Where-Object {$_ -notMatch "^$path\\?"}
    }

    $env:Path = ($arrPath + $addPath) -join ';'
}

###############################################################################

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

$PSReadLineOptions = @{
    EditMode = "Vi"
    ViModeIndicator = "Script"
    ViModeChangeHandler = $Function:OnViModeChange
    HistoryNoDuplicates = $true
    #HistorySearchCursorMovesToEnd = $true
    Colors = @{
        "Command" = "#8181f7"
    }
}
Set-PSReadLineOption @PSReadLineOptions

# An oh-my-zsh copypath like function
# Copy current path to clipboard
function Copy-Path {
    (pwd).Path | clip
}

# An oh-my-zsh copyfile like function
# Copy the file contents to clipboard
function Copy-File {
    param (
        [string]$File
    )

    cat $File | clip
}

# An oh-my-zsh magic-enter like plugin
Set-PSReadLineKeyHandler -Chord Enter -Description "An oh-my-zsh magic-enter like plugin" -ScriptBlock {
    # Copy current command-line input
    $currentInput = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $currentInput, [ref] $null)

    # If command line is empty...
    if( $currentInput.Length -eq 0 ) {
        # Enter new console command
        if (Test-Path ".git") {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, 'git status -u')
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, 'ls -Exclude ".*"')
        }
    }

    # Simulate pressing Enter
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# An oh-my-zsh copybuffer like plugin
Set-PSReadLineKeyHandler -Chord Ctrl+o -Description "Copy current command input to clipboard" -ScriptBlock {
    # Copy current command-line input
    $currentInput = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $currentInput, [ref] $null)

    # If command line is NOT empty...
    if( $currentInput.Length -gt 0 ) {
        echo $currentInput | clip
    }
}

Set-Alias -Name:"which" -Value:"Get-Command" -Option:"AllScope"

# This require both fzf and ripgrep installed
$env:FZF_DEFAULT_COMMAND = 'rg --files'

# Set vifm home if not set
if (-not $env:VIFM) { $env:VIFM = "$HOME\.config\vifm" }

Set-EnvPath -AddPath "$HOME\bin"
