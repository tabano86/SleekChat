# PowerShell

# ==================================
# Configuration Parameters
# ==================================

# Path to your WoW Classic AddOns directory
$wowAddonsPath = "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"

# Path to your addon's development directory (where the 'src' folder is)
$sourceAddonPath = $PSScriptRoot

# Directory to copy contents from
$sourceFolder = ""

# ==================================
# Functions
# ==================================

Function Remove-ExistingAddonDirectory
{
    param ([string]$destinationPath)

    $SleekChatAddonPath = Join-Path -Path $destinationPath -ChildPath "SleekChat"

    Write-Host "Removing any existing SleekChat directory to ensure a clean deployment..." -ForegroundColor Yellow

    if (Test-Path -Path $SleekChatAddonPath)
    {
        Remove-Item -Path $SleekChatAddonPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Existing SleekChat directory removed." -ForegroundColor Green
    }
    else
    {
        Write-Host "No existing SleekChat directory found; nothing to remove." -ForegroundColor Cyan
    }
}

Function Clear-NonUserSettings {
    param ([string]$destinationPath)

    Write-Host "Clearing non-user settings..." -ForegroundColor Yellow

    # Define patterns or files to remove
    $filesToDelete = @("settings_temp.json", "*.old", "*.cache")

    $SleekChatAddonPath = Join-Path -Path $destinationPath -ChildPath "SleekChat"

    foreach ($filePattern in $filesToDelete)
    {
        $files = Get-ChildItem -Path $SleekChatAddonPath -Filter $filePattern -Recurse -ErrorAction SilentlyContinue
        if ($files) {
            Write-Host "Deleting files matching pattern '$filePattern' in '$SleekChatAddonPath'" -ForegroundColor Yellow
            $files | Remove-Item -Force -Recurse
        }
    }

    Write-Host "Non-user settings cleared." -ForegroundColor Green
}

Function Copy-AddonFiles {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )

    Write-Host "Starting deployment..." -ForegroundColor Cyan

    $SleekChatAddonPath = Join-Path -Path $destinationPath -ChildPath "SleekChat"
    New-Item -Path $SleekChatAddonPath -ItemType Directory -Force | Out-Null

    $sourceContentPath = Join-Path -Path $sourcePath -ChildPath $sourceFolder
    if (Test-Path -Path $sourceContentPath) {
        Write-Host "Copying contents of '$sourceFolder' to '$SleekChatAddonPath'..." -ForegroundColor Green
        Copy-Item -Path (Join-Path $sourceContentPath '*') -Destination $SleekChatAddonPath -Recurse -Force
        Write-Host "Deployment complete!" -ForegroundColor Cyan
    } else {
        Write-Host "Source folder '$sourceFolder' does not exist!" -ForegroundColor Red
        exit 1
    }
}

# ==================================
# Main Script Execution
# ==================================

# Remove existing SleekChat addon directory
Remove-ExistingAddonDirectory -destinationPath $wowAddonsPath

# (Optional) Clear non-user settings from user-specific backup locations if needed
Clear-NonUserSettings -destinationPath $wowAddonsPath

# Copy addon files to the target directory
Copy-AddonFiles -sourcePath $sourceAddonPath -destinationPath $wowAddonsPath
