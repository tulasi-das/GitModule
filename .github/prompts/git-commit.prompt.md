---
agent: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.

## Task: Commit Changes to Git Branch

### Objective
Execute `git add .` and `git commit -m` with a user-provided commit message.

### Steps
1. Take commit message from user via `Read-Host "Enter a commit message"`
2. Execute `git add .` to stage all changes
3. Execute `git commit -m $commitMessage` with the user-provided message

### Requirements
- Capture git output with `2>&1` error redirection
- Display output to user with `Write-Host` in green color
- Use the exact user message without modification