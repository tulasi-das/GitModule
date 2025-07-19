# importing the root module 
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Modules\GitModule.psm1')
Install-DependenciesAndConfigs
Give-Options