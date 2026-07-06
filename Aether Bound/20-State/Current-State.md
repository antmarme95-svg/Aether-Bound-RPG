---
status: vivo
updated: 2026-07-06
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **Milestone:** Planeación de producción (el GDD v2.2 quedó cerrado y
  bendecido — commit 3969646; congelado como fuente raw en `docs/GDD.md`).
- **Objetivo actual:** plan de producción + definición del vertical slice
  narrativo **"Slice of Bond"** — probar Bond/links/traición con 1 celda de
  jugador + 1 Pivote.
- **Próxima prioridad:**
  1. ~~B14~~ ✅ (2026-07-06): benchmark v2 AAA hecho — [[Benchmark
     Biomecánico]] §v2. Veredicto: motion matching descartado; camino
     validado = Sifu (handkey trifásico) + foot IK de HZD (→C4).
     **Pendiente del director: ratificar la página (v1+v2) y el A/B en
     vivo del stepping en 2s.**
  2. Siguiente: [[PRD-006 Combate mínimo]] alcance 1 (4 componentes
     + HitPayload) + curvas anticipación/overshoot del strike (= la
     estructura trifásica de Sifu).
- **PRD-006 en curso** (Feature Loop, branch `feat/prd-006-combate`,
  mergeado a master al cierre de sesión): **alcance 0 ✅** — rig humano
  restringido (ROM + constraints cada frame) + strike hip-first; movilidad
  aprobada "como primer saque" con 2 rondas de feedback aplicadas (coil
  amplificado, cadera como motor, crouch-walk v2). **Pose stepping EN 2s**
  implementado tras toggle `animation_on_twos` ([[Benchmark Biomecánico]],
  propuesto) — **pendiente: A/B en vivo del director + ratificar página**.
  Después del alcance 1: PRD-007 (Dagna + Springboard T1). Gate 1: pelear
  junto a Dagna en greybox se siente bien a ≥60 FPS. Pareja: **Humano
  Duelist × Dagna** ([[Slice of Bond]] ratificado completo).
- **Sesiones de arte (2026-07-04, todas cerradas):** fenotipos ✅ (B12) ·
  keyframes dawn/dusk ✅ + regla nocturna · Speck trilogía ✅ (B9 arte) ·
  golden scene ✅ (B11, look = sistema replicable) · Dagna ✅ (B1 1/9).
  Queda del plan original: Game Feel Bible (B10).
- **Branch actual:** `master` (todo mergeado; PR #4 fue el último).
- **Motor: GODOT CONFIRMADO** (2026-07-04, ADR-002 cerrada con la evidencia
  de la golden scene).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** ninguna pendiente de Fase 0 (C1 y C5 cerradas
  2026-07-05); ver [[Task-Board]] frente C para lo que abre la Fase 1.
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
