---
status: vivo
updated: 2026-07-06
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **Milestone:** Fase 1 del [[Plan-de-Produccion]] — combate mínimo del
  vertical slice **"Slice of Bond"** (Humano Duelist × Dagna).
- **⚠️ ANTES DE EMPEZAR CUALQUIER COSA la próxima sesión: pedir al
  director la UBICACIÓN de los clips del benchmark observacional (B15)**
  — va a grabar Sifu (combate: jab/combo/cargado/parry/guard break),
  Fortnite (movilidad: sprint/slide/etc.) y posiblemente **Sable** (lo
  va a comprar; timing visual en 2s — incluye la pregunta clave de cómo
  maneja Sable la raíz vs nuestro body pop descartado). Análisis frame a
  frame → tabla comparativa → calibrar `weapons.json`, fases (0.32/0.58)
  y [[Game Feel Bible]] con números reales en vez de valores inventados.
- **PRIMERA TAREA de código: [[PRD-006 Combate mínimo]]
  alcance 2 — kit Humano Duelist jugable.** Combo ×4 sobre
  CombatComponent (ventanas biomecánicas + buffer generoso), parry Roba
  con input real, momentum→daño, ley sprint↔arma. **Decisión de diseño a
  resolver al entrar:** el combate nuevo REEMPLAZA al del prototipo para
  el jugador — definir cómo se mantiene verde el `autotest_slice`
  histórico (anti-objetivo del PRD).
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
