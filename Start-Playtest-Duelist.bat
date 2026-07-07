@echo off
rem AETHER BOUND - playtest del kit Duelist (PRD-006 alcance 3).
rem Doble clic y listo: boot directo a Wilds como Ironblooded Warrior
rem con el par light/heavy spawneado a 8 m del jugador.
rem Controles: LMB/F = combo x4 - RMB mantener = guardia - RMB tap = parry Roba
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe"
where godot >nul 2>nul && set "GODOT=godot"
start "" "%GODOT%" --path "%~dp0godot" -- --origin=ironblooded --cls=warrior --skip=wilds --spawn=duelpair
