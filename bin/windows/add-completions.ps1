Write-Output '> Setting up Completions...'

$completionsPath = "$HOME\dotfiles\powershell\completions"
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
Add-Contents-To-Completions "starship" (starship completions powershell)

Write-Output '> Done making powershell completions available.'

Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value "Import-Module $HOME\dotfiles\powershell\completions\fnm.ps1"
Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value "Import-Module $HOME\dotfiles\powershell\completions\rustup.ps1"
Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value "Import-Module $HOME\dotfiles\powershell\completions\starship.ps1"