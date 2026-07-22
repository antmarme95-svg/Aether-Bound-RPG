---
status: vivo
updated: 2026-07-22
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
- **Buscar un nodo por "el último hijo" (`get_child(count-1)`) es un hack que
  se rompe SOLO cuando otro sistema agrega un hijo más tarde — no en el
  momento en que se escribe.** El pauldron (`character_rig.gd`) se ubicaba así
  desde hacía mucho, y funcionaba, hasta que las venas de mana (`vein_defs`,
  agregadas DESPUÉS del pauldron en `_build()`) empezaron a parentear una vena
  al mismo nodo (`arms[1]`) — el "último hijo" pasó a ser la vena, no el
  pauldron, y quedó VISIBLE por accidente en todos los renders (2026-07-14,
  bug de producción real, no solo de banco de pruebas: `_apply_build()`
  también lo usaba para el escalado de Vanguard). Nombrar el nodo
  (`.name = "..."`) y buscar por `find_child()` es un costo fijo mínimo que
  evita esta clase entera de bug silencioso.
- **Una asignación de rotación/posición hecha UNA VEZ en `_build()` se puede
  borrar sola si existe un sistema de "settle"/"follow" que corre cada frame
  y hace `lerp` hacia un target que no la incluye.** Al agregar una curva
  dorsal estática (`upper_spine.rotation.x`) para el perfil "en tabla"
  (PRD Rework Fenotipo pt.13), la asignación directa en `_build()` se hubiera
  borrado en <150ms de idle real — el "follow del torácico fuera del strike"
  (`character_rig.gd`, corre todo frame que no sea strike) hace `lerp` de
  `upper_spine.rotation.x` hacia `spine.rotation.x * 0.30`, sin ningún término
  que preserve un offset estático. Fix: sumar el offset al TARGET del lerp,
  no asignarlo aparte. Antes de asumir que "poner el valor en `_build()`
  alcanza", rastrear si algo en `_process()` escribe esa misma propiedad cada
  frame.
- **Un array de datos usado por dos sistemas (UI-facing vs. técnico/atlas)
  puede tener longitudes distintas — verificar AMBOS antes de declarar un
  índice "inválido".** `PhenotypeData.WARPAINTS` (para la UI) llegaba hasta
  el índice 5; `warpaint_atlas.gd` reconoce un índice 6 ("Scout Marks") que
  el propio atlas deja VACÍO A PROPÓSITO (su marca vive como geometría en
  `character_rig._face_mark`, documentado en el código desde M9-r4). El PRD
  Rework Fenotipo (2026-07-14) dio ese 6 por "índice inválido" y lo cambió a
  un valor 1-5 — eso pintó un patrón LEGACY encima de la geometría nueva,
  detectado recién al renderizar. Antes de "corregir" un índice que parece
  fuera de rango, grep el símbolo en TODO el código, no solo en el array más
  a mano.
- **Ante un QA imparcial que describe una forma en TEXTO (no solo un
  veredicto de %), verificar la lámina en pixeles antes de implementar esa
  descripción como spec.** El primer QA de warpaint (ronda 32%) transcribió
  "dos trazos verticales... ceja/sien izquierda" y esa descripción se
  implementó literal — recién al mirar `fenotipo-humano-torso-v1.png`
  directamente (2026-07-14, sin intermediario) se confirmó que el patrón
  real es una "V" bilateral diagonal, no 2 trazos de un lado. Mismo
  principio que "ante conflicto con una review, auditar contra la lámina"
  (arriba), extendido: un QA de IA parafraseando una imagen es UNA capa de
  traducción con pérdida, igual que una review humana — para geometría/forma
  específica, mirar el píxel gana.

- **Para encontrar QUÉ primitiva causa un defecto visual, marcar con color
  diagnóstico (`material_override` a un color imposible de confundir —
  magenta/rojo/verde/azul), NO alternar `visible=false` una pieza a la
  vez.** Caso real (2026-07-16): un "bloque rectangular tipo cuello de
  camisa sin soldar" en `anatomy_face_34.png` (vista 3/4) se investigó
  ocultando, una por una, 8 piezas candidatas (torso, cuello, trapecio,
  clavícula ×2, acromion, pauldron, pec, deltoide) — el render salió
  PIXEL-IDÉNTICO las 8 veces, generando sospecha de que los cambios de
  código no se estaban aplicando (llegó a verificarse timestamp de
  archivo y hasta forzar un color magenta en el torso solo para confirmar
  que si SÍ recargaba). El método de ocultar no distingue "esta pieza no
  es la culpable" de "mi cambio no se aplicó" — un color imposible de
  confundir sí lo hace, sin ambigüedad, en un solo render. Cambiar a
  colorear en vez de ocultar identificó la pieza real (`chin_boss`) al
  primer intento.
- **Una pieza validada SOLO contra la vista de FRENTE puede fallar en
  otros ángulos del turnaround (3/4, perfil) sin que nadie lo note hasta
  que un QA mira esas capturas específicas.** `chin_boss` (el mentón)
  tiene 6+ rondas de calibración documentadas, todas contra la lámina de
  frente — nunca se verificó en 3/4. Ahí se lee desconectado de la
  mandíbula (Sobel entinta un borde completo alrededor, como si fuera una
  pieza suelta) pese a que el overlap 3D calculado dice que debería
  fusionar. Regla: cualquier pieza con bordes duros (`_box_mesh`)
  solapada contra un volumen redondeado (`_sphere_mesh`/`_cylinder_mesh`)
  debe revisarse en las 4 vistas del turnaround (frente/3-4/perfil/
  espalda), no solo la que ya se validó — el ángulo cambia qué overlap
  es "suficiente" para que el Sobel no dibuje una costura.
- **Cuando 2-3 intentos razonados de ajustar overlap (profundidad, alto/Y)
  no cierran una desconexión visual pese a que el cálculo de solape 3D
  dice que debería funcionar, PARAR y documentar — no seguir iterando a
  ciegas sobre una pieza con historial de calibración pesado.** Puede ser
  que el defecto real sea de LECTURA DE SILUETA/SOBEL en ese ángulo
  específico (cómo se proyecta el corte transversal de una caja contra
  una esfera desde esa cámara), no de overlap puro medido en el espacio
  3D del objeto — seguir moviendo números sin una hipótesis nueva quema
  presupuesto sin converger (mismo espíritu que "sospechar del andamiaje
  tras 2 iteraciones", pero aquí el andamiaje en sí no cambió — es la
  cámara/ángulo la variable no probada).
- **El rig NO fabrica outline por-pieza — `_add_outline_pass` es un no-op
  a propósito (decisión del director 2026-07-10, documentada en el header
  de `character_rig.gd`).** La tinta la pone un ÚNICO Sobel de profundidad
  full-screen (`melancolia_post.gdshader`), muy sensible (tinta cualquier
  salto de profundidad de pocos mm entre píxeles vecinos, a la distancia
  de cámara típica del banco). Consecuencia práctica: cualquier "costura"
  o "pieza que se ve suelta" es SIEMPRE un hueco/salto 3D real entre
  masas, nunca un artefacto de outline-por-objeto — no perder tiempo
  buscando causas de shader/render, ir directo a la geometría.
- **Antes de dar un hallazgo geométrico por CERRADO, hacer zoom (recortar
  y ampliar 3-4x) a la unión exacta — el render completo a resolución de
  banco (1280×720) puede camuflar un hueco real.** Caso real (2026-07-17,
  cierre del CRITICAL `chin_boss`↔`neck`): un primer fix se verificó
  mirando `anatomy_face_34.png`/`anatomy_face.png` completas y parecía
  cerrado — un QA imparcial (con las mismas 4 capturas, sin zoom manual)
  lo marcó NO CERRADO con precisión; recién al recortar y ampliar la zona
  mentón/cuello con `System.Drawing` (PowerShell: `Bitmap.Clone(rect)` +
  `Graphics.DrawImage` con `InterpolationMode.NearestNeighbor` para no
  perder los bordes duros del toon) se vio el bloque real que el ojo
  pasaba por alto a tamaño natural. Regla: un veredicto "se ve bien" sobre
  el render completo NO alcanza para cerrar un hallazgo de fusión
  geométrica — zoom a la unión específica primero, en cada vista relevante.
- **Un salto de profundidad entre dos masas puede existir DENTRO del rango
  de overlap "correcto" en un eje (Y) pero estar fuera en el eje que no se
  está mirando (Z / profundidad hacia cámara) — sobre todo entre piezas
  con jerarquías de padre distintas.** `chin_boss` (hijo de `head`, que
  escala ×0.84) y `neck` (cilindro fijo, hijo directo de `upper_spine`) SÍ
  se solapaban en rango Y, pero el mentón, al ser un rasgo que sobresale
  hacia adelante (Z), no tenía nada que continuara ese saliente hasta la
  superficie — más lisa, menos profunda — del cuello: un salto real de
  varios cm en Z, no en Y, invisible al razonar solo en términos de "¿se
  tocan verticalmente?". Antes de dar una fusión por buena entre piezas de
  padres distintos, verificar el solape en LOS 3 EJES, no solo el que
  parece relevante a simple vista.
- **Bajo el Sobel de profundidad, lo que entinta el perímetro de un rasgo
  no es su protrusión total sino la PENDIENTE de sus paredes: pared
  empinada (perpendicular a cámara) = salto de profundidad grande entre
  píxeles vecinos = contorno entintado completo; rampa gradual = el mismo
  volumen SIN contorno.** (2026-07-17, R1 rostro.) A distancia de banco
  el post entinta saltos de ~6mm+ por píxel. Por eso los músculos del
  cuerpo (elipsoides semi-hundidas, pendientes suaves) nunca se
  entintaron pero TODA pieza facial montada con paredes (caja de pómulo
  tangente, cápsula de boca, prisma de nariz) recibía perímetro de tinta
  y leía "calcomanía". Fix probado (pómulos): ACOSTAR la pieza sobre la
  normal local de la superficie anfitriona (yaw/pitch alineado) y bajar
  su profundidad — emerge en rampa y el cel-step la lee sin que el Sobel
  la recorte. Corolario 1: la silueta de la CABEZA contra el fondo sí se
  entinta siempre (salto de metros) — diseñar la silueta con la
  estructura (mandíbula de cajas) es gratis en tinta. Corolario 2: dos
  primitivas que se INTERPENETRAN comparten profundidad continua en la
  curva de intersección — un arco facetado de cajas solapadas no dibuja
  costuras entre facets si el ángulo entre ellos es chico. Corolario 3:
  el key offset de 15° de la cámara del banco hace que fixes de
  pendiente calibrados "de frente" queden asimétricos — verificar ambos
  lados.
- **El % de fidelidad de un QA-LLM solo es comparable DENTRO del mismo
  hilo de agente — nunca entre agentes distintos.** (2026-07-17.) Al
  expirar los hilos de los QA de fase, agentes frescos re-midieron el
  MISMO estado: rostro 48% donde el hilo de fase había dado 57%, torso
  38% donde había dado 55% — y con veredictos opuestos sobre la misma
  vista (espalda: "el salto más grande de la ronda" vs "desastre de
  malvavisco"). Varianza entre jueces: ±10-17 puntos. Además un juez
  fresco no distingue tinta Sobel de banda oscura del cel-shading (llamó
  "banda negra de tinta" a una sombra de quantización). Reglas: (a) los
  deltas ronda-a-ronda valen solo dentro del mismo agente (por eso el QA
  Loop pide re-invocar al MISMO, fase 4 — si el hilo expiró, anotar el
  quiebre de serie y arrancar rango nuevo); (b) ante contradicción entre
  jueces, el orquestador arbitra mirando el PIXEL él mismo antes de
  escribir nada al Vault; (c) el número informa, el VoBo del director
  cierra (fase 7) — no perseguir un % absoluto entre jueces distintos.
- **La regla de tinta vive en UN número: `edge_threshold` de
  `melancolia_post.gdshader` (0.30→1.00, 2026-07-17, VoBo con A/B).**
  A 0.30 el Sobel entintaba saltos >6mm de cerca (cada frontera interior
  entre masas del rig = contorno propio = lectura "collage/maniquí" —
  el techo común que declararon los QA de rostro Y torso). A 1.00
  entinta solo >~2cm: silueta, pliegues hondos y follaje sobreviven;
  las costuras interiores mueren. Corolario: si una masa nueva necesita
  leerse, debe hacerlo por SILUETA o por cel-step — ya no puede apoyarse
  en que el Sobel le dibuje el borde (diseñar pendientes con eso en
  mente). A/B 1.60 descartado: nada extra en el cuerpo, más erosión de
  follaje.
- **Un pellizco de cintura correcto en la MALLA puede seguir sin leerse si
  el brazo cuelga pegado al torso a tasa fija.** (2026-07-21, frente
  hombro/cintura.) `waist` tapera de verdad (top→bottom radius), pero el
  brazo (`arm.rotation.z` fijo, decisión anti-gorila 2026-07-13: "roza el
  torso todo el trayecto") lo hace a una tasa CONSTANTE mientras el torso
  se angosta más abajo — el ANCHO COMBINADO brazo+torso a esa altura lo
  fija el brazo, no el torso, así que ningún ajuste del radio de cintura
  se ve mientras el brazo siga tapando ese borde. Diagnóstico: colorear
  torso/waist/pelvis con `material_override` + OCULTAR los brazos (nuevo
  `DIAG_TORSO=1` en `tmp_anatomy.gd`, mismo patrón que `DIAG_AXIS`)
  confirmó que el pellizco SÍ existía antes de tocar nada. Fix: profundizar
  el radio de cintura lo suficiente para que gane margen real contra el
  brazo (no solo contra el fondo/pelvis) — verificado por un hueco de
  fondo visible entre brazo interior y cintura en el render con brazos
  puestos. Regla: ante una masa que "no se angosta" pese a que su propio
  mesh sí tapera, sospechar de un vecino con posición/rotación FIJA
  (brazo, correa, prop) que dibuja el borde exterior real de la silueta a
  esa altura — diagnosticar ocultando ese vecino antes de re-esculpir la
  masa misma.
- **Una curva delgada con perfil de radio decreciente (loft/ribbon) puede
  leer PEOR que un cono/cápsula simple para un rasgo CHICO y CORTO, aunque
  la técnica de curva sea la correcta "en teoría" para la silueta que se
  busca.** (2026-07-22, oreja de elfo.) Un QA imparcial pidió una silueta
  de "hoja compuesta" (borde recto + cóncavo + flick de punta) para
  reemplazar un cono de taper lineal que ya medía 60-65%. Se probó
  `HairLibrary._loft`/`_lock` (curva Catmull-Rom + perfil de radios, la
  técnica vigente y correcta para mechones de pelo) — 3 rondas con QA de
  por medio, cada una peor que la anterior (40% → 45% → 45-50%, todas
  por debajo del cono). Causa diagnosticada por el propio QA: a la
  distancia de cámara del banco, un perfil de radio que cae rápido deja
  el 70-80% del cuerpo de la pieza como "alambre sin volumen", y una
  curva concentrada en el tramo final lee como gancho/garfio, no como
  remate suave — el cono simple, aunque genérico, comunica la FORMA
  base (triángulo que se angosta) de manera más inequívoca que una curva
  compuesta a esta escala. Se revirtió al cono. Regla: una técnica de
  curva/loft que funciona bien para pelo (mechones largos, MUCHOS puntos
  de control, radio que se mantiene grueso buen trecho) no se transfiere
  automáticamente a un rasgo corto y chico — si el primer intento con la
  técnica nueva mide peor que el baseline, no seguir puliendo parámetros
  de la misma técnica más de 1 ronda extra de corrección dirigida por
  QA; si la 2ª ronda tampoco supera el baseline, es señal real de que la
  técnica no encaja en esta escala (no un problema de calibración), y
  toca revertir y documentar, no seguir iterando (mismo espíritu que
  "sospechar del andamiaje tras 2-3 intentos").
- **IK analítica de 2 huesos sin Skeleton3D: si dos rotaciones consecutivas
  de la cadena giran sobre el MISMO eje local fijo (aquí, X: cadera→rodilla
  del rig `Node3D` procedural), sus ángulos se SUMAN — un solo `acos` da el
  ángulo TOTAL de la cadena para alcanzar una altura de mundo, sin
  necesitar Jacobianos ni iterar.** (2026-07-21, C4 foot IK.) Con
  `down.rotated(X, θ).y == -cos(θ)` (rotación estándar mano derecha) y dos
  segmentos iguales `L`: `hip_y - L·cos(hip_flex) - L·cos(hip_flex+knee) =
  target_y` se despeja directo (`knee = acos(...) - hip_flex`), preservando
  el ángulo de cadera YA autorado por el gait (la IK es una capa correctiva
  ENCIMA, no lo reemplaza — mismo principio que el foot IK de HZD sobre
  mocap, [[Benchmark Biomecánico]]). Corolario de andamiaje: si un joint
  nuevo (aquí, tobillo) no EXISTE en la jerarquía, ninguna cantidad de IK
  en los joints vecinos puede fingirlo — antes de resolver la cinemática,
  verificar que el nodo que necesita rotar de verdad tiene su propio pivote
  (la bota colgaba rígida del `knee`, sin `ankle` propio).
- **El límite de gasto de Claude puede ser una ventana de 5 horas, no
  mensual/semanal** — un subagente que falla por "spend limit" puede
  volver a funcionar poco después con el MISMO prompt; no asumir que hay
  que esperar hasta el próximo mes ni cambiar de enfoque solo por ese
  error.

## Entorno

- **Python 3.12 instalado vía winget** (2026-07-20:
  `winget install --id Python.Python.3.12`) en
  `%LOCALAPPDATA%\Programs\Python\Python312\python.exe`. El alias
  `python`/`python3`/`py` seguía resolviendo al stub roto de Microsoft
  Store (`%LOCALAPPDATA%\Microsoft\WindowsApps\`, "Python was not found")
  en terminales YA ABIERTAS antes de instalar — el PATH de máquina/usuario
  se actualiza al instalar, pero una sesión de shell existente no lo
  relee. Si `python`/`python3` fallan así después de instalar: abre una
  terminal NUEVA, o usa la ruta completa de arriba directamente. Afecta a
  `Aether Bound/scripts/check_vault.py` (auditoría de peso de arranque,
  SCHEMA §8) — con Python real, el script corre en Windows sin más ajuste
  salvo forzar UTF-8 en `sys.stdout` (la consola de Windows no siempre usa
  UTF-8 por defecto; sin eso, los acentos salen como `�`).
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
- **Una propuesta RATIFICADA no está ejecutada solo porque quedó escrita.**
  [[Propuesta-Recursos-de-Modelado]] (5 recursos, ratificada 2026-07-12)
  se asumió "en curso" durante 4 días de sesiones de rework de geometría
  (pelo llegó a un 3er intento con cajas/conos) hasta que una verificación
  de campo (grep directo sobre `character_rig.gd`/`toon_ramp.tres`,
  2026-07-16) confirmó que NINGUNO de los 5 recursos se había tocado en
  código. Antes de seguir iterando con la MISMA técnica que ya falló 2+
  veces en el mismo problema, grep el código para confirmar si existe ya
  una solución ratificada sin ejecutar — no confiar en la memoria de
  sesión de que "eso ya se resolvió" o "ya está en curso". Ver
  [[Catálogo Técnico Godot]] para el estado verificado de recursos
  pendientes.

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
