@echo off
setlocal enabledelayedexpansion
title Aether Bound - Playtest Protocolo A

rem Lanzador de sesion del test gris del Bond.
rem Existe porque en PowerShell el "--" que Godot necesita para separar sus
rem argumentos de los del proyecto es un OPERADOR del shell, y la linea se
rem rompe con "Token 'path' inesperado". Se puede sortear con --% pero eso
rem no es algo que convenga estar peleando con un tester sentado al lado.
rem
rem   Start-Playtest.bat prueba
rem   Start-Playtest.bat                       (pregunta el nombre)
rem   Start-Playtest.bat prueba --gravedad=22  (variante de tacto)
rem
rem --gravedad= cambia cuanto dura el salto en el aire SIN cambiar su
rem alcance: el impulso se recalcula solo para que la mesa se siga
rem alcanzando igual. Es para comparar tacto, no para el playtest real.
rem
rem OJO CON EL NOMBRE. El 2026-08-18 una sesion de prueba quedo grabada como
rem "diego" porque el ejemplo del comando llevaba ese nombre. Un CSV mal
rem etiquetado contamina la muestra sin avisar, asi que los tres nombres
rem registrados piden confirmacion explicita.

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

rem Los tres testers registrados (ADR-003) son sesion REAL: se confirma.
set "REAL="
if /i "%TESTER%"=="Diego" set "REAL=1"
if /i "%TESTER%"=="Santiago" set "REAL=1"
if /i "%TESTER%"=="Delmer" set "REAL=1"
if defined REAL (
  echo.
  echo   "%TESTER%" es uno de los tres testers registrados.
  echo   Esta sesion va a ENTRAR EN LA MUESTRA del Protocolo A.
  echo.
  set /p "OK=Es la sesion real de %TESTER%? (s/n): "
  if /i not "!OK!"=="s" (
    echo.
    echo   Cancelado. Para probar vos mismo, usa un nombre cualquiera:
    echo     Start-Playtest.bat prueba
    echo.
    pause
    exit /b 1
  )
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

"%GODOT%" --path "%~dp0godot" -- --tester=%TESTER% %2 %3

echo.
echo   Sesion terminada. El CSV quedo en:
echo     %APPDATA%\Godot\app_userdata\
echo   (carpeta del proyecto, subcarpeta telemetry)
echo.
echo   Para leer los resultados de los 3 testers:
echo     Report-Playtest.bat
echo.
pause
