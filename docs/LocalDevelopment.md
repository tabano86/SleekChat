# Local Development Guide

This guide outlines the recommended workflow for developing and testing SleekChat locally on Windows.

## Prerequisites
- **Lua & LuaRocks:** Install via manual download or package managers (Scoop/Chocolatey).
- **LuaCheck:** Installed via LuaRocks for linting your code.

## Installation (Manual Setup)
1. **Download Lua All-in-One:** Extract to a folder (e.g. `C:\Lua`) and add it to your PATH.
2. **Install LuaRocks:** Place `luarocks.exe` alongside `lua.exe` and update your PATH accordingly.

## Using a Package Manager

### Scoop
```powershell
scoop bucket add main
scoop install main/luarocks
```

Chocolatey
`choco install luarocks`
Verifying Installation
Open Command Prompt or PowerShell and run:

`lua -v`
`luarocks --version`
Setting Up Symbolic Links
Use directory junctions to link your local project to WoW’s AddOns folder:

Project Folder: e.g. C:\Users\<YourName>\Projects\SleekChat
WoW AddOns Folder: e.g. C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns
Create the link from an Administrator Command Prompt:

```powershell
New-Item -ItemType Junction `
  -Path "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\SleekChat" `
  -Target "C:\Users\<YourName>\Projects\SleekChat"
```

Linting & Automated Checks
Create a script (e.g. check.bat) to run LuaCheck:
```powershell
@echo off
echo Running LuaCheck...
luacheck Modules Config
IF %ERRORLEVEL% NEQ 0 (
    echo "LuaCheck found issues!"
    exit /b 1
)
echo "No issues found!"

```

Deployment Without Symlinks
Alternatively, use a deployment script (e.g. deploy.ps1):
```powershell
# deploy.ps1
# 1. Lint first
luacheck Modules Config
if ($LASTEXITCODE -ne 0) {
    Write-Host "Lint errors!"
    exit 1
}

# 2. Remove old addon folder
$wowPath = "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\SleekChat"
if (Test-Path $wowPath) {
    Remove-Item $wowPath -Recurse -Force
}

# 3. Copy new version
Copy-Item -Path .\SleekChat -Destination (Split-Path $wowPath -Parent) -Recurse
Write-Host "Deployment complete. Restart or /reload in WoW to see changes."
```

In-Game Testing
Launch WoW Classic.
Type /reload to load changes.
Enable Lua error display (Interface → Help → Display Lua Errors) for immediate feedback.
