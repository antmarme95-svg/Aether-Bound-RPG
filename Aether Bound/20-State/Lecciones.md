---
status: vivo
updated: 2026-07-04
---

# Lecciones y entorno técnico

> Conocimiento operativo duro, ganado en los sprints del prototipo. Aplicar a
> todo brief de ejecutor (Feature Loop).

## Lecciones (no repetir)

- **Nunca usar `class_name` cruzado entre scripts** en Godot — race de
  load-order en CLI. Siempre `const _X = preload("res://…")`.
- **Autotests visuales = windowed-only** y una sola instancia de Godot a la
  vez; matar procesos `Godot*` huérfanos tras cada corrida.
- **`test_core` headless no carga scripts de escena/main** — gatear cambios
  visuales también con `autotest_scenes` + `autotest_slice`.
- **FPS relativo al estado térmico de la GPU** (RTX 2060 laptop: throttle
  warm ~58): tomar el número del gate en corrida fría.
- **Método de review de movimiento:** montage harness
  (`tests/autotest_montage.gd`) → regenerar strips (~20s) → revisar imágenes;
  no live window salvo aceptación final.

## Entorno

- **Godot 4.6.3** (no está en PATH):
  `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe`
  (o `Start-Godot.bat`).
- QA lógico: `--headless --path godot --script res://tests/test_core.gd`.
- QA visual: `--path godot -- --autotest=res://tests/autotest_{rig,scenes,slice,ui}.gd`
  → PNG/JSON en `godot/test_out/`.
- Gate de rendimiento: **≥60 FPS** en The Wilds.

## Tiering de modelos (orquestación)

| Rol | Modelo |
|---|---|
| Orchestrator (diseño, gates, merges) | Opus/Fable |
| Ejecutor primario (lógica/shaders/VFX) | Sonnet |
| Ejecutor mecánico (JSON/boilerplate) | Haiku |
| QA paralelo persistente | Sonnet |
