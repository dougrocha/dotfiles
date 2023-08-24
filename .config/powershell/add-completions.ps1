Write-Output '> Setting up Completions...'

$completionsPath = "$HOME\dotfiles\.config\powershell\completions"
function Add-Contents-To-Completions ($name, $output) {
    $output_path = "$completionsPath\$name.ps1"

    New-Item -Force -Path $output_path
    
    $output | Add-Content $output_path

    Write-Output "> Created powershell completions for '$name'. Append to: $completionsPath"
}

Write-Output '> Making powershell completions available...'

New-Item -Force -ItemType Directory $completionsPath

Add-Contents-To-Completions "rustup" (rustup completions powershell) 
Add-Contents-To-Completions "fnm" (fnm completions --shell=power-shell)

Write-Output '> Done making powershell completions available.

Notes:
-----
Usage: Add these two lines to your microsoft profile
Import-Module "$HOME\dotfiles\.config\powershell\completions\fnm.ps1"
Import-Module "$HOME\dotfiles\.config\powershell\completions\rustup.ps1"
'