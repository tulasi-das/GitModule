# importing the root module 
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Modules\GitModule.psm1')

# Specify the name of the module you want to check
$moduleName = "posh-git"

# Check if the module is installed
if (Get-Module -Name $moduleName -ListAvailable) {
    Write-Host "$moduleName is already installed." -ForegroundColor Green
}
else {
    # Install the module if it's not installed
    Install-Module -Name $moduleName -Force
    Write-Host "$moduleName has been installed." -ForegroundColor Green
}

#setting up the core editor to VS Code, this important because, when we are doing rebase we need to open interactive mode in VS Code
$coreEditor = git config --get core.editor 
if(-Not($coreEditor -eq "code --wait"))
{
    git config --global core.editor "code --wait"
}

Install-DependenciesAndConfigs
Give-Options