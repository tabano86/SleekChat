@echo off
echo Running LuaCheck...
luacheck Modules Config

IF %ERRORLEVEL% NEQ 0 (
    echo "LuaCheck found issues!"
    exit /b 1
)

echo "No issues found!"
