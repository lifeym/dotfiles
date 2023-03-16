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
    # Do NOT use "clip" which produces unwanted crlf at the end
    (pwd).Path | Set-Clipboard
}

# An oh-my-zsh copyfile like function
# Copy the file contents to clipboard
function Copy-File {
    param (
        [string]$File
    )

    # Do NOT use "clip" which produces unwanted crlf at the end
    cat $File | Set-Clipboard
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
        $currentInput | Set-Clipboard
    }
}

Set-Alias -Name:"which" -Value:"Get-Command" -Option:"AllScope"

# Useful cd.. functions
function cdup {Set-Location -Path ..}
function cdup2 {Set-Location -Path ../..}
function cdup3 {Set-Location -Path ../../..}
function cdup4 {Set-Location -Path ../../../..}
function cdup5 {Set-Location -Path ../../../../..}
function cdup6 {Set-Location -Path ../../../../../..}
function cdup7 {Set-Location -Path ../../../../../../..}
function cdup8 {Set-Location -Path ../../../../../../../..}
Set-Alias -Name:"cd.." -Value:"cdup" -Option:"AllScope"
Set-Alias -Name:"cd..." -Value:"cdup2" -Option:"AllScope"
Set-Alias -Name:"cd...." -Value:"cdup3" -Option:"AllScope"
Set-Alias -Name:"cd....." -Value:"cdup4" -Option:"AllScope"
Set-Alias -Name:"cd......" -Value:"cdup5" -Option:"AllScope"
Set-Alias -Name:"cd......." -Value:"cdup6" -Option:"AllScope"
Set-Alias -Name:"cd........" -Value:"cdup7" -Option:"AllScope"
Set-Alias -Name:"cd........." -Value:"cdup8" -Option:"AllScope"

function ll() {
    ls -Exclude ".*"
}

# This require both fzf and ripgrep installed
$env:FZF_DEFAULT_COMMAND = 'rg --files'

# Set vifm home if not set
if (-not $env:VIFM) { $env:VIFM = "$HOME\.config\vifm" }

Set-EnvPath -AddPath "$HOME\bin"
