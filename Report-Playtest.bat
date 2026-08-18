@echo off
setlocal
title Aether Bound - Informe del Protocolo A

rem Deriva P, T y U de todas las sesiones guardadas y da el veredicto de
rem seccion 0.3. No mueve umbrales: estan como constantes en el codigo.

set "GODOT=C:\Users\tonom\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe"

if not exist "%GODOT%" (
  echo   No se encontro Godot en: %GODOT%
  pause
  exit /b 1
)

"%GODOT%" --headless --path "%~dp0godot" --script res://tools/telemetry_report.gd -- --dir=user://telemetry

echo.
pause
