# GitModule AI Coding Instructions

## Project Overview
GitModule is a **PowerShell-based Git workflow automation suite** that provides an interactive menu-driven interface for complex Git operations. It simplifies advanced workflows (rebasing, squashing, commit editing, API operations) that normally require manual terminal commands. The project is **pre-release** (v0.0.0.4) and actively evolving.

## Architecture & Structure

### Module Organization
- **GitModule.psm1** (~478 lines): Core CLI workflow module with interactive menu (`Give-Options`) and 20+ Git operation functions
- **GitModuleAPI.psm1** (~198 lines): GitHub REST API integration (repo creation, details, contributors, privacy settings)
- **GitModule.psd1**: Module manifest (metadata, versioning, dependencies on `posh-git`)
- **firstscript.ps1**: Entry point that imports modules and launches interactive menu

### Key Data Flow
1. User imports `GitModule.psm1` → Initializes global vars (`$Global:rootFolderLocation`, `$Global:rootFolder`)
2. `Give-Options` displays grid-based menu (Out-GridView) for 18 operations
3. Selected function prompts for repo/branch names, then executes git/API commands
4. Results written to host with color-coded output (Green/Yellow for status)

### Global State Management
The module relies on two **global variables** to track workspace context:
- `$Global:rootFolderLocation`: Full path to root folder (e.g., `C:\MyRepos`)
- `$Global:rootFolder`: Root folder name for reconstruction
- These persist across function calls but **reset on PowerShell session restart**

## Critical Patterns & Conventions

### Function Naming & Behavior
- **Imperative verbs**: `Clone-GitRepo`, `Create-NewBranch`, `Edit-Commit` (PowerShell verb-noun standard)
- **Repository location handling**: Most functions follow this pattern:
  ```powershell
  if([string]::IsNullOrEmpty($Global:rootFolderLocation) -or [string]::IsNullOrWhiteSpace($Global:rootFolderLocation)) {
      $Global:rootFolder = Read-Host "Please give the Root Folder Name"
  }
  # Build path: "C:\$Global:rootFolder\$repoName"
  ```
- **Location preservation**: Save current location, change to repo directory, restore on exit
  ```powershell
  $defaultLocation = Get-Location
  # ... work ...
  Set-Location $defaultLocation
  ```

### Interactive User Input
- Heavy use of **`Out-GridView`** for multi-select scenarios (choosing commits from git log)
- **`Read-Host`** for string inputs with descriptive color-coded prompts
- Yes/no confirmations: Always accept lowercase "yes"/"no" (`if($input -eq "yes")`)

### Git Integration Patterns
- Raw `git` command execution (not git module cmdlets) captured as `$output = git <cmd> 2>&1`
- **Forced pushes**: `git push -f` common in rebase/squash workflows (suitable for feature branches)
- **VS Code integration**: Core editor hardcoded to `code --wait` in `Install-DependenciesAndConfigs`
- **Dependency**: Assumes `posh-git` module installed (verified/installed automatically)

### API Authentication
- GitHub PAT stored in **`$env:GITHUB_TOKEN`** environment variable
- `Set-TokenAsEnvVariable` prompts user if token missing (session-scoped, not persistent)
- API calls use Bearer auth: `Authorization = "Bearer $accessToken"`

## Development Workflows

### Installation & First Run
```powershell
# User installs from PSGallery (planned via publish.ps1)
Install-Module -Name GitModule

# Then runs initial setup
Import-Module GitModule
Give-Options  # Select "Install dependencies and configs"
```

### Setup Requirements
- **posh-git** module auto-installed if missing
- **VS Code** must be installed (git core.editor set to `code --wait`)
- **GitHub PAT** required for API operations (set via `Set-TokenAsEnvVariable`)
- **Git CLI** must be in PATH

### Publishing
- Script: `publish.ps1` → `Publish-Module` to PSGallery using `$env:PSGALLERY_API_KEY`
- Versioning: Manual in `GitModule.psd1` (currently 0.0.0.4, pre-release)

## Common Pitfalls & Testing Notes

### Known Issues (from comments)
- **`Edit-Commit`**: Uses `git reset --soft` but comments indicate testing pending
- **`Git-RebaseBranch`**: TODO marked - full testing not complete
- **Path handling**: Windows-specific (`C:\` hardcoded), won't work on Linux/Mac
- **Branch checkout syntax error**: `git checkout -$branchName` should be `git checkout $branchName`
- **API `Delete-Repo`**: Has assignment bug (`$owner = "Give me the user name"` should use `Read-Host`)

### Test Scope
Most Git functions tested locally (`Testing is done` comments), but interactive rebase workflows (`Squash-Commit`, `Drop-Commit`, `Edit-Commit`) have partial coverage.

## When Modifying Code

### Adding New Git Operations
1. Follow verb-noun naming: `<Verb>-<GitOperation>`
2. Accept mandatory params for `$repoName` and `$branchName` (if applicable)
3. Call `Set-RootFolderLocation -repoName $repoName` at start
4. Use `$defaultLocation = Get-Location` / restore pattern for location safety
5. Wrap git output: `$output = git <cmd> 2>&1`
6. Use `Write-Host` with `-ForegroundColor Green` for success, `Yellow` for warnings
7. Add menu option in `Give-Options` switch statement
8. Document testing status in comment (`# Testing is done` or `# TODO:`)

### Extending API Functions
1. Check `$env:GITHUB_TOKEN` existence before API calls
2. Use consistent headers with Bearer auth
3. Call `Invoke-RestMethod` with `-Headers $headers -Method <Get|Post|Patch|Delete>`
4. Validate `$response` before display (`if ($response) { ... }`)

### Module Manifest Updates
- Update `ModuleVersion` in `GitModule.psd1` (semantic: major.minor.patch.build)
- Add release notes to `ReleaseNotes.txt`
- Keep `RootModule` pointing to `./GitModule.psm1`

## Special Considerations

### Interactive Rebase Workflows
Functions like `Squash-Commit`, `Drop-Commit`, `Edit-Commit` require **vim/editor interaction**:
- User edits rebase file in VS Code (due to `core.editor = "code --wait"`)
- Script continues with `git rebase --continue` after user closes editor
- Comments guide user: "Write [pick|squash|drop] infront of commit, :wq to save"

### Error Handling
- Minimal try-catch blocks; relies on capturing `2>&1` output
- No formal error propagation; success shown via color-coded output
- API failures display `$error[0].Exception.Message`
- Consider adding terminating errors for critical path functions

### Performance & Scope
- Grid-view selections (`Out-GridView`) block execution (not async)
- Suitable for interactive CLI, not batch automation
- Root folder always reconstructed as `C:\$Global:rootFolder` (hardcoded drive)

## Recommended Improvements (Future)
- Cross-platform support (detect OS, use appropriate paths)
- Persistent PAT storage (Windows Credential Manager)
- Error handling refactor (terminating errors + try-catch)
- Function parameter validation (test empty strings earlier)
- Unit tests for Git command wrapping (pester framework)
