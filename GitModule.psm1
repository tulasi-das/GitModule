# fucntion to clone the git repository
function Clone-GitRepo{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $defaultLocation = Get-Location

    $repoLink = "https://github.com/tulasi-das/$repoName.git"

    # Creating a folder to store the repo

    $FolderName = Read-Host 'Pleaes give a name to the root folder'

    $FolderPath = "C:\$FolderName"

    if(-Not (Test-Path $FolderPath)){
        New-Item -name FolderName -ItemType Directory -Path $FolderPath
        write-hsot "Root folder $FolderName is created" -ForegroundColor Green
    }else {
        Write-Host "The root folder already exists with the name $FolderName" -ForegroundColor Green
    }
    # set location to the creted directory
    Set-Location $FolderPath 
    $cloneMsg = git clone $repoLink 2>&1
    #setting back the default location from where the script is execute
    Set-Location $defaultLocation

}

#function to open a repo in the vs code

function Open-VSCode{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $filePath = "C:\$repoName"
    code $filePath
    
}

# do commit to the git in remote

function Git-Commit{
    #chane this to defualt once we commit from here TODO
    param(
        [Parameter(Mandatory)]
        $fodlerPath
    )
    Set-Location $fodlerPath
    $commitMessage = Read-Host "Enter a commit message "
    #stage all the changes 

    $stageOutput = git add . 2>&1
    $commitOutput = git commit -m $commitMessage 2>&1
    $pushOutput = git push -f 2>&1
}