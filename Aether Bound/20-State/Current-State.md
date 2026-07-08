---
status: vivo
updated: 2026-07-07
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **Milestone:** Fase 1 del [[Plan-de-Produccion]] — combate mínimo del
  vertical slice **"Slice of Bond"** (Humano Duelist × Dagna).
- **B15 ✅ (2026-07-06): benchmark observacional medido** — los 3 clips
  del director analizados frame a frame → [[Benchmark Biomecánico]] §v3.
  Números clave para el alcance 2: hit-stop 2f normal / 3f pesado
  (congelado global), reacción del golpeado al frame siguiente, combo
  sincopado (no uniforme), frontera de release 0.58 VALIDADA (contacto
  ≈60% del ciclo), estados de movilidad no bloqueantes (~0.1 s), y
  **Sable confirma nuestro canon 1:1: raíz continua + stepping solo en
  extremidades**. **B15b (misma tarde): el director grabó el tutorial
  COMPLETO de Sifu (28 clips) — los 3 faltantes quedaron medidos:**
  parry (hit-stop 3 f > 2 f del golpe normal, riposte ~0.3 s, stun
  ≥0.85 s), guard break (~1.0 s de stagger sin control), y el bloqueo
  cede terreno bajo golpes pesados (→ PushPullComponent). Ver
  [[Benchmark Biomecánico]] §B15b (consecuencias 6–8 para el alcance 2).
  Único faltante: mantle de Fortnite (irrelevante hasta C2).
  **B15d (misma tarde): el director grabó NUESTRA build y se midió con
  el mismo pipeline → [[Benchmark Biomecánico]] §B15d (AS IS vs TO BE).**
  Confirmado: 0 hit-stops en combate (esperado, alcance 4) y locomoción
  ya alineada con Sable (raíz continua + holds ~4–5 f). Hallazgos
  nuevos: la bestia reacciona solo con flash blanco (pose idéntica — sin
  reacción corporal) y el daño al jugador es un tinte de pantalla >1 s
  que tapa la lectura. Salvedad (cerrada a medias por B15e: kit activo
  confirmado; síncopa aún sin medir). Ampliado
  con el running jump: aire 42 f = analítica del código exacta (0.70 s,
  ~8 f más flotante que Fortnite), landing no bloqueante ✅, pero el
  rig NO tiene canal airborne — el salto no tiene pose (gait sin
  silueta, extiende B15c).
- **PRD-006 alcance 2 ✅ CÓDIGO (2026-07-06): kit Humano Duelist
  jugable.** Combo ×4 con buffer generoso y durs sincopadas (B15), RMB
  contextual = guardia/parry Roba (ventana estricta), momentum→daño
  capturado al arrancar el swing, ley sprint↔arma, lunge enemigo vía
  HitPayload+guardia (parry → bestia stunned ~2 s). La decisión de
  diseño quedó resuelta por ENRUTAMIENTO DE INPUT: `try_attack()` viejo
  intacto y solo llamado por autotests históricos (`autotest_slice`
  ALL_PASS). Decisiones documentadas en el PRD.
- **B15e ✅ (2026-07-06 noche): playtest dirigido del kit Duelist
  medido.** Veredicto del director: "los fundamentals existen, pero no
  es ni de cerca la experiencia de Sifu" — y los números lo localizan
  ([[Benchmark Biomecánico]] §B15e): 8 tintes rojos a pantalla completa
  en 11.4 s de pelea (el evento visual MÁS grande del clip; wash ~50 %
  del combate), jugador golpeado sin cambio de pose, bestia solo flash
  (kit confirmado activo), patrón resultante = trade-fest (tanquear es
  óptimo). Todo el feedback sigue siendo cromático; nada corporal ni
  temporal. Salvedad B15d cerrada a medias: la síncopa del combo sigue
  sin ser medible con ese encuadre + wash encima.
- **Fix del tinte de daño ✅ (2026-07-06, adelantado por B15e):** el
  wash plano (`ColorRect` alpha 0.55 full-rect en `hud.gd`) es ahora un
  vignette real de bordes (shader canvas_item radial, centro SIEMPRE a
  alpha 0) con decay en dos fases: fuerte ≤0.2 s + cola ≤0.3 s.
  Verificado con sonda visual `tests/tmp_vignette.gd` (frames t=0 /
  0.1 / 0.25 / 0.5 s) + `autotest_ui` y `autotest_slice` ALL_PASS.
  Con esto el próximo clip del director ya permite medir la síncopa.
- **PRD-006 alcance 3 ✅ CÓDIGO (2026-07-06 noche): reacciones
  corporales + par light/heavy.** (a) La bestia tiene `receive_strike()`:
  HitPayload → GuardComponent → flinch/stagger/posture break **animados
  en el cuerpo** (head snap, roll lateral, derrumbe con patas abiertas),
  FSM suspendida durante stagger/broken y ventana de castigo (daño
  ×1.5). (b) El jugador acusa el golpe con `rig.play_flinch()` (head
  snap a 60 fps + recoil de columna en el reloj de pose). (c)
  `enemy_humanoid.gd`: light (saber rápido, postura frágil, encadena) y
  heavy (maul, torre de Equilibrio, carga de 0.8–1.0 s) sobre el MISMO
  CharacterRig con el strike hip-first — el telegraph es la biomecánica.
  Parry Roba contra ellos → stun 2 s. QA: test_core/test_combat/
  autotest_slice/autotest_ui ALL_PASS; sondas visuales `tmp_reactions` y
  `tmp_duel_pair`. **Pendiente: playtest del director (feel).**
- **B15f (2026-07-06 noche): playtest del alcance 3 PARCIAL ✅** — en
  gameplay real: cero washes (daño = banda de borde, centro limpio) y
  la bestia acusa con el CUERPO (roll/postura baja legibles). Los 2
  asesinos de B15e resueltos y verificados. Sin salir en cámara: flinch
  del jugador, par light/heavy (el boot no llevó `--spawn=duelpair`) y
  síncopa. [[Benchmark Biomecánico]] §B15f.
- **B15g ✅ (2026-07-06 noche): Playtest Loop del alcance 3 CERRADO** —
  el par verificado en juego real (5/7): spawn por flag, siluetas por
  rol sin leer color, swing del maul legible en arco completo,
  reacciones/muertes corporales, vignette limpio. Pendientes de
  medición: parry vs humanoides y síncopa. **Hallazgo de feel: presión
  enemiga baja** (≈1 golpe/2–3 s se lee pasivo) → candidatos de tuning
  en [[Benchmark Biomecánico]] §B15g.
- **PRD-006 alcance 4 ✅ CÓDIGO (2026-07-07): canales 1–3 de la
  [[Game Feel Bible]] como sistema reutilizable.** Autoload `Feel` +
  lógica pura `combat/time_feel.gd` / `combat/trauma_shake.gd`
  (headless-testable, lista para PRD-007). Canal 1: hit-stop 2f/3f
  GLOBAL por masa de arma (números B15 medidos; ×1.5 golpe de muerte,
  50% al recibir, cap 1 por 100 ms), parry Roba = clang 3f (B15b) +
  dilation 0.2×0.35 s + sting de dos notas sintetizado (placeholder
  hasta B8). Canal 2: shake trauma² Perlin, decay 1.2/s, caps 0.25 m /
  2° / 0.6. Canal 3: combat framing (FOV +4°, lift, histéresis 2 s) +
  soft-aim cono 30° total. `HitPayload.weapon_mass` nuevo. QA:
  test_combat +22 asserts, sonda en juego real `tmp_timefeel` (clang
  3 f exactos, dilation 0.354 s), test_core/slice/ui ALL_PASS, FPS
  491/336. Decisiones en el PRD. **Pendiente: playtest del director
  (feel).** Esto cierra el B15e #1 (la mitad temporal contra Sifu).
- **Tuning de presión enemiga ✅ CÓDIGO (2026-07-07, B15g):** el par
  humanoide ya no se congela entre golpes. En `enemy_humanoid.gd`:
  recover del light 0.55→0.42 s, `chain_prob` data-driven (light 0.72,
  heavy 0.0), y **circle-strafe durante recover** (tangente + corrección
  radial al anillo de ataque; sentido que alterna). El heavy sigue lento
  pero ACECHA. Verificado por sonda `tmp_pressure` en juego real:
  `recover_path` del light ≈0 → 3.55 m, heavy 3.56 m; loop de golpes
  vivo (light 6 / heavy 5 strikes en 8 s). **Pendiente: playtest del
  director.**
- **PRD-006 alcance 5 ✅ CÓDIGO (2026-07-07): greybox + spawns
  parametrizables + `autotest_combat.gd` — CIERRA PRD-006 y abre el
  Gate 1.** Escena nueva `scenes/combat_arena.gd`: blockout barato (suelo
  plano + anillo de límite + postes de parallax) que implementa el
  contrato de escena completo (`get_height`/`clamp_position`/`get_bounds`/
  `player_spawn`/...). Parser `gameplay/spawn_spec.gd`: spec tolerante
  (`light,heavy`, `2light+1heavy`, `duelpair` alias, vacío→default).
  Estado FSM `ARENA` + `--skip=arena`; helper `_spawn_humanoids`
  COMPARTIDO con WILDS — el `--spawn=duelpair` viejo se generalizó (back-
  compat verificado por `tmp_spawnflag`). `tests/autotest_combat.gd`
  (windowed): verifica spawn parametrizado (2 kinds), parry Roba→stun,
  kill loop del kit Duelist real (ambos muertos en 940 frames) y muestra
  FPS. **FPS del greybox 177 → gate ≥60 holgado** (escena trivial;
  captura `test_out/combat_arena.png`). QA: test_core/slice/ui ALL_PASS,
  `tmp_spawnflag` PASS. Lección nueva: golpear a un enemigo `dying`
  reinicia su timer de muerte (dejar de pegarle al entrar en dying).
  **Pendiente: playtest del director del feel (alcances 4 + tuning).**
- **Playtest del director (clip 2026-07-08) → feedback del kit defensivo.**
  Notas: (1) RMB mantener no generaba guardia — sin pose ni cambio de
  feedback (el rojo salía igual al bloquear); (2) LMB/RMB-tap funcionan
  pero poco evidentes del lado del jugador (sobre todo el parry); (3) el
  "status gráfico" del enemigo no le encanta (→ tarea de arte aparte).
- **Capa 1 del fix ✅ CÓDIGO (2026-07-08): la guardia gana cuerpo +
  feedback propio.** (a) Rig: `set_guard(bool)` = pose de bloqueo
  sostenida (antebrazos cruzados al frente + arma arriba + brace),
  blend in/out, compone sobre el gait y bajo el strike; el flinch acusa
  el golpe SIN bajar la guardia. Dentro de ROM (constraint_report vacío).
  (b) Feedback: un golpe BLOQUEADO deja de pintar el vignette rojo —
  ahora destello ACERO (`COL_BLOCK`) + chispa de deflexión en el arma
  (`_spawn_guard_spark`); el rojo queda SOLO para daño limpio. Wiring:
  `stats.take_damage(..., blocked)` → payload al HUD; `_set_guard` llama
  `rig.set_guard`. Sonda visual `tests/tmp_guard.gd` (neutral/guardia/
  3-4/flinch). QA: test_core/combat/slice/ui ALL_PASS. **Pendiente:
  visto bueno del director en vivo (`Start-Playtest-Greybox.bat`) antes
  de la Capa 2 (tell del parry) y Capa 3 (legibilidad del swing).**
- **Dagna gráfica en Godot ✅ (2026-07-07): pipeline lámina → config →
  rig PROBADO** (entregable extra pedido por el director para *liberar su
  diseño*). Sistema nuevo reutilizable: `godot/data/characters.gd`
  (configs de personajes nombrados: origin+clase+fenotipo+piezas firma)
  + `godot/character/character_signature.gd` (extras de lámina —
  túnica/hombreras/cuña de trenza/tatuajes de gremio/martillo — colgados
  aditivos sobre el rig, cero cambios al rig base). Dagna se lee
  inconfundible vs. `dagna-v1.png`; **la cuña de la trenza queda
  garantizada y legible en perfil** (la ficha lo exigía). Sonda de
  presentación `tests/tmp_dagna.gd` (frente/espalda/perfil/detalle,
  cámara nivelada). **Solo capa de LOOK** — el ROM/IK enano y su
  animación siguen diferidos (C4 + PRD-007). QA: test_core/autotest_slice
  ALL_PASS, tmp_dagna limpio. Ejecución creativa por subagente **Fable**;
  orquestación + fixes de fidelidad (mirada nivelada, cuña) por mí.
  **Nota: la sesión de Fable se cortó por límite de gasto mensual de la
  cuenta.** Demo adicional: `tmp_dagna_golden.gd` — Dagna bajo el pase
  Melancolía Gráfica en la golden scene (el registro del Art Bible SÍ
  aterriza en el rig; el greybox era la anti-referencia).
  **Veredicto del director (2026-07-07): identidad liberada, pero la
  ANATOMÍA está lejos de la lámina** — el cuerpo base hereda gráficos del
  prototipo pre-reset que ya estaban corruptos; debió hacerse rework
  completo. → **C6 (rework anatómico del cuerpo base)** en el Task-Board;
  **ventana RATIFICADA (2026-07-07): entre el Gate 1 y la Fase 2, junto
  al pase de poses C4** (cláusula de escape: se adelanta a PRD-007 si en
  el Gate 1 los cuerpos impiden juzgar el feel).
- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN:**
  0. **PRD-006 CERRADO ✅** (alcances 0–5 en código). Falta solo el
     **playtest del director** del feel acumulado (alcances 4 + tuning de
     presión) — el greybox (`--skip=arena --spawn=<spec>`) es el banco
     ideal para grabar el clip: cámara quieta, spawns controlados.
  1. **Abrir PRD-007 (Dagna + Seismic Springboard T1):** el aliado
     jugable junto al que se pelea en el greybox. Gate 1 = pelear junto
     a Dagna en greybox ≥60 FPS (el greybox y su FPS ya están listos).
  1b. El **pipeline de personajes** (`characters.gd` + `signature.gd`) ya
     está listo para replicar con los otros 8 pivotes cuando toque
     (Fase 4 / concept art). Dagna es el molde.
  2. Medir en el próximo clip del director: parry, síncopa, los
     hit-stops (alcance 4) y AHORA la presión enemiga (piden cámara
     quieta y combos limpios contra UNA bestia; el pipeline B15 ya sabe
     contar hit-stops).
  3. Backlog C4 (cuando toque el pase de poses): postura de columna
     por gait (B15c) + canal airborne del rig (B15d #6 — el salto hoy
     no tiene pose).
- **PRD-006 CERRADO ✅ en código** (Feature Loop; alcances 0–5). Falta
  solo el playtest del director del feel:
  - **Alcance 0 ✅** rig restringido (ROM + constraints) + strike
    hip-first, movilidad aprobada.
  - **Alcance 1 ✅** (2026-07-06): `godot/combat/` — CombatComponent /
    GuardComponent / EnergyComponent / PushPullComponent + HitPayload +
    `weapons.json`, instanciados NEUTROS en jugador y bestia; curvas
    trifásicas del strike (coil hold / release overshoot / settle con
    follow-through). QA: `test_combat` 41/41.
  - **Ronda de articulación ✅ APROBADA en vivo** (feedback "legos"):
    follow-through amortiguado por segmento + lag de cadena abierto +
    **columna en 2 segmentos** (lumbar+torácico, adelanto de C4). El
    melee vivo anima `play_strike` (fix: antes solo lo veían los
    autotests). Boot de prueba melee:
    `--origin=ironblooded --cls=warrior --skip=wilds`.
  - **Alcance 5 ✅ código** (2026-07-07): greybox `combat_arena.gd` +
    spawns parametrizables (`spawn_spec.gd`) + `autotest_combat.gd`.
    Siguiente hito: PRD-007 (Dagna + Springboard T1). Gate 1: pelear
    junto a Dagna en el greybox ≥60 FPS (greybox ya a 177 FPS).
- **Animación — canon fijado por A/B (2026-07-06, 3 rondas):** stepping
  EN 2s (12 Hz) SOLO en extremidades; cuerpo/raíz suaves a 60. Body pop
  descartado (mecanismo queda tras `body_pop_on_twos` OFF). Tecla T
  cicla los 3 modos in-game. [[Benchmark Biomecánico]] **RATIFICADO por
  el director (2026-07-06 noche)** — la condición se cumplió vía
  B15d–B15g: canon validado midiendo nuestra propia build + playtest.
- **Sesiones de arte (2026-07-04, todas cerradas):** fenotipos ✅ (B12) ·
  keyframes dawn/dusk ✅ + regla nocturna · Speck trilogía ✅ (B9 arte) ·
  golden scene ✅ (B11) · Dagna ✅ (B1 1/9).
- **Branch actual:** `master` (último PR local `--no-ff`: Capa 1 del fix
  de feedback del kit defensivo — guardia con cuerpo + bloqueo acero).
  `autotest_combat.gd` es un gate permanente. Lanzador de doble clic para
  el playtest en el greybox: `Start-Playtest-Greybox.bat` (raíz).
  Sondas temporales `tests/tmp_*.gd` (step, vignette, reactions,
  duel_pair, spawnflag, timefeel, pressure, dagna, guard) quedan hasta el
  visto bueno del director / validar el pipeline de personajes.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
