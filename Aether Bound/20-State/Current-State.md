---
status: vivo
updated: 2026-07-06
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
- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN (actualizado tras B15e):**
  1. **Fix del tinte de daño ADELANTADO** (era nota del alcance 4; es
     barato y es el mayor destructor de lectura medido): wash → vignette
     de bordes, fuerte ≤0.2 s, cola ≤0.3 s, centro de pantalla nunca
     >40 % alpha. Prerequisito práctico para volver a medir la síncopa.
  2. **Alcance 3 (2 enemigos con reacciones por Equilibrio)** — ataca
     directo el trade-fest: flinch del jugador al recibir (B15e #4),
     reacción CORPORAL de la bestia (B15d #2/B15e #5), stagger/castigo.
  3. En cola para **alcance 4**: hit-stop 2f/3f + TimeFeel + sting de
     parry (B15e #1: 0 congelados re-medidos).
  4. Backlog C4 (cuando toque el pase de poses): postura de columna
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
  - Después del alcance 2: alcances 3–5 (2 enemigos, feel canales 1–3,
    greybox+autotest_combat) → PRD-007 (Dagna + Springboard T1). Gate 1:
    pelear junto a Dagna en greybox ≥60 FPS.
- **Animación — canon fijado por A/B (2026-07-06, 3 rondas):** stepping
  EN 2s (12 Hz) SOLO en extremidades; cuerpo/raíz suaves a 60. Body pop
  descartado (mecanismo queda tras `body_pop_on_twos` OFF). Tecla T
  cicla los 3 modos in-game. [[Benchmark Biomecánico]] (v1 Sable + v2
  AAA: motion matching descartado, camino Sifu validado) sigue
  `propuesto` — se ratifica al ver el alcance 2 con poses extremas.
- **Sesiones de arte (2026-07-04, todas cerradas):** fenotipos ✅ (B12) ·
  keyframes dawn/dusk ✅ + regla nocturna · Speck trilogía ✅ (B9 arte) ·
  golden scene ✅ (B11) · Dagna ✅ (B1 1/9).
- **Branch actual:** `master` (todo mergeado; último PR: alcance 1 vía
  merge local `--no-ff`). Sondas temporales `tests/tmp_step_*.gd` quedan
  hasta cerrar el alcance 2.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
