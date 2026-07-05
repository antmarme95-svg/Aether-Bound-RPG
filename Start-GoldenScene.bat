@echo off
rem Golden scene (B11) — revisión en vivo contra los keyframes ratificados.
rem SPACE: alterna amanecer/atardecer · F12: captura a godot/test_out · ESC: salir
set GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe
"%GODOT%" --path "%~dp0godot" -- --autotest=res://tests/autotest_golden.gd --hold
