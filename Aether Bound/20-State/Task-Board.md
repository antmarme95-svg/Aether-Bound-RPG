---
status: vivo
updated: 2026-07-04
---

# Task Board — preproducción

> Sucesor del `BACKLOG.md` raíz (los sprints históricos completos del
> prototipo quedan archivados allí). Estados: ✅ done · 🔄 in-progress ·
> ⛔ blocked · ⬜ todo. Actualizar tras **cada** tarea (regla de oro,
> [[SCHEMA]]).

## Frente A — Producción / vertical slice

| ID | Tarea | Status | Notas |
|---|---|---|---|
| A1 | Plan de producción macro (fases, orden de frentes) | ⬜ | El objetivo actual de [[Current-State]] |
| A2 | Slice of Bond: pareja jugador×Pivote | ✅ | RATIFICADA: **Humano Duelist × Dagna** (Seismic Springboard) — [[Slice of Bond]] |
| A2b | Slice of Bond: alcance completo (PRD del slice) | ⬜ | Tramo de La Rueda, sistemas mínimos, duración — [[Slice of Bond]] |
| A3 | Decisión de motor | ✅ | **GODOT CONFIRMADO** (2026-07-04) — evidencia: golden scene B11; ver ADR-002 |

## Frente B — Diseño pendiente (los ❓ del GDD §8)

| ID | Tarea | Status | Página afectada |
|---|---|---|---|
| B1 | Fichas completas de los 9 Pivotes (bio, arco, visual) + naming definitivo | 🔄 | [[Dagna]] escrita (propuesto — la primera y la del slice); quedan 8 |
| B2 | Tablas de C1/C2/C4 por celda + sus links + links directos de Speck E2 | ⬜ | [[El Quinteto]] |
| B3 | Lista definitiva de ~7 Momentos de Persona + economía de Standing + contenido ruta Conqueror | ⬜ | [[The Tether]], [[Speck]] |
| B4 | Desambiguación de Bond con dos links posibles; ¿ping opcional? | ⬜ | [[Bond y el Bond Vacío]] |
| B5 | Asentamientos secundarios; tiempos de viaje; fast travel diegético | ⬜ | [[La Rueda]] |
| B6 | Estado post-final jugable; epílogos; variantes C3 vivo/muerto en finales 2–3 | ⬜ | [[Los 4 Finales]] |
| B7 | Progresión de personaje (skills/equipo/crafting) | ⬜ | [[Progresión y Contrato]] |
| B8 | Dirección de audio/música (semilla: sting de dos notas) | ⬜ | [[Bond y el Bond Vacío]] |
| B9 | Diseño visual de Speck (3 estadios) + re-naming de sub-estilos VFX | 🔄 arte ✅ | [[Speck]] — diseño visual RATIFICADO (trilogía en `90-Raw/concept/`); solo falta el re-naming de sub-estilos VFX |
| B10 | Game Feel Bible §6.3 (hit-stop, screen-shake budget, cámara de combate) | ⬜ | [[Combate]], [[Art Bible]] |
| B11 | Golden scene: keyframes + prueba técnica 4 capas | ✅ | CERRADA (rondas 1-2 aprobadas y mergeadas). Look = sistema replicable: 3 shaders + foliage_clump.png + PRESETS. Fine-tuning diferido a producción del slice: corteza de ramas en close-up, facetas del cristal de cerca, banding del terreno lejano. `Start-GoldenScene.bat` |
| B12 | Fenotipos y creación de personaje | ✅ | [[Fenotipos y Creación de Personaje]] ratificada 2026-07-04, con 5 láminas canónicas en `90-Raw/concept/` |
| B13 | Generar concept art de fenotipos en Nano Banana 2 (director) | ✅ | 5 láminas en `90-Raw/concept/`; ver [[Fenotipos y Creación de Personaje]] |

## Frente C — Técnico (hereda del prototipo)

| ID | Tarea | Status | Notas |
|---|---|---|---|
| C1 | Renombrar V&V → AETHER BOUND (repo/README/strings) | ⬜ | [[Nomenclatura]] |
| C2 | Implementar Mantling + Escalada zonificada sobre la FSM | ⬜ | [[Locomoción]]; tuning montage+playtest |
| C3 | Implementar combate 4-componentes + HitPayload; DamageProfiles por celda; enemigos | ⬜ | [[Combate]] |
| C4 | Rig biomecánico: constraints + IK + 3 ROM | ⬜ | [[Movilidad Realista]]; prioridad sobre cantidad de anims |
| C5 | T1: fix `--skip=wilds` en boot live | ⬜ | Deuda de tooling (diagnosticada en BACKLOG.md) |
