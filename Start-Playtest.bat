@echo off
setlocal enabledelayedexpansion
title Aether Bound - Playtest Protocolo A

rem Lanzador de sesion del test gris del Bond.
rem Existe porque en PowerShell el "--" que Godot necesita para separar sus
rem argumentos de los del proyecto es un OPERADOR del shell, y la linea se
rem rompe con "Token 'path' inesperado". Se puede sortear con --% pero eso
rem no es algo que convenga estar peleando con un tester sentado al lado.
rem
rem   Start-Playtest.bat Diego
rem   Start-Playtest.bat          (pregunta el nombre)

set "GODOT=C:\Users\tonom\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64.exe"

if not exist "%GODOT%" (
  echo.
  echo   No se encontro Godot en:
  echo     %GODOT%
  echo.
  echo   Edita la variable GODOT arriba en este archivo.
  echo.
  pause
  exit /b 1
)

set "TESTER=%~1"
if "%TESTER%"=="" set /p "TESTER=Nombre del tester: "
if "%TESTER%"=="" (
  echo.
  echo   Hace falta un nombre de tester: el CSV se guarda con ese id.
  echo.
  pause
  exit /b 1
)

echo.
echo   ============================================================
echo    PROTOCOLO A - test gris del Bond
echo   ============================================================
echo    Tester        : %TESTER%
echo    Inicio        : %DATE% %TIME%
echo.
echo    F10  corte por fallo tecnico del build
echo    F11  corte por incomodidad del tester
echo    ESC  libera el mouse
echo.
echo    Recorda anotar esta hora en la hoja de registro.
echo   ============================================================
echo.

"%GODOT%" --path "%~dp0godot" -- --tester=%TESTER%

echo.
echo   Sesion terminada. El CSV quedo en:
echo     %APPDATA%\Godot\app_userdata\
echo   (carpeta del proyecto, subcarpeta telemetry)
echo.
echo   Para leer los resultados de los 3 testers:
echo     Report-Playtest.bat
echo.
pause
