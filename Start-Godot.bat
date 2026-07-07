@echo off
rem BORISAWA - launch the Godot build (no editor).
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe"
where godot >nul 2>nul && set "GODOT=godot"
rem %* forwards flags to the game (e.g.: Start-Godot.bat -- --origin=ironblooded --cls=warrior --skip=wilds)
start "" "%GODOT%" --path "%~dp0godot" %*
