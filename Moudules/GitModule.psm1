

function Give-Options {
  #give user a grid view to choose his input
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
    $options = $openVsCode, $CloneGitRepo, $createNewbranch, $gitCommit, $showlog, $stashChanges, $dropCommit, $editCommit, $initgitRepo, $rebaseBranch, $squaseCommit
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

    if($selectedOption -eq "Stash Changes")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to stash  changes"
        Git-Stash -repoName $repoName
    }
    if($selectedOption -eq "Drop Commit")
    {
        $repoName = Read-Host "Give me the repo Name of which you drop commits"
        $commitID = Read-Host "Give me the commit ID" 
        Drop-Commit -firstCommit $commitID -repoName $repoName 
    }
    if($selectedOption -eq "edit commit")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to edit commit"
        $commitID = Read-host "Give me the commit ID"
        Edit-Commit -repoName $repoName -commitId $commitID
    }
    if($selectedOption -eq "Initialise new repository")
    {
        $repoName = Read-Host "Give me the repo Name of which you want Initialise"
        Init-GITRepo -repoName $repoName
        
    }
    if($selectedOption -eq "Rabase Branch")
    {
        $repoName = Read-Host "Give me the repo Name of which you want Rebase"
        $rebaseBranch = Read-Host "Give me a rebase branch"
        $currentBranch = Read-host "Give me your "
        Git-RebaseBranch -repoName $repoName -rebaseBranch $rebaseBranch -currentBranch $currentBranch
      
    }
    if($selectedOption -eq "Squace Commits")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to squace commits"
        $firstCommitId = Read-host "Give me first commit ID"
        $secondCommitID = Read-host "Give me second commit ID"
        Squase-Commit -firstCommit $firstCommitId -secondCommit $secondCommitID -executingFromPowershell "yes" -repoName $repoName
        
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

#create a new folder at a default location (Currently used for creating new git repos)
function Create-NewRepo{
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    $fodlerPath = "C:\GitAutomation\$repoName"
    if(-Not (Test-Path $fodlerPath)){
        New-Item -Name $repoName -Path $fodlerPath -ItemType Directory
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

#git stash
function Git-Stash{
    param(
        [Parameter(Mandatory)]
        $repoName
        )
    $stashMsg = Read-Host "Give me a stash message"
    $stashOutput = git stash save $stashMsg
}

#show the log to the user in grid view
function Show-log{
    param(
        [parameter(Mandatory)]
        $repoName,
        $chooseCommit
    )
    $defaultLocation = Get-Location
    Set-RootFolerLocaiton -repoName $repoName
   
    if($chooseCommit -eq "yes"){
        $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
        $commitArray1 = ($choosenCommit[0] -split ' ')[1]
        $commitArray2 = ($choosenCommit[1] -split ' ')[1]
        $firstCommit = $commitArray1
        $secondCommit = $commitArray2
    }else{
        git log | Out-GridView
    }
    Set-Location $defaultLocation
    Squase-Commit -firstCommit $firstCommit -secondCommit $secondCommit
}

# TODO (Testing is pending) 
function Squase-Commit{
    param(
        [parameter(Mandatory)]
        $firstCommit,
        [parameter(Mandatory)]
        $secondCommit,
        $executingFromPowershell,
        $repoName
    )
    if($executingFromPowershell -eq "yes"){
        Set-RootFolerLocaiton -repoName $repoName
    }
    $squashMsg = git reset --soft $secondCommit
    write-host $squashMsg
    Git-Commit -repoName $repoName
    Write-host "Opening ... and edit your commit message"
}

# to drop a commit (Testing is pending(TODO:))
function Drop-Commit{
    param(
        [parameter(Mandatory)]
        $firstCommit,
        [parameter(Mandatory)]
        $repoName
    )
    Set-RootFolerLocaiton -repoName $repoName

    write-host "Please choose a commit"
    $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
    $commitArray1 = $choosenCommit.split(' ')
    $branch = git branch
    $branchInVSCode = ($branch -split ' ')[1]
    #commit to remote repo 
    $inputBranch = Read-Host "Is your branch exist in the remote repo(yes/no)"
    if($inputBranch -eq "yes")
    {
        $newCommitMsg = Read-Host "Do you want to create a new commit(yes/no), this is recommended"
        if($newCommitMsg -eq "yes"){
            $gitrevertMsg = git revert $commitArray1[1]
            # $commitMessge = Read-host "Give me a commit message"
            # $commitOutput = git commit -m $commitMessage 2>&1
            $pushOutput = git push -f 2>&1
        }else{
            write-host "Choose a one commit before of which you want to drop"
            $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
            $commitArray1 = $choosenCommit.split(' ')
            $rebsaeCommitMsg = git rebase -i $commitArray1[1]
            write-host "Write drop infront of the commit which you want to drop, save and close the file(if in vim, go to command more and type :wq)"
            $rebaseMsg = git rebase --continue 2>&1
            $forcePushCommit = git push -f
        }
    }else{
        $pushBranchMsg = git push $repoName ${$branchInVSCode:$branchInVSCode}
    }
}

# to edit a commit (Testing is pending(TODO:))
function Edit-Commit{
    param(
        [parameter(Mandatory)]
        $repoName,
        [parameter(Mandatory)]
        $commitId
    )
    write-host "Plesae choose a commit"
    $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
    $commitArray1 = ($choosenCommit[0] -split ' ')[1]
    $editMsg = git reset --soft $commitArray1 2>&1
    write-host "Please proceed with your changes"
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
    $fodlerPath = "C:\GitAutomation\$repoName"
    Set-Location $fodlerPath
    $branch = git branch
    $branchInVSCode = ($branch -split ' ')[1];
    if(-Not ($branchInVSCode -eq $currentBranch)){
        $chekcoutMsg = git checkout $currentBranch
    }
    $rebaseMsg = git rebase $rebaseBranch
    write-host "pushing it to remote"
    $pushMsg = git push -f
    Set-Location $defaultLocation
}

# create new git repo (Testing is pending(TODO:))
function Init-GITRepo{
    param(
        [parameter(Mandatory)]
        $repoName
    )
    Create-NewRepo -repoName $repoName
    $gitInitMsg = git init
    write-host "To commit the changes from here to remote you need to have a remote repo, so please craete a remote repo with the same name as local repo"
    do{
        $remoteRepoMsg = Read-host "have you created your remote repo(yes/no)"
        if($remoteRepoMsg -eq "no"){
            write-host "Okay waiting till you create a remote repo"
        }
    }while($remoteRepoMsg -eq "no")

    if($remoteRepoMsg -eq "yes"){
        $aboutRepo = Read-host "what is this repo about, this will be shown in readme.md file"
        $fodlerPath = "C:\GitAutomation\$repoName"
        New-Item -Path $filePath -ItemType File
        Add-Content -Path $filePath -Value $aboutRepo
        $stageOutput = git add . 2>&1
        $commitOutput = git commit -m $commitMessage 2>&1
        $repoLink = "https://github.com/tulasi-das/$repoName.git"
        $addingToOrigin = git remote add origin $repoLink 2>&1
        $changeName = git branch -M main
        $upstreamMsg = git push --set-upstream origin main
        $pushBranch = git push -f
    }
}

