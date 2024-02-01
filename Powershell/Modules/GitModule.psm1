#global variables 
$Global:rootFolderLocation = " "
$Global:rootFolder = " "

function Install-DependenciesAndConfigs{
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
    #setting up the core editor to VS Code, this important because, when we are doing rebase we need to open interactive mode in VS Code
    $coreEditor = git config --get core.editor 
    if(-Not($coreEditor -eq "code --wait"))
    {
        git config --global core.editor "code --wait"
    }
}

function Give-Options {
    #give user a grid view to choose his input
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

    Write-Host $selectedOption
    
    if($selectedOption -eq "Create Root Folder"){
        $rootFolder = Read-Host "Give me the folder Name, this can be considered as Root Folder"
        Create-RootFolder -rootFolder $rootFolder
    }

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
        $branchName = Read-host "Give me the branch name on which you want to drop the commit"
        Drop-Commit -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "edit commit")
    {
        $repoName = Read-Host "Give me the repo Name of which you want to edit commit"
        $branchName = Read-host "Give me the commit ID"
        Edit-Commit -repoName $repoName -branchName $branchName
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
        $branchName = Read-host "Give me the branch name "
        Squase-Commit -repoName $repoName -branchName $branchName
    }

    if($selectedOption -eq "Show log")
    {
        $repoName = Read-host "Give me the repo name of which you want show logs"
        $branchName = Read-host "Give me the branch name of which you want to show logs"
        Show-log -repoName $repoName -branchName $branchName
    }
    if($selectedOption -eq "Create repo using API")
    {
        Create-GITRepoUsingAPi
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
        Write-Host "Root folder $FolderName is created" -ForegroundColor Green
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
    $fodlerPath = "C:\$Global:rootFolder\$repoName"
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
    write-host "Choose a one commit before of which you want to Squace"
        $choosenCommit = git log | Out-GridView -Title "Choose the commits" -PassThru
        $commitArray1 = $choosenCommit.split(' ')
        $rebsaeCommitMsg = git rebase -i $commitArray1[1]
        write-host "Write Squace infront of the commit which you want to Squace, save and close the file(if in vim, go to command more and type :wq)"
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
    $inputBranch = Read-Host "Is your branch exist in the remote repo(yes/no)"
    if($inputBranch -eq "yes")
    {
        $newCommitMsg = Read-Host "Do you want to create a new commit(yes/no), this is recommended"
        if($newCommitMsg -eq "yes"){
            $gitrevertMsg = git revert $commitArray1[1]
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
        write-host "Choose a one commit before of which you want to drop"
        $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
        $commitArray1 = $choosenCommit.split(' ')
        $rebsaeCommitMsg = git rebase -i $commitArray1[1]
        write-host "Write drop infront of the commit which you want to drop, save and close the file(if in vim, go to command more and type :wq)"
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
    write-host "Plesae choose a commit"
    $choosenCommit = git log | Out-GridView -Title "Choose the two commits" -PassThru
    $commitArray1 = ($choosenCommit -split ' ')
    $editMsg = git reset --soft $commitArray1[1] 2>&1
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
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
    $fodlerPath = "C:\$Global:rootFolder\$repoName"
    Set-Location $fodlerPath
    $branch = git branch
    $branchInVSCode = ($branch -split ' ')[1]
    if(-Not ($branchInVSCode -eq $currentBranch)){
        $chekcoutMsg = git checkout $currentBranch
    }
    $rebaseMsg = git rebase $rebaseBranch
    write-host "pushing it to remote"
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
    write-host "To commit the changes from here to remote you need to have a remote repo, so please craete a remote repo with the same name as local repo"
    do{
        $remoteRepoMsg = Read-host "have you created your remote repo(yes/no)"
        if($remoteRepoMsg -eq "no"){
            write-host "Okay waiting till you create a remote repo"
        }
    }while($remoteRepoMsg -eq "no")

    if($remoteRepoMsg -eq "yes"){
        $aboutRepo = Read-host "what is this repo about, this will be shown in readme.md file"
    if($Global:rootFolderLocation -eq " "){
        Write-Host "Seems Like you didn't have root folder" -ForegroundColor Yellow
        $Global:rootFolder = Read-Host "Please give the Root Folder Name"
    }
        $filePath = "C:\$Global:rootFolder\$repoName"
        New-Item -Path $filePath -ItemType File
        Add-Content -Path $filePath -Value $aboutRepo
        $stageOutput = git add . 2>&1
        $commitMessage = Read-Host "Give me a initial commit message"
        $commitOutput = git commit -m $commitMessage 2>&1
        $repoLink = "https://github.com/tulasi-das/$repoName.git"
        $addingToOrigin = git remote add origin $repoLink 2>&1
        $changeName = git branch -M main
        $upstreamMsg = git push --set-upstream origin main
        $pushBranch = git push -f
    }
}

# function to create a repo using the GITHUB api
function Create-GITRepoUsingAPi{

    # Set your GitHub personal access token
    $accessToken = $env:GITHUB_TOKEN

    # Set the repository name
    $repoName = Read-Host "Give me the repo that you want to creaete"

    # Set the GitHub API endpoint
    $apiUrl = "https://api.github.com/user/repos"
    # Create a JSON payload with repository information
    $jsonPayload = @{
        name = $repoName
    } | ConvertTo-Json

    # Set headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/vnd.github.v3+json"
    }

    # Invoke the GitHub API to create the repository
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $jsonPayload

    # Check if the repository was created successfully
    if ($response) {
        Write-Host "Repository '$repoName' created successfully."
    } else {
        Write-Host "Failed to create the repository."
        Write-Host $error[0].Exception.Message
    }
}

# Fuction for getting all the github repos 
function Get-RepoDetails{
    # Set your GitHub personal access token
    $accessToken = $env:GITHUB_TOKEN

    # Set the owner and repository name
    $owner = "tulasi-das"
    $repo = "powershell"

    # Set the GitHub API endpoint for repository details
    $apiUrl = "https://api.github.com/repos/$owner/$repo"

    # Set headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/vnd.github.v3+json"
    }

    # Invoke the GitHub API to get repository details
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

    # Display repository details
    Write-Host "Repository Details for $owner/$repo"
    Write-Host "Name: $($response.name)"
    Write-Host "Description: $($response.description)"
    Write-Host "URL: $($response.html_url)"
    Write-Host "Default Branch: $($response.default_branch)"
    Write-Host "Created At: $($response.created_at)"
    Write-Host "Updated At: $($response.updated_at)"
    # Add more properties as needed

    # You can also output the entire response object by uncommenting the next line
    # $response | Format-List

    # Check if the request was successful
    if ($response) {
        Write-Host "Repository details retrieved successfully."
    } else {
        Write-Host "Failed to retrieve repository details."
        Write-Host $error[0].Exception.Message
    }

}
# Funciton to list all the contributors in the repo
function List-AllTheContributors{
    # Set your GitHub repository details
    $owner = "tulasi-das"
    $repo = Read-Host "Give me a repo name of which you want to list the contributors"
    $accessToken = $env:GITHUB_TOKEN 

    # Set the GitHub API endpoint for listing contributors
    $apiUrl = "https://api.github.com/repos/$owner/$repo/contributors"

    # Set headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/vnd.github.v3+json"
    }

    # Invoke the GitHub API to list contributors
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

    # Display contributors
    Write-Host "Contributors to $owner/$repo"
    foreach ($contributor in $response) {
        Write-Host "Login: $($contributor.login), Contributions: $($contributor.contributions)"
    }

    # Check if the request was successful
    if ($response) {
        Write-Host "Contributors listed successfully."
    } else {
        Write-Host "Failed to list contributors."
        Write-Host $error[0].Exception.Message
    }

}

# Function for deleting a repo
function Delete-Repo{
    # Set your GitHub repository details
    $owner = "tulasi-das"
    $repo = Read-host "Give me the repo name which you want to delete"
    $accessToken = $env:GITHUB_TOKEN

    # Set the GitHub API endpoint for deleting a repository
    $apiUrl = "https://api.github.com/repos/$owner/$repo"

    # Set headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/vnd.github.v3+json"
    }

    # Invoke the GitHub API to delete the repository
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Delete

    # Check if the request was successful
    if ($response) {
        Write-Host "Repository $owner/$repo deleted successfully."
    } else {
        Write-Host "Failed to delete repository."
        Write-Host $error[0].Exception.Message
    }

}

# Function for making a fodler private 
function MakeRepo-Private {
    # Set your GitHub repository details
    $owner = "tulasi-das"
    $repo = Read-Host "Give Me a repo which you want to private"
    $accessToken = $env:GITHUB_TOKEN 

    # Set the GitHub API endpoint for updating a repository
    $apiUrl = "https://api.github.com/repos/$owner/$repo"

    # Create a JSON payload with repository settings
    $jsonPayload = @{
        private = $true
    } | ConvertTo-Json

    # Set headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/vnd.github.v3+json"
    }

    # Invoke the GitHub API to update the repository settings
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Patch -Body $jsonPayload

    # Check if the request was successful
    if ($response) {
        Write-Host "Repository $owner/$repo set to private successfully."
    } else {
        Write-Host "Repository is not set to private"
}
}
# setting up $PAT env variable 
function Set-TokenAsEnvVariable{
    $PAT = Read-Host "Give me the Personal Access Token"
    $env:PAT = $PAT 
    Write-Host "Your token has been set as env variable"
}