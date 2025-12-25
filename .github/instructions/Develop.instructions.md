---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

## Project Overview

GitModule is a **PowerShell-based Git workflow automation suite** (pre-release v0.0.0.4) that provides an interactive menu-driven CLI for complex Git operations. It simplifies workflows like interactive rebasing, commit squashing, editing, and GitHub API operations that normally require manual terminal commands.

### Core Purpose
- Automate repetitive Git workflows through interactive prompts
- Provide grid-view selection for choosing commits from git log
- Integrate GitHub API for repo management (create, delete, set privacy)
- Maintain a persistent root folder context across operations

---

## Project Structure & Key Files

```
GitModule/
├── Powershell/
│   ├── firstscript.ps1              # Entry point: imports modules and launches menu
│   └── Modules/
│       ├── GitModule.psm1            # Core module (~478 lines): 18+ Git operation functions
│       ├── GitModuleAPI.psm1         # GitHub API module (~198 lines): repo/contributor management
│       └── GitModule.psd1            # Module manifest: metadata, versioning, dependencies
├── publish.ps1                       # Publishing script to PSGallery
├── README.md                         # Basic overview
├── ReleaseNotes.txt                  # Version history
├── LICENSE.md
└── TODO/
    └── todo.txt                      # Implementation roadmap and testing notes
```

### Module Responsibilities

**GitModule.psm1** (Core Workflows)
- Interactive menu (`Give-Options`) using Out-GridView
- 20+ functions for Git operations: Clone, Create-Branch, Commit, Stash, Rebase, Squash, Drop, Edit
- Global state management (`$Global:rootFolderLocation`, `$Global:rootFolder`)
- Location preservation pattern for directory navigation safety

**GitModuleAPI.psm1** (GitHub REST API)
- Create/delete repositories
- Fetch repository details and contributors
- Change repository privacy settings
- GitHub PAT authentication via `$env:GITHUB_TOKEN`

**GitModule.psd1** (Manifest)
- Module metadata and versioning (currently 0.0.0.4)
- Declares `posh-git` as required dependency
- Root module reference and GUID

---

## Development Workflow

### Local Testing
1. **Import the module locally** (from `Powershell/Modules/`)
   ```powershell
   Import-Module (Join-Path -Path <repo-path> -ChildPath 'Powershell\Modules\GitModule.psm1')
   ```
2. **Test individual functions** by calling them directly with test parameters
3. **Test menu flow** by calling `Give-Options` and navigating selections
4. **Verify git commands** are captured correctly with `2>&1` redirection

### Testing Status (from TODO.txt)
- ✅ Most Git functions: "Testing is done" (locally verified)
- ⚠️ Interactive Rebase Workflows: Partial coverage
  - `Squash-Commit`: Testing done but "still need to check some more conditions"
  - `Drop-Commit`: "Testing is pending" → marked "Testing is done" later
  - `Edit-Commit`: Uses `git reset --soft` with pending verification
  - `Git-RebaseBranch`: Marked TODO - full testing incomplete

### Publishing & Versioning
- **Version format**: `major.minor.patch.build` in `GitModule.psd1`
- **Current version**: 0.0.0.4 (pre-release)
- **Publish command**: `Publish-Module` via `publish.ps1` using `$env:PSGALLERY_API_KEY`
- **Update process**:
  1. Increment `ModuleVersion` in `GitModule.psd1`
  2. Update `ReleaseNotes.txt` with changes
  3. Run `publish.ps1` to upload to PSGallery

### Setup & Dependencies
**Automatic via `Install-DependenciesAndConfigs`**:
- Checks for `posh-git` module, installs if missing
- Sets `core.editor = "code --wait"` (required for interactive rebase editing in VS Code)
- Imports `GitModuleAPI.psm1`

**Manual Requirements**:
- PowerShell 5.1+
- Git CLI installed and in PATH
- VS Code installed (for interactive rebase editing)
- GitHub PAT for API operations (set via `Set-TokenAsEnvVariable`)

---

## Coding Standards & Patterns

### Function Naming
- **PowerShell verb-noun convention**: `Verb-Noun` (e.g., `Clone-GitRepo`, `Create-NewBranch`, `Edit-Commit`)
- **API functions**: Descriptive imperatives (e.g., `Create-GITRepoUsingAPI`, `List-AllTheContributors`)
- Avoid abbreviations in public functions (spell out "Repository", "Commit")

### Parameter Declaration
```powershell
function Clone-GitRepo {
    param(
        [Parameter(Mandatory)]
        $repoName
    )
    # Implementation
}
```
- All repo/branch parameters are mandatory (`[Parameter(Mandatory)]`)
- Use simple `$repoName`, `$branchName` naming (not abbreviated)
- Always handle null/empty global state before using parameters

### Global State Management Pattern
**Every function that uses repos must initialize root folder context**:
```powershell
if([string]::IsNullOrEmpty($Global:rootFolderLocation) -or [string]::IsNullOrWhiteSpace($Global:rootFolderLocation)) {
    $Global:rootFolder = Read-Host "Please give the Root Folder Name"
}
# Build path: "C:\$Global:rootFolder\$repoName"
$folderPath = "C:\$Global:rootFolder\$repoName"
Set-Location $folderPath
```

**Alternative (delegated initialization)**:
```powershell
Set-RootFolderLocation -repoName $repoName  # Encapsulates the null check
```

### Location Preservation Pattern
**Always restore working directory after operations**:
```powershell
function My-GitOperation {
    param([Parameter(Mandatory)]$repoName)
    
    $defaultLocation = Get-Location  # Save current location
    
    # ... change location and perform work ...
    Set-RootFolderLocation -repoName $repoName
    $output = git <command> 2>&1
    
    Set-Location $defaultLocation  # Restore location
}
```

### Git Command Execution
- **Capture output with error redirection**: `$output = git <cmd> 2>&1`
- **Use raw git commands** (not PowerShell wrappers; posh-git provides completion only)
- **Forced pushes**: `git push -f` appropriate for feature branches in rebase workflows
- **Branch checkout**: Use `git checkout $branchName` (not `git checkout -$branchName` — this is a known bug)

### User Input & Interactive UI
```powershell
# Read-Host for simple prompts
$branchName = Read-Host "Give me the branch name"

# Out-GridView for multi-select (e.g., choosing commits)
$choosenCommit = git log | Out-GridView -Title "Choose the commits" -PassThru

# Yes/no confirmations (always lowercase check)
$confirmation = Read-Host "Are there any changes(yes/no)"
if($confirmation -eq "yes") {
    # Execute
}
```

### Output & Logging
```powershell
Write-Host "Repository created successfully." -ForegroundColor Green   # Success
Write-Host "Please provide a token." -ForegroundColor Yellow          # Warning
Write-Host "Operation failed." -ForegroundColor Red                   # Error (rarely used)
```
- Green: successful operations
- Yellow: prompts, warnings, pending actions
- Output messages are descriptive and include context (repo name, branch, status)

### GitHub API Pattern
```powershell
# 1. Check token
if ($env:GITHUB_TOKEN -eq "") {
    Set-TokenAsEnvVariable
}
$accessToken = $env:GITHUB_TOKEN

# 2. Build URL and headers
$apiUrl = "https://api.github.com/repos/$owner/$repo/something"
$headers = @{
    Authorization = "Bearer $accessToken"
    Accept = "application/vnd.github.v3+json"
}

# 3. Invoke API
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# 4. Validate and display
if ($response) {
    Write-Host "Operation successful." -ForegroundColor Green
    # Display $response properties
} else {
    Write-Host "Operation failed." -ForegroundColor Green
    Write-Host $error[0].Exception.Message
}
```
- Bearer token authentication (not Basic auth)
- Always pre-check `$env:GITHUB_TOKEN` before making calls
- Validate response before displaying
- Display error details from `$error[0].Exception.Message`

---

## Adding New Features

### Adding a Git Operation Function

1. **Create function with verb-noun naming**:
   ```powershell
   function New-GitOperation {
       param(
           [Parameter(Mandatory)]$repoName,
           [Parameter(Mandatory)]$branchName
       )
   }
   ```

2. **Initialize root folder location**:
   ```powershell
   Set-RootFolderLocation -repoName $repoName
   ```

3. **Save and restore working directory**:
   ```powershell
   $defaultLocation = Get-Location
   # ... work ...
   Set-Location $defaultLocation
   ```

4. **Use git command pattern**:
   ```powershell
   $output = git <command> 2>&1
   Write-Host $output -ForegroundColor Green
   ```

5. **Add menu option in `Give-Options` switch**:
   ```powershell
   $newFeature = "New Feature Name"
   # Add to $options array
   # Add to switch statement:
   $newFeature {
       $repoName = Read-Host "Give me the repo Name"
       $branchName = Read-Host "Give me the branch name"
       New-GitOperation -repoName $repoName -branchName $branchName
   }
   ```

6. **Document testing status in comment**:
   ```powershell
   # Testing is done (or # TODO: if pending)
   function My-Operation {
   ```

7. **Consider interactive scenarios**:
   - Does user need to select commits? Use `Out-GridView`
   - Does function open VS Code? Ensure `code --wait` is set
   - Does function require editor interaction? Add guidance comments

### Adding an API Function

1. **Follow GitHub REST API v3 documentation**
2. **Request user input before calling API** (owner, repo, settings)
3. **Check token availability**:
   ```powershell
   if ($env:GITHUB_TOKEN -eq "") {
       Set-TokenAsEnvVariable
   }
   ```
4. **Use consistent header pattern**:
   ```powershell
   $headers = @{
       Authorization = "Bearer $env:GITHUB_TOKEN"
       Accept = "application/vnd.github.v3+json"
   }
   ```
5. **Validate response and display results**
6. **Add to menu in `Give-Options`** if user-facing

### Updating Module Manifest

When releasing a new version:
1. Update `ModuleVersion` in `GitModule.psd1`:
   ```powershell
   ModuleVersion = '0.0.0.5'
   ```
2. Add release notes to `ReleaseNotes.txt`:
   ```
   0.0.0.5 --> Brief description of changes (Stable/Not Stable)
   ```
3. Verify `RootModule = './GitModule.psm1'` points to correct file

---

## Known Issues & Bug Fixes

### Current Bugs (Discovered During Analysis)

1. **Branch Checkout Syntax Error** (Show-log, Squash-Commit, Drop-Commit, Edit-Commit)
   - **Location**: Multiple functions using `git checkout -$branchName`
   - **Fix**: Change to `git checkout $branchName`
   - **Example**:
     ```powershell
     # Wrong:
     $gitChangeBrnachMsg = git checkout -$branchName
     # Correct:
     $gitChangeBrnachMsg = git checkout $branchName
     ```

2. **Delete-Repo Assignment Bug** (GitModuleAPI.psm1)
   - **Location**: `Delete-Repo` function
   - **Issue**: `$owner = "Give me the user name"` (hardcoded string instead of prompt)
   - **Fix**: Use `Read-Host`
     ```powershell
     # Wrong:
     $owner = "Give me the user name"
     # Correct:
     $owner = Read-Host "Give me the user name" -ForegroundColor Green
     ```

3. **Incomplete Testing**
   - `Git-RebaseBranch`: Marked TODO - full testing not complete
   - `Edit-Commit`: `git reset --soft` implementation needs verification
   - `Squash-Commit`: Needs additional condition testing

### Known Limitations (By Design)

1. **Windows-Only**: Hardcoded `C:\` drive path - won't work on Linux/Mac
2. **Session-Scoped PAT**: GitHub token stored in `$env:GITHUB_TOKEN` (session variable, not persistent)
3. **Interactive Blocking**: Out-GridView selections block execution (suitable for CLI, not batch)
4. **Minimal Error Handling**: Relies on output capture, no formal try-catch in most functions

---

## Testing Checklist

Before committing changes:

- [ ] **Unit Testing**: Test function directly with sample repos/branches
- [ ] **Menu Integration**: Test function appears and executes from `Give-Options`
- [ ] **Location Safety**: Verify working directory is restored after function completes
- [ ] **Git Command Output**: Verify `2>&1` capture shows success/error correctly
- [ ] **User Prompts**: Verify all `Read-Host` prompts are clear and descriptive
- [ ] **Edge Cases**:
  - Null/empty global state (root folder not set)
  - Non-existent repo/branch
  - API call without token
  - User cancellation in Out-GridView
- [ ] **Comment Documentation**: Add "# Testing is done" or "# TODO:" comment above function

---

## Debugging Tips

### Debug Git Command Execution
```powershell
# Capture and inspect output
$output = git <command> 2>&1
$output | Get-Member  # Check type
$output | Write-Host  # Display raw output
```

### Debug Global State Issues
```powershell
Write-Host "RootFolderLocation: $Global:rootFolderLocation"
Write-Host "RootFolder: $Global:rootFolder"
Write-Host "Current Location: $(Get-Location)"
```

### Debug API Calls
```powershell
$response | Format-List  # Display all properties
$response | ConvertTo-Json | Write-Host  # JSON view
$error[0] | Format-List  # Inspect error details
```

### Test Specific Function Without Menu
```powershell
Import-Module (Join-Path -Path <repo-path> -ChildPath 'Powershell\Modules\GitModule.psm1')
Clone-GitRepo -repoName "TestRepo"
```

---

## Performance Considerations

- **Out-GridView blocking**: Selections pause script execution (by design for interactive use)
- **Forced pushes**: `git push -f` appropriate only for feature branches
- **API calls**: No pagination implemented for large contributor lists
- **Global state persistence**: Only valid during current PowerShell session

---

## Future Roadmap (From TODO.txt)

- [ ] Cross-platform support (detect OS, use appropriate paths)
- [ ] Persistent PAT storage (Windows Credential Manager)
- [ ] Enhanced error handling (terminating errors + try-catch)
- [ ] Function parameter validation (test empty strings earlier)
- [ ] Unit tests with Pester framework
- [ ] Commit pagination for `Show-log` (currently shows all commits)
- [ ] Additional API functions (branching, pull requests, releases)
- [ ] Stable release (v1.0.0)

---

## Communication Guidelines for AI

- **Preserve existing patterns**: Don't refactor git command execution or location preservation without discussion
- **Respect interactive design**: Out-GridView and Read-Host are intentional for CLI UX
- **Test thoroughly**: Interactive rebase workflows need special attention due to editor interaction
- **Document status**: Always indicate testing status in code comments
- **Reference specific files**: When suggesting changes, cite exact functions/lines
- **Consider Windows scope**: Acknowledge path hardcoding limitation in cross-platform discussions