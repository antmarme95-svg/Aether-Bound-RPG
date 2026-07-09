# LOG — bitácora append-only del Vault

## [2026-07-09] feature | PRD-007 alcance 2 — Seismic Springboard T1 (Bond=`R` + salto-en-onda → lanzamiento)
Cierra la mecánica central del PRD-007. **Input Bond = `R`** (`game_director`:
`_check_key_r()` + `request_bond_pound()`) pide el ground-pound a Dagna en el
estado ARENA; la onda ya se registra sola (alcance 1). El controlador comparte
`springboard_waves` por referencia (mismo patrón que `enemies`). **Lanzamiento**
(`player_controller._wave_at()` en el bloque de salto vertical): un salto DENTRO
de una onda activa no usa el `jump_force` normal (8.4 → ~0.8 m con el warrior
ironblooded pesado) sino `SPRINGBOARD_LAUNCH_VEL 17.0` → **~6.0 m** (7.3× el
salto normal, altura "imposible" para cornisas). **Air control por la ley de leap
del PRD-005:** el lanzamiento SIEMBRA `_air_vel` con el momentum horizontal actual
y activa `_leaping`, de modo que el path aéreo del leap conserva y DIRIGE la
inercia (llegas corriendo → cargas y diriges; saltas parado → subes recto). **Feel
(GFB):** fachada nueva `Feel.springboard_launch()` = freeze pesado (pop de la
curva de subida) + trauma; VFX de estela teal ascendente; **tell de HUD**
(`hud.set_springboard_ready()` = cue "SALTA" teal que pulsa mientras pisas la onda
con ventana abierta, refuerza los anillos diegéticos). Sonda
`tests/tmp_springboard.gd` ALL_PASS: Bond→pound→onda, altura con onda 6.00 m vs.
sin onda 0.82 m (7.3×), air control 4.67 m de desplazamiento dirigible, captura
`springboard_launch.png` (jugador en el aire, suelo curvado abajo). QA regresión:
test_core + autotest_combat ALL_PASS. **Pendiente: playtest del director (feel) —
"afinamos con playtest"** (números de altura/tecla/ventana a tunear en vivo).
Siguiente: alcance 3 (IA de combate mínima de Dagna) y alcance 4 (Gate 1: cornisa
solo alcanzable vía Springboard + `autotest_springboard` + ≥60 FPS frío).

## [2026-07-08] feature | PRD-007 alcance 1 — ground-pound de Dagna → zona de onda + VFX teal
Donde nace la mecánica del Springboard. `ally_dagna.gd`: `ground_pound()` =
secuencia plant→slam→recover; en el impacto (tras windup ~0.35 s) spawnea el
VFX (burst teal + 2 anillos de choque expandiéndose por el suelo, per la
lámina `Seismic Springboard.png`) y emite `springboard:wave`. El director
registra la zona de onda en `springboard_waves` ({pos, radio 4.2, ventana
0.6 s} — la consume el jugador en el alcance 2) y **empuja a los enemigos
cercanos** (la onda ES un ataque; knockback por `push_pull`, sin daño aún —
eso llega con la IA del alcance 3). Los triggers del pound (Bond alcance 2,
IA alcance 3) se enchufan después; aquí lo dispara la sonda. `tests/
tmp_pound.gd`: onda registrada + knockback (heavy 1.6 m) + expiración +
captura `pound_wave.png` (los anillos teal leen igual que la lámina). QA:
test_core/combat/slice/ui + tmp_ally (regresión follow) ALL_PASS. Siguiente:
alcance 2 (Springboard T1: Bond=`R` + salto-en-onda → lanzamiento vertical).

## [2026-07-08] design | [[Briefs de Concept Art]] RATIFICADA
El director ratifica la biblioteca de prompts: sus outputs (fenotipos,
keyframes dawn/dusk, trilogía Speck, foliage_clump, Dagna v1) ya son canon
en `90-Raw/concept/`, y sus fuentes ([[Fenotipos y Creación de Personaje]],
[[Art Bible]]) están ratificadas. Era el único `propuesto` que quedaba en el
vault. Página VIVA: los briefs de los 8 pivotes restantes se añaden sin
desratificar lo probado (mismo patrón que [[Benchmark Biomecánico]]). Index
actualizado. Vault ahora 100% sin status pendientes.

## [2026-07-08] lint | Salud del vault — consistente (fix de branch line)
Lint Loop tras PRD-007 (ratificación + alcance 0) y el depósito de concept
art. **Reporte:** (1) sin contradicciones — PRD-007 coherente con Dagna /
Los 9 Links / Slice of Bond. (2) Wikilinks: sin rotos reales (solo los
`[[wikilink]]` de ejemplo del SCHEMA); [[PRD-007 …]] resuelve; sin huérfanas
(solo LLM-WIKI/VDD, fuentes raw por archivo). (3) Status: `Briefs de Concept
Art` sigue `propuesto` (único abierto, decisión del director); PRD-007
`ratificado` ✅. (4) Index: 45 páginas, PRD-007 catalogado. (5) State vs
repo: **fix** — la línea "Branch actual" seguía en "Capas 1–3" (después
vinieron concept art + PRD-007 + alcance 0) y le faltaba la sonda `ally`;
actualizada. Vault consistente.

## [2026-07-08] feature | PRD-007 alcance 0 — Dagna aliada spawnea y sigue
Primer alcance del PRD-007. `gameplay/ally_dagna.gd`: Dagna montada por el
pipeline de personajes (`apply_to_rig("dagna")`) sobre los 4 componentes
canónicos (kit Vanguard neutro por ahora), SIGUE un slot al hombro izquierdo
del jugador (la cámara vive en el derecho — lección nueva), con ground-snap
y gait procedural. Boot flag `--ally=dagna`: spawn en ARENA, array `allies`
separado de `enemies`, update en `_gameplay_update`. Sonda `tests/tmp_ally.gd`
(spawn + follow: 22 m recorridos, dist acotada ~2.6 m + captura
`ally_dagna_follow.png` — Dagna legible). QA: test_core/combat/slice/ui
ALL_PASS (el código de aliada solo se activa con el flag). Sin combate aún.
Siguiente: alcance 1 (ground-pound → zona de onda PushPull + VFX teal).

## [2026-07-08] design | PRD-007 RATIFICADO — Dagna aliada + Seismic Springboard T1
Design Loop del siguiente hito (rumbo al Gate 1). Nuevo spec
[[PRD-007 Dagna aliada + Seismic Springboard T1]] (`20-State/PRDs/`).
**2 ejes decididos por el director:** (1) Springboard T1 = onda + salto en
ventana (co-op de timing; input único Bond; reusa PushPullComponent +
supersalto/leap del PRD-005) — el golpe de suelo de Dagna spawnea una zona
de onda temporal, y saltar dentro de la ventana amplifica el salto a un
lanzamiento vertical; (2) Dagna aliada = mínima pero real (sigue + ground-
pound + muralla + defensa básica, sobre los 4 componentes vía config
`dagna`, sin companion AI rica). **4 detalles ratificados:** Bond=`R`; tell
de ventana = anillos de la onda + pulso de HUD; spawn = flag `--ally=dagna`
+ presente en el gate; pounds de IA se suman en el alcance 3 (T1 arranca
solo-Bond). Alcance en 5 pasos (0 aliada→1 onda→2 T1→3 IA→4 Gate 1 con
cornisa + `autotest_springboard` + ≥60 FPS). Anti-obj: solo T1; sin
Tether/T2/T3, sin camp scene; C6 no se adelanta salvo cláusula de escape.
Task-Board: C7 🔄. Siguiente: Feature Loop alcance 0.

## [2026-07-08] lint | Salud del vault — consistente (fixes menores aplicados)
Lint Loop tras cerrar el paquete de feedback del kit. **Reporte:**
1. Contradicciones: ninguna (Knowledge↔código coherentes).
2. Wikilinks: sin rotos (los `[[wikilink]]`/`[[wikilinks]]` son ejemplos
   del SCHEMA, no links reales); sin páginas huérfanas — las 27 Knowledge
   + State + Loops tienen link entrante; 90-Raw se referencia por archivo.
3. Status: solo `Briefs de Concept Art` sigue `propuesto` (coincide con el
   Index) — pendiente de confirmar con el director si se ratifica o queda.
4. Index vs realidad: 44 páginas, todas catalogadas (incl. Estructura
   Dramática); sin entradas fantasma.
5. State vs repo: **drift corregido** — la línea "Branch actual" seguía en
   "Capa 1" (ya íbamos por la validación) y el "arranque próxima sesión"
   marcaba el playtest como pendiente (ya validado). Fechas `updated:` de
   Current-State/Task-Board/Lecciones puestas al día (2026-07-08).
Vault consistente. Único ítem abierto: status de Briefs (decisión del director).

## [2026-07-08] playtest | Paquete de feedback del kit VALIDADO por el director
El director probó en vivo (`Start-Playtest-Greybox.bat`) y validó las 3
capas del feedback del kit Duelist: Capa 1 (guardia con cuerpo + bloqueo
acero, "mejoró mucho"), Capa 2 (tell del parry: batazo de cuerpo + flash
cian-oro) y Capa 3 (estela del swing). El kit queda cerrado a nivel feel.
Pendiente de arte aparte: el status gráfico de las reacciones del enemigo
(sesión propia). Siguiente hito: PRD-007 (Dagna + Seismic Springboard T1)
rumbo al Gate 1.

## [2026-07-08] feature | Feedback del kit — Capa 3: legibilidad del swing (LMB) + paquete cerrado
Última capa del feedback del kit. El swing se leía poco del lado del
jugador; SIN tocar la biomecánica ratificada del strike, `_spawn_swing_arc()`
dibuja una estela de filo (crescent emisivo additivo con TAPER por
vertex-color: borde de ataque brilla, cola se apaga) al ENTRAR la fase
active — 1×/golpe detectando la transición de fase en el update del
controller — que se desvanece en ~0.16 s (tween albedo→transparente).
Iteración de tuning por sonda: la v1 salió gigante/reventada; se bajó a
crescent fino translúcido (r 0.5–0.95, alpha 0.55) tilteado en diagonal.
Sonda `tmp_guard.gd` amplió la captura (swing_arc.png). QA: test_core/
combat/slice/ui ALL_PASS. Con esto el paquete de feedback del kit
(guardia+bloqueo, parry, swing) queda CERRADO en código; pendiente solo el
visto bueno del director en vivo. El status gráfico del enemigo corre
aparte (sesión propia).

## [2026-07-08] feature | Feedback del kit defensivo — Capa 2: el parry se ve del lado del jugador
El director aprobó la Capa 1 ("mejoró mucho") y dio luz verde a la Capa 2.
El parry Roba solo se leía por el stun del enemigo. Ahora: (a) rig
`play_parry()` = deflexión seca de TODO el cuerpo (el arma batea arriba-
afuera + off-arm en contrapeso + giro de torso lumbar/torácico + cabeza al
acero robado), riposte ~0.3 s sobre la guardia, ROM limpio; (b) VFX
`_spawn_parry_flash()` = pop emisivo cian + burst de chispas cian→oro al
frente del arma, más brillante que el destello de bloqueo. Wiring en
`receive_hit` (reacción parried). Sonda `tmp_guard.gd` amplió la captura
(guard_parry.png). QA: test_core/combat/slice/ui ALL_PASS. Fix de test
descubierto en el camino: el kill loop de autotest_combat estaba acotado
por FRAMES → dependiente del FPS (a ~900 fps mataba tarde y fallaba); se
acotó por TIEMPO REAL. Lecciones nuevas: loops de autotest por tiempo real,
y capturas de pose en 2s tras un tick. Pendiente: Capa 3 (legibilidad del
swing LMB) + visto bueno del parry en vivo.

## [2026-07-08] feature | Feedback del kit defensivo — Capa 1: la guardia gana cuerpo + bloqueo diferenciado
Playtest del director (clip 2026-07-08) del kit Duelist: la GUARDIA (RMB
mantener) no comunicaba nada — sin pose y el vignette rojo salía igual al
bloquear; el parry (RMB tap) poco evidente del lado del jugador; el status
gráfico del enemigo no le encanta (→ tarea de arte aparte, chip creado).
Plan en 3 capas; el director eligió arrancar por la Capa 1 con sonda visual
para su visto bueno antes de seguir. **Capa 1 ✅ código:** (a) rig
`set_guard(bool)` = pose de bloqueo sostenida (antebrazos cruzados + arma
arriba + brace) que compone sobre el gait, bajo el strike, y aguanta bajo
el flinch — dentro de ROM (constraint_report vacío); (b) golpe BLOQUEADO
deja de pintar rojo → destello ACERO (COL_BLOCK en hud.gd) + chispa de
deflexión en el arma (_spawn_guard_spark), el rojo queda solo para daño
limpio; wiring `stats.take_damage(...,blocked)` + `_set_guard`→`rig.set_guard`.
Sonda `tests/tmp_guard.gd` (neutral/guardia/3-4/flinch). QA: test_core/
combat/slice/ui ALL_PASS. Lanzador `Start-Playtest-Greybox.bat` para el
playtest en el greybox. Pendiente: visto bueno del director → Capa 2 (tell
del parry) + Capa 3 (legibilidad del swing).

## [2026-07-07] feature | PRD-006 alcance 5: greybox + spawns parametrizables + autotest_combat — PRD-006 CERRADO
Cierra PRD-006 y abre el Gate 1. Tres piezas nuevas: (1) `scenes/
combat_arena.gd` — greybox blockout barato (suelo plano + anillo + postes)
que implementa el contrato de escena completo; (2) `gameplay/spawn_spec.gd`
— parser tolerante de la spec de spawns (`light,heavy`, `2light+1heavy`,
`duelpair` alias, vacío→default); (3) `tests/autotest_combat.gd` — gate
windowed permanente. Integración en `game_director.gd`: estado FSM `ARENA`
+ `--skip=arena` + helper `_spawn_humanoids` COMPARTIDO con WILDS (el
`--spawn=duelpair` viejo se generalizó; back-compat verificado por
`tmp_spawnflag`). El autotest verifica: spawn parametrizado (2 kinds),
parry Roba→stun, kill loop del kit Duelist real (ambos muertos, 940
frames) y FPS. **Greybox a 177 FPS → gate ≥60 holgado.** QA: test_core/
slice/ui ALL_PASS. Lección dura nueva: golpear a un enemigo `dying`
reinicia su timer de muerte (receive_strike vuelve a health<=0 y pone
state_t=0) → en kill loops/AoE, dejar de pegar al entrar en dying. Falta
solo el playtest del director del feel acumulado (alcances 4 + tuning).

## [2026-07-07] design | Ventana de C6 RATIFICADA: entre el Gate 1 y la Fase 2
El director ratifica la ventana del rework anatómico (C6): tras cerrar
PRD-006/007 y el Gate 1, junto al pase de poses C4 — una sola cirugía
anatómica antes del contenido de Fase 2. Cláusula de escape acordada: si
en el playtest del Gate 1 los cuerpos impiden juzgar el feel, C6 se
adelanta a dentro de PRD-007. Secuencia vigente: alcance 5 → PRD-007 →
Gate 1 → C6+C4 poses → Fase 2. Fase 4 conserva solo el vestido final.

## [2026-07-07] design | Veredicto del director sobre Dagna in-engine → C6 rework anatómico
Tras ver la comparación lado a lado (lámina · greybox · golden scene):
la demo en golden scene confirma que el REGISTRO del Art Bible aterriza
sobre el rig (sonda nueva `tests/tmp_dagna_golden.gd`: materiales toon →
toon_golden opaco para sobrevivir al post, conservando el outline), pero
**la anatomía está lejos de la lámina**. Causa raíz señalada por el
director: el cuerpo base reutiliza los gráficos del prototipo PRE-RESET,
que ya estaban corruptos — debió hacerse un rework completo en vez de
heredarlos. Decisión: **C6 — rework anatómico del cuerpo base** (Task-
Board): reconstruir proporciones/volúmenes/cabeza desde las láminas de
fenotipo, conservando la biomecánica ganada (hip-first, columna 2 seg,
constraints, canon 2s). Ventana recomendada: junto al pase de poses C4
(B15c/B15d), tras el Gate 1 y antes del contenido de Fase 2; el vestido
final (materiales/cara/atlas) permanece en Fase 4.

## [2026-07-07] feature | Dagna gráfica en Godot — pipeline lámina → config → rig
Entregable extra pedido por el director: meter a Dagna GRÁFICAMENTE en el
motor para **liberar su diseño** y probar el pipeline replicable. Sistema
nuevo: `godot/data/characters.gd` (configs de personajes nombrados =
origin+clase+fenotipo+piezas firma; `apply_to_rig()`) +
`godot/character/character_signature.gd` (extras de lámina colgados
ADITIVOS sobre el rig: túnica de guardiana, hombreras/espinilleras de
compuerta, cuña de trenza, tatuajes de gremio arco+cuña, martillo de
cabezal plano a la espalda, cinturón, faldón — cero cambios al rig base).
Dagna (`ironblooded` + warrior + fenotipo enano robusto, mismo par
weight/height que el heavy) se lee inconfundible vs. `dagna-v1.png`; la
**cuña de la trenza quedó garantizada y legible en perfil** (la ficha lo
exigía). Sonda `tests/tmp_dagna.gd` (frente/espalda/perfil/detalle con
cámara nivelada tomada por la sonda — el idle fuerza head.rotation.x=0, así
que el "mira arriba" era encuadre). Solo capa de LOOK: ROM/IK enano +
animación diferidos (C4 + PRD-007). QA: test_core/autotest_slice ALL_PASS,
tmp_dagna limpio. **Ejecución creativa por subagente Fable, orquestación +
fixes de fidelidad (mirada, cuña) por Opus.** La sesión de Fable se cortó
por límite de gasto mensual de la cuenta. Pendiente: visto bueno estético
del director (miss: cuña sutil de frente, hombreras altas, tatuajes
tenues). El pipeline queda como MOLDE para los otros 8 pivotes.

## [2026-07-07] feature | PRD-006 tuning de presión enemiga (B15g)
El par humanoide ya no se congela entre golpes — el otro asesino del
feel medido en B15g ("YDIF plano / se lee pasivo"). En
`enemy_humanoid.gd`, los 3 candidatos del benchmark: recover del light
0.55→0.42 s; `chain_prob` data-driven (light 0.72 encadena, heavy 0.0
respira — antes hardcodeado a `kind=="light"`); y **circle-strafe
durante recover** (componente tangente + corrección radial al anillo
de ataque; el sentido alterna al re-entrar para no leerse robótico).
El heavy sigue lento (su identidad) pero ACECHA en vez de plantarse.
Verificado por sonda `tmp_pressure` en juego real (jugador inmortal +
pineado, 8 s): `recover_path` del light ≈0 → 3.55 m (≈1.7 m/s, calza
con strafe_speed), heavy 3.56 m; loop de golpes vivo (light 6 / heavy
5 strikes). QA: test_combat/test_core/autotest_slice ALL_PASS.
Pendiente: playtest del director. Nota: la regresión de datos vive en
la sonda windowed, no en test_combat headless — preload de un script
que referencia el autoload EventBus rompe la compilación en `--script`
(autoloads no registrados headless).

## [2026-07-07] feature | PRD-006 alcance 4: canales 1–3 de la Game Feel Bible como sistema
La mitad temporal que faltaba contra Sifu (B15e #1). Autoload `Feel` +
lógica pura `combat/time_feel.gd` (canal 1) y `combat/trauma_shake.gd`
(canal 2), reutilizables por PRD-007. Hit-stop 2f/3f GLOBAL por masa
de arma (números medidos B15; ×1.5 golpe de muerte, 50% al recibir,
cap 1 por 100 ms); parry Roba = clang 3f (B15b) + dilation 0.2×0.35 s
+ sting de dos notas sintetizado (E5→B5, placeholder hasta B8); shake
trauma² Perlin con caps GFB (0.25 m / 2° / 0.6); canal 3 = combat
framing (FOV +4°, lift 0.12 m, histéresis 2 s) + soft-aim cono 30°
total. `HitPayload.weapon_mass` nuevo (el stop escala por ARMA, no por
cuerpo; el lunge de la bestia usa masa corporal). QA: test_combat +22
asserts, sonda en juego real `tmp_timefeel` (clang 3 f exactos,
dilation 0.354 s, trauma, heat), test_core/autotest_slice/autotest_ui
ALL_PASS, FPS 491/336. Lección dura: relojes reales del autoload en
usec — sin vsync (~300–500 fps) el frame mide <1 ms y con msec el dt
daba 0 (la dilation se quedaba pegada). Pendiente: playtest del
director (feel) + tuning de presión enemiga (B15g).

## [2026-07-06] design | [[Benchmark Biomecánico]] RATIFICADO por el director
Cierre de la decisión que dejó abierta el Lint Loop: el director
ratifica el benchmark (v1 Sable/Hinterberg + v2 AAA + v3 mediciones
B15–B15g). La condición original ("ver el alcance 2 con poses
extremas") quedó superada: el canon se validó midiendo nuestra propia
build (B15d) y el playtest verificado del alcance 3 (B15f–B15g). Con
esto las 27 páginas de Knowledge quedan `ratificado` salvo [[Briefs de
Concept Art]] (propuesto legítimo — pipeline NB2 en exploración).

## [2026-07-06] lint | Lint Loop: vault sano — 7 fixes menores aplicados, 1 decisión para el director
Barrido completo (44 páginas). **Sano:** cero wikilinks a páginas
inexistentes, cero huérfanas (los Raw quedan enlazados vía 00-Index/
SCHEMA/ADR-001), Index↔realidad 1:1 en ambas direcciones, State=repo.
**Fixes aplicados:** 2 wikilinks partidos por salto de línea en LOG
(B15f y alcance 1 — Obsidian no los resolvía); Current-State
desactualizado en 3 líneas ("último PR: alcance 1"→alcance 3, sondas
tmp ampliadas y atadas a PRD-006 completo, "después del alcance 2"→
alcance 3 ✅); 00-Index marcaba `(propuesto)` a [[Fenotipos y Creación
de Personaje]] y [[Dagna]] que ya son `ratificado`. **Decisión para el
director:** [[Benchmark Biomecánico]] sigue `propuesto` y su condición
de ratificación ("ver el alcance 2 con poses extremas") ya se cumplió —
B15d–B15g validaron el canon contra nuestra propia build; ratificarlo
es cosa de una palabra. [[Briefs de Concept Art]] sigue `propuesto`
legítimamente (pipeline NB2 aún en uso exploratorio).

## [2026-07-06] state | Cierre de sesión: B15e→B15g + tinte + alcance 3 completo y VERIFICADO en juego
Sesión nocturna completa sobre el veredicto del director ("fundamentals
sí, Sifu no"). Recorrido: **B15e** (playtest medido: 8 tintes/11.4 s +
cero reacción corporal = trade-fest) → **fix del tinte** (wash →
vignette de bordes, centro siempre limpio) → **PRD-006 alcance 3 ✅**
(reacciones corporales por Equilibrio en bestia y jugador + par
light/heavy sobre el mismo rig, mergeado a master) → **fix del bat**
(Start-Godot.bat no reenviaba flags; nuevo Start-Playtest-Duelist.bat)
→ **B15f–B15g** (verificación en juego real: los 2 asesinos de B15e
resueltos, par legible por silueta, Playtest Loop CERRADO 5/7).
Hallazgo abierto: presión enemiga baja (≈1 golpe/2–3 s). Arranque de la
próxima sesión fijado en [[Current-State]]: alcance 4 (hit-stop 2f/3f +
TimeFeel + sting + shake) + tuning de presión + medir parry/síncopa.
Sondas tmp_* siguen en tests/ (limpiar al cerrar PRD-006).

## [2026-07-06] playtest | B15g ✅: par light/heavy verificado — Playtest Loop del alcance 3 CERRADO
Clip de 23.6 s con el bat nuevo. 5/7 verificados: spawn por flag,
siluetas por rol distinguibles sin color, ataques de ambos legibles (el
swing del maul del heavy se lee en arco completo), reacciones y muertes
corporales, vignette con centro limpio en pelea real. Pendientes de
MEDICIÓN (no de implementación): parry vs humanoides y síncopa del
combo. **Hallazgo de feel:** presión enemiga baja — cadencia ≈1 golpe/
2–3 s se lee como pasividad; candidatos de tuning anotados en
[[Benchmark Biomecánico]] §B15g. Lo que falta contra Sifu ahora es
temporal: alcance 4 (hit-stop 2f/3f + TimeFeel + sting) + presión.

## [2026-07-06] playtest | B15f: alcance 3 verificado en gameplay (parcial) — los 2 asesinos de B15e resueltos
Dos clips del director post-fix (el 2º usable solo 60 s). Pipeline B15
sobre la pelea (52–60 s): **cero washes de pantalla** (vs 8/11.4 s en
B15e) — el daño ahora es banda de borde con centro limpio, visible
pulsando en pleno combate; y la bestia acusa CON EL CUERPO (roll
lateral, postura baja, patas abiertas — stagger distinguible de flinch
en silueta a distancia de juego). Sin verificar (no salió en cámara):
flinch del jugador (escala/ángulo), par light/heavy (boot sin
`--spawn=duelpair`) y síncopa (sin combos limpios). Ver
[[Benchmark Biomecánico]] §B15f. Decisión pendiente: cerrar verificación con clip
dirigido o avanzar a alcance 4 con lo validado.

## [2026-07-06] feature | Flag --spawn=duelpair para el playtest del alcance 3
El par light/heavy ya spawnea en Wilds sin sonda: boot
`--origin=ironblooded --cls=warrior --skip=wilds --spawn=duelpair` los
mete a 8 m frente al jugador (además de las bestias). QA: sonda
`tmp_spawnflag.gd` PASS (par presente + screenshot) y `autotest_slice`
ALL_PASS (sin flag no cambia nada). Decisión: se valida el alcance 3 en
playtest ANTES de construir el alcance 4 — el hit-stop congela poses, y
las poses tienen que decir lo cierto antes de dramatizarlas con tiempo.

## [2026-07-06] feature | PRD-006 alcance 3 ✅ código: reacciones corporales + light/heavy
Dos pasos en branch `feat/prd006-alcance3`. **Paso 1 (absorbe B15e):**
la bestia resuelve el combate nuevo por `receive_strike()` → el
GuardComponent decide (flinch/stagger/posture break) y el CUERPO lo
anima (head snap inmediato, roll lateral, derrumbe con patas abiertas);
FSM suspendida durante stagger/broken; ventana de castigo = daño ×1.5;
`hit()` viejo intacto para los autotests históricos. El jugador acusa
con `rig.play_flinch()`: head snap a 60 (nunca stepped, canon B15) +
recoil de columna en el reloj de pose. **Paso 2:** `enemy_humanoid.gd` —
el par del PRD sobre el MISMO CharacterRig y strike hip-first: light
(raider_saber nuevo, masa 0.7, encadena, postura frágil) y heavy
(heavy_maul, masa 1.8, torre, carga 0.8–1.0 s legible). Parry Roba →
stun 2 s. QA: test_core + test_combat + autotest_slice + autotest_ui
ALL_PASS; sondas `tmp_reactions.gd` y `tmp_duel_pair.gd` con capturas al
midpoint. Pendiente: playtest del feel (Playtest Loop) y greybox de
spawns (alcance 5).

## [2026-07-06] feature | Fix del tinte de daño ✅ (adelantado por B15e)
El wash plano de daño (ColorRect full-rect alpha 0.55, decay único
~0.45 s en hud.gd) es ahora un vignette real de bordes: shader
canvas_item radial (sin screen texture — compatible con la lección del
toon/ALPHA), centro SIEMPRE a alpha 0, decay en dos fases fuerte ≤0.2 s
+ cola ≤0.3 s (spec de [[Benchmark Biomecánico]] §B15e consecuencia 1).
QA: `autotest_ui` + `autotest_slice` ALL_PASS; sonda visual
`tests/tmp_vignette.gd` captura t=0/0.1/0.25/0.5 s — centro limpio con
el golpe recién recibido, tinte extinto a 0.5 s. Desbloquea la medición
de la síncopa en el próximo clip del director.

## [2026-07-06] ingest | B15e ✅: playtest dirigido del kit Duelist — "fundamentals sí, Sifu no"
El director jugó el kit Duelist y grabó 48 s (pelea 1v1 vs bestia,
23.0–34.5 s). Veredicto: "los fundamentals existen, pero no es ni de
cerca la experiencia de Sifu". El pipeline B15 (hojas 60 fps + YDIF) le
da la razón con números: 0 hit-stops; **8 tintes rojos a pantalla
completa en 11.4 s de pelea** (el tinte es el evento visual más grande
del clip, YDIF 37–41 vs ~10 de un swing; wash ~50 % del combate);
jugador golpeado SIN cambio de pose; bestia solo flash blanco (kit
activo — re-confirma B15d #2); patrón resultante = trade-fest (tanquear
es óptimo, no se observa guardia/parry). Salvedad B15d cerrada a medias:
kit confirmado activo, síncopa aún no medible con ese encuadre + wash.
**Ajuste de prioridades:** adelantar el fix del tinte (wash → vignette
≤0.2 s fuerte) ANTES del alcance 4; alcance 3 (reacción corporal por
Equilibrio) ataca directo el trade-fest. [[Benchmark Biomecánico]] §B15e.

## [2026-07-06] state | Cierre de sesión: benchmark completo (B15–B15d) + kit Duelist listo para playtest
Sesión cerrada con el ciclo de benchmark observacional completo: B15
(3 clips base) → B15b (28 clips de Sifu) → B15c (gaits de Sable) → B15d
(nuestra build, AS IS vs TO BE). El alcance 2 de PRD-006 quedó ✅ en
código a la espera del playtest del director. Arranque de la próxima
sesión fijado en [[Current-State]]: (1) playtest del kit Duelist con
boot melee — ideal grabando 3–4 combos con cámara quieta; (2) alcance 3
absorbiendo la reacción corporal de la bestia; (3) alcance 4 con
hit-stop + revisión del tinte de daño; (4) backlog C4: poses por gait +
canal airborne. Task-Board sincronizado (B15c/B15d visibles, herencias
en C3 y C4).

## [2026-07-06] ingest | B15d ampliado: running jump medido (video↔código)
A pedido del director se midió el W+espacio del clip AS IS: aire 42 f
(0.70 s), coincide exacto con JUMP_V 8.4 / GRAVITY 24 del código —
validación cruzada. Landing stutter plano ~3 f (no bloqueante ✅, mejor
que el presupuesto Fortnite de 6 f). **Hallazgo:** el salto es invisible
en la silueta — `rig.set_motion()` no tiene canal airborne, así que
despegue/aire/aterrizaje no tienen pose (solo la raíz arquea y la cámara
hace thump). El aire es un gait sin pose: extiende la lección B15c.
[[Benchmark Biomecánico]] §B15d punto 6.

## [2026-07-06] ingest | B15d: nuestra build medida contra el benchmark (AS IS vs TO BE)
El director grabó nuestra propia build (63 s: Wilds → bestia → núcleo →
menú) y se analizó con el pipeline idéntico de B15 (hojas 60 fps + YDIF).
Medido-contra-medido: 0 hit-stops en combate (esperado — alcance 4);
locomoción YA alineada con Sable (raíz continua + holds ~4–5 f); columna
sin postura por gait (B15c ya pendiente). **Hallazgos nuevos:** (1) la
bestia reacciona solo con flash blanco ~7–8 f y pose IDÉNTICA — cero
reacción corporal (refuerza la consecuencia 3 con evidencia propia);
(2) el daño al jugador es un tinte salmón de pantalla completa >1 s que
tapa la lectura — mover el feedback al cuerpo y acortar el tinte.
Salvedad: no está claro si el kit Duelist estaba activo en el clip; el
clip ideal para medirlo es `--cls=warrior`, cámara quieta, 3–4 combos.
[[Benchmark Biomecánico]] §B15d.

## [2026-07-06] ingest | B15c: crouch walk y sprint de Sable (2 clips más)
Paréntesis del director tras el alcance 2. Mismo sistema confirmado
(holds ~4 f solo extremidades + raíz continua) y una lección nueva de
gaits para [[Locomoción]]/C4: **cada gait es una POSE de silueta propia**
— crouch = torso plegado ~90° con mano rozando el suelo; sprint =
encorvada adelante con cabeza baja (cita de Holland verificada frame a
frame). Nuestra columna de 2 segmentos ya permite posturas de columna
distintas por estado de la FSM. [[Benchmark Biomecánico]] §B15c.

## [2026-07-06] feature | PRD-006 alcance 2: kit Humano Duelist jugable
El input real deja el prototipo 0 atrás: LMB/F arranca el combo ×4 del
CombatComponent (buffer generoso; durs sincopadas con los números B15:
0.40/0.32/0.46/0.62), RMB contextual en melee = guardia (hold bloquea,
press abre la ventana ESTRICTA de parry Roba — B15b), momentum→daño se
captura al arrancar el swing (el slide alimenta el golpe aunque la ley
sprint↔arma frene el cuerpo el mismo tick), y el lunge de la bestia viaja
como HitPayload por la guardia del jugador (parry → stun ~2 s medido en
Sifu). **Anti-objetivo resuelto por enrutamiento de input:** try_attack()
intacto, solo autotests históricos lo llaman. QA: test_combat/core/
locomotion/ads ALL_PASS · autotest_slice ALL_PASS · autotest_biomech
ALL_PASS · wilds 280 fps. Decisiones en [[PRD-006 Combate mínimo]].
Pendiente: playtest del director (feel) antes del alcance 3.

## [2026-07-06] ingest | B15b: tutorial completo de Sifu (28 clips) — parry y guard break medidos
El director grabó las lecciones completas del tutorial de Sifu (Structure
& Block / Deflect / Parry / Avoid / Special / Command Attacks) + 2 peleas
reales. Identificación por frame del nombre de lección en pantalla +
detección de congelados YDIF en los 28 clips. **Cerrados los 3 faltantes
de la v3:** parry exitoso = clang con hit-stop 3 f (un frame MÁS que el
golpe normal: el premio está en el freeze) + riposte ~0.3 s + stun ≥0.85 s;
guard break al jugador = burst + golpe gratis + ~1.0 s de stagger sin
control; bloqueo bajo special = cede terreno deslizando (→
PushPullComponent). Bonus: los fallos grabados muestran el feedback
"Too Early" — ventana de parry estricta que castiga el spam. Trampas de
método documentadas: pausas pedagógicas de ~18 f del tutorial y freezes
de idle en escenas oscuras NO son hit-stops. [[Benchmark Biomecánico]]
§B15b + consecuencias 6–8; Task-Board y Current-State al día.

## [2026-07-06] ingest | B15 ✅: benchmark observacional medido (3 clips del director)
Clips 60 fps de Sifu/Fortnite/Sable analizados frame a frame (hojas de
contacto ffmpeg + perfil YDIF por frame para detectar hit-stops e
impactos). Resultado en [[Benchmark Biomecánico]] §v3 — números medidos,
no estimados: **Sifu** hit-stop 2f normal / 3f pesado (congelado GLOBAL),
combo sincopado (16f/8f/29f entre impactos), viaje a contacto 2–3f,
contacto ≈60% del ciclo (**valida la frontera 0.58 de weapons.json**),
Double Palm 32f windup + 24f follow. **Fortnite** movilidad no
bloqueante: aterrizaje ~6f sin cortar sprint, slide entra/sale en ~6f,
salto 34f de aire. **Sable (LA pregunta clave): raíz CONTINUA cada
frame + holds de ~4f solo en extremidades + tela suave encima —
validación 1:1 de nuestro canon A/B; el body pop descartado coincide
con la referencia.** Faltantes del clip: parry/guard break, mantle
(pedir clip extra solo si el alcance 2 los pide). Task-Board y
Current-State actualizados; consecuencias listadas para el alcance 2
(hit-stop budget, síncopa de dur, reacción al frame siguiente).

## [2026-07-06] state | Cierre de sesión: B14 + A/B + alcance 1 + articulación
Sesión completa en un día. Recorrido: **B14 ✅** (benchmark v2 AAA — motion
matching descartado, camino Sifu/HZD validado; la v1 quedó ratificada de
facto por 4 rondas de A/B en vivo) → **A/B del stepping CERRADO** (canon:
2s solo extremidades, cuerpo suave; body pop probado en 3 variantes y
descartado, queda tras toggle) → **PRD-006 alcance 1 ✅** (4 componentes +
HitPayload + weapons.json + curvas trifásicas; test_combat 41/41; PR por
merge local) → fix melee vivo (play_strike no estaba conectado al juego)
→ **ronda de articulación ✅ aprobada** (follow-through + lag abierto +
columna 2 segmentos) tras feedback "legos/playmobil" del director.
Lecciones nuevas: follow-through vs tope de bisagra; A/B de percepción
siempre con zoom. **Próxima sesión: alcance 2 (kit Duelist jugable)** —
primera decisión: cómo convive el reemplazo del combate con el
autotest_slice histórico. Master limpio, todo pusheado.

## [2026-07-06] playtest | Ronda de articulación APROBADA por el director
Veredicto en vivo tras #1+#2+#3: "se ve bien". La ronda completa contra
el feedback "legos/playmobil": #2 mató el frenar-en-seco (follow-through
amortiguado), #1 el todo-llega-junto (lag abierto con overlap real), #3
el torso-monobloque (columna lumbar+torácica). Lo que queda de lectura
de juguete es etapa: mesh de bloques (pase visual en producción del
slice) y pies sin IK (C4). Cerrada la ronda; el rig queda como base de
animación del alcance 2.

## [2026-07-06] playtest | Articulación #1+#3: lag abierto + columna en 2 segmentos
Director tras la #2: "vamos en dirección correcta" → aplicadas las otras
dos. **#1:** CHAIN_LAG abierto (0/0.08/0.16/0.22 + `chest` 0.12) — más
overlap entre segmentos, con el pico del codo aún pegado al cierre de la
ventana activa (k≈0.67) para que la mano no conecte tarde. **#3:** la
columna deja de ser monobloque — `upper_spine` (torácico, ROM propio ~60%
del lumbar) carga torso/strap/brazos/cuello/cabeza; en el strike el twist
se reparte 45% lumbar + 62% torácico con lag de pecho (el torso se
ENROSCA); fuera del strike, capa de follow (38% twist / 30% lean, lagged).
Fix en el camino: release del codo -0.10→-0.085 — el follow-through
oscilaba +0.036 y el tope de extensión es +0.03 (lección nueva en
[[Lecciones]]). QA: core, combat, biomech, rig, scenes, slice — todo
ALL_PASS. Pendiente: veredicto del director de la ronda completa (1+2+3).

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
Curvas v2 del strike en `rig_biomech.segment_offset` (acción #2 de
[[Benchmark Biomecánico]]): coil con moving hold, release back-out con
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
