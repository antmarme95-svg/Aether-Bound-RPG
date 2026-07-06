# LOG — bitácora append-only del Vault

## [2026-07-06] playtest | Articulación #2: follow-through por segmento en el settle
Feedback del director: el melee lee "como legos/playmobil". Diagnóstico
compartido: parte etapa (mesh de bloques, sin secundario), parte deuda
(segmentos que frenan en seco, poca superposición, columna monobloque).
El director ordenó la ronda #2 (follow-through): el settle del strike es
ahora un coseno amortiguado por segmento — undershoot pico ~−10% del
release, lo distal ondula más y decae más lento (whip/decay/freq escalan
con el lag de cadena). Pendientes de su orden: #1 (abrir CHAIN_LAG) y
#3 (columna 2–3 segmentos, adelanto de C4). QA: test_combat, biomech y
slice ALL_PASS.

## [2026-07-06] playtest | Fix: el melee vivo no mostraba el strike biomecánico
Feedback del director ("no lo siento tan melee") destapó dos cosas: (1)
`play_strike` (hip-first + curvas del alcance 1) solo lo llamaban los
autotests — el juego vivo animaba el envelope legacy de 0.38 s; puenteado:
el path melee de `try_attack` ahora anima con `play_strike(0.55)`, daño
legacy intacto (anti-objetivo). (2) El boot `--skip=wilds` sin `--cls`
hereda la clase de la pantalla de creación — para probar melee hay que
bootear warrior (`--origin=ironblooded --cls=warrior --skip=wilds`).
QA: test_core y slice ALL_PASS. Commit 59ec800.

## [2026-07-06] feature | PRD-006 alcance 1: arquitectura de combate + curvas trifásicas
Branch `feat/prd-006-a1`. (1) `godot/combat/`: HitPayload (4 campos canon
+ MarkMultiplier fijo 1.0), CombatComponent (combos con ventanas ancladas
a las fases biomecánicas — buffer generoso acepta desde active, encadena
al cerrar recovery, windup cancelable; momentum = masa × velocidad al
conectar), GuardComponent (Equilibrio nace de la masa §B.3; flinch →
stagger → posture break; parry Roba §B.4: roba Equilibrio + desarma),
EnergyComponent (Aether placeholder), PushPullComponent (§B.2: un solo
sistema físico — impulsos con decay, techo de sanidad; PRD-007 lo
reutiliza). Datos: `data/weapons.json` (duelist_blade ×4, unarmed,
gloom_claws, heavy_maul). Instanciados en jugador Y bestia, NEUTROS
(anti-objetivo: el combate viejo intacto, autotest_slice verde). (2)
Curvas v2 del strike en `rig_biomech.segment_offset` ([[Benchmark
Biomecánico]] acción #2): coil con moving hold, release back-out con
overshoot, settle con rebote; fracciones de fase (= ventanas) intactas.
QA: test_combat NUEVO 41/41 ALL_PASS; test_core, biomech, scenes, slice
todos verdes. Next: alcance 2 (kit Duelist jugable sobre los componentes).

## [2026-07-06] playtest | A/B CERRADO: canon = 2s solo extremidades, cuerpo suave
Veredicto del director tras 3 rondas de body pop (completo → moving hold
→ 24 Hz jerárquico): ninguna variante paga su costo; "pop en extremidades
es mucho mejor". CANON: stepping en 2s (12 Hz) SOLO en extremidades;
cuerpo/raíz suaves a 60. `body_pop_on_twos` queda default OFF con el
mecanismo completo implementado (3 variantes probadas y commiteadas) por
si el alcance 1 con poses extremas reabre la pregunta. Tecla T conserva
el ciclo de 3 modos. Lección de método: el A/B de percepción necesita
zoom de cámara — a distancia default el chop de extremidades no se lee.

## [2026-07-06] playtest | Body pop ronda 3: timing jerárquico — cuerpo a 24 Hz
Feedback del director sobre la ronda 2: "solo extremidades es mucho mejor;
¿y si el cuerpo va a 24 Hz?". Implementado: reloj propio del body pop a
24 Hz (BODY_POP_STEP 1/24) — el cuerpo re-ancla el doble de rápido que la
pose (12 Hz); caps de la ronda 2 quedan como red anti-lag. Es timing
JERÁRQUICO à la Spider-Verse/Xrd (mezcla de 1s y 2s): la masa corre fina,
el ritmo cómic vive en las extremidades. Toast actualizado. QA: test_core,
biomech y slice ALL_PASS. Pendiente: veredicto de la ronda 3 (si 24 Hz
converge visualmente a "solo extremidades", ese es el veredicto gratis).

## [2026-07-06] playtest | Body pop ronda 2: moving hold (feedback: "se siente con lag")
El pop puro trailing-completo (hasta ~0.5 m en sprint) se percibía como
input lag. Corregido con MOVING HOLD: el offset del hold se capea a 0.15 m
(≈25 ms percibidos en sprint) y el yaw a ~11°; el anchor se arrastra con
el cuerpo para no acumular excedente entre ticks. El pop queda como chop
constante de textura, no como retraso. Era el plan B ya documentado en
[[Benchmark Biomecánico]] (moving holds, técnica stop-motion/Xrd). QA:
test_core, biomech y slice ALL_PASS. Pendiente: veredicto del director
sobre la ronda 2.

## [2026-07-06] playtest | A/B resuelto: 12 Hz CANON + body pop implementado
El director vio la diferencia (con zoom de cámara; las sondas confirmaron
antes que el stepping funcionaba end-to-end — el enmascarador era la raíz
continua). Decisiones: (1) **EN 2s / 12 Hz queda como canon** del rig;
(2) **body pop implementado YA**: el mesh visible holdea X/Z + yaw entre
ticks (estilo Sable, `body_pop_on_twos`, snap-guard 1.5 m; el eje Y del
body queda para crouch/slide; raíz/gameplay siempre continua); (3) la
página [[Benchmark Biomecánico]] sigue `propuesto` hasta ver el alcance 1
(poses extremas). Tecla T ahora cicla 3 modos: 2s+pop → solo extremidades
→ suave. QA: test_core, biomech, rig y slice ALL_PASS; tira A/B regenerada
muestra el pop (~0.5 m de hold en sprint). Sondas tmp_* quedan hasta el
cierre del alcance 1.

## [2026-07-06] playtest | A/B en vivo del stepping en 2s: tecla T in-game
Preparado el A/B que pedía [[Benchmark Biomecánico]] v1: tecla **T** en el
juego alterna `animation_on_twos` en caliente (toast en HUD: "EN 2s
(12 Hz)" vs "suave (60 fps)"); boot directo a WILDS con `--skip=wilds`.
QA: test_core ALL_PASS, autotest_scenes ok, autotest_slice ALL_PASS.
Sesión en vivo lanzada para el director. Pendiente: veredicto del director
(ratifica la página v1+v2 o pide ajustes — moving holds es el plan B si el
stepping puro se siente muerto).

## [2026-07-06] design | B14 cerrada: benchmark v2 AAA — el AAA valida el camino, no lo cambia
Research de los 5 títulos encargados, volcado en [[Benchmark Biomecánico]]
§v2 (sigue propuesto; se ratifica junto con la v1). Hallazgo estructural:
el AAA se divide en dos familias. (A) Data-driven / motion matching (AC,
For Honor, 007 First Light con Glacier Next): descartada sin ambigüedad —
el combustible es una base masiva de mocap que no tenemos ni queremos;
rescatables solo los conceptos (dial responsividad↔fidelidad, motion
warping — que nuestro hip drive ya hace procedural). (B) Autorada + capas:
NUESTRO camino, validado. Sifu es el benchmark real: combate ~100% handkey,
estructura trifásica build-up/impacto/release (= nuestras curvas del
alcance 1), legibilidad por silueta + timing manipulado + ralentización
deliberada; su costo es iteración (docenas de rondas por ataque, 2→15
animadores) — para 1+LLM: presupuestar MUCHO feedback del director, las
curvas iteran barato. HZD aporta foot IK con anotación de contacto (→ C4,
Godot lo trae) y el checklist de estados de locomoción. Jedi FO (physical
animation) queda como versión procedural barata en Fase 4, respetando la
regla del stepping. Conclusión: la pila de 4 capas de la v1 queda
ratificada como arquitectura; PRD-006 alcance 1 es el paso correcto.
Task-Board B14 ✅. Pendiente para ratificar la página: A/B en vivo del
stepping (v1) + visto bueno del director a la v2.

## [2026-07-06] state | Cierre de sesión: PRD-006 parte 1 mergeada; B14 fijada como primera tarea
Sesión 2026-07-05/06 cerrada. Recorrido: A2b ratificada (alcance del
slice) → A1 ratificada (plan de producción, frente A COMPLETO) → Fase 0
cerrada (C1+C5) → B10 ratificada (Game Feel Bible) → PRD-006 ratificado e
iniciado: alcance 0 completo (rig restringido + strike hip-first) con 2
rondas de feedback de movilidad del director aplicadas + deep dive
[[Benchmark Biomecánico]] (hallazgo: el gap es timing/pose, no realismo;
pose stepping en 2s implementado tras toggle). QA todo verde al merge
(biomech, core, rig, scenes, slice). **Mandato del director al cierre:
B14 (benchmark v2 AAA — AC, 007 First Light, HZD, Jedi, y Sifu para
biomecánica/movilidad/combate) es LA PRIMERA TAREA de la próxima sesión,
antes de seguir el dev.** Branch `feat/prd-006-combate` mergeado a master
(el loop de PRD-006 sigue abierto: alcances 1–5).

## [2026-07-06] design | Deep dive biomecánico: el benchmark es TIMING, no más realismo
Pedido del director: benchmark contra Sable y Hinterberg. Hallazgo central
(página nueva [[Benchmark Biomecánico]], propuesto): Sable anima EN 2s
(12 poses/s sostenidas, frame a frame, técnica Xrd/Spider-Verse) con poses
empujadas al extremo — legibilidad > realismo (Micah Holland, Shedworks).
Hinterberg no publica data de animación (su deep dive público es de
rendering); su lección es eficiencia. Diagnóstico: nuestro rig era suave/
gomoso — ni realista ni expresivo. Síntesis con el canon §4.3: esqueleto
REALISTA (intacto) + pose EXTREMA + timing EN 2s; el gameplay nunca se
escalona. Implementado ya en el rig (commit en branch): pose stepping a
12 Hz detrás de toggle `animation_on_twos`, relojes de combate continuos
a 60 fps, constraints corriendo TODOS los frames (red de seguridad no
escalonada — el autotest adversarial lo forzó). QA: biomech ALL_PASS,
test_core ALL_PASS, rig 11 casos, slice ALL_PASS. Pendiente: A/B en vivo
con el director + ratificar la página.

## [2026-07-06] playtest | Ronda 2 de movilidad: cadera como motor (feedback del director)
Director: "buena movilidad en general; el crouch walk no convence y la
cadera sigue conservadora". Corregido (commit 0b45ab8): (1) ROM del pelvis
en Y ampliado a ±0.7 con justificación biomecánica (pelvis + pivote de pie
como unidad hasta que C4 traiga pies IK); (2) strike con cadera −0.60/+0.55
+ drive de traslación (el peso viaja al objetivo, no solo rota); (3) crouch
walk v2: rotación pélvica por zancada, peso lateral sobre el pie plantado,
contra-rotación de tronco y brazos en contra-balanceo — la silueta baja
aceptada se preserva. QA ALL_PASS, cero violaciones. Strips nuevos:
biomech_crouchwalk_{a,b}.png + strike re-capturado.

## [2026-07-06] playtest | Review de strips del strike: coil amplificado (feedback del director)
Dos observaciones del director sobre los strips de biomech: (1) el look de
las capturas está fuera de la Art Bible — CONFIRMADO COMO PLANEADO (stage
pelado de QA + rig del prototipo cuyo cel genérico es anti-referencia
explícita; el look canónico se aplica en Fase 4 del [[Plan-de-Produccion]];
las fases 1–3 se revisan en crudo: el cuerpo, no el pixel). (2) "No veo
mucha amplitud en el coil" → CORREGIDO (commit 47a483e): amplitudes
llevadas al borde del ROM (cadera −0.42, columna −0.75, hombro −1.90,
codo −1.45), contra-giro de cabeza (los ojos quedan en el objetivo — lo
que hace legible un windup real), captura del windup movida al pico del
coil (k 0.28). autotest_biomech ALL_PASS se mantiene (cero violaciones:
el ROM absorbe las amplitudes nuevas).

## [2026-07-06] feature | PRD-006 alcance 0 COMPLETO: rig humano restringido (en branch)
En `feat/prd-006-combate` (commit 5d9d93b). Entregado: `rig_biomech.gd`
(tabla ROM humana de referencia — hombro 3-DOF, codo/rodilla bisagra sin
hiperextensión, columna, cadera; clamp con reporte de violaciones
intentadas; curvas de cadena cinética con lags cadera→torso→hombro→brazo
y fases windup 0–0.32 / active 0.32–0.58 / recovery = las ventanas de
combate) + `play_strike()` hip-first en el rig (el snap legacy queda solo
para el slice histórico) + pase de constraints SIEMPRE al final del pose.
QA: `autotest_biomech` ALL_PASS (locomoción/strike cero violaciones ROM,
orden de fases correcto, clamp adversarial verificado, capturas de fases a
midpoint); regresión verde (test_core, rig 11 casos, slice). Siguiente
tarea del loop: alcance 1 (4 componentes + HitPayload).

## [2026-07-06] design | PRD-006 RATIFICADO — arranca el Feature Loop de combate
El director ratifica la spec iterada (movilidad realista como columna
vertebral). Feature Loop abierto en `feat/prd-006-combate`; orden de
construcción: alcance 0 (rig humano restringido: constraints + cadena de
transferencia hip-first) → componentes → kit Duelist → enemigos → feel →
greybox/QA. Doble criterio de aceptación en Playtest Loop.

## [2026-07-06] design | PRD-006 iterado: Movilidad Realista como columna vertebral
Mandato del director en sesión: construir el combate con mucho foco en
[[Movilidad Realista]]. El PRD se reestructura: (1) nueva sección columna
vertebral §4.3 — el moveset deriva del esqueleto, ventanas de combo =
fases biomecánicas del golpe (carga de cadera / transferencia / re-
equilibrio), momentum→daño como física corporal (masa × velocidad),
telegraphs = biomecánica legible (se lee la cadera del rival, no un
flash); (2) alcance 0 nuevo: rig humano restringido (C4 parcial: joint
constraints + cadena de transferencia hip-first) ANTES de animar ataque
alguno — Task-Board C4 → 🔄; (3) QA con assert de constraints por joint y
revisión biomecánica en montage; (4) doble criterio de aceptación: "no se
siente como el prototipo 0" + "el cuerpo importa más que el pixel".
Sigue `propuesto`, pendiente ratificación.

## [2026-07-05] design | PRD-006 (combate mínimo) PROPUESTO — con anti-objetivo del director
Spec nueva [[PRD-006 Combate mínimo]] en `20-State/PRDs/`. Mandato del
director incorporado como anti-objetivo: **el combate no debe sentirse
como el prototipo 0** — diagnóstico del viejo (`try_attack()`: botón +
cooldown, daño plano, flash+nudge) y reemplazo estructural (combos
AnimNotify + buffer, HitPayload 4 campos, reacciones por Equilibrio,
GuardComponent con parry Roba, canales de la Bible, soft-aim). El código
viejo queda intacto solo para autotest_slice histórico. Criterio de
aceptación literal del Playtest Loop: "no se siente como el prototipo 0".
Pendiente ratificación.

## [2026-07-05] design | B10 RATIFICADA: Game Feel Bible sellada
El director ratifica sin cambios, incluida la decisión mayor de cámara:
LIBRE + soft-assist, sin lock-on duro (revisable en Gate 1 si el greybox
la desmiente). [[Game Feel Bible]] → `ratificado`; Task-Board B10 ✅.
La Fase 1 queda desbloqueada para implementación: siguiente, PRD-006
(combate §4.2 mínimo contra la Bible) y PRD-007 (Dagna companion +
Springboard T1).

## [2026-07-05] design | B10: Game Feel Bible PROPUESTA (abre Fase 1)
Página nueva [[Game Feel Bible]] (`propuesto`), anclada en los valores
vivos del prototipo (FOV-kick 8°, stutter 0.03 s/m, cam-thump 0.18 s).
4 canales: tiempo (hit-stop 40/70/110 ms por masa de arma; parry =
dilation 0.2×0.35 s, no se apilan), screen-shake (modelo trauma², cap 0.6,
Perlin; el shake comunica masa ajena, el impacto propio habla por
thump/stutter), cámara de combate (DECISIÓN MAYOR propuesta: libre +
soft-assist, sin lock-on duro — el momentum del Duelist manda; revisable
en Gate 1), y feel del Springboard (windup 0.4 s, apex float g×0.5 0.2 s,
sting T2/T3; degradado post-traición sin float/sting). Pendiente
ratificación del director.

## [2026-07-05] feature | Fase 0 CERRADA: C1 rename + C5 fix --skip (merge a master)
Feature Loop en `feat/fase-0-higiene` → merge --no-ff a master. **C1:**
AETHER BOUND en config/name (título de ventana), prints de boot y README
(roadmap V&V marcado histórico); identificadores internos retenidos adrede
(save path, sentinel de test_hello, `window.__BORISAWA` del build web
congelado, fallback defaultName). **C5:** `start()` invoca
`_apply_skip_arg()` cuando el fast-path llega a OFFICE; el helper quedó
idempotente respecto de OFFICE. QA: test_core ALL_PASS, autotest_scenes
10/10, autotest_slice ALL_PASS (errors=0), wilds_fps 372 en frío;
aceptación live de --skip=wilds por log FSM. Además se preserva un ajuste
manual del director en [[Lecciones]] (tiering: Opus/Fable si disponible).
**Fase actual del [[Plan-de-Produccion]]: 1 (fundaciones — el link vivo).**

## [2026-07-05] design | A1 RATIFICADA: Plan de Producción sellado — arranca Fase 0
El director ratifica el plan sin cambios (companion AI en F1, diseño B
just-in-time, regla de re-apertura por gate fallido x2). [[Plan-de-Produccion]]
→ `ratificado`; Task-Board A1 ✅. **El frente A queda cerrado completo.**
Fase actual: 0 (higiene) — C1 rename V&V → AETHER BOUND + C5 fix
`--skip=wilds` + gates QA verdes.

## [2026-07-05] design | A1: Plan de Producción macro PROPUESTO
Página nueva [[Plan-de-Produccion]] (20-State, `propuesto`). Norte único:
shippear el [[Slice of Bond]]. 5 fases con gates de Playtest Loop: F0
higiene (C1+C5) → F1 fundaciones/link vivo (B10 + PRD-006 combate mínimo +
PRD-007 Dagna companion/Springboard T1 + C4 parcial; el mayor riesgo
—companion AI— primero) → F2 espina Cinder Ascent + tiers (PRD-008/009 +
T3) → F3 arco completo 4 escenas (PRD-010/011/012) → F4 arte/audio/tuning
(gate final: playtester externo siente la pérdida dos veces). Diseño B
just-in-time (solo B10 entra); B1-B8 restantes diferidos post-slice.
Pendiente ratificación del director.

## [2026-07-05] design | A2b RATIFICADA: alcance del Slice of Bond sellado
El director ratifica la propuesta sin cambios (incluidas las 3 decisiones
señaladas: Cinder Ascent como espina, T1→T3 comprimido en una sesión sin
tope por acto, Standing fuera como sistema). [[Slice of Bond]] →
`ratificado` completo; Task-Board A2b ✅. El frente A queda: solo A1 (plan
de producción macro) abierto. Siguiente: desglose del slice en PRDs
(Feature Loops) + B10 (Game Feel Bible).

## [2026-07-05] design | A2b: alcance del Slice of Bond PROPUESTO
Propuesta completa escrita en [[Slice of Bond]] (pendiente de ratificación).
Estructura: la Estructura Dramática en miniatura, 4 escenas — cold open El
Nido (prófugo + reclutamiento + T1), espina Cinder Ascent corto (Springboard
como progresión + camp scene del ritual + T2), mini-dungeon eco del Sunken
Archive (T3 + traición con la Primera Cuña), coda Bond vacío desandando el
Ascent (ratio 80/20). Sistemas in: locomoción PRD-005, combate §4.2 mínimo
(Humano Duelist + Dagna Enano Vanguard reducido + 2 enemigos), Tether solo-
Bond sin Standing, 1 camp scene. Out: Quinteto, marcas, economía Standing,
momentos de Persona sistémicos. Duración 45–60 min. Criterio de éxito: el
playtester siente la pérdida dos veces (mecánica y emocional). Task-Board
A2b → 🔄.

## [2026-07-04] lint | Vault preparado para orquestación por Opus
El director pierde acceso a Fable a partir de 2026-07-05; revisión de
agnosticismo de modelo. Resultado: el Vault ya era agnóstico por diseño (VDD);
cambios: tiering de [[Lecciones]] actualizado (Opus = orquestador único),
7 lecciones operativas de la sesión golden-scene consolidadas en Lecciones
(trampa ALPHA del toon, quad de post, absf, Image.load_from_file en CLI, gh
sin auth → merge --no-ff, patrón PowerShell de autotests, comandos de
Start-GoldenScene/process_clump), Index desfasado de ADR-002 corregido, plan
de sesiones de arte en Current-State actualizado a "todas cerradas".

## [2026-07-04] state | Creación del Vault
Adopción del modelo de trabajo VDD × LLM-WIKI (ver [[SCHEMA]] y ADR-001).
Scaffolding: capas 10-Knowledge / 20-State / 30-Loops / 90-Raw, Index y este Log.
Frameworks fuente archivados en `90-Raw/`.

## [2026-07-04] ingest | GDD v2.2 → 21 páginas Knowledge
Ingest #1: `docs/GDD.md` (congelado con banner) compilado en 21 páginas
interlinkeadas en `10-Knowledge/`. Todas `ratificado` (el GDD venía bendecido).

## [2026-07-04] state | Migración de State + Loops v1
`20-State/`: Current-State, Task-Board (frentes A/B/C desde GDD §8),
Lecciones (desde BACKLOG.md), ADR-001, ADR-002. `BACKLOG.md` raíz archivado
como histórico. `30-Loops/`: Ingest, Design, Feature, Playtest, Lint.

## [2026-07-04] design | Fenotipos y Creación de Personaje (Sesión 1 de arte)
Nueva página [[Fenotipos y Creación de Personaje]] (status `propuesto`).
3 decisiones ratificadas por el director: Mistbound 100% humanos (se retira lo
beast-folk); enanas con trenzas/patillas ornamentadas (sin barba plena);
slider peso = solo visual (masa la fija la celda). Plan de sesiones de arte
acordado: 1 fenotipos → 3 golden scene (B11) → 2 Game Feel Bible (B10).
Repo renombrado a Aether-Bound-RPG (remote actualizado).

## [2026-07-04] design | Briefs de concept art para fenotipos
Estudio de silueta de las 3 razas mostrado y validado en sesión. Nueva página
[[Briefs de Concept Art]]: 3 prompts autocontenidos para Nano Banana 2
(fenotipos) + notas de pipeline (aprobados → 90-Raw/, evaluar contra los 5
ejes de la Art Bible). El mismo pipeline alimentará B11 (keyframes) y B9
(Speck).

## [2026-07-04] ingest | Concept art de fenotipos → 90-Raw/concept/
5 láminas Nano Banana 2 archivadas (humano, elfo lavanda+porcelana, enano
varón, enana v2 definitiva) tras 2 rondas de re-roll (1b piel, 2b→2c
proporción blindada). Todas evaluadas contra los 5 ejes; referencias cruzadas
en [[Fenotipos y Creación de Personaje]]. B13 ✅. Lección de prompt: el sesgo
"woman→alta/esbelta" se corrige poniendo la proporción como primera regla +
negativos anti-deriva (documentado en [[Briefs de Concept Art]] 2c).

## [2026-07-04] design | Fenotipos RATIFICADOS — Sesión 1 de arte cerrada
El director ratifica [[Fenotipos y Creación de Personaje]] (B12 ✅). La
Sesión 1 queda cerrada: página canónica + 5 láminas de referencia. Siguiente:
golden scene (B11).

## [2026-07-04] design | Golden scene: estrategia + brief del keyframe
Decisión de método (el director señaló que the_wilds arrastra la dirección de
arte vieja): la golden scene NO retrofitea the_wilds.gd — se construye un
diorama nuevo diminuto que persigue un keyframe ratificado; se hereda solo
tech agnóstica de look (FSM, sistema MultiMesh, mecanismo de presets, harness
A/B), nunca paletas/materiales/post viejos. Briefs 4 ("Wilds at dawn") y 4b
(variante atardecer) escritos en [[Briefs de Concept Art]]. B11 → en curso.

## [2026-07-04] ingest | Keyframes Wilds dawn/dusk → 90-Raw/concept/
`keyframe-wilds-dawn-v1.png` + `keyframe-wilds-dusk-v1.png` archivados.
Evaluación 5 ejes: línea-que-muere-con-la-distancia y rojo-único-saturado
demostrados de libro; composición idéntica entre horas (gate A/B viable).
Pendiente de ratificación del director: (a) el par como criterio de
aceptación de la golden scene; (b) decisión nueva que trajo el dusk — filos
neón teal en crestas de noche (herencia Sable nocturna, no estaba en brief).

## [2026-07-04] design | Speck: forma base ratificada + brief de 3 estadios
RATIFICADO: Speck = salamandra/axolotl luminosa (branquias-antena, cresta
erizable; rima con la Muda). Brief 5 escrito en [[Briefs de Concept Art]] —
regla nueva: los cristales del estadio 3 usan la misma geometría del God-Core
del keyframe (revelación retroactiva cosida en el arte). Avanza B9.

## [2026-07-04] ingest | Speck 3 estadios v1 → 90-Raw/concept/
`speck-estadio{1-cria,2-vinculo,3-espejo}-v1.png` archivadas. Evaluación:
identidad ✓✓ (misma criatura en las 3), beats canónicos en viñetas ✓
(estornudo/puente/imitación del Pivote), cristales E3 riman con el core del
keyframe ✓. FALLO: el crecimiento no se lee — las 3 comparten cuerpo de cría
(la edición preservó de más; inverso del caso enana 2b). Re-roll propuesto
para E2/E3 con silueta humana gris de escala + anti-chibi (prompts en sesión;
pendiente decisión del director: re-roll vs resolver escala en 3D).

## [2026-07-04] design | Keyframes RATIFICADOS + regla nocturna
El director ratifica: (a) el par dawn/dusk como criterio de aceptación de la
golden scene; (b) filos neón teal nocturnos como regla canónica de la
[[Art Bible]] (sección nueva "regla nocturna" + keyframes canónicos). La capa
3 del pipeline debe soportar glowing edges con color por hora del día.

## [2026-07-04] design | ADR-002 CERRADA: Godot confirmado + ficha de Dagna (B1)
**"A3: Godot confirmado"** — el director sella el motor con la evidencia de
la golden scene (ADR-002 actualizada; Task-Board A3 ✅). Decisión de
secuencia: B1-Dagna ANTES de A2b (la ficha del Pivote dimensiona el slice,
no al revés). Página nueva [[Dagna]] (propuesto): bio Guardiana de la Puerta,
beat de reclutamiento ("You kept the wrong promise"), tiers del Springboard
(T2 Fault Line / T3 Mountain's Answer), quiebre por ley del clan, objeto
firma "la Primera Cuña" (+ martillo si T3), brief visual sobre la enana v2.

## [2026-07-04] design | Dagna RATIFICADA + brief 7 (concept art)
El director ratifica la ficha completa de [[Dagna]] ("me gusta todo"; solo
faltaba el visual). Brief 7 escrito en [[Briefs de Concept Art]]: prompt
autocontenido NB2 con la enana v2 como ancla de anatomía; plants visuales —
cuña miniatura en la trenza (plant del objeto firma), hombreras-compuerta,
martillo-ariete. Pendiente: generar/aprobar `dagna-v1.png` → ingest.
Siguiente sesión: A2b (alcance del slice), dimensionado alrededor de Dagna.

## [2026-07-04] ingest | dagna-v1.png aprobada → 90-Raw/concept/
Lámina generada por el director y aprobada por ambos: trapecio intacto (el
ancla de la enana v2 previno la deriva esbelta), martillo-ariete ✓,
hombreras-compuerta ✓, tatuajes de gremio ✓, sin barba ✓. Nota a modelado:
la cuña miniatura de la trenza quedó tímida — garantizarla en el modelo 3D.
**Dagna COMPLETA** (ficha ratificada + lámina canónica). B1: 1/9.

## [2026-07-04] feature+ingest | Follaje por tarjetas con sprite real + 2 especies nuevas
Técnica de follaje ratificada e implementada: tarjetas alpha-cutout en cruz
sobre cascarón con normales radiales (`toon_foliage.gdshader` +
`_card_shell`). Sprite sheet del brief 6 generada por el director →
`90-Raw/concept/foliage-clumps-v1.png`; procesada a asset tintable con
`tools/process_clump.gd` (blanco→alpha, tonos casi-blancos, tinta preservada)
→ `godot/rendering/foliage_clump.png`. Especies nuevas en la golden scene:
**pino** (tiers cónicos de tarjetas) y **jacaranda** (tronco bifurcado +
paraguas lavanda; claves de preset pine/bloom/bloom_dark por hora). El look
Moebius de copas festoneadas quedó funcionando en las dos horas.

## [2026-07-04] feature | Golden scene RONDA 2 CERRADA — look capturado como sistema
Director aprueba ("buen punto; después fine-tuning"). Entregado sobre la v0:
color alineado a keyframes (valor de acuarela: sombras luminosas, ambient_lift
0.24, shadow_opacity por hora) · terreno con relieve (vaguada+montículos) ·
árboles con anatomía Moebius (esqueleto recursivo de ramas, grumos del sprite
del director SOLO en puntas, 3 especies: caducifolio/pino/jacaranda) ·
God-Core facetado (columnas prismáticas + facetas con banda propia) · god
rays · regla nocturna teal. **El look es ahora un sistema replicable:**
melancolia_post + toon_golden + toon_foliage + foliage_clump.png + tabla
PRESETS. Gates: test_core ALL_PASS, FPS 432-530 (≥60). Merge a master.
Fine-tuning pendiente anotado en B11: corteza/curvatura de ramas héroe en
close-up, facetado del cristal de cerca, cel banding del terreno lejano.
Los re-rolls v2 de E2/E3 derivaron a humanoide/bípedo (E2 uncanny, E3 raptor
elegante pero otra criatura) → DESCARTADOS, no se ingestan. Decisión del
director: **cuadrúpeda en los 3 estadios** (la alternativa "se yergue en E3"
se evaluó y descartó). Prompts v3 emitidos: parten de las v1 (anatomía buena)
con candado anti-bípedo triple + silueta de escala. Lección de prompt: pedir
proporciones nuevas sin fijar la postura invita al modelo a re-anatomizar.

## [2026-07-04] ingest | Speck E2/E3 v2 (briefs v4) → 90-Raw/concept/
`speck-estadio2-vinculo-v2.png` + `speck-estadio3-espejo-v2.png` archivadas.
Los briefs v4 (generación desde cero, encuadre field-guide, spine parallel to
the ground, v1 solo como referencia de cara) resolvieron el crecimiento:
cuadrúpedas ✓, escala con silueta humana ✓ (cintura/pecho), identidad ✓,
cristales E3 riman con el core ✓, "expresión intacta" ✓. La trilogía
cría→adolescente→espejo lee el crecimiento completo. Set visual de Speck
COMPLETO — pendiente ratificación del director.

## [2026-07-04] design | Set visual de Speck RATIFICADO — sesión de arte cerrada
El director ratifica la trilogía (cría v1 / adolescente v2 / espejo v2).
B9: parte de arte ✅ (queda re-naming VFX). Balance de la sesión de arte:
fenotipos 3 razas ✅ (5 láminas) · keyframes dawn/dusk ✅ (gate golden scene)
· regla nocturna nueva en Art Bible · trilogía Speck ✅ · 3 lecciones de
prompt-craft documentadas. Siguiente: Feature Loop de la golden scene (B11).

## [2026-07-04] design | Pareja del Slice of Bond RATIFICADA (A2)
**Humano Duelist × Dagna (Seismic Springboard).** Razón principal: el
supersalto/momentum del PRD-005 ya es la base técnica del link; orfandad
mecánica máximamente legible (pierdes la verticalidad); quiebre de Dagna de
los más fuertes. Página nueva [[Slice of Bond]]. Abierto: alcance (A2b).
(En paralelo corre el Feature Loop de la golden scene en feat/golden-scene.)

## [2026-07-04] feature | Golden scene v0 APROBADA en vivo — loop cerrado (PR→master)
Diorama nuevo (claro + árboles héroe + core + 3 planos + presets dawn/dusk) +
`melancolia_post.gdshader` (4 capas screen-space) + `toon_golden.gdshader`
opaco + `autotest_golden` (A/B + modo --hold / Start-GoldenScene.bat).
Director revisó en vivo: "mucho mejor" → cierre v0. Gates: test_core ALL_PASS,
FPS 510/625 (≥60). **Evidencia ADR-002: las 4 capas corren en Godot a 8–10×
el presupuesto.** Lecciones nuevas: el toon del prototipo escribe ALPHA (pase
transparente → invisible a screen_texture); quads de post van en pase
transparente; absf/abs en inferencias GDScript.
**Ronda 2 abierta (gaps):** calidez+rayos del dawn · core como racimo de
cristal · árboles nudosos sin costuras · bandas cel visibles.
