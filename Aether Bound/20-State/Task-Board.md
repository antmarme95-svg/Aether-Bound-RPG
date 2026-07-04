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
| A2 | Definir "Slice of Bond": celda jugador + Pivote + alcance | ⬜ | Gate de casi todo lo demás |
| A3 | Decisión de motor Godot vs. Unreal | ⛔ diferida | Se evalúa contra biblias + slice (ADR-002) |

## Frente B — Diseño pendiente (los ❓ del GDD §8)

| ID | Tarea | Status | Página afectada |
|---|---|---|---|
| B1 | Fichas completas de los 9 Pivotes (bio, arco, visual) + naming definitivo | ⬜ | [[Los 9 Pivotes]] |
| B2 | Tablas de C1/C2/C4 por celda + sus links + links directos de Speck E2 | ⬜ | [[El Quinteto]] |
| B3 | Lista definitiva de ~7 Momentos de Persona + economía de Standing + contenido ruta Conqueror | ⬜ | [[The Tether]], [[Speck]] |
| B4 | Desambiguación de Bond con dos links posibles; ¿ping opcional? | ⬜ | [[Bond y el Bond Vacío]] |
| B5 | Asentamientos secundarios; tiempos de viaje; fast travel diegético | ⬜ | [[La Rueda]] |
| B6 | Estado post-final jugable; epílogos; variantes C3 vivo/muerto en finales 2–3 | ⬜ | [[Los 4 Finales]] |
| B7 | Progresión de personaje (skills/equipo/crafting) | ⬜ | [[Progresión y Contrato]] |
| B8 | Dirección de audio/música (semilla: sting de dos notas) | ⬜ | [[Bond y el Bond Vacío]] |
| B9 | Diseño visual de Speck (3 estadios) + re-naming de sub-estilos VFX | ⬜ | [[Speck]], [[Matriz Raza x Rol]] |
| B10 | Game Feel Bible §6.3 (hit-stop, screen-shake budget, cámara de combate) | ⬜ | [[Combate]], [[Art Bible]] |
| B11 | Concept art: 3 keyframes + prueba técnica 4 capas ("golden scene") | ⬜ | [[Art Bible]] |

## Frente C — Técnico (hereda del prototipo)

| ID | Tarea | Status | Notas |
|---|---|---|---|
| C1 | Renombrar V&V → AETHER BOUND (repo/README/strings) | ⬜ | [[Nomenclatura]] |
| C2 | Implementar Mantling + Escalada zonificada sobre la FSM | ⬜ | [[Locomoción]]; tuning montage+playtest |
| C3 | Implementar combate 4-componentes + HitPayload; DamageProfiles por celda; enemigos | ⬜ | [[Combate]] |
| C4 | Rig biomecánico: constraints + IK + 3 ROM | ⬜ | [[Movilidad Realista]]; prioridad sobre cantidad de anims |
| C5 | T1: fix `--skip=wilds` en boot live | ⬜ | Deuda de tooling (diagnosticada en BACKLOG.md) |
