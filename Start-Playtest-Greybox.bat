@echo off
rem AETHER BOUND - playtest en el greybox de combate (PRD-006/007).
rem Doble clic y listo: boot directo al greybox como Ironblooded Warrior
rem con UNA bestia heavy enfrente y DAGNA aliada a tu lado (banco limpio
rem para medir el feel: camara quieta, sin follaje/clima).
rem Combate: LMB/F = combo x4 - RMB mantener = guardia - RMB tap = parry Roba
rem SPRINGBOARD (PRD-007 alcance 2):
rem   R = Bond: Dagna hace ground-pound -> onda teal (anillos = "salta AHORA")
rem   SPACE dentro de la onda = lanzamiento vertical ~6m (dirigible con WASD)
rem   SPACE fuera de la onda = salto normal
rem   T = cicla modos de animacion (2s / extremidades / suave)
rem Variar spawn: editar --spawn (ej: light,heavy  |  2light+1heavy)
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe"
where godot >nul 2>nul && set "GODOT=godot"
start "" "%GODOT%" --path "%~dp0godot" -- --origin=ironblooded --cls=warrior --skip=arena --spawn=heavy --ally=dagna
