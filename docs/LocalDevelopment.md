# Local Development Guide  This document covers the recommended workflow for developing and testing SleekChat locally on
**Windows
**, including installing Lua/LuaRocks, creating symbolic links, and setting up linting. --- ## Installing Lua & LuaRocks on Windows  SleekChat is written in Lua, and we recommend using
**luacheck** (installed via LuaRocks) to lint your addon’s code. ### 1. Manual Download and Setup 1. **Lua All-in-One
**      You can download a Windows “all-in-one” Lua package (which includes
`lua.exe` and libraries) from various sources online. 2. **Extract & Place
**      Extract the downloaded files into a folder (e.g. `C:\Lua`), then ensure that `C:\Lua` is added to your **PATH
** environment variable. 3. **LuaRocks**      - Download the matching **LuaRocks
** Windows package and place it in the same folder as `lua.exe`. - Update PATH if needed so
`luarocks.exe` is discoverable. - **Note:
** Whenever you update Lua or LuaRocks, you’d need to replace these executables again. ### 2. Using a Windows Package Manager If you’d rather not manually download and maintain your Lua setup, you can use a package manager like
**Scoop** or **Chocolatey
**—similar to Linux package management. That way, you can easily update everything with one command. #### 2.1 Scoop 1. *
*Install [Scoop](https://scoop.sh/)
**. 2. Run:    ```powershell    scoop bucket add main    scoop install main/luarocks``

Scoop will install both Lua and LuaRocks into your environment automatically.

#### 2.2 Chocolatey

1. **Install [Chocolatey](https://chocolatey.org/)**.
2. Run:

   powershell

   CopyEdit

   `choco install luarocks`

   Chocolatey will set up LuaRocks (and handle Lua as a dependency).

### Checking Installation

Open **Command Prompt** or **PowerShell** and type:

powershell

CopyEdit

`lua -v luarocks --version`

If both commands respond with version info, you’re good to go.

* * *

Symbolic Links for Local Development
------------------------------------

Using **symbolic links** (Windows directory junctions) is the easiest way to avoid constantly copying files into WoW’s
`AddOns` folder.

1. **Project Folder**  
   Example: `C:\Users\<YourName>\Projects\SleekChat`.
2. **WoW AddOns Folder**  
   E.g., `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns`.
3. **Create Link** from an **Administrator** Command Prompt:

   cmd

   CopyEdit

   ```powershell
   New-Item -ItemType Junction `
   -Path "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\SleekChat" `
   -Target "C:\Users\Taban\IdeaProjects\SleekChat"
   ```

   Adjust paths to match your setup.

Now all changes in your local repo instantly reflect in WoW.

* * *

LuaCheck & Linting
------------------

### 1\. Install LuaCheck

With LuaRocks on Windows, simply run:

powershell

CopyEdit

`luarocks install luacheck`

LuaCheck should now be available in your PATH.

### 2\. Basic Lint Script

Create a small batch or PowerShell script to run LuaCheck over your addon directories:

bat

CopyEdit

`:: check.bat @echo off echo Running LuaCheck... luacheck Modules Config  IF %ERRORLEVEL% NEQ 0 (   echo "LuaCheck found issues!"   exit /b 1 ) echo "No issues found!"`

Run `check.bat` before testing in WoW to catch syntax and style issues quickly.

* * *

Local Deployment Without Symlinks
---------------------------------

If symlinks aren’t an option, create a script to copy files to WoW’s AddOns folder:

powershell

CopyEdit

`# deploy.ps1  # 1) Lint first luacheck Modules Config if ($LASTEXITCODE -ne 0) {   Write-Host "Lint errors!"   exit 1 }  # 2) Remove old addon folder $wowPath = "C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\SleekChat" if (Test-Path $wowPath) {   Remove-Item $wowPath -Recurse -Force }  # 3) Copy new version Copy-Item -Path .\SleekChat -Destination (Split-Path $wowPath -Parent) -Recurse  Write-Host "Deployment complete. Restart or /reload in WoW to see changes."`

* * *

In-Game Testing
---------------

1. **Launch WoW Classic** as usual.
2. **Type `/reload`** in chat to load your latest code changes whenever you modify the addon.
3. **Enable Lua Error Display** if you need to see errors right away (Interface → Help → Display Lua Errors, or check
   `FrameXML.log`/`Errors.log`).

* * *

Summary
-------

1. **Install Lua & LuaRocks** via manual download or a package manager.
2. **Link or Script** to quickly push changes into WoW’s `AddOns` folder.
3. **Use LuaCheck** to lint your code regularly.
4. **In-Game**: type `/reload` to test updates instantly.

With this setup, you can iterate rapidly on **SleekChat** while ensuring high code quality and minimal friction.
