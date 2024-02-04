# global variables 
$Global:rootFolderLocation = " "
$Global:rootFolder = " "

function Install-DependenciesAndConfigs{
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
    # Importing the GITAPI module
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'GitModuleAPI.psm1')
}
# this function isu used to give user a grid view to choose his input
function Give-Options {
    $createRoootFolder = "Create Root Folder"
    $openVsCode = "Open VS code"
    $CloneGitRepo = "Clone Git Repo"
    $createNewbranch = "Create new branch"
    $gitCommit = "Commit to git"
    $showlog = "Show log"
    $stashChanges = "Stash Changes"
    $dropCommit = "Drop Commit"
    $editCommit = "edit commit"
    $initgitRepo = "Initialise new repository"
    $rebaseBranch = "Rabase Branch"
    $squaseCommit = "Squace Commits"
    $CreteRepoUsingAPI = "Create repo using API"
    $ListAllTheReposUsingAPI = "List all the repos"
    $ListAllTheContributorsOfARepo = "List all the contributors of a repo"
    $setPATasEnvVar = "Set PAT as environment varible"
    $installDependenciesAndCongigs = "Install dependencies and configs"
    $options = $openVsCode, $CloneGitRepo, $createNewbranch, $gitCommit, $showlog, $stashChanges, $dropCommit, $editCommit, $initgitRepo, $rebaseBranch, $squaseCommit, $CreteRepoUsingAPI, $ListAllTheReposUsingAPI, $ListAllTheContributorsOfARepo, $createRoootFolder, $setPATasEnvVar, $installDependenciesAndCongigs
    $selectedOption = $options | Out-GridView -Title "Select an Option" -PassThru

    Write-Host $selectedOption -ForegroundColor Green
    
    if($selectedOption -eq "Create Root Folder"){
        $rootFolder = Read-Host "Give me the folder Name, this can be considered as Root Folder" -ForegroundColor Green
        Create-RootFolder -rootFolder $rootFolder
    }

    if($selectedOption -eq "Open VS code"){
        $repoName = Read-Host "Give me the repo Name which you want ot open in vs code" -ForegroundColor Green
        Open-VSCode -repoName $repoName
    }

    if($selectedOption -eq "Clone Git Repo"){
      $userIn = Read-host "Which repo you would like to clone" -ForegroundColor Green
      Clone-GitRepo -repoName $userIn
    }

    if($selectedOption -eq "Create new branch"){

        $userInput = Read-Host "Give me the repo Name and the branch that you wanted to create(Give me a string seperated by comma)" -ForegroundColor Green
        $inputArray = $userInput -split ','
        $inputArray = $inputArray.Trim()
        $repoName = $inputArray[0]
        $branchName = $inputArray[1]
        Create-NewBranch -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "Commit to git"){
        $repoName = Read-Host "Give me the repo Name of changes which you want to commit" -ForegroundColor Green
        Git-Commit -repoName $repoName
    }

    if($selectedOption -eq "Stash Changes")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to stash  changes" -ForegroundColor Green
        Git-Stash -repoName $repoName
    }

    if($selectedOption -eq "Drop Commit")
    {
        $repoName = Read-Host "Give me the repo Name of which you drop commits" -ForegroundColor Green
        $branchName = Read-host "Give me the branch name on which you want to drop the commit" -ForegroundColor Green
        Drop-Commit -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "edit commit")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to edit commit" -ForegroundColor Green
        $branchName = Read-host "Give me the commit ID" -ForegroundColor Green
        Edit-Commit -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "Initialise new repository")
    {
        $repoName = Read-Host "Give me the repo Name of which you want Initialise" -ForegroundColor Green
        Init-GITRepo -repoName $repoName
        
    }

    if($selectedOption -eq "Rabase Branch")
    {
        $repoName = Read-Host "Give me the repo Name of which you want Rebase" -ForegroundColor Green
        $rebaseBranch = Read-Host "Give me a rebase branch" -ForegroundColor Green
        $currentBranch = Read-host "Give me your current branch" -ForegroundColor Green
        Git-RebaseBranch -repoName $repoName -rebaseBranch $rebaseBranch -currentBranch $currentBranch
      
    }

    if($selectedOption -eq "Squace Commits")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to squace commits" -ForegroundColor Green
        $branchName = Read-host "Give me the branch name " -ForegroundColor Green
        Squase-Commit -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "Show log")
    {
        $repoName = Read-host "Give me the repo name of which you want show logs" -ForegroundColor Green
        $branchName = Read-host "Give me the branch name of which you want to show logs"  -ForegroundColor Green
        Show-log -repoName $repoName -branchName $branchName
    }
    if($selectedOption -eq "Create repo using API")
    {
        Create-GITRepoUsingAPI
    }
    if($selectedOption -eq "Create repo using API")
    {
        Get-RepoDetails
    }
    if($selectedOption -eq "List all the contributors of a repo")
    {
        List-AllTheContributors
    }
    if($selectedOption -eq "Set PAT as environment varible")
    {
        Set-TokenAsEnvVariable   
    }
    if($selectedOption -eq "Install dependencies and configs")
    {
        Install-DependenciesAndConfigs
    }
}

#function for creating root folder
function Create-RootFolder{
    param(
        [parameter(Mandatory)]
        $rootFolder
    )
    write-host "Creating Root Folder" -ForegroundColor Green

    $FolderPath = "C:\$rootFolder"

    if(-Not (Test-Path $FolderPath)){
        New-Item -name FolderName -ItemType Directory -Path $FolderPath
        Write-Host "Root folder $rootFolder is created" -ForegroundColor Green
    }else {
        Write-Host "The root folder already exists with the name $FolderName" -ForegroundColor Green
    }
    $Global:rootFolderLocation = $FolderPath
    $Global:rootFolder = $rootFolder
}
# fucntion to clone the git repository
function Clone-GitRepo{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $defaultLocation = Get-Location
    $userName = Read-Host "Please give me your user name"

    $repoLink = "https://github.com/$userName/$repoName.git"

    # Creating a folder to store the repo

    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder"
        $Global:rootFolder = Read-Host "Please give the Root Folder name"
    }

    $FolderPath = "C:\$Global:rootFolder"

    if(-Not (Test-Path $FolderPath)){
        New-Item -name FolderName -ItemType Directory -Path $FolderPath
        write-host "Root folder $FolderName is created" -ForegroundColor Green
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
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder"
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
    $filePath = "C:\$Global:rootFolder\$repoName"
    code $filePath
}
function Set-RootFolderLocation{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
    $fodlerPath = "C:\$Global:rootFolder\$repoName"
    Set-Location $fodlerPath
}

#create a new folder at a default location (Currently used for creating new git repos)
function Create-NewRepo{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
    $fodlerPath = "C:\$Global:rootFolder"
    if(-Not (Test-Path (Join-Path -Path $fodlerPath -ChildPath $repoName))){
        New-Item -Name $repoName -Path $fodlerPath -ItemType Directory
    }else{
        write-host "The repository with name $repoName already exist" -ForegroundColor Green
    }
    Set-Location $fodlerPath
}

# do commit to the git in remote
function Git-Commit{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $defaultLocation = Get-Location
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
    $fodlerPath = "C:\$Global:rootFolder\$repoName"
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
    Set-RootFolderLocation -repoName $repoName

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

#git stash
function Git-Stash{
    param(
        [Parameter(Mandatory)]
        $repoName
        )
    $stashMsg = Read-Host "Give me a stash message"
    $stashOutput = git stash save $stashMsg
}

#show the log to the user in grid view(Testing is done)
function Show-log{
    param(
        [parameter(Mandatory)]
        $repoName,
        [Parameter(Mandatory)]
        $branchName
    )
    $defaultLocation = Get-Location
    Set-RootFolderLocation -repoName $repoName
    $branch = git branch --show-current
    if(-Not ($branchName -eq $branch))
    {
        $gitChangeBrnachMsg = git checkout -$branchName
    }
    git log | Out-GridView -Title "Logs"
    Set-Location $defaultLocation
}

# Testing is done (But still need to check some more conditions)
function Squase-Commit{
    param(
        [Parameter(Mandatory)]
        $repoName,
        [Parameter(Mandatory)]
        $branchName
    )
    Set-RootFolderLocation -repoName $repoName
    $branch = git branch --show-current
    if(-Not ($branchName -eq $branch))
    {
        $gitChangeBrnachMsg = git checkout -$branchName
    }
    write-host "Choose a one commit before of which you want to Squace" -ForegroundColor Green
        $choosenCommit = git log | Out-GridView -Title "Choose the commits" -PassThru
        $commitArray1 = $choosenCommit.split(' ')
        $rebsaeCommitMsg = git rebase -i $commitArray1[1]
        write-host "Write Squace infront of the commit which you want to Squace, save and close the file(if in vim, go to command more and type :wq)" -ForegroundColor Green
        $rebaseMsg = git rebase --continue 2>&1
        $upstreamBranch = git push --set-upstream origin $branchName
        $pushChanges = git push -f
}

# to drop a commit (Testing is pending(Testing is done ))
function Drop-Commit{
    param(
        [parameter(Mandatory)]
        $branchName,
        [parameter(Mandatory)]
        $repoName
    )
    Set-RootFolderLocation -repoName $repoName
    $branch = git branch --show-current
    if(-Not ($branchName -eq $branch))
    {
        $gitChangeBrnachMsg = git checkout -$branchName
    }
    write-host "Please choose a commit"
    $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
    $commitArray1 = $choosenCommit.split(' ')
   
    #commit to remote repo 
    $inputBranch = Read-Host "Is your branch exist in the remote repo(yes/no)" -ForegroundColor Green
    if($inputBranch -eq "yes")
    {
        $newCommitMsg = Read-Host "Do you want to create a new commit(yes/no), this is recommended" -ForegroundColor Green
        if($newCommitMsg -eq "yes"){
            $gitrevertMsg = git revert $commitArray1[1]
            $pushOutput = git push -f 2>&1
        }else{
            write-host "Choose a one commit before of which you want to drop" -ForegroundColor Green
            $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
            $commitArray1 = $choosenCommit.split(' ')
            $rebsaeCommitMsg = git rebase -i $commitArray1[1]
            write-host "Write drop infront of the commit which you want to drop, save and close the file(if in vim, go to command more and type :wq)" -ForegroundColor Green
            $rebaseMsg = git rebase --continue 2>&1
            $forcePushCommit = git push -f
        }
    }else{
        write-host "Choose a one commit before of which you want to drop" -ForegroundColor Green
        $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
        $commitArray1 = $choosenCommit.split(' ')
        $rebsaeCommitMsg = git rebase -i $commitArray1[1]
        write-host "Write drop infront of the commit which you want to drop, save and close the file(if in vim, go to command more and type :wq)" -ForegroundColor Green
        $rebaseMsg = git rebase --continue 
        $pushBranchMsg = git push origin $branch 2>&1
    }
}

# to edit a commit (Testing is pending(Testing is done:))
function Edit-Commit{
    param(
        [parameter(Mandatory)]
        $repoName,
        [parameter(Mandatory)]
        $branchName
    )
    Set-RootFolderLocation -repoName $repoName
    $branch = git branch --show-current
    if(-Not ($branchName -eq $branch))
    {
        $gitChangeBrnachMsg = git checkout -$branchName
    }
    write-host "Plesae choose a commit" -ForegroundColor Yellow
    $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
    $commitArray1 = ($choosenCommit -split ' ')
    $editMsg = git reset --soft $commitArray1[1] 2>&1
    write-host "Please proceed with your changes" -ForegroundColor Green
}

#rebase branch (Testing is pending(TODO:))
function Git-RebaseBranch{
    param(
        [Parameter(Mandatory)]
        $rebaseBranch,
        [Parameter(Mandatory)]
        $currentBranch,
        [Parameter(Mandatory)]
        $repoName
    )
    $defaultLocation = Get-Location
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name" -ForegroundColor Green
    }
    $fodlerPath = "C:\$Global:rootFolder\$repoName"
    Set-Location $fodlerPath
    $branch = git branch
    $branchInVSCode = ($branch -split ' ')[1]
    if(-Not ($branchInVSCode -eq $currentBranch)){
        $chekcoutMsg = git checkout $currentBranch
    }
    $rebaseMsg = git rebase $rebaseBranch
    write-host "pushing it to remote" -ForegroundColor Green
    $pushMsg = git push -f
    Set-Location $defaultLocation
}

# create new git repo (testing is done, but still some more is required) (This imagines that the folder was not created and doing it by scratch)
function Init-GITRepo{
    param(
        [parameter(Mandatory)]
        $repoName
    )
    Create-NewRepo -repoName $repoName
    $gitInitMsg = git init
    write-host "To commit the changes from here to remote you need to have a remote repo, so please craete a remote repo with the same name as local repo" -ForegroundColor Green
    do{
        $remoteRepoMsg = Read-host "have you created your remote repo(yes/no)" -ForegroundColor Green
        if($remoteRepoMsg -eq "no"){
            write-host "Okay waiting till you create a remote repo" -ForegroundColor Green
        }
    }while($remoteRepoMsg -eq "no")

    if($remoteRepoMsg -eq "yes"){
        $aboutRepo = Read-host "what is this repo about, this will be shown in readme.md file" -ForegroundColor Green
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name" -ForegroundColor Green
    }
        $filePath = "C:\$Global:rootFolder\$repoName"
        New-Item -Path $filePath -ItemType File
        Add-Content -Path $filePath -Value $aboutRepo
        $stageOutput = git add . 2>&1
        $commitMessage = Read-Host "Give me a initial commit message" -ForegroundColor Green
        $commitOutput = git commit -m $commitMessage 2>&1
        $repoLink = "https://github.com/tulasi-das/$repoName.git"
        $addingToOrigin = git remote add origin $repoLink 2>&1
        $changeName = git branch -M main
        $upstreamMsg = git push --set-upstream origin main
        $pushBranch = git push -f
    }
}