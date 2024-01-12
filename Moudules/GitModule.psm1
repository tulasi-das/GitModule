

function Give-Options {
  #give user a grid view to choose his input
    $openVsCode = "Open VS code"
    $CloneGitRepo = "Clone Git Repo"
    $createNewbranch = "Create new branch"
    $gitCommit = "Commit to git"
    $options = $openVsCode, $CloneGitRepo, $createNewbranch, $gitCommit
    $selectedOption = $options | Out-GridView -Title "Select an Option" -PassThru

    Write-Host $selectedOption

    if($selectedOption -eq "Open VS code"){
        $repoName = Read-Host "Give me the repo Name which you want ot open in vs code"
        Open-VSCode -repoName $repoName
    }
    if($selectedOption -eq "Clone Git Repo"){
      $userIn = Read-host "Which repo you would like to clone"
      Clone-GitRepo -repoName $userIn
    }

    if($selectedOption -eq "Create new branch"){

        $userInput = Read-Host "Give me the repo Name and the branch that you wanted to create(Give me a string seperated by comma)"
        $inputArray = $userInput -split ','
        $inputArray = $inputArray.Trim()
        $repoName = $inputArray[0]
        $branchName = $inputArray[1]
        Create-NewBranch -repoName $repoName -branchName $branchName
    }
    if($selectedOption -eq "Commit to git"){
        $repoName = Read-Host "Give me the repo Name of changes which you want to commit"
        Git-Commit -repoName $repoName
    }

}


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
    write-host $cloneMsg
    #setting back the default location from where the script is execute
    Set-Location $defaultLocation

}

#function to open a repo in the vs code
function Open-VSCode{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $filePath = "C:\GitAutomation\$repoName"
    code $filePath
    
}
function Set-RootFolerLocaiton{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $fodlerPath = "C:\GitAutomation\$repoName"
    Set-Location $fodlerPath
}

# do commit to the git in remote
function Git-Commit{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $defaultLocation = Get-Location
    $fodlerPath = "C:\GitAutomation\$repoName"
    Set-Location $fodlerPath

    $changesExist = Read-Host "are there any uncommited changes exist: (yes/no)"
    if ($changesExist -eq "yes"){
        write-host "Commiting changes to the remote repo"
        $commitMessage = Read-Host "Enter a commit message "
        #stage all the changes 
        $stageOutput = git add . 2>&1
        $commitOutput = git commit -m $commitMessage 2>&1
        $pushOutput = git push -f 2>&1
    } else{
        Write-Host "Please make your changes and comeback"
    }
    Set-Location $defaultLocation
}

#function for stashing changes and checking out to new branch/create new branch

function Create-NewBranch{
    param(
        [Parameter(Mandatory)]
        $branchName, $repoName
    )
    Set-RootFolerLocaiton -repoName $repoName

    $changesOnMain = Read-Host "Are thre any changes in the branch(yes/no)"
    if($changesOnMain -eq "yes")
    {
        $stashMsg = Read-Host "you hvae some uncommited changes on the branch, give me a stash message"
        $stashOutputMsg = git stash save -m $stashMsg 2>&1
    }
    $gitBranchOutput = git checkout -b feature main 2>&1

    if($changesOnMain -eq "yes")
    {
        $stashOutputMsg = git stash apply stash@{0}
        $commitInput = Read-Host "Would you like to commit your changes(yes/no)"
        if($commitInput -eq "yes"){
            Git-Commit -repoName $repoName
        }
    }
    Open-VSCode -repoName $repoName

}