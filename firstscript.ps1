Import-Module .\GitModule.psm1

# Specify the name of the module you want to check
$moduleName = "posh-git"

# Check if the module is installed
if (Get-Module -Name $moduleName -ListAvailable) {
    Write-Host "$moduleName is already installed."
}
else {
    # Install the module if it's not installed
    Install-Module -Name $moduleName -Force
    Write-Host "$moduleName has been installed."
}
