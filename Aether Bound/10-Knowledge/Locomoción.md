---
status: ratificado
source: "GDD §4.1"
updated: 2026-07-04
---

# Locomoción — spec v1

**FSM de estado único** (PRD-003/005, ya viva en el prototipo): `Idle ·
Walking(crouch) · Running · Sprinting · Sliding · Airborne · Landing` +
nuevos `Mantling · Climbing_Idle · Climbing_Moving`.

## Ya construido y aceptado (NO se rehace)

Sprint táctico con stamina · slide por momentum (masa, fricción, heading
recto) · supersalto slide→jump (0.90 del vector) · interrupts ≤1 tick ·
fisionomía 9-cell · crouch squat + crouch-jog. Ver
[[Inventario del Prototipo]].

## Nuevo — Mantling 🔶

2 raycasts (pecho + cabeza): pecho impacta y cabeza no ⇒ trepable. Física OFF
+ lerp sincronizado con animación → sale a `Running`. Heavy mantlea más lento
pero bordes más altos; Light encadena mantle→salto.

## Nuevo — Escalada zonificada 🔶

**Anti-BotW deliberado: NO todo es escalable** — solo superficies `Climbable`
(enredaderas, roca rugosa, tuberías). La escalada libre rompería el gating de
[[La Rueda]]; la zonificada lo diseña — **el acceso al Stillwood es un muro de
enredaderas**. Stamina: drena en movimiento, climb-jump de costo fijo, a 0 →
caída + bloqueo de reenganche. Por fisionomía: Heavy sin climb-jump (trepa
como tanque), Light climb-jump doble. **Elegir raza cambia qué montañas son
tuyas.** Skyhook y Seismic Springboard son atajos de escalada
([[Los 9 Links del Pivote]]).

## Regla transversal

**Conservación del impulso en TODA transición** — la velocidad nunca se
resetea al cambiar de estado. Mantle y climb-jump la heredan.

El esqueleto que limita todo esto: [[Movilidad Realista]]. Feel sensorial
pendiente en la Game Feel Bible (→ Task-Board).

**Pendiente (❓):** valores iniciales (ClimbSpeed, drenajes, alturas de mantle
por masa) — tuning montage+playtest; lenguaje visual de `Climbable` en la
[[Art Bible]]. → Task-Board.
