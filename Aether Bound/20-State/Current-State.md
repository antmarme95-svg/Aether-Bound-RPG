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
- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN:**
  1. **Alcance 5 (Feature Loop):** greybox con spawns parametrizables
     + `autotest_combat.gd` — cierra PRD-006 y abre el Gate 1.
  2. Medir en el próximo clip del director: parry, síncopa, los
     hit-stops (alcance 4) y AHORA la presión enemiga (piden cámara
     quieta y combos limpios contra UNA bestia; el pipeline B15 ya sabe
     contar hit-stops).
  3. Backlog C4 (cuando toque el pase de poses): postura de columna
     por gait (B15c) + canal airborne del rig (B15d #6 — el salto hoy
     no tiene pose).
- **PRD-006 en curso** (Feature Loop; alcances 0 y 1 mergeados a master):
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
  - Después del alcance 4 (✅ código): alcance 5 (greybox +
    autotest_combat) → PRD-007 (Dagna + Springboard T1). Gate 1:
    pelear junto a Dagna en greybox ≥60 FPS.
- **Animación — canon fijado por A/B (2026-07-06, 3 rondas):** stepping
  EN 2s (12 Hz) SOLO en extremidades; cuerpo/raíz suaves a 60. Body pop
  descartado (mecanismo queda tras `body_pop_on_twos` OFF). Tecla T
  cicla los 3 modos in-game. [[Benchmark Biomecánico]] **RATIFICADO por
  el director (2026-07-06 noche)** — la condición se cumplió vía
  B15d–B15g: canon validado midiendo nuestra propia build + playtest.
- **Sesiones de arte (2026-07-04, todas cerradas):** fenotipos ✅ (B12) ·
  keyframes dawn/dusk ✅ + regla nocturna · Speck trilogía ✅ (B9 arte) ·
  golden scene ✅ (B11) · Dagna ✅ (B1 1/9).
- **Branch actual:** `master` (todo mergeado; último PR: tuning de
  presión vía merge local `--no-ff`). Sondas temporales `tests/tmp_*.gd`
  (step, vignette, reactions, duel_pair, spawnflag, timefeel, pressure)
  quedan hasta cerrar PRD-006 completo.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
