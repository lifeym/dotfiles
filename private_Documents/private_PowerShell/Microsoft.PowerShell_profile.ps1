# Util Functions {{{
#
# Manage $env:Path
Function Set-EnvPath {
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
Set-Alias -Name:"which" -Value:"Get-Command" -Option:"AllScope"

# This require both fzf and ripgrep installed
$env:FZF_DEFAULT_COMMAND = 'rg --files'

# Set vifm home if not set
if (-not $env:VIFM) { $env:VIFM = "$HOME\.config\vifm" }

Set-EnvPath -AddPath "$HOME\bin"
