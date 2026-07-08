@echo off
rem AETHER BOUND - playtest en el greybox de combate (PRD-006 alcance 5).
rem Doble clic y listo: boot directo al greybox como Ironblooded Warrior
rem con UNA bestia heavy spawneada enfrente (banco limpio para medir el
rem feel: camara quieta, sin follaje/clima, 177 FPS).
rem Controles: LMB/F = combo x4 - RMB mantener = guardia - RMB tap = parry Roba
rem            T = cicla modos de animacion (2s / extremidades / suave)
rem Variar spawn: editar --spawn (ej: light,heavy  |  2light+1heavy)
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe"
where godot >nul 2>nul && set "GODOT=godot"
start "" "%GODOT%" --path "%~dp0godot" -- --origin=ironblooded --cls=warrior --skip=arena --spawn=heavy
