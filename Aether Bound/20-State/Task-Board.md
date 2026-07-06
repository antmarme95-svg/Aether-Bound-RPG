---
status: vivo
updated: 2026-07-06
---

# Task Board — preproducción

> Sucesor del `BACKLOG.md` raíz (los sprints históricos completos del
> prototipo quedan archivados allí). Estados: ✅ done · 🔄 in-progress ·
> ⛔ blocked · ⬜ todo. Actualizar tras **cada** tarea (regla de oro,
> [[SCHEMA]]).

## Frente A — Producción / vertical slice

| ID | Tarea | Status | Notas |
|---|---|---|---|
| A1 | Plan de producción macro (fases, orden de frentes) | ✅ | RATIFICADO 2026-07-05: [[Plan-de-Produccion]] (Fases 0–4, gates de playtest, PRD-006…012). **Fase 0 ✅ (2026-07-05); fase actual: 1** |
| A2 | Slice of Bond: pareja jugador×Pivote | ✅ | RATIFICADA: **Humano Duelist × Dagna** (Seismic Springboard) — [[Slice of Bond]] |
| A2b | Slice of Bond: alcance completo (PRD del slice) | ✅ | RATIFICADO 2026-07-05: 4 escenas (Nido → Cinder Ascent → eco Sunken Archive → coda Bond vacío), sistemas in/out, 45–60 min — [[Slice of Bond]] |
| A3 | Decisión de motor | ✅ | **GODOT CONFIRMADO** (2026-07-04) — evidencia: golden scene B11; ver ADR-002 |

## Frente B — Diseño pendiente (los ❓ del GDD §8)

| ID | Tarea | Status | Página afectada |
|---|---|---|---|
| B1 | Fichas completas de los 9 Pivotes (bio, arco, visual) + naming definitivo | 🔄 1/9 | [[Dagna]] COMPLETA (ficha ratificada + `dagna-v1.png` canónica); quedan 8 fichas |
| B2 | Tablas de C1/C2/C4 por celda + sus links + links directos de Speck E2 | ⬜ | [[El Quinteto]] |
| B3 | Lista definitiva de ~7 Momentos de Persona + economía de Standing + contenido ruta Conqueror | ⬜ | [[The Tether]], [[Speck]] |
| B4 | Desambiguación de Bond con dos links posibles; ¿ping opcional? | ⬜ | [[Bond y el Bond Vacío]] |
| B5 | Asentamientos secundarios; tiempos de viaje; fast travel diegético | ⬜ | [[La Rueda]] |
| B6 | Estado post-final jugable; epílogos; variantes C3 vivo/muerto en finales 2–3 | ⬜ | [[Los 4 Finales]] |
| B7 | Progresión de personaje (skills/equipo/crafting) | ⬜ | [[Progresión y Contrato]] |
| B8 | Dirección de audio/música (semilla: sting de dos notas) | ⬜ | [[Bond y el Bond Vacío]] |
| B9 | Diseño visual de Speck (3 estadios) + re-naming de sub-estilos VFX | 🔄 arte ✅ | [[Speck]] — diseño visual RATIFICADO (trilogía en `90-Raw/concept/`); solo falta el re-naming de sub-estilos VFX |
| B10 | Game Feel Bible §6.3 (hit-stop, screen-shake budget, cámara de combate) | ✅ | RATIFICADA 2026-07-05: [[Game Feel Bible]] — 4 canales; cámara LIBRE + soft-assist (revisable en Gate 1); tuning fino por montage en Fase 1 |
| B11 | Golden scene: keyframes + prueba técnica 4 capas | ✅ | CERRADA (rondas 1-2 aprobadas y mergeadas). Look = sistema replicable: 3 shaders + foliage_clump.png + PRESETS. Fine-tuning diferido a producción del slice: corteza de ramas en close-up, facetas del cristal de cerca, banding del terreno lejano. `Start-GoldenScene.bat` |
| B12 | Fenotipos y creación de personaje | ✅ | [[Fenotipos y Creación de Personaje]] ratificada 2026-07-04, con 5 láminas canónicas en `90-Raw/concept/` |
| B13 | Generar concept art de fenotipos en Nano Banana 2 (director) | ✅ | 5 láminas en `90-Raw/concept/`; ver [[Fenotipos y Creación de Personaje]] |
| B14 | **Benchmark biomecánico v2: state of the art AAA** — Assassin's Creed, 007 First Light, Horizon Zero Dawn, Star Wars Jedi, y **Sifu** (biomecánica, movilidad y combate) | ✅ | Research 2026-07-06 volcado en [[Benchmark Biomecánico]] §v2 (propuesto — se ratifica junto con la v1). Veredicto: motion matching descartado por costo; camino validado = Sifu (handkey trifásico) + foot IK de HZD (→C4); PRD-006 alcance 1 confirmado como paso correcto |

## Frente C — Técnico (hereda del prototipo)

| ID | Tarea | Status | Notas |
|---|---|---|---|
| C1 | Renombrar V&V → AETHER BOUND (repo/README/strings) | ✅ | 2026-07-05: config/name, boot prints, README (título + roadmap V&V histórico). Identificadores internos retenidos adrede (save path, sentinels, web congelado) |
| C2 | Implementar Mantling + Escalada zonificada sobre la FSM | ⬜ | [[Locomoción]]; tuning montage+playtest |
| C3 | Implementar combate 4-componentes + HitPayload; DamageProfiles por celda; enemigos | 🔄 | Spec Fase 1: [[PRD-006 Combate mínimo]] (propuesto 2026-07-05) — kit Duelist + 2 enemigos; resto de celdas post-slice |
| C4 | Rig biomecánico: constraints + IK + 3 ROM | 🔄 | [[Movilidad Realista]]; prioridad sobre cantidad de anims. **Parcial (ROM humano + constraints + transferencia de peso) entra como alcance 0 de [[PRD-006 Combate mínimo]]** |
| C5 | T1: fix `--skip=wilds` en boot live | ✅ | 2026-07-05: `start()` invoca `_apply_skip_arg()` tras el fast-path a OFFICE. Verificado live por log FSM (∅→CREATION→OFFICE→WILDS) |
