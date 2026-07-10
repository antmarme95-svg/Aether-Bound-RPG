---
status: vivo
updated: 2026-07-08
---

# Lecciones y entorno técnico

> Conocimiento operativo duro, ganado en los sprints del prototipo. Aplicar a
> todo brief de ejecutor (Feature Loop).

## Lecciones (no repetir)

- **Nunca usar `class_name` cruzado entre scripts** en Godot — race de
  load-order en CLI. Siempre `const _X = preload("res://…")`.
- **El toon del prototipo (`toon.gdshader`) escribe `ALPHA`** → manda TODO al
  pase transparente → invisible para `hint_screen_texture` (los post-process
  lo "borran"). Para escenas con post screen-space usar `toon_golden.gdshader`
  (opaco) o variantes sin escritura de ALPHA.
- **Quads de post fullscreen** (POSITION override) deben escribir `ALPHA=1.0`
  para caer en el pase transparente y muestrear el pase opaco COMPLETO del
  frame actual (si no, feedback lavado del frame anterior).
- **GDScript: `abs()`/`min()`/`max()` devuelven Variant** — rompen inferencia
  `:=`. Usar `absf/mini/maxf...` o tipar la variable.
- **Texturas cargadas en runtime por CLI:** `Image.load_from_file()` +
  `ImageTexture.create_from_image()` — `load("res://*.png")` depende del
  import del editor y falla en corridas CLI sin `.import`.
- **`gh` NO está autenticado en esta máquina** — los "PR" se cierran con
  `git merge --no-ff` local a master con mensaje estilo PR (topología
  equivalente). No intentar `gh pr create`.
- **Patrón para correr autotests desde el agente:** PowerShell
  `Start-Process -Wait -NoNewWindow` con redirección a logs de `$env:TEMP`, y
  SIEMPRE matar `Godot_v4.6.3*` huérfanos antes de cada corrida.
- **Autotests visuales = windowed-only** y una sola instancia de Godot a la
  vez; matar procesos `Godot*` huérfanos tras cada corrida.
- **`test_core` headless no carga scripts de escena/main** — gatear cambios
  visuales también con `autotest_scenes` + `autotest_slice`.
- **Headless `--script` NO registra autoloads como globals:** hacer
  `preload()` de un script que referencia un singleton por nombre (ej.
  `EventBus`, `Feel`) rompe la compilación en corridas `--headless
  --script` (`Identifier not found: EventBus`). Las regresiones que
  necesiten tocar esos scripts van en una sonda **windowed** (autoloads
  vivos), no en `test_core`/`test_combat` headless.
- **FPS relativo al estado térmico de la GPU** (RTX 2060 laptop: throttle
  warm ~58): tomar el número del gate en corrida fría.
- **Método de review de movimiento:** montage harness
  (`tests/autotest_montage.gd`) → regenerar strips (~20s) → revisar imágenes;
  no live window salvo aceptación final.
- **`git commit -m` en PowerShell 5.1: sin comillas dobles dentro del
  mensaje** — un `"` embebido rompe el parseo hacia git aunque uses
  here-string. Frases sin comillas o varios `-m`.
- **Capturas de fases de animación: al MIDPOINT de la fase**, no al
  entrar — recién entrando la pose apenas arranca y el strip miente.
- **Con pose stepping (2s), gameplay y seguridad corren cada frame:**
  relojes/ventanas de combate y el pase de constraints (otros sistemas
  pueden escribir huesos entre ticks). Solo la POSE se escalona.
- **Follow-through cerca del límite de una bisagra:** el vaivén oscila
  ~35% del release al otro lado — si el target queda pegado al tope del
  ROM (codo: +0.03), reducir el release para que el pico quepa DENTRO.
  `autotest_biomech` exige pose autorada sin violaciones de ROM en el
  strike (el clamp es red, no muleta).
- **A/B de percepción de animación: siempre con zoom de cámara** — a
  distancia default el chop/detalle de extremidades no se lee y parece
  que el toggle no hace nada.
- **Golpear a un enemigo en estado `dying` reinicia su timer de muerte.**
  `receive_strike` vuelve a la rama `health<=0` y pone `state="dying"; state_t=0`
  en CADA golpe, así que un test/AoE que martillea el cadáver lo deja
  agonizando eterno (`dead` nunca flipa a los 0.8 s). En loops de kill
  automatizados y en AoE: dejar de aplicar daño cuando el objetivo ya está
  `dying` (no solo cuando `dead`). Diagnóstico típico: el enemigo llega a
  0 HP rapidísimo pero el loop consume TODO el presupuesto de frames.
- **VFX que se desvanecen: partículas vs. mallas fijas.** Un `GPUParticles3D`
  se apaga solo por su `lifetime` + `color_ramp` (basta liberarlo con un
  `Timer`). Una malla emisiva ESTÁTICA (arco de swing, anillos del pound) NO
  se desvanece sola: necesita un `Tween` sobre el material (additivo →
  `tween_property(mat, "albedo_color", <alpha 0>, dur)`); con solo un `Timer`
  hace pop-and-cut. Patrón cross-entity para habilidades: el emisor manda un
  evento (`springboard:wave`) y el director mantiene el registro + resuelve el
  AoE (tiene `enemies`/escena) — el emisor no necesita ref al director.
- **El slot de un NPC seguidor debe esquivar la cámara over-the-shoulder.**
  La cámara vive sobre el hombro DERECHO (`CAM_SHOULDER` +). Un aliado
  plantado detrás-derecha del jugador queda pegado/clippeado contra el
  lente. Colocarlo al hombro IZQUIERDO (y más al lado que atrás) para que
  se lea en pantalla sin estorbar la cámara.
- **Loops de autotest acotados por FRAMES son dependientes del FPS.** La
  IA/combate corren en `dt` real; un `while frames < N` da tiempo real
  distinto según el FPS (a 900 fps, 1800 frames = 2 s → el heavy no
  alcanza a morir; a 177 fps, los mismos frames = 10 s → sí). Acotar por
  TIEMPO REAL acumulado (`elapsed += get_process_delta_time()`), no por
  conteo de frames. Mismo espíritu que los relojes de feel en usec.
- **Capturas de pose en 2s: dejar pasar un tick de pose (~0.083 s) antes
  del screenshot.** Con `animation_on_twos`, la pose re-evalúa a ~12 Hz y
  HOLDea entre ticks; una captura demasiado pronto tras disparar una pose
  (ej. `play_parry`) atrapa el frame held ANTERIOR y parece que la pose no
  se aplicó. Esperar > POSE_STEP pero dentro de la duración de la pose.
- **FPS dentro de un autotest windowed miente:** el contador es una media
  rodante de 1 s que absorbe el ritmo del propio polling `await
  process_frame` y cualquier thrash del test (ej. martillear cadáveres). Un
  greybox trivial marcó 43–57 durante el bug y 177–196 ya limpio. El gate
  real ≥60 se lee en corrida FRÍA representativa; dentro del autotest usar
  solo un piso CATASTRÓFICO (regresión total), nunca el número del gate.
- **Relojes de tiempo real (autoloads de feel): `Time.get_ticks_usec()`,
  nunca msec** — los autotests corren sin vsync (~300–500 fps); con
  frames < 1 ms el dt en msec da 0 y el reloj no decae (la dilation del
  parry se quedó pegada en 0.2×). Y al medir duraciones en sondas: los
  freezes se cuentan en FRAMES, las duraciones en tiempo real — nunca
  con `get_process_delta_time()` (durante un freeze delta = 0).

- **Un actor con IA autónoma contamina las sondas de OTRA mecánica.** Al sumar
  el pound AUTÓNOMO de Dagna (PRD-007 alcance 3), la sonda del Springboard dirigido
  (`tmp_springboard_directed`) empezó a fallar: Dagna inyectaba una onda
  no-dirigida en `springboard_waves` durante el ramp del test y el lanzamiento la
  agarraba en vez de la onda dirigida inyectada a mano (empuje del arco = 0). Fix:
  la sonda **silencia la IA del actor** (`_ai_pound_cd = 999`) y **limpia el estado
  compartido JUSTO antes** de inyectar el suyo. Regla: cuando un sistema nuevo
  escribe en un array/estado compartido por su cuenta, revisar TODAS las sondas que
  leen ese estado — no solo la del sistema nuevo.
- **"Air control conservado" (ley de leap PRD-005) = conserva/dirige el
  momentum EXISTENTE, no acelera desde cero.** Para lanzar un salto en una
  dirección (Seismic Springboard T1) NO basta con subir `vel_y`: eso da un
  brinco puramente vertical sin steering. Hay que sembrar `_air_vel` con la
  velocidad horizontal actual del jugador y activar `_leaping` — así el path
  aéreo del leap integra `_air_vel` a magnitud completa y lo lerp-ea hacia el
  input (steering escalado por `air_control` del perfil). Corolario de test: un
  probe que mide air control SALTANDO DESDE PARADO mide 0 (no hay inercia que
  cargar) — hay que construir momentum con W en el suelo ~0.4 s antes de saltar
  y medir solo el tramo aéreo. El salto normal desde parado tampoco deriva.
- **Cadenas if/elif por id (origins, clases): la última rama SIEMPRE explícita,
  nunca `else`.** `_build_origin_features` tenía ironblooded como else → cualquier
  origin desconocido (ej. el origin neutro del banco de anatomía) montaba la
  armadura de forja + heat glow fantasma. Un id fuera del canon debe degradar a
  NEUTRO (cuerpo desnudo), no al último caso que alguien escribió.
- **Las "cabezas" del canon anatómico se miden suelo→CORONILLA del cráneo.** El
  AABB del rig incluye el pelo (~+0.07 m) e infla el conteo (+0.3 cabezas). El
  banco (`tmp_anatomy.gd`) reporta ambos números; el gate es contra la coronilla.
- **La altura de un salto es analítica pura: `h = v²/(2·GRAVITY)`.** Con
  `GRAVITY=24`, `SPRINGBOARD_LAUNCH_VEL=17` → 6.02 m (la sonda midió 6.00). El
  salto "normal" NO es `jump_force` crudo: el LSM lo modula por clase (el warrior
  ironblooded `massMult 1.5` deja el salto en ~0.8 m, no ~1.5). Sizear cornisas
  y umbrales de test contra el número MEDIDO, no el `jump_force` nominal.

## Entorno

- **Godot 4.6.3** (no está en PATH):
  `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe`
  (o `Start-Godot.bat`).
- QA lógico: `--headless --path godot --script res://tests/test_core.gd`.
- QA visual: `--path godot -- --autotest=res://tests/autotest_{rig,scenes,slice,ui,golden}.gd`
  → PNG/JSON en `godot/test_out/`.
- Revisión en vivo del look para el director: `Start-GoldenScene.bat` (raíz
  del repo; SPACE=dawn/dusk, F12=captura, ESC=salir).
- Regenerar el asset de follaje si cambia la sprite sheet:
  `--headless --path godot --script res://tools/process_clump.gd`.
- Gate de rendimiento: **≥60 FPS** en The Wilds.

## Tiering de modelos (orquestación)

> Actualizado 2026-07-05: **Opus es el orquestador** (Fable ya no está
> disponible). El Vault es agnóstico de modelo por diseño (VDD): el protocolo
> de sesión —CLAUDE.md → [[Current-State]] → loop → checkpoint— no depende de
> ningún modelo en particular.

| Rol                                    | Modelo                              |
| -------------------------------------- | ----------------------------------- |
| Orchestrator (diseño, gates, merges)   | **Opus/Fable (si está disponible)** |
| Ejecutor primario (lógica/shaders/VFX) | Sonnet (subagente)                  |
| Ejecutor mecánico (JSON/boilerplate)   | Haiku (subagente)                   |
| QA paralelo persistente                | Sonnet (subagente)                  |
