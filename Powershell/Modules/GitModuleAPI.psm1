
# function to create a repo using the GITHUB api
function Create-GITRepoUsingAPI{

    # Set your GitHub personal access token
    if ($env:GITHUB_TOKEN -eq "")
    {
        Set-TokenAsEnvVariable
    }
    $accessToken = $env:GITHUB_TOKEN

    # Set the repository name
    $repoName = Read-Host "Give me the repo that you want to creaete" -ForegroundColor Green

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
        Write-Host "Repository '$repoName' created successfully." -ForegroundColor Green
    } else {
        Write-Host "Failed to create the repository." -ForegroundColor Green
        Write-Host $error[0].Exception.Message
    }
}

# Fuction for getting all the github repos 
function Get-RepoDetails{
    # Set your GitHub personal access token
    if ($env:GITHUB_TOKEN -eq "")
    {
        Set-TokenAsEnvVariable
    }
    $accessToken = $env:GITHUB_TOKEN
    
    # Set the owner and repository name
    $owner = Read-host "Give me the user name" -ForegroundColor Green
    $repo =  Read-host "Give me the repo name" -ForegroundColor Green

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
        Write-Host "Repository details retrieved successfully." -ForegroundColor Green
    } else {
        Write-Host "Failed to retrieve repository details." -ForegroundColor Green
        Write-Host $error[0].Exception.Message
    }

}
# Funciton to list all the contributors in the repo
function List-AllTheContributors{
    # Set your GitHub repository details
    $owner = Read-host "Give me the user name" -ForegroundColor Green
    $repo = Read-Host "Give me a repo name of which you want to list the contributors" -ForegroundColor Green
    if ($env:GITHUB_TOKEN -eq "")
    {
        Set-TokenAsEnvVariable
    }
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
        Write-Host "Contributors listed successfully." -ForegroundColor Green
    } else {
        Write-Host "Failed to list contributors." -ForegroundColor Green
        Write-Host $error[0].Exception.Message
    }

}
# Function for deleting a repo
function Delete-Repo{
    # Set your GitHub repository details
    $owner = "Give me the user name"
    $repo = Read-host "Give me the repo name which you want to delete" -ForegroundColor Green
    if ($env:GITHUB_TOKEN -eq "")
    {
        Set-TokenAsEnvVariable
    }
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
        Write-Host "Repository $owner/$repo deleted successfully." -ForegroundColor Green
    } else {
        Write-Host "Failed to delete repository." -ForegroundColor Green
        Write-Host $error[0].Exception.Message
    }

}

# Function for making a fodler private 
function MakeRepo-Private {
    # Set your GitHub repository details
    $owner = "Give me the user name" 
    $repo = Read-Host "Give Me a repo which you want to private" -ForegroundColor Green
    if ($env:GITHUB_TOKEN -eq "")
    {
        Set-TokenAsEnvVariable
    }
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
        Write-Host "Repository $owner/$repo set to private successfully." -ForegroundColor Green
    } else {
        Write-Host "Repository is not set to private" -ForegroundColor Green
}
}
# setting up $PAT env variable 
function Set-TokenAsEnvVariable{
    $PAT = Read-Host "Give me the Personal Access Token" -ForegroundColor Green
    $env:GITHUB_TOKEN = $PAT 
    Write-Host "Your token has been set as env variable" -ForegroundColor Green
}