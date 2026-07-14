---
status: vivo
updated: 2026-07-13
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
  strike (el clamp es red, no muleta). **Y el margen debe ser REAL
  (≥ ~0.001 rad):** con margen 0.0003 el pico cruza o no según el alineado
  de frames del pose stepping → gate FLAKY (visto 2026-07-10: elbow release
  −0.085 fallaba 1 de ~4 corridas; −0.082 lo estabiliza).
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
- **Geometría de pintura/marcas sobre cuerpos: margen REAL fuera de la
  superficie.** Dos entierros el mismo día (M9-r3): (a) un anillo en el bíceps
  dimensionado al radio del mesh queda DENTRO del brazo — `_apply_build`
  escala las extremidades ×1.12–1.42 por peso y el anillo no (dimensionar
  contra el radio EFECTIVO máximo); (b) una placa al ras de la elipse del
  cráneo asoma ~1 mm y la tinta Sobel se la come — centrar la pieza ~8 mm
  FUERA de la superficie con profundidad hacia adentro. Diagnóstico útil:
  `find_child` + global_position (el nodo existía, visible, en su lugar — el
  problema era oclusión, no lógica).
- **Asserts adversariales de clamp: re-forzar la violación VARIOS frames.**
  Si un frame tarda >0.125 s (hitch de compilación de shaders al boot), el
  settle del idle satura su lerp (factor 1.0) y devuelve el hueso a territorio
  legal ANTES del pase de constraints → no se registra nada → gate flaky
  (autotest_biomech 2/3 fallos). Forzar en loop (~6 frames): los frames HELD
  del pose stepping no corren el settle y el clamp ve la violación cruda.
- **Pelo low-poly sobre un cráneo esférico: las CAJAS no pueden abrazarlo**
  (o hacen tablones flotantes o se entierran) **y una esfera-casquete siempre
  lee casco/hongo** (borde-repisa de 360°). La construcción correcta es una
  CONCHA elipsoide AJUSTADA que se auto-recorta contra el cráneo: dimensionar
  sus semiejes para emerger ~7 mm donde hay pelo (parietales/coronilla/
  occipucio) y hundirse bajo la superficie donde hay piel (orejas, nuca baja)
  — la línea del pelo sube sola en las sienes (fade) y el borde es la
  intersección de las dos superficies, no una repisa. Los acentos angulares
  (quiff/cresta) van como cajas HUNDIDAS en la concha.
- **El mapeo v del atlas de la cabeza se comprime NO-linealmente hacia la
  ceja** (esfera: v lineal en latitud, la cara vive cerca del ecuador): franjas
  de FRENTE por textura no son posicionables con confianza — van como
  geometría. La cara vive en la costura u=0 del atlas (el centro de la textura
  es la NUCA); los patrones 1–5 históricos pintaban la nuca y solo se veían por
  el embarrado de los UV de caja del jaw (retirado en M9-r2b). `_build_origin_features` tenía ironblooded como else → cualquier
  origin desconocido (ej. el origin neutro del banco de anatomía) montaba la
  armadura de forja + heat glow fantasma. Un id fuera del canon debe degradar a
  NEUTRO (cuerpo desnudo), no al último caso que alguien escribió.
- **Las "cabezas" del canon anatómico se miden suelo→CORONILLA del cráneo.** El
  AABB del rig incluye el pelo (~+0.07 m) e infla el conteo (+0.3 cabezas). El
  banco (`tmp_anatomy.gd`) reporta ambos números; el gate es contra la coronilla.
- **Geometría en frame local: el contrato de ejes entre el generador y el
  consumidor debe estar ALINEADO (y documentado en ambos).** El bug M10-r4:
  `_s_spine` generaba la espina del mechón con Y NEGATIVA (convención
  "cuelga hacia abajo") mientras `_ribbon` mapeaba la espina sobre
  `mbasis.y` = flow root→tip — resultado: los 21 mechones crecían en
  dirección OPUESTA a su flow autorado (las capas de caída apuntaban al
  cielo como astas). Ni la revisión estática de loops/NaN lo detectó: el
  código era "correcto" línea a línea; el defecto vivía en la COSTURA entre
  helpers. Detección: solo VISUAL (el banco desbloqueado lo mostró al
  primer frame). Regla: al escribir un par generador/consumidor de puntos
  en frame local, escribir el contrato de ejes en el docstring de AMBOS y
  verificar UNA construcción end-to-end en captura antes de autorar 20 más
  encima.
- **Ante conflicto entre una review del director y la LÁMINA, auditar contra
  la lámina.** (2026-07-13, hombros que no convencían tras 2 rondas.) La review
  v0.1 pidió hombros "+10-15% más anchos"; se aplicó (+12%) y quedó FOSILIZADO
  en `SHOULDER_X`. Pero la lámina dice "narrow sloped shoulders" (biacromial
  ~2.05 cabezas): el render medía +30% de ancho y +13 cm de alto. Dos rondas
  esculpieron el músculo correcto sobre el PIVOTE equivocado — ninguna
  escultura del deltoide podía arreglar un esqueleto mal dimensionado. Un QA
  imparcial dirigido midió lámina↔render en píxeles y dirimió; Boris lo aprobó.
  Regla: cuando un fix estético no cierra tras 2 iteraciones, sospechar del
  ANDAMIAJE (proporción/pivote/posición), no seguir puliendo la superficie; y
  medir contra la lámina, no contra un número heredado de una review previa
  (las reviews pueden contradecir el concept).
- **Músculo/pelo estilizado = MASAS de silueta semi-hundidas, NUNCA hebras ni
  cuerdas rectas sobre superficie convexa.** (2026-07-12/13.) El peinado
  príncipe de cintas rectas (cadenas de cajas cayendo desde cerca del polo del
  cráneo) falló ~8 rondas: enterrado/antena/starburst — porque una cuerda recta
  larga que parte cerca de un polo convexo se reentierra sin importar el offset
  ni la dirección. Se DESECHÓ. El patrón que SÍ funciona (probado en gemelo,
  bíceps/tríceps, pecs): elipsoide escalada SEMI-HUNDIDA en el volumen
  anfitrión (protrusión ≤30%), el escalón del cel-shading lee el volumen y el
  Sobel entinta solo el contorno. El bulto se lee de FRENTE por el
  ensanchamiento lateral (X), no por el sesgo frontal (Z). Corolario: "aplastar"
  un músculo = bajar los ejes radiales X/Z dejando el eje Y (largo) y la
  posición intactos (feedback del director sobre los brazos).
- **Una ESFERA nunca da un plano/borde anguloso bajo el toon+Sobel de este
  proyecto — usar CAJA.** Confirmado 3 veces independientes durante el ajuste
  fino de la Fase C cara (2026-07-14, loop QA↔código): mentón cuadrado,
  pómulo como plano malar, y el primer intento de barba en bloque, los tres
  leían "bola/cachete/bulto negro" con una esfera (por chica o aplastada que
  fuera — la curvatura continua en todas direcciones cae en la banda oscura
  de la rampa toon) y se resolvieron al cambiar a una caja (caras planas =
  el cel-step lee un escalón de tono real, no una autosombra redonda). Si la
  lámina muestra un plano o borde definido (pómulo, mentón, mandíbula), la
  primitiva correcta es caja, no esfera — reservar la esfera para masas
  genuinamente redondeadas (mejilla llena, articulaciones).
- **Un "escalón" de profundidad entre dos masas solo existe si sus CARAS
  FRONTALES terminan en Z distinto — no alcanza con mover el centro o el
  radio sin verificarlo.** Bug real de 4 rondas de ajuste de labios (Fase C,
  2026-07-14): con radios distintos (0.007 vs 0.011) y un offset de centro
  que "parecía" dar un escalón, las caras FRONTALES de ambos labios
  terminaban exactamente en el mismo Z — cero discontinuidad real, por eso
  un cambio de tono de material (ronda 4) no tuvo nada con qué interactuar.
  Antes de dar un escalón por bueno, calcular `posición_z + radio` (la cara
  frontal real) de cada masa y confirmar que difieren — no confiar en que
  los números de posición/radio "se ven distintos".
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
- **NUNCA editar archivos de texto del repo con Get-Content/Set-Content de
  PowerShell 5.1:** sin BOM, lee UTF-8 como ANSI y al re-escribir
  DOBLE-CODIFICA (mojibake en todos los acentos — le pasó al LOG el
  2026-07-11; restaurado de git). Las ediciones van con las herramientas de
  archivo del agente (Edit/Write), que preservan encoding.
- **Extraer zips en rutas profundas de esta máquina (scratchpad/OneDrive)
  revienta MAX_PATH** (~260): `Expand-Archive` falla con zips de árboles
  hondos. Workaround probado (2026-07-11): mapear unidad temporal
  `subst P: <ruta>` → extraer en `P:\` → `subst P: /D`. Los archivos quedan
  en la ruta original.
- **Cuelgues/lentitud extrema en corridas limpias (2026-07-10; CONFIRMADO
  2026-07-12):** con la laptop cargada de apps de fondo (Epic Games Launcher,
  EA Desktop, Xbox App — ~9 GB RAM fuera de Godot), tanto `tmp_anatomy.gd`
  (windowed) como `test_core.gd` (`--headless`) se colgaron 3+ veces seguidas
  con procesos recién lanzados y limpios (sin proceso huérfano previo —
  verificado con `tasklist`/`taskkill //T`). El proceso consumía CPU real (no
  un deadlock: ver CPU-time creciente vía `Get-Process -Id X | Select CPU`),
  pero nunca llegaba a imprimir salida. **Cierre del diagnóstico (2026-07-12):
  matando Epic/EA/Steam (con `taskkill /IM x.exe /F /T` proceso por proceso —
  `Stop-Process` en lote aborta en el primer servicio protegido), los MISMOS
  tests corrieron al instante: `tmp_anatomy` 7 s, `test_core` 0.4 s ALL_PASS.
  Era contención de recursos, NO bug del código.** Protocolo: cerrar las apps
  de fondo ANTES de cualquier corrida y de cualquier sesión de debug — una
  hora de bisección de código no vale lo que 30 s de `taskkill`.

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
